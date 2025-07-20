import 'package:flutter/material.dart';
import '../logic/app_database.dart';
import 'package:drift/drift.dart' as drift;
import '../database_provider.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[100],
      body: Column(
        children: [
          // Removed HomeHeader
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
                                            controller: _partNumberController,
                                            decoration: const InputDecoration(
                                              labelText: 'Part Number',
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
                                                _partDescriptionController,
                                            decoration: const InputDecoration(
                                              labelText: 'Part Description',
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
                      ),
                    ),
                    const SizedBox(width: 32),
                    // Right: Saved Parts Table
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
                                        const Text('Saved Parts:',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16)),
                                        const SizedBox(height: 8),
                                        Expanded(
                                          child: _parts.isEmpty
                                              ? const Text(
                                                  'No parts saved yet.')
                                              : SingleChildScrollView(
                                                  scrollDirection:
                                                      Axis.vertical,
                                                  child: DataTable(
                                                    columns: const [
                                                      DataColumn(
                                                          label: Text(
                                                              'Part Number')),
                                                      DataColumn(
                                                          label: Text(
                                                              'Description')),
                                                    ],
                                                    rows: _parts
                                                        .map((part) =>
                                                            DataRow(cells: [
                                                              DataCell(Text(
                                                                  part['part_number'] ??
                                                                      '')),
                                                              DataCell(Text(
                                                                  part['part_description'] ??
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
