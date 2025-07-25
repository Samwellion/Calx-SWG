import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';
import '../widgets/app_footer.dart';
import '../widgets/home_button_wrapper.dart';
import '../database_provider.dart';
import '../logic/app_database.dart';
import 'package:drift/drift.dart' show OrderingTerm;

class SetupInfo {
  final int setupId;
  final String setupName;
  final String partNumber;
  final DateTime setupDateTime;
  final String observerName;
  final List<SetupElement> elements;

  SetupInfo({
    required this.setupId,
    required this.setupName,
    required this.partNumber,
    required this.setupDateTime,
    required this.observerName,
    required this.elements,
  });
}

class SetupElementViewerScreen extends StatefulWidget {
  const SetupElementViewerScreen({super.key});

  @override
  State<SetupElementViewerScreen> createState() =>
      _SetupElementViewerScreenState();
}

class _SetupElementViewerScreenState extends State<SetupElementViewerScreen> {
  List<SetupInfo> _setups = [];
  SetupInfo? _selectedSetup;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSetups();
  }

  Future<void> _loadSetups() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final db = await DatabaseProvider.getInstance();

      // Get all setups first
      final allSetups = await db.select(db.setups).get();

      List<SetupInfo> setups = [];

      for (final setup in allSetups) {
        try {
          // Get process part info for this setup
          final processPart = await (db.select(db.processParts)
                ..where((pp) => pp.id.equals(setup.processPartId)))
              .getSingleOrNull();

          if (processPart == null) {
            continue;
          }

          // Get all elements for this setup
          final elements = await (db.select(db.setupElements)
                ..where((e) => e.setupId.equals(setup.id))
                ..orderBy([(e) => OrderingTerm(expression: e.orderIndex)]))
              .get();

          if (elements.isEmpty) {
            continue;
          }

          // Get study info for observer name (if available) - use first() to handle multiple studies
          final studies = await (db.select(db.study)
                ..where((s) => s.setupId.equals(setup.id)))
              .get();
          final study = studies.isNotEmpty ? studies.first : null;

          if (studies.length > 1) {}

          // Use the first element's setup date/time as the setup date
          final setupDateTime = elements.isNotEmpty
              ? elements.first.setupDateTime
              : DateTime.now();

          setups.add(SetupInfo(
            setupId: setup.id,
            setupName: setup.setupName,
            partNumber: processPart.partNumber,
            setupDateTime: setupDateTime,
            observerName: study?.observerName ?? 'Unknown',
            elements: elements,
          ));
        } catch (e) {
          // Continue with next setup instead of failing completely
          continue;
        }
      }

      // Sort by setup date (most recent first)
      setups.sort((a, b) => b.setupDateTime.compareTo(a.setupDateTime));

      setState(() {
        _setups = setups;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error loading setups: $e';
        _isLoading = false;
      });
    }
  }

  void _selectSetup(SetupInfo setup) {
    setState(() {
      _selectedSetup = setup;
    });
  }

  @override
  Widget build(BuildContext context) {
    return HomeButtonWrapper(
        child: Scaffold(
      appBar: AppBar(
        title: const Text('Setup Element Viewer'),
        backgroundColor: Colors.white,
      ),
      drawer: const AppDrawer(),
      backgroundColor: Colors.yellow[100],
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left side: Setup Elements List
                    Expanded(
                      flex: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.yellow[200],
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Time Studies',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              child: _buildSetupsList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Right side: Element Details
                    Expanded(
                      flex: 2,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.yellow[200],
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Time Study Summaries',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              child: _buildElementDetailsTable(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const AppFooter(),
          ],
        ),
      ),
    ));
  }

  Widget _buildSetupsList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red[400],
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadSetups,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_setups.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              color: Colors.grey,
              size: 48,
            ),
            SizedBox(height: 16),
            Text(
              'No setups found',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _setups.length,
      itemBuilder: (context, index) {
        final setup = _setups[index];
        final isSelected = _selectedSetup?.setupId == setup.setupId;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          color: isSelected ? Colors.yellow[100] : Colors.white,
          elevation: isSelected ? 4 : 1,
          child: ListTile(
            title: Text(
              '${setup.setupName} - ${setup.partNumber}',
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 16,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Expanded(
                    child: _buildInfoRow('Date:',
                        '${setup.setupDateTime.month}/${setup.setupDateTime.day}/${setup.setupDateTime.year}'),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInfoRow('Observer:', setup.observerName),
                  ),
                ],
              ),
            ),
            contentPadding: const EdgeInsets.all(16),
            onTap: () => _selectSetup(setup),
            selected: isSelected,
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildElementDetailsTable() {
    if (_selectedSetup == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.touch_app_outlined,
              color: Colors.grey,
              size: 64,
            ),
            SizedBox(height: 16),
            Text(
              'Select a setup to view element details',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    final setup = _selectedSetup!;

    return Column(
      children: [
        // Setup Header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.yellow[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.yellow[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                setup.setupName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildHeaderInfo('Part Number', setup.partNumber),
                  ),
                  Expanded(
                    child: _buildHeaderInfo('Observer', setup.observerName),
                  ),
                  Expanded(
                    child: _buildHeaderInfo('Date',
                        '${setup.setupDateTime.month}/${setup.setupDateTime.day}/${setup.setupDateTime.year} at ${setup.setupDateTime.hour}:${setup.setupDateTime.minute.toString().padLeft(2, '0')}'),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Elements Table
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildElementsTable(setup.elements),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildElementsTable(List<SetupElement> elements) {
    if (elements.isEmpty) {
      return const Center(
        child: Text(
          'No elements found for this setup',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Table(
        border: TableBorder.all(color: Colors.grey[300]!, width: 1),
        columnWidths: const {
          0: FixedColumnWidth(80), // Order (widened to prevent wrapping)
          1: FlexColumnWidth(4), // Element Name (increased)
          2: FlexColumnWidth(1), // Time (reduced by half)
        },
        children: [
          // Header Row
          TableRow(
            decoration: BoxDecoration(
              color: Colors.yellow[100],
            ),
            children: const [
              TableCell(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    'Order',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              TableCell(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    'Element Name',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              TableCell(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    'Time',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          // Data Rows
          ...elements.map((element) => TableRow(
                decoration: BoxDecoration(
                  color: element.orderIndex % 2 == 0
                      ? Colors.white
                      : Colors.grey[50],
                ),
                children: [
                  TableCell(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        element.orderIndex.toString(),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(element.elementName),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        element.time,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontFamily: 'monospace'),
                      ),
                    ),
                  ),
                ],
              )),
        ],
      ),
    );
  }
}
