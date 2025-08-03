import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:drift/drift.dart' as drift;
import '../database_provider.dart';
import '../logic/app_database.dart';
import '../widgets/app_footer.dart';
import '../widgets/home_button_wrapper.dart';
import 'process_canvas_screen.dart';

class VSDetailScreen extends StatefulWidget {
  final String valueStreamName;
  final int valueStreamId;
  final String companyName;
  final String plantName;

  const VSDetailScreen({
    super.key,
    required this.valueStreamName,
    required this.valueStreamId,
    required this.companyName,
    required this.plantName,
  });

  @override
  State<VSDetailScreen> createState() => _VSDetailScreenState();
}

class _VSDetailScreenState extends State<VSDetailScreen> {
  late AppDatabase db;
  bool _isLoading = true;

  // Value Stream form controllers
  final TextEditingController _monthlyDemandController =
      TextEditingController();
  final TextEditingController _managerEmpIdController = TextEditingController();
  UnitOfMeasure? _selectedUOM;

  // VS Shifts data
  List<VSShift> _vsShifts = [];
  bool _isAddingShift = false;
  final TextEditingController _newShiftNameController = TextEditingController();
  String _calculatedTaktTime = '0:00:00';
  String _timePerUnit = '0:00:00';

  // Editing state
  int? _editingShiftId;
  final Map<String, TextEditingController> _editControllers = {
    'shiftName': TextEditingController(),
    'sun': TextEditingController(),
    'mon': TextEditingController(),
    'tue': TextEditingController(),
    'wed': TextEditingController(),
    'thu': TextEditingController(),
    'fri': TextEditingController(),
    'sat': TextEditingController(),
  };

