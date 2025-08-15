import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../logic/app_database.dart';
import 'package:drift/drift.dart' as drift;
import '../database_provider.dart';
import '../widgets/app_drawer.dart';
import '../widgets/app_footer.dart';
import '../widgets/home_button_wrapper.dart';

class DetailedProcessInputScreen extends StatefulWidget {
  final int valueStreamId;
  final String valueStreamName;
  final String companyName;
  final String plantName;
  final int? processId; // Optional - for editing existing process

  const DetailedProcessInputScreen({
    super.key,
    required this.valueStreamId,
    required this.valueStreamName,
    required this.companyName,
    required this.plantName,
    this.processId,
  });

  @override
  State<DetailedProcessInputScreen> createState() =>
      _DetailedProcessInputScreenState();
}

class _DetailedProcessInputScreenState
    extends State<DetailedProcessInputScreen> {
  final _formKey = GlobalKey<FormState>();

  // Process field controllers
  final TextEditingController _processNameController = TextEditingController();
  final TextEditingController _processDescriptionController =
      TextEditingController();
  final TextEditingController _dailyDemandController = TextEditingController();
  final TextEditingController _staffController = TextEditingController();
  final TextEditingController _wipController = TextEditingController();
  final TextEditingController _uptimeController = TextEditingController();
  final TextEditingController _coTimeController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _taktTimeController = TextEditingController();

  bool _loading = true;
  String? _error;
  late AppDatabase db;

  // Available parts for this value stream - split into assigned and available
  List<Part> _assignedParts = [];
  List<Part> _availableParts = [];
  List<Part> _filteredAvailableParts = [];

  // Available processes for dropdown selection
  List<ProcessesData> _availableProcesses = [];
  ProcessesData? _selectedProcess;

  // Process parts assignments
  List<Map<String, dynamic>> _processPartAssignments = [];
  Set<String> _selectedParts = <String>{};

  // ProcessShift records
  List<ProcessShiftData> _processShifts = [];

  // Process part details controllers
  final Map<String, TextEditingController> _processTimeControllers = {};
  final Map<String, TextEditingController> _fpyControllers = {};
  final Map<String, TextEditingController> _dailyDemandPartControllers = {};

  @override
  void initState() {
    super.initState();
    DatabaseProvider.getInstance().then((database) {
      db = database;
      _loadData();
    }).catchError((e) {
      setState(() {
        _error = 'Database initialization failed: $e';
        _loading = false;
      });
    });
    _searchController.addListener(_filterAvailableParts);
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // Load all processes for this value stream
      final processesQuery = db.select(db.processes)
        ..where((p) => p.valueStreamId.equals(widget.valueStreamId))
        ..orderBy([(p) => drift.OrderingTerm.asc(p.orderIndex)]);

      _availableProcesses = await processesQuery.get();

      // Load all parts for this value stream
      final partsQuery = db.select(db.parts)
        ..where((p) => p.valueStreamId.equals(widget.valueStreamId))
        ..orderBy([(p) => drift.OrderingTerm.asc(p.partNumber)]);

      final allParts = await partsQuery.get();

      // If editing existing process, load process details and part assignments
      if (widget.processId != null) {
        // Find and set the selected process
        _selectedProcess = _availableProcesses.firstWhere(
          (process) => process.id == widget.processId!,
          orElse: () => _availableProcesses.isNotEmpty
              ? _availableProcesses.first
              : throw Exception('No processes available'),
        );

        await _loadExistingProcess();

        // Split parts into assigned and available
        _assignedParts = allParts
            .where((part) => _selectedParts.contains(part.partNumber))
            .toList();
        _availableParts = allParts
            .where((part) => !_selectedParts.contains(part.partNumber))
            .toList();
      } else {
        // For new process, set first available process as selected
        _selectedProcess =
            _availableProcesses.isNotEmpty ? _availableProcesses.first : null;

        // For new process, all parts are available
        _assignedParts = [];
        _availableParts = allParts;
      }

      _filteredAvailableParts = _availableParts;

      // Load ProcessShift records
      await _loadProcessShifts();

      setState(() {
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load data: $e';
        _loading = false;
      });
    }
  }

  Future<void> _loadExistingProcess() async {
    if (widget.processId == null) return;

    try {
      // Load process details
      final processResult = await db.customSelectQuery(
        '''SELECT process_name, process_description, daily_demand, staff, wip, uptime, co_time, takt_time
           FROM processes 
           WHERE id = ?''',
        variables: [drift.Variable.withInt(widget.processId!)],
      ).get();

      if (processResult.isNotEmpty) {
        final process = processResult.first.data;
        _processNameController.text = process['process_name'] ?? '';
        _processDescriptionController.text =
            process['process_description'] ?? '';
        _dailyDemandController.text = process['daily_demand']?.toString() ?? '';
        _staffController.text = process['staff']?.toString() ?? '';
        _wipController.text = process['wip']?.toString() ?? '';
        _uptimeController.text = process['uptime'] != null
            ? (process['uptime'] * 100).toStringAsFixed(1)
            : '';
        _coTimeController.text = process['co_time'] ?? '';

        // Load the takt time from database or calculate if not stored
        String? storedTaktTime = process['takt_time'];
        String taktTimeValue = storedTaktTime ?? _calculateTaktTime();
        _taktTimeController.text = taktTimeValue;
      }

      // Load existing process part assignments
      final assignmentsResult = await db.customSelectQuery(
        '''SELECT pp.part_number, pp.daily_demand, pp.process_time, pp.fpy,
                  p.part_description, p.monthly_demand
           FROM process_parts pp
           JOIN parts p ON pp.part_number = p.part_number AND p.value_stream_id = ?
           WHERE pp.process_id = ?''',
        variables: [
          drift.Variable.withInt(widget.valueStreamId),
          drift.Variable.withInt(widget.processId!),
        ],
      ).get();

      _processPartAssignments =
          assignmentsResult.map((row) => row.data).toList();
      _selectedParts = _processPartAssignments
          .map<String>((assignment) => assignment['part_number'] as String)
          .toSet();

      // Initialize controllers for existing assignments
      for (final assignment in _processPartAssignments) {
        final partNumber = assignment['part_number'] as String;
        _processTimeControllers[partNumber] =
            TextEditingController(text: assignment['process_time'] ?? '');
        _fpyControllers[partNumber] = TextEditingController(
            text: assignment['fpy'] != null
                ? (assignment['fpy'] * 100).toStringAsFixed(1)
                : '');
        _dailyDemandPartControllers[partNumber] = TextEditingController(
            text: assignment['daily_demand']?.toString() ?? '');
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load existing process: $e';
      });
    }
  }

  @override
  void dispose() {
    // Save current field values before disposing
    if (_selectedProcess != null) {
      _saveCurrentFieldValues();
    }

    _processNameController.dispose();
    _processDescriptionController.dispose();
    _dailyDemandController.dispose();
    _staffController.dispose();
    _wipController.dispose();
    _uptimeController.dispose();
    _coTimeController.dispose();
    _searchController.dispose();
    _taktTimeController.dispose();

    for (var controller in _processTimeControllers.values) {
      controller.dispose();
    }
    for (var controller in _fpyControllers.values) {
      controller.dispose();
    }
    for (var controller in _dailyDemandPartControllers.values) {
      controller.dispose();
    }

    super.dispose();
  }

  // Load ProcessShift records for the current process
  Future<void> _loadProcessShifts() async {
    if (_selectedProcess == null) {
      setState(() {
        _processShifts = [];
      });
      return;
    }

    try {
      final shifts = await db.getProcessShifts(_selectedProcess!.id);
      setState(() {
        _processShifts = shifts;
      });

      // Update daily demand field after loading shifts
      await _updateDailyDemandField();
    } catch (e) {
      debugPrint('Error loading ProcessShifts: $e');
      setState(() {
        _processShifts = [];
      });
    }
  }

  // Part assignment methods
  void _onProcessSelectionChanged(ProcessesData? newProcess) async {
    if (newProcess == null || newProcess == _selectedProcess) return;

    // Auto-save current field values before switching processes
    if (_selectedProcess != null) {
      await _saveCurrentFieldValues();
    }

    setState(() {
      _selectedProcess = newProcess;
      _loading = true;
    });

    try {
      // Clear current form data
      _processNameController.clear();
      _processDescriptionController.clear();
      _dailyDemandController.clear();
      _staffController.clear();
      _wipController.clear();
      _uptimeController.clear();
      _coTimeController.clear();

      // Clear part assignments
      _assignedParts.clear();
      _availableParts.clear();
      _selectedParts.clear();

      // Load the selected process data
      await _loadSelectedProcessData(newProcess);

      // Calculate and save takt time for the newly selected process
      await _autoSaveTaktTime();

      setState(() {
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load process data: $e';
        _loading = false;
      });
    }
  }

  // Auto-save all current field values
  Future<void> _saveCurrentFieldValues() async {
    if (_selectedProcess == null) return;

    try {
      // Save all field values that might have changed
      await Future.wait([
        _autoSaveProcessField('description', _processDescriptionController.text),
        _autoSaveProcessField('staff', _staffController.text),
        _autoSaveProcessField('wip', _wipController.text),
        _autoSaveProcessField('uptime', _uptimeController.text),
        _autoSaveProcessField('coTime', _coTimeController.text),
      ]);
    } catch (e) {
      debugPrint('Error saving current field values: $e');
    }
  }

  // Auto-save process field changes
  Future<void> _autoSaveProcessField(String fieldName, String value) async {
    if (_selectedProcess == null) return;

    try {
      switch (fieldName) {
        case 'description':
          await db.updateProcess(
            _selectedProcess!.id,
            description: value.trim().isNotEmpty ? value.trim() : null,
          );
          break;
        case 'dailyDemand':
          await db.updateProcess(
            _selectedProcess!.id,
            dailyDemand:
                value.trim().isNotEmpty ? int.tryParse(value.trim()) : null,
          );
          // Update takt time since daily demand affects the calculation
          await _autoSaveTaktTime();
          break;
        case 'staff':
          await db.updateProcess(
            _selectedProcess!.id,
            staff: value.trim().isNotEmpty ? int.tryParse(value.trim()) : null,
          );
          break;
        case 'wip':
          await db.updateProcess(
            _selectedProcess!.id,
            wip: value.trim().isNotEmpty ? int.tryParse(value.trim()) : null,
          );
          break;
        case 'uptime':
          await db.updateProcess(
            _selectedProcess!.id,
            uptime: value.trim().isNotEmpty
                ? (double.tryParse(value.trim()) ?? 0) / 100
                : null,
          );
          break;
        case 'coTime':
          await db.updateProcess(
            _selectedProcess!.id,
            coTime: value.trim().isNotEmpty ? value.trim() : null,
          );
          break;
        case 'taktTime':
          await db.updateProcess(
            _selectedProcess!.id,
            taktTime: value.trim().isNotEmpty ? value.trim() : null,
          );
          break;
      }
    } catch (e) {
      debugPrint('Auto-save error for $fieldName: $e');
      // Show subtle error indication
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Auto-save failed for $fieldName'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  // Auto-save calculated takt time to the database
  Future<void> _autoSaveTaktTime() async {
    if (_selectedProcess == null) return;

    try {
      String calculatedTaktTime = _calculateTaktTime();
      // Update the controller to refresh the UI
      _taktTimeController.text = calculatedTaktTime;
      await _autoSaveProcessField('taktTime', calculatedTaktTime);
    } catch (e) {
      debugPrint('Auto-save error for taktTime: $e');
    }
  }

  Future<void> _loadSelectedProcessData(ProcessesData process) async {
    // Load process details into form
    _processNameController.text = process.processName;
    _processDescriptionController.text = process.processDescription ?? '';
    _dailyDemandController.text = process.dailyDemand?.toString() ?? '';
    _staffController.text = process.staff?.toString() ?? '';
    _wipController.text = process.wip?.toString() ?? '';
    _uptimeController.text = process.uptime != null
        ? (process.uptime! * 100).toStringAsFixed(1)
        : '';
    _coTimeController.text = process.coTime ?? '';

    // Initialize takt time controller with stored value or calculate if not stored
    String taktTimeValue = process.taktTime ?? _calculateTaktTime();
    _taktTimeController.text = taktTimeValue;

    // Load existing process part assignments
    final assignmentsResult = await db.customSelectQuery(
      '''SELECT pp.part_number, pp.daily_demand, pp.process_time, pp.fpy,
                p.part_description, p.monthly_demand
         FROM process_parts pp
         JOIN parts p ON pp.part_number = p.part_number AND p.value_stream_id = ?
         WHERE pp.process_id = ?''',
      variables: [
        drift.Variable.withInt(widget.valueStreamId),
        drift.Variable.withInt(process.id),
      ],
    ).get();

    _processPartAssignments = assignmentsResult.map((row) => row.data).toList();
    _selectedParts = _processPartAssignments
        .map<String>((assignment) => assignment['part_number'] as String)
        .toSet();

    // Initialize controllers for existing assignments
    for (final assignment in _processPartAssignments) {
      final partNumber = assignment['part_number'] as String;
      _processTimeControllers[partNumber] =
          TextEditingController(text: assignment['process_time'] ?? '');
      _fpyControllers[partNumber] = TextEditingController(
          text: assignment['fpy'] != null
              ? (assignment['fpy'] * 100).toStringAsFixed(1)
              : '');
      _dailyDemandPartControllers[partNumber] = TextEditingController(
          text: assignment['daily_demand']?.toString() ?? '');
    }

    // Load all parts and split into assigned/available
    final partsQuery = db.select(db.parts)
      ..where((p) => p.valueStreamId.equals(widget.valueStreamId))
      ..orderBy([(p) => drift.OrderingTerm.asc(p.partNumber)]);

    final allParts = await partsQuery.get();

    _assignedParts = allParts
        .where((part) => _selectedParts.contains(part.partNumber))
        .toList();
    _availableParts = allParts
        .where((part) => !_selectedParts.contains(part.partNumber))
        .toList();
    _filteredAvailableParts = _availableParts;

    // Load ProcessShift records
    await _loadProcessShifts();
  }

  void _filterAvailableParts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredAvailableParts = _availableParts.where((part) {
        final partNumber = part.partNumber.toLowerCase();
        final partDescription = part.partDescription?.toLowerCase() ?? '';
        return partNumber.contains(query) || partDescription.contains(query);
      }).toList();
    });
  }

  void _assignPartToProcess(Part part) async {
    setState(() {
      _selectedParts.add(part.partNumber);
      _assignedParts.add(part);
      _availableParts.remove(part);

      // Initialize controllers for new part
      _processTimeControllers[part.partNumber] = TextEditingController();
      _fpyControllers[part.partNumber] = TextEditingController();
      _dailyDemandPartControllers[part.partNumber] = TextEditingController();
    });

    // Auto-save the part assignment
    if (_selectedProcess != null) {
      try {
        final processPartCompanion = ProcessPartsCompanion(
          partNumber: drift.Value(part.partNumber),
          processId: drift.Value(_selectedProcess!.id),
          dailyDemand: const drift.Value(null),
          processTime: const drift.Value(null),
          fpy: const drift.Value(null),
        );

        await db.into(db.processParts).insert(processPartCompanion);

        // Update daily demand field and recalculate takt time
        await _updateDailyDemandField();
        await _autoSaveTaktTime();

        if (mounted) {
          setState(() {}); // Force UI refresh to show updated TT value
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Part ${part.partNumber} assigned to process'),
              duration: const Duration(seconds: 2),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        debugPrint('Error auto-saving part assignment: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to assign part ${part.partNumber}'),
              duration: const Duration(seconds: 2),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }

    // Update the daily demand field after assignment
    await _updateDailyDemandField();
  }

  void _unassignPartFromProcess(Part part) async {
    setState(() {
      _selectedParts.remove(part.partNumber);
      _assignedParts.remove(part);
      _availableParts.add(part);
      _availableParts.sort((a, b) => a.partNumber.compareTo(b.partNumber));

      // Dispose controllers for removed part
      _processTimeControllers[part.partNumber]?.dispose();
      _fpyControllers[part.partNumber]?.dispose();
      _dailyDemandPartControllers[part.partNumber]?.dispose();
      _processTimeControllers.remove(part.partNumber);
      _fpyControllers.remove(part.partNumber);
      _dailyDemandPartControllers.remove(part.partNumber);
    });

    // Auto-save the part removal
    if (_selectedProcess != null) {
      try {
        await db.customStatement(
          'DELETE FROM process_parts WHERE process_id = ? AND part_number = ?',
          [_selectedProcess!.id, part.partNumber],
        );

        // Update daily demand field and recalculate takt time
        await _updateDailyDemandField();
        await _autoSaveTaktTime();

        if (mounted) {
          setState(() {}); // Force UI refresh to show updated TT value
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Part ${part.partNumber} removed from process'),
              duration: const Duration(seconds: 2),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        debugPrint('Error auto-saving part removal: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to remove part ${part.partNumber}'),
              duration: const Duration(seconds: 2),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }

    // Update the daily demand field after removal
    await _updateDailyDemandField();
  }

  String? _validateTimeFormat(String? value) {
    if (value == null || value.isEmpty) return null;

    final timeRegex = RegExp(r'^\d{1,2}:\d{2}:\d{2}$');
    if (!timeRegex.hasMatch(value)) {
      return 'Format: HH:MM:SS (e.g., 01:30:00)';
    }

    final parts = value.split(':');
    final hours = int.tryParse(parts[0]);
    final minutes = int.tryParse(parts[1]);
    final seconds = int.tryParse(parts[2]);

    if (hours == null ||
        minutes == null ||
        seconds == null ||
        minutes >= 60 ||
        seconds >= 60) {
      return 'Invalid time format';
    }

    return null;
  }

  bool _isWorkingDay(String? timeValue) {
    if (timeValue == null || timeValue.trim().isEmpty) return false;

    String cleanTime = timeValue.trim();

    // Check for common "no work" patterns
    if (cleanTime == '0' ||
        cleanTime == '00:00:00' ||
        cleanTime == '0:00:00' ||
        cleanTime == '00:00' ||
        cleanTime == '0:00') {
      return false;
    }

    return true;
  }

  int _calculateWorkingDaysPerWeek() {
    if (_processShifts.isEmpty) return 0;

    Set<String> workingDays = <String>{};

    for (var shift in _processShifts) {
      // Check each day of the week for actual working time values
      if (_isWorkingDay(shift.sun)) workingDays.add('sun');
      if (_isWorkingDay(shift.mon)) workingDays.add('mon');
      if (_isWorkingDay(shift.tue)) workingDays.add('tue');
      if (_isWorkingDay(shift.wed)) workingDays.add('wed');
      if (_isWorkingDay(shift.thu)) workingDays.add('thu');
      if (_isWorkingDay(shift.fri)) workingDays.add('fri');
      if (_isWorkingDay(shift.sat)) workingDays.add('sat');
    }

    return workingDays.length;
  }

  double _calculateAverageHoursPerWorkingDay() {
    if (_processShifts.isEmpty) return 0.0;

    double totalHours = 0.0;
    int workingDaysCount = 0;

    for (var shift in _processShifts) {
      List<String?> dayTimes = [
        shift.sun,
        shift.mon,
        shift.tue,
        shift.wed,
        shift.thu,
        shift.fri,
        shift.sat
      ];

      for (String? timeValue in dayTimes) {
        if (_isWorkingDay(timeValue)) {
          workingDaysCount++;
          totalHours += _parseTimeToHours(timeValue!);
        }
      }
    }

    return workingDaysCount > 0 ? totalHours / workingDaysCount : 0.0;
  }

  double _parseTimeToHours(String timeValue) {
    try {
      String cleanTime = timeValue.trim();

      // Handle different time formats
      List<String> parts;
      if (cleanTime.contains(':')) {
        parts = cleanTime.split(':');
      } else {
        // If it's just a number, assume it's hours
        return double.tryParse(cleanTime) ?? 0.0;
      }

      double hours = double.tryParse(parts[0]) ?? 0.0;

      if (parts.length > 1) {
        double minutes = double.tryParse(parts[1]) ?? 0.0;
        hours += minutes / 60.0;
      }

      if (parts.length > 2) {
        double seconds = double.tryParse(parts[2]) ?? 0.0;
        hours += seconds / 3600.0;
      }

      return hours;
    } catch (e) {
      return 0.0;
    }
  }

  double _calculateTotalDailyDemand() {
    if (_assignedParts.isEmpty) return 0.0;

    int totalMonthlyDemand = 0;
    for (var part in _assignedParts) {
      if (part.monthlyDemand != null) {
        totalMonthlyDemand += part.monthlyDemand!;
      }
    }

    // Convert monthly demand to weekly demand (divide by 4.33)
    double weeklyDemand = totalMonthlyDemand / 4.33;

    // Get working days per week
    int workingDaysPerWeek = _calculateWorkingDaysPerWeek();

    // Convert weekly demand to daily demand
    if (workingDaysPerWeek > 0) {
      return weeklyDemand / workingDaysPerWeek;
    } else {
      return 0.0;
    }
  }

  Future<void> _updateDailyDemandField() async {
    double calculatedDailyDemand = _calculateTotalDailyDemand();
    String newValue =
        calculatedDailyDemand.toStringAsFixed(0); // Round to whole number

    // Only update if the value has changed to avoid unnecessary saves
    if (_dailyDemandController.text != newValue) {
      _dailyDemandController.text = newValue;

      // Auto-save the new value
      await _autoSaveProcessField('dailyDemand', newValue);
    }
  }

  String _formatHoursToHHMMSS(double hours) {
    if (hours == 0.0) return '00:00:00';

    int totalSeconds = (hours * 3600).round();
    int hoursPart = totalSeconds ~/ 3600;
    int minutes = (totalSeconds % 3600) ~/ 60;
    int seconds = totalSeconds % 60;

    return '${hoursPart.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String _calculateTaktTime() {
    double avgHoursPerDay = _calculateAverageHoursPerWorkingDay();
    double dailyDemand = _calculateTotalDailyDemand();

    if (dailyDemand == 0.0) return '00:00:00';

    double taktTimeHours = avgHoursPerDay / dailyDemand;
    return _formatHoursToHHMMSS(taktTimeHours);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[100],
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: Text(
          '${widget.valueStreamName}: Detailed Process View',
          style: const TextStyle(fontSize: 18),
        ),
        elevation: 4,
      ),
      drawer: const AppDrawer(),
      body: _buildBody(),
      bottomNavigationBar: const AppFooter(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const HomeButtonWrapper(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 24),
              Text('Loading process data...'),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return HomeButtonWrapper(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return HomeButtonWrapper(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Column: Process Details (58%)
          Expanded(
            flex: 58,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildProcessDetailsSection(),
              ),
            ),
          ),

          // Middle Column: Assigned Parts (21%)
          Expanded(
            flex: 21,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 16, 16, 16),
              child: _buildAssignedPartsSection(),
            ),
          ),

          // Right Column: Available Parts (21%)
          Expanded(
            flex: 21,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 16, 16, 16),
              child: _buildAvailablePartsSection(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessDetailsSection() {
    return Column(
      children: [
        // Edit Process Details Card
        Card(
          color: Colors.yellow[50],
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Edit Process Details',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Process Name Dropdown (Required)
                  DropdownButtonFormField<ProcessesData>(
                    value: _selectedProcess,
                    decoration: const InputDecoration(
                      labelText: 'Process Name *',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                      isDense: true,
                    ),
                    items: _availableProcesses.map((process) {
                      return DropdownMenuItem<ProcessesData>(
                        value: process,
                        child: Text(process.processName),
                      );
                    }).toList(),
                    onChanged: _onProcessSelectionChanged,
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a process';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Process Description
                  TextFormField(
                    controller: _processDescriptionController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Process Description',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                      isDense: true,
                    ),
                    onFieldSubmitted: (value) =>
                        _autoSaveProcessField('description', value),
                    onEditingComplete: () =>
                        _autoSaveProcessField('description', _processDescriptionController.text),
                    onTapOutside: (event) =>
                        _autoSaveProcessField('description', _processDescriptionController.text),
                  ),
                  const SizedBox(height: 12),

                  // Staff Count, Daily Demand, WIP, Uptime, and Changeover Time on one line
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _staffController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Staff Count',
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                            isDense: true,
                          ),
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              if (int.tryParse(value) == null) {
                                return 'Must be a valid number';
                              }
                            }
                            return null;
                          },
                          onFieldSubmitted: (value) =>
                              _autoSaveProcessField('staff', value),
                          onEditingComplete: () =>
                              _autoSaveProcessField('staff', _staffController.text),
                          onTapOutside: (event) =>
                              _autoSaveProcessField('staff', _staffController.text),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _wipController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration: const InputDecoration(
                            labelText: 'WIP (Work in Progress)',
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                            isDense: true,
                          ),
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              if (int.tryParse(value) == null) {
                                return 'Must be a valid number';
                              }
                            }
                            return null;
                          },
                          onFieldSubmitted: (value) =>
                              _autoSaveProcessField('wip', value),
                          onEditingComplete: () =>
                              _autoSaveProcessField('wip', _wipController.text),
                          onTapOutside: (event) =>
                              _autoSaveProcessField('wip', _wipController.text),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _uptimeController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d*')),
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Uptime (%)',
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                            isDense: true,
                            suffixText: '%',
                          ),
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              final uptime = double.tryParse(value);
                              if (uptime == null ||
                                  uptime < 0 ||
                                  uptime > 100) {
                                return 'Must be between 0 and 100';
                              }
                            }
                            return null;
                          },
                          onFieldSubmitted: (value) =>
                              _autoSaveProcessField('uptime', value),
                          onEditingComplete: () =>
                              _autoSaveProcessField('uptime', _uptimeController.text),
                          onTapOutside: (event) =>
                              _autoSaveProcessField('uptime', _uptimeController.text),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _coTimeController,
                          decoration: const InputDecoration(
                            labelText: 'Changeover Time (HH:MM:SS)',
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                            isDense: true,
                            hintText: '01:30:00',
                          ),
                          validator: _validateTimeFormat,
                          onFieldSubmitted: (value) =>
                              _autoSaveProcessField('coTime', value),
                          onEditingComplete: () =>
                              _autoSaveProcessField('coTime', _coTimeController.text),
                          onTapOutside: (event) =>
                              _autoSaveProcessField('coTime', _coTimeController.text),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Daily Demand, Days/Week, Hours/Day, and Takt Time as form fields
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _dailyDemandController,
                          enabled: false,
                          decoration: const InputDecoration(
                            labelText: 'Daily Demand',
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Color(0xFFF5F5F5),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          initialValue: '${_calculateWorkingDaysPerWeek()}',
                          enabled: false,
                          decoration: const InputDecoration(
                            labelText: 'Days/Wk',
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Color(0xFFF5F5F5),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          initialValue: _formatHoursToHHMMSS(
                              _calculateAverageHoursPerWorkingDay()),
                          enabled: false,
                          decoration: const InputDecoration(
                            labelText: 'Hrs/Day',
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Color(0xFFF5F5F5),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _taktTimeController,
                          enabled: false,
                          decoration: const InputDecoration(
                            labelText: 'Takt Time',
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Color(0xFFF5F5F5),
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Process Shifts Card
        _buildProcessShiftsCard(),
      ],
    );
  }

  Widget _buildProcessShiftsCard() {
    return Card(
      color: Colors.yellow[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row with button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _selectedProcess != null
                        ? '${_selectedProcess!.processName} Weekly Schedule (days and hours)'
                        : 'Weekly Schedule (days and hours)',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: _selectedProcess != null
                      ? _showProcessShiftsDialog
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Text('Modify Shift(s)'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_processShifts.isEmpty)
              const Center(
                child: Text(
                  'Loading shifts...',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              )
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 16,
                  headingRowColor: MaterialStateProperty.all(Colors.blue[50]),
                  columns: const [
                    DataColumn(
                      label: Text(
                        'Shift Name',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Sunday',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Monday',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Tuesday',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Wednesday',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Thursday',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Friday',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Saturday',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                  rows: _processShifts.map((shift) {
                    return DataRow(
                      cells: [
                        DataCell(
                          Text(
                            shift.shiftName,
                            style: TextStyle(
                              fontWeight: shift.shiftName == 'TBD'
                                  ? FontWeight.w500
                                  : FontWeight.normal,
                              color: shift.shiftName == 'TBD'
                                  ? Colors.orange[700]
                                  : null,
                            ),
                          ),
                        ),
                        DataCell(Text(shift.sun ?? '-')),
                        DataCell(Text(shift.mon ?? '-')),
                        DataCell(Text(shift.tue ?? '-')),
                        DataCell(Text(shift.wed ?? '-')),
                        DataCell(Text(shift.thu ?? '-')),
                        DataCell(Text(shift.fri ?? '-')),
                        DataCell(Text(shift.sat ?? '-')),
                      ],
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Show Process Shifts modification dialog
  void _showProcessShiftsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ProcessShiftsDialog(
          processId: _selectedProcess!.id,
          processName: _selectedProcess!.processName,
          valueStreamId: widget.valueStreamId,
          onShiftsChanged: () async {
            // Reload the shifts after changes
            await _loadProcessShifts();
            // Update takt time since shifts affect the calculation
            await _autoSaveTaktTime();
          },
        );
      },
    );
  }

  Widget _buildAssignedPartsSection() {
    return Card(
      color: Colors.yellow[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Assigned Parts',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _assignedParts.isEmpty
                ? const Expanded(
                    child: Center(
                      child: Text('No parts assigned to this process.'),
                    ),
                  )
                : Expanded(
                    child: ListView.builder(
                      itemCount: _assignedParts.length,
                      itemBuilder: (context, index) {
                        final part = _assignedParts[index];
                        return Card(
                          color: Colors.yellow[100],
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            title: Text(part.partNumber),
                            subtitle:
                                Text(part.partDescription ?? 'No description'),
                            trailing: IconButton(
                              icon: const Icon(Icons.remove_circle,
                                  color: Colors.red),
                              onPressed: () => _unassignPartFromProcess(part),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailablePartsSection() {
    return Card(
      color: Colors.yellow[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Available Parts',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _filteredAvailableParts.isEmpty
                ? const Expanded(
                    child: Center(
                      child: Text('No parts available to assign.'),
                    ),
                  )
                : Expanded(
                    child: ListView.builder(
                      itemCount: _filteredAvailableParts.length,
                      itemBuilder: (context, index) {
                        final part = _filteredAvailableParts[index];
                        return Card(
                          color: Colors.yellow[100],
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            title: Text(part.partNumber),
                            subtitle:
                                Text(part.partDescription ?? 'No description'),
                            trailing: IconButton(
                              icon: const Icon(Icons.add_circle,
                                  color: Colors.green),
                              onPressed: () => _assignPartToProcess(part),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  //endregion

  //region Database Operations

  //endregion
}

// Process Shifts Dialog for modifying process shifts
class ProcessShiftsDialog extends StatefulWidget {
  final int processId;
  final String processName;
  final int valueStreamId;
  final VoidCallback onShiftsChanged;

  const ProcessShiftsDialog({
    super.key,
    required this.processId,
    required this.processName,
    required this.valueStreamId,
    required this.onShiftsChanged,
  });

  @override
  State<ProcessShiftsDialog> createState() => _ProcessShiftsDialogState();
}

class _ProcessShiftsDialogState extends State<ProcessShiftsDialog> {
  late AppDatabase db;
  List<ProcessShiftData> _processShifts = [];

  // Controllers for each shift row (indexed by shift ID, or negative for new rows)
  final Map<int, Map<String, TextEditingController>> _rowControllers = {};
  int _newRowCounter = -1; // Use negative IDs for new rows

  // State variables for Copy Value Stream Shifts functionality
  bool _hasVSShifts = false;
  bool _isCopying = false;

  @override
  void initState() {
    super.initState();
    DatabaseProvider.getInstance().then((database) {
      db = database;
      _loadProcessShifts();
    });
  }

  @override
  void dispose() {
    // Dispose all controllers
    for (var rowControllers in _rowControllers.values) {
      for (var controller in rowControllers.values) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  Future<void> _loadProcessShifts() async {
    setState(() {});

    try {
      final shifts = await db.getProcessShifts(widget.processId);

      // Check if VSShifts exist for this value stream
      final vsShifts = await (db.select(db.vSShifts)
            ..where((vs) => vs.vsId.equals(widget.valueStreamId)))
          .get();

      // Clear existing controllers
      for (var rowControllers in _rowControllers.values) {
        for (var controller in rowControllers.values) {
          controller.dispose();
        }
      }
      _rowControllers.clear();

      // Create controllers for each existing shift
      for (var shift in shifts) {
        _rowControllers[shift.id] = {
          'shiftName': TextEditingController(text: shift.shiftName),
          'sun': TextEditingController(text: shift.sun ?? ''),
          'mon': TextEditingController(text: shift.mon ?? ''),
          'tue': TextEditingController(text: shift.tue ?? ''),
          'wed': TextEditingController(text: shift.wed ?? ''),
          'thu': TextEditingController(text: shift.thu ?? ''),
          'fri': TextEditingController(text: shift.fri ?? ''),
          'sat': TextEditingController(text: shift.sat ?? ''),
        };
      }

      setState(() {
        _processShifts = shifts;
        _hasVSShifts = vsShifts.isNotEmpty;
      });
    } catch (e) {
      debugPrint('Error loading process shifts: $e');
      setState(() {
        _hasVSShifts = false;
      });
    }
  }

  void _addNewShift() {
    setState(() {
      // Create a new row with empty controllers
      _rowControllers[_newRowCounter] = {
        'shiftName': TextEditingController(),
        'sun': TextEditingController(),
        'mon': TextEditingController(),
        'tue': TextEditingController(),
        'wed': TextEditingController(),
        'thu': TextEditingController(),
        'fri': TextEditingController(),
        'sat': TextEditingController(),
      };
      _newRowCounter--; // Decrement for next new row
    });
  }

  Future<void> _copyValueStreamShifts() async {
    if (!_hasVSShifts) return;

    setState(() {
      _isCopying = true;
    });

    try {
      // First, delete all existing ProcessShift records for this process
      await (db.delete(db.processShift)
            ..where((ps) => ps.processId.equals(widget.processId)))
          .go();

      // Call the database method to copy VSShifts to ProcessShift
      await db.copyVSShiftsToProcessShift(
          widget.valueStreamId, widget.processId);

      // Reload the shifts to show the copied data
      await _loadProcessShifts();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Value stream shifts copied successfully')),
        );
      }
    } catch (e) {
      debugPrint('Error copying value stream shifts: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error copying shifts: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCopying = false;
        });
      }
    }
  }

  Widget _buildEditableTable() {
    // Combine existing shifts with new rows
    List<Widget> tableRows = [];

    // Add existing shifts
    for (var shift in _processShifts) {
      tableRows.add(_buildEditableRow(shift.id, shift));
    }

    // Add new rows
    for (var entry in _rowControllers.entries) {
      if (entry.key < 0) {
        // New rows have negative IDs
        tableRows.add(_buildEditableRow(entry.key, null));
      }
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: const Row(
              children: [
                Expanded(
                    flex: 2,
                    child: Text('Shift Name',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    child: Text('Sun',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    child: Text('Mon',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    child: Text('Tue',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    child: Text('Wed',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    child: Text('Thu',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    child: Text('Fri',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    child: Text('Sat',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                SizedBox(
                    width: 100,
                    child: Text('Actions',
                        style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
          ),
          // Data rows
          ...tableRows,
        ],
      ),
    );
  }

  Widget _buildEditableRow(int shiftId, ProcessShiftData? shift) {
    final controllers = _rowControllers[shiftId];
    if (controllers == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          // Shift Name
          Expanded(
            flex: 2,
            child: TextFormField(
              controller: controllers['shiftName']!,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding: EdgeInsets.all(8),
                filled: true,
                fillColor: Colors.white,
              ),
              style: TextStyle(
                fontWeight: shift?.shiftName == 'TBD'
                    ? FontWeight.w500
                    : FontWeight.normal,
                color: shift?.shiftName == 'TBD' ? Colors.orange[700] : null,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Days
          Expanded(
            child: TextFormField(
              controller: controllers['sun']!,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding: EdgeInsets.all(8),
                hintText: '08:00:00',
                filled: true,
                fillColor: Colors.white,
              ),
              validator: _validateTimeFormat,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              controller: controllers['mon']!,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding: EdgeInsets.all(8),
                hintText: '08:00:00',
                filled: true,
                fillColor: Colors.white,
              ),
              validator: _validateTimeFormat,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              controller: controllers['tue']!,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding: EdgeInsets.all(8),
                hintText: '08:00:00',
                filled: true,
                fillColor: Colors.white,
              ),
              validator: _validateTimeFormat,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              controller: controllers['wed']!,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding: EdgeInsets.all(8),
                hintText: '08:00:00',
                filled: true,
                fillColor: Colors.white,
              ),
              validator: _validateTimeFormat,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              controller: controllers['thu']!,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding: EdgeInsets.all(8),
                hintText: '08:00:00',
                filled: true,
                fillColor: Colors.white,
              ),
              validator: _validateTimeFormat,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              controller: controllers['fri']!,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding: EdgeInsets.all(8),
                hintText: '08:00:00',
                filled: true,
                fillColor: Colors.white,
              ),
              validator: _validateTimeFormat,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              controller: controllers['sat']!,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding: EdgeInsets.all(8),
                hintText: '08:00:00',
                filled: true,
                fillColor: Colors.white,
              ),
              validator: _validateTimeFormat,
            ),
          ),
          const SizedBox(width: 8),
          // Actions
          SizedBox(
            width: 100,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () => _saveShift(shiftId),
                  icon: const Icon(Icons.save, size: 16, color: Colors.green),
                  tooltip: 'Save',
                ),
                if (shift != null)
                  IconButton(
                    onPressed: () => _deleteShift(shift),
                    icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                    tooltip: 'Delete',
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveShift(int shiftId) async {
    final controllers = _rowControllers[shiftId];
    if (controllers == null) return;

    final shiftName = controllers['shiftName']!.text.trim();
    if (shiftName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a shift name')),
      );
      return;
    }

    try {
      if (shiftId < 0) {
        // Add new shift
        await db.into(db.processShift).insert(ProcessShiftCompanion.insert(
              processId: widget.processId,
              shiftName: shiftName,
              sun: drift.Value(controllers['sun']!.text.trim().isEmpty
                  ? null
                  : controllers['sun']!.text.trim()),
              mon: drift.Value(controllers['mon']!.text.trim().isEmpty
                  ? null
                  : controllers['mon']!.text.trim()),
              tue: drift.Value(controllers['tue']!.text.trim().isEmpty
                  ? null
                  : controllers['tue']!.text.trim()),
              wed: drift.Value(controllers['wed']!.text.trim().isEmpty
                  ? null
                  : controllers['wed']!.text.trim()),
              thu: drift.Value(controllers['thu']!.text.trim().isEmpty
                  ? null
                  : controllers['thu']!.text.trim()),
              fri: drift.Value(controllers['fri']!.text.trim().isEmpty
                  ? null
                  : controllers['fri']!.text.trim()),
              sat: drift.Value(controllers['sat']!.text.trim().isEmpty
                  ? null
                  : controllers['sat']!.text.trim()),
            ));

        // Remove the temporary row
        _rowControllers.remove(shiftId);
      } else {
        // Update existing shift
        await (db.update(db.processShift)..where((ps) => ps.id.equals(shiftId)))
            .write(ProcessShiftCompanion(
          shiftName: drift.Value(shiftName),
          sun: drift.Value(controllers['sun']!.text.trim().isEmpty
              ? null
              : controllers['sun']!.text.trim()),
          mon: drift.Value(controllers['mon']!.text.trim().isEmpty
              ? null
              : controllers['mon']!.text.trim()),
          tue: drift.Value(controllers['tue']!.text.trim().isEmpty
              ? null
              : controllers['tue']!.text.trim()),
          wed: drift.Value(controllers['wed']!.text.trim().isEmpty
              ? null
              : controllers['wed']!.text.trim()),
          thu: drift.Value(controllers['thu']!.text.trim().isEmpty
              ? null
              : controllers['thu']!.text.trim()),
          fri: drift.Value(controllers['fri']!.text.trim().isEmpty
              ? null
              : controllers['fri']!.text.trim()),
          sat: drift.Value(controllers['sat']!.text.trim().isEmpty
              ? null
              : controllers['sat']!.text.trim()),
        ));
      }

      await _loadProcessShifts();
      widget.onShiftsChanged();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(shiftId < 0
                  ? 'Shift added successfully'
                  : 'Shift updated successfully')),
        );
      }
    } catch (e) {
      debugPrint('Error saving shift: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error saving shift')),
        );
      }
    }
  }

  Future<void> _deleteShift(ProcessShiftData shift) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Shift'),
        content: Text(
            'Are you sure you want to delete the "${shift.shiftName}" shift?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await (db.delete(db.processShift)
              ..where((ps) => ps.id.equals(shift.id)))
            .go();
        await _loadProcessShifts();
        widget.onShiftsChanged();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Shift deleted successfully')),
          );
        }
      } catch (e) {
        debugPrint('Error deleting shift: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error deleting shift')),
          );
        }
      }
    }
  }

  String? _validateTimeFormat(String? value) {
    if (value == null || value.isEmpty) return null;

    final timeRegex = RegExp(r'^\d{1,2}:\d{2}:\d{2}$');
    if (!timeRegex.hasMatch(value)) {
      return 'Format: HH:MM:SS';
    }

    final parts = value.split(':');
    final hours = int.tryParse(parts[0]);
    final minutes = int.tryParse(parts[1]);
    final seconds = int.tryParse(parts[2]);

    if (hours == null ||
        minutes == null ||
        seconds == null ||
        hours >= 24 ||
        minutes >= 60 ||
        seconds >= 60) {
      return 'Invalid time';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.4,
        decoration: BoxDecoration(
          color: Colors.yellow[50],
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${widget.processName} - Process Shifts',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _hasVSShifts && !_isCopying
                          ? _copyValueStreamShifts
                          : null,
                      icon: _isCopying
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.copy),
                      label: Text(_isCopying
                          ? 'Copying...'
                          : 'Copy Value Stream Shifts'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _hasVSShifts ? Colors.green[600] : Colors.grey[400],
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _addNewShift,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Shift'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 16),

            // Editable Shifts Table
            Expanded(
              child: _buildEditableTable(),
            ),
          ],
        ),
      ),
    );
  }
}
