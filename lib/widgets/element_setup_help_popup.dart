import 'package:flutter/material.dart';

class ElementSetupHelpPopup extends StatelessWidget {
  const ElementSetupHelpPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Element Setup Guide'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'How to set up process elements:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text('1. Adding Elements:'),
            Padding(
              padding: EdgeInsets.only(left: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• Enter the element name'),
                  Text('• Provide a clear description'),
                  Text('• Specify any special conditions'),
                ],
              ),
            ),
            SizedBox(height: 12),
            Text('2. Element Configuration:'),
            Padding(
              padding: EdgeInsets.only(left: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• Set the element sequence'),
                  Text('• Define time standards if applicable'),
                  Text('• Add any related notes'),
                ],
              ),
            ),
            SizedBox(height: 12),
            Text('3. Managing Elements:'),
            Padding(
              padding: EdgeInsets.only(left: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• Review element details'),
                  Text('• Edit or update existing elements'),
                  Text('• Remove unnecessary elements'),
                ],
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Note: Elements should be specific, measurable, and clearly defined.',
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
