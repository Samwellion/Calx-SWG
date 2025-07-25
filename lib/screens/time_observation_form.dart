import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/detailed_selection_display_card.dart';
import '../control_buttons.dart';
import '../logic/simple_stopwatch.dart';
import '../database_provider.dart';
import 'package:drift/drift.dart' as drift;
import '../widgets/app_drawer.dart';
import '../widgets/app_footer.dart';
import '../time_observation_table.dart';
import '../logic/app_database.dart';

// Ensure that organization_data.dart defines a class OrganizationData with a static member companyName.
// If not, define it below as a fallback.
class OrganizationData {
  static String companyName = '';
}

// If TimerDisplay is not defined elsewhere, define it here as a stateless widget.
class TimerDisplay extends StatelessWidget {
  final Duration elapsed;
  final Duration lapTime;
  final bool isCompact;

  const TimerDisplay({
    super.key,
    required this.elapsed,
    required this.lapTime,
    this.isCompact = false,
  });

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    final milliseconds =
        (d.inMilliseconds.remainder(1000) ~/ 10).toString().padLeft(2, '0');
    return "$minutes:$seconds.$milliseconds";
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          _formatDuration(elapsed),
          style: TextStyle(
            fontSize: isCompact ? 36 : 48, // Smaller font when compact
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        if (lapTime > Duration.zero)
          Text(
            "Lap: ${_formatDuration(lapTime)}",
            style: TextStyle(
              fontSize: isCompact ? 16 : 20, // Smaller font when compact
              color: Colors.grey,
            ),
          ),
      ],
    );
  }
}

class TimeObservationForm extends StatefulWidget {
  final String companyName;
  final String plantName;
  final String valueStreamName;
  final String processName;
  final String? initialPartNumber;
  final List<String>? initialElements;
  const TimeObservationForm({
    super.key,
    required this.companyName,
    required this.plantName,
    required this.valueStreamName,
    required this.processName,
    this.initialPartNumber,
    this.initialElements,
  });

  @override
  State<TimeObservationForm> createState() => _TimeObservationFormState();
}

class _TimeObservationFormState extends State<TimeObservationForm> {
  final TextEditingController _observerNameController = TextEditingController();
  final GlobalKey<TimeObservationTableState> _tableKey =
      GlobalKey<TimeObservationTableState>();
  String get companyName => widget.companyName;
  String get plantName => widget.plantName;
  String get valueStreamName => widget.valueStreamName;
  String get processName => widget.processName;
  final SimpleStopwatch _simpleStopwatch = SimpleStopwatch();
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  Duration _lapTime = Duration.zero;
  bool _hasStarted = false;
  bool _hasStopped = false; // Track if timer has been stopped
  bool get _isInitial =>
      !_hasStarted && !_simpleStopwatch.isRunning && _elapsed == Duration.zero;

  List<Map<String, dynamic>> _parts = [];
  String? _selectedPartNumber;
  bool _loadingParts = true;
  String? _partsError;
  String? _currentSetupName;

