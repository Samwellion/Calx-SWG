import 'package:flutter/material.dart';
import '../logic/app_database.dart';
import 'package:drift/drift.dart' as drift;
import '../database_provider.dart';
import '../widgets/selection_display_card.dart';
import '../widgets/app_drawer.dart';
import '../widgets/app_footer.dart';
import '../widgets/home_button_wrapper.dart';
import '../utils/error_handler.dart';
import '../widgets/process_setup_help_popup.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProcessInputScreen extends StatefulWidget {
  final int valueStreamId;
  final String valueStreamName;
  final String companyName;
  final String plantName;

  const ProcessInputScreen({
    super.key,
    required this.valueStreamId,
    required this.valueStreamName,
    required this.companyName,
    required this.plantName,
  });

  @override
  State<ProcessInputScreen> createState() => _ProcessInputScreenState();
}

class _ProcessInputScreenState extends State<ProcessInputScreen> {
  static const _kProcessSetupHelpShownKey = 'processSetupHelpShown';
  final TextEditingController _processNameController = TextEditingController();
  final TextEditingController _processDescriptionController =
      TextEditingController();
  bool _saving = false;
  bool _loading = true;
  String? _error;
  late AppDatabase db;
  List<Map<String, dynamic>> _processes = [];
  Map<int, bool> _editingStates = {};
  Map<int, TextEditingController> _processDescriptionControllers = {};

