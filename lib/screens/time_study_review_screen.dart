import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';
import '../widgets/app_footer.dart';
import '../database_provider.dart';
import '../logic/app_database.dart';
import 'package:drift/drift.dart' show OrderingTerm;

class TimeStudyReviewInfo {
  final int studyId;
  final String setupName;
  final String partNumber;
  final DateTime studyDate;
  final String observerName;
  final List<TimeStudyData> timeStudies;
  final Map<String, List<String>> elementLaps; // taskName -> list of lap times
  final Map<String, SetupElement>
      setupElements; // taskName -> SetupElement data
  final List<SetupElement> elements; // For the summary tab

  TimeStudyReviewInfo({
    required this.studyId,
    required this.setupName,
    required this.partNumber,
    required this.studyDate,
    required this.observerName,
    required this.timeStudies,
    required this.elementLaps,
    required this.setupElements,
    required this.elements,
  });
}

class TimeStudyReviewScreen extends StatefulWidget {
  const TimeStudyReviewScreen({super.key});

  @override
  State<TimeStudyReviewScreen> createState() => _TimeStudyReviewScreenState();
}

class _TimeStudyReviewScreenState extends State<TimeStudyReviewScreen>
    with SingleTickerProviderStateMixin {
  List<TimeStudyReviewInfo> _studies = [];
  List<TimeStudyReviewInfo> _filteredStudies = [];
  TimeStudyReviewInfo? _selectedStudy;
  bool _isLoading = true;
  String? _error;

  late TabController _tabController;

  // Filter controllers
  final TextEditingController _partNumberFilterController =
      TextEditingController();
  final TextEditingController _setupNameFilterController =
      TextEditingController();
  final TextEditingController _observerFilterController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadStudies();

    // Add listeners to filter controllers
    _partNumberFilterController.addListener(_applyFilters);
    _setupNameFilterController.addListener(_applyFilters);
    _observerFilterController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _partNumberFilterController.dispose();
    _setupNameFilterController.dispose();
    _observerFilterController.dispose();
    super.dispose();
  }

  Future<void> _loadStudies() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final db = await DatabaseProvider.getInstance();

      // Get all studies first
      final allStudies = await db.select(db.study).get();

      List<TimeStudyReviewInfo> studies = [];

      for (final study in allStudies) {
        try {
          // Get setup info for this study
          final setup = await (db.select(db.setups)
                ..where((s) => s.id.equals(study.setupId)))
              .getSingleOrNull();

          if (setup == null) {
            continue;
          }

          // Get process part info for the setup
          final processPart = await (db.select(db.processParts)
                ..where((pp) => pp.id.equals(setup.processPartId)))
              .getSingleOrNull();

          if (processPart == null) {
            continue;
          }

          // Get all time studies for this study
          final timeStudies = await (db.select(db.timeStudy)
                ..where((ts) => ts.studyId.equals(study.id)))
              .get();

          if (timeStudies.isEmpty) {
            continue;
          }

          // Group time studies by task name to organize laps
          Map<String, List<String>> elementLaps = {};
          for (final timeStudy in timeStudies) {
            if (!elementLaps.containsKey(timeStudy.taskName)) {
              elementLaps[timeStudy.taskName] = [];
            }
            elementLaps[timeStudy.taskName]!.add(timeStudy.iterationTime);
          }

          // Get setup elements for this study to get lrt, overrideTime, and comments
          final setupElements = await (db.select(db.setupElements)
                ..where((se) => se.setupId.equals(study.setupId))
                ..orderBy([(e) => OrderingTerm(expression: e.orderIndex)]))
              .get();

          // Create a map of element name to SetupElement for easy lookup
          Map<String, SetupElement> elementMap = {};
          for (final element in setupElements) {
            elementMap[element.elementName] = element;
          }

          studies.add(TimeStudyReviewInfo(
            studyId: study.id,
            setupName: setup.setupName,
            partNumber: processPart.partNumber,
            studyDate: study.date,
            observerName: study.observerName,
            timeStudies: timeStudies,
            elementLaps: elementLaps,
            setupElements: elementMap,
            elements: setupElements, // For the summary tab
          ));
        } catch (e) {
          continue;
        }
      }

      // Sort by study date (most recent first)
      studies.sort((a, b) => b.studyDate.compareTo(a.studyDate));

      setState(() {
        _studies = studies;
        _filteredStudies = studies; // Initialize filtered list
        _isLoading = false;
      });
      _applyFilters(); // Apply any existing filters
    } catch (e) {
      setState(() {
        _error = 'Error loading time studies: $e';
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredStudies = _studies.where((study) {
        final partNumberFilter = _partNumberFilterController.text.toLowerCase();
        final setupNameFilter = _setupNameFilterController.text.toLowerCase();
        final observerFilter = _observerFilterController.text.toLowerCase();

        final matchesPartNumber = partNumberFilter.isEmpty ||
            study.partNumber.toLowerCase().contains(partNumberFilter);
        final matchesSetupName = setupNameFilter.isEmpty ||
            study.setupName.toLowerCase().contains(setupNameFilter);
        final matchesObserver = observerFilter.isEmpty ||
            study.observerName.toLowerCase().contains(observerFilter);

        return matchesPartNumber && matchesSetupName && matchesObserver;
      }).toList();

      // Clear selection if the selected study is no longer in filtered results
      if (_selectedStudy != null &&
          !_filteredStudies
              .any((study) => study.studyId == _selectedStudy!.studyId)) {
        _selectedStudy = null;
      }
    });
  }

  void _clearFilters() {
    _partNumberFilterController.clear();
    _setupNameFilterController.clear();
    _observerFilterController.clear();
  }

  void _selectStudy(TimeStudyReviewInfo study) {
    setState(() {
      _selectedStudy = study;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Time Study Review'),
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
                    // Left side: Studies List
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
                            // Filter Section
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  TextField(
                                    controller: _partNumberFilterController,
                                    decoration: const InputDecoration(
                                      labelText: 'Filter by Part Number',
                                      prefixIcon: Icon(Icons.search),
                                      border: OutlineInputBorder(),
                                      isDense: true,
                                    ),
                                    onChanged: (value) => _applyFilters(),
                                  ),
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: _setupNameFilterController,
                                    decoration: const InputDecoration(
                                      labelText: 'Filter by Setup Name',
                                      prefixIcon: Icon(Icons.search),
                                      border: OutlineInputBorder(),
                                      isDense: true,
                                    ),
                                    onChanged: (value) => _applyFilters(),
                                  ),
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: _observerFilterController,
                                    decoration: const InputDecoration(
                                      labelText: 'Filter by Observer',
                                      prefixIcon: Icon(Icons.search),
                                      border: OutlineInputBorder(),
                                      isDense: true,
                                    ),
                                    onChanged: (value) => _applyFilters(),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(
                                        onPressed: _clearFilters,
                                        child: const Text('Clear Filters'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const Divider(height: 1),
                            Expanded(
                              child: _buildStudiesList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Right side: Tabbed Study Details
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
                              decoration: BoxDecoration(
                                color: Colors.yellow[200],
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12),
                                ),
                              ),
                              child: TabBar(
                                controller: _tabController,
                                labelColor: Colors.black,
                                unselectedLabelColor: Colors.grey[600],
                                indicatorColor: Colors.black,
                                labelStyle: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                unselectedLabelStyle: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                tabs: const [
                                  Tab(text: 'Study Summary'),
                                  Tab(text: 'Detailed Times'),
                                ],
                              ),
                            ),
                            Expanded(
                              child: TabBarView(
                                controller: _tabController,
                                children: [
                                  _buildStudySummaryTab(),
                                  _buildDetailedTimesTab(),
                                ],
                              ),
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
    );
  }

  Widget _buildStudiesList() {
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
              onPressed: _loadStudies,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_studies.isEmpty) {
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
              'No time studies found',
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
      itemCount: _filteredStudies.length,
      itemBuilder: (context, index) {
        final study = _filteredStudies[index];
        final isSelected = _selectedStudy?.studyId == study.studyId;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          color: isSelected ? Colors.yellow[100] : Colors.white,
          elevation: isSelected ? 4 : 1,
          child: ListTile(
            title: Text(
              '${study.setupName} - ${study.partNumber}',
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
                        '${study.studyDate.month}/${study.studyDate.day}/${study.studyDate.year}'),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInfoRow('Observer:', study.observerName),
                  ),
                ],
              ),
            ),
            contentPadding: const EdgeInsets.all(16),
            onTap: () => _selectStudy(study),
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
          width: 60,
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

  Widget _buildStudySummaryTab() {
    if (_selectedStudy == null) {
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
              'Select a study to view summary',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    final study = _selectedStudy!;

    return Column(
      children: [
        // Study Header
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
                study.setupName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildHeaderInfo('Part Number', study.partNumber),
                  ),
                  Expanded(
                    child: _buildHeaderInfo('Observer', study.observerName),
                  ),
                  Expanded(
                    child: _buildHeaderInfo('Date',
                        '${study.studyDate.month}/${study.studyDate.day}/${study.studyDate.year}'),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Elements Table (Summary from Setup Element Viewer)
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildElementsTable(study.elements),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailedTimesTab() {
    if (_selectedStudy == null) {
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
              'Select a study to view detailed times',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    final study = _selectedStudy!;

    return Column(
      children: [
        // Study Header
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
                study.setupName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildHeaderInfo('Part Number', study.partNumber),
                  ),
                  Expanded(
                    child: _buildHeaderInfo('Observer', study.observerName),
                  ),
                  Expanded(
                    child: _buildHeaderInfo('Date',
                        '${study.studyDate.month}/${study.studyDate.day}/${study.studyDate.year}'),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Detailed Times Table (from Time Study Viewer)
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildLapsTable(study.elementLaps, study.setupElements),
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

  // Elements Table from Setup Element Viewer (Study Summary)
  Widget _buildElementsTable(List<SetupElement> elements) {
    if (elements.isEmpty) {
      return const Center(
        child: Text(
          'No elements found for this study',
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
          0: FixedColumnWidth(80), // Order
          1: FlexColumnWidth(4), // Element Name
          2: FlexColumnWidth(1), // Time
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

  // Laps Table from Time Study Viewer (Detailed Times)
  Widget _buildLapsTable(Map<String, List<String>> elementLaps,
      Map<String, SetupElement> setupElements) {
    if (elementLaps.isEmpty) {
      return const Center(
        child: Text(
          'No time studies found for this study',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    }

    // Find the maximum number of laps across all elements
    int maxLaps = elementLaps.values
        .fold(0, (max, laps) => laps.length > max ? laps.length : max);

    List<String> sortedElements = elementLaps.keys.toList()..sort();

    return Column(
      children: [
        // Fixed Header
        Container(
          decoration: BoxDecoration(
            color: Colors.yellow[100],
            border: Border.all(color: Colors.grey[300]!, width: 1),
          ),
          child: Row(
            children: [
              // Fixed Element Name column
              Container(
                width: 400,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(color: Colors.grey[300]!, width: 1),
                  ),
                ),
                child: const Text(
                  'Element Name',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              // Scrollable header columns
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Lap columns
                      ...List.generate(
                        maxLaps,
                        (index) => Container(
                          width: 80,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border(
                              right: BorderSide(
                                  color: Colors.grey[300]!, width: 1),
                            ),
                          ),
                          child: Text(
                            'Lap ${index + 1}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      // LRT Time column
                      Container(
                        width: 80,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border(
                            right:
                                BorderSide(color: Colors.grey[300]!, width: 1),
                          ),
                        ),
                        child: const Text(
                          'LRT Time',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      // Override Time column
                      Container(
                        width: 90,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border(
                            right:
                                BorderSide(color: Colors.grey[300]!, width: 1),
                          ),
                        ),
                        child: const Text(
                          'Override Time',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      // Comments column
                      Container(
                        width: 400,
                        padding: const EdgeInsets.all(12),
                        child: const Text(
                          'Comments',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        // Vertically Scrollable Data Rows
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: sortedElements.asMap().entries.map((entry) {
                final index = entry.key;
                final elementName = entry.value;
                final laps = elementLaps[elementName]!;
                final setupElement = setupElements[elementName];

                return Container(
                  decoration: BoxDecoration(
                    color: index % 2 == 0 ? Colors.white : Colors.grey[50],
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[300]!, width: 1),
                      left: BorderSide(color: Colors.grey[300]!, width: 1),
                      right: BorderSide(color: Colors.grey[300]!, width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Fixed Element Name column
                      Container(
                        width: 400,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border(
                            right:
                                BorderSide(color: Colors.grey[300]!, width: 1),
                          ),
                        ),
                        child: Text(
                          elementName,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                      // Horizontally scrollable data columns
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              // Lap columns
                              ...List.generate(
                                maxLaps,
                                (lapIndex) => Container(
                                  width: 80,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      right: BorderSide(
                                          color: Colors.grey[300]!, width: 1),
                                    ),
                                  ),
                                  child: Text(
                                    lapIndex < laps.length
                                        ? laps[lapIndex]
                                        : '',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                              // LRT Time column
                              Container(
                                width: 80,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  border: Border(
                                    right: BorderSide(
                                        color: Colors.grey[300]!, width: 1),
                                  ),
                                ),
                                child: Text(
                                  setupElement?.lrt ?? '-',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              // Override Time column
                              Container(
                                width: 90,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  border: Border(
                                    right: BorderSide(
                                        color: Colors.grey[300]!, width: 1),
                                  ),
                                ),
                                child: Text(
                                  setupElement?.overrideTime ?? '-',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              // Comments column
                              Container(
                                width: 400,
                                padding: const EdgeInsets.all(12),
                                child: Text(
                                  setupElement?.comments ?? '',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
