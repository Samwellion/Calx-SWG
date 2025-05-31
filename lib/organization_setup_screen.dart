import 'package:flutter/material.dart';
import 'plant_setup_screen.dart';

class OrganizationData {
  static String companyName = '';
  static List<String> plants = [];
}

class OrganizationSetupHeader extends StatelessWidget {
  const OrganizationSetupHeader({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/calx_logo.png',
            height: 56,
            width: 56,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Organization Setup',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class OrganizationSetupFooter extends StatelessWidget {
  const OrganizationSetupFooter({super.key, required this.onBack});
  final VoidCallback onBack;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.yellow[200],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.yellow[300],
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              textStyle:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 6,
            ),
            onPressed: onBack,
            child: const Text('Back to Home'),
          ),
          const SizedBox(height: 8),
          const Text(
            '© 2025 Standard Work Generator App',
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

class OrganizationSetupScreen extends StatefulWidget {
  const OrganizationSetupScreen({super.key});

  @override
  State<OrganizationSetupScreen> createState() => _OrganizationSetupScreenState();
}

class _OrganizationSetupScreenState extends State<OrganizationSetupScreen> {
  final TextEditingController _companyNameController = TextEditingController();
  List<String> _plants = [];

  @override
  void initState() {
    super.initState();
    _companyNameController.text = OrganizationData.companyName;
    _plants = List<String>.from(OrganizationData.plants);
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    super.dispose();
  }

  void _goBackToHome() {
    Navigator.of(context).pop();
  }

  void _saveOrganization() {
    OrganizationData.companyName = _companyNameController.text.trim();
    OrganizationData.plants = List<String>.from(_plants);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Organization details saved!'),
        duration: Duration(seconds: 2),
      ),
    );
    // Navigate to Plant Setup UI
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const PlantSetupScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Add this label at the top of the main body container
                      const Padding(
                        padding: EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          'Company and Plants',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Company Name label and input
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 32.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Company Name',
                                    style: TextStyle(
                                        fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: _companyNameController,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      isDense: true,
                                      filled: true,
                                      fillColor: Colors.white, // <-- white background
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Company Plants Table
                          Expanded(
                            flex: 3,
                            child: CompanyPlantsTable(
                              initialPlants: _plants,
                              onChanged: (plants) {
                                setState(() {
                                  _plants = plants;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.yellow[300],
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 16),
                            textStyle: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 6,
                          ),
                          onPressed: _saveOrganization,
                          child: const Text('Save and Proceed to Plant Setup'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          OrganizationSetupFooter(onBack: _goBackToHome),
        ],
      ),
    );
  }
}

class CompanyPlantsTable extends StatefulWidget {
  final List<String> initialPlants;
  final ValueChanged<List<String>>? onChanged;

  const CompanyPlantsTable({
    super.key,
    this.initialPlants = const [],
    this.onChanged,
  });

  @override
  State<CompanyPlantsTable> createState() => _CompanyPlantsTableState();
}

class _CompanyPlantsTableState extends State<CompanyPlantsTable> {
  late List<String> _plants;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _plants = List<String>.from(widget.initialPlants);
  }

  void _addPlant() {
    final plant = _controller.text.trim();
    if (plant.isNotEmpty && !_plants.contains(plant)) {
      setState(() {
        _plants.add(plant);
        _controller.clear();
        widget.onChanged?.call(_plants);
      });
    }
  }

  void _removePlant(int index) {
    setState(() {
      _plants.removeAt(index);
      widget.onChanged?.call(_plants);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 8.0),
          child: Text(
            'Company Plants',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.yellow[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.yellow[300]!),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        labelText: 'Add Plant Name',
                        border: OutlineInputBorder(),
                        isDense: true,
                        filled: true,
                        fillColor: Colors.white, // <-- white background
                      ),
                      onSubmitted: (_) => _addPlant(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow[300],
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 6,
                    ),
                    onPressed: _addPlant,
                    child: const Text('Add'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_plants.isNotEmpty)
                Table(
                  columnWidths: const {
                    0: FlexColumnWidth(1),
                    1: IntrinsicColumnWidth(),
                  },
                  children: [
                    ..._plants.asMap().entries.map(
                      (entry) => TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(entry.value),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removePlant(entry.key),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              if (_plants.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'No plants added yet.',
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
