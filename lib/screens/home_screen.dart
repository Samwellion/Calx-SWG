import 'package:flutter/material.dart';
import '../widgets/home_header.dart';
import '../widgets/home_footer.dart';
import '../screens/organization_setup_screen.dart';
import '../screens/plant_setup_screen.dart';
import 'stopwatch_app.dart';

class HomeButtonColumn extends StatelessWidget {
  final VoidCallback onSetupOrg;
  final VoidCallback onOpenObs;

  const HomeButtonColumn({
    super.key,
    required this.onSetupOrg,
    required this.onOpenObs,
  });

  @override
  Widget build(BuildContext context) {
    const double buttonWidth = 260;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: buttonWidth,
          child: ElevatedButton(
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
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: buttonWidth,
          child: ElevatedButton(
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
        ),
      ],
    );
  }
}

class HomeDropdownsColumn extends StatelessWidget {
  final String? orgCompany;
  final List<String> orgCompanies;
  final ValueChanged<String?> onCompanyChanged;
  final String? selectedPlant;
  final List<String> orgPlants;
  final ValueChanged<String?> onPlantChanged;
  final String? selectedValueStream;
  final List<String> valueStreams;
  final ValueChanged<String?> onValueStreamChanged;

  const HomeDropdownsColumn({
    super.key,
    required this.orgCompany,
    required this.orgCompanies,
    required this.onCompanyChanged,
    required this.selectedPlant,
    required this.orgPlants,
    required this.onPlantChanged,
    required this.selectedValueStream,
    required this.valueStreams,
    required this.onValueStreamChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400, // Width for the dropdowns container
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.yellow[300]!, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(
                width: 100, // Adjust width as needed for labels
                child: Text('Company',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              const SizedBox(width: 16), // Increased spacing from 8
              Expanded(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: orgCompany,
                  hint: const Text('Select Company',
                      style: TextStyle(fontSize: 18)),
                  items: orgCompanies
                      .map((c) => DropdownMenuItem(
                          value: c,
                          child: Text(c, style: TextStyle(fontSize: 18))))
                      .toList(),
                  onChanged: onCompanyChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const SizedBox(
                width: 100, // Adjust width as needed for labels
                child: Text('Plant',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              const SizedBox(width: 16), // Increased spacing from 8
              Expanded(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: selectedPlant,
                  hint: const Text('Select Plant',
                      style: TextStyle(fontSize: 18)),
                  items: orgPlants
                      .map((p) => DropdownMenuItem(
                          value: p,
                          child: Text(p, style: TextStyle(fontSize: 18))))
                      .toList(),
                  onChanged: onPlantChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const SizedBox(
                width: 100, // Adjust width as needed for labels
                child: Text('Value Stream',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              const SizedBox(width: 16), // Increased spacing from 8
              Expanded(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: selectedValueStream,
                  hint: const Text('Select Value Stream',
                      style: TextStyle(fontSize: 18)),
                  items: valueStreams
                      .map((v) => DropdownMenuItem(
                          value: v,
                          child: Text(v, style: TextStyle(fontSize: 18))))
                      .toList(),
                  onChanged: onValueStreamChanged,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? selectedCompany;
  String? selectedPlant;
  String? selectedValueStream;

  @override
  Widget build(BuildContext context) {
    // Use all available company names from OrganizationData
    final List<String> orgCompanies = OrganizationData.companyNames ?? (OrganizationData.companyName.isNotEmpty ? [OrganizationData.companyName] : []);
    final String? orgCompany = selectedCompany ?? (orgCompanies.isNotEmpty ? orgCompanies.first : null);
    final List<String> orgPlants = orgCompany != null && OrganizationData.companyPlants != null && OrganizationData.companyPlants[orgCompany] != null
        ? OrganizationData.companyPlants[orgCompany]!
        : <String>[];
    final List<String> valueStreams = (selectedPlant != null && plantValueStreams[selectedPlant!] != null)
        ? plantValueStreams[selectedPlant!]!
        : <String>[];
    return Scaffold(
      backgroundColor: Colors.yellow[100],
      body: Column(
        children: [
          const HomeHeader(),
          Expanded(
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.yellow[50],
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Left column: Buttons
                    HomeButtonColumn(
                      onSetupOrg: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const OrganizationSetupScreen(),
                          ),
                        );
                        setState(() {});
                      },
                      onOpenObs: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const StopwatchApp(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 32),
                    // Right column: Dropdowns - Replaced with HomeDropdownsColumn
                    HomeDropdownsColumn(
                      orgCompany: orgCompany,
                      orgCompanies: orgCompanies,
                      onCompanyChanged: (val) => setState(() {
                        selectedCompany = val;
                        selectedPlant = null;
                        selectedValueStream = null;
                      }),
                      selectedPlant: selectedPlant,
                      orgPlants: orgPlants,
                      onPlantChanged: (val) {
                        setState(() {
                          selectedPlant = val;
                          selectedValueStream = null;
                        });
                      },
                      selectedValueStream: selectedValueStream,
                      valueStreams:
                          valueStreams, // This is derived in the build method
                      onValueStreamChanged: (val) {
                        setState(() {
                          selectedValueStream = val;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          const HomeFooter(),
        ],
      ),
    );
  }
}
