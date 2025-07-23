import 'package:flutter/material.dart';
import 'dart:async';
import '../models/organization_data.dart' as org_data;
import '../widgets/app_footer.dart';
import '../widgets/app_drawer.dart';
import '../database_provider.dart';
import '../logic/plant_repository.dart';
import '../widgets/plant_details_panel.dart';
import '../widgets/plant_list.dart';

// Global map to hold plant name -> value streams (one-to-many)
Map<String, List<String>> plantValueStreams = {};

class PlantSetupScreen extends StatefulWidget {
  final int initialPlantIndex;

  const PlantSetupScreen({
    super.key,
    this.initialPlantIndex = 0, // Default to the first plant if not provided
  });

  @override
  State<PlantSetupScreen> createState() => _PlantSetupScreenState();
}

class _PlantSetupScreenState extends State<PlantSetupScreen> {
  Future<void>? _initialLoad;
  bool _isLoading = false;
  late PlantRepository _repository;
  bool _hasUnsavedChanges = false;
  Timer? _autoSaveTimer;

  @override
  void initState() {
    super.initState();
    _selectedPlantIdx = widget.initialPlantIndex; // Use the passed-in index
    _initialLoad = _loadInitialData();

    // Add listeners to track changes
    _plantNameController.addListener(_markAsChanged);
    _streetController.addListener(_markAsChanged);
    _cityController.addListener(_markAsChanged);
    _stateController.addListener(_markAsChanged);
    _zipController.addListener(_markAsChanged);
  }

  void _markAsChanged() {
    if (!_hasUnsavedChanges) {
      setState(() {
        _hasUnsavedChanges = true;
      });
    }
    // Auto-save after a short delay to avoid excessive saves
    _triggerAutoSave();
  }

  void _triggerAutoSave() {
    // Cancel any existing timer
    _autoSaveTimer?.cancel();

    // Start a new timer for auto-save after 1 second of inactivity
    _autoSaveTimer = Timer(const Duration(seconds: 1), () {
      _saveCurrentPlantDetails();
    });
  }

  void _markAsSaved() {
    setState(() {
      _hasUnsavedChanges = false;
    });
  }

