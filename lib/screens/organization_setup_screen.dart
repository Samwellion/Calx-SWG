// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'plant_setup_screen.dart';
import '../models/organization_data.dart' as org_data;
import '../database_provider.dart';
import 'package:collection/collection.dart';

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
  List<String> _companyNames = [];
  String? _selectedCompany;
  Map<String, List<String>> _companyPlants = {};
  String? _selectedPlant;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadFromDatabase();
  }

  Future<void> _loadFromDatabase() async {
    setState(() {
      _loading = true;
    });
    final db = await DatabaseProvider.getInstance();
    final orgs = await db.select(db.organizations).get();
    final plants = await db.select(db.plants).get();
    _companyNames = orgs.map((o) => o.name).toList();
    _companyPlants = {};
    for (final org in orgs) {
      _companyPlants[org.name] = plants
          .where((p) => p.organizationId == org.id)
          .map((p) => p.name)
          .toList();
    }
    // Only set the controller if a company is selected (e.g., from the list), not on every DB load
    if (_selectedCompany != null && _selectedCompany!.isNotEmpty) {
      _companyNameController.text = _selectedCompany!;
    }
    setState(() {
      _loading = false;
    });
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

  void _saveOrganization() {
    if (_selectedCompany != null && _selectedPlant != null) {
      org_data.OrganizationData.companyName = _selectedCompany!;
      final plantNames =
          List<String>.from(_companyPlants[_selectedCompany!] ?? []);
      org_data.OrganizationData.plants = plantNames
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

  void _addCompanyName() async {
    final name = _companyNameController.text.trim();
    if (name.isNotEmpty && !_companyNames.contains(name)) {
      final db = await DatabaseProvider.getInstance();
      await db.upsertOrganization(name);
      await _loadFromDatabase();
      setState(() {
        _selectedCompany = name;
      });
      _companyNameController.clear();
    }
    FocusScope.of(context).requestFocus(_companyNameFocusNode);
  }

  void _removeCompanyName(int index) async {
    final name = _companyNames[index];
    final db = await DatabaseProvider.getInstance();
    // Remove all plants for this org
    final orgs = await db.select(db.organizations).get();
    final org = orgs.firstWhereOrNull((o) => o.name == name);
    if (org != null) {
      await (db.delete(db.plants)
            ..where((p) => p.organizationId.equals(org.id)))
          .go();
      await (db.delete(db.organizations)..where((o) => o.id.equals(org.id)))
          .go();
    }
    await _loadFromDatabase();
    setState(() {
      if (_selectedCompany == name) {
        _selectedCompany =
            _companyNames.isNotEmpty ? _companyNames.first : null;
      }
    });
  }

  void _addPlant() async {
    final plant = _plantController.text.trim();
    if (_selectedCompany != null && plant.isNotEmpty) {
      final db = await DatabaseProvider.getInstance();
      final orgs = await db.select(db.organizations).get();
      final org = orgs.firstWhereOrNull((o) => o.name == _selectedCompany);
      if (org != null) {
        await db.upsertPlant(
          organizationId: org.id,
          name: plant,
          street: 'N/A',
          city: 'N/A',
          state: 'N/A',
          zip: 'N/A',
        );
        await _loadFromDatabase();
        setState(() {
          _plantController.clear();
        });
      }
    }
    FocusScope.of(context).requestFocus(_plantFocusNode);
  }

  void _removePlant(int index) async {
    if (_selectedCompany != null) {
      final db = await DatabaseProvider.getInstance();
      final orgs = await db.select(db.organizations).get();
      final org = orgs.firstWhereOrNull((o) => o.name == _selectedCompany);
      if (org != null) {
        final plantName = _companyPlants[_selectedCompany!]![index];
        final plants = await db.select(db.plants).get();
        final plant = plants.firstWhereOrNull(
            (p) => p.name == plantName && p.organizationId == org.id);
        if (plant != null) {
          await (db.delete(db.plants)..where((p) => p.id.equals(plant.id)))
              .go();
        }
        await _loadFromDatabase();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Colors.yellow,
        body: Center(child: CircularProgressIndicator()),
      );
    }
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
                onSelectCompany: (name) {
                  setState(() {
                    _selectedCompany = name;
                    _selectedPlant = null;
                  });
                },
                plants: _selectedCompany != null
                    ? _companyPlants[_selectedCompany!] ?? []
                    : [],
                selectedPlant: _selectedPlant,
                onSelectPlant: (plant) {
                  setState(() {
                    _selectedPlant = plant;
                  });
                },
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
