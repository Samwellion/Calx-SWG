import 'package:flutter/material.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.yellow[200],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.yellow[300],
              foregroundColor: Colors.black,
              elevation: 6,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              textStyle:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.home, size: 28),
            label: const Text('Home',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
          const Spacer(),
          const Text(
            '© 2025 Standard Work Generator App',
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