  Future<bool> _onWillPop() async {
    if (!_hasUnsavedChanges) {
      return true; // Allow navigation if no unsaved changes
    }

    // Show confirmation dialog
    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Unsaved Changes'),
          content: const Text(
            'You have unsaved changes. Do you want to save them before leaving?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Discard'),
              onPressed: () {
                Navigator.of(context).pop(false); // Don't save, just leave
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(null); // Cancel navigation
              },
            ),
            ElevatedButton(
              child: const Text('Save'),
              onPressed: () {
                Navigator.of(context).pop(true); // Save and leave
              },
            ),
          ],
        );
      },
    );

    if (shouldSave == null) {
      return false; // Cancel navigation
    } else if (shouldSave) {
      await _saveCurrentPlantDetails();
      _markAsSaved();
      return true; // Allow navigation after saving
    } else {
      return true; // Allow navigation without saving
    }
  }

  Future<void> _saveCurrentPlantDetails() async {
    if (_selectedPlantIdx == null) return;

    // Safeguard: Do not save if the plant name is empty
    if (_plantNameController.text.trim().isEmpty) {
      return;
    }

    final plantToSave = org_data.OrganizationData.plants[_selectedPlantIdx!];

    // Update the plant object from the controllers before saving
    plantToSave.name = _plantNameController.text;
    plantToSave.street = _streetController.text;
    plantToSave.city = _cityController.text;
    plantToSave.state = _stateController.text;
    plantToSave.zip = _zipController.text;

    final valueStreamNames = plantValueStreams[plantToSave.name] ?? [];

    await _repository.savePlantDetails(plantToSave, valueStreamNames);
    _markAsSaved(); // Mark as saved after successful save
  }

  Future<void> _loadInitialData() async {
    final db = await DatabaseProvider.getInstance();
    _repository = PlantRepository(db);

    // Load all plants from database into OrganizationData.plants
    final dbPlants = await _repository.getAllPlants();
    org_data.OrganizationData.plants = dbPlants;

    // Load data for the initially selected plant
    if (mounted) {
      await _loadSelectedPlantData();
    }
  }

  void _ensurePlantDataInitialized(List<org_data.PlantData> plants) {
    for (final plant in plants) {
      plantValueStreams.putIfAbsent(plant.name, () => <String>[]);
      if (!_controllers.containsKey(plant.name)) {
        final controller = TextEditingController();
        // Add listener to value stream controller for auto-save on text changes
        controller.addListener(() {
          // Only trigger auto-save if the field is not empty and user is actively typing
          if (controller.text.isNotEmpty) {
            _markAsChanged();
          }
        });
        _controllers[plant.name] = controller;
      }
    }
  }

  Future<void> _loadSelectedPlantData() async {
    if (_selectedPlantIdx == null) return;
    final plants = org_data.OrganizationData.plants;
    if (plants.isEmpty) return;
    final selectedPlant = plants[_selectedPlantIdx!];

    // Fetch plant address from DB using the repository
    final dbPlant = await _repository.getPlant(selectedPlant.name);

    if (dbPlant != null) {
      setState(() {
        // Update the model object
        selectedPlant.street = dbPlant.street;
        selectedPlant.city = dbPlant.city;
        selectedPlant.state = dbPlant.state;
        selectedPlant.zip = dbPlant.zip;
        // Update the controllers
        _updatePlantDetailControllers(selectedPlant);
      });
    } else {
      // If no data in DB, clear the fields
      setState(() {
        selectedPlant.street = '';
        selectedPlant.city = '';
        selectedPlant.state = '';
        selectedPlant.zip = '';
        _updatePlantDetailControllers(selectedPlant);
      });
    }
    // Fetch value streams from DB using the repository
    final valueStreams = await _repository.getValueStreams(dbPlant?.id ?? -1);
    setState(() {
      plantValueStreams[selectedPlant.name] = valueStreams;
    });
  }

  // Controllers for each plant's value stream input
  final Map<String, TextEditingController> _controllers = {};
  int? _selectedPlantIdx;

  // Add controllers for plant details
  final _plantNameController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initialLoad,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        // Ensure all plant data is initialized to avoid null errors
        _ensurePlantDataInitialized(org_data.OrganizationData.plants);
        final plants = org_data.OrganizationData.plants;
        _selectedPlantIdx ??= plants.isNotEmpty ? 0 : null;
        final selectedPlant = (_selectedPlantIdx != null && plants.isNotEmpty)
            ? plants[_selectedPlantIdx!]
            : null;

        return PopScope(
          canPop: false, // Always handle pop manually
          onPopInvoked: (bool didPop) async {
            if (didPop) return; // Already popped

            final shouldPop = await _onWillPop();
            if (shouldPop && mounted) {
              // ignore: use_build_context_synchronously
              Navigator.of(context).pop();
            }
          },
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Plant Setup'),
              backgroundColor: Colors.white,
            ),
            drawer: const AppDrawer(),
            backgroundColor: Colors.yellow[100],
            resizeToAvoidBottomInset: true,
            body: LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Main body
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(width: 24),
                          // Plant list - aligned to top, takes only needed space
                          Align(
                            alignment: Alignment.topCenter,
                            child: PlantList(
                              plants: plants,
                              selectedPlantIdx: _selectedPlantIdx,
                              onPlantSelected: (idx) async {
                                // 1. Save the current plant's details
                                await _saveCurrentPlantDetails();

                                // 2. Set loading state and update index
                                setState(() {
                                  _selectedPlantIdx = idx;
                                  _isLoading = true;
                                });

                                // 3. Load data for the newly selected plant
                                await _loadSelectedPlantData();

                                // 4. Turn off loading state
                                setState(() {
                                  _isLoading = false;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 32),
                          // Plant details panel - takes remaining space
                          if (_isLoading)
                            const Expanded(
                              child: Center(child: CircularProgressIndicator()),
                            )
                          else if (selectedPlant != null)
                            Expanded(
                              child: PlantDetailsPanel(
                                plant: selectedPlant,
                                valueStreams:
                                    plantValueStreams[selectedPlant.name]!,
                                controller: _controllers[selectedPlant.name]!,
                                onAdd: () async {
                                  final value =
                                      _controllers[selectedPlant.name]!
                                          .text
                                          .trim();
                                  if (value.isNotEmpty &&
                                      !plantValueStreams[selectedPlant.name]!
                                          .contains(value)) {
                                    setState(() {
                                      plantValueStreams[selectedPlant.name]!
                                          .add(value);
                                      // Only clear the value stream input field
                                      _controllers[selectedPlant.name]!.clear();
                                      _markAsChanged(); // Mark as changed when value stream is added
                                    });
                                    // Auto-save immediately when value stream is added
                                    await _saveCurrentPlantDetails();
                                  }
                                  // Do NOT reload or reset plant address fields here
                                },
                                onRemove: (idx) async {
                                  setState(() {
                                    plantValueStreams[selectedPlant.name]!
                                        .removeAt(idx);
                                    _markAsChanged(); // Mark as changed when value stream is removed
                                  });
                                  // Auto-save immediately when value stream is removed
                                  await _saveCurrentPlantDetails();
                                },
                                onPlantChanged: (updated) {
                                  // This now just updates the model in memory.
                                  // The save happens via the dedicated button.
                                  setState(() {
                                    final i = org_data.OrganizationData.plants
                                        .indexWhere((p) =>
                                            p.name == selectedPlant.name);
                                    if (i != -1) {
                                      org_data.OrganizationData.plants[i] =
                                          updated;
                                    }
                                  });
                                },
                                // Pass down the controllers
                                plantNameController: _plantNameController,
                                streetController: _streetController,
                                cityController: _cityController,
                                stateController: _stateController,
                                zipController: _zipController,
                              ),
                            )
                          else
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.yellow[50],
                                  borderRadius: BorderRadius.circular(12),
                                  border:
                                      Border.all(color: Colors.yellow[300]!),
                                ),
                                padding: const EdgeInsets.all(32),
                                child: const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.factory_outlined,
                                        size: 64,
                                        color: Colors.grey,
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        'No Plants Available',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Please go to Organization Setup to add plants first.',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Footer replaced with AppFooter
                    const AppFooter(),
                  ],
                );
              },
            ),
          ), // Close the PopScope widget
        );
      },
    );
  }

  void _updatePlantDetailControllers(org_data.PlantData plant) {
    // Temporarily remove listeners to avoid triggering change detection during data loading
    _plantNameController.removeListener(_markAsChanged);
    _streetController.removeListener(_markAsChanged);
    _cityController.removeListener(_markAsChanged);
    _stateController.removeListener(_markAsChanged);
    _zipController.removeListener(_markAsChanged);

    // Update the controllers
    _plantNameController.text = plant.name;
    _streetController.text = plant.street;
    _cityController.text = plant.city;
    _stateController.text = plant.state;
    _zipController.text = plant.zip;

    // Re-add listeners
    _plantNameController.addListener(_markAsChanged);
    _streetController.addListener(_markAsChanged);
    _cityController.addListener(_markAsChanged);
    _stateController.addListener(_markAsChanged);
    _zipController.addListener(_markAsChanged);

    // Reset the unsaved changes flag since we just loaded data
    _markAsSaved();
  }

  @override
  void dispose() {
    // Cancel auto-save timer
    _autoSaveTimer?.cancel();

    // Remove listeners before disposing
    _plantNameController.removeListener(_markAsChanged);
    _streetController.removeListener(_markAsChanged);
    _cityController.removeListener(_markAsChanged);
    _stateController.removeListener(_markAsChanged);
    _zipController.removeListener(_markAsChanged);

    // Dispose controllers
    _plantNameController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();

    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}
