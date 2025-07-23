import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/home_screen.dart';
import '../screens/organization_setup_screen.dart';
import '../screens/plant_setup_screen.dart';
import '../screens/elements_input_screen.dart';
import '../screens/time_observation_form.dart';
import '../screens/setup_element_viewer.dart';
import '../screens/task_study_viewer.dart';
import '../screens/time_study_viewer.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  static const _kCompanyKey = 'selectedCompany';
  static const _kPlantKey = 'selectedPlant';
  static const _kValueStreamKey = 'selectedValueStream';
  static const _kProcessKey = 'selectedProcess';

  String? selectedCompany;
  String? selectedPlant;
  String? selectedValueStream;
  String? selectedProcess;

  @override
  void initState() {
    super.initState();
    _loadSelections();
  }

  Future<void> _loadSelections() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      final c = prefs.getString(_kCompanyKey);
      selectedCompany = (c != null && c.isNotEmpty) ? c : null;
      final p = prefs.getString(_kPlantKey);
      selectedPlant = (p != null && p.isNotEmpty) ? p : null;
      final vs = prefs.getString(_kValueStreamKey);
      selectedValueStream = (vs != null && vs.isNotEmpty) ? vs : null;
      final proc = prefs.getString(_kProcessKey);
      selectedProcess = (proc != null && proc.isNotEmpty) ? proc : null;
    });
  }

  bool get hasCompanySelection => selectedCompany != null;
  bool get hasPlantSelection => selectedPlant != null;
  bool get hasValueStreamSelection => selectedValueStream != null;
  bool get hasProcessSelection => selectedProcess != null;

  bool get canAccessPlantSetup => hasCompanySelection;
  bool get canAccessPartSetup =>
      hasCompanySelection && hasPlantSelection && hasValueStreamSelection;
  bool get canAccessProcessInput =>
      hasCompanySelection && hasPlantSelection && hasValueStreamSelection;
  bool get canAccessPartInput =>
      hasCompanySelection && hasPlantSelection && hasValueStreamSelection;

  void _showRequirementsDialog(
      BuildContext context, String feature, List<String> requirements) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('$feature Access Requirements'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('To access $feature, please select:'),
              const SizedBox(height: 12),
              ...requirements.map((req) => Padding(
                    padding: const EdgeInsets.only(left: 16, bottom: 4),
                    child: Row(
                      children: [
                        const Text('• '),
                        Text(req),
                      ],
                    ),
                  )),
              const SizedBox(height: 12),
              const Text('Go to Home screen to make these selections.'),
            ],
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

  Widget _buildDisabledListTile({
    required IconData icon,
    required String title,
    required List<String> requirements,
    String? subtitle,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey),
      title: Text(
        title,
        style: const TextStyle(color: Colors.grey),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            )
          : null,
      contentPadding: const EdgeInsets.only(left: 72.0, right: 16.0),
      onTap: () {
        Navigator.pop(context); // Close the drawer first
        _showRequirementsDialog(context, title, requirements);
      },
    );
  }

  Widget _buildEnabledListTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      contentPadding: const EdgeInsets.only(left: 72.0, right: 16.0),
      onTap: onTap,
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
              // Organization Setup - Always available
              _buildEnabledListTile(
                icon: Icons.account_tree,
                title: 'Organization Setup',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const OrganizationSetupScreen()),
                  );
                },
              ),

              // Plant & Value Stream Setup - Requires Company
              if (canAccessPlantSetup)
                _buildEnabledListTile(
                  icon: Icons.location_city,
                  title: 'Plant & Value Stream Setup',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const PlantSetupScreen()),
                    );
                  },
                )
              else
                _buildDisabledListTile(
                  icon: Icons.location_city,
                  title: 'Plant & Value Stream Setup',
                  requirements: ['Company'],
                  subtitle: 'Requires: Company',
                ),

              // Part Number Setup - Requires Company, Plant, Value Stream
              if (canAccessPartSetup)
                _buildEnabledListTile(
                  icon: Icons.precision_manufacturing,
                  title: 'Part Number Setup',
                  onTap: () {
                    Navigator.pop(context); // Close the drawer first
                    // TODO: Navigate to actual Part Setup screen when implemented
                    _showRequirementsDialog(context, 'Part Number Setup',
                        ['Feature not yet implemented']);
                  },
                )
              else
                _buildDisabledListTile(
                  icon: Icons.precision_manufacturing,
                  title: 'Part Number Setup',
                  requirements: ['Company', 'Plant', 'Value Stream'],
                  subtitle: 'Requires: Company, Plant, Value Stream',
                ),

              // Process Setup - Requires Company, Plant, Value Stream
              if (canAccessProcessInput)
                _buildEnabledListTile(
                  icon: Icons.settings,
                  title: 'Process Setup',
                  onTap: () {
                    Navigator.pop(context); // Close the drawer first
                    // TODO: Navigate to process input screen
                    _showRequirementsDialog(context, 'Process Setup',
                        ['Feature access from Home screen']);
                  },
                )
              else
                _buildDisabledListTile(
                  icon: Icons.settings,
                  title: 'Process Setup',
                  requirements: ['Company', 'Plant', 'Value Stream'],
                  subtitle: 'Requires: Company, Plant, Value Stream',
                ),
            ],
          ),

          // Standard Work Development
          ExpansionTile(
            leading: const Icon(Icons.engineering),
            title: const Text('Standard Work Development'),
            children: <Widget>[
              // Add Elements in Setup - Requires Company, Plant, Value Stream
              if (canAccessPartInput)
                _buildEnabledListTile(
                  icon: Icons.add_circle_outline,
                  title: 'Add Elements in Setup',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ElementsInputScreen(
                                companyName: selectedCompany,
                                plantName: selectedPlant,
                                valueStreamName: selectedValueStream,
                                processName: selectedProcess,
                              )),
                    );
                  },
                )
              else
                _buildDisabledListTile(
                  icon: Icons.add_circle_outline,
                  title: 'Add Elements in Setup',
                  requirements: ['Company', 'Plant', 'Value Stream'],
                  subtitle: 'Requires: Company, Plant, Value Stream',
                ),

              // Time Observation - Requires Company, Plant, Value Stream, Process
              if (canAccessPartInput && hasProcessSelection)
                _buildEnabledListTile(
                  icon: Icons.timer,
                  title: 'Time Observation',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => TimeObservationForm(
                                companyName: selectedCompany!,
                                plantName: selectedPlant!,
                                valueStreamName: selectedValueStream!,
                                processName: selectedProcess!,
                              )),
                    );
                  },
                )
              else
                _buildDisabledListTile(
                  icon: Icons.timer,
                  title: 'Time Observation',
                  requirements: hasProcessSelection
                      ? ['Company', 'Plant', 'Value Stream']
                      : ['Company', 'Plant', 'Value Stream', 'Process'],
                  subtitle: hasProcessSelection
                      ? 'Requires: Company, Plant, Value Stream'
                      : 'Requires: Company, Plant, Value Stream, Process',
                ),
            ],
          ),

          // Data Viewers
          ExpansionTile(
            leading: const Icon(Icons.visibility),
            title: const Text('Data Viewers'),
            children: <Widget>[
              // Setup Element Viewer - No requirements (view-only)
              _buildEnabledListTile(
                icon: Icons.view_list,
                title: 'Setup Element Viewer',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SetupElementViewerScreen()),
                  );
                },
              ),

              // Task Study Viewer - No requirements (view-only)
              _buildEnabledListTile(
                icon: Icons.assignment_outlined,
                title: 'Task Study Viewer',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const TaskStudyViewerScreen()),
                  );
                },
              ),

              // Time Study Viewer - No requirements (view-only)
              _buildEnabledListTile(
                icon: Icons.timer_outlined,
                title: 'Time Study Viewer',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const TimeStudyViewerScreen()),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
