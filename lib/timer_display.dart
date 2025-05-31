import 'package:flutter/material.dart';

class TimerDisplay extends StatelessWidget {
  final Duration elapsed;
  final Duration lapTime;
  const TimerDisplay({super.key, required this.elapsed, required this.lapTime});

  @override
  Widget build(BuildContext context) {
    String format(Duration d) => d.toString().split('.').first.padLeft(8, '0');
    return Column(
      children: [
        Text(
          format(elapsed),
          style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
        ),
        if (lapTime > Duration.zero)
          Text(
            '+${format(lapTime)}',
            style: const TextStyle(fontSize: 24, color: Colors.black54),
          ),
      ],
    );
  }
}
