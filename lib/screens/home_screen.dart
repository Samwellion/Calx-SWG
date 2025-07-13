import 'package:drift/drift.dart' as drift;
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../widgets/home_header.dart';
import '../widgets/home_dropdowns_column.dart';
import '../widgets/home_button_column.dart';
import 'part_input_screen.dart';
import 'process_input_screen.dart';
import '../screens/organization_setup_screen.dart';
import 'stopwatch_app.dart';
import '../logic/app_database.dart';
import 'plant_setup_screen.dart';
import '../database_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/home_footer.dart';
import 'setup.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _kCompanyKey = 'selectedCompany';
  static const _kPlantKey = 'selectedPlant';
  static const _kValueStreamKey = 'selectedValueStream';
  static const _kValueStreamIdKey = 'selectedValueStreamId';
  static const _kProcessKey = 'selectedProcess';
  void _onProcessChanged(String? value) {
    setState(() {
      selectedProcess = value;
    });
    _saveSelections();
  }

  void _onAddVSProcess() async {
    if (selectedValueStreamId != null &&
        selectedValueStream != null &&
        selectedCompany != null &&
        selectedPlant != null) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ProcessInputScreen(
            valueStreamId: selectedValueStreamId!,
            valueStreamName: selectedValueStream!,
            companyName: selectedCompany!,
            plantName: selectedPlant!,
          ),
        ),
      );
      // Reload process dropdown after returning from process input
      await _loadProcessesForValueStream();
    }
  }

  String? selectedCompany;
  String? selectedPlant;
  String? selectedValueStream;
  int? selectedValueStreamId;
  String? selectedProcess;
  late AppDatabase db;
  List<ValueStream> _allValueStreams = [];
  List<Plant> _allPlants = [];
  List<String> companyNames = [];
  Map<String, List<String>> companyPlants = {};
  Map<String, List<String>> plantValueStreams = {};
  List<String> processNames = [];
  bool isLoading = true;
  Future<void> _loadProcessesForValueStream() async {
    if (selectedValueStreamId == null) {
      setState(() {
        processNames = [];
        selectedProcess = null;
      });
      return;
    }
    final result = await db.customSelect(
      'SELECT process_name FROM processes WHERE value_stream_id = ?',
      variables: [drift.Variable.withInt(selectedValueStreamId!)],
    ).get();
    final names =
        result.map((row) => row.data['process_name'] as String).toList();
    setState(() {
      processNames = names;
      if (!processNames.contains(selectedProcess)) {
        selectedProcess = null;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _loadSelections().then((_) {
      DatabaseProvider.getInstance().then((database) {
        db = database;
        _loadDropdownData();
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadSelections();
  }

  Future<void> _loadSelections() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      final c = prefs.getString(_kCompanyKey);
      selectedCompany = (c != null && c.isNotEmpty) ? c : null;
      final p = prefs.getString(_kPlantKey);
      selectedPlant = (p != null && p.isNotEmpty) ? p : null;
      final vs = prefs.getString(_kValueStreamKey);
      selectedValueStream = (vs != null && vs.isNotEmpty) ? vs : null;
      final vsid = prefs.getInt(_kValueStreamIdKey);
      selectedValueStreamId = (vsid != null && vsid != -1) ? vsid : null;
      final proc = prefs.getString(_kProcessKey);
      selectedProcess = (proc != null && proc.isNotEmpty) ? proc : null;
    });
  }

  Future<void> _saveSelections() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kCompanyKey, selectedCompany ?? '');
    await prefs.setString(_kPlantKey, selectedPlant ?? '');
    await prefs.setString(_kValueStreamKey, selectedValueStream ?? '');
    await prefs.setInt(_kValueStreamIdKey, selectedValueStreamId ?? -1);
    await prefs.setString(_kProcessKey, selectedProcess ?? '');
  }

  Future<void> _openPlantSetupScreen() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const PlantSetupScreen(),
      ),
    );
    await _loadDropdownData();
  }

  Future<void> _loadDropdownData() async {
    final orgs = await db.select(db.organizations).get();
    companyNames = orgs.map((o) => o.name).toList();
    final plants = await db.select(db.plants).get();
    companyPlants = {};
    for (final org in orgs) {
      companyPlants[org.name] = plants
          .where((p) => p.organizationId == org.id)
          .map((p) => p.name)
          .toList();
    }
    final valueStreams = await db.select(db.valueStreams).get();
    plantValueStreams = {};
    for (final plant in plants) {
      plantValueStreams[plant.name] = valueStreams
          .where((vs) => vs.plantId == plant.id)
          .map((vs) => vs.name)
          .toList();
    }
    _allPlants = plants
        .map((p) => Plant(
              id: p.id,
              organizationId: p.organizationId,
              name: p.name,
              street: p.street,
              city: p.city,
              state: p.state,
              zip: p.zip,
            ))
        .toList();
    _allValueStreams = valueStreams;

    setState(() {
      isLoading = false;
    });
  }

  void _onCompanyChanged(String? value) {
    setState(() {
      selectedCompany = value;
      selectedPlant = null;
      selectedValueStream = null;
      selectedValueStreamId = null;
      selectedProcess = null;
    });
    _saveSelections();
  }

  void _onPlantChanged(String? value) {
    setState(() {
      selectedPlant = value;
      selectedValueStream = null;
      selectedValueStreamId = null;
      selectedProcess = null;
    });
    _saveSelections();
  }

  // Removed duplicate declaration of _allValueStreams
  Future<void> _onValueStreamChanged(String? value) async {
    setState(() {
      selectedValueStream = value;
      if (value != null && value.isNotEmpty && selectedPlant != null) {
        final plant = _allPlants.firstWhere(
          (p) => p.name == selectedPlant,
          orElse: () => Plant(
              id: -1,
              organizationId: -1,
              name: '',
              street: '',
              city: '',
              state: '',
              zip: ''),
        );
        final vs = _allValueStreams.firstWhere(
          (v) => v.name == value && v.plantId == plant.id,
          orElse: () => ValueStream(id: -1, plantId: -1, name: ''),
        );
        selectedValueStreamId = vs.id > 0 ? vs.id : null;
      } else {
        selectedValueStreamId = null;
      }
      selectedProcess = null;
    });
    _saveSelections();
    await _loadProcessesForValueStream();
  }

  void _openPartInputScreen() async {
    if (selectedValueStreamId != null &&
        selectedValueStream != null &&
        selectedCompany != null &&
        selectedPlant != null) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PartInputScreen(
            valueStreamId: selectedValueStreamId!,
            valueStreamName: selectedValueStream!,
            companyName: selectedCompany!,
            plantName: selectedPlant!,
          ),
        ),
      );
      await _loadSelections();
    }
  }

  void _openAddElementsScreen() async {
    if (selectedValueStreamId != null) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => SetupScreen(
            companyName: selectedCompany,
            plantName: selectedPlant,
            valueStreamName: selectedValueStream,
            processName: selectedProcess,
          ),
        ),
      );
    }
  }

  void _openStopwatchApp() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => StopwatchApp(
          companyName: selectedCompany ?? '',
          plantName: selectedPlant ?? '',
          valueStreamName: selectedValueStream ?? '',
          processName: selectedProcess ?? '',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final String? orgCompany = selectedCompany;
    final List<String> orgPlants =
        orgCompany != null && companyPlants[orgCompany] != null
            ? companyPlants[orgCompany]!
            : <String>[];
    final List<String> valueStreams =
        (selectedPlant != null && plantValueStreams[selectedPlant!] != null)
            ? plantValueStreams[selectedPlant!]!
            : <String>[];
    return Scaffold(
      backgroundColor: Colors.yellow[100],
      body: Column(
        children: [
          HomeHeader(
            companyName: orgCompany,
            plantName: selectedPlant,
            valueStreamName: selectedValueStream,
          ),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Container(
                  padding: const EdgeInsets.all(32),
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
                  child: SingleChildScrollView(
                    child: IntrinsicHeight(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                            child: HomeButtonColumn(
                              onSetupOrg: () async {
                                await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const OrganizationSetupScreen(),
                                  ),
                                );
                                await _loadDropdownData();
                              },
                              onLoadOrg: _openPlantSetupScreen,
                              onOpenObs: _openStopwatchApp,
                              onAddPartNumber: _openPartInputScreen,
                              onAddVSProcess: _onAddVSProcess,
                              onAddElements: _openAddElementsScreen,
                              enableAddPartNumber: (selectedCompany != null &&
                                  selectedCompany!.isNotEmpty &&
                                  selectedPlant != null &&
                                  selectedPlant!.isNotEmpty &&
                                  selectedValueStream != null &&
                                  selectedValueStream!.isNotEmpty),
                              // Only enable Add Setup and Elements and Open Time Observation if a process is selected
                              enableAddElements: (selectedCompany != null &&
                                  selectedCompany!.isNotEmpty &&
                                  selectedPlant != null &&
                                  selectedPlant!.isNotEmpty &&
                                  selectedValueStream != null &&
                                  selectedValueStream!.isNotEmpty &&
                                  selectedProcess != null &&
                                  selectedProcess!.isNotEmpty),
                              enableOpenObs: (selectedCompany != null &&
                                  selectedCompany!.isNotEmpty &&
                                  selectedPlant != null &&
                                  selectedPlant!.isNotEmpty &&
                                  selectedValueStream != null &&
                                  selectedValueStream!.isNotEmpty &&
                                  selectedProcess != null &&
                                  selectedProcess!.isNotEmpty),
                            ),
                          ),
                          const SizedBox(width: 32),
                          Flexible(
                            child: HomeDropdownsColumn(
                              companyNames: companyNames,
                              selectedCompany: selectedCompany,
                              onCompanyChanged: _onCompanyChanged,
                              plantNames: orgPlants,
                              selectedPlant: selectedPlant,
                              onPlantChanged: _onPlantChanged,
                              valueStreams: valueStreams,
                              selectedValueStream: selectedValueStream,
                              onValueStreamChanged: _onValueStreamChanged,
                              processes: processNames,
                              selectedProcess: selectedProcess,
                              onProcessChanged: _onProcessChanged,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const HomeFooter(),
        ],
      ),
    );
  }
}

class Plant {
  final int id;
  final int organizationId;
  final String name;
  final String street;
  final String city;
  final String state;
  final String zip;

  Plant({
    required this.id,
    required this.organizationId,
    required this.name,
    required this.street,
    required this.city,
    required this.state,
    required this.zip,
  });
}
