import 'package:flutter/material.dart';

class ProcessSetupHelpPopup extends StatelessWidget {
  const ProcessSetupHelpPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Process Setup Guide'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'How to set up a process:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text('1. Process Information:'),
            Padding(
              padding: EdgeInsets.only(left: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• Enter the process name'),
                  Text('• Verify the value stream information'),
                  Text('• Add any process description or notes'),
                ],
              ),
            ),
            SizedBox(height: 12),
            Text('2. Process Elements:'),
            Padding(
              padding: EdgeInsets.only(left: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• Add all steps in the process'),
                  Text('• Specify the sequence of operations'),
                  Text('• Include any special requirements'),
                ],
              ),
            ),
            SizedBox(height: 12),
            Text('3. Saving the Process:'),
            Padding(
              padding: EdgeInsets.only(left: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• Review all process details'),
                  Text('• Ensure all required fields are filled'),
                  Text('• Save the process configuration'),
                ],
              ),
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
