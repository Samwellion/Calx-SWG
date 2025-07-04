import 'package:flutter/material.dart';
import 'organization_setup_screen.dart';

import '../database_provider.dart';
import '../models/organization_data.dart' as org_data;

// Global map to hold plant name -> value streams (one-to-many)
Map<String, List<String>> plantValueStreams = {};

class PlantSetupScreen extends StatefulWidget {
  const PlantSetupScreen({super.key});

  @override
  State<PlantSetupScreen> createState() => _PlantSetupScreenState();
}

class _PlantSetupScreenState extends State<PlantSetupScreen> {
  Future<void> _saveAllToDatabase() async {
    debugPrint('Getting singleton database instance...');
    final db = await DatabaseProvider.getInstance();
    debugPrint(
        'Upserting organization: \'${org_data.OrganizationData.companyName}\'');
    final orgId =
        await db.upsertOrganization(org_data.OrganizationData.companyName);
    debugPrint('Organization id: $orgId');
    for (final plant in org_data.OrganizationData.plants) {
      debugPrint('Upserting plant: \'${plant.name}\'');
      final plantId = await db.upsertPlant(
        organizationId: orgId,
        name: plant.name,
        street: plant.street,
        city: plant.city,
        state: plant.state,
        zip: plant.zip,
      );
      debugPrint('Plant id: $plantId');
      final streams = plantValueStreams[plant.name] ?? [];
      for (int i = 0; i < streams.length; i++) {
        debugPrint(
            '  Upserting value stream: \'${streams[i]}\' for plantId: $plantId');
        await db.upsertValueStream(plantId: plantId, name: streams[i]);
        if (i % 10 == 9) {
          await Future.delayed(Duration.zero);
        }
      }
      await Future.delayed(Duration.zero);
    }
    debugPrint('SaveAllToDatabase complete.');
  }

  // Controllers for each plant's value stream input
  final Map<String, TextEditingController> _controllers = {};
  int? _selectedPlantIndex;

  @override
  void initState() {
    super.initState();
    for (final plant in org_data.OrganizationData.plants) {
      _controllers[plant.name] = TextEditingController();
      plantValueStreams.putIfAbsent(plant.name, () => []);
    }
    if (org_data.OrganizationData.plants.isNotEmpty) {
      _selectedPlantIndex = 0;
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addValueStream(String plantName) {
    final controller = _controllers[plantName];
    final value = controller?.text.trim() ?? '';
    if (value.isNotEmpty && !plantValueStreams[plantName]!.contains(value)) {
      setState(() {
        plantValueStreams[plantName]!.add(value);
        controller?.clear();
      });
    }
  }

  void _removeValueStream(String plantName, int index) {
    setState(() {
      plantValueStreams[plantName]!.removeAt(index);
    });
  }

  void _goBack() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final plants = org_data.OrganizationData.plants;
    final selectedIdx = _selectedPlantIndex;
    final selectedPlant =
        (selectedIdx != null && selectedIdx >= 0 && selectedIdx < plants.length)
            ? plants[selectedIdx]
            : null;
    final valueStreams = selectedPlant != null
        ? plantValueStreams[selectedPlant.name] ?? []
        : [];

    return Scaffold(
      backgroundColor: Colors.yellow[100],
      body: Column(
        children: [
          const OrganizationSetupHeader(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.yellow[50],
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(bottom: 16.0),
                          child: Text(
                            'Plant Setup',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (plants.isNotEmpty)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              PlantListSelector(
                                plants: plants,
                                selectedIndex: selectedIdx,
                                onPlantSelected: (idx) {
                                  setState(() {
                                    _selectedPlantIndex = idx;
                                  });
                                },
                              ),
                              if (selectedPlant != null)
                                Expanded(
                                  child: PlantDetailsPanel(
                                    plant: selectedPlant,
                                    valueStreams:
                                        List<String>.from(valueStreams),
                                    controller:
                                        _controllers[selectedPlant.name]!,
                                    onAdd: () =>
                                        _addValueStream(selectedPlant.name),
                                    onRemove: (idx) => _removeValueStream(
                                        selectedPlant.name, idx),
                                    onPlantChanged: (updatedPlant) {
                                      setState(() {
                                        org_data.OrganizationData
                                                .plants[selectedIdx!] =
                                            updatedPlant;
                                      });
                                    },
                                  ),
                                ),
                            ],
                          )
                        else
                          const Text(
                            'No plants found for this company.',
                            style: TextStyle(color: Colors.black54),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          OrganizationSetupFooter(
            onBack: _goBack,
            rightButton: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow[300],
                foregroundColor: Colors.black,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                textStyle:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 6,
              ),
              onPressed: () async {
                debugPrint('Save button pressed. Starting save...');
                final nav = Navigator.of(context);
                final messenger = ScaffoldMessenger.of(context);
                await _saveAllToDatabase();
                debugPrint('Save complete. Showing snackbar.');
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Plant and value stream data saved!'),
                    duration: Duration(seconds: 2),
                  ),
                );
                debugPrint('Navigating back to home.');
                nav.popUntil((route) => route.isFirst);
                debugPrint('Navigation complete.');
              },
              child: const Text('Save and Proceed to Home'),
            ),
          ),
        ],
      ),
    );
  }
}

