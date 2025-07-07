import 'package:flutter/material.dart';

import '../models/organization_data.dart' as org_data;
import '../database_provider.dart';
import '../logic/app_database.dart';
import '../widgets/home_header.dart';
import '../screens/home_screen.dart';
import 'package:drift/drift.dart' as drift;

// Global map to hold plant name -> value streams (one-to-many)
Map<String, List<String>> plantValueStreams = {};

class PlantSetupScreen extends StatefulWidget {
  const PlantSetupScreen({super.key});

  @override
  State<PlantSetupScreen> createState() => _PlantSetupScreenState();
}

class _PlantSetupScreenState extends State<PlantSetupScreen> {
  void _ensurePlantDataInitialized(List<org_data.PlantData> plants) {
    for (final plant in plants) {
      plantValueStreams.putIfAbsent(plant.name, () => <String>[]);
      _controllers.putIfAbsent(plant.name, () => TextEditingController());
    }
  }

  // Controllers for each plant's value stream input
  final Map<String, TextEditingController> _controllers = {};
  late final ValueNotifier<int?> _selectedPlantIndex;
  int? _selectedPlantIdx;

  @override
  Widget build(BuildContext context) {
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
              // Standard HomeHeader
              HomeHeader(
                companyName: org_data.OrganizationData.companyName,
                plantName: selectedPlant?.name,
                valueStreamName: null,
              ),
              const SizedBox(height: 24),
              // Main body
              Expanded(
                child: plants.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'No plants found. Add your first plant to get started!',
                              style: TextStyle(
                                  fontSize: 20, color: Colors.black54),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.add),
                              label: const Text('Add Plant'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.yellow[300],
                                foregroundColor: Colors.black,
                                textStyle: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 32, vertical: 16),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () {
                                setState(() {
                                  final newPlant = org_data.PlantData(
                                    name: 'New Plant',
                                    street: '',
                                    city: '',
                                    state: '',
                                    zip: '',
                                  );
                                  org_data.OrganizationData.plants
                                      .add(newPlant);
                                  plantValueStreams[newPlant.name] = [];
                                  _controllers[newPlant.name] =
                                      TextEditingController();
                                  _selectedPlantIdx =
                                      org_data.OrganizationData.plants.length -
                                          1;
                                });
                              },
                            ),
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                        padding: EdgeInsets.only(
                          left: 12.0,
                          right: 12.0,
                          bottom:
                              MediaQuery.of(context).viewInsets.bottom + 12.0,
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight -
                                24 -
                                80, // header + footer approx
                            maxWidth: 1100,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Plant name selectable list
                              Container(
                                width: 220,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border:
                                      Border.all(color: Colors.yellow[300]!),
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
                                    valueStreams:
                                        plantValueStreams[selectedPlant.name]!,
                                    controller:
                                        _controllers[selectedPlant.name]!,
                                    onAdd: () {
                                      final value =
                                          _controllers[selectedPlant.name]!
                                              .text
                                              .trim();
                                      if (value.isNotEmpty &&
                                          !plantValueStreams[
                                                  selectedPlant.name]!
                                              .contains(value)) {
                                        setState(() {
                                          plantValueStreams[selectedPlant.name]!
                                              .add(value);
                                          _controllers[selectedPlant.name]!
                                              .clear();
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
                                        final i = org_data
                                            .OrganizationData.plants
                                            .indexWhere((p) =>
                                                p.name == selectedPlant.name);
                                        if (i != -1) {
                                          org_data.OrganizationData.plants[i] =
                                              updated;
                                        }
                                      });
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
              ),
              // Footer (always visible)
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Home button on the left
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
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      onPressed: () async {
                        // Validate all plant fields before DB ops
                        for (final plant in org_data.OrganizationData.plants) {
                          if ([plant.street, plant.city, plant.state, plant.zip]
                              .any((v) => v.trim().isEmpty)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'All plant fields (street, city, state, zip) must be filled out.')),
                            );
                            return;
                          }
                        }
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) =>
                              const Center(child: CircularProgressIndicator()),
                        );
                        try {
                          final db = await DatabaseProvider.getInstance();
                          final orgName = org_data.OrganizationData.companyName;
                          final orgId = await db.upsertOrganization(orgName);
                          for (final plant
                              in org_data.OrganizationData.plants) {
                            await db.upsertPlant(
                              organizationId: orgId,
                              name: plant.name,
                              street: plant.street,
                              city: plant.city,
                              state: plant.state,
                              zip: plant.zip,
                            );
                            // Fetch the plant's id from the DB
                            final dbPlant = await (db.select(db.plants)
                                  ..where((tbl) =>
                                      tbl.organizationId.equals(orgId) &
                                      tbl.name.equals(plant.name)))
                                .getSingleOrNull();
                            if (dbPlant == null) continue;
                            final valueStreams =
                                plantValueStreams[plant.name] ?? [];
                            for (final vs in valueStreams) {
                              await db.upsertValueStream(
                                ValueStreamsCompanion(
                                  name: drift.Value(vs),
                                  plantId: drift.Value(dbPlant.id),
                                ),
                              );
                            }
                          }
                          // ignore: use_build_context_synchronously
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => HomeScreen(),
                            ),
                          );
                        } catch (e) {
                          // ignore: use_build_context_synchronously
                          Navigator.of(context)
                              .pop(); // Remove loading indicator
                          // ignore: use_build_context_synchronously
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error saving data: $e')),
                          );
                        }
                      },
                    ),
                    // Spacer
                    const Spacer(),
                    // Copyright centered
                    const Text(
                      '© 2025 Standard Work Generator App',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                    // Spacer
                    const Spacer(),
                    // (Optional) right-aligned placeholder for future button
                  ],
                ),
              ),
            ],
          );
        },
      ),
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
}
