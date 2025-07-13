import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/header_text_box.dart';
import '../control_buttons.dart';
import '../time_observation_table.dart';
import '../logic/simple_stopwatch.dart';
import '../database_provider.dart';
import 'package:drift/drift.dart' as drift;

// Ensure that organization_data.dart defines a class OrganizationData with a static member companyName.
// If not, define it below as a fallback.
class OrganizationData {
  static String companyName = '';
}

// If TimerDisplay is not defined elsewhere, define it here as a stateless widget.
class TimerDisplay extends StatelessWidget {
  final Duration elapsed;
  final Duration lapTime;

  const TimerDisplay({super.key, required this.elapsed, required this.lapTime});

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
          style: const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        if (lapTime > Duration.zero)
          Text(
            "Lap: ${_formatDuration(lapTime)}",
            style: const TextStyle(
              fontSize: 20,
              color: Colors.grey,
            ),
          ),
      ],
    );
  }
}

class StopwatchApp extends StatefulWidget {
  final String companyName;
  final String plantName;
  final String valueStreamName;
  final String processName;
  final String? initialPartNumber;
  final List<String>? initialElements;
  const StopwatchApp({
    super.key,
    required this.companyName,
    required this.plantName,
    required this.valueStreamName,
    required this.processName,
    this.initialPartNumber,
    this.initialElements,
  });

  @override
  State<StopwatchApp> createState() => _StopwatchAppState();
}

class _StopwatchAppState extends State<StopwatchApp> {
  final TextEditingController _observerNameController = TextEditingController();
  String get companyName => widget.companyName;
  String get plantName => widget.plantName;
  String get valueStreamName => widget.valueStreamName;
  String get processName => widget.processName;
  final SimpleStopwatch _simpleStopwatch = SimpleStopwatch();
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  Duration _lapTime = Duration.zero;
  final GlobalKey<TimeObservationTableState> _tableKey =
      GlobalKey<TimeObservationTableState>();
  bool _hasStarted = false;
  bool get _isInitial =>
      !_hasStarted && !_simpleStopwatch.isRunning && _elapsed == Duration.zero;

  List<Map<String, dynamic>> _parts = [];
  String? _selectedPartNumber;
  bool _loadingParts = true;
  String? _partsError;

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
        if (_parts.isNotEmpty) {
          _selectedPartNumber = _parts[0]['part_number'];
        }
        _loadingParts = false;
      });
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
    }
  }

  void _stop() {
    if (_simpleStopwatch.isRunning) {
      _simpleStopwatch.stop();
      _tableKey.currentState?.unhideOvrdColumn();
    }
  }

  void _reset() {
    _simpleStopwatch.reset();
    setState(() {
      _elapsed = Duration.zero;
      _lapTime = Duration.zero;
      _hasStarted = false;
    });
    _tableKey.currentState?.clearTimeColumns();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[100],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Persistent top container for timer and buttons (original header)
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
                    // Left: Timer and controls
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TimerDisplay(elapsed: _elapsed, lapTime: _lapTime),
                          const SizedBox(height: 8),
                          ControlButtons(
                            onStart: _start,
                            onStop: _stop,
                            onReset: _reset,
                            onMarkLap: _markLap,
                            running: _simpleStopwatch.isRunning,
                            isInitial: _isInitial,
                          ),
                        ],
                      ),
                    ),
                    // Right: Company/Plant/Value Stream and Part dropdown
                    Padding(
                      padding: const EdgeInsets.only(left: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              HeaderTextBox(
                                  label: 'Company', value: companyName),
                              const SizedBox(width: 8),
                              HeaderTextBox(label: 'Plant', value: plantName),
                              const SizedBox(width: 8),
                              HeaderTextBox(
                                  label: 'Value Stream',
                                  value: valueStreamName),
                              const SizedBox(width: 8),
                              HeaderTextBox(
                                  label: 'Process', value: processName),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (_loadingParts)
                            const Center(child: CircularProgressIndicator())
                          else if (_partsError != null)
                            Text(_partsError!,
                                style: const TextStyle(color: Colors.red))
                          else if (_parts.isNotEmpty)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('Part: ',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                DropdownButton<String>(
                                  value: _selectedPartNumber,
                                  items: _parts.map((part) {
                                    final partNum = part['part_number'] ?? '';
                                    final desc = part['part_description'] ?? '';
                                    return DropdownMenuItem<String>(
                                      value: partNum,
                                      child: Row(
                                        children: [
                                          Text(partNum,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          if (desc.isNotEmpty) ...[
                                            const SizedBox(width: 12),
                                            Text(desc,
                                                style: const TextStyle(
                                                    color: Colors.black54)),
                                          ]
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedPartNumber = value;
                                      // Optionally, you can use selected['part_description'] here if needed
                                    });
                                  },
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left side: Observer Name above the table
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Observer Name',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(
                                  width: 240,
                                  child: TextField(
                                    controller: _observerNameController,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(child: TimeObservationTable(key: _tableKey)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Footer container with back and save button
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.yellow[100],
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
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
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Back to Home'),
                    ),
                    ElevatedButton(
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
                      onPressed: () {
                        // TODO: Implement save logic for time observation
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Time observation data saved!'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
