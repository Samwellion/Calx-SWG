import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';
import '../widgets/app_footer.dart';
import '../database_provider.dart';
import '../logic/app_database.dart';

class StudyInfo {
  final int studyId;
  final String setupName;
  final String partNumber;
  final DateTime studyDate;
  final String observerName;
  final List<TaskStudyData> taskStudies;

  StudyInfo({
    required this.studyId,
    required this.setupName,
    required this.partNumber,
    required this.studyDate,
    required this.observerName,
    required this.taskStudies,
  });
}

class TaskStudyViewerScreen extends StatefulWidget {
  const TaskStudyViewerScreen({super.key});

  @override
  State<TaskStudyViewerScreen> createState() => _TaskStudyViewerScreenState();
}

class _TaskStudyViewerScreenState extends State<TaskStudyViewerScreen> {
  List<StudyInfo> _studies = [];
  StudyInfo? _selectedStudy;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStudies();
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

      List<StudyInfo> studies = [];

      for (final study in allStudies) {
        // Get setup info for this study
        final setup = await (db.select(db.setups)
              ..where((s) => s.id.equals(study.setupId)))
            .getSingleOrNull();

        if (setup == null) continue;

        // Get process part info for the setup
        final processPart = await (db.select(db.processParts)
              ..where((pp) => pp.id.equals(setup.processPartId)))
            .getSingleOrNull();

        if (processPart == null) continue;

        // Get all task studies for this study
        final taskStudies = await (db.select(db.taskStudy)
              ..where((ts) => ts.studyId.equals(study.id)))
            .get();

        if (taskStudies.isEmpty) continue;

        studies.add(StudyInfo(
          studyId: study.id,
          setupName: setup.setupName,
          partNumber: processPart.partNumber,
          studyDate: study.date,
          observerName: study.observerName,
          taskStudies: taskStudies,
        ));
      }

      // Sort by study date (most recent first)
      studies.sort((a, b) => b.studyDate.compareTo(a.studyDate));

      setState(() {
        _studies = studies;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error loading task studies: $e';
        _isLoading = false;
      });
    }
  }

  void _selectStudy(StudyInfo study) {
    setState(() {
      _selectedStudy = study;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Study Viewer'),
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
                                'Task Studies',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              child: _buildStudiesList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Right side: Study Details
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
                                'Study Details',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              child: _buildTaskStudyDetailsTable(),
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
              'No task studies found',
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
      itemCount: _studies.length,
      itemBuilder: (context, index) {
        final study = _studies[index];
        final isSelected = _selectedStudy?.studyId == study.studyId;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          color: isSelected ? Colors.yellow[100] : Colors.white,
          elevation: isSelected ? 4 : 1,
          child: ListTile(
            title: Text(
              study.setupName,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 16,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('Part Number:', study.partNumber),
                  const SizedBox(height: 4),
                  _buildInfoRow('Date:',
                      '${study.studyDate.day}/${study.studyDate.month}/${study.studyDate.year}'),
                  const SizedBox(height: 4),
                  _buildInfoRow('Observer:', study.observerName),
                  const SizedBox(height: 4),
                  _buildInfoRow('Tasks:', '${study.taskStudies.length}'),
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

  Widget _buildTaskStudyDetailsTable() {
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
              'Select a study to view task details',
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
                        '${study.studyDate.day}/${study.studyDate.month}/${study.studyDate.year}'),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Task Studies Table
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildTaskStudiesTable(study.taskStudies),
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

  Widget _buildTaskStudiesTable(List<TaskStudyData> taskStudies) {
    if (taskStudies.isEmpty) {
      return const Center(
        child: Text(
          'No task studies found for this study',
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
          0: FlexColumnWidth(3), // Task Name
          1: FlexColumnWidth(2), // LRT Time
          2: FlexColumnWidth(2), // Override Time
          3: FlexColumnWidth(3), // Comments
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
                    'Task Name',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              TableCell(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    'LRT Time',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              TableCell(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    'Override Time',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              TableCell(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    'Comments',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          // Data Rows
          ...taskStudies.asMap().entries.map((entry) {
            final index = entry.key;
            final task = entry.value;
            return TableRow(
              decoration: BoxDecoration(
                color: index % 2 == 0 ? Colors.white : Colors.grey[50],
              ),
              children: [
                TableCell(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(task.taskName),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      task.lrt,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      task.overrideTime ?? '-',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(task.comments ?? ''),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
