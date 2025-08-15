import 'package:flutter/material.dart';

class PlantValueStreamHelpPopup extends StatelessWidget {
  const PlantValueStreamHelpPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Plant & Value Stream Setup Guide'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'How to set up plants and value streams:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text('1. Plant Details:'),
            Padding(
              padding: EdgeInsets.only(left: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• Enter the plant location details'),
                  Text('• Add address information'),
                  Text('• Include any plant-specific notes'),
                ],
              ),
            ),
            SizedBox(height: 12),
            Text('2. Value Streams:'),
            Padding(
              padding: EdgeInsets.only(left: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• Create new value streams'),
                  Text('• Name them clearly and consistently'),
                  Text('• Associate them with the correct plant'),
                ],
              ),
            ),
            SizedBox(height: 12),
            Text('3. Managing Setup:'),
            Padding(
              padding: EdgeInsets.only(left: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• Review plant and value stream configurations'),
                  Text('• Update information as needed'),
                  Text('• Ensure all required fields are complete'),
                ],
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Note: Clear organization of value streams helps with process management.',
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
