import 'package:flutter/material.dart';

class SelectionDisplayCard extends StatelessWidget {
  final String companyName;
  final String plantName;
  final String valueStreamName;

  const SelectionDisplayCard({
    super.key,
    required this.companyName,
    required this.plantName,
    required this.valueStreamName,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.yellow[50],
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Current Selections',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Company:', companyName),
            const SizedBox(height: 8),
            _buildInfoRow('Plant:', plantName),
            const SizedBox(height: 8),
            _buildInfoRow('Value Stream:', valueStreamName),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
              color: Colors.black87,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
