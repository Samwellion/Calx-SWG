import 'package:flutter/material.dart';
import '../widgets/full_hierarchy_tree.dart';
import '../widgets/home_button_wrapper.dart';

/// Demo screen to showcase the Full Hierarchy Tree widget
/// This screen demonstrates the comprehensive organizational navigation tree
/// that displays Companies -> Plants -> Value Streams -> Processes
class FullHierarchyDemoScreen extends StatefulWidget {
  const FullHierarchyDemoScreen({super.key});

  @override
  State<FullHierarchyDemoScreen> createState() =>
      _FullHierarchyDemoScreenState();
}

class _FullHierarchyDemoScreenState extends State<FullHierarchyDemoScreen> {
  // Selected values to demonstrate selection state
  String? _selectedCompany;
  String? _selectedPlant;
  String? _selectedValueStream;
  String? _selectedProcess;
  int? _selectedPlantIndex;
  int? _selectedValueStreamId;
  int? _selectedProcessId;

  void _onItemSelected({
    String? companyName,
    String? plantName,
    String? valueStreamName,
    String? processName,
    int? plantIndex,
    int? valueStreamId,
    int? processId,
  }) {
    setState(() {
      _selectedCompany = companyName;
      _selectedPlant = plantName;
      _selectedValueStream = valueStreamName;
      _selectedProcess = processName;
      _selectedPlantIndex = plantIndex;
      _selectedValueStreamId = valueStreamId;
      _selectedProcessId = processId;
    });

    // Optional: Show a snackbar with selection details
    String message = 'Selected: ';
    if (processName != null) {
      message += 'Process "$processName"';
      if (valueStreamName != null) {
        message += ' in Value Stream "$valueStreamName"';
      }
      if (plantName != null) message += ' at Plant "$plantName"';
      if (companyName != null) message += ' (Company: $companyName)';
    } else if (valueStreamName != null) {
      message += 'Value Stream "$valueStreamName"';
      if (plantName != null) message += ' at Plant "$plantName"';
      if (companyName != null) message += ' (Company: $companyName)';
    } else if (plantName != null) {
      message += 'Plant "$plantName"';
      if (companyName != null) message += ' (Company: $companyName)';
    } else if (companyName != null) {
      message += 'Company "$companyName"';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return HomeButtonWrapper(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Full Hierarchy Tree Demo'),
          backgroundColor: Colors.yellow[700],
          foregroundColor: Colors.black,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Instructions
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Full Hierarchy Navigation',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'This tree widget displays the complete organizational hierarchy:\n'
                        '• Companies (top level)\n'
                        '• Plants (under companies)\n'
                        '• Value Streams (under plants)\n'
                        '• Processes (under value streams)\n\n'
                        'Click on expandable items to explore the hierarchy, or click on any item to select it.',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Main content with tree and selection info
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tree widget
                    Expanded(
                      flex: 2,
                      child: FullHierarchyTree(
                        width: null, // Let it expand to fit
                        height: null, // Let it use intrinsic height
                        showHeader: true,
                        headerText: 'Organizational Hierarchy',
                        expandedByDefault: false,
                        onItemSelected: _onItemSelected,
                        selectedCompany: _selectedCompany,
                        selectedPlant: _selectedPlant,
                        selectedValueStream: _selectedValueStream,
                        selectedProcess: _selectedProcess,
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Selection information panel
                    Expanded(
                      flex: 1,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Current Selection',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 16),

                              _buildSelectionRow('Company', _selectedCompany),
                              _buildSelectionRow('Plant', _selectedPlant),
                              _buildSelectionRow(
                                  'Value Stream', _selectedValueStream),
                              _buildSelectionRow('Process', _selectedProcess),

                              if (_selectedPlantIndex != null ||
                                  _selectedValueStreamId != null ||
                                  _selectedProcessId != null) ...[
                                const SizedBox(height: 16),
                                const Divider(),
                                const SizedBox(height: 8),
                                Text(
                                  'Database IDs',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                if (_selectedPlantIndex != null)
                                  _buildSelectionRow('Plant ID',
                                      _selectedPlantIndex.toString()),
                                if (_selectedValueStreamId != null)
                                  _buildSelectionRow('Value Stream ID',
                                      _selectedValueStreamId.toString()),
                                if (_selectedProcessId != null)
                                  _buildSelectionRow('Process ID',
                                      _selectedProcessId.toString()),
                              ],

                              const SizedBox(height: 16),

                              // Clear selection button
                              if (_selectedCompany != null ||
                                  _selectedPlant != null ||
                                  _selectedValueStream != null ||
                                  _selectedProcess != null)
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      _selectedCompany = null;
                                      _selectedPlant = null;
                                      _selectedValueStream = null;
                                      _selectedProcess = null;
                                      _selectedPlantIndex = null;
                                      _selectedValueStreamId = null;
                                      _selectedProcessId = null;
                                    });
                                  },
                                  child: const Text('Clear Selection'),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'None',
              style: TextStyle(
                color: value != null ? Colors.black : Colors.grey[600],
                fontStyle: value != null ? FontStyle.normal : FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
