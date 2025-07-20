import 'package:flutter/material.dart';
import '../models/organization_data.dart' as org_data;
import '../widgets/app_footer.dart';
import '../database_provider.dart';
import '../logic/app_database.dart';
import 'package:drift/drift.dart' as drift;
import 'home_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _selectedPlantIdx = widget.initialPlantIndex; // Use the passed-in index
    _initialLoad = _loadInitialData();
  }

  Future<void> _saveCurrentPlantDetails() async {
    if (db == null || _selectedPlantIdx == null) return;

    // Safeguard: Do not save if the plant name is empty
    if (_plantNameController.text.trim().isEmpty) {
      return;
    }

    final plantToSave = org_data.OrganizationData.plants[_selectedPlantIdx!];
    final orgId = 1; // Assuming a static orgId for now.

    // Update the plant object from the controllers before saving
    plantToSave.name = _plantNameController.text;
    plantToSave.street = _streetController.text;
    plantToSave.city = _cityController.text;
    plantToSave.state = _stateController.text;
    plantToSave.zip = _zipController.text;

    await db!.upsertPlant(
      organizationId: orgId,
      name: plantToSave.name,
      street: plantToSave.street,
      city: plantToSave.city,
      state: plantToSave.state,
      zip: plantToSave.zip,
    );

    // Fetch the plant ID after upsert
    final dbPlant = await (db!.select(db!.plants)
          ..where((tbl) =>
              tbl.organizationId.equals(orgId) &
              tbl.name.equals(plantToSave.name)))
        .getSingleOrNull();
    final plantId = dbPlant?.id ?? -1;

    if (plantId == -1) {
      return; // Don't save value streams if plant wasn't saved
    }

    // First, delete existing value streams for this plant to handle removals
    await (db!.delete(db!.valueStreams)
          ..where((tbl) => tbl.plantId.equals(plantId)))
        .go();

    // Then, insert the current ones
    final valueStreamNames = plantValueStreams[plantToSave.name] ?? [];
    for (final vsName in valueStreamNames) {
      await db!.upsertValueStream(
        ValueStreamsCompanion(
          plantId: drift.Value(plantId),
          name: drift.Value(vsName),
        ),
      );
    }
  }

  Future<void> _loadInitialData() async {
    db = await DatabaseProvider.getInstance();
    // Load data for the initially selected plant
    if (mounted) {
      await _loadSelectedPlantData();
    }
  }

  void _ensurePlantDataInitialized(List<org_data.PlantData> plants) {
    for (final plant in plants) {
      plantValueStreams.putIfAbsent(plant.name, () => <String>[]);
      _controllers.putIfAbsent(plant.name, () => TextEditingController());
    }
  }

  Future<void> _loadSelectedPlantData() async {
    if (db == null || _selectedPlantIdx == null) return;
    final plants = org_data.OrganizationData.plants;
    if (plants.isEmpty) return;
    final selectedPlant = plants[_selectedPlantIdx!];

    // Fetch plant address from DB
    final dbPlant = await (db!.select(db!.plants)
          ..where((tbl) => tbl.name.equals(selectedPlant.name)))
        .getSingleOrNull();

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
    // Fetch value streams from DB
    final valueStreams = await (db!.select(db!.valueStreams)
          ..where((tbl) => tbl.plantId.equals(dbPlant?.id ?? -1)))
        .get();
    setState(() {
      plantValueStreams[selectedPlant.name] =
          valueStreams.map((vs) => vs.name).toList();
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

  AppDatabase? db;

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

        return Scaffold(
          backgroundColor: Colors.yellow[50],
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
                        // Plant list
                        Container(
                          width: 220,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.yellow[300]!),
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: plants.length,
                            itemBuilder: (context, idx) {
                              final isSelected = idx == _selectedPlantIdx;
                              return Material(
                                color: isSelected
                                    ? Colors.yellow[100]
                                    : Colors.transparent,
                                child: ListTile(
                                  title: Text(plants[idx].name,
                                      style: TextStyle(
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal)),
                                  selected: isSelected,
                                  onTap: () async {
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
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 32),
                        // Plant details panel
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
                              onAdd: () {
                                final value = _controllers[selectedPlant.name]!
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
                                  });
                                }
                                // Do NOT reload or reset plant address fields here
                              },
                              onRemove: (idx) {
                                setState(() {
                                  plantValueStreams[selectedPlant.name]!
                                      .removeAt(idx);
                                });
                              },
                              onPlantChanged: (updated) {
                                // This now just updates the model in memory.
                                // The save happens via the dedicated button.
                                setState(() {
                                  final i = org_data.OrganizationData.plants
                                      .indexWhere(
                                          (p) => p.name == selectedPlant.name);
                                  if (i != -1) {
                                    org_data.OrganizationData.plants[i] =
                                        updated;
                                  }
                                });
                              },
                              onSave: _saveCurrentPlantDetails,
                              // Pass down the controllers
                              plantNameController: _plantNameController,
                              streetController: _streetController,
                              cityController: _cityController,
                              stateController: _stateController,
                              zipController: _zipController,
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
        );
      },
    );
  }

  void _updatePlantDetailControllers(org_data.PlantData plant) {
    _plantNameController.text = plant.name;
    _streetController.text = plant.street;
    _cityController.text = plant.city;
    _stateController.text = plant.state;
    _zipController.text = plant.zip;
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}

