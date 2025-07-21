import 'package:flutter/material.dart';

class HomeDropdownsColumn extends StatelessWidget {
  final List<String> companyNames;
  final String? selectedCompany;
  final ValueChanged<String?> onCompanyChanged;
  final List<String> plantNames;
  final String? selectedPlant;
  final ValueChanged<String?> onPlantChanged;
  final List<String> valueStreams;
  final String? selectedValueStream;
  final ValueChanged<String?> onValueStreamChanged;
  final List<String> processes;
  final String? selectedProcess;
  final ValueChanged<String?> onProcessChanged;

  const HomeDropdownsColumn({
    super.key,
    required this.companyNames,
    required this.selectedCompany,
    required this.onCompanyChanged,
    required this.plantNames,
    required this.selectedPlant,
    required this.onPlantChanged,
    required this.valueStreams,
    required this.selectedValueStream,
    required this.onValueStreamChanged,
    required this.processes,
    required this.selectedProcess,
    required this.onProcessChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Validate selected values to prevent dropdown assertion errors
    final validSelectedCompany =
        (companyNames.isNotEmpty && companyNames.contains(selectedCompany))
            ? selectedCompany
            : null;

    final validSelectedPlant =
        (plantNames.isNotEmpty && plantNames.contains(selectedPlant))
            ? selectedPlant
            : null;

    final validSelectedValueStream =
        (valueStreams.isNotEmpty && valueStreams.contains(selectedValueStream))
            ? selectedValueStream
            : null;

    final validSelectedProcess =
        (processes.isNotEmpty && processes.contains(selectedProcess))
            ? selectedProcess
            : null;

    return Container(
      width: 400, // Width for the dropdowns container
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.yellow[300]!, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(
                width: 100, // Adjust width as needed for labels
                child: Text('Company',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              const SizedBox(width: 16), // Increased spacing from 8
              Expanded(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: validSelectedCompany,
                  hint: const Text('Select Company',
                      style: TextStyle(fontSize: 18)),
                  items: companyNames
                      .map((c) => DropdownMenuItem(
                          value: c,
                          child: Text(c, style: const TextStyle(fontSize: 18))))
                      .toList(),
                  onChanged: onCompanyChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const SizedBox(
                width: 100, // Adjust width as needed for labels
                child: Text('Plant',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              const SizedBox(width: 16), // Increased spacing from 8
              Expanded(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: validSelectedPlant,
                  hint: const Text('Select Plant',
                      style: TextStyle(fontSize: 18)),
                  items: plantNames
                      .map((p) => DropdownMenuItem(
                          value: p,
                          child: Text(p, style: const TextStyle(fontSize: 18))))
                      .toList(),
                  onChanged: onPlantChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const SizedBox(
                width: 100, // Adjust width as needed for labels
                child: Text('Value Stream',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              const SizedBox(width: 16), // Increased spacing from 8
              Expanded(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: validSelectedValueStream,
                  hint: const Text('Select Value Stream',
                      style: TextStyle(fontSize: 18)),
                  items: valueStreams
                      .map((v) => DropdownMenuItem(
                          value: v,
                          child: Text(v, style: const TextStyle(fontSize: 18))))
                      .toList(),
                  onChanged: onValueStreamChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const SizedBox(
                width: 100,
                child: Text('Process',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: validSelectedProcess,
                  hint: const Text('Select Process',
                      style: TextStyle(fontSize: 18)),
                  items: processes
                      .map((p) => DropdownMenuItem(
                          value: p,
                          child: Text(p, style: const TextStyle(fontSize: 18))))
                      .toList(),
                  onChanged: onProcessChanged,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
