// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'plant_setup_screen.dart';
import '../widgets/app_footer.dart';
import '../models/organization_data.dart' as org_data;
import '../database_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrganizationSetupHeader extends StatelessWidget {
  const OrganizationSetupHeader({super.key});
  @override
  Widget build(BuildContext context) {
    // final companyName = org_data.OrganizationData.companyName;
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
          // Removed company name label from header
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
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.yellow[300],
              foregroundColor: Colors.black,
              elevation: 6,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              textStyle:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.home, size: 28),
            label: const Text('Home',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            onPressed: onBack,
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
                                  title: Text(
                                    name,
                                    style: TextStyle(
                                      fontWeight: selected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow[300],
                  foregroundColor: Colors.black,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  textStyle: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 6,
                ),
                onPressed: saveEnabled ? onSave : null,
                child: const Text('Plant Setup'),
              ),
            ],
          ),
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
  static const _kCompanyKey = 'selectedCompany';
  static const _kPlantKey = 'selectedPlant';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_companyNameFocusNode);
    });
    _restoreSelections().then((_) => _loadFromDatabase());
  }

  Future<void> _restoreSelections() async {
    final prefs = await SharedPreferences.getInstance();
    final c = prefs.getString(_kCompanyKey);
    final p = prefs.getString(_kPlantKey);
    setState(() {
      _selectedCompany = (c != null && c.isNotEmpty) ? c : null;
      _selectedPlant = (p != null && p.isNotEmpty) ? p : null;
    });
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
    // Load persisted organization and plants into OrganizationData
    if (orgs.isNotEmpty) {
      // Use restored selection if available, else first org
      final selectedOrg = _selectedCompany ?? orgs.first.name;
      _selectedCompany = selectedOrg;
      _companyNameController.text = selectedOrg;
      org_data.OrganizationData.companyName = selectedOrg;
      final org = orgs.firstWhere((o) => o.name == selectedOrg,
          orElse: () => orgs.first);
      final orgPlants =
          plants.where((p) => p.organizationId == org.id).toList();
      org_data.OrganizationData.plants = orgPlants
          .map((p) => org_data.PlantData(
                name: p.name,
                street: p.street,
                city: p.city,
                state: p.state,
                zip: p.zip,
              ))
          .toList();
      // Use restored plant selection if available, else first plant
      if (orgPlants.isNotEmpty) {
        _selectedPlant = _selectedPlant ?? orgPlants.first.name;
      } else {
        _selectedPlant = null;
      }
    } else {
      org_data.OrganizationData.companyName = '';
      org_data.OrganizationData.plants = [];
      _selectedCompany = null;
      _selectedPlant = null;
      _companyNameController.text = '';
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
        MaterialPageRoute(
          builder: (context) => PlantSetupScreen(
            initialPlantIndex: org_data.OrganizationData.plants
                .indexWhere((p) => p.name == _selectedPlant),
          ),
        ),
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
        _saveSelections();
      });
      _companyNameController.clear();
      // Move focus to plant name input after adding company
      FocusScope.of(context).requestFocus(_plantFocusNode);
      return;
    }
    // If not added, keep focus on company name
    FocusScope.of(context).requestFocus(_companyNameFocusNode);
  }

  void _removeCompanyName(int index) async {
    final name = _companyNames[index];
    final db = await DatabaseProvider.getInstance();
    // Remove all plants for this org
    final orgs = await db.select(db.organizations).get();
    final org = orgs.firstWhere(
      (o) => o.name == name,
      orElse: () => throw Exception('Organization not found'),
    );
    await (db.delete(db.plants)..where((p) => p.organizationId.equals(org.id)))
        .go();
    await (db.delete(db.organizations)..where((o) => o.id.equals(org.id))).go();
    await _loadFromDatabase();
    setState(() {
      if (_selectedCompany == name) {
        _selectedCompany =
            _companyNames.isNotEmpty ? _companyNames.first : null;
        _saveSelections();
      }
    });
  }

  void _addPlant() async {
    final plant = _plantController.text.trim();
    if (_selectedCompany != null && plant.isNotEmpty) {
      final db = await DatabaseProvider.getInstance();
      final orgs = await db.select(db.organizations).get();
      final org = orgs.firstWhere(
        (o) => o.name == _selectedCompany,
        orElse: () => throw Exception('Organization not found'),
      );
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
        _selectedPlant = plant;
        _saveSelections();
      });
    }
    FocusScope.of(context).requestFocus(_plantFocusNode);
  }

  void _removePlant(int index) async {
    if (_selectedCompany != null) {
      final db = await DatabaseProvider.getInstance();
      final orgs = await db.select(db.organizations).get();
      final org = orgs.firstWhere(
        (o) => o.name == _selectedCompany,
        orElse: () => throw Exception('Organization not found'),
      );
      final plantName = _companyPlants[_selectedCompany!]![index];
      final plants = await db.select(db.plants).get();
      plants.firstWhere(
        (p) => p.name == plantName && p.organizationId == org.id,
        orElse: () => throw Exception('Plant not found'),
      );
      // await (db.delete(db.plants)..where((p) => p.id.equals(plant.id))).go();
      await _loadFromDatabase();
      setState(() {
        if (_selectedPlant == plantName) {
          _selectedPlant =
              (_companyPlants[_selectedCompany!]?.isNotEmpty ?? false)
                  ? _companyPlants[_selectedCompany!]!.first
                  : null;
          _saveSelections();
        }
      });
    }
  }

  Future<void> _saveSelections() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kCompanyKey, _selectedCompany ?? '');
    await prefs.setString(_kPlantKey, _selectedPlant ?? '');
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
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          // Removed OrganizationSetupHeader
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 24.0,
                right: 24.0,
                top: 24.0,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24.0,
              ),
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
          const AppFooter(),
        ],
      ),
    );
  }
}
