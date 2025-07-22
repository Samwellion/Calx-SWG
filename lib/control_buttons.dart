// control_buttons.dart
import 'package:flutter/material.dart';

class ControlButtons extends StatelessWidget {
  final VoidCallback? onStart;
  final VoidCallback onStop;
  final VoidCallback onReset;
  final VoidCallback onMarkLap;
  final VoidCallback? onSave;
  final bool running;
  final bool isInitial;
  final bool hasStopped;
  const ControlButtons({
    super.key,
    required this.onStart,
    required this.onStop,
    required this.onReset,
    required this.onMarkLap,
    this.onSave,
    required this.running,
    required this.isInitial,
    this.hasStopped = false,
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
                  : hasStopped
                      ? null // Disable when stopped until reset is pressed
                      : onReset,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.yellow[300],
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            textStyle:
                const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 6,
          ),
          child: Text(
            isInitial
                ? 'Start'
                : running
                    ? 'Mark Lap'
                    : 'Start/Lap',
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: running ? onStop : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.yellow[300],
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            textStyle:
                const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 6,
          ),
          child: const Text('Stop'),
        ),
        if (hasStopped) ...[
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: onReset,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange[300],
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              textStyle:
                  const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 6,
            ),
            child: const Text('Reset'),
          ),
        ],
        if (onSave != null) ...[
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: hasStopped ? onSave : null,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  hasStopped ? Colors.yellow[300] : Colors.grey[300],
              foregroundColor: hasStopped ? Colors.black : Colors.grey[600],
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              textStyle:
                  const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: hasStopped ? 6 : 2,
            ),
            child: const Text('Save'),
          ),
        ],
      ],
    );
  }
}
