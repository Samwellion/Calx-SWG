import 'package:flutter/material.dart';

class PartInputHelpPopup extends StatelessWidget {
  const PartInputHelpPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Part Input Guide'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'How to add and manage parts:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text('1. Adding a Part:'),
            Padding(
              padding: EdgeInsets.only(left: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• Enter the part number in the input field'),
                  Text('• Add a description if needed'),
                  Text('• Click "Save Part" or press Enter'),
                  Text('• The part will appear in the list below'),
                ],
              ),
            ),
            SizedBox(height: 12),
            Text('2. Managing Parts:'),
            Padding(
              padding: EdgeInsets.only(left: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• View all parts in the list'),
                  Text('• Edit part descriptions using the edit button'),
                  Text('• Save changes after editing'),
                  Text('• Remove parts using the delete button'),
                ],
              ),
            ),
            SizedBox(height: 12),
            Text('3. Next Steps:'),
            Padding(
              padding: EdgeInsets.only(left: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• Return to process setup to assign parts'),
                  Text('• Set up elements for each part'),
                ],
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Note: Part numbers must be unique within a value stream.',
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
