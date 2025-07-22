import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift;

import '../widgets/app_footer.dart';
import '../widgets/detailed_selection_display_card.dart';
import '../widgets/element_list_card.dart';
import '../screens/home_screen.dart';
import '../screens/organization_setup_screen.dart';
import '../screens/plant_setup_screen.dart';

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
  bool initialDialogCompleted = false;
  int? processPartId;
  String? setupName;
  DateTime? setupDateTime;
  TextEditingController newElementNameController = TextEditingController();
  TextEditingController newTimeController =
      TextEditingController(text: '00:00:00');
  List<String> existingSetupNames = [];
  String? selectedSetupName;
  final String _newSetupOption = 'Create New Setup...';

  // New flags for tracking setup state
  bool _isNewSetup = false;
  bool _hasModifiedSetup = false;
  List<SetupElement> _originalElements = [];
  List<SetupElement> _currentElements = [];
  int _elementListRefreshKey = 0;

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

    // Get setups from the Setups table instead of SetupElements
    final setups = await (db.select(db.setups)
          ..where((s) => s.processPartId.equals(processPart.id)))
        .get();

    setState(() {
      existingSetupNames = setups.map((s) => s.setupName).toSet().toList();
      selectedSetupName = null;
    });
  }

  // Check if setup has been modified by comparing current elements with original
  bool _checkIfSetupModified() {
    if (_isNewSetup) return _currentElements.isNotEmpty;

    // Compare current elements with original elements
    if (_currentElements.length != _originalElements.length) return true;

    for (int i = 0; i < _currentElements.length; i++) {
      final current = _currentElements[i];
      final original = _originalElements[i];
      if (current.elementName != original.elementName ||
          current.time != original.time) {
        return true;
      }
    }
    return false;
  }

  // Load existing setup elements and store as original
  Future<void> _loadExistingSetupElements(String setupName) async {
    if (processPartId == null) return;

    // First get the setup ID from the setup name
    final setup = await (db.select(db.setups)
          ..where((s) =>
              s.processPartId.equals(processPartId!) &
              s.setupName.equals(setupName)))
        .getSingleOrNull();

    if (setup == null) return;

    final elements = await (db.select(db.setupElements)
          ..where((tbl) =>
              tbl.processPartId.equals(processPartId!) &
              tbl.setupId.equals(setup.id)))
        .get();

    setState(() {
      _originalElements = List.from(elements);
      _currentElements = List.from(elements);
    });
  }

  // Save new setup and setup elements (used for saving modified existing setups with new names)
  Future<void> _saveNewSetup(String setupNameToSave) async {
    if (processPartId == null) return;

    // Save setup record and get the setup ID
    final setupId = await db.into(db.setups).insert(
          SetupsCompanion(
            processPartId: drift.Value(processPartId!),
            setupName: drift.Value(setupNameToSave),
          ),
        );

    // Save setup elements with the setup ID
    for (final element in _currentElements) {
      await db.into(db.setupElements).insert(
            SetupElementsCompanion(
              processPartId: drift.Value(processPartId!),
              setupId: drift.Value(setupId),
              setupDateTime: drift.Value(DateTime.now()),
              elementName: drift.Value(element.elementName),
              time: drift.Value(element.time),
            ),
          );
    }
  }

  // Handle navigation with setup protection
  Future<bool> _handleNavigation() async {
    _hasModifiedSetup = _checkIfSetupModified();

    if (_isNewSetup && _hasModifiedSetup) {
      // New setup with elements - setup record already exists, no need to save again
      return true; // Allow navigation
    } else if (!_isNewSetup && _hasModifiedSetup) {
      // Ask user if they want to rename existing setup
      final shouldRename = await _showRenameDialog();
      if (shouldRename != null && shouldRename) {
        final newName = await _showNewNameDialog();
        if (newName != null && newName.isNotEmpty) {
          await _saveNewSetup(newName);
        }
      }
      return true; // Allow navigation
    }

    return true; // Allow navigation if no modifications
  }

  // Show dialog asking if user wants to rename setup
  Future<bool?> _showRenameDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Setup Modified'),
          content: const Text(
              'You have modified this existing setup. Would you like to save it as a new setup with a different name?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('No, Discard Changes'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Yes, Save as New'),
            ),
          ],
        );
      },
    );
  }

  // Show dialog to get new setup name
  Future<String?> _showNewNameDialog() async {
    final controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('New Setup Name'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Enter new setup name',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  Navigator.of(context).pop(controller.text);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
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
    if (widget.processName == null) {
      return;
    }
    // Find process for the selected processName
    final process = await (db.select(db.processes)
          ..where((p) => p.processName.equals(widget.processName!)))
        .getSingleOrNull();
    if (process == null) {
      return;
    }
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
    if (!dialogShown && partNumbers.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _fetchSetupsForPart(selectedPartNumber);
        _showSetupDialog();
      });
      dialogShown = true;
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
      setState(() {
        selectedPartNumber = result['partNumber'];
        setupName = result['setupName'];
        setupDateTime = DateTime.now();

        // Determine if this is a new setup
        _isNewSetup = !existingSetupNames.contains(setupName);
        _hasModifiedSetup = false;
        initialDialogCompleted = true;
      });

      final process = await (db.select(db.processes)
            ..where((p) => p.processName.equals(widget.processName!)))
          .getSingleOrNull();
      if (process == null) {
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
      }

      // Handle setup creation and element loading
      if (!_isNewSetup && setupName != null) {
        // Existing setup - load elements
        await _loadExistingSetupElements(setupName!);
      } else if (_isNewSetup && setupName != null && processPartId != null) {
        // New setup - create the setup record immediately
        await db.into(db.setups).insert(
              SetupsCompanion(
                processPartId: drift.Value(processPartId!),
                setupName: drift.Value(setupName!),
              ),
            );
        setState(() {
          _originalElements = [];
          _currentElements = [];
        });
      } else {
        setState(() {
          _originalElements = [];
          _currentElements = [];
        });
      }

      // Note: The ElementListCard widget will automatically fetch elements
      // based on the processPartId and setupName we just set
    } else {
      // Dialog was cancelled, mark that initial dialog interaction is complete
      setState(() {
        initialDialogCompleted = true;
      });
      // ignore: use_build_context_synchronously
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;
        final shouldPop = await _handleNavigation();
        if (shouldPop && mounted) {
          // ignore: use_build_context_synchronously
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Element Input'),
          backgroundColor: Colors.white,
        ),
        drawer: _buildCustomDrawer(),
        backgroundColor: Colors.yellow[100],
        floatingActionButton: FloatingActionButton(
          heroTag: "setup",
          onPressed: () {
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
                            mainAxisSize: MainAxisSize.min,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Center(
                                        child: Text('Add Element',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                      ),
                                      if (setupName == null &&
                                          initialDialogCompleted) ...[
                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.orange[100],
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            border: Border.all(
                                                color: Colors.orange),
                                          ),
                                          child: const Text(
                                            'Please complete setup dialog first (tap settings button)',
                                            style: TextStyle(
                                              color: Colors.orange,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ],
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
                                              try {
                                                // First get the setup ID from the setup name
                                                final setup = await (db
                                                        .select(db.setups)
                                                      ..where((s) =>
                                                          s.processPartId.equals(
                                                              processPartId!) &
                                                          s.setupName.equals(
                                                              setupName!)))
                                                    .getSingleOrNull();

                                                if (setup == null) {
                                                  if (mounted) {
                                                    // ignore: use_build_context_synchronously
                                                    ScaffoldMessenger.of(
                                                        // ignore: use_build_context_synchronously
                                                        context).showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                            'Setup not found'),
                                                        backgroundColor:
                                                            Colors.red,
                                                      ),
                                                    );
                                                  }
                                                  return;
                                                }

                                                // Get the count of existing elements to set the order index
                                                final existingElements = await (db
                                                        .select(
                                                            db.setupElements)
                                                      ..where((tbl) =>
                                                          tbl.processPartId.equals(
                                                              processPartId!) &
                                                          tbl.setupId.equals(
                                                              setup.id)))
                                                    .get();
                                                final nextOrderIndex =
                                                    existingElements.length;

                                                // Add to database for immediate display
                                                await db
                                                    .into(db.setupElements)
                                                    .insert(
                                                      SetupElementsCompanion(
                                                        processPartId:
                                                            drift.Value(
                                                                processPartId!),
                                                        setupId: drift.Value(
                                                            setup.id),
                                                        setupDateTime:
                                                            drift.Value(
                                                                setupDateTime!),
                                                        elementName: drift.Value(
                                                            newElementNameController
                                                                .text),
                                                        time: drift.Value(
                                                            newTimeController
                                                                .text),
                                                        orderIndex: drift.Value(
                                                            nextOrderIndex),
                                                      ),
                                                    );

                                                // Update current elements list for tracking changes
                                                await _refreshCurrentElements();

                                                // Increment refresh key to force ElementListCard rebuild
                                                setState(() {
                                                  _elementListRefreshKey++;
                                                });

                                                // Clear the input fields
                                                newElementNameController
                                                    .clear();
                                                newTimeController.text =
                                                    '00:00:00';
                                              } catch (e) {
                                                // Show error message if insertion fails
                                                if (mounted) {
                                                  // ignore: use_build_context_synchronously
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                          'Error adding element: $e'),
                                                      backgroundColor:
                                                          Colors.red,
                                                    ),
                                                  );
                                                }
                                              }
                                            } else {
                                              // Show message if required fields are missing
                                              if (mounted) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                        'Please complete the setup dialog first and fill in all fields'),
                                                    backgroundColor:
                                                        Colors.orange,
                                                  ),
                                                );
                                              }
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
                            key: ValueKey(
                                '${processPartId}_${setupName}_$_elementListRefreshKey'),
                            processPartId: processPartId,
                            setupName: setupName,
                            onElementChanged: () {
                              // Update current elements when changes occur in the card
                              _refreshCurrentElements();
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
      ),
    );
  }

  // Refresh current elements list when ElementListCard changes
  Future<void> _refreshCurrentElements() async {
    if (processPartId != null && setupName != null) {
      // Get the setup ID first
      final existingSetup = await (db.select(db.setups)
            ..where((setup) =>
                setup.processPartId.equals(processPartId!) &
                setup.setupName.equals(setupName!)))
          .getSingleOrNull();

      if (existingSetup != null) {
        final elements = await (db.select(db.setupElements)
              ..where((tbl) =>
                  tbl.processPartId.equals(processPartId!) &
                  tbl.setupId.equals(existingSetup.id)))
            .get();

        setState(() {
          _currentElements = List.from(elements);
        });
      }
    }
  }

  // Build custom drawer with navigation protection
  Widget _buildCustomDrawer() {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          GestureDetector(
            onTap: () async {
              Navigator.pop(context); // Close drawer
              final shouldNavigate = await _handleNavigation();
              if (shouldNavigate && mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                );
              }
            },
            child: DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: Row(
                children: [
                  Image.asset(
                    'assets/images/calx_logo.png',
                    height: 60,
                    width: 60,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Calx LLC Industrial Tools',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () async {
              Navigator.pop(context); // Close drawer
              final shouldNavigate = await _handleNavigation();
              if (shouldNavigate && mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                );
              }
            },
          ),
          ExpansionTile(
            leading: const Icon(Icons.business),
            title: const Text('Organizational Setup'),
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.account_tree),
                title: const Text('Organization Setup'),
                contentPadding: const EdgeInsets.only(left: 72.0, right: 16.0),
                onTap: () async {
                  Navigator.pop(context); // Close drawer
                  final shouldNavigate = await _handleNavigation();
                  if (shouldNavigate && mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const OrganizationSetupScreen()),
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.location_city),
                title: const Text('Plant & Value Stream Setup'),
                contentPadding: const EdgeInsets.only(left: 72.0, right: 16.0),
                onTap: () async {
                  Navigator.pop(context); // Close drawer
                  final shouldNavigate = await _handleNavigation();
                  if (shouldNavigate && mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const PlantSetupScreen()),
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.precision_manufacturing),
                title: const Text('Part Number Setup'),
                contentPadding: const EdgeInsets.only(left: 72.0, right: 16.0),
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                  _showPartSetupDialog();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showPartSetupDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Part Number Setup'),
          content: const Text(
            'To access Part Number Setup, please first select a Company, Plant, and Value Stream from the Home screen.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Go to Home'),
              onPressed: () async {
                Navigator.of(context).pop(); // Close dialog
                final shouldNavigate = await _handleNavigation();
                if (shouldNavigate && mounted) {
                  Navigator.pushReplacement(
                    // ignore: use_build_context_synchronously
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                  );
                }
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
            ),
          ],
        );
      },
    );
  }
}
