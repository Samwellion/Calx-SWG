import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/organization_setup_screen.dart';
import '../screens/plant_setup_screen.dart';

class AppMenuBar extends StatelessWidget implements PreferredSizeWidget {
  const AppMenuBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          Image.asset(
            'assets/images/calx_logo.png',
            height: 40,
            width: 40,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 10),
          const Text('Calx Time Observation'),
        ],
      ),
      backgroundColor: Colors.yellow[300],
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
              (Route<dynamic> route) => false,
            );
          },
          child: const Text('Home', style: TextStyle(color: Colors.black)),
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const OrganizationSetupScreen()),
            );
          },
          child: const Text('Organization Setup',
              style: TextStyle(color: Colors.black)),
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PlantSetupScreen()),
            );
          },
          child:
              const Text('Plant Setup', style: TextStyle(color: Colors.black)),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
