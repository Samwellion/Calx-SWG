import 'package:flutter/material.dart';

class HelpPopup extends StatelessWidget {
  const HelpPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Welcome to Calx-SWG!'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Here\'s how to get started:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text('1. First, set up your organization using the "Setup Organization" button'),
            SizedBox(height: 8),
            Text('2. Add plants to your organization using "Load Organization"'),
            SizedBox(height: 8),
            Text('3. Use the dropdowns to select your:'),
            Padding(
              padding: EdgeInsets.only(left: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• Company'),
                  Text('• Plant'),
                  Text('• Value Stream'),
                  Text('• Process'),
                ],
              ),
            ),
            SizedBox(height: 8),
            Text('4. Add parts and elements to start recording time observations'),
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
