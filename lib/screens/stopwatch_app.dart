import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/stopwatch_header.dart';
import '../widgets/stopwatch_footer.dart';
import '../../time_observation_table.dart';
// import '../../organization_setup_screen.dart';
import '../logic/simple_stopwatch.dart';

class StopwatchApp extends StatefulWidget {
  const StopwatchApp({super.key});

  @override
  State<StopwatchApp> createState() => _StopwatchAppState();
}

class _StopwatchAppState extends State<StopwatchApp> {
  final SimpleStopwatch _simpleStopwatch = SimpleStopwatch();
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  Duration _lapTime = Duration.zero;
  final GlobalKey<TimeObservationTableState> _tableKey =
      GlobalKey<TimeObservationTableState>();
  bool _hasStarted = false;
  bool get _isInitial =>
      !_hasStarted && !_simpleStopwatch.isRunning && _elapsed == Duration.zero;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 30), (_) {
      setState(() {
        _elapsed = _simpleStopwatch.elapsed;
      });
    });
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
      _tableKey.currentState?.enterLowestRepeatedIntoTimeColumn();
      _tableKey.currentState?.unhideOvrdColumn();
      _tableKey.currentState
          ?.showFooterLowestRepeatables(); // Show lowest repeatable in footer
      // Removed call to undefined showFooterTotalLapLowestRepeatable
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
              // Header
              StopwatchHeader(
                elapsed: _elapsed,
                lapTime: _lapTime,
                onStart: _start,
                onStop: _stop,
                onReset: _reset,
                onMarkLap: _markLap,
                running: _simpleStopwatch.isRunning,
                isInitial: _isInitial,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: TimeObservationTable(key: _tableKey),
                    ),
                  ],
                ),
              ),
              // Footer
              StopwatchFooter(
                onBack: () {
                  Navigator.of(context).pop();
                },
                onSave: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Time observation data saved!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