// PlantDetailsPanel widget (stateless)
class PlantDetailsPanel extends StatelessWidget {
  final org_data.PlantData plant;
  final List<String> valueStreams;
  final TextEditingController controller;
  final VoidCallback onAdd;
  final void Function(int) onRemove;
  final ValueChanged<org_data.PlantData> onPlantChanged;
  final Future<void> Function() onSave;

  // Add controller fields
  final TextEditingController plantNameController;
  final TextEditingController streetController;
  final TextEditingController cityController;
  final TextEditingController stateController;
  final TextEditingController zipController;

  const PlantDetailsPanel({
    super.key,
    required this.plant,
    required this.valueStreams,
    required this.controller,
    required this.onAdd,
    required this.onRemove,
    required this.onPlantChanged,
    required this.onSave,
    // Add controllers to constructor
    required this.plantNameController,
    required this.streetController,
    required this.cityController,
    required this.stateController,
    required this.zipController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.yellow[300]!),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ...existing card content...
          const Text(
            'Plant Details',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _buildTextField(
            label: 'Plant Name',
            controller: plantNameController,
            onChanged: (val) {}, // No longer needed, controller handles state
          ),
          const SizedBox(height: 8),
          _buildTextField(
            label: 'Street',
            controller: streetController,
            onChanged: (val) {}, // No longer needed, controller handles state
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  label: 'City',
                  controller: cityController,
                  onChanged:
                      (val) {}, // No longer needed, controller handles state
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTextField(
                  label: 'State',
                  controller: stateController,
                  onChanged:
                      (val) {}, // No longer needed, controller handles state
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTextField(
                  label: 'Zip',
                  controller: zipController,
                  onChanged:
                      (val) {}, // No longer needed, controller handles state
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    labelText: 'Add Value Stream Name',
                    border: OutlineInputBorder(),
                    isDense: true,
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onSubmitted: (_) => onAdd(),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow[300],
                  foregroundColor: Colors.black,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 6,
                ),
                onPressed: onAdd,
                child: const Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Scrollbar(
              thumbVisibility: true,
              child: ListView.builder(
                itemCount: valueStreams.length,
                itemBuilder: (context, idx) {
                  return ListTile(
                    title: Text(valueStreams[idx]),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => onRemove(idx),
                    ),
                  );
                },
              ),
            ),
          ),
          // Save Plant Details and Home buttons at bottom center
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow[300],
                  foregroundColor: Colors.black,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 8,
                ),
                onPressed: () async {
                  await onSave();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Plant details saved!')),
                  );
                },
                child: const Text('Save Plant Details'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow[300],
                  foregroundColor: Colors.black,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 8,
                ),
                onPressed: () async {
                  await onSave();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                    (Route<dynamic> route) => false,
                  );
                },
                child: const Text('Home'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
        filled: true,
        fillColor: Colors.white,
      ),
      onChanged: onChanged,
    );
  }
}
