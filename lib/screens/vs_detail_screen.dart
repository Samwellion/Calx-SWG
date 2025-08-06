import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:drift/drift.dart' as drift;
import '../database_provider.dart';
import '../logic/app_database.dart';
import '../widgets/app_footer.dart';
import '../widgets/home_button_wrapper.dart';

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
      await Future.wait([
        _loadValueStreamData(),
        _loadVSShifts(),
      ]);
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar('Failed to initialize screen: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _loadValueStreamData() async {
    try {
      final valueStream = await _getValueStreamById(widget.valueStreamId);
      
      if (valueStream != null && mounted) {
        _updateValueStreamForm(valueStream);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar('Failed to load value stream data: $e');
      }
    }
  }

  Future<ValueStream?> _getValueStreamById(int id) async {
    return await (db.select(db.valueStreams)
          ..where((vs) => vs.id.equals(id)))
        .getSingleOrNull();
  }

  void _updateValueStreamForm(ValueStream valueStream) {
    setState(() {
      _monthlyDemandController.text = valueStream.mDemand?.toString() ?? '';
      _managerEmpIdController.text = valueStream.mngrEmpId?.toString() ?? '';
      _selectedUOM = valueStream.uom;
    });
  }

  Future<void> _loadVSShifts() async {
    try {
      final shifts = await _getVSShiftsByValueStreamId(widget.valueStreamId);
      
      if (mounted) {
        setState(() {
          _vsShifts = shifts;
          _calculateTaktTime();
        });
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar('Failed to load shifts: $e');
      }
    }
  }

  Future<List<VSShift>> _getVSShiftsByValueStreamId(int valueStreamId) async {
    return await (db.select(db.vSShifts)
          ..where((vs) => vs.vsId.equals(valueStreamId)))
        .get();
  }

  void _calculateTaktTime() {
    final totalMinutes = _calculateTotalWorkingMinutes();
    _timePerUnit = _calculateTimePerUnit(totalMinutes);
  }

  int _calculateTotalWorkingMinutes() {
    int totalMinutes = 0;

    for (final shift in _vsShifts) {
      final dayTimes = _getShiftDayTimes(shift);
      
      for (final timeString in dayTimes) {
        if (timeString != null && timeString.isNotEmpty) {
          totalMinutes += _parseTimeToMinutes(timeString);
        }
      }
    }

    return totalMinutes;
  }

  List<String?> _getShiftDayTimes(VSShift shift) {
    return [
      shift.sun,
      shift.mon,
      shift.tue,
      shift.wed,
      shift.thu,
      shift.fri,
      shift.sat,
    ];
  }

  String _calculateTimePerUnit(int totalMinutes) {
    final monthlyDemand = _getMonthlyDemandFromController();

    if (monthlyDemand != null && monthlyDemand > 0 && totalMinutes > 0) {
      final minutesPerUnit = totalMinutes / (monthlyDemand / 4.33); // 4.33 weeks in a month
      return _formatMinutesToTime(minutesPerUnit.round());
    }
    
    return '0:00:00';
  }

  int? _getMonthlyDemandFromController() {
    return _monthlyDemandController.text.isNotEmpty
        ? int.tryParse(_monthlyDemandController.text)
        : null;
  }

  int _parseTimeToMinutes(String timeString) {
    try {
      final trimmedTime = timeString.trim();
      if (trimmedTime.isEmpty) return 0;
      
      final parts = trimmedTime.split(':');
      if (parts.length >= 2) {
        final hours = int.tryParse(parts[0]) ?? 0;
        final minutes = int.tryParse(parts[1]) ?? 0;
        return (hours * 60) + minutes;
      }
    } catch (e) {
      // Silently handle parsing errors by returning 0
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
      final valueStreamData = _buildValueStreamCompanion();
      
      await _updateValueStreamInDatabase(valueStreamData);
      await _recalculateAndUpdateTaktTime();
      
      if (mounted) {
        _showSuccessSnackbar('Value Stream data saved successfully');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar('Error saving value stream data: $e');
      }
    }
  }

  ValueStreamsCompanion _buildValueStreamCompanion() {
    final monthlyDemand = _getMonthlyDemandFromController();
    final managerEmpId = _getManagerEmpIdFromController();

    return ValueStreamsCompanion(
      mDemand: monthlyDemand != null
          ? drift.Value(monthlyDemand)
          : const drift.Value.absent(),
      uom: _selectedUOM != null
          ? drift.Value(_selectedUOM)
          : const drift.Value.absent(),
      mngrEmpId: managerEmpId != null
          ? drift.Value(managerEmpId)
          : const drift.Value.absent(),
      taktTime: drift.Value(_timePerUnit), // Save the calculated takt time (time per unit)
    );
  }

  int? _getManagerEmpIdFromController() {
    return _managerEmpIdController.text.isNotEmpty
        ? int.tryParse(_managerEmpIdController.text)
        : null;
  }

  Future<void> _updateValueStreamInDatabase(ValueStreamsCompanion companion) async {
    await (db.update(db.valueStreams)
          ..where((vs) => vs.id.equals(widget.valueStreamId)))
        .write(companion);
  }

  Future<void> _recalculateAndUpdateTaktTime() async {
    if (mounted) {
      setState(() {
        _calculateTaktTime();
      });
    }
  }

  Future<void> _addNewShift() async {
    if (!_validateShiftName()) return;

    try {
      final companion = _buildNewShiftCompanion();
      await _insertShiftInDatabase(companion);
      await _handleShiftAddSuccess();
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar('Error adding new shift: $e');
      }
    }
  }

  bool _validateShiftName() {
    if (_newShiftNameController.text.trim().isEmpty) {
      _showErrorSnackbar('Please enter a shift name');
      return false;
    }
    return true;
  }

  VSShiftsCompanion _buildNewShiftCompanion() {
    return VSShiftsCompanion(
      vsId: drift.Value(widget.valueStreamId),
      shiftName: drift.Value(_newShiftNameController.text.trim()),
      sun: _buildDayValue('sun'),
      mon: _buildDayValue('mon'),
      tue: _buildDayValue('tue'),
      wed: _buildDayValue('wed'),
      thu: _buildDayValue('thu'),
      fri: _buildDayValue('fri'),
      sat: _buildDayValue('sat'),
    );
  }

  drift.Value<String> _buildDayValue(String day) {
    return _dayControllers[day]!.text.isNotEmpty
        ? drift.Value(_dayControllers[day]!.text)
        : const drift.Value.absent();
  }

  Future<void> _insertShiftInDatabase(VSShiftsCompanion companion) async {
    await db.into(db.vSShifts).insert(companion);
  }

  Future<void> _handleShiftAddSuccess() async {
    _clearNewShiftForm();
    setState(() {
      _isAddingShift = false; // Close the add shift form
    });
    await _loadVSShifts();

    if (mounted) {
      _showSuccessSnackbar('Shift added successfully');
    }
  }

  void _clearNewShiftForm() {
    _newShiftNameController.clear();
    for (final controller in _dayControllers.values) {
      controller.clear();
    }
  }

  Future<void> _deleteShift(int shiftId) async {
    try {
      await _deleteShiftFromDatabase(shiftId);
      await _loadVSShifts();
      
      if (mounted) {
        _showSuccessSnackbar('Shift deleted successfully');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar('Error deleting shift: $e');
      }
    }
  }

  Future<void> _deleteShiftFromDatabase(int shiftId) async {
    await (db.delete(db.vSShifts)..where((vs) => vs.id.equals(shiftId))).go();
  }

  void _startEditingShift(VSShift shift) {
    setState(() {
      _editingShiftId = shift.id;
      _populateEditControllers(shift);
    });
  }

  void _populateEditControllers(VSShift shift) {
    _editControllers['shiftName']!.text = shift.shiftName;
    _editControllers['sun']!.text = shift.sun ?? '';
    _editControllers['mon']!.text = shift.mon ?? '';
    _editControllers['tue']!.text = shift.tue ?? '';
    _editControllers['wed']!.text = shift.wed ?? '';
    _editControllers['thu']!.text = shift.thu ?? '';
    _editControllers['fri']!.text = shift.fri ?? '';
    _editControllers['sat']!.text = shift.sat ?? '';
  }

  void _cancelEditingShift() {
    setState(() {
      _editingShiftId = null;
      _clearEditControllers();
    });
  }

  void _clearEditControllers() {
    for (var controller in _editControllers.values) {
      controller.clear();
    }
  }

  Future<void> _saveEditingShift() async {
    if (_editingShiftId == null) return;
    
    if (!_validateEditShiftName()) return;

    try {
      final companion = _buildEditShiftCompanion();
      await _updateShiftInDatabase(companion);
      await _handleShiftUpdateSuccess();
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar('Error updating shift: $e');
      }
    }
  }

  bool _validateEditShiftName() {
    if (_editControllers['shiftName']!.text.trim().isEmpty) {
      _showErrorSnackbar('Please enter a shift name');
      return false;
    }
    return true;
  }

  VSShiftsCompanion _buildEditShiftCompanion() {
    return VSShiftsCompanion(
      id: drift.Value(_editingShiftId!),
      vsId: drift.Value(widget.valueStreamId),
      shiftName: drift.Value(_editControllers['shiftName']!.text.trim()),
      sun: _buildEditDayValue('sun'),
      mon: _buildEditDayValue('mon'),
      tue: _buildEditDayValue('tue'),
      wed: _buildEditDayValue('wed'),
      thu: _buildEditDayValue('thu'),
      fri: _buildEditDayValue('fri'),
      sat: _buildEditDayValue('sat'),
    );
  }

  drift.Value<String> _buildEditDayValue(String day) {
    return _editControllers[day]!.text.isNotEmpty
        ? drift.Value(_editControllers[day]!.text)
        : const drift.Value.absent();
  }

  Future<void> _updateShiftInDatabase(VSShiftsCompanion companion) async {
    await (db.update(db.vSShifts)
          ..where((vs) => vs.id.equals(_editingShiftId!)))
        .write(companion);
  }

  Future<void> _handleShiftUpdateSuccess() async {
    setState(() {
      _editingShiftId = null;
    });

    await _loadVSShifts();

    if (mounted) {
      _showSuccessSnackbar('Shift updated successfully');
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
                    if (!_isAddingShift) {
                      // Clear form when canceling
                      _newShiftNameController.clear();
                      for (var controller in _dayControllers.values) {
                        controller.clear();
                      }
                    }
                  });
                },
                icon: Icon(_isAddingShift ? Icons.cancel : Icons.add),
                label: Text(_isAddingShift ? 'Cancel' : 'Add Shift'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isAddingShift ? Colors.orange[600] : Colors.yellow[600],
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
