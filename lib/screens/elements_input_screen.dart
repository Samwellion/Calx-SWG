import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift;

import '../widgets/app_footer.dart';
import '../widgets/detailed_selection_display_card.dart';
import '../widgets/app_drawer.dart';
import '../widgets/element_list_card.dart';

import '../logic/app_database.dart';
import '../database_provider.dart';

class ElementsInputScreen extends StatefulWidget {
  final String? companyName;
  final String? plantName;
  final String? valueStreamName;
  final String? processName;

  const ElementsInputScreen({
    super.key,
    this.companyName,
    this.plantName,
    this.valueStreamName,
    this.processName,
  });

  @override
  State<ElementsInputScreen> createState() => _ElementsInputScreenState();
}

class _ElementsInputScreenState extends State<ElementsInputScreen> {
  late AppDatabase db;
  List<String> partNumbers = [];
  String? selectedPartNumber;
  TextEditingController setupNameController = TextEditingController();
  bool dialogShown = false;
  int? processPartId;
  String? setupName;
  DateTime? setupDateTime;
  TextEditingController newElementNameController = TextEditingController();
  TextEditingController newTimeController =
      TextEditingController(text: '00:00:00');
  List<String> existingSetupNames = [];
  String? selectedSetupName;
  final String _newSetupOption = 'Create New Setup...';

  Future<void> _fetchSetupsForPart(String? partNumber) async {
    if (partNumber == null || widget.processName == null) {
      setState(() {
        existingSetupNames = [];
        selectedSetupName = null;
      });
      return;
    }

    final process = await (db.select(db.processes)
          ..where((p) => p.processName.equals(widget.processName!)))
        .getSingleOrNull();
    if (process == null) return;

    final processPart = await (db.select(db.processParts)
          ..where((pp) =>
              pp.processId.equals(process.id) &
              pp.partNumber.equals(partNumber)))
        .getSingleOrNull();
    if (processPart == null) {
      setState(() {
        existingSetupNames = [];
        selectedSetupName = null;
      });
      return;
    }

    final query = db.select(db.setupElements, distinct: true)
      ..where((tbl) => tbl.processPartId.equals(processPart.id));
    final setups = await query.get();

    setState(() {
      existingSetupNames = setups.map((s) => s.setupName).toSet().toList();
      selectedSetupName = null;
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
    print('_fetchPartNumbers called with processName: ${widget.processName}');
    if (widget.processName == null) {
      print('processName is null, returning early');
      return;
    }
    // Find process for the selected processName
    final process = await (db.select(db.processes)
          ..where((p) => p.processName.equals(widget.processName!)))
        .getSingleOrNull();
    print('Found process: $process');
    if (process == null) {
      print('Process not found, returning early');
      return;
    }
    // Get all part numbers for the value stream linked to this process
    final parts = await (db.select(db.parts)
          ..where((part) => part.valueStreamId.equals(process.valueStreamId)))
        .get();
    print('Found ${parts.length} parts');
    setState(() {
      partNumbers = parts.map((p) => p.partNumber).toList();
      if (partNumbers.isNotEmpty) {
        selectedPartNumber = partNumbers.first;
      }
    });
    print('partNumbers: $partNumbers, selectedPartNumber: $selectedPartNumber');
    // Show dialog after part numbers are loaded
    if (!dialogShown && partNumbers.isNotEmpty) {
      print('Scheduling dialog to show');
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        print('PostFrameCallback executing');
        await _fetchSetupsForPart(selectedPartNumber);
        print('About to show dialog');
        _showSetupDialog();
      });
      dialogShown = true;
    } else {
      print(
          'Dialog not shown: dialogShown=$dialogShown, partNumbers.isEmpty=${partNumbers.isEmpty}');
    }
  }

  Future<void> _showSetupDialog() async {
    String? localSelectedSetupName = selectedSetupName;
    String? localSelectedPartNumber = selectedPartNumber;
    List<String> localExistingSetupNames = List.from(existingSetupNames);
    final localSetupNameController =
        TextEditingController(text: setupNameController.text);

    final result = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Colors.yellow[100],
            title: Text('Setup for ${widget.processName ?? ''}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: localSelectedPartNumber,
                  items: partNumbers
                      .map((pn) => DropdownMenuItem(
                            value: pn,
                            child: Text(pn),
                          ))
                      .toList(),
                  onChanged: (val) async {
                    if (val != null) {
                      setState(() {
                        localSelectedPartNumber = val;
                        localSelectedSetupName = null;
                        localExistingSetupNames = [];
                      });
                      await _fetchSetupsForPart(val);
                      setState(() {
                        localExistingSetupNames = List.from(existingSetupNames);
                      });
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: 'Part Number',
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: localSelectedSetupName,
                  hint: const Text('Select or Create Setup'),
                  items: [
                    ...localExistingSetupNames.map((name) => DropdownMenuItem(
                          value: name,
                          child: Text(name),
                        )),
                    DropdownMenuItem(
                      value: _newSetupOption,
                      child: Text(_newSetupOption),
                    ),
                  ],
                  onChanged: (val) {
                    setState(() {
                      localSelectedSetupName = val;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Setup Name',
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                if (localSelectedSetupName == _newSetupOption) ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: localSetupNameController,
                    decoration: const InputDecoration(
                      labelText: 'Enter New Setup Name',
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onSubmitted: (value) {
                      final setupChoice = value;
                      if (localSelectedPartNumber != null &&
                          setupChoice.isNotEmpty) {
                        Navigator.of(context).pop({
                          'partNumber': localSelectedPartNumber,
                          'setupName': setupChoice,
                        });
                      }
                    },
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(null);
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final setupChoice = localSelectedSetupName == _newSetupOption
                      ? localSetupNameController.text
                      : localSelectedSetupName;

                  if (localSelectedPartNumber != null &&
                      setupChoice != null &&
                      setupChoice.isNotEmpty) {
                    Navigator.of(context).pop({
                      'partNumber': localSelectedPartNumber,
                      'setupName': setupChoice,
                    });
                  }
                },
                child: const Text('OK'),
              ),
            ],
          );
        });
      },
    );

