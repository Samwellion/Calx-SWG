import 'package:flutter/material.dart';
import '../models/organization_data.dart' as org_data;
import '../screens/home_screen.dart';

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
        color: Colors.yellow[50],
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
