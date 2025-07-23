import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import '../widgets/home_dropdowns_column.dart';
import '../widgets/home_button_column.dart';
import 'part_input_screen.dart';
import 'process_input_screen.dart';
import '../screens/organization_setup_screen.dart';
import '../logic/app_database.dart';
import 'plant_setup_screen.dart';
import '../database_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/app_footer.dart';
import 'elements_input_screen.dart';
import 'time_observation_form.dart';
import '../widgets/app_drawer.dart';

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware {
  static const _kCompanyKey = 'selectedCompany';
  static const _kPlantKey = 'selectedPlant';
  static const _kValueStreamKey = 'selectedValueStream';
  static const _kValueStreamIdKey = 'selectedValueStreamId';
  static const _kProcessKey = 'selectedProcess';
  bool hasSetupsForSelectedProcess = false;

  void _onProcessChanged(String? value) async {
    setState(() {
      selectedProcess = value;
    });
    _saveSelections();
    await _checkSetupsForSelectedProcess();
  }

  Future<void> _checkSetupsForSelectedProcess() async {
    if (selectedProcess == null || selectedProcess!.isEmpty) {
      setState(() {
        hasSetupsForSelectedProcess = false;
      });
      return;
    }
    // Get processId for selectedProcess
    final processRow = await (db.select(db.processes)
          ..where((tbl) => tbl.processName.equals(selectedProcess!)))
        .getSingleOrNull();
    if (processRow == null) {
      setState(() {
        hasSetupsForSelectedProcess = false;
      });
      return;
    }
    final processId = processRow.id;
    // Get all ProcessParts for this processId
    final processParts = await (db.select(db.processParts)
          ..where((tbl) => tbl.processId.equals(processId)))
        .get();
    if (processParts.isEmpty) {
      setState(() {
        hasSetupsForSelectedProcess = false;
      });
      return;
    }
    // Check if any SetupElements exist for these processPartIds
    final partIds = processParts.map((pp) => pp.id).toList();
    final setupCount = await (db.select(db.setupElements)
          ..where((tbl) => tbl.processPartId.isIn(partIds)))
        .get();
    setState(() {
      hasSetupsForSelectedProcess = setupCount.isNotEmpty;
    });
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
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    db = await DatabaseProvider.getInstance();
    await _loadSelections();
    await _loadDropdownData();
    await _loadProcessesForValueStream();
    await _checkSetupsForSelectedProcess();
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // Called when returning to this screen after popping another route
    _loadSelections();
    _loadDropdownData();
    setState(() {});
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
          builder: (_) => ElementsInputScreen(
            companyName: selectedCompany,
            plantName: selectedPlant,
            valueStreamName: selectedValueStream,
            processName: selectedProcess,
          ),
        ),
      );
    }
  }

  Future<void> _openTimeObservationScreen() async {
    // Query available setups and part numbers for the selected process
    if (selectedProcess == null || selectedProcess!.isEmpty) return;
    // Get processId
    final processRow = await (db.select(db.processes)
          ..where((tbl) => tbl.processName.equals(selectedProcess!)))
        .getSingleOrNull();
    if (processRow == null) return;
    final processId = processRow.id;
    // Get all ProcessParts for this processId
    final processParts = await (db.select(db.processParts)
          ..where((tbl) => tbl.processId.equals(processId)))
        .get();
    if (processParts.isEmpty) return;
    // For each processPart, get setups and elements
    List<Map<String, dynamic>> setupOptions = [];
    // Group by setupName and partNumber, merge elements
    final Map<String, Map<String, dynamic>> grouped = {};
    for (final pp in processParts) {
      final setupElementsWithSetup = await (db.select(db.setupElements)
            ..where((tbl) => tbl.processPartId.equals(pp.id))
            ..orderBy([(tbl) => drift.OrderingTerm.asc(tbl.orderIndex)]))
          .join([
        drift.leftOuterJoin(
            db.setups, db.setups.id.equalsExp(db.setupElements.setupId))
      ]).get();

      for (final row in setupElementsWithSetup) {
        final setupElement = row.readTable(db.setupElements);
        final setup = row.readTableOrNull(db.setups);
        if (setup != null) {
          final key = '${setup.setupName}||${pp.partNumber}';
          if (!grouped.containsKey(key)) {
            grouped[key] = {
              'partNumber': pp.partNumber,
              'setupName': setup.setupName,
              'elements': <String>[],
            };
          }
          (grouped[key]!['elements'] as List<String>)
              .add(setupElement.elementName);
        }
      }
    }
    setupOptions = grouped.values.toList();
    if (setupOptions.isEmpty) return;

    Map<String, dynamic>? selectedOption = setupOptions[0];
    await showDialog(
      // ignore: use_build_context_synchronously
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Select Setup and Part Number'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return DropdownButton<Map<String, dynamic>>(
                value: selectedOption,
                isExpanded: true,
                items: setupOptions.map((opt) {
                  return DropdownMenuItem<Map<String, dynamic>>(
                    value: opt,
                    child: Text('${opt['setupName']} - ${opt['partNumber']}'),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    selectedOption = val;
                  });
                },
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(selectedOption),
              child: const Text('OK'),
            ),
          ],
        );
      },
    ).then((result) {
      if (result != null && result is Map<String, dynamic>) {
        // ignore: use_build_context_synchronously
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => TimeObservationForm(
              companyName: selectedCompany ?? '',
              plantName: selectedPlant ?? '',
              valueStreamName: selectedValueStream ?? '',
              processName: selectedProcess ?? '',
              initialPartNumber: result['partNumber'],
              initialElements: List<String>.from(result['elements']),
            ),
          ),
        );
      }
    });
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

    // Validate and clear invalid selections to prevent dropdown assertion errors
    String? validCompany = selectedCompany;
    String? validPlant = selectedPlant;
    String? validValueStream = selectedValueStream;
    String? validProcess = selectedProcess;

    if (selectedCompany != null && !companyNames.contains(selectedCompany)) {
      validCompany = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _onCompanyChanged(null);
      });
    }

    if (selectedPlant != null && !orgPlants.contains(selectedPlant)) {
      validPlant = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _onPlantChanged(null);
      });
    }

    if (selectedValueStream != null &&
        !valueStreams.contains(selectedValueStream)) {
      validValueStream = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _onValueStreamChanged(null);
      });
    }

    if (selectedProcess != null && !processNames.contains(selectedProcess)) {
      validProcess = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _onProcessChanged(null);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: Colors.white,
      ),
      drawer: const AppDrawer(),
      backgroundColor: Colors.yellow[100],
      body: Column(
        children: [
          // Removed HomeHeader from home screen
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Removed HeaderTextBox row
                        ],
                      ),
                      const SizedBox(height: 16),
                      SingleChildScrollView(
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
                                  onOpenObs: _openTimeObservationScreen,
                                  onAddPartNumber: _openPartInputScreen,
                                  onAddVSProcess: _onAddVSProcess,
                                  onAddElements: _openAddElementsScreen,
                                  enableAddPartNumber:
                                      (selectedCompany != null &&
                                          selectedCompany!.isNotEmpty &&
                                          selectedPlant != null &&
                                          selectedPlant!.isNotEmpty &&
                                          selectedValueStream != null &&
                                          selectedValueStream!.isNotEmpty),
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
                                      selectedProcess!.isNotEmpty &&
                                      hasSetupsForSelectedProcess),
                                ),
                              ),
                              const SizedBox(width: 32),
                              Flexible(
                                child: HomeDropdownsColumn(
                                  companyNames: companyNames,
                                  selectedCompany: validCompany,
                                  onCompanyChanged: _onCompanyChanged,
                                  plantNames: orgPlants,
                                  selectedPlant: validPlant,
                                  onPlantChanged: _onPlantChanged,
                                  valueStreams: valueStreams,
                                  selectedValueStream: validValueStream,
                                  onValueStreamChanged: _onValueStreamChanged,
                                  processes: processNames,
                                  selectedProcess: validProcess,
                                  onProcessChanged: _onProcessChanged,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const AppFooter(),
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
