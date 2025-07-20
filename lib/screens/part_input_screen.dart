import 'package:flutter/material.dart';
import '../logic/app_database.dart';
import 'package:drift/drift.dart' as drift;
import '../database_provider.dart';
import '../widgets/selection_display_card.dart';
import '../widgets/app_footer.dart';
import '../widgets/app_drawer.dart';

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
  bool _saving = false;
  bool _loading = true;
  String? _error;
  late AppDatabase db;
  List<Map<String, dynamic>> _parts = [];
  Map<int, bool> _editingStates = {};
  Map<int, TextEditingController> _partNumberControllers = {};
  Map<int, TextEditingController> _partDescriptionControllers = {};

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
      final result = await db.customSelect(
        'SELECT id, part_number, part_description FROM parts WHERE value_stream_id = ?',
        variables: [drift.Variable.withInt(widget.valueStreamId)],
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
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load parts: $e';
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _partNumberController.dispose();
    _partDescriptionController.dispose();
    for (var controller in _partNumberControllers.values) {
      controller.dispose();
    }
    for (var controller in _partDescriptionControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _savePart() async {
    final partNumber = _partNumberController.text.trim();
    final partDescription = _partDescriptionController.text.trim();
    if (partNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Part Number is required!')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await db.insertPart(
        PartsCompanion.insert(
          valueStreamId: widget.valueStreamId,
          partNumber: partNumber,
          partDescription: partDescription.isEmpty
              ? drift.Value.absent()
              : drift.Value(partDescription),
        ),
      );
      await _loadParts();
      _partNumberController.clear();
      _partDescriptionController.clear();
    } catch (e) {
      setState(() {
        _error = 'Failed to save part: $e';
      });
    } finally {
      setState(() => _saving = false);
    }
  }

  void _trySaveOnEnter() {
    final partNumber = _partNumberController.text.trim();
    final partDescription = _partDescriptionController.text.trim();
    if (partNumber.isNotEmpty && partDescription.isNotEmpty && !_saving) {
      _savePart();
    }
  }

  Future<void> _deletePart(int id) async {
    try {
      await (db.delete(db.parts)..where((p) => p.id.equals(id))).go();
      await _loadParts();
    } catch (e) {
      setState(() {
        _error = 'Failed to delete part: $e';
      });
    }
  }

  Future<void> _updatePart(int id) async {
    final partNumber = _partNumberControllers[id]!.text.trim();
    final partDescription = _partDescriptionControllers[id]!.text.trim();
    if (partNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Part Number is required!')),
      );
      return;
    }
    try {
      await (db.update(db.parts)..where((p) => p.id.equals(id))).write(
        PartsCompanion(
          partNumber: drift.Value(partNumber),
          partDescription: drift.Value(partDescription),
        ),
      );
      await _loadParts();
    } catch (e) {
      setState(() {
        _error = 'Failed to update part: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Part Input'),
        backgroundColor: Colors.white,
      ),
      drawer: const AppDrawer(),
      backgroundColor: Colors.yellow[100],
      body: Column(
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
                                                  'Enter Part',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 14),
                                                TextField(
                                                  controller:
                                                      _partNumberController,
                                                  decoration:
                                                      const InputDecoration(
                                                    labelText: 'Part Number',
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
                                                      _partDescriptionController,
                                                  decoration:
                                                      const InputDecoration(
                                                    labelText:
                                                        'Part Description',
                                                    border:
                                                        OutlineInputBorder(),
                                                    filled: true,
                                                    fillColor: Colors.white,
                                                  ),
                                                  onSubmitted: (_) =>
                                                      _trySaveOnEnter(),
                                                ),
                                                const SizedBox(height: 20),
                                                SizedBox(
                                                  width: double.infinity,
                                                  child: ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          Colors.yellow[300],
                                                      foregroundColor:
                                                          Colors.black,
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 16),
                                                      textStyle:
                                                          const TextStyle(
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          12)),
                                                      elevation: 6,
                                                    ),
                                                    onPressed: _saving
                                                        ? null
                                                        : _savePart,
                                                    child: _saving
                                                        ? const CircularProgressIndicator()
                                                        : const Text(
                                                            'Save Part'),
                                                  ),
                                                ),
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
                    // Right: Saved Parts Table
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
                                        Expanded(
                                          child: _parts.isEmpty
                                              ? const Text(
                                                  'No parts saved yet.')
                                              : SingleChildScrollView(
                                                  scrollDirection:
                                                      Axis.vertical,
                                                  child: LayoutBuilder(builder:
                                                      (context, constraints) {
                                                    return DataTable(
                                                      columnSpacing: 20,
                                                      columns: [
                                                        DataColumn(
                                                          label: SizedBox(
                                                            width: constraints
                                                                    .maxWidth *
                                                                0.2,
                                                            child: const Text(
                                                                'Part Number'),
                                                          ),
                                                        ),
                                                        DataColumn(
                                                          label: SizedBox(
                                                            width: constraints
                                                                    .maxWidth *
                                                                0.5,
                                                            child: const Text(
                                                                'Description'),
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
                                                            Text(part[
                                                                    'part_number'] ??
                                                                ''),
                                                          ),
                                                          DataCell(
                                                            isEditing
                                                                ? TextFormField(
                                                                    controller:
                                                                        _partDescriptionControllers[
                                                                            part['id']],
                                                                  )
                                                                : Text(part[
                                                                        'part_description'] ??
                                                                    ''),
                                                          ),
                                                          DataCell(
                                                            Row(
                                                              children: [
                                                                if (isEditing)
                                                                  IconButton(
                                                                    icon: const Icon(
                                                                        Icons
                                                                            .check,
                                                                        color: Colors
                                                                            .green),
                                                                    onPressed:
                                                                        () {
                                                                      _updatePart(
                                                                          part[
                                                                              'id']);
                                                                    },
                                                                  )
                                                                else
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
                                                                  ),
                                                                IconButton(
                                                                  icon: const Icon(
                                                                      Icons
                                                                          .delete,
                                                                      color: Colors
                                                                          .red),
                                                                  onPressed:
                                                                      () {
                                                                    _deletePart(
                                                                        part[
                                                                            'id']);
                                                                  },
                                                                ),
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
          const SizedBox(height: 8),
          const AppFooter(),
        ],
      ),
    );
  }
}
