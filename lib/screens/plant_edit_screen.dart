import 'package:flutter/material.dart';
// Example: import '../models/plant.dart';
// import '../logic/plant.dart';

class PlantEditScreen extends StatefulWidget {
  final Plant plant;
  final void Function(Plant updatedPlant)? onSaved;

  const PlantEditScreen({
    super.key,
    required this.plant,
    this.onSaved,
  });

  @override
  State<PlantEditScreen> createState() => _PlantEditScreenState();
}

class Plant {
  final String name;

  Plant({required this.name});

  Plant copyWith({String? name}) {
    return Plant(
      name: name ?? this.name,
    );
  }
}

class _PlantEditScreenState extends State<PlantEditScreen> {
  late TextEditingController nameController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.plant.name);
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Plant Info')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Plant Name'),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    final updatedPlant = widget.plant.copyWith(
                      name: nameController.text,
                    );
                    widget.onSaved?.call(updatedPlant);
                    Navigator.of(context).pop(updatedPlant);
                  },
                  child: const Text('Save'),
                ),
                const SizedBox(width: 16),
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
