import 'package:flutter/material.dart';

class ErrorHandler {
  /// Shows a user-friendly error dialog for database constraint violations
  static void showConstraintErrorDialog(BuildContext context, dynamic error) {
    String title = 'Error';
    String message = 'An unexpected error occurred.';

    if (error.toString().contains('UNIQUE constraint failed')) {
      final errorString = error.toString();

      if (errorString
          .contains('processes.value_stream_id, processes.process_name')) {
        title = 'Duplicate Process';
        message =
            'A process with this name already exists in the selected value stream. Please choose a different name.';
      } else if (errorString
          .contains('parts.organization_id, parts.part_number')) {
        title = 'Duplicate Part Number';
        message =
            'A part with this number already exists in the selected company. Please choose a different part number.';
      } else if (errorString.contains('organizations.organization_name')) {
        title = 'Duplicate Company';
        message =
            'A company with this name already exists. Please choose a different name.';
      } else if (errorString
          .contains('plants.organization_id, plants.plant_name')) {
        title = 'Duplicate Plant';
        message =
            'A plant with this name already exists in the selected company. Please choose a different name.';
      } else if (errorString.contains(
          'value_streams.plant_id, value_streams.value_stream_name')) {
        title = 'Duplicate Value Stream';
        message =
            'A value stream with this name already exists in the selected plant. Please choose a different name.';
      } else {
        title = 'Duplicate Entry';
        message =
            'This entry already exists. Please choose a different name or number.';
      }
    } else if (error.toString().contains('FOREIGN KEY constraint failed')) {
      title = 'Invalid Reference';
      message =
          'The selected reference is no longer valid. Please refresh the page and try again.';
    } else {
      // For any other database or general errors
      message = 'An error occurred while saving. Please try again.';
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.error, color: Colors.red),
              const SizedBox(width: 8),
              Text(title),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  /// Shows a success snackbar
  static void showSuccessSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
