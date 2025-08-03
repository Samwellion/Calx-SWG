import 'package:flutter/material.dart';
import 'package:drift/drift.dart' hide Column;
import '../widgets/app_footer.dart';
import '../widgets/app_drawer.dart';
import '../widgets/home_button_wrapper.dart';
import '../logic/app_database.dart';
import '../database_provider.dart';

class ProcessCapacityScreen extends StatefulWidget {
  final int processId;
  final String processName;
  final int valueStreamId;

  const ProcessCapacityScreen({
    super.key,
    required this.processId,
    required this.processName,
    required this.valueStreamId,
  });

  @override
  State<ProcessCapacityScreen> createState() => _ProcessCapacityScreenState();
}

class _ProcessCapacityScreenState extends State<ProcessCapacityScreen> {
  late AppDatabase db;
  bool _loading = true;
  String? _error;
  ProcessesData? _process;
  String? _averageDailyRunTime;
  String? _effectiveRunTime;
  List<Map<String, dynamic>> _processParts = [];

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    try {
      db = await DatabaseProvider.getInstance();
      await _loadProcessData();
    } catch (e) {
      setState(() {
        _error = 'Database initialization failed: $e';
        _loading = false;
      });
    }
  }

  Future<void> _loadProcessData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // Load the process data
      final processQuery = db.select(db.processes)
        ..where((p) => p.id.equals(widget.processId));

      final processes = await processQuery.get();

      if (processes.isNotEmpty) {
        _process = processes.first;

        // Calculate average daily run time from shift data
        await _calculateAverageDailyRunTime();

        // Load process parts data
        await _loadProcessParts();
      } else {
        throw Exception('Process not found');
      }

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

  Future<void> _calculateAverageDailyRunTime() async {
    try {
      // Get shift data for this process
      final shiftQuery = db.select(db.processShift)
        ..where((s) => s.processId.equals(widget.processId));

      final shifts = await shiftQuery.get();

      if (shifts.isEmpty) {
        _averageDailyRunTime = 'N/A';
        return;
      }

      List<int> totalMinutes = [];

      // Process each shift
      for (final shift in shifts) {
        final days = [
          shift.sun,
          shift.mon,
          shift.tue,
          shift.wed,
          shift.thu,
          shift.fri,
          shift.sat
        ];

        for (final dayTime in days) {
          if (dayTime != null && dayTime.isNotEmpty) {
            final minutes = _parseTimeToMinutes(dayTime);
            if (minutes > 0) {
              totalMinutes.add(minutes);
            }
          }
        }
      }

      if (totalMinutes.isNotEmpty) {
        final averageMinutes =
            totalMinutes.reduce((a, b) => a + b) / totalMinutes.length;
        _averageDailyRunTime = _formatMinutesToTime(averageMinutes.round());

        // Calculate effective runtime (Average Daily Run Time * Process Uptime)
        _calculateEffectiveRunTime(averageMinutes.round());
      } else {
        _averageDailyRunTime = 'N/A';
        _effectiveRunTime = 'N/A';
      }
    } catch (e) {
      _averageDailyRunTime = 'Error';
      _effectiveRunTime = 'Error';
    }
  }

  int _parseTimeToMinutes(String timeString) {
    try {
      final parts = timeString.split(':');
      if (parts.length >= 2) {
        final hours = int.parse(parts[0]);
        final minutes = int.parse(parts[1]);
        return hours * 60 + minutes;
      }
    } catch (e) {
      // Invalid time format
    }
    return 0;
  }

  String _formatMinutesToTime(int totalMinutes) {
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:00';
  }

  void _calculateEffectiveRunTime(int averageDailyMinutes) {
    try {
      if (_process?.uptime != null && _process!.uptime! > 0) {
        // Calculate effective runtime = Average Daily Run Time * Process Uptime
        final effectiveMinutes =
            (averageDailyMinutes * _process!.uptime!).round();
        _effectiveRunTime = _formatMinutesToTime(effectiveMinutes);
      } else {
        _effectiveRunTime = 'N/A';
      }
    } catch (e) {
      _effectiveRunTime = 'Error';
    }
  }

  Future<void> _loadProcessParts() async {
    try {
      final query = db.select(db.processParts).join([
        leftOuterJoin(
            db.parts, db.parts.partNumber.equalsExp(db.processParts.partNumber))
      ])
        ..where(db.processParts.processId.equals(widget.processId));

      final results = await query.get();

      // Update ProcessParts with daily demand from Parts table (recalculate every time)
      for (final row in results) {
        final processPart = row.readTable(db.processParts);
        final part = row.readTableOrNull(db.parts);

        // Recalculate daily demand whenever we have monthly demand
        if (part?.monthlyDemand != null) {
          final workingDaysPerWeek =
              await _getWorkingDaysPerWeek(processPart.processId);
          if (workingDaysPerWeek > 0) {
            // Daily Demand = Monthly Demand ÷ 4.33 ÷ Working Days per Week
            final weeklyDemand = part!.monthlyDemand! / 4.33;
            final calculatedDailyDemand =
                (weeklyDemand / workingDaysPerWeek).round();
            await (db.update(db.processParts)
                  ..where((pp) => pp.id.equals(processPart.id)))
                .write(ProcessPartsCompanion(
              dailyDemand: Value(calculatedDailyDemand),
            ));
          }
        }
      }

      // Reload data after updates
      final updatedResults = await query.get();

      _processParts = updatedResults.map((row) {
        final processPart = row.readTable(db.processParts);
        final part = row.readTableOrNull(db.parts);

        return {
          'id': processPart.id,
          'partNumber': processPart.partNumber,
          'partDescription': part?.partDescription ?? 'N/A',
          'dailyDemand': processPart.dailyDemand?.toString() ?? 'N/A',
          'processTime': processPart.processTime ?? 'N/A',
          'userOverrideTime': processPart.userOverrideTime ?? '',
          'fpy': processPart.fpy != null
              ? (processPart.fpy! * 100).toStringAsFixed(1)
              : '',
        };
      }).toList();
    } catch (e) {
      _processParts = [];
    }
  }

  Future<int> _getWorkingDaysPerWeek(int processId) async {
    try {
      // Get all shift records for this process
      final shiftQuery = db.select(db.processShift)
        ..where((s) => s.processId.equals(processId));

      final shifts = await shiftQuery.get();

      if (shifts.isEmpty) {
        return 5; // Default to 5 working days if no shift data
      }

      // Count working days across all shifts (a day is working if any shift has > 0 hours)
      Set<String> workingDays = {};

      for (final shift in shifts) {
        final days = [
          ('sun', shift.sun),
          ('mon', shift.mon),
          ('tue', shift.tue),
          ('wed', shift.wed),
          ('thu', shift.thu),
          ('fri', shift.fri),
          ('sat', shift.sat),
        ];

        for (final (dayName, dayTime) in days) {
          if (dayTime != null &&
              dayTime.isNotEmpty &&
              _hasWorkingHours(dayTime)) {
            workingDays.add(dayName);
          }
        }
      }

      return workingDays.isNotEmpty
          ? workingDays.length
          : 5; // Default to 5 if no working days found
    } catch (e) {
      return 5; // Default to 5 working days on error
    }
  }

  bool _hasWorkingHours(String timeString) {
    try {
      final parts = timeString.split(':');
      if (parts.length >= 2) {
        final hours = int.parse(parts[0]);
        final minutes = int.parse(parts[1]);
        return hours > 0 || minutes > 0;
      }
    } catch (e) {
      // Invalid time format
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return HomeButtonWrapper(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Process Capacity Analysis - ${widget.processName}'),
          backgroundColor: Colors.white,
        ),
        drawer: const AppDrawer(),
        backgroundColor: Colors.yellow[100],
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.red[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.red[600],
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _loadProcessData,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      Expanded(child: _buildCapacityAnalysisContent()),
                      const AppFooter(),
                    ],
                  ),
      ),
    );
  }

  Widget _buildCapacityAnalysisContent() {
    if (_process == null) {
      return const Center(child: Text('No process data available'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Process Information',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                  ),
                  const SizedBox(height: 16),
                  // Process Name
                  _buildBasicLabelField('Process Name', _process!.processName),
                  const SizedBox(height: 16),
                  // Process Metrics Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildBasicLabelField(
                          'Daily Demand',
                          _process!.dailyDemand?.toString() ?? 'N/A',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildBasicLabelField(
                          'Average Daily Run Time',
                          _averageDailyRunTime ?? 'N/A',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildBasicLabelField(
                          'Takt Time',
                          _process!.taktTime ?? 'N/A',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildBasicLabelField(
                          'Process Uptime',
                          _process!.uptime != null
                              ? '${(_process!.uptime! * 100).toStringAsFixed(1)}%'
                              : 'N/A',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildBasicLabelField(
                          'Effective RunTime',
                          _effectiveRunTime ?? 'N/A',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildBasicLabelField(
                          'WIP',
                          _process!.wip?.toString() ?? 'N/A',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Process Parts Table
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProcessPartsTable(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicLabelField(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildProcessPartsTable() {
    if (_processParts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        child: const Center(
          child: Text(
            'No parts assigned to this process',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        // Header Row
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          child: const Row(
            children: [
              Expanded(
                  flex: 1,
                  child: Text('Part',
                      style: TextStyle(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.visible,
                      softWrap: true)),
              Expanded(
                  flex: 3,
                  child: Text('Description',
                      style: TextStyle(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.visible,
                      softWrap: true)),
              Expanded(
                  flex: 1,
                  child: Text('Daily Demand',
                      style: TextStyle(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.visible,
                      softWrap: true)),
              Expanded(
                  flex: 1,
                  child: Text('Time Study',
                      style: TextStyle(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.visible,
                      softWrap: true)),
              Expanded(
                  flex: 2,
                  child: Text('Total Process Lead Time',
                      style: TextStyle(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.visible,
                      softWrap: true)),
              Expanded(
                  flex: 2,
                  child: Text('FPY (%)',
                      style: TextStyle(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.visible,
                      softWrap: true)),
              Expanded(
                  flex: 2,
                  child: Text('Process Lead Time / Pc',
                      style: TextStyle(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.visible,
                      softWrap: true)),
              Expanded(
                  flex: 2,
                  child: Text('Cycle Time / PC',
                      style: TextStyle(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.visible,
                      softWrap: true)),
              Expanded(
                  flex: 2,
                  child: Text('Total Daily Run',
                      style: TextStyle(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.visible,
                      softWrap: true)),
            ],
          ),
        ),
        // Data Rows
        ...List.generate(_processParts.length, (index) {
          return _buildEditableRow(index);
        }),
        // Totals Row
        _buildTotalsRow(),
      ],
    );
  }

  Widget _buildEditableRow(int index) {
    final part = _processParts[index];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        color: index % 2 == 0 ? Colors.white : Colors.grey[50],
      ),
      child: Row(
        children: [
          // Part Number (read-only)
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Text(part['partNumber'] ?? ''),
            ),
          ),
          // Description (read-only)
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Text(part['partDescription'] ?? ''),
            ),
          ),
          // Daily Demand (read-only)
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Text(part['dailyDemand'] ?? ''),
            ),
          ),
          // Cycle Time (read-only)
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Text(part['processTime'] ?? ''),
            ),
          ),
          // User Override Time (editable)
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(4),
              child: TextFormField(
                initialValue: part['userOverrideTime'] ?? '',
                decoration: const InputDecoration(
                  hintText: 'HH:MM:SS',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
                style: const TextStyle(fontSize: 12),
                onChanged: (value) {
                  _processParts[index]['userOverrideTime'] = value;
                  _saveProcessPartField(part['id'], 'userOverrideTime', value);
                  setState(() {}); // Refresh calculated values
                },
              ),
            ),
          ),
          // FPY (editable)
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(4),
              child: TextFormField(
                initialValue: part['fpy'] ?? '',
                decoration: const InputDecoration(
                  hintText: '0-100',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
                style: const TextStyle(fontSize: 12),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _processParts[index]['fpy'] = value;
                  _saveProcessPartField(part['id'], 'fpy', value);
                  setState(() {}); // Refresh calculated values
                },
              ),
            ),
          ),
          // Time / Pc (calculated, read-only)
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Text(_calculateTimePerPiece(part)),
            ),
          ),
          // Cycle Time / PC (calculated, read-only)
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Text(_calculateCycleTimePerPC(part)),
            ),
          ),
          // Total Daily Run (calculated, read-only)
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Text(_calculateTotalDailyRun(part)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalsRow() {
    // Calculate totals
    int totalDailyDemand = 0;
    int totalDailyRunSeconds = 0;

    for (final part in _processParts) {
      // Sum daily demand
      final dailyDemandString = part['dailyDemand'];
      if (dailyDemandString != null && dailyDemandString != 'N/A') {
        final dailyDemand = int.tryParse(dailyDemandString);
        if (dailyDemand != null) {
          totalDailyDemand += dailyDemand;
        }
      }

      // Sum total daily run (convert from HH:MM:SS to seconds)
      final totalDailyRunString = _calculateTotalDailyRun(part);
      if (totalDailyRunString != 'N/A' && totalDailyRunString != 'Error') {
        final timeParts = totalDailyRunString.split(':');
        if (timeParts.length == 3) {
          final hours = int.tryParse(timeParts[0]) ?? 0;
          final minutes = int.tryParse(timeParts[1]) ?? 0;
          final seconds = int.tryParse(timeParts[2]) ?? 0;
          totalDailyRunSeconds += (hours * 3600) + (minutes * 60) + seconds;
        }
      }
    }

    // Convert total daily run back to HH:MM:SS
    final totalHours = totalDailyRunSeconds ~/ 3600;
    final totalMinutes = (totalDailyRunSeconds % 3600) ~/ 60;
    final remainingSeconds = totalDailyRunSeconds % 60;
    final totalDailyRunFormatted =
        '${totalHours.toString().padLeft(2, '0')}:${totalMinutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.blue[100],
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
      ),
      child: Row(
        children: [
          // Part (empty for totals)
          const Expanded(
            flex: 1,
            child: Text(
              'TOTAL',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          // Description (empty for totals)
          const Expanded(
            flex: 3,
            child: Text(''),
          ),
          // Daily Demand (total)
          Expanded(
            flex: 1,
            child: Text(
              totalDailyDemand.toString(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          // Time Study (empty for totals)
          const Expanded(
            flex: 1,
            child: Text(''),
          ),
          // Cycle Time (empty for totals)
          const Expanded(
            flex: 2,
            child: Text(''),
          ),
          // FPY (empty for totals)
          const Expanded(
            flex: 2,
            child: Text(''),
          ),
          // Time / Pc (empty for totals)
          const Expanded(
            flex: 2,
            child: Text(''),
          ),
          // Cycle Time / PC (empty for totals)
          const Expanded(
            flex: 2,
            child: Text(''),
          ),
          // Total Daily Run (total)
          Expanded(
            flex: 2,
            child: Text(
              totalDailyRunFormatted,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveProcessPartField(
      int processPartId, String fieldName, String value) async {
    try {
      ProcessPartsCompanion companion;

      if (fieldName == 'userOverrideTime') {
        // Validate time format if not empty
        if (value.isNotEmpty && !_isValidTimeFormat(value)) {
          return; // Don't save invalid time format
        }
        companion = ProcessPartsCompanion(
          userOverrideTime: Value(value.isEmpty ? null : value),
        );
      } else if (fieldName == 'fpy') {
        // Parse FPY percentage and convert to decimal
        if (value.isEmpty) {
          companion = ProcessPartsCompanion(fpy: const Value(null));
        } else {
          final fpyValue = double.tryParse(value);
          if (fpyValue == null || fpyValue < 0 || fpyValue > 100) {
            return; // Don't save invalid FPY value
          }
          companion = ProcessPartsCompanion(
            fpy: Value(fpyValue / 100), // Convert percentage to decimal
          );
        }
      } else {
        return; // Unknown field
      }

      await (db.update(db.processParts)
            ..where((pp) => pp.id.equals(processPartId)))
          .write(companion);
    // ignore: empty_catches
    } catch (e) {
    }
  }

  bool _isValidTimeFormat(String time) {
    final timeRegex = RegExp(r'^\d{1,2}:\d{2}:\d{2}$');
    if (!timeRegex.hasMatch(time)) return false;

    final parts = time.split(':');
    final hours = int.tryParse(parts[0]);
    final minutes = int.tryParse(parts[1]);
    final seconds = int.tryParse(parts[2]);

    return hours != null &&
        minutes != null &&
        seconds != null &&
        hours >= 0 &&
        minutes >= 0 &&
        minutes < 60 &&
        seconds >= 0 &&
        seconds < 60;
  }

  String _calculateCycleTimePerPC(dynamic part) {
    try {
      if (_process?.wip == null || _process!.wip! <= 0) {
        return '00:00:00';
      }

      final timePerPc = _calculateTimePerPiece(part);
      if (timePerPc == '00:00:00') {
        return '00:00:00';
      }

      // Parse time string (HH:MM:SS) to seconds
      final timeParts = timePerPc.split(':');
      if (timeParts.length != 3) return '00:00:00';

      final hours = int.tryParse(timeParts[0]) ?? 0;
      final minutes = int.tryParse(timeParts[1]) ?? 0;
      final seconds = int.tryParse(timeParts[2]) ?? 0;

      final totalSeconds = hours * 3600 + minutes * 60 + seconds;

      // Divide by WIP
      final resultSeconds = totalSeconds / _process!.wip!;

      // Convert back to HH:MM:SS format
      final resultHours = (resultSeconds / 3600).floor();
      final resultMinutes = ((resultSeconds % 3600) / 60).floor();
      final remainingSeconds = (resultSeconds % 60).floor();

      return '${resultHours.toString().padLeft(2, '0')}:${resultMinutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
    } catch (e) {
      return '00:00:00';
    }
  }

  String _calculateTimePerPiece(Map<String, dynamic> part) {
    try {
      // Get cycle time (from userOverrideTime field, or processTime if override is empty)
      String? timeString = part['userOverrideTime'];
      if (timeString == null || timeString.isEmpty) {
        timeString = part['processTime'];
      }

      // Get FPY as decimal
      String? fpyString = part['fpy'];

      if (timeString == null ||
          timeString.isEmpty ||
          timeString == 'N/A' ||
          fpyString == null ||
          fpyString.isEmpty) {
        return 'N/A';
      }

      // Parse cycle time to total seconds
      final timeParts = timeString.split(':');
      if (timeParts.length != 3) return 'N/A';

      final hours = int.tryParse(timeParts[0]) ?? 0;
      final minutes = int.tryParse(timeParts[1]) ?? 0;
      final seconds = int.tryParse(timeParts[2]) ?? 0;
      final totalSeconds = (hours * 3600) + (minutes * 60) + seconds;

      // Parse FPY percentage and convert to decimal
      final fpyPercent = double.tryParse(fpyString);
      if (fpyPercent == null || fpyPercent <= 0) return 'N/A';
      final fpyDecimal = fpyPercent / 100;

      // Calculate time per piece: cycle time / FPY
      final timePerPieceSeconds = (totalSeconds / fpyDecimal).round();

      // Convert back to HH:MM:SS format
      final resultHours = timePerPieceSeconds ~/ 3600;
      final resultMinutes = (timePerPieceSeconds % 3600) ~/ 60;
      final resultSeconds = timePerPieceSeconds % 60;

      return '${resultHours.toString().padLeft(2, '0')}:${resultMinutes.toString().padLeft(2, '0')}:${resultSeconds.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Error';
    }
  }

  String _calculateTotalDailyRun(Map<String, dynamic> part) {
    try {
      // Get daily demand
      String? dailyDemandString = part['dailyDemand'];
      if (dailyDemandString == null ||
          dailyDemandString.isEmpty ||
          dailyDemandString == 'N/A') {
        return 'N/A';
      }

      final dailyDemand = int.tryParse(dailyDemandString);
      if (dailyDemand == null || dailyDemand <= 0) {
        return 'N/A';
      }

      // Get cycle time per PC
      String cycleTimePerPC = _calculateCycleTimePerPC(part);
      if (cycleTimePerPC == 'N/A' || cycleTimePerPC == 'Error') {
        return 'N/A';
      }

      // Parse cycle time per PC to total seconds
      final timeParts = cycleTimePerPC.split(':');
      if (timeParts.length != 3) return 'Error';

      final hours = int.tryParse(timeParts[0]) ?? 0;
      final minutes = int.tryParse(timeParts[1]) ?? 0;
      final seconds = int.tryParse(timeParts[2]) ?? 0;
      final cycleTimePerPCSeconds = (hours * 3600) + (minutes * 60) + seconds;

      // Calculate total daily run: daily demand × cycle time per PC
      final totalDailyRunSeconds = dailyDemand * cycleTimePerPCSeconds;

      // Convert back to HH:MM:SS format
      final resultHours = totalDailyRunSeconds ~/ 3600;
      final resultMinutes = (totalDailyRunSeconds % 3600) ~/ 60;
      final resultSecondsRemainder = totalDailyRunSeconds % 60;

      return '${resultHours.toString().padLeft(2, '0')}:${resultMinutes.toString().padLeft(2, '0')}:${resultSecondsRemainder.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Error';
    }
  }
}
