import 'package:flutter/material.dart';
import '../models/organization_data.dart' as org_data;
import '../screens/home_screen.dart';

class PlantDetailsPanel extends StatefulWidget {
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
  State<PlantDetailsPanel> createState() => _PlantDetailsPanelState();
}

class _PlantDetailsPanelState extends State<PlantDetailsPanel> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Detect keyboard visibility for responsive layout
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardVisible = keyboardHeight > 0;

    return GestureDetector(
      onTap: () {
        // Dismiss keyboard when tapping outside text fields
        FocusScope.of(context).unfocus();
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.yellow[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.yellow[300]!),
        ),
        padding: EdgeInsets.all(
            isKeyboardVisible ? 8 : 12), // Reduce padding when keyboard visible
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: isKeyboardVisible ? 300 : 400,
            ),
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
                  controller: widget.plantNameController,
                  onChanged:
                      (val) {}, // No longer needed, controller handles state
                ),
                const SizedBox(height: 8),
                _buildTextField(
                  label: 'Street',
                  controller: widget.streetController,
                  onChanged:
                      (val) {}, // No longer needed, controller handles state
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Flexible(
                      child: _buildTextField(
                        label: 'City',
                        controller: widget.cityController,
                        onChanged:
                            (val) {}, // No longer needed, controller handles state
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: _buildTextField(
                        label: 'State',
                        controller: widget.stateController,
                        onChanged:
                            (val) {}, // No longer needed, controller handles state
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: _buildTextField(
                        label: 'Zip',
                        controller: widget.zipController,
                        onChanged:
                            (val) {}, // No longer needed, controller handles state
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isKeyboardVisible ? 12 : 16),
                Wrap(
                  alignment: WrapAlignment.start,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    Container(
                      constraints: BoxConstraints(
                        minWidth: isKeyboardVisible ? 200 : 250,
                        maxWidth: isKeyboardVisible ? 300 : 400,
                      ),
                      child: TextField(
                        controller: widget.controller,
                        decoration: const InputDecoration(
                          labelText: 'Add Value Stream Name',
                          border: OutlineInputBorder(),
                          isDense: true,
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        onSubmitted: (_) => widget.onAdd(),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow[300],
                        foregroundColor: Colors.black,
                        padding: EdgeInsets.symmetric(
                          horizontal: isKeyboardVisible ? 20 : 24,
                          vertical: isKeyboardVisible ? 12 : 14,
                        ),
                        textStyle: TextStyle(
                          fontSize: isKeyboardVisible ? 14 : 16,
                          fontWeight: FontWeight.bold,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 6,
                      ),
                      onPressed: widget.onAdd,
                      child: const Text('Add'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  constraints: BoxConstraints(
                    minHeight: isKeyboardVisible ? 100 : 150,
                    maxHeight: isKeyboardVisible ? 200 : 300,
                  ),
                  child: Scrollbar(
                    controller: _scrollController,
                    thumbVisibility: true,
                    child: ListView.builder(
                      controller: _scrollController,
                      shrinkWrap: true,
                      itemCount: widget.valueStreams.length,
                      itemBuilder: (context, idx) {
                        return ListTile(
                          dense:
                              isKeyboardVisible, // More compact when keyboard visible
                          title: Text(widget.valueStreams[idx]),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => widget.onRemove(idx),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // Save Plant Details and Home buttons at bottom center
                Padding(
                  padding: EdgeInsets.only(top: isKeyboardVisible ? 8 : 16),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellow[300],
                          foregroundColor: Colors.black,
                          padding: EdgeInsets.symmetric(
                            horizontal: isKeyboardVisible ? 24 : 32,
                            vertical: isKeyboardVisible ? 12 : 16,
                          ),
                          textStyle: TextStyle(
                            fontSize: isKeyboardVisible ? 14 : 16,
                            fontWeight: FontWeight.bold,
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 8,
                        ),
                        onPressed: () async {
                          await widget.onSave();
                          // ignore: use_build_context_synchronously
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Plant details saved!')),
                          );
                        },
                        child: const Text('Save Plant Details'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellow[300],
                          foregroundColor: Colors.black,
                          padding: EdgeInsets.symmetric(
                            horizontal: isKeyboardVisible ? 24 : 32,
                            vertical: isKeyboardVisible ? 12 : 16,
                          ),
                          textStyle: TextStyle(
                            fontSize: isKeyboardVisible ? 14 : 16,
                            fontWeight: FontWeight.bold,
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 8,
                        ),
                        onPressed: () async {
                          await widget.onSave();
                          Navigator.pushAndRemoveUntil(
                            // ignore: use_build_context_synchronously
                            context,
                            MaterialPageRoute(
                                builder: (context) => const HomeScreen()),
                            (Route<dynamic> route) => false,
                          );
                        },
                        child: const Text('Home'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
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
