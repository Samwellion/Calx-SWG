import 'package:flutter/material.dart';
import 'plant_setup_screen.dart';
import '../models/organization_data.dart' as org_data;

class OrganizationSetupHeader extends StatelessWidget {
  const OrganizationSetupHeader({super.key});
  @override
  Widget build(BuildContext context) {
    final companyName = org_data.OrganizationData.companyName;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
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
          if (companyName.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Text(
                companyName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class OrganizationSetupFooter extends StatelessWidget {
  const OrganizationSetupFooter(
      {super.key, required this.onBack, this.rightButton});
  final VoidCallback onBack;
  final Widget? rightButton;
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
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Home button on the left
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
          // Spacer
          const Spacer(),
          // Copyright centered
          const Text(
            '© 2025 Standard Work Generator App',
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          // Spacer
          const Spacer(),
          // Save button on the right
          if (rightButton != null) rightButton!,
        ],
      ),
    );
  }
}

class OrganizationDetailsForm extends StatelessWidget {
  final TextEditingController companyNameController;
  final FocusNode companyNameFocusNode;
  final TextEditingController plantController;
  final FocusNode plantFocusNode;
  final List<String> companyNames;
  final String? selectedCompany;
  final void Function() onAddCompanyName;
  final void Function(int) onRemoveCompanyName;
  final void Function(String) onSelectCompany;
  final List<String> plants;
  final String? selectedPlant;
  final void Function(String) onSelectPlant;
  final void Function() onAddPlant;
  final void Function(int) onRemovePlant;
  final void Function() onSave;
  final bool saveEnabled;

  const OrganizationDetailsForm({
    super.key,
    required this.companyNameController,
    required this.companyNameFocusNode,
    required this.plantController,
    required this.plantFocusNode,
    required this.companyNames,
    required this.selectedCompany,
    required this.onAddCompanyName,
    required this.onRemoveCompanyName,
    required this.onSelectCompany,
    required this.plants,
    required this.selectedPlant,
    required this.onSelectPlant,
    required this.onAddPlant,
    required this.onRemovePlant,
    required this.onSave,
    required this.saveEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
              // Company Name label and input + scrollable selectable list
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
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: companyNameController,
                              focusNode: companyNameFocusNode,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                isDense: true,
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              onSubmitted: (_) => onAddCompanyName(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.yellow[300],
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 14),
                              textStyle: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              elevation: 6,
                            ),
                            onPressed: onAddCompanyName,
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
                            itemCount: companyNames.length,
                            itemBuilder: (context, idx) {
                              final name = companyNames[idx];
                              final selected = name == selectedCompany;
                              return Material(
                                color: selected
                                    ? Colors.yellow[200]
                                    : Colors.transparent,
                                child: ListTile(
                                  title: Text(name,
                                      style: TextStyle(
                                          fontWeight: selected
                                              ? FontWeight.bold
                                              : FontWeight.normal)),
                                  selected: selected,
                                  onTap: () => onSelectCompany(name),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () => onRemoveCompanyName(idx),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Plant Name label, input, and scrollable selectable list
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Plant Name',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: plantController,
                            focusNode: plantFocusNode,
                            enabled: selectedCompany != null,
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              isDense: true,
                              filled: true,
                              fillColor: Colors.white,
                              hintText: selectedCompany == null
                                  ? 'Select a company first'
                                  : 'Add Plant Name',
                            ),
                            onSubmitted: (_) => onAddPlant(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.yellow[300],
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 14),
                            textStyle: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 6,
                          ),
                          onPressed:
                              selectedCompany != null ? onAddPlant : null,
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
                          itemCount: plants.length,
                          itemBuilder: (context, idx) {
                            final plant = plants[idx];
                            final selected = plant == selectedPlant;
                            return Material(
                              color: selected
                                  ? Colors.yellow[200]
                                  : Colors.transparent,
                              child: ListTile(
                                title: Text(plant,
                                    style: TextStyle(
                                        fontWeight: selected
                                            ? FontWeight.bold
                                            : FontWeight.normal)),
                                selected: selected,
                                onTap: () => onSelectPlant(plant),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () => onRemovePlant(idx),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // ...existing code...
        ],
      ),
    );
  }
}

class OrganizationSetupScreen extends StatefulWidget {
  const OrganizationSetupScreen({super.key});

  @override
  State<OrganizationSetupScreen> createState() =>
      _OrganizationSetupScreenState();
}

class _OrganizationSetupScreenState extends State<OrganizationSetupScreen> {
  final TextEditingController _companyNameController = TextEditingController();
  final FocusNode _companyNameFocusNode = FocusNode();
  final TextEditingController _plantController = TextEditingController();
  final FocusNode _plantFocusNode = FocusNode();
  final List<String> _companyNames = [];
  String? _selectedCompany;
  final Map<String, List<String>> _companyPlants = {};
  String? _selectedPlant;

