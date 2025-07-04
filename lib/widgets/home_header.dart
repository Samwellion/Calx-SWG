import 'package:flutter/material.dart';
// Removed import of organization_setup_screen.dart since OrganizationData is undefined

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final companyName = ''; // TODO: Replace with actual company name source
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
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
          if (companyName.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Text(
                companyName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
