import 'package:flutter/material.dart';

class TimeObservationHelpPopup extends StatelessWidget {
  const TimeObservationHelpPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Time Observation Guide'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'How to record time observations:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text('1. Basic Information:'),
            Padding(
              padding: EdgeInsets.only(left: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• Verify the company, plant, and process information'),
                  Text('• Enter the observer\'s name'),
                  Text('• Select the date and time of observation'),
                ],
              ),
            ),
            SizedBox(height: 12),
            Text('2. Recording Elements:'),
            Padding(
              padding: EdgeInsets.only(left: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• Use the timer controls for each element'),
                  Text('• Start/stop timing for each process element'),
                  Text('• Add any relevant notes or observations'),
                ],
              ),
            ),
            SizedBox(height: 12),
            Text('3. Completing the Observation:'),
            Padding(
              padding: EdgeInsets.only(left: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• Review all recorded times'),
                  Text('• Add any final comments'),
                  Text('• Submit the observation'),
                ],
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Note: Make sure to complete timing all elements before submitting.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Got it!'),
        ),
      ],
    );
  }
}
