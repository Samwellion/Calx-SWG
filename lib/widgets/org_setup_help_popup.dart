import 'package:flutter/material.dart';

class OrgSetupHelpPopup extends StatelessWidget {
  const OrgSetupHelpPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Organization Setup Guide'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'How to set up your organization:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text('1. Adding a Company:'),
            Padding(
              padding: EdgeInsets.only(left: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• Enter your company name in the left input field'),
                  Text('• Click "Add" or press Enter'),
                  Text('• Your company will appear in the list below'),
                ],
              ),
            ),
            SizedBox(height: 12),
            Text('2. Adding Plants:'),
            Padding(
              padding: EdgeInsets.only(left: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• Select your company from the list'),
                  Text('• Enter a plant name in the right input field'),
                  Text('• Click "Add" or press Enter'),
                  Text('• Your plant will appear in the list below'),
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
                  Text('• Select a plant from the list'),
                  Text('• Click "Plant Setup" to configure plant details'),
                ],
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Note: You can delete companies or plants using the red delete buttons next to each item.',
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