    @override
  void initState() {
    super.initState();

    _checkAndShowHelp();
    DatabaseProvider.getInstance().then((database) {

    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    try {
      final database = await DatabaseProvider.getInstance();

      db = database;
      await _loadProcesses();
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Database initialization failed: $e';
          _loading = false;
        });
      }
    }
  }

  Future<void> _loadProcesses() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // Debug logging to identify the issue

      // First, verify the value stream exists and get the correct ID by name
      // This handles cases where the ID might be stale after app restart
      final valueStreamCheck = await db.customSelectQuery(
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
      } else {}

      // Query processes using the correct value stream ID, ordered by orderIndex then by name
      final result = await db.customSelectQuery(
        'SELECT id, process_name, process_description, order_index FROM processes WHERE value_stream_id = ? ORDER BY order_index ASC, process_name ASC',
        variables: [drift.Variable.withInt(actualValueStreamId)],
      ).get();

      setState(() {
        _processes = result.map((row) => row.data).toList();
        _editingStates = {for (var process in _processes) process['id']: false};
        _processDescriptionControllers = {
          for (var process in _processes)
            process['id']:
                TextEditingController(text: process['process_description'])
        };
        _loading = false;
      });

      if (_processes.isNotEmpty) {
      } else {
        // Check for orphaned processes (processes with value_stream_id that no longer exists)
        final orphanedProcesses = await db.customSelectQuery(
            '''SELECT p.id, p.process_name, p.value_stream_id 
             FROM processes p 
             LEFT JOIN value_streams vs ON p.value_stream_id = vs.id 
             WHERE vs.id IS NULL''').get();

        if (orphanedProcesses.isNotEmpty) {
          // Ask user if they want to fix the orphaned processes by updating them to current value stream
          if (mounted) {
            final shouldFix = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Data Repair Needed'),
                content: Text(
                    'Found ${orphanedProcesses.length} saved processes that are referencing an old value stream configuration.\n\n'
                    'Would you like to update these processes to use the current "${widget.valueStreamName}" value stream?\n\n'
                    'Processes to update: ${orphanedProcesses.map((p) => p.data['process_name']).join(', ')}'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Update Processes'),
                  ),
                ],
              ),
            );

            if (shouldFix == true) {
              // Update orphaned processes to use the current value stream ID
              for (final orphanProcess in orphanedProcesses) {
                await db.customStatement(
                  'UPDATE processes SET value_stream_id = ? WHERE id = ?',
                  [actualValueStreamId, orphanProcess.data['id']],
                );
              }

              // Reload the processes after fixing
              _loadProcesses();
              return;
            }
          }
        }
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load processes: $e';
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _processNameController.dispose();
    _processDescriptionController.dispose();
    for (var controller in _processDescriptionControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _checkAndShowHelp() async {
    final prefs = await SharedPreferences.getInstance();
    final hasShownHelp = prefs.getBool(_kProcessSetupHelpShownKey) ?? false;
    
    if (!hasShownHelp && mounted) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const ProcessSetupHelpPopup(),
      );
      await prefs.setBool(_kProcessSetupHelpShownKey, true);
    }
  }

  Future<void> _saveProcess() async {
    final processName = _processNameController.text.trim();
    final processDescription = _processDescriptionController.text.trim();
    
    if (processName.isEmpty) {
      _showErrorSnackbar('Process Name is required!');
      return;
    }

    setState(() => _saving = true);

    try {
      // Check for duplicates
      if (await _isDuplicateProcess(processName)) {
        await _showDuplicateDialog(processName);
        return;
      }

      // Save the process
      final processId = await _createProcess(processName, processDescription);
      
      // Copy VSShifts to ProcessShift for the new process
      await db.copyVSShiftsToProcessShift(widget.valueStreamId, processId);

      // Refresh the list and reset form
      await _loadProcesses();
      _clearForm();
      _requestFocusOnProcessName();

      if (mounted) {
        ErrorHandler.showSuccessSnackbar(
            context, 'Process "$processName" saved successfully!');
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

  Future<bool> _isDuplicateProcess(String processName) async {
    final existingProcesses = await db.customSelectQuery(
      '''SELECT process_name FROM processes 
         WHERE value_stream_id = ? 
         AND LOWER(process_name) = LOWER(?)''',
      variables: [
        drift.Variable.withInt(widget.valueStreamId),
        drift.Variable.withString(processName),
      ],
    ).get();
    
    return existingProcesses.isNotEmpty;
  }

  Future<void> _showDuplicateDialog(String processName) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Duplicate Process'),
        content: Text('A process named "$processName" already exists.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<int> _createProcess(String processName, String processDescription) async {
    final nextOrderIndex = _processes.length;
    
    return await db.upsertProcess(
      ProcessesCompanion(
        valueStreamId: drift.Value(widget.valueStreamId),
        processName: drift.Value(processName),
        processDescription: drift.Value(
            processDescription.isEmpty ? null : processDescription),
        orderIndex: drift.Value(nextOrderIndex),
      ),
    );
  }

  void _clearForm() {
    _processNameController.clear();
    _processDescriptionController.clear();
  }

  void _requestFocusOnProcessName() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Request focus on the process name field
        FocusScope.of(context).requestFocus();
      }
    });
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _trySaveOnEnter() {
    final processName = _processNameController.text.trim();
    final processDescription = _processDescriptionController.text.trim();
    if (processName.isNotEmpty && processDescription.isNotEmpty && !_saving) {
      _saveProcess();
    }
  }

  Future<void> _deleteProcess(int id) async {
    try {
      await (db.delete(db.processes)..where((p) => p.id.equals(id))).go();
      await _loadProcesses();
    } catch (e) {
      setState(() {
        _error = 'Failed to delete process: $e';
      });
    }
  }

  Future<void> _updateProcess(int id) async {
    final processDescription = _processDescriptionControllers[id]!.text.trim();
    try {
      await (db.update(db.processes)..where((p) => p.id.equals(id))).write(
        ProcessesCompanion(
          processDescription: drift.Value(processDescription),
        ),
      );
      await _loadProcesses();
    } catch (e) {
      setState(() {
        _error = 'Failed to update process: $e';
      });
    }
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _processes.removeAt(oldIndex);
      _processes.insert(newIndex, item);
    });
    _updateProcessOrder();
  }

  Future<void> _updateProcessOrder() async {
    try {
      // Update the order_index for each process based on current list order
      for (int i = 0; i < _processes.length; i++) {
        final processId = _processes[i]['id'] as int;
        await db.customStatement(
          'UPDATE processes SET order_index = ? WHERE id = ?',
          [i, processId],
        );
      }
    } catch (e) {
      debugPrint('Error updating process order: $e');
    }
  }

  void _cancelEdit(int processId) {
    setState(() {
      _editingStates[processId] = false;
      // Reset the controller to original value
      final process = _processes.firstWhere((p) => p['id'] == processId);
      _processDescriptionControllers[processId]?.text =
          process['process_description'] ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return HomeButtonWrapper(
        child: Scaffold(
      appBar: AppBar(
        title: const Text('Process Input'),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'Show Help',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const ProcessSetupHelpPopup(),
              );
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      backgroundColor: Colors.yellow[100],
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
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
                            Expanded(
                              child: Card(
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
                                          : SingleChildScrollView(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.max,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.stretch,
                                                children: [
                                                  const Text(
                                                    'Enter Process',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 14),
                                                  TextField(
                                                    controller:
                                                        _processNameController,
                                                    decoration:
                                                        const InputDecoration(
                                                      labelText: 'Process Name',
                                                      border:
                                                          OutlineInputBorder(),
                                                      filled: true,
                                                      fillColor: Colors.white,
                                                    ),
                                                    onSubmitted: (_) =>
                                                        _trySaveOnEnter(),
                                                  ),
                                                  const SizedBox(height: 14),
                                                  TextField(
                                                    controller:
                                                        _processDescriptionController,
                                                    decoration:
                                                        const InputDecoration(
                                                      labelText:
                                                          'Process Description',
                                                      border:
                                                          OutlineInputBorder(),
                                                      filled: true,
                                                      fillColor: Colors.white,
                                                    ),
                                                    onSubmitted: (_) =>
                                                        _trySaveOnEnter(),
                                                  ),
                                                  const SizedBox(height: 24),
                                                  SizedBox(
                                                    width: double.infinity,
                                                    child: ElevatedButton(
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                            Colors.yellow[300],
                                                        foregroundColor:
                                                            Colors.black,
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 16),
                                                        textStyle:
                                                            const TextStyle(
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12)),
                                                        elevation: 6,
                                                      ),
                                                      onPressed: _saving
                                                          ? null
                                                          : _saveProcess,
                                                      child: _saving
                                                          ? const CircularProgressIndicator()
                                                          : const Text(
                                                              'Save Process'),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 16),
                                                ],
                                              ),
                                            ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 32),
                      // Right: Saved Processes Table
                      Expanded(
                        flex: 3,
                        child: Card(
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          const Text('Saved Processes',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18)),
                                          const SizedBox(height: 4),
                                          const Text(
                                            'Drag processes to reorder them',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Expanded(
                                            child: _processes.isEmpty
                                                ? const Text(
                                                    'No processes saved yet.')
                                                : Theme(
                                                    data: Theme.of(context)
                                                        .copyWith(
                                                      canvasColor:
                                                          Colors.transparent,
                                                    ),
                                                    child: ReorderableListView
                                                        .builder(
                                                      itemCount:
                                                          _processes.length,
                                                      onReorder: _onReorder,
                                                      itemBuilder:
                                                          (context, index) {
                                                        final process =
                                                            _processes[index];
                                                        final isEditing =
                                                            _editingStates[
                                                                    process[
                                                                        'id']] ??
                                                                false;

                                                        return Card(
                                                          key: ValueKey(
                                                              process['id']),
                                                          margin:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical: 4),
                                                          color: Colors
                                                              .yellow[100],
                                                          child: ListTile(
                                                            title: Text(
                                                              process['process_name'] ??
                                                                  '',
                                                              style: const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                            subtitle: isEditing
                                                                ? Padding(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        top: 8),
                                                                    child:
                                                                        TextFormField(
                                                                      controller:
                                                                          _processDescriptionControllers[
                                                                              process['id']],
                                                                      decoration:
                                                                          const InputDecoration(
                                                                        labelText:
                                                                            'Description',
                                                                        border:
                                                                            OutlineInputBorder(),
                                                                        isDense:
                                                                            true,
                                                                        filled:
                                                                            true,
                                                                        fillColor:
                                                                            Colors.white,
                                                                      ),
                                                                    ),
                                                                  )
                                                                : Text(process[
                                                                        'process_description'] ??
                                                                    ''),
                                                            trailing: Row(
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
                                                                        _updateProcess(
                                                                            process['id']),
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
                                                                            process['id']),
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
                                                                        _editingStates[process['id']] =
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
                                                                        _deleteProcess(
                                                                            process['id']),
                                                                    tooltip:
                                                                        'Delete',
                                                                  ),
                                                                ],
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
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
            const AppFooter(),
          ],
        ),
      ),
    ));
  }
}
