import 'package:flutter/material.dart';

import '../models/organization_data.dart' as org_data;
import '../logic/app_database.dart';
import '../database_provider.dart';
import '../widgets/home_header.dart';
import '../screens/home_screen.dart';

// Global map to hold plant name -> value streams (one-to-many)
Map<String, List<String>> plantValueStreams = {};

class PlantSetupScreen extends StatefulWidget {
  const PlantSetupScreen({super.key});

  @override
  State<PlantSetupScreen> createState() => _PlantSetupScreenState();
}

class _PlantSetupScreenState extends State<PlantSetupScreen> {
  int? _selectedPlantIdx;

  @override
  Widget build(BuildContext context) {
    final plants = org_data.OrganizationData.plants;
    _selectedPlantIdx ??= plants.isNotEmpty ? 0 : null;
    final selectedPlant = (_selectedPlantIdx != null && plants.isNotEmpty)
        ? plants[_selectedPlantIdx!]
        : null;
    return Scaffold(
      backgroundColor: Colors.yellow[50],
      body: Column(
        children: [
          // Standard HomeHeader
          HomeHeader(
            companyName: org_data.OrganizationData.companyName,
            plantName: selectedPlant?.name,
            valueStreamName: null,
          ),
          const SizedBox(height: 24),
          // Main body: left = plant list, right = details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Plant name selectable list
                  Container(
                    width: 220,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.yellow[300]!),
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
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
                            onTap: () {
                              setState(() {
                                _selectedPlantIdx = idx;
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 32),
                  // Plant details panel
                  if (selectedPlant != null)
                    Expanded(
                      child: PlantDetailsPanel(
                        plant: selectedPlant,
                        valueStreams: plantValueStreams[selectedPlant.name]!,
                        controller: _controllers[selectedPlant.name]!,
                        onAdd: () {
                          final value =
                              _controllers[selectedPlant.name]!.text.trim();
                          if (value.isNotEmpty &&
                              !plantValueStreams[selectedPlant.name]!
                                  .contains(value)) {
                            setState(() {
                              plantValueStreams[selectedPlant.name]!.add(value);
                              _controllers[selectedPlant.name]!.clear();
                            });
                          }
                        },
                        onRemove: (idx) {
                          setState(() {
                            plantValueStreams[selectedPlant.name]!
                                .removeAt(idx);
                          });
                        },
                        onPlantChanged: (updated) {
                          setState(() {
                            final i = org_data.OrganizationData.plants
                                .indexWhere(
                                    (p) => p.name == selectedPlant.name);
                            if (i != -1)
                              org_data.OrganizationData.plants[i] = updated;
                          });
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
          // Footer
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
                SizedBox(
                  width: 180,
                  child: ElevatedButton.icon(
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
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    onPressed: () async {
                      // Save all plants and value streams to the database
                      final db = await DatabaseProvider.getInstance();
                      // Save organization (assuming single org for now)
                      final orgName = org_data.OrganizationData.companyName;
                      final orgId = await db.upsertOrganization(orgName);
                      for (final plant in org_data.OrganizationData.plants) {
                        final plantId = await db.upsertPlant(
                          organizationId: orgId,
                          name: plant.name,
                          street: plant.street,
                          city: plant.city,
                          state: plant.state,
                          zip: plant.zip,
                        );
                        final valueStreams =
                            plantValueStreams[plant.name] ?? [];
                        for (final vs in valueStreams) {
                          await db.upsertValueStream(
                              plantId: plantId, name: vs);
                        }
                      }
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const HomeScreen(),
                        ),
                      );
                    },
                  ),
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

  // Controllers for each plant's value stream input
  final Map<String, TextEditingController> _controllers = {};
  late final ValueNotifier<int?> _selectedPlantIndex;

  @override
  void initState() {
    super.initState();
    for (final plant in org_data.OrganizationData.plants) {
      _controllers[plant.name] = TextEditingController();
      plantValueStreams.putIfAbsent(plant.name, () => []);
    }
    _selectedPlantIndex = ValueNotifier<int?>(
      org_data.OrganizationData.plants.isNotEmpty ? 0 : null,
    );
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _selectedPlantIndex.dispose();
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
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String initialValue,
    required ValueChanged<String> onChanged,
  }) {
    return TextField(
      controller: TextEditingController.fromValue(
        TextEditingValue(
          text: initialValue,
          selection: TextSelection.collapsed(offset: initialValue.length),
        ),
      ),
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

// Move PlantDetailsPanel to top-level (outside of _PlantSetupScreenState)
}