class PlantListSelector extends StatelessWidget {
  final List<org_data.PlantData> plants;
  final int? selectedIndex;
  final ValueChanged<int> onPlantSelected;
  const PlantListSelector({
    super.key,
    required this.plants,
    required this.selectedIndex,
    required this.onPlantSelected,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.yellow[300]!),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: plants.length,
        itemBuilder: (context, idx) {
          final plant = plants[idx];
          final selected = idx == selectedIndex;
          return Material(
            color: selected ? Colors.yellow[200] : Colors.transparent,
            child: ListTile(
              title: Text(
                plant.name,
                style: TextStyle(
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  color: selected ? Colors.black : Colors.black87,
                ),
              ),
              selected: selected,
              onTap: () => onPlantSelected(idx),
            ),
          );
        },
      ),
    );
  }
}

class PlantDetailsPanel extends StatelessWidget {
  final org_data.PlantData plant;
  final List<String> valueStreams;
  final TextEditingController controller;
  final VoidCallback onAdd;
  final void Function(int) onRemove;
  final ValueChanged<org_data.PlantData> onPlantChanged;
  const PlantDetailsPanel({
    super.key,
    required this.plant,
    required this.valueStreams,
    required this.controller,
    required this.onAdd,
    required this.onRemove,
    required this.onPlantChanged,
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
          const Text(
            'Plant Details',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _buildTextField(
            label: 'Plant Name',
            initialValue: plant.name,
            onChanged: (val) => onPlantChanged(plant.copyWith(name: val)),
          ),
          const SizedBox(height: 8),
          _buildTextField(
            label: 'Street',
            initialValue: plant.street,
            onChanged: (val) => onPlantChanged(plant.copyWith(street: val)),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  label: 'City',
                  initialValue: plant.city,
                  onChanged: (val) => onPlantChanged(plant.copyWith(city: val)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTextField(
                  label: 'State',
                  initialValue: plant.state,
                  onChanged: (val) =>
                      onPlantChanged(plant.copyWith(state: val)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTextField(
                  label: 'Zip',
                  initialValue: plant.zip,
                  onChanged: (val) => onPlantChanged(plant.copyWith(zip: val)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Value Streams',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
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
          SizedBox(
            height: 180,
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
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String initialValue,
    required ValueChanged<String> onChanged,
  }) {
    final controller = TextEditingController(text: initialValue);
    controller.selection = TextSelection.fromPosition(
      TextPosition(offset: controller.text.length),
    );
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
