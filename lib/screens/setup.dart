import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift;

import '../widgets/home_header.dart';
import '../widgets/app_footer.dart';

import '../logic/app_database.dart';
import '../database_provider.dart';

class SetupScreen extends StatefulWidget {
  final String? companyName;
  final String? plantName;
  final String? valueStreamName;
  final String? processName;

  const SetupScreen({
    super.key,
    this.companyName,
    this.plantName,
    this.valueStreamName,
    this.processName,
  });

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  late AppDatabase db;
  List<String> partNumbers = [];
  String? selectedPartNumber;
  TextEditingController setupNameController = TextEditingController();
  bool dialogShown = false;
  int? processPartId;
  String? setupName;
  DateTime? setupDateTime;
  List<SetupElement> setupElements = [];
  bool loadingElements = false;
  TextEditingController newElementNameController = TextEditingController();
  TextEditingController newTimeController =
      TextEditingController(text: '00:00:00');
  Map<int, String> elementNameEdits = {};
  Map<int, String> timeEdits = {};

  Future<void> _fetchSetupElements() async {
    if (processPartId == null || setupName == null || setupDateTime == null) {
      return;
    }
    setState(() {
      loadingElements = true;
    });
    final elements = await (db.select(db.setupElements)
          ..where((tbl) =>
              tbl.processPartId.equals(processPartId!) &
              tbl.setupName.equals(setupName!)))
        .get();
    setState(() {
      setupElements = elements;
      loadingElements = false;
    });
  }

  @override
  void initState() {
    super.initState();
    // Do not prefill setup name with process name; leave it empty for user input
    DatabaseProvider.getInstance().then((database) {
      db = database;
      _fetchPartNumbers();
    });
  }

  Future<void> _fetchPartNumbers() async {
    if (widget.processName == null) return;
    // Find process for the selected processName
    final process = await (db.select(db.processes)
          ..where((p) => p.processName.equals(widget.processName!)))
        .getSingleOrNull();
    if (process == null) return;
    // Get all part numbers for the value stream linked to this process
    final parts = await (db.select(db.parts)
          ..where((part) => part.valueStreamId.equals(process.valueStreamId)))
        .get();
    setState(() {
      partNumbers = parts.map((p) => p.partNumber).toList();
      if (partNumbers.isNotEmpty) {
        selectedPartNumber = partNumbers.first;
      }
    });
    // Show dialog after part numbers are loaded
    if (!dialogShown) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showSetupDialog());
      dialogShown = true;
    }
  }

  Future<void> _showSetupDialog() async {
    final result = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text('Setup for ${widget.processName ?? ''}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedPartNumber,
                items: partNumbers
                    .map((pn) => DropdownMenuItem(
                          value: pn,
                          child: Text(pn),
                        ))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    selectedPartNumber = val;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Part Number',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: setupNameController,
                decoration: const InputDecoration(
                  labelText: 'Setup Name',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (widget.processName == null || selectedPartNumber == null) {
                  Navigator.of(context).pop(false);
                  return;
                }
                final process = await (db.select(db.processes)
                      ..where((p) => p.processName.equals(widget.processName!)))
                    .getSingleOrNull();
                if (process == null) {
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pop(false);
                  return;
                }
                final existing = await (db.select(db.processParts)
                      ..where((pp) =>
                          pp.processId.equals(process.id) &
                          pp.partNumber.equals(selectedPartNumber!)))
                    .getSingleOrNull();
                int id;
                if (existing != null) {
                  id = existing.id;
                } else {
                  id = await db.into(db.processParts).insert(
                        ProcessPartsCompanion(
                          partNumber: drift.Value(selectedPartNumber!),
                          processId: drift.Value(process.id),
                        ),
                      );
                }
                setState(() {
                  processPartId = id;
                  setupName = setupNameController.text;
                  setupDateTime = DateTime.now();
                });
                // ignore: use_build_context_synchronously
                Navigator.of(context).pop(true);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
    if (result == true) {
      await _fetchSetupElements();
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
            processName: widget.processName,
          ),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Input area (left)
                      Flexible(
                        flex: 1,
                        child: Card(
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Setup Details',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                InputDecorator(
                                  decoration: const InputDecoration(
                                    labelText: 'Setup Name',
                                    border: OutlineInputBorder(),
                                  ),
                                  child: Text(
                                    setupNameController.text,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                InputDecorator(
                                  decoration: const InputDecoration(
                                    labelText: 'Part Number',
                                    border: OutlineInputBorder(),
                                  ),
                                  child: Text(
                                    selectedPartNumber ?? '',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                                const SizedBox(height: 32),
                                Text('Add Element',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium),
                                const SizedBox(height: 16),
                                TextField(
                                  controller: newElementNameController,
                                  decoration: const InputDecoration(
                                    labelText: 'Element Name',
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                TextField(
                                  controller: newTimeController,
                                  decoration: const InputDecoration(
                                    labelText: 'Time (HH:MM:SS)',
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () async {
                                    if (processPartId != null &&
                                        setupName != null &&
                                        setupDateTime != null &&
                                        newElementNameController
                                            .text.isNotEmpty &&
                                        newTimeController.text.isNotEmpty) {
                                      await db.into(db.setupElements).insert(
                                            SetupElementsCompanion(
                                              processPartId:
                                                  drift.Value(processPartId!),
                                              setupName:
                                                  drift.Value(setupName!),
                                              setupDateTime:
                                                  drift.Value(setupDateTime!),
                                              elementName: drift.Value(
                                                  newElementNameController
                                                      .text),
                                              time: drift.Value(
                                                  newTimeController.text),
                                            ),
                                          );
                                      await _fetchSetupElements();
                                      newElementNameController.clear();
                                      newTimeController.text = '00:00:00';
                                    }
                                  },
                                  child: const Text('Add Element'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      // Elements list (right)
                      Flexible(
                        flex: 2,
                        child: Card(
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (setupName != null)
                                  loadingElements
                                      ? const Center(
                                          child: CircularProgressIndicator())
                                      : Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Elements for Setup: $setupName',
                                                style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              const SizedBox(height: 12),
                                              SingleChildScrollView(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                child: SizedBox(
                                                  width:
                                                      500, // Adjust width as needed
                                                  child: setupElements.isEmpty
                                                      ? const Center(
                                                          child: Text(
                                                              'No elements added yet.'))
                                                      : SizedBox(
                                                          height:
                                                              350, // Set max height for vertical scroll
                                                          child: ListView
                                                              .separated(
                                                            itemCount:
                                                                setupElements
                                                                    .length,
                                                            separatorBuilder:
                                                                (context,
                                                                        idx) =>
                                                                    const Divider(),
                                                            itemBuilder:
                                                                (context, idx) {
                                                              final element =
                                                                  setupElements[
                                                                      idx];
                                                              return ListTile(
                                                                title: Text(element
                                                                    .elementName),
                                                                subtitle: Text(
                                                                    'Time: ${element.time}'),
                                                                trailing:
                                                                    IconButton(
                                                                  icon: const Icon(
                                                                      Icons
                                                                          .delete,
                                                                      color: Colors
                                                                          .red),
                                                                  onPressed:
                                                                      () async {
                                                                    await db
                                                                        .delete(db
                                                                            .setupElements)
                                                                        .delete(
                                                                            element);
                                                                    await _fetchSetupElements();
                                                                  },
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                else
                                  const Center(
                                    child: Text(
                                        'Please complete setup to add elements.'),
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
          AppFooter(),
        ],
      ),
    );
  }
}
