// control_buttons.dart
import 'package:flutter/material.dart';

class ControlButtons extends StatelessWidget {
  final VoidCallback onStart;
  final VoidCallback onStop;
  final VoidCallback onReset;
  final VoidCallback onMarkLap;
  final bool running;
  final bool isInitial;
  const ControlButtons({
    super.key,
    required this.onStart,
    required this.onStop,
    required this.onReset,
    required this.onMarkLap,
    required this.running,
    required this.isInitial,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: isInitial
              ? onStart
              : running
                  ? onMarkLap
                  : onReset,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.yellow[300],
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            textStyle:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 6,
          ),
          child: Text(isInitial
              ? 'Start'
              : running
                  ? 'Mark Lap'
                  : 'Reset'),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: running ? onStop : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.yellow[300],
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            textStyle:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 6,
          ),
          child: const Text('Stop'),
        ),
      ],
    );
  }
}
