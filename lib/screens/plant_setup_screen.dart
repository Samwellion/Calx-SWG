import 'package:flutter/material.dart';
import 'organization_setup_screen.dart';
import '../logic/app_database.dart';

// Global map to hold plant -> value streams (one-to-many)
Map<String, List<String>> plantValueStreams = {};

class PlantSetupScreen extends StatefulWidget {
  const PlantSetupScreen({super.key});

  @override
  State<PlantSetupScreen> createState() => _PlantSetupScreenState();
}

class _PlantSetupScreenState extends State<PlantSetupScreen> {
  Future<void> _saveAllToDatabase() async {
    final db = await AppDatabase.open();
    // Insert organization
    final orgId = await db.insertOrganization(OrganizationData.companyName);
    // Insert plants and value streams
    for (final plant in OrganizationData.plants) {
      final plantId = await db.insertPlant(organizationId: orgId, name: plant);
      final streams = plantValueStreams[plant] ?? [];
      for (final vs in streams) {
        await db.insertValueStream(plantId: plantId, name: vs);
      }
    }
    await db.close();
  }

  // Controllers for each plant's value stream input
  final Map<String, TextEditingController> _controllers = {};
  String? _selectedPlant;

  @override
  void initState() {
    super.initState();
    // Initialize controllers and value stream lists for each plant
    for (final plant in OrganizationData.plants) {
      _controllers[plant] = TextEditingController();
      plantValueStreams.putIfAbsent(plant, () => []);
    }
    // Select the first plant by default if available
    if (OrganizationData.plants.isNotEmpty) {
      _selectedPlant = OrganizationData.plants.first;
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addValueStream(String plant) {
    final controller = _controllers[plant];
    final value = controller?.text.trim() ?? '';
    if (value.isNotEmpty && !plantValueStreams[plant]!.contains(value)) {
      setState(() {
        plantValueStreams[plant]!.add(value);
        controller?.clear();
      });
    }
  }

  void _removeValueStream(String plant, int index) {
    setState(() {
      plantValueStreams[plant]!.removeAt(index);
    });
  }

  void _goBack() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final plants = OrganizationData.plants;
    final selectedPlant = _selectedPlant;
    final valueStreams =
        selectedPlant != null ? plantValueStreams[selectedPlant] ?? [] : [];

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
                        color: Colors.black.withValues(alpha: 0.06),
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
                                selectedPlant: selectedPlant,
                                onPlantSelected: (plant) {
                                  setState(() {
                                    _selectedPlant = plant;
                                  });
                                },
                              ),
                              if (selectedPlant != null)
                                Expanded(
                                  child: PlantValueStreamsPanel(
                                    plant: selectedPlant,
                                    valueStreams:
                                        List<String>.from(valueStreams),
                                    controller: _controllers[selectedPlant]!,
                                    onAdd: () => _addValueStream(selectedPlant),
                                    onRemove: (idx) =>
                                        _removeValueStream(selectedPlant, idx),
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
                await _saveAllToDatabase();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Plant and value stream data saved!'),
                    duration: Duration(seconds: 2),
                  ),
                );
                Navigator.of(context).popUntil((route) => route.isFirst);
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
  final List<String> plants;
  final String? selectedPlant;
  final ValueChanged<String> onPlantSelected;
  const PlantListSelector({
    super.key,
    required this.plants,
    required this.selectedPlant,
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
          final selected = plant == selectedPlant;
          return Material(
            color: selected ? Colors.yellow[200] : Colors.transparent,
            child: ListTile(
              title: Text(
                plant,
                style: TextStyle(
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  color: selected ? Colors.black : Colors.black87,
                ),
              ),
              selected: selected,
              onTap: () => onPlantSelected(plant),
            ),
          );
        },
      ),
    );
  }
}

class PlantValueStreamsPanel extends StatelessWidget {
  final String plant;
  final List<String> valueStreams;
  final TextEditingController controller;
  final VoidCallback onAdd;
  final void Function(int) onRemove;
  const PlantValueStreamsPanel({
    super.key,
    required this.plant,
    required this.valueStreams,
    required this.controller,
    required this.onAdd,
    required this.onRemove,
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
          Text(
            plant,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
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
}
