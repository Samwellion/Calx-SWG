import 'package:flutter/material.dart';
import '../logic/app_database.dart';
import 'package:drift/drift.dart' as drift;
import '../database_provider.dart';
import '../widgets/home_header.dart';

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
  final TextEditingController _processNameController = TextEditingController();
  final TextEditingController _processDescriptionController =
      TextEditingController();
  bool _saving = false;
  bool _loading = true;
  String? _error;
  late AppDatabase db;
  List<Map<String, dynamic>> _processes = [];

  @override
  void initState() {
    super.initState();
    DatabaseProvider.getInstance().then((database) {
      db = database;
      _loadProcesses();
    }).catchError((e) {
      setState(() {
        _error = 'Database initialization failed: $e';
        _loading = false;
      });
    });
  }

  Future<void> _loadProcesses() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await db.customSelectQuery(
        'SELECT id, process_name, process_description FROM processes WHERE value_stream_id = ?',
        variables: [drift.Variable.withInt(widget.valueStreamId)],
      ).get();
      setState(() {
        _processes = result.map((row) => row.data).toList();
        _loading = false;
      });
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
    super.dispose();
  }

  Future<void> _saveProcess() async {
    final processName = _processNameController.text.trim();
    final processDescription = _processDescriptionController.text.trim();
    if (processName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Process Name is required!')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await db.into(db.processes).insert(
            ProcessesCompanion(
              valueStreamId: drift.Value(widget.valueStreamId),
              processName: drift.Value(processName),
              processDescription: drift.Value(
                  processDescription.isEmpty ? null : processDescription),
            ),
          );
      await _loadProcesses();
      _processNameController.clear();
      _processDescriptionController.clear();
    } catch (e) {
      setState(() {
        _error = 'Failed to save process: $e';
      });
    } finally {
      setState(() => _saving = false);
    }
  }

  void _trySaveOnEnter() {
    final processName = _processNameController.text.trim();
    final processDescription = _processDescriptionController.text.trim();
    if (processName.isNotEmpty && processDescription.isNotEmpty && !_saving) {
      _saveProcess();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[100],
      body: Column(
        children: [
          HomeHeader(
            companyName: widget.companyName,
            plantName: widget.plantName,
            valueStreamName: widget.valueStreamName,
          ),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left: Form
                    Expanded(
                      flex: 2,
                      child: Card(
                        color: Colors.white,
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
                                  : SingleChildScrollView(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          TextField(
                                            controller: _processNameController,
                                            decoration: const InputDecoration(
                                              labelText: 'Process Name',
                                              border: OutlineInputBorder(),
                                              filled: true,
                                              fillColor: Colors.white,
                                            ),
                                            onSubmitted: (_) =>
                                                _trySaveOnEnter(),
                                          ),
                                          const SizedBox(height: 16),
                                          TextField(
                                            controller:
                                                _processDescriptionController,
                                            decoration: const InputDecoration(
                                              labelText: 'Process Description',
                                              border: OutlineInputBorder(),
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
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.yellow[300],
                                                foregroundColor: Colors.black,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 16),
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
                                                  _saving ? null : _saveProcess,
                                              child: _saving
                                                  ? const CircularProgressIndicator()
                                                  : const Text('Save Process'),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 32),
                    // Right: Saved Processes Table
                    Expanded(
                      flex: 3,
                      child: Card(
                        color: Colors.white,
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
                                        const Text('Saved Processes:',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16)),
                                        const SizedBox(height: 8),
                                        Expanded(
                                          child: _processes.isEmpty
                                              ? const Text(
                                                  'No processes saved yet.')
                                              : SingleChildScrollView(
                                                  scrollDirection:
                                                      Axis.vertical,
                                                  child: DataTable(
                                                    columns: const [
                                                      DataColumn(
                                                          label: Text(
                                                              'Process Name')),
                                                      DataColumn(
                                                          label: Text(
                                                              'Description')),
                                                    ],
                                                    rows: _processes
                                                        .map((process) =>
                                                            DataRow(cells: [
                                                              DataCell(Text(
                                                                  process['process_name'] ??
                                                                      '')),
                                                              DataCell(Text(
                                                                  process['process_description'] ??
                                                                      '')),
                                                            ]))
                                                        .toList(),
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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.yellow[200],
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow[300],
                    foregroundColor: Colors.black,
                    elevation: 6,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    textStyle: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.home, size: 28),
                  label: const Text('Home',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                ),
                const Spacer(),
                const Text(
                  '© 2025 Standard Work Generator App',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
