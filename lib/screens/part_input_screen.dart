import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../logic/app_database.dart';
import 'package:drift/drift.dart' as drift;
import '../database_provider.dart';
import '../widgets/selection_display_card.dart';
import '../widgets/app_footer.dart';
import '../widgets/app_drawer.dart';
import '../widgets/home_button_wrapper.dart';
import '../utils/error_handler.dart';

class PartInputScreen extends StatefulWidget {
  final int valueStreamId;
  final String valueStreamName;
  final String companyName;
  final String plantName;

  const PartInputScreen({
    super.key,
    required this.valueStreamId,
    required this.valueStreamName,
    required this.companyName,
    required this.plantName,
  });

  @override
  State<PartInputScreen> createState() => _PartInputScreenState();
}

class _PartInputScreenState extends State<PartInputScreen> {
  final TextEditingController _partNumberController = TextEditingController();
  final TextEditingController _partDescriptionController =
      TextEditingController();
  final TextEditingController _monthlyDemandController =
      TextEditingController();
  final FocusNode _partNumberFocus = FocusNode();
  final FocusNode _partDescriptionFocus = FocusNode();
  final FocusNode _monthlyDemandFocus = FocusNode();
  bool _saving = false;
  bool _loading = true;
  String? _error;
  late AppDatabase db;
  List<Map<String, dynamic>> _parts = [];
  Map<int, bool> _editingStates = {};
  Map<int, TextEditingController> _partNumberControllers = {};
  Map<int, TextEditingController> _partDescriptionControllers = {};
  Map<int, TextEditingController> _monthlyDemandControllers = {};

  @override
  void initState() {
    super.initState();
    DatabaseProvider.getInstance().then((database) {
      db = database;
      _loadParts();
    }).catchError((e) {
      setState(() {
        _error = 'Database initialization failed: $e';
        _loading = false;
      });
    });
  }

  Future<void> _loadParts() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // First, verify the value stream exists and get the correct ID by name
      // This handles cases where the ID might be stale after app restart
      final valueStreamCheck = await db.customSelect(
        '''SELECT vs.id, vs.name 
           FROM value_streams vs 
           JOIN plants p ON vs.plant_id = p.id 
           WHERE vs.name = ? AND p.name = ?''',
        variables: [
          drift.Variable.withString(widget.valueStreamName),
          drift.Variable.withString(widget.plantName),
        ],
      ).get();

      int actualValueStreamId = widget.valueStreamId;

      if (valueStreamCheck.isNotEmpty) {
        actualValueStreamId = valueStreamCheck.first.data['id'] as int;
      } else {
        // Log warning: Value stream not found, using original ID
        debugPrint(
            'Warning: Value stream "${widget.valueStreamName}" not found in plant "${widget.plantName}"');
      }

      // Query parts using the correct value stream ID
      final result = await db.customSelect(
        'SELECT id, part_number, part_description, monthly_demand FROM parts WHERE value_stream_id = ?',
        variables: [drift.Variable.withInt(actualValueStreamId)],
      ).get();

      setState(() {
        _parts = result.map((row) => row.data).toList();
        _editingStates = {for (var part in _parts) part['id']: false};
        _partNumberControllers = {
          for (var part in _parts)
            part['id']: TextEditingController(text: part['part_number'])
        };
        _partDescriptionControllers = {
          for (var part in _parts)
            part['id']: TextEditingController(text: part['part_description'])
        };
        _monthlyDemandControllers = {
          for (var part in _parts)
            part['id']: TextEditingController(
                text: part['monthly_demand']?.toString() ?? '')
        };
        _loading = false;
      });

