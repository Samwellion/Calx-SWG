import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'dart:async';
import 'part_input_screen.dart';
import 'process_input_screen.dart';
import 'detailed_process_input_screen.dart';
import 'process_capacity.dart';
import 'process_canvas_screen.dart';
import '../screens/organization_setup_screen.dart';
import '../logic/app_database.dart';
import 'plant_setup_screen.dart';
import 'vs_detail_screen.dart';
import '../database_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/app_footer.dart';
import 'elements_input_screen.dart';
import 'time_observation_form.dart';
import '../widgets/app_drawer.dart';
import '../widgets/help_popup.dart';
import '../widgets/full_hierarchy_tree.dart';

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware {
  static const _kCompanyKey = 'selectedCompany';
  static const _kPlantKey = 'selectedPlant';
  static const _kValueStreamKey = 'selectedValueStream';
  static const _kValueStreamIdKey = 'selectedValueStreamId';
  static const _kProcessKey = 'selectedProcess';
  static const _kFirstLaunchKey = 'isFirstLaunch';


  bool hasSetupsForSelectedProcess = false;
  bool hasPartsInDatabase = false;
  bool hasProcessesInDatabase = false;
  bool _isDisposed = false;

  void _onHierarchyTreeItemSelected({
    String? companyName,
    String? plantName,
    String? valueStreamName,
    String? processName,
    int? plantIndex,
    int? valueStreamId,
    int? processId,
  }) async {
    if (_isDisposed) return;

    // Update selections based on what was selected in the tree
    bool hasChanges = false;

    if (companyName != selectedCompany) {
      selectedCompany = companyName;
      hasChanges = true;
    }

    if (plantName != selectedPlant) {
      selectedPlant = plantName;
      hasChanges = true;
    }

    if (valueStreamName != selectedValueStream ||
        valueStreamId != selectedValueStreamId) {
      selectedValueStream = valueStreamName;
      selectedValueStreamId = valueStreamId;
      hasChanges = true;
    }

    if (processName != selectedProcess) {
      selectedProcess = processName;
      hasChanges = true;
    }

    if (hasChanges) {
      setState(() {});
      await _saveSelections();

      // Reload dependent data
      if (valueStreamName != null) {
        await _loadProcessesForValueStream();
      }
      await _checkSetupsForSelectedProcess();
      await _checkPartsAndProcessesExistence();
    }
  }

  void _onHierarchyTreeAddItem({
    TreeItemType? itemType,
    String? companyName,
    String? plantName,
    String? valueStreamName,
    int? valueStreamId,
  }) async {
    if (itemType == null) return;

    switch (itemType) {
      case TreeItemType.company:
        // Navigate to organization setup screen
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => OrganizationSetupScreen(),
          ),
        );
        break;
      case TreeItemType.plant:
        // Navigate to organization setup screen with company pre-selected
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => OrganizationSetupScreen(
              selectedCompany: companyName,
            ),
          ),
        );
        break;

      case TreeItemType.valueStream:
        // Navigate to plant setup screen
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PlantSetupScreen(),
          ),
        );
        break;

      case TreeItemType.process:
        // Navigate to process input screen with value stream information
        if (valueStreamId != null &&
            valueStreamName != null &&
            companyName != null &&
            plantName != null) {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ProcessInputScreen(
                valueStreamId: valueStreamId,
                valueStreamName: valueStreamName,
                companyName: companyName,
                plantName: plantName,
              ),
            ),
          );
        }
        break;
    }

    // Refresh data after navigation
    await _loadDropdownData();
    await _loadSelections();
  }

  String _getSelectedItemDisplayText() {
    if (companyNames.isEmpty) {
      return "Getting started";
    } else if (selectedProcess != null && selectedProcess!.isNotEmpty) {
      return "Process";
    } else if (selectedValueStream != null && selectedValueStream!.isNotEmpty) {
      return "Value Stream";
    } else if (selectedPlant != null && selectedPlant!.isNotEmpty) {
      return "Plant";
    } else if (selectedCompany != null && selectedCompany!.isNotEmpty) {
      return "Company";
    } else {
      return "Getting started";
    }
  }

  Widget _buildWelcomePanel() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.yellow[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.yellow[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome to Calx\' Industrial Tools',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'This app will help mentor you and your team in applying well known Lean manufacturing concepts to your factory. You will see action buttons and video links to guide you through the journey. Start by clicking \'Setup Organization\'...',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyPanel() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.yellow[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.yellow[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Company and Plant Names',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Company names and plant names are the containers for the details that we will focus our improvements on. Notice the hierarchy navigation panel to the left side of the screen. As you select items there the actions and videos will change to help guide you through utilizing the tools. At the plant level we have:',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '• ',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Employees (Under Development)',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '• ',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'PFEP (Under Development)',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '• ',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Product Process Matrix (Under Development)',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '• ',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Value Streams',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValueStreamPanel() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.yellow[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.yellow[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Where Customer Value is Created',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'The Value Stream is the series of processes that transform data or materials into something that your customer considers valuable. So the basic building blocks are:',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '• ',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Job Positions (Under Development)',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '• ',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Parts Customers Consume',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '• ',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Processes That Create the Parts',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessPanel() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.yellow[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.yellow[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Processes in the Value Stream Transform',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'As the data or material move through the value stream a series of processes transform it into something the customer wants. These processes are where the work is done. Here we have:',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '• ',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Detailed Process Performance (Under Development)',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '• ',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Setups with Work Elements',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '• ',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Machines (Under Development)',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '• ',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Time Studies',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContextualActionsPanel() {
    if (companyNames.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.yellow[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.yellow[300]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Actions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const OrganizationSetupScreen(),
                  ),
                );
                await _loadDropdownData();
              },
              child: const Text('Setup Organization'),
            ),
          ],
        ),
      );
    }

    // Show plant setup button when company or plant is selected (but no value stream)
    if (selectedCompany != null &&
        selectedCompany!.isNotEmpty &&
        (selectedValueStream == null || selectedValueStream!.isEmpty)) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.yellow[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.yellow[300]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Actions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _openPlantSetupScreen,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow[600],
                  ),
                  child: const Text('Setup Value Stream Names'),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Show value stream actions when value stream is selected (but no process)
    if (selectedValueStream != null &&
        selectedValueStream!.isNotEmpty &&
        (selectedProcess == null || selectedProcess!.isEmpty)) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.yellow[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.yellow[300]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Actions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (selectedCompany != null &&
                          selectedCompany!.isNotEmpty &&
                          selectedPlant != null &&
                          selectedPlant!.isNotEmpty)
                      ? _openPartInputScreen
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow[600],
                  ),
                  child: const Text('Add / Edit Part Number'),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _onAddVSProcess,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow[600],
                  ),
                  child: const Text('Add / Edit Process'),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _openVSDetailScreen,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow[600],
                  ),
                  child: const Text('Value Stream Details'),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _openValueStreamMapping,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow[600],
                  ),
                  child: const Text('Value Stream Mapping'),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Show process actions when process is selected
    if (selectedProcess != null && selectedProcess!.isNotEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.yellow[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.yellow[300]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Actions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _openDetailedProcessScreen,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow[600],
                  ),
                  child: const Text('Detailed Process Edit'),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _openProcessCapacityScreen,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow[600],
                  ),
                  child: const Text('Process Capacity Analysis'),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (hasPartsInDatabase && hasProcessesInDatabase)
                      ? _openAddElementsScreen
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow[600],
                  ),
                  child: const Text('Setups and Elements'),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: hasSetupsForSelectedProcess
                      ? _openTimeObservationScreen
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow[600],
                  ),
                  child: const Text('Time Observation'),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Return contextual actions based on selection for other cases
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.yellow[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.yellow[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Actions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),
          ..._getContextualActionButtons(),
        ],
      ),
    );
  }

  List<Widget> _getContextualActionButtons() {
    List<Widget> buttons = [];

    // Always show setup organization
    buttons.add(
      Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const OrganizationSetupScreen(),
                ),
              );
              await _loadDropdownData();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.yellow[600],
            ),
            child: const Text('Setup Organization'),
          ),
        ),
      ),
    );

    // Show plant setup if company exists
    if (selectedCompany != null && selectedCompany!.isNotEmpty) {
      buttons.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _openPlantSetupScreen,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow[600],
              ),
              child: const Text('Setup Plant'),
            ),
          ),
        ),
      );
    }

    // Show add part number if value stream is selected
    if (selectedValueStream != null && selectedValueStream!.isNotEmpty) {
      buttons.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (selectedCompany != null &&
                      selectedCompany!.isNotEmpty &&
                      selectedPlant != null &&
                      selectedPlant!.isNotEmpty)
                  ? _openPartInputScreen
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow[600],
              ),
              child: const Text('Add / Edit Part Number'),
            ),
          ),
        ),
      );

      buttons.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _onAddVSProcess,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow[600],
              ),
              child: const Text('Add / Edit Process'),
            ),
          ),
        ),
      );

      buttons.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _openVSDetailScreen,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow[600],
              ),
              child: const Text('Value Stream Details'),
            ),
          ),
        ),
      );
    }

    // Show process-specific actions if process is selected
    if (selectedProcess != null && selectedProcess!.isNotEmpty) {
      buttons.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (hasPartsInDatabase && hasProcessesInDatabase)
                  ? _openAddElementsScreen
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow[600],
              ),
              child: const Text('Setups and Elements'),
            ),
          ),
        ),
      );

      buttons.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _openProcessCapacityScreen,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow[600],
              ),
              child: const Text('Process Capacity Analysis'),
            ),
          ),
        ),
      );

      buttons.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: hasSetupsForSelectedProcess
                  ? _openTimeObservationScreen
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow[600],
              ),
              child: const Text('Time Observation'),
            ),
          ),
        ),
      );
    }

    return buttons;
  }

  Widget _buildVideoLinksPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.yellow[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.yellow[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Video Links',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),
          if (companyNames.isEmpty) ...[
            // Show only welcome and setup videos when no companies exist
            _buildVideoLink('Welcome to Calx\' Industrial Tools',
                'https://example.com/getting-started'),
            _buildVideoLink(
                'Setting up Organizations', 'https://example.com/setup-org'),
          ] else if (selectedCompany != null &&
              selectedCompany!.isNotEmpty &&
              (selectedValueStream == null ||
                  selectedValueStream!.isEmpty)) ...[
            // Show welcome and value streams videos when company or plant is selected
            _buildVideoLink('Welcome to Calx\' Industrial Tools',
                'https://example.com/getting-started'),
            _buildVideoLink('Adding Value Streams',
                'https://example.com/add-value-streams'),
          ] else if (selectedValueStream != null &&
              selectedValueStream!.isNotEmpty &&
              (selectedProcess == null || selectedProcess!.isEmpty)) ...[
            // Show value stream specific videos when value stream is selected
            _buildVideoLink('Welcome to Calx\' Industrial Tools',
                'https://example.com/getting-started'),
            _buildVideoLink(
                'Adding Part Numbers', 'https://example.com/add-part-numbers'),
            _buildVideoLink('Adding Process Names',
                'https://example.com/add-process-names'),
          ] else if (selectedProcess != null &&
              selectedProcess!.isNotEmpty) ...[
            // Show process specific videos when process is selected
            _buildVideoLink('Welcome to Calx\' Industrial Tools',
                'https://example.com/getting-started'),
            _buildVideoLink('Setting up Setups and Elements',
                'https://example.com/setup-elements'),
            _buildVideoLink(
                'Conducting Time Studies', 'https://example.com/time-studies'),
          ] else ...[
            // Show all video links when deeper levels are selected
            _buildVideoLink('Welcome to Calx\' Industrial Tools',
                'https://example.com/getting-started'),
            _buildVideoLink(
                'Setting up Organizations', 'https://example.com/setup-org'),
            _buildVideoLink('Adding Parts', 'https://example.com/add-parts'),
            _buildVideoLink(
                'Time Observations', 'https://example.com/time-obs'),
          ],
        ],
      ),
    );
  }

  Widget _buildVideoLink(String title, String url) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          // TODO: Implement video link opening
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Opening: $title')),
          );
        },
        child: Row(
          children: [
            Icon(Icons.play_circle_outline, color: Colors.blue[600], size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.blue[600],
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _checkSetupsForSelectedProcess() async {
    if (_isDisposed || selectedProcess == null || selectedProcess!.isEmpty) {
      if (!_isDisposed) {
        setState(() {
          hasSetupsForSelectedProcess = false;
        });
      }
      return;
    }

    try {
      // Use a single optimized query instead of multiple queries
      final result = await db.customSelect('''
        SELECT COUNT(*) as count 
        FROM setup_elements se
        INNER JOIN process_parts pp ON se.process_part_id = pp.id
        INNER JOIN processes p ON pp.process_id = p.id
        WHERE p.process_name = ?
      ''',
          variables: [drift.Variable.withString(selectedProcess!)]).getSingle();

      final count = result.data['count'] as int;

      if (!_isDisposed) {
        setState(() {
          hasSetupsForSelectedProcess = count > 0;
        });
      }
    } catch (e) {
      debugPrint('Error checking setups for selected process: $e');
      if (!_isDisposed) {
        setState(() {
          hasSetupsForSelectedProcess = false;
        });
      }
    }
  }

  Future<void> _checkPartsAndProcessesExistence() async {
    debugPrint(
        '_checkPartsAndProcessesExistence: selectedValueStream=$selectedValueStream, selectedValueStreamId=$selectedValueStreamId');

    if (_isDisposed || selectedValueStreamId == null) {
      debugPrint(
          'Early return: _isDisposed=$_isDisposed, selectedValueStreamId=$selectedValueStreamId');
      if (!_isDisposed) {
        setState(() {
          hasPartsInDatabase = false;
          hasProcessesInDatabase = false;
        });
      }
      return;
    }

    try {
      // Check if there are any parts for the selected value stream
      final partsResult = await db.customSelect('''
        SELECT COUNT(*) as count 
        FROM parts p
        WHERE p.value_stream_id = ?
      ''', variables: [
        drift.Variable.withInt(selectedValueStreamId!)
      ]).getSingle();

      final partsCount = partsResult.data['count'] as int;
      debugPrint(
          'Parts count for value stream $selectedValueStreamId: $partsCount');

      // Check if there are any processes for the selected value stream
      final processesResult = await db.customSelect('''
        SELECT COUNT(*) as count 
        FROM processes p
        WHERE p.value_stream_id = ?
      ''', variables: [
        drift.Variable.withInt(selectedValueStreamId!)
      ]).getSingle();

      final processesCount = processesResult.data['count'] as int;
      debugPrint(
          'Processes count for value stream $selectedValueStreamId: $processesCount');

      if (!_isDisposed) {
        setState(() {
          hasPartsInDatabase = partsCount > 0;
          hasProcessesInDatabase = processesCount > 0;
        });
        debugPrint(
            'Updated flags: hasPartsInDatabase=$hasPartsInDatabase, hasProcessesInDatabase=$hasProcessesInDatabase');
      }
    } catch (e) {
      debugPrint('Error checking parts and processes existence: $e');
      if (!_isDisposed) {
        setState(() {
          hasPartsInDatabase = false;
          hasProcessesInDatabase = false;
        });
      }
    }
  }

  Future<void> _onAddVSProcess() async {
    if (selectedValueStreamId != null &&
        selectedValueStream != null &&
        selectedCompany != null &&
        selectedPlant != null) {
      try {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ProcessInputScreen(
              valueStreamId: selectedValueStreamId!,
              valueStreamName: selectedValueStream!,
              companyName: selectedCompany!,
              plantName: selectedPlant!,
            ),
          ),
        );
        // Reload process dropdown after returning from process input
        await _loadProcessesForValueStream();
      } catch (e) {
        debugPrint('Error navigating to process input screen: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error opening process input screen')),
          );
        }
      }
    }
  }

  Future<void> _openVSDetailScreen() async {
    if (selectedValueStreamId != null &&
        selectedValueStream != null &&
        selectedCompany != null &&
        selectedPlant != null) {
      try {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => VSDetailScreen(
              valueStreamName: selectedValueStream!,
              valueStreamId: selectedValueStreamId!,
              companyName: selectedCompany!,
              plantName: selectedPlant!,
            ),
          ),
        );
        // Reload data after returning from VS detail screen
        await _loadDropdownData();
        await _loadSelections();
      } catch (e) {
        debugPrint('Error navigating to VS detail screen: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error opening VS detail screen')),
          );
        }
      }
    }
  }

  Future<void> _openValueStreamMapping() async {
    if (selectedValueStreamId == null ||
        selectedValueStream == null) {
      return;
    }

    try {
      // Get parts linked to this value stream
      final partsQuery = db.select(db.parts)
        ..where((p) => p.valueStreamId.equals(selectedValueStreamId!))
        ..orderBy([(p) => drift.OrderingTerm.asc(p.partNumber)]);

      final parts = await partsQuery.get();

      if (parts.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No parts found for this value stream. Please add parts first.'),
            ),
          );
        }
        return;
      }

      // Show part selection dialog
      final selectedPart = await _showPartSelectionDialog(parts);

      if (selectedPart != null) {
        // Save selected part number to shared preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('selectedPartNumber', selectedPart.partNumber);

        // Navigate to process canvas
        if (mounted) {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ProcessCanvasScreen(
                valueStreamId: selectedValueStreamId!,
                valueStreamName: selectedValueStream!,
              ),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error opening value stream mapping: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error opening value stream mapping')),
        );
      }
    }
  }

  Future<Part?> _showPartSelectionDialog(List<Part> parts) async {
    return showDialog<Part>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Part Number'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Choose a part number for the value stream mapping:',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 300,
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: parts.length,
                    itemBuilder: (context, index) {
                      final part = parts[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          title: Text(
                            part.partNumber,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: part.partDescription != null
                              ? Text(part.partDescription!)
                              : const Text('No description'),
                          trailing: part.monthlyDemand != null
                              ? Chip(
                                  label: Text('${part.monthlyDemand} /mo'),
                                  backgroundColor: Colors.blue[100],
                                )
                              : null,
                          onTap: () => Navigator.of(context).pop(part),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  String? selectedCompany;
  String? selectedPlant;
  String? selectedValueStream;
  int? selectedValueStreamId;
  String? selectedProcess;
  late AppDatabase db;
  List<String> companyNames = [];
  Map<String, List<String>> companyPlants = {};
  Map<String, List<String>> plantValueStreams = {};
  List<String> processNames = [];
  bool isLoading = true;
  DateTime? _lastDataLoad;
  static const Duration _cacheValidityDuration = Duration(minutes: 5);
  Future<void> _loadProcessesForValueStream() async {
    if (_isDisposed || selectedValueStreamId == null) {
      if (!_isDisposed) {
        setState(() {
          processNames = [];
          selectedProcess = null;
        });
      }
      return;
    }

    try {
      final result = await db.customSelect(
        'SELECT process_name FROM processes WHERE value_stream_id = ? ORDER BY process_name',
        variables: [drift.Variable.withInt(selectedValueStreamId!)],
      ).get();

      final names =
          result.map((row) => row.data['process_name'] as String).toList();

      if (!_isDisposed) {
        setState(() {
          processNames = names;
          if (!processNames.contains(selectedProcess)) {
            selectedProcess = null;
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading processes for value stream: $e');
      if (!_isDisposed) {
        setState(() {
          processNames = [];
          selectedProcess = null;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeScreen();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstLaunch = prefs.getBool(_kFirstLaunchKey) ?? true;
    
    if (isFirstLaunch && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const HelpPopup(),
        );
      });
      await prefs.setBool(_kFirstLaunchKey, false);
    }
  }

  Future<void> _initializeScreen() async {
    db = await DatabaseProvider.getInstance();
    await _loadSelections();
    await _loadDropdownData();
    await _loadProcessesForValueStream();
    await _checkSetupsForSelectedProcess();
    await _checkPartsAndProcessesExistence();
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    _isDisposed = true;
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // Called when returning to this screen after popping another route
    _loadSelections();
    _loadDropdownData();
    _checkPartsAndProcessesExistence();
    setState(() {});
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
      final vsid = prefs.getInt(_kValueStreamIdKey);
      selectedValueStreamId = (vsid != null && vsid != -1) ? vsid : null;
      final proc = prefs.getString(_kProcessKey);
      selectedProcess = (proc != null && proc.isNotEmpty) ? proc : null;
    });
  }

  Future<void> _saveSelections() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kCompanyKey, selectedCompany ?? '');
    await prefs.setString(_kPlantKey, selectedPlant ?? '');
    await prefs.setString(_kValueStreamKey, selectedValueStream ?? '');
    await prefs.setInt(_kValueStreamIdKey, selectedValueStreamId ?? -1);
    await prefs.setString(_kProcessKey, selectedProcess ?? '');
  }

  Future<void> _openPlantSetupScreen() async {
    try {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PlantSetupScreen(
            selectedPlantName:
                selectedPlant, // Pass the currently selected plant
          ),
        ),
      );
      // Invalidate cache to force reload of dropdown data
      _lastDataLoad = null;
      await _loadDropdownData();
    } catch (e) {
      debugPrint('Error navigating to plant setup screen: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error opening plant setup screen')),
        );
      }
    }
  }

  Future<void> _loadDropdownData() async {
    if (_isDisposed) return;

    // Check if we need to reload data based on cache validity
    final now = DateTime.now();
    if (_lastDataLoad != null &&
        now.difference(_lastDataLoad!) < _cacheValidityDuration &&
        companyNames.isNotEmpty) {
      return; // Use cached data
    }

    try {
      final orgs = await db.select(db.organizations).get();
      companyNames = orgs.map((o) => o.name).toList()..sort();

      final plants = await db.select(db.plants).get();
      companyPlants = {};
      for (final org in orgs) {
        final orgPlants = plants
            .where((p) => p.organizationId == org.id)
            .map((p) => p.name)
            .toList()
          ..sort();
        companyPlants[org.name] = orgPlants;
      }

      final valueStreams = await db.select(db.valueStreams).get();
      plantValueStreams = {};
      for (final plant in plants) {
        final plantStreams = valueStreams
            .where((vs) => vs.plantId == plant.id)
            .map((vs) => vs.name)
            .toList()
          ..sort();
        plantValueStreams[plant.name] = plantStreams;
      }

      _lastDataLoad = now;
    } catch (e) {
      debugPrint('Error loading dropdown data: $e');
      // Initialize with empty data on error
      companyNames = [];
      companyPlants = {};
      plantValueStreams = {};
    }
  }

  void _openPartInputScreen() async {
    if (selectedValueStreamId != null &&
        selectedValueStream != null &&
        selectedCompany != null &&
        selectedPlant != null) {
      try {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PartInputScreen(
              valueStreamId: selectedValueStreamId!,
              valueStreamName: selectedValueStream!,
              companyName: selectedCompany!,
              plantName: selectedPlant!,
            ),
          ),
        );
        await _loadSelections();
      } catch (e) {
        debugPrint('Error navigating to part input screen: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error opening part input screen')),
          );
        }
      }
    }
  }

  void _openAddElementsScreen() async {
    if (selectedValueStreamId != null) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ElementsInputScreen(
            companyName: selectedCompany,
            plantName: selectedPlant,
            valueStreamName: selectedValueStream,
            processName: selectedProcess,
          ),
        ),
      );
    }
  }

  Future<void> _openDetailedProcessScreen() async {
    if (selectedProcess == null ||
        selectedProcess!.isEmpty ||
        selectedValueStreamId == null ||
        selectedValueStream == null ||
        selectedCompany == null ||
        selectedPlant == null) {
      return;
    }

    try {
      // Get the process ID for the selected process
      final result = await db.customSelect(
        'SELECT id FROM processes WHERE process_name = ? AND value_stream_id = ?',
        variables: [
          drift.Variable.withString(selectedProcess!),
          drift.Variable.withInt(selectedValueStreamId!),
        ],
      ).getSingleOrNull();

      if (result != null) {
        final processId = result.data['id'] as int;

        // ignore: use_build_context_synchronously
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DetailedProcessInputScreen(
              valueStreamId: selectedValueStreamId!,
              valueStreamName: selectedValueStream!,
              companyName: selectedCompany!,
              plantName: selectedPlant!,
              processId: processId,
            ),
          ),
        );

        // Refresh data after returning from detailed screen
        await _loadProcessesForValueStream();
        await _checkSetupsForSelectedProcess();
        await _checkPartsAndProcessesExistence();
      }
    } catch (e) {
      debugPrint('Error opening detailed process screen: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Error opening detailed process screen')),
        );
      }
    }
  }

  Future<void> _openProcessCapacityScreen() async {
    if (selectedProcess == null ||
        selectedProcess!.isEmpty ||
        selectedValueStreamId == null ||
        selectedValueStream == null ||
        selectedCompany == null ||
        selectedPlant == null) {
      return;
    }

    try {
      // Get the process ID for the selected process
      final result = await db.customSelect(
        'SELECT id FROM processes WHERE process_name = ? AND value_stream_id = ?',
        variables: [
          drift.Variable.withString(selectedProcess!),
          drift.Variable.withInt(selectedValueStreamId!),
        ],
      ).getSingleOrNull();

      if (result != null) {
        final processId = result.data['id'] as int;

        // ignore: use_build_context_synchronously
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ProcessCapacityScreen(
              processId: processId,
              processName: selectedProcess!,
              valueStreamId: selectedValueStreamId!,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error opening process capacity screen: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Error opening process capacity screen')),
        );
      }
    }
  }

  Future<void> _openTimeObservationScreen() async {
    if (selectedProcess == null || selectedProcess!.isEmpty) return;

    // Store context before async operations
    final currentContext = context;

    try {
      // Use optimized single query to get setup options
      final setupOptionsResult = await db.customSelect('''
        SELECT pp.part_number, s.setup_name, 
               GROUP_CONCAT(se.element_name ORDER BY se.order_index) as elements
        FROM setup_elements se
        INNER JOIN process_parts pp ON se.process_part_id = pp.id
        INNER JOIN processes p ON pp.process_id = p.id
        INNER JOIN setups s ON se.setup_id = s.id
        WHERE p.process_name = ?
        GROUP BY pp.part_number, s.setup_name
        ORDER BY s.setup_name, pp.part_number
      ''', variables: [drift.Variable.withString(selectedProcess!)]).get();

      if (setupOptionsResult.isEmpty) {
        if (mounted && currentContext.mounted) {
          ScaffoldMessenger.of(currentContext).showSnackBar(
            const SnackBar(
                content: Text('No setups found for selected process')),
          );
        }
        return;
      }

      final setupOptions = setupOptionsResult.map((row) {
        final elements = row.data['elements'] as String? ?? '';
        return {
          'partNumber': row.data['part_number'] as String,
          'setupName': row.data['setup_name'] as String,
          'elements': elements.isNotEmpty ? elements.split(',') : <String>[],
        };
      }).toList();

      Map<String, dynamic>? selectedOption = setupOptions.first;

      // ignore: use_build_context_synchronously
      final result = await showDialog<Map<String, dynamic>>(
        // ignore: use_build_context_synchronously
        context: currentContext,
        barrierDismissible: false,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('Select Setup and Part Number'),
            content: StatefulBuilder(
              builder: (context, setState) {
                return DropdownButton<Map<String, dynamic>>(
                  value: selectedOption,
                  isExpanded: true,
                  items: setupOptions.map((opt) {
                    return DropdownMenuItem<Map<String, dynamic>>(
                      value: opt,
                      child: Text('${opt['setupName']} - ${opt['partNumber']}'),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      selectedOption = val;
                    });
                  },
                );
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(selectedOption),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );

      if (result != null) {
        if (mounted && currentContext.mounted) {
          Navigator.of(currentContext).push(
            MaterialPageRoute(
              builder: (_) => TimeObservationForm(
                companyName: selectedCompany ?? '',
                plantName: selectedPlant ?? '',
                valueStreamName: selectedValueStream ?? '',
                processName: selectedProcess ?? '',
                initialPartNumber: result['partNumber'],
                initialElements: List<String>.from(result['elements']),
              ),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error opening time observation screen: $e');
      if (mounted && currentContext.mounted) {
        ScaffoldMessenger.of(currentContext).showSnackBar(
          const SnackBar(content: Text('Error loading setup data')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'Show Help',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const HelpPopup(),
              );
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      backgroundColor: Colors.yellow[100],
      body: Column(
        children: [
          // Removed HomeHeader from home screen
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints:
                    const BoxConstraints(maxWidth: 1200), // Increased from 900
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.yellow[50],
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Removed HeaderTextBox row
                        ],
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left side: Full Hierarchy Tree
                            Flexible(
                              flex: 2,
                              child: FullHierarchyTree(
                                width: 300, // Provide explicit width
                                height:
                                    null, // Use intrinsic height instead of fixed
                                showHeader: true,
                                headerText: 'Organization',
                                expandedByDefault:
                                    true, // Set to true for debugging
                                onItemSelected: _onHierarchyTreeItemSelected,
                                onAddItem: _onHierarchyTreeAddItem,
                                selectedCompany: selectedCompany,
                                selectedPlant: selectedPlant,
                                selectedValueStream: selectedValueStream,
                                selectedProcess: selectedProcess,
                              ),
                            ),
                            const SizedBox(width: 24),

                            // Right side: Three-panel design
                            Flexible(
                              flex: 3,
                              child: Column(
                                children: [
                                  // Top panel: Context display
                                  companyNames.isEmpty
                                      ? _buildWelcomePanel()
                                      : (selectedCompany != null &&
                                              selectedCompany!.isNotEmpty &&
                                              (selectedValueStream == null ||
                                                  selectedValueStream!.isEmpty))
                                          ? _buildCompanyPanel()
                                          : (selectedValueStream != null &&
                                                  selectedValueStream!
                                                      .isNotEmpty &&
                                                  (selectedProcess == null ||
                                                      selectedProcess!.isEmpty))
                                              ? _buildValueStreamPanel()
                                              : (selectedProcess != null &&
                                                      selectedProcess!
                                                          .isNotEmpty)
                                                  ? _buildProcessPanel()
                                                  : Container(
                                                      width: double.infinity,
                                                      padding:
                                                          const EdgeInsets.all(
                                                              16),
                                                      decoration: BoxDecoration(
                                                        color:
                                                            Colors.yellow[50],
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                        border: Border.all(
                                                            color: Colors
                                                                .yellow[300]!),
                                                      ),
                                                      child: Text(
                                                        _getSelectedItemDisplayText(),
                                                        style: const TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ),
                                  const SizedBox(height: 16),

                                  // Bottom row: Actions and Video Links
                                  Expanded(
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Left panel: Actions
                                        Expanded(
                                          child: SingleChildScrollView(
                                            child:
                                                _buildContextualActionsPanel(),
                                          ),
                                        ),
                                        const SizedBox(width: 16),

                                        // Right panel: Video Links
                                        Expanded(
                                          child: SingleChildScrollView(
                                            child: _buildVideoLinksPanel(),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const AppFooter(),
        ],
      ),
    );
  }
}

class Plant {
  final int id;
  final int organizationId;
  final String name;
  final String street;
  final String city;
  final String state;
  final String zip;

  Plant({
    required this.id,
    required this.organizationId,
    required this.name,
    required this.street,
    required this.city,
    required this.state,
    required this.zip,
  });
}
