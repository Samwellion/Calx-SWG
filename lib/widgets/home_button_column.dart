import 'package:flutter/material.dart';

class HomeButtonColumn extends StatelessWidget {
  final VoidCallback onSetupOrg;
  final VoidCallback onLoadOrg;
  final VoidCallback onOpenObs;
  final VoidCallback onAddPartNumber;
  final VoidCallback onAddVSProcess;
  final bool enableAddPartNumber;
  const HomeButtonColumn({
    super.key,
    required this.onSetupOrg,
    required this.onLoadOrg,
    required this.onOpenObs,
    required this.onAddPartNumber,
    required this.onAddVSProcess,
    required this.enableAddPartNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHomeButton(label: 'Setup Organization', onPressed: onSetupOrg),
        const SizedBox(height: 20),
        _buildHomeButton(
          label: 'Add Part Number',
          onPressed: enableAddPartNumber ? onAddPartNumber : null,
        ),
        const SizedBox(height: 20),
        _buildHomeButton(
          label: 'Add VS Process',
          onPressed: enableAddPartNumber ? onAddVSProcess : null,
        ),
        const SizedBox(height: 20),
        _buildHomeButton(label: 'Open Time Observation', onPressed: onOpenObs),
      ],
    );
  }

  Widget _buildHomeButton(
      {required String label, required VoidCallback? onPressed}) {
    return SizedBox(
      width: 320,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.yellow[300],
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 8,
        ),
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}
