import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/organization_setup_screen.dart';
import '../screens/plant_setup_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  void _showPartSetupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Part Number Setup'),
          content: const Text(
            'To access Part Number Setup, please first select a Company, Plant, and Value Stream from the Home screen.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Go to Home'),
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                );
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            },
            child: DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: Row(
                children: [
                  Image.asset(
                    'assets/images/calx_logo.png',
                    height: 60,
                    width: 60,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Calx LLC Industrial Tools',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            },
          ),
          ExpansionTile(
            leading: const Icon(Icons.business),
            title: const Text('Organizational Setup'),
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.account_tree),
                title: const Text('Organization Setup'),
                contentPadding: const EdgeInsets.only(left: 72.0, right: 16.0),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const OrganizationSetupScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.location_city),
                title: const Text('Plant & Value Stream Setup'),
                contentPadding: const EdgeInsets.only(left: 72.0, right: 16.0),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PlantSetupScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.precision_manufacturing),
                title: const Text('Part Number Setup'),
                contentPadding: const EdgeInsets.only(left: 72.0, right: 16.0),
                onTap: () {
                  Navigator.pop(context); // Close the drawer first
                  _showPartSetupDialog(context);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
