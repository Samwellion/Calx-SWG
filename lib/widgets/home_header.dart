import 'package:flutter/material.dart';
// Removed import of organization_setup_screen.dart since OrganizationData is undefined

class HomeHeader extends StatelessWidget {
  final String? companyName;
  final String? plantName;
  final String? valueStreamName;
  const HomeHeader(
      {super.key, this.companyName, this.plantName, this.valueStreamName});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
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
          Image.asset(
            'assets/images/calx_logo.png',
            height: 56,
            width: 56,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Standard Work Generator by Calx',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ),
          // Text boxes for company, plant, value stream
          if ((companyName?.isNotEmpty ?? false) ||
              (plantName?.isNotEmpty ?? false) ||
              (valueStreamName?.isNotEmpty ?? false))
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _HeaderTextBox(label: 'Company', value: companyName),
                  const SizedBox(width: 8),
                  _HeaderTextBox(label: 'Plant', value: plantName),
                  const SizedBox(width: 8),
                  _HeaderTextBox(label: 'Value Stream', value: valueStreamName),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _HeaderTextBox extends StatelessWidget {
  final String label;
  final String? value;
  const _HeaderTextBox({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 80, maxWidth: 160),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.yellow[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.yellow[700]!, width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 12, color: Colors.black54)),
          Text(value ?? '',
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
