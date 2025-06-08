import 'package:flutter/material.dart';
import '../widgets/home_header.dart';
import '../widgets/home_footer.dart';
import 'organization_setup_screen.dart';
import 'stopwatch_app.dart';

class HomeButtonColumn extends StatelessWidget {
  final VoidCallback onSetupOrg;
  final VoidCallback onLoadOrg;
  final VoidCallback onOpenObs;

  const HomeButtonColumn({
    super.key,
    required this.onSetupOrg,
    required this.onLoadOrg,
    required this.onOpenObs,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          onPressed: onSetupOrg,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.yellow[300],
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            textStyle:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 6,
          ),
          child: const Text('Setup Organization'),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: onLoadOrg,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.yellow[300],
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            textStyle:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 6,
          ),
          child: const Text('Load Organization'),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: onOpenObs,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.yellow[300],
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            textStyle:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 6,
          ),
          child: const Text('Open Time Observation'),
        ),
      ],
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Set the background color to Colors.yellow[200]
      backgroundColor: Colors.yellow[100],
      body: Column(
        children: [
          const HomeHeader(),
          Expanded(
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  HomeButtonColumn(
                    onSetupOrg: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const OrganizationSetupScreen(),
                        ),
                      );
                      setState(() {});
                    },
                    onLoadOrg: () {
                      // Implement load organization logic here
                    },
                    onOpenObs: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const StopwatchApp(),
                        ),
                      );
                    },
                  ),
                  // Add any right-side widgets here if needed
                ],
              ),
            ),
          ),
          const HomeFooter(),
        ],
      ),
    );
  }
}