      // Only check for orphaned parts if no parts were found for this value stream
      if (_parts.isEmpty) {
        await _handleOrphanedParts(actualValueStreamId);
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load parts: $e';
        _loading = false;
      });
    }
  }

  /// Handles orphaned parts that reference non-existent value streams
  Future<void> _handleOrphanedParts(int actualValueStreamId) async {
    try {
      // Check for orphaned parts (parts with value_stream_id that no longer exists)
      final orphanedParts = await db.customSelect('''
        SELECT p.id, p.part_number, p.value_stream_id 
        FROM parts p 
        LEFT JOIN value_streams vs ON p.value_stream_id = vs.id 
        WHERE vs.id IS NULL
      ''').get();

      if (orphanedParts.isNotEmpty && mounted) {
        final shouldFix = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Data Repair Needed'),
            content: Text(
                'Found ${orphanedParts.length} saved parts that are referencing an old value stream configuration.\n\n'
                'Would you like to update these parts to use the current "${widget.valueStreamName}" value stream?\n\n'
                'Parts to update: ${orphanedParts.map((p) => p.data['part_number']).join(', ')}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Update Parts'),
              ),
            ],
          ),
        );

        if (shouldFix == true) {
          // Update orphaned parts to use the current value stream ID
          for (final orphanPart in orphanedParts) {
            await db.customStatement(
              'UPDATE parts SET value_stream_id = ? WHERE id = ?',
              [actualValueStreamId, orphanPart.data['id']],
            );
          }

          // Reload the parts after fixing
          await _loadParts();
        }
      }
    } catch (e) {
      debugPrint('Error handling orphaned parts: $e');
    }
  }

  @override
  void dispose() {
    _partNumberController.dispose();
    _partDescriptionController.dispose();
    _monthlyDemandController.dispose();
    _partNumberFocus.dispose();
    _partDescriptionFocus.dispose();
    _monthlyDemandFocus.dispose();
    for (var controller in _partNumberControllers.values) {
      controller.dispose();
    }
    for (var controller in _partDescriptionControllers.values) {
      controller.dispose();
    }
    for (var controller in _monthlyDemandControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _savePart() async {
    final partNumber = _partNumberController.text.trim();
    final partDescription = _partDescriptionController.text.trim();
    final monthlyDemandText = _monthlyDemandController.text.trim();
    final monthlyDemand =
        monthlyDemandText.isNotEmpty ? int.tryParse(monthlyDemandText) : null;

    if (partNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Part Number is required!')),
      );
      return;
    }

    // Validate monthly demand if provided
    if (monthlyDemandText.isNotEmpty && monthlyDemand == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Monthly Demand must be a valid number!')),
      );
      return;
    }

    // Check for duplicate part numbers
    if (_parts.any((part) =>
        part['part_number']?.toLowerCase() == partNumber.toLowerCase())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('A part with this number already exists!')),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      // Get the correct value stream ID
      final valueStreamCheck = await db.customSelect(
        '''SELECT vs.id FROM value_streams vs 
           JOIN plants p ON vs.plant_id = p.id 
           WHERE vs.name = ? AND p.name = ?''',
        variables: [
          drift.Variable.withString(widget.valueStreamName),
          drift.Variable.withString(widget.plantName),
        ],
      ).get();

      final actualValueStreamId = valueStreamCheck.isNotEmpty
          ? valueStreamCheck.first.data['id'] as int
          : widget.valueStreamId;

      // Get the organization ID from the company name
      final organizationId = await db.upsertOrganization(widget.companyName);

      await db.insertPart(
        PartsCompanion.insert(
          valueStreamId: actualValueStreamId,
          organizationId: organizationId,
          partNumber: partNumber,
          partDescription: partDescription.isEmpty
              ? drift.Value.absent()
              : drift.Value(partDescription),
          monthlyDemand: monthlyDemand != null
              ? drift.Value(monthlyDemand)
              : const drift.Value.absent(),
        ),
      );

      await _loadParts();
      _partNumberController.clear();
      _partDescriptionController.clear();
      _monthlyDemandController.clear();

      // Reset focus to part number field for efficient data entry
      _partNumberFocus.requestFocus();

      if (mounted) {
        ErrorHandler.showSuccessSnackbar(
            context, 'Part "$partNumber" saved successfully!');
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showConstraintErrorDialog(context, e);
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  void _trySaveOnEnter() {
    final partNumber = _partNumberController.text.trim();
    if (partNumber.isNotEmpty && !_saving) {
      _savePart();
    }
  }

  Future<void> _deletePart(int id) async {
    // Find the part to get its name for confirmation
    final part = _parts.firstWhere((p) => p['id'] == id, orElse: () => {});
    final partNumber = part['part_number'] ?? 'Unknown Part';

    // Show confirmation dialog
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text(
            'Are you sure you want to delete part "$partNumber"?\n\nThis action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    try {
      await (db.delete(db.parts)..where((p) => p.id.equals(id))).go();

      // Clean up the controller for this part
      _partNumberControllers[id]?.dispose();
      _partDescriptionControllers[id]?.dispose();
      _monthlyDemandControllers[id]?.dispose();
      _partNumberControllers.remove(id);
      _partDescriptionControllers.remove(id);
      _monthlyDemandControllers.remove(id);
      _editingStates.remove(id);

      await _loadParts();

      if (mounted) {
        ErrorHandler.showSuccessSnackbar(
            context, 'Part "$partNumber" deleted successfully!');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to delete part: $e';
        });
        ErrorHandler.showConstraintErrorDialog(context, e);
      }
    }
  }

  Future<void> _updatePart(int id) async {
    final partNumber = _partNumberControllers[id]!.text.trim();
    final partDescription = _partDescriptionControllers[id]!.text.trim();
    final monthlyDemandText = _monthlyDemandControllers[id]!.text.trim();
    final monthlyDemand =
        monthlyDemandText.isNotEmpty ? int.tryParse(monthlyDemandText) : null;

    if (partNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Part Number is required!')),
      );
      return;
    }

    // Validate monthly demand if provided
    if (monthlyDemandText.isNotEmpty && monthlyDemand == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Monthly Demand must be a valid number!')),
      );
      return;
    }

    try {
      await (db.update(db.parts)..where((p) => p.id.equals(id))).write(
        PartsCompanion(
          partNumber: drift.Value(partNumber),
          partDescription: drift.Value(partDescription),
          monthlyDemand: monthlyDemand != null
              ? drift.Value(monthlyDemand)
              : const drift.Value.absent(),
        ),
      );

      // Exit editing mode
      setState(() {
        _editingStates[id] = false;
      });

      await _loadParts();

      if (mounted) {
        ErrorHandler.showSuccessSnackbar(
            context, 'Part "$partNumber" updated successfully!');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to update part: $e';
        });
        ErrorHandler.showConstraintErrorDialog(context, e);
      }
    }
  }

  void _cancelEdit(int id) {
    setState(() {
      _editingStates[id] = false;
      // Reset the controllers to original values
      final part = _parts.firstWhere((p) => p['id'] == id);
      _partNumberControllers[id]!.text = part['part_number'] ?? '';
      _partDescriptionControllers[id]!.text = part['part_description'] ?? '';
      _monthlyDemandControllers[id]!.text =
          part['monthly_demand']?.toString() ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return HomeButtonWrapper(
        child: Scaffold(
      appBar: AppBar(
        title: const Text('Part Input'),
        backgroundColor: Colors.white,
      ),
      drawer: const AppDrawer(),
      backgroundColor: Colors.yellow[100],
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom -
                  kToolbarHeight -
                  32, // Account for app bar and padding
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                    maxWidth: 1200), // Increased from 900 to 1200
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Column: Selection Card and Form
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          SelectionDisplayCard(
                            companyName: widget.companyName,
                            plantName: widget.plantName,
                            valueStreamName: widget.valueStreamName,
                          ),
                          const SizedBox(height: 16),
                          Card(
                            color: Colors.yellow[50],
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            elevation: 8,
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: _loading
                                  ? const Center(
                                      child: CircularProgressIndicator())
                                  : _error != null
                                      ? Center(
                                          child: Text(_error!,
                                              style: const TextStyle(
                                                  color: Colors.red)))
                                      : Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            const Text(
                                              'Enter Part',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 14),
                                            TextField(
                                              controller: _partNumberController,
                                              focusNode: _partNumberFocus,
                                              decoration: const InputDecoration(
                                                labelText: 'Part Number',
                                                border: OutlineInputBorder(),
                                                filled: true,
                                                fillColor: Colors.white,
                                              ),
                                              textInputAction:
                                                  TextInputAction.next,
                                              onSubmitted: (_) =>
                                                  _partDescriptionFocus
                                                      .requestFocus(),
                                            ),
                                            const SizedBox(height: 14),
                                            TextField(
                                              controller:
                                                  _partDescriptionController,
                                              focusNode: _partDescriptionFocus,
                                              decoration: const InputDecoration(
                                                labelText: 'Part Description',
                                                border: OutlineInputBorder(),
                                                filled: true,
                                                fillColor: Colors.white,
                                              ),
                                              textInputAction:
                                                  TextInputAction.next,
                                              onSubmitted: (_) =>
                                                  _monthlyDemandFocus
                                                      .requestFocus(),
                                            ),
                                            const SizedBox(height: 14),
                                            TextField(
                                              controller:
                                                  _monthlyDemandController,
                                              focusNode: _monthlyDemandFocus,
                                              decoration: const InputDecoration(
                                                labelText:
                                                    'Monthly Demand (Optional)',
                                                border: OutlineInputBorder(),
                                                filled: true,
                                                fillColor: Colors.white,
                                                hintText: 'Enter quantity',
                                              ),
                                              keyboardType:
                                                  TextInputType.number,
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .digitsOnly
                                              ],
                                              textInputAction:
                                                  TextInputAction.done,
                                              onSubmitted: (_) =>
                                                  _trySaveOnEnter(),
                                            ),
                                            const SizedBox(height: 20),
                                            SizedBox(
                                              width: double.infinity,
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.yellow[300],
                                                  foregroundColor: Colors.black,
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 16),
                                                  textStyle: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12)),
                                                  elevation: 6,
                                                ),
                                                onPressed:
                                                    _saving ? null : _savePart,
                                                child: _saving
                                                    ? const CircularProgressIndicator()
                                                    : const Text('Save Part'),
                                              ),
                                            ),
                                          ],
                                        ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 32),
                    // Right: Saved Parts Table
                    Expanded(
                      flex:
                          4, // Increased from 3 to 4 for more horizontal space
                      child: Card(
                        color: Colors.yellow[50],
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 8,
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: _loading
                              ? const Center(child: CircularProgressIndicator())
                              : _error != null
                                  ? Center(
                                      child: Text(_error!,
                                          style: const TextStyle(
                                              color: Colors.red)))
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        const Text('Saved Parts',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18)),
                                        const SizedBox(height: 8),
                                        SizedBox(
                                          height:
                                              400, // Fixed height for the table
                                          child: _parts.isEmpty
                                              ? const Center(
                                                  child: Text(
                                                      'No parts saved yet.'))
                                              : SingleChildScrollView(
                                                  scrollDirection:
                                                      Axis.vertical,
                                                  child: LayoutBuilder(builder:
                                                      (context, constraints) {
                                                    return DataTable(
                                                      columnSpacing:
                                                          30, // Increased from 20 to 30 for better spacing
                                                      columns: [
                                                        DataColumn(
                                                          label: SizedBox(
                                                            width: constraints
                                                                    .maxWidth *
                                                                0.22, // Increased from 0.2 to 0.22
                                                            child: const Text(
                                                                'Part Number'),
                                                          ),
                                                        ),
                                                        DataColumn(
                                                          label: SizedBox(
                                                            width: constraints
                                                                    .maxWidth *
                                                                0.38, // Decreased from 0.4 to 0.38
                                                            child: const Text(
                                                                'Description'),
                                                          ),
                                                        ),
                                                        DataColumn(
                                                          label: SizedBox(
                                                            width: constraints
                                                                    .maxWidth *
                                                                0.18, // Increased from 0.15 to 0.18
                                                            child: const Text(
                                                                'Monthly Demand'),
                                                          ),
                                                        ),
                                                        const DataColumn(
                                                          label:
                                                              Text('Actions'),
                                                        ),
                                                      ],
                                                      rows: _parts.map((part) {
                                                        final isEditing =
                                                            _editingStates[part[
                                                                    'id']] ??
                                                                false;
                                                        return DataRow(cells: [
                                                          DataCell(
                                                            isEditing
                                                                ? TextFormField(
                                                                    controller:
                                                                        _partNumberControllers[
                                                                            part['id']],
                                                                    decoration:
                                                                        const InputDecoration(
                                                                      labelText:
                                                                          'Part Number',
                                                                      isDense:
                                                                          true,
                                                                    ),
                                                                  )
                                                                : Text(part[
                                                                        'part_number'] ??
                                                                    ''),
                                                          ),
                                                          DataCell(
                                                            isEditing
                                                                ? TextFormField(
                                                                    controller:
                                                                        _partDescriptionControllers[
                                                                            part['id']],
                                                                    decoration:
                                                                        const InputDecoration(
                                                                      labelText:
                                                                          'Description',
                                                                      isDense:
                                                                          true,
                                                                    ),
                                                                  )
                                                                : Text(part[
                                                                        'part_description'] ??
                                                                    ''),
                                                          ),
                                                          DataCell(
                                                            isEditing
                                                                ? TextFormField(
                                                                    controller:
                                                                        _monthlyDemandControllers[
                                                                            part['id']],
                                                                    decoration:
                                                                        const InputDecoration(
                                                                      labelText:
                                                                          'Monthly Demand',
                                                                      isDense:
                                                                          true,
                                                                    ),
                                                                    keyboardType:
                                                                        TextInputType
                                                                            .number,
                                                                    inputFormatters: [
                                                                      FilteringTextInputFormatter
                                                                          .digitsOnly
                                                                    ],
                                                                  )
                                                                : Text(part['monthly_demand']
                                                                        ?.toString() ??
                                                                    ''),
                                                          ),
                                                          DataCell(
                                                            Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                if (isEditing) ...[
                                                                  IconButton(
                                                                    icon: const Icon(
                                                                        Icons
                                                                            .check,
                                                                        color: Colors
                                                                            .green),
                                                                    onPressed: () =>
                                                                        _updatePart(
                                                                            part['id']),
                                                                    tooltip:
                                                                        'Save',
                                                                  ),
                                                                  IconButton(
                                                                    icon: const Icon(
                                                                        Icons
                                                                            .close,
                                                                        color: Colors
                                                                            .orange),
                                                                    onPressed: () =>
                                                                        _cancelEdit(
                                                                            part['id']),
                                                                    tooltip:
                                                                        'Cancel',
                                                                  ),
                                                                ] else ...[
                                                                  IconButton(
                                                                    icon: const Icon(
                                                                        Icons
                                                                            .edit,
                                                                        color: Colors
                                                                            .blue),
                                                                    onPressed:
                                                                        () {
                                                                      setState(
                                                                          () {
                                                                        _editingStates[part['id']] =
                                                                            true;
                                                                      });
                                                                    },
                                                                    tooltip:
                                                                        'Edit',
                                                                  ),
                                                                  IconButton(
                                                                    icon: const Icon(
                                                                        Icons
                                                                            .delete,
                                                                        color: Colors
                                                                            .red),
                                                                    onPressed: () =>
                                                                        _deletePart(
                                                                            part['id']),
                                                                    tooltip:
                                                                        'Delete',
                                                                  ),
                                                                ],
                                                              ],
                                                            ),
                                                          ),
                                                        ]);
                                                      }).toList(),
                                                    );
                                                  }),
                                                ),
                                        ),
                                      ],
                                    ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomSheet: Container(
        color: Colors.transparent,
        child: const AppFooter(),
      ),
    ));
  }
}
