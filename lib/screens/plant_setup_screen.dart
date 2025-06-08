import 'package:flutter/material.dart';
import 'organization_setup_screen.dart';

// Global map to hold plant -> value streams (one-to-many)
Map<String, List<String>> plantValueStreams = {};

class PlantSetupScreen extends StatefulWidget {
  const PlantSetupScreen({super.key});

  @override
  State<PlantSetupScreen> createState() => _PlantSetupScreenState();
}

class _PlantSetupScreenState extends State<PlantSetupScreen> {
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
                              // Plant selectable list
                              Container(
                                width: 220,
                                margin: const EdgeInsets.only(right: 32),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border:
                                      Border.all(color: Colors.yellow[300]!),
                                ),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: plants.length,
                                  itemBuilder: (context, idx) {
                                    final plant = plants[idx];
                                    final selected = plant == selectedPlant;
                                    return Material(
                                      color: selected
                                          ? Colors.yellow[200]
                                          : Colors.transparent,
                                      child: ListTile(
                                        title: Text(
                                          plant,
                                          style: TextStyle(
                                            fontWeight: selected
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                            color: selected
                                                ? Colors.black
                                                : Colors.black87,
                                          ),
                                        ),
                                        selected: selected,
                                        onTap: () {
                                          setState(() {
                                            _selectedPlant = plant;
                                          });
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ),
                              // Value stream input and table for selected plant
                              if (selectedPlant != null)
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: Colors.yellow[300]!),
                                    ),
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          selectedPlant,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: TextField(
                                                controller: _controllers[
                                                    selectedPlant]!,
                                                decoration:
                                                    const InputDecoration(
                                                  labelText:
                                                      'Add Value Stream Name',
                                                  border: OutlineInputBorder(),
                                                  isDense: true,
                                                  filled: true,
                                                  fillColor: Colors.white,
                                                ),
                                                onSubmitted: (_) {
                                                  _addValueStream(
                                                      selectedPlant);
                                                },
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.yellow[300],
                                                foregroundColor: Colors.black,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 32,
                                                        vertical: 16),
                                                textStyle: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.bold),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                elevation: 6,
                                              ),
                                              onPressed: () => _addValueStream(
                                                  selectedPlant),
                                              child: const Text('Add'),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        if (valueStreams.isNotEmpty)
                                          Table(
                                            columnWidths: const {
                                              0: FlexColumnWidth(1),
                                              1: IntrinsicColumnWidth(),
                                            },
                                            children: [
                                              ...valueStreams
                                                  .asMap()
                                                  .entries
                                                  .map(
                                                    (entry) => TableRow(
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical:
                                                                      8.0),
                                                          child:
                                                              Text(entry.value),
                                                        ),
                                                        IconButton(
                                                          icon: const Icon(
                                                              Icons.delete,
                                                              color:
                                                                  Colors.red),
                                                          onPressed: () =>
                                                              _removeValueStream(
                                                                  selectedPlant,
                                                                  entry.key),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                            ],
                                          ),
                                        if (valueStreams.isEmpty)
                                          const Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 8.0),
                                            child: Text(
                                              'No value streams added yet.',
                                              style: TextStyle(
                                                  color: Colors.black54),
                                            ),
                                          ),
                                      ],
                                    ),
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
          Padding(
            padding:
                const EdgeInsets.only(right: 24.0, bottom: 24.0, top: 12.0),
            child: Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow[300],
                  foregroundColor: Colors.black,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  textStyle: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 6,
                ),
                onPressed: () {
                  // Implement save logic for plant/value stream data here if needed
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
          ),
          OrganizationSetupFooter(onBack: _goBack),
        ],
      ),
    );
  }
}
