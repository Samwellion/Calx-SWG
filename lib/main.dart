// main.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'timer_display.dart';
import 'control_buttons.dart';
import 'time_observation_table.dart';
import 'simple_stopwatch.dart';
import 'organization_setup_screen.dart'; // Import the new screen

void main() {
  runApp(const MaterialApp(
    home: HomeScreen(),
  ));
}

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final companyName = OrganizationData.companyName;
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
              'Standard Work Generator by Calx',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                companyName.isNotEmpty ? companyName : '',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HomeFooter extends StatelessWidget {
  const HomeFooter({super.key});

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
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: const Center(
        child: Text(
          '© 2025 Standard Work Generator App',
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
      ),
    );
  }
}

class HomeButtonColumn extends StatelessWidget {
  final VoidCallback onSetupOrg;
  final VoidCallback onLoadOrg;
  final VoidCallback onOpenObs;
  const HomeButtonColumn({
    super.key,
    required this.onSetupOrg,
    required this.onLoadOrg,
    required this.onOpenObs,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHomeButton(label: 'Setup Organization', onPressed: onSetupOrg),
        const SizedBox(height: 20),
        _buildHomeButton(label: 'Load Organization', onPressed: onLoadOrg),
        const SizedBox(height: 20),
        _buildHomeButton(label: 'Open Time Observation', onPressed: onOpenObs),
      ],
    );
  }

  Widget _buildHomeButton(
      {required String label, required VoidCallback onPressed}) {
    return SizedBox(
      width: 320,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.yellow[300],
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 8,
        ),
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}

class HomeRightBox extends StatelessWidget {
  const HomeRightBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      margin: const EdgeInsets.only(left: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.yellow[300]!, width: 2),
      ),
      child: const Center(
        child: Text(
          'Welcome!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[100],
      body: Column(
        children: [
          const HomeHeader(),
          Expanded(
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.yellow[100],
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HomeButtonColumn(
                      onSetupOrg: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const OrganizationSetupScreen(),
                          ),
                        );
                        setState(() {});
                      },
                      onLoadOrg: () {},
                      onOpenObs: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const StopwatchApp(),
                          ),
                        );
                      },
                    ),
                    const HomeRightBox(),
                  ],
                ),
              ),
            ),
          ),
          const HomeFooter(),
        ],
      ),
    );
  }
}

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
      _tableKey.currentState?.unhideOvrdColumn(); // Unhide the OVRD column when stopped
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
              // Persistent top container for timer and buttons
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.yellow[100],
                  borderRadius: BorderRadius.circular(12),
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
                    if (OrganizationData.companyName.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 24.0),
                        child: Text(
                          OrganizationData.companyName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
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
                    Expanded(
                      flex: 3,
                      child: TimeObservationTable(key: _tableKey),
                    ),
                  ],
                ),
              ),
              // Footer container with back and save button
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.yellow[100],
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
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