  @override
  void initState() {
    super.initState();
    _companyNameController.text = org_data.OrganizationData.companyName;
    if (org_data.OrganizationData.companyName.isNotEmpty) {
      _companyNames.add(org_data.OrganizationData.companyName);
      _selectedCompany = org_data.OrganizationData.companyName;
      _companyPlants[org_data.OrganizationData.companyName] = List<String>.from(
          org_data.OrganizationData.plants.map((p) => p.name));
    }
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _companyNameFocusNode.dispose();
    _plantController.dispose();
    _plantFocusNode.dispose();
    super.dispose();
  }

  void _goBackToHome() {
    Navigator.of(context).pop();
  }

  void _selectPlant(String plant) {
    setState(() {
      _selectedPlant = plant;
    });
  }

  void _saveOrganization() {
    if (_selectedCompany != null && _selectedPlant != null) {
      org_data.OrganizationData.companyName = _selectedCompany!;
      org_data.OrganizationData.plants =
          List<String>.from(_companyPlants[_selectedCompany!] ?? [])
              .map((name) => org_data.PlantData(
                    name: name,
                    street: '',
                    city: '',
                    state: '',
                    zip: '',
                  ))
              .toList();
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
  }

  void _addCompanyName() {
    final name = _companyNameController.text.trim();
    if (name.isNotEmpty && !_companyNames.contains(name)) {
      setState(() {
        _companyNames.add(name);
        // org_data.OrganizationData.companyNames = List<String>.from(_companyNames); // No such field in model
        _selectedCompany = name;
        _companyPlants[name] = [];
        // org_data.OrganizationData.companyPlants = Map<String, List<String>>.from(_companyPlants); // No such field in model
        _companyNameController.clear();
      });
    }
    FocusScope.of(context).requestFocus(_companyNameFocusNode);
  }

  void _removeCompanyName(int index) {
    setState(() {
      String removed = _companyNames.removeAt(index);
      // org_data.OrganizationData.companyNames = List<String>.from(_companyNames); // No such field in model
      _companyPlants.remove(removed);
      // org_data.OrganizationData.companyPlants = Map<String, List<String>>.from(_companyPlants); // No such field in model
      if (_selectedCompany == removed) {
        _selectedCompany =
            _companyNames.isNotEmpty ? _companyNames.first : null;
      }
    });
  }

  void _selectCompany(String name) {
    setState(() {
      _selectedCompany = name;
    });
  }

  void _addPlant() {
    final plant = _plantController.text.trim();
    if (_selectedCompany != null &&
        plant.isNotEmpty &&
        !_companyPlants[_selectedCompany]!.contains(plant)) {
      setState(() {
        _companyPlants[_selectedCompany]!.add(plant);
        // org_data.OrganizationData.companyPlants = Map<String, List<String>>.from(_companyPlants); // No such field in model
        _plantController.clear();
      });
    }
    FocusScope.of(context).requestFocus(_plantFocusNode);
  }

  void _removePlant(int index) {
    if (_selectedCompany != null) {
      setState(() {
        _companyPlants[_selectedCompany]!.removeAt(index);
        // org_data.OrganizationData.companyPlants = Map<String, List<String>>.from(_companyPlants); // No such field in model
      });
    }
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
              child: OrganizationDetailsForm(
                companyNameController: _companyNameController,
                companyNameFocusNode: _companyNameFocusNode,
                plantController: _plantController,
                plantFocusNode: _plantFocusNode,
                companyNames: _companyNames,
                selectedCompany: _selectedCompany,
                onAddCompanyName: _addCompanyName,
                onRemoveCompanyName: _removeCompanyName,
                onSelectCompany: _selectCompany,
                plants: _selectedCompany != null
                    ? _companyPlants[_selectedCompany!] ?? []
                    : [],
                selectedPlant: _selectedPlant,
                onSelectPlant: _selectPlant,
                onAddPlant: _addPlant,
                onRemovePlant: _removePlant,
                onSave: _saveOrganization,
                saveEnabled: _selectedPlant != null,
              ),
            ),
          ),
          OrganizationSetupFooter(
            onBack: _goBackToHome,
            rightButton: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow[300],
                foregroundColor: Colors.black,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                textStyle:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 6,
              ),
              onPressed: _selectedPlant != null ? _saveOrganization : null,
              child: const Text('Save and Proceed to Plant Setup'),
            ),
          ),
        ],
      ),
    );
  }
}