  // Day controllers for new shift
  final Map<String, TextEditingController> _dayControllers = {
    'sun': TextEditingController(),
    'mon': TextEditingController(),
    'tue': TextEditingController(),
    'wed': TextEditingController(),
    'thu': TextEditingController(),
    'fri': TextEditingController(),
    'sat': TextEditingController(),
  };

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  @override
  void dispose() {
    _monthlyDemandController.dispose();
    _managerEmpIdController.dispose();
    _newShiftNameController.dispose();
    for (var controller in _dayControllers.values) {
      controller.dispose();
    }
    for (var controller in _editControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _initializeScreen() async {
    try {
      db = await DatabaseProvider.getInstance();
      await _loadValueStreamData();
      await _loadVSShifts();
    } catch (e) {
      debugPrint('Error initializing VS detail screen: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadValueStreamData() async {
    try {
      final valueStream = await (db.select(db.valueStreams)
            ..where((vs) => vs.id.equals(widget.valueStreamId)))
          .getSingleOrNull();

      if (valueStream != null && mounted) {
        setState(() {
          _monthlyDemandController.text = valueStream.mDemand?.toString() ?? '';
          _managerEmpIdController.text =
              valueStream.mngrEmpId?.toString() ?? '';
          _selectedUOM = valueStream.uom;
        });
      }
    } catch (e) {
      debugPrint('Error loading value stream data: $e');
    }
  }

  Future<void> _loadVSShifts() async {
    try {
      final shifts = await (db.select(db.vSShifts)
            ..where((vs) => vs.vsId.equals(widget.valueStreamId)))
          .get();

      if (mounted) {
        setState(() {
          _vsShifts = shifts;
          _calculateTaktTime();
        });
      }
    } catch (e) {
      debugPrint('Error loading VS shifts: $e');
    }
  }

  void _calculateTaktTime() {
    int totalMinutes = 0;

    for (final shift in _vsShifts) {
      final List<String?> dayTimes = [
        shift.sun,
        shift.mon,
        shift.tue,
        shift.wed,
        shift.thu,
        shift.fri,
        shift.sat
      ];

      for (final timeString in dayTimes) {
        if (timeString != null && timeString.isNotEmpty) {
          final minutes = _parseTimeToMinutes(timeString);
          totalMinutes += minutes;
        }
      }
    }

    _calculatedTaktTime = _formatMinutesToTime(totalMinutes);

    // Calculate time per unit based on monthly demand
    final monthlyDemand = _monthlyDemandController.text.isNotEmpty
        ? int.tryParse(_monthlyDemandController.text)
        : null;

    if (monthlyDemand != null && monthlyDemand > 0 && totalMinutes > 0) {
      final minutesPerUnit =
          totalMinutes / (monthlyDemand / 4.33); // 4.33 weeks in a month
      _timePerUnit = _formatMinutesToTime(minutesPerUnit.round());
    } else {
      _timePerUnit = '0:00:00';
    }
  }

  int _parseTimeToMinutes(String timeString) {
    try {
      final parts = timeString.split(':');
      if (parts.length >= 2) {
        final hours = int.tryParse(parts[0]) ?? 0;
        final minutes = int.tryParse(parts[1]) ?? 0;
        return (hours * 60) + minutes;
      }
    } catch (e) {
      debugPrint('Error parsing time string: $timeString');
    }
    return 0;
  }

  String _formatMinutesToTime(int totalMinutes) {
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:00';
  }

  Future<void> _saveValueStreamData() async {
    try {
      final monthlyDemand = _monthlyDemandController.text.isNotEmpty
          ? int.tryParse(_monthlyDemandController.text)
          : null;
      final managerEmpId = _managerEmpIdController.text.isNotEmpty
          ? int.tryParse(_managerEmpIdController.text)
          : null;

      await (db.update(db.valueStreams)
            ..where((vs) => vs.id.equals(widget.valueStreamId)))
          .write(ValueStreamsCompanion(
        mDemand: monthlyDemand != null
            ? drift.Value(monthlyDemand)
            : const drift.Value.absent(),
        uom: _selectedUOM != null
            ? drift.Value(_selectedUOM)
            : const drift.Value.absent(),
        mngrEmpId: managerEmpId != null
            ? drift.Value(managerEmpId)
            : const drift.Value.absent(),
        taktTime:
            drift.Value(_timePerUnit), // Save the calculated takt time (time per unit)
      ));

      // Recalculate takt time and time per unit after saving monthly demand
      if (mounted) {
        setState(() {
          _calculateTaktTime();
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Value Stream data saved successfully')),
        );
      }
    } catch (e) {
      debugPrint('Error saving value stream data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error saving value stream data')),
        );
      }
    }
  }

  Future<void> _addNewShift() async {
    if (_newShiftNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a shift name')),
      );
      return;
    }

    try {
      final companion = VSShiftsCompanion(
        vsId: drift.Value(widget.valueStreamId),
        shiftName: drift.Value(_newShiftNameController.text.trim()),
        sun: _dayControllers['sun']!.text.isNotEmpty
            ? drift.Value(_dayControllers['sun']!.text)
            : const drift.Value.absent(),
        mon: _dayControllers['mon']!.text.isNotEmpty
            ? drift.Value(_dayControllers['mon']!.text)
            : const drift.Value.absent(),
        tue: _dayControllers['tue']!.text.isNotEmpty
            ? drift.Value(_dayControllers['tue']!.text)
            : const drift.Value.absent(),
        wed: _dayControllers['wed']!.text.isNotEmpty
            ? drift.Value(_dayControllers['wed']!.text)
            : const drift.Value.absent(),
        thu: _dayControllers['thu']!.text.isNotEmpty
            ? drift.Value(_dayControllers['thu']!.text)
            : const drift.Value.absent(),
        fri: _dayControllers['fri']!.text.isNotEmpty
            ? drift.Value(_dayControllers['fri']!.text)
            : const drift.Value.absent(),
        sat: _dayControllers['sat']!.text.isNotEmpty
            ? drift.Value(_dayControllers['sat']!.text)
            : const drift.Value.absent(),
      );

      await db.into(db.vSShifts).insert(companion);

      // Clear form
      _newShiftNameController.clear();
      for (final controller in _dayControllers.values) {
        controller.clear();
      }

      // Reload shifts
      await _loadVSShifts();

      // Don't close the form - let user add another shift if they want
      // Clear the form but keep it open
      // setState is not needed here as _loadVSShifts already triggers a rebuild

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Shift added successfully')),
        );
      }
    } catch (e) {
      debugPrint('Error adding new shift: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding new shift: $e')),
        );
      }
    }
  }

  Future<void> _deleteShift(int shiftId) async {
    try {
      await (db.delete(db.vSShifts)..where((vs) => vs.id.equals(shiftId))).go();
      await _loadVSShifts();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Shift deleted successfully')),
        );
      }
    } catch (e) {
      debugPrint('Error deleting shift: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error deleting shift')),
        );
      }
    }
  }

  void _startEditingShift(VSShift shift) {
    setState(() {
      _editingShiftId = shift.id;
      _editControllers['shiftName']!.text = shift.shiftName;
      _editControllers['sun']!.text = shift.sun ?? '';
      _editControllers['mon']!.text = shift.mon ?? '';
      _editControllers['tue']!.text = shift.tue ?? '';
      _editControllers['wed']!.text = shift.wed ?? '';
      _editControllers['thu']!.text = shift.thu ?? '';
      _editControllers['fri']!.text = shift.fri ?? '';
      _editControllers['sat']!.text = shift.sat ?? '';
    });
  }

  void _cancelEditingShift() {
    setState(() {
      _editingShiftId = null;
      // Clear edit controllers
      for (var controller in _editControllers.values) {
        controller.clear();
      }
    });
  }

  Future<void> _saveEditingShift() async {
    if (_editingShiftId == null) return;

    if (_editControllers['shiftName']!.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a shift name')),
      );
      return;
    }

    try {
      final companion = VSShiftsCompanion(
        id: drift.Value(_editingShiftId!),
        vsId: drift.Value(widget.valueStreamId),
        shiftName: drift.Value(_editControllers['shiftName']!.text.trim()),
        sun: _editControllers['sun']!.text.isNotEmpty
            ? drift.Value(_editControllers['sun']!.text)
            : const drift.Value.absent(),
        mon: _editControllers['mon']!.text.isNotEmpty
            ? drift.Value(_editControllers['mon']!.text)
            : const drift.Value.absent(),
        tue: _editControllers['tue']!.text.isNotEmpty
            ? drift.Value(_editControllers['tue']!.text)
            : const drift.Value.absent(),
        wed: _editControllers['wed']!.text.isNotEmpty
            ? drift.Value(_editControllers['wed']!.text)
            : const drift.Value.absent(),
        thu: _editControllers['thu']!.text.isNotEmpty
            ? drift.Value(_editControllers['thu']!.text)
            : const drift.Value.absent(),
        fri: _editControllers['fri']!.text.isNotEmpty
            ? drift.Value(_editControllers['fri']!.text)
            : const drift.Value.absent(),
        sat: _editControllers['sat']!.text.isNotEmpty
            ? drift.Value(_editControllers['sat']!.text)
            : const drift.Value.absent(),
      );

      await (db.update(db.vSShifts)
            ..where((vs) => vs.id.equals(_editingShiftId!)))
          .write(companion);

      // Clear editing state
      setState(() {
        _editingShiftId = null;
      });

      // Reload shifts to refresh display and recalculate takt time
      await _loadVSShifts();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Shift updated successfully')),
        );
      }
    } catch (e) {
      debugPrint('Error updating shift: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating shift: $e')),
        );
      }
    }
  }

  Widget _buildValueStreamInfoSection() {
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
          // Title with Value Stream Name
          Row(
            children: [
              Text(
                'Value Stream Information for: ',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              Text(
                widget.valueStreamName,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Monthly Demand, UOM, Manager ID, Save Button, and Takt Time in a single row
          Row(
            children: [
              // Monthly Demand
              Expanded(
                flex: 1,
                child: TextField(
                  controller: _monthlyDemandController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Monthly Demand',
                    border: OutlineInputBorder(),
                    hintText: 'Enter quantity',
                    isDense: true,
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Unit of Measure Dropdown
              Expanded(
                flex: 1,
                child: DropdownButtonFormField<UnitOfMeasure>(
                  value: _selectedUOM,
                  decoration: const InputDecoration(
                    labelText: 'Unit of Measure',
                    border: OutlineInputBorder(),
                    isDense: true,
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: UnitOfMeasure.values.map((uom) {
                    return DropdownMenuItem<UnitOfMeasure>(
                      value: uom,
                      child: Text(uom.displayName),
                    );
                  }).toList(),
                  onChanged: (UnitOfMeasure? newValue) {
                    setState(() {
                      _selectedUOM = newValue;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),

              // Manager Employee ID (Optional)
              Expanded(
                flex: 1,
                child: TextField(
                  controller: _managerEmpIdController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Manager ID (Optional)',
                    border: OutlineInputBorder(),
                    hintText: 'ID',
                    isDense: true,
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Save Button (moved before Takt Time and reduced size)
              ElevatedButton(
                onPressed: _saveValueStreamData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow[600],
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                ),
                child: const Text('Save VS Info'),
              ),
              const SizedBox(width: 12),

              // Takt Time Label with calculated value and time per unit (moved after Save button)
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[800],
                          ),
                          children: [
                            const TextSpan(text: 'Total Time: '),
                            TextSpan(
                              text: _calculatedTaktTime,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[800],
                          ),
                          children: [
                            const TextSpan(text: 'Takt Time: '),
                            TextSpan(
                              text: _timePerUnit,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVSShiftsSection() {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Value Stream Shifts',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    'Enter the exact amount of working time per day. Do not include break and lunch time (HH:MM:SS format or leave blank)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _isAddingShift = !_isAddingShift;
                  });
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Shift'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isAddingShift) ...[
            _buildAddShiftForm(),
            if (_vsShifts.isNotEmpty) const SizedBox(height: 16),
          ],
          if (_vsShifts.isEmpty && !_isAddingShift)
            const Center(
              child: Text(
                'No shifts defined yet. Click "Add Shift" to create one.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
          if (_vsShifts.isNotEmpty) _buildShiftsTable(),
        ],
      ),
    );
  }

  Widget _buildAddShiftForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.yellow[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.yellow[300]!),
      ),
      child: Column(
        children: [
          _buildShiftNameAndDayInputs(),
        ],
      ),
    );
  }

  Widget _buildShiftNameAndDayInputs() {
    final days = [
      {'key': 'sun', 'label': 'Sunday'},
      {'key': 'mon', 'label': 'Monday'},
      {'key': 'tue', 'label': 'Tuesday'},
      {'key': 'wed', 'label': 'Wednesday'},
      {'key': 'thu', 'label': 'Thursday'},
      {'key': 'fri', 'label': 'Friday'},
      {'key': 'sat', 'label': 'Saturday'},
    ];

    return Column(
      children: [
        // Shift Name, Day inputs, and buttons in the same row
        Row(
          children: [
            // Shift Name
            Expanded(
              flex: 2,
              child: TextField(
                controller: _newShiftNameController,
                style: const TextStyle(
                    fontSize: 14), // Reduced font size to match day fields
                decoration: const InputDecoration(
                  labelText: 'Shift Name',
                  labelStyle:
                      TextStyle(fontSize: 14), // Reduced label font size
                  border: OutlineInputBorder(),
                  hintText: 'e.g., Day Shift, Night Shift',
                  hintStyle: TextStyle(fontSize: 14), // Reduced hint font size
                  isDense: true,
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Day time inputs (reduced flex to make room for buttons)
            ...days.map((day) {
              return Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: TextField(
                    controller: _dayControllers[day['key']]!,
                    decoration: InputDecoration(
                      labelText:
                          day['label']!.substring(0, 3), // Show first 3 letters
                      border: const OutlineInputBorder(),
                      hintText: '08:00:00',
                      isDense: true,
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9:]')),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(width: 8),
            // Cancel Button
            TextButton(
              onPressed: () {
                setState(() {
                  _isAddingShift = false;
                });
                _newShiftNameController.clear();
                for (var controller in _dayControllers.values) {
                  controller.clear();
                }
              },
              child: const Text('Cancel'),
            ),
            const SizedBox(width: 4),
            // Add Shift Button
            ElevatedButton(
              onPressed: _addNewShift,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow[600],
              ),
              child: const Text('Add Shift'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildShiftsTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Shift Name')),
          DataColumn(label: Text('Sun')),
          DataColumn(label: Text('Mon')),
          DataColumn(label: Text('Tue')),
          DataColumn(label: Text('Wed')),
          DataColumn(label: Text('Thu')),
          DataColumn(label: Text('Fri')),
          DataColumn(label: Text('Sat')),
          DataColumn(label: Text('Actions')),
        ],
        rows: _vsShifts.map((shift) {
          final isEditing = _editingShiftId == shift.id;

          return DataRow(
            cells: [
              // Shift Name
              DataCell(
                isEditing
                    ? SizedBox(
                        width: 120,
                        child: TextField(
                          controller: _editControllers['shiftName']!,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            isDense: true,
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                      )
                    : Text(shift.shiftName),
              ),
              // Sunday
              DataCell(
                isEditing
                    ? SizedBox(
                        width: 80,
                        child: TextField(
                          controller: _editControllers['sun']!,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: '08:00:00',
                            isDense: true,
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9:]')),
                          ],
                        ),
                      )
                    : Text(shift.sun ?? '-'),
              ),
              // Monday
              DataCell(
                isEditing
                    ? SizedBox(
                        width: 80,
                        child: TextField(
                          controller: _editControllers['mon']!,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: '08:00:00',
                            isDense: true,
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9:]')),
                          ],
                        ),
                      )
                    : Text(shift.mon ?? '-'),
              ),
              // Tuesday
              DataCell(
                isEditing
                    ? SizedBox(
                        width: 80,
                        child: TextField(
                          controller: _editControllers['tue']!,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: '08:00:00',
                            isDense: true,
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9:]')),
                          ],
                        ),
                      )
                    : Text(shift.tue ?? '-'),
              ),
              // Wednesday
              DataCell(
                isEditing
                    ? SizedBox(
                        width: 80,
                        child: TextField(
                          controller: _editControllers['wed']!,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: '08:00:00',
                            isDense: true,
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9:]')),
                          ],
                        ),
                      )
                    : Text(shift.wed ?? '-'),
              ),
              // Thursday
              DataCell(
                isEditing
                    ? SizedBox(
                        width: 80,
                        child: TextField(
                          controller: _editControllers['thu']!,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: '08:00:00',
                            isDense: true,
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9:]')),
                          ],
                        ),
                      )
                    : Text(shift.thu ?? '-'),
              ),
              // Friday
              DataCell(
                isEditing
                    ? SizedBox(
                        width: 80,
                        child: TextField(
                          controller: _editControllers['fri']!,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: '08:00:00',
                            isDense: true,
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9:]')),
                          ],
                        ),
                      )
                    : Text(shift.fri ?? '-'),
              ),
              // Saturday
              DataCell(
                isEditing
                    ? SizedBox(
                        width: 80,
                        child: TextField(
                          controller: _editControllers['sat']!,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: '08:00:00',
                            isDense: true,
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9:]')),
                          ],
                        ),
                      )
                    : Text(shift.sat ?? '-'),
              ),
              // Actions
              DataCell(
                isEditing
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.save, color: Colors.green),
                            onPressed: _saveEditingShift,
                            tooltip: 'Save',
                          ),
                          IconButton(
                            icon:
                                const Icon(Icons.cancel, color: Colors.orange),
                            onPressed: _cancelEditingShift,
                            tooltip: 'Cancel',
                          ),
                        ],
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _startEditingShift(shift),
                            tooltip: 'Edit',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _showDeleteConfirmation(shift.id),
                            tooltip: 'Delete',
                          ),
                        ],
                      ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  void _showDeleteConfirmation(int shiftId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Shift'),
          content: const Text('Are you sure you want to delete this shift?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteShift(shiftId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return HomeButtonWrapper(
      child: Scaffold(
        appBar: AppBar(
          title: Text('${widget.valueStreamName} Details'),
          backgroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.dashboard_outlined),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProcessCanvasScreen(
                      valueStreamId: widget.valueStreamId,
                      valueStreamName: widget.valueStreamName,
                    ),
                  ),
                );
              },
              tooltip: 'Process Canvas',
            ),
          ],
        ),
        backgroundColor: Colors.yellow[100],
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Top half: Value Stream Information
                    _buildValueStreamInfoSection(),
                    const SizedBox(height: 16),

                    // Bottom half: VS Shifts
                    _buildVSShiftsSection(),
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
}