  @override
  void initState() {
    super.initState();
    _selectedPartNumber = widget.initialPartNumber;
    _timer = Timer.periodic(const Duration(milliseconds: 30), (_) {
      setState(() {
        _elapsed = _simpleStopwatch.elapsed;
      });
    });
    _loadParts();

    // Load setup name if we have an initial part number
    if (widget.initialPartNumber != null) {
      _loadSetupName();
    }

    // If initialElements are provided, load them into the table
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialElements != null && _tableKey.currentState != null) {
        _tableKey.currentState!.setElements(widget.initialElements!);
      }
    });
  }

  Future<void> _loadParts() async {
    setState(() {
      _loadingParts = true;
      _partsError = null;
    });
    try {
      final db = await DatabaseProvider.getInstance();
      final result = await db.customSelect(
        'SELECT id, part_number, part_description FROM parts WHERE value_stream_id = ?',
        variables: [drift.Variable.withInt(await _getValueStreamId())],
      ).get();
      setState(() {
        _parts = result.map((row) => row.data).toList();
        if (_parts.isNotEmpty && _selectedPartNumber == null) {
          _selectedPartNumber = _parts[0]['part_number'];
        }
        _loadingParts = false;
      });

      // Load setup name after parts are loaded
      await _loadSetupName();
    } catch (e) {
      setState(() {
        _partsError = 'Failed to load parts: $e';
        _loadingParts = false;
      });
    }
  }

  Future<int> _getValueStreamId() async {
    // This assumes valueStreamName is unique for the plant; adjust as needed
    final db = await DatabaseProvider.getInstance();
    final valueStreams = await db.customSelect(
      'SELECT id FROM value_streams WHERE name = ?',
      variables: [drift.Variable.withString(widget.valueStreamName)],
    ).get();
    if (valueStreams.isNotEmpty) {
      return valueStreams.first.data['id'] as int;
    }
    return -1;
  }

  Future<void> _loadSetupName() async {
    if (_selectedPartNumber == null) {
      setState(() {
        _currentSetupName = null;
      });
      return;
    }

    try {
      final db = await DatabaseProvider.getInstance();

      // Query to get the setup name based on process and part
      final result = await db.customSelect(
        '''
        SELECT s.setup_name 
        FROM setups s
        JOIN process_parts pp ON s.process_part_id = pp.id
        JOIN processes p ON pp.process_id = p.id
        WHERE p.process_name = ? AND pp.part_number = ?
        LIMIT 1
        ''',
        variables: [
          drift.Variable.withString(widget.processName),
          drift.Variable.withString(_selectedPartNumber!),
        ],
      ).get();

      setState(() {
        if (result.isNotEmpty) {
          _currentSetupName = result.first.data['setup_name'] as String?;
        } else {
          // Fallback to "Standard" if no setup is found
          _currentSetupName = 'Standard';
        }
      });
    } catch (e) {
      setState(() {
        _currentSetupName = 'Standard'; // Fallback
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _start() {
    if (!_simpleStopwatch.isRunning) {
      _simpleStopwatch.start();
      setState(() {
        _lapTime = Duration.zero;
        _hasStarted = true;
      });
      _tableKey.currentState?.hideRowsWithoutElement();
      _tableKey.currentState
          ?.showTotalRow(); // Show the total row when starting
    }
  }

  void _stop() {
    if (_simpleStopwatch.isRunning) {
      _simpleStopwatch.stop();
      setState(() {
        _hasStopped = true; // Enable save button when stopped
      });
      _tableKey.currentState?.unhideOvrdColumn();
      // Automatically evaluate and display lowest repeated times
      _tableKey.currentState?.showFooterLowestRepeatables();
      // Enable editing of lowest repeatable cells
      _tableKey.currentState?.enableLowestRepeatableEditing();
    }
  }

  void _resetToPreStart() {
    // Reset table to pre-start condition (after stop has been pressed)
    _simpleStopwatch.reset();
    setState(() {
      _elapsed = Duration.zero;
      _lapTime = Duration.zero;
      _hasStarted = false;
      _hasStopped = false; // Reset stopped flag
    });
    _tableKey.currentState?.clearTimeColumns(); // Clear lap times
    _tableKey.currentState?.hideTotalRow(); // Hide the total row
    _tableKey.currentState
        ?.disableLowestRepeatableEditing(); // Disable editing when reset
    // Note: Additional methods like clearComments, hideFooterLowestRepeatables, etc.
    // would need to be implemented in TimeObservationTableState if they don't exist
  }

  // Save observed times to database
  Future<void> _saveObservedTimes() async {
    try {
      if (_selectedPartNumber == null) {
        throw Exception('No part number selected');
      }

      final tableState = _tableKey.currentState;
      if (tableState == null) {
        throw Exception('Table state not available');
      }

      final completeTableData = tableState.getCompleteTableData();
      if (completeTableData.isEmpty) {
        throw Exception('No observed times data to save');
      }

      final db = await DatabaseProvider.getInstance();

      // Get the process and part information
      final process = await (db.select(db.processes)
            ..where((p) => p.processName.equals(widget.processName)))
          .getSingleOrNull();
      if (process == null) {
        throw Exception('Process not found');
      }

      final processPart = await (db.select(db.processParts)
            ..where((pp) =>
                pp.processId.equals(process.id) &
                pp.partNumber.equals(_selectedPartNumber!)))
          .getSingleOrNull();
      if (processPart == null) {
        throw Exception('Process part not found');
      }

      // Get the setup for this process part
      final setup = await (db.select(db.setups)
            ..where((s) => s.processPartId.equals(processPart.id)))
          .getSingleOrNull();
      if (setup == null) {
        throw Exception('Setup not found for this process part');
      }

      // Create a new Study record
      final now = DateTime.now();
      final studyId = await db.insertStudy(StudyCompanion.insert(
        setupId: setup.id,
        date: now,
        time: now,
        observerName: _observerNameController.text.trim(),
      ));

      int totalTimeRecords = 0;

      // Process each element's data
      for (final data in completeTableData) {
        final elementName = data['elementName'] as String;
        final observedTime = data['observedTime'] as String;
        final times = data['times'] as List<String>;
        final comments = data['comments'] as String?;
        final lowestRepeatableTime = data['lowestRepeatableTime'] as String?;
        final overrideTime = data['overrideTime'] as String?;

        // Find the setup element by process part ID and element name
        final setupElement = await (db.select(db.setupElements)
              ..where((se) =>
                  se.processPartId.equals(processPart.id) &
                  se.elementName.equals(elementName)))
            .getSingleOrNull();

        if (setupElement != null) {
          // Parse current time and new observed time for comparison
          final currentTime = setupElement.time;
          bool shouldUpdate = false;

          if (currentTime.isEmpty || currentTime == '00:00:00') {
            // Update if current time is zero or empty
            shouldUpdate = true;
          } else {
            // Parse times to compare (assuming HH:MM:SS format)
            final currentDuration = _parseTimeString(currentTime);
            final newDuration = _parseTimeString(observedTime);

            // Update if new time is less than current time
            if (newDuration != null &&
                currentDuration != null &&
                newDuration < currentDuration) {
              shouldUpdate = true;
            }
          }

          if (shouldUpdate) {
            await (db.update(db.setupElements)
                  ..where((se) => se.id.equals(setupElement.id)))
                .write(SetupElementsCompanion(
              time: drift.Value(observedTime),
            ));
          }
        }

        // Create TaskStudy record for this element
        await db.insertTaskStudy(TaskStudyCompanion.insert(
          studyId: studyId,
          taskName: elementName,
          lrt: lowestRepeatableTime ?? 'N/A',
          overrideTime: drift.Value(overrideTime),
          comments: drift.Value(comments),
        ));

        // Create TimeStudy records for each lap time
        for (final lapTime in times) {
          await db.insertTimeStudy(TimeStudyCompanion.insert(
            studyId: studyId,
            taskName: elementName,
            iterationTime: lapTime,
          ));
          totalTimeRecords++;
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Saved study with ${completeTableData.length} elements and created $totalTimeRecords time records'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving observed times: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _markLap() {
    final previousLap = _lapTime;
    final current = _simpleStopwatch.elapsed;
    final diff = current - previousLap;
    setState(() {
      _lapTime = current;
    });
    _tableKey.currentState?.insertTime(diff);
  }

  // Helper method to parse time string in HH:MM:SS format to Duration
  Duration? _parseTimeString(String timeString) {
    try {
      final parts = timeString.split(':');
      if (parts.length == 3) {
        final hours = int.parse(parts[0]);
        final minutes = int.parse(parts[1]);
        final seconds = int.parse(parts[2]);
        return Duration(hours: hours, minutes: minutes, seconds: seconds);
      }
    } catch (e) {
      // Return null if parsing fails
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final observerNameNotEmpty = _observerNameController.text.trim().isNotEmpty;

    // Detect keyboard visibility
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardVisible = keyboardHeight > 0;

    return GestureDetector(
      onTap: () {
        // Dismiss keyboard when tapping outside text fields
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Time Observation'),
          backgroundColor: Colors.white,
        ),
        drawer: const AppDrawer(),
        backgroundColor: Colors.yellow[100],
        resizeToAvoidBottomInset: true, // Enable keyboard avoidance
        body: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom -
                    kToolbarHeight, // AppBar height
              ),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Persistent top container for timer and buttons (original header)
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                            vertical: isKeyboardVisible
                                ? 8
                                : 12, // Reduce padding when keyboard visible
                            horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.yellow[100],
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left: Part number and Observer Name
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Part number at top left
                                if (_selectedPartNumber != null) ...[
                                  Row(
                                    children: [
                                      const Text('Part: ',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16)),
                                      Text(_selectedPartNumber!,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                ],
                                // Observer Name below part number
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Observer Name',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      constraints: const BoxConstraints(
                                        maxWidth: 300,
                                        minWidth: 200,
                                      ),
                                      child: TextField(
                                        controller: _observerNameController,
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          isDense: true,
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 8, horizontal: 12),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(width: 24),
                            // Timer and buttons side by side, aligned to top
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TimerDisplay(
                                  elapsed: _elapsed,
                                  lapTime: _lapTime,
                                  isCompact: isKeyboardVisible,
                                ),
                                const SizedBox(width: 16), // Normal spacing
                                ControlButtons(
                                  onStart: observerNameNotEmpty ? _start : null,
                                  onStop: _stop,
                                  onReset: _resetToPreStart,
                                  onMarkLap: _markLap,
                                  onSave: _saveObservedTimes,
                                  running: _simpleStopwatch.isRunning,
                                  isInitial: _isInitial,
                                  hasStopped: _hasStopped,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Flexible(
                        child: Container(
                          constraints: BoxConstraints(
                            minHeight: isKeyboardVisible
                                ? 200
                                : 400, // Reduce height when keyboard is visible
                            maxHeight: isKeyboardVisible
                                ? MediaQuery.of(context).size.height * 0.3
                                : // 30% when keyboard visible
                                MediaQuery.of(context).size.height *
                                    0.6, // 60% when keyboard hidden
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Left side: Observer Name above the table
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: TimeObservationTable(
                                        key: _tableKey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Footer using AppFooter widget
                      const AppFooter(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return Dialog(
                  child: Container(
                    constraints: const BoxConstraints(
                      maxWidth: 500,
                      maxHeight: 350,
                    ),
                    child: DetailedSelectionDisplayCard(
                      companyName: widget.companyName,
                      plantName: widget.plantName,
                      valueStreamName: widget.valueStreamName,
                      processName: widget.processName,
                      partNumber: _selectedPartNumber,
                      setupName: _currentSetupName ?? 'Standard',
                    ),
                  ),
                );
              },
            );
          },
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          child: const Icon(Icons.info),
        ),
      ),
    );
  }
}
