import 'package:flutter/material.dart';
import '../../timer_display.dart';
import '../../control_buttons.dart';
import '../../models/organization_data.dart';

class StopwatchHeader extends StatelessWidget {
  final Duration elapsed;
  final Duration lapTime;
  final VoidCallback onStart;
  final VoidCallback onStop;
  final VoidCallback onReset;
  final VoidCallback onMarkLap;
  final bool running;
  final bool isInitial;

  const StopwatchHeader({
    super.key,
    required this.elapsed,
    required this.lapTime,
    required this.onStart,
    required this.onStop,
    required this.onReset,
    required this.onMarkLap,
    required this.running,
    required this.isInitial,
  });

  @override
  Widget build(BuildContext context) {
    String? selectedPlant = OrganizationData.plants.isNotEmpty
        ? OrganizationData.plants.first.name
        : null;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TimerDisplay(elapsed: elapsed, lapTime: lapTime),
                const SizedBox(height: 8),
                ControlButtons(
                  onStart: onStart,
                  onStop: onStop,
                  onReset: onReset,
                  onMarkLap: onMarkLap,
                  running: running,
                  isInitial: isInitial,
                ),
              ],
            ),
          ),
          if (OrganizationData.companyName.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
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
                if (OrganizationData.plants.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, left: 24.0),
                    child: StatefulBuilder(
                      builder: (context, setState) => DropdownButton<String>(
                        value: selectedPlant,
                        items: OrganizationData.plants
                            .map((plant) => DropdownMenuItem<String>(
                                  value: plant.name,
                                  child: Text(plant.name),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedPlant = value;
                          });
                        },
                        hint: const Text('Select Plant'),
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