    if (result != null && result is Map<String, dynamic>) {
      print('Dialog result received: $result');

      setState(() {
        selectedPartNumber = result['partNumber'];
        setupName = result['setupName'];
        setupDateTime = DateTime.now();
      });

      print(
          'Updated state: processPartId will be determined, setupName: $setupName');

      final process = await (db.select(db.processes)
            ..where((p) => p.processName.equals(widget.processName!)))
          .getSingleOrNull();
      if (process == null) {
        print('Process not found for: ${widget.processName}');
        return;
      }

      final existingProcessPart = await (db.select(db.processParts)
            ..where((pp) =>
                pp.processId.equals(process.id) &
                pp.partNumber.equals(selectedPartNumber!)))
          .getSingleOrNull();

      if (existingProcessPart != null) {
        setState(() {
          processPartId = existingProcessPart.id;
        });
        print('Found existing processPartId: $processPartId');
      } else {
        final newProcessPartId = await db.into(db.processParts).insert(
              ProcessPartsCompanion(
                partNumber: drift.Value(selectedPartNumber!),
                processId: drift.Value(process.id),
              ),
            );
        setState(() {
          processPartId = newProcessPartId;
        });
        print('Created new processPartId: $processPartId');
      }

      print(
          'Final state: processPartId: $processPartId, setupName: $setupName');
      // Note: The ElementListCard widget will automatically fetch elements
      // based on the processPartId and setupName we just set
    } else {
      // ignore: use_build_context_synchronously
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Element Input'),
        backgroundColor: Colors.white,
      ),
      drawer: const AppDrawer(),
      backgroundColor: Colors.yellow[100],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print('Manual dialog trigger');
          _showSetupDialog();
        },
        backgroundColor: Colors.yellow[300],
        child: const Icon(Icons.settings),
      ),
      body: Column(
        children: [
          // Removed HomeHeader
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
                        child: Column(
                          children: [
                            DetailedSelectionDisplayCard(
                              companyName: widget.companyName,
                              plantName: widget.plantName,
                              valueStreamName: widget.valueStreamName,
                              processName: widget.processName,
                              setupName: setupName,
                              partNumber: selectedPartNumber,
                            ),
                            Card(
                              color: Colors.yellow[50],
                              elevation: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Center(
                                      child: Text('Add Element',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                  fontWeight: FontWeight.bold)),
                                    ),
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
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.yellow[300],
                                          foregroundColor: Colors.black,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 16),
                                          textStyle: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          elevation: 6,
                                        ),
                                        onPressed: () async {
                                          if (processPartId != null &&
                                              setupName != null &&
                                              setupDateTime != null &&
                                              newElementNameController
                                                  .text.isNotEmpty &&
                                              newTimeController
                                                  .text.isNotEmpty) {
                                            await db
                                                .into(db.setupElements)
                                                .insert(
                                                  SetupElementsCompanion(
                                                    processPartId: drift.Value(
                                                        processPartId!),
                                                    setupName:
                                                        drift.Value(setupName!),
                                                    setupDateTime: drift.Value(
                                                        setupDateTime!),
                                                    elementName: drift.Value(
                                                        newElementNameController
                                                            .text),
                                                    time: drift.Value(
                                                        newTimeController.text),
                                                  ),
                                                );
                                            // Clear the input fields
                                            newElementNameController.clear();
                                            newTimeController.text = '00:00:00';
                                            // The ElementListCard will automatically refresh
                                            setState(
                                                () {}); // Trigger rebuild to refresh ElementListCard
                                          }
                                        },
                                        child: const Text('Add Element'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      // Elements list (right) - now using ElementListCard widget
                      Flexible(
                        flex: 2,
                        child: ElementListCard(
                          key: ValueKey('${processPartId}_$setupName'),
                          processPartId: processPartId,
                          setupName: setupName,
                          onElementChanged: () {
                            // This callback can be used if we need to react to element changes
                            // For now, no additional action needed
                          },
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
