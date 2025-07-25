import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'dart:async';
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

  // Debouncing timer for database operations
  Timer? _debounceTimer;
  static const Duration _debounceDelay = Duration(milliseconds: 300);

  bool hasSetupsForSelectedProcess = false;
  bool _isDisposed = false;

  void _onProcessChanged(String? value) async {
    if (_isDisposed) return;

    setState(() {
      selectedProcess = value;
    });
    _saveSelections();

    // Debounce the database operation
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDelay, () async {
      if (!_isDisposed) {
        await _checkSetupsForSelectedProcess();
      }
    });
  }

  Future<void> _checkSetupsForSelectedProcess() async {
    if (_isDisposed || selectedProcess == null || selectedProcess!.isEmpty) {
      if (!_isDisposed) {
        setState(() {
          hasSetupsForSelectedProcess = false;
        });
      }
      return;
    }

    try {
      // Use a single optimized query instead of multiple queries
      final result = await db.customSelect('''
        SELECT COUNT(*) as count 
        FROM setup_elements se
        INNER JOIN process_parts pp ON se.process_part_id = pp.id
        INNER JOIN processes p ON pp.process_id = p.id
        WHERE p.process_name = ?
      ''',
          variables: [drift.Variable.withString(selectedProcess!)]).getSingle();

      final count = result.data['count'] as int;

      if (!_isDisposed) {
        setState(() {
          hasSetupsForSelectedProcess = count > 0;
        });
      }
    } catch (e) {
      debugPrint('Error checking setups for selected process: $e');
      if (!_isDisposed) {
        setState(() {
          hasSetupsForSelectedProcess = false;
        });
      }
    }
  }

  Future<void> _onAddVSProcess() async {
    if (selectedValueStreamId != null &&
        selectedValueStream != null &&
        selectedCompany != null &&
        selectedPlant != null) {
      try {
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
      } catch (e) {
        debugPrint('Error navigating to process input screen: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error opening process input screen')),
          );
        }
      }
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
  DateTime? _lastDataLoad;
  static const Duration _cacheValidityDuration = Duration(minutes: 5);
  Future<void> _loadProcessesForValueStream() async {
    if (_isDisposed || selectedValueStreamId == null) {
      if (!_isDisposed) {
        setState(() {
          processNames = [];
          selectedProcess = null;
        });
      }
      return;
    }

    try {
      final result = await db.customSelect(
        'SELECT process_name FROM processes WHERE value_stream_id = ? ORDER BY process_name',
        variables: [drift.Variable.withInt(selectedValueStreamId!)],
      ).get();

      final names =
          result.map((row) => row.data['process_name'] as String).toList();

      if (!_isDisposed) {
        setState(() {
          processNames = names;
          if (!processNames.contains(selectedProcess)) {
            selectedProcess = null;
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading processes for value stream: $e');
      if (!_isDisposed) {
        setState(() {
          processNames = [];
          selectedProcess = null;
        });
      }
    }
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
    _isDisposed = true;
    _debounceTimer?.cancel();
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
    try {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PlantSetupScreen(
            selectedPlantName:
                selectedPlant, // Pass the currently selected plant
          ),
        ),
      );
      // Invalidate cache to force reload of dropdown data
      _lastDataLoad = null;
      await _loadDropdownData();
    } catch (e) {
      debugPrint('Error navigating to plant setup screen: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error opening plant setup screen')),
        );
      }
    }
  }

  Future<void> _loadDropdownData() async {
    if (_isDisposed) return;

    // Check if we need to reload data based on cache validity
    final now = DateTime.now();
    if (_lastDataLoad != null &&
        now.difference(_lastDataLoad!) < _cacheValidityDuration &&
        companyNames.isNotEmpty) {
      return; // Use cached data
    }

    try {
      final orgs = await db.select(db.organizations).get();
      companyNames = orgs.map((o) => o.name).toList()..sort();

      final plants = await db.select(db.plants).get();
      companyPlants = {};
      for (final org in orgs) {
        final orgPlants = plants
            .where((p) => p.organizationId == org.id)
            .map((p) => p.name)
            .toList()
          ..sort();
        companyPlants[org.name] = orgPlants;
      }

      final valueStreams = await db.select(db.valueStreams).get();
      plantValueStreams = {};
      for (final plant in plants) {
        final plantStreams = valueStreams
            .where((vs) => vs.plantId == plant.id)
            .map((vs) => vs.name)
            .toList()
          ..sort();
        plantValueStreams[plant.name] = plantStreams;
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
      _lastDataLoad = now;
    } catch (e) {
      debugPrint('Error loading dropdown data: $e');
      // Initialize with empty data on error
      companyNames = [];
      companyPlants = {};
      plantValueStreams = {};
      _allPlants = [];
      _allValueStreams = [];
    }
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

  Future<void> _onValueStreamChanged(String? value) async {
    if (_isDisposed) return;

    setState(() {
      selectedValueStream = value;
      selectedProcess = null;

      if (value != null && value.isNotEmpty && selectedPlant != null) {
        try {
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

          if (plant.id > 0) {
            final vs = _allValueStreams.firstWhere(
              (v) => v.name == value && v.plantId == plant.id,
              orElse: () => ValueStream(id: -1, plantId: -1, name: ''),
            );
            selectedValueStreamId = vs.id > 0 ? vs.id : null;
          } else {
            selectedValueStreamId = null;
          }
        } catch (e) {
          debugPrint('Error finding value stream ID: $e');
          selectedValueStreamId = null;
        }
      } else {
        selectedValueStreamId = null;
      }
    });

    _saveSelections();
    await _loadProcessesForValueStream();
  }

  void _openPartInputScreen() async {
    if (selectedValueStreamId != null &&
        selectedValueStream != null &&
        selectedCompany != null &&
        selectedPlant != null) {
      try {
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
      } catch (e) {
        debugPrint('Error navigating to part input screen: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error opening part input screen')),
          );
        }
      }
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
    if (selectedProcess == null || selectedProcess!.isEmpty) return;

    // Store context before async operations
    final currentContext = context;

    try {
      // Use optimized single query to get setup options
      final setupOptionsResult = await db.customSelect('''
        SELECT pp.part_number, s.setup_name, 
               GROUP_CONCAT(se.element_name ORDER BY se.order_index) as elements
        FROM setup_elements se
        INNER JOIN process_parts pp ON se.process_part_id = pp.id
        INNER JOIN processes p ON pp.process_id = p.id
        INNER JOIN setups s ON se.setup_id = s.id
        WHERE p.process_name = ?
        GROUP BY pp.part_number, s.setup_name
        ORDER BY s.setup_name, pp.part_number
      ''', variables: [drift.Variable.withString(selectedProcess!)]).get();

      if (setupOptionsResult.isEmpty) {
        if (mounted && currentContext.mounted) {
          ScaffoldMessenger.of(currentContext).showSnackBar(
            const SnackBar(
                content: Text('No setups found for selected process')),
          );
        }
        return;
      }

      final setupOptions = setupOptionsResult.map((row) {
        final elements = row.data['elements'] as String? ?? '';
        return {
          'partNumber': row.data['part_number'] as String,
          'setupName': row.data['setup_name'] as String,
          'elements': elements.isNotEmpty ? elements.split(',') : <String>[],
        };
      }).toList();

      Map<String, dynamic>? selectedOption = setupOptions.first;

      // ignore: use_build_context_synchronously
      final result = await showDialog<Map<String, dynamic>>(
        // ignore: use_build_context_synchronously
        context: currentContext,
        barrierDismissible: false,
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
      );

      if (result != null) {
        if (mounted && currentContext.mounted) {
          Navigator.of(currentContext).push(
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
      }
    } catch (e) {
      debugPrint('Error opening time observation screen: $e');
      if (mounted && currentContext.mounted) {
        ScaffoldMessenger.of(currentContext).showSnackBar(
          const SnackBar(content: Text('Error loading setup data')),
        );
      }
    }
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
