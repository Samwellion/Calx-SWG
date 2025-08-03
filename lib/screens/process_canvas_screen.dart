import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:drift/drift.dart' hide Column;
import 'dart:convert';
import '../database_provider.dart';
import '../logic/app_database.dart';
import '../models/process_object.dart';
import '../models/canvas_icon.dart';
import '../models/canvas_connector.dart';
import '../models/material_connector.dart';
import '../models/kanban_loop.dart';
import '../models/connection_handle.dart';
import '../widgets/draggable_process_widget.dart';
import '../widgets/draggable_canvas_icon.dart';
import '../widgets/customer_data_box.dart';
import '../widgets/supplier_data_box.dart';
import '../widgets/production_control_data_box.dart';
import '../widgets/truck_data_box.dart';
import '../widgets/connector_widget.dart';
import '../widgets/material_connector_widget.dart';
import '../widgets/kanban_loop_widget.dart';
import '../widgets/connection_handle_widget.dart';
import '../widgets/floating_icon_toolbar.dart';
import '../widgets/home_button_wrapper.dart';

class ProcessCanvasScreen extends StatefulWidget {
  final int valueStreamId;
  final String valueStreamName;

  const ProcessCanvasScreen({
    super.key,
    required this.valueStreamId,
    required this.valueStreamName,
  });

  @override
  State<ProcessCanvasScreen> createState() => _ProcessCanvasScreenState();
}

class _ProcessCanvasScreenState extends State<ProcessCanvasScreen>
    with WidgetsBindingObserver {
  List<ProcessObject> processes = [];
  List<CanvasIcon> canvasIcons = [];
  List<CanvasConnector> connectors = []; // Track connectors between items
  List<MaterialConnector> materialConnectors = []; // Track material connectors between processes
  List<KanbanLoop> kanbanLoops = []; // Track kanban loops from supermarkets to suppliers
  Map<String, Offset> customerDataBoxPositions = {}; // Track positions of customer data boxes
  Map<String, Offset> supplierDataBoxPositions = {}; // Track positions of supplier data boxes
  Map<String, Offset> productionControlDataBoxPositions = {}; // Track positions of production control data boxes
  Map<String, Offset> truckDataBoxPositions = {}; // Track positions of truck data boxes
  Map<String, String> supplierDataBoxUserData = {}; // Track user input data for supplier data boxes
  Map<String, String> truckDataBoxUserData = {}; // Track user input data for truck data boxes
  ProcessObject? selectedProcess;
  CanvasIcon? selectedCanvasIcon;
  String? selectedCustomerDataBox;
  String? selectedSupplierDataBox;
  String? selectedProductionControlDataBox;
  String? selectedTruckDataBox;
  String? selectedConnector; // Track selected connector
  String? selectedMaterialConnector; // Track selected material connector
  String? selectedKanbanLoop; // Track selected kanban loop
  ConnectionMode connectionMode = ConnectionMode.none; // Track connection mode
  ConnectorEndpoint? pendingConnection; // Track first item when connecting
  ConnectorType currentConnectorType = ConnectorType.information; // Track current connector type being created
  
  // Connection handle state
  String? selectedItemForHandles; // Which item is showing handles
  String? selectedItemType; // Type of item showing handles
  ConnectionHandle? selectedHandle; // Currently selected handle
  bool showConnectionHandles = false; // Show/hide handles
  
  String? currentPartNumber; // Track current part number for canvas state
  bool isLoading = true;
  CanvasIconType? pendingMaterialConnectorType; // Type of material connector being created
  ProcessObject? pendingSupplierProcess; // Track supplier process for material connector
  ProcessObject? pendingCustomerProcess; // Track customer process for material connector
  
  // Kanban loop creation state
  String? pendingSupermarketId; // Track selected supermarket for kanban loop
  ProcessObject? pendingKanbanSupplierProcess; // Track supplier process for kanban loop
  late AppDatabase db;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeDatabase();
  }

  @override
  void dispose() {
    // Save canvas state before disposing
    _saveCanvasState();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Force refresh when dependencies change (e.g., when navigating back)
    if (mounted && !isLoading) {
      _loadProcesses();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh data when app comes back to foreground
      _loadProcesses();
    } else if (state == AppLifecycleState.paused || 
               state == AppLifecycleState.detached ||
               state == AppLifecycleState.inactive) {
      // Save canvas state when app is backgrounded or closed
      _saveCanvasState();
    }
  }

  Future<void> _initializeDatabase() async {
    db = await DatabaseProvider.getInstance();
    await _loadProcesses();
  }

  /// Force refresh all process data - called when screen gains focus or data changes
  Future<void> refreshProcessData() async {
    await _loadProcesses();
  }

  Future<void> _loadProcesses() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Clear existing processes to ensure fresh data
      processes.clear();
      selectedProcess = null;

      // Force fresh database queries for all process data
      final processEntries =
          await db.getProcessesForValueStream(widget.valueStreamId);

      // Get selected part number from shared preferences (always fresh)
      final partNumber = await db.getSelectedPartNumber();

      if (partNumber == null || partNumber.isEmpty) {
        setState(() {
          isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No part number selected. Please select a part number first.')),
          );
        }
        return;
      }

      List<ProcessObject> processObjects = [];

      for (final processEntry in processEntries) {
        ProcessPart? processPart;

        // Always fetch fresh process part data for the selected part
        processPart = await db.getProcessPartByPartNumberAndProcessId(
            partNumber, processEntry.id);

        // Only create a new ProcessPart record if one doesn't exist at all
        // This preserves any existing process time data
        if (processPart == null) {
          // Create a new ProcessPart record for this part-process combination
          await db.into(db.processParts).insert(ProcessPartsCompanion.insert(
            partNumber: partNumber,
            processId: processEntry.id,
            dailyDemand: const Value.absent(),
            processTime: const Value.absent(), // Will show as N/A until user enters data
            fpy: const Value.absent(),
          ));

          // Fetch the newly created ProcessPart
          processPart = await db.getProcessPartByPartNumberAndProcessId(
              partNumber, processEntry.id);
        }

        // Create ProcessObject with refreshed data from database
        final processObjectData = ProcessObjectData(
          process: processEntry,
          processPart: processPart,
          calculatedCycleTime: null, // Use specific part data only
        );

        var processObject = ProcessObject.fromProcessData(processObjectData);

        // Ensure processes have valid positions - if they're at default (100,100) or invalid positions,
        // place them in a grid pattern to make them visible
        if (processObject.position.dx < 0 ||
            processObject.position.dy < 0 ||
            (processObject.position.dx == 100 &&
                processObject.position.dy == 100)) {
          final index = processObjects.length;
          final gridX = 50 + (index % 3) * 250; // 3 columns
          final gridY = 50 + (index ~/ 3) * 350; // New row every 3 processes

          processObject = processObject.copyWith(
              position: Offset(gridX.toDouble(), gridY.toDouble()));

          // Update the database with the new position
          await db.updateProcessPosition(
            processObject.id,
            processObject.position.dx,
            processObject.position.dy,
          );
        }

        processObjects.add(processObject);
      }

      setState(() {
        processes = processObjects;
        currentPartNumber = partNumber;
        isLoading = false;
      });

      // Load canvas state for this value stream and part
      await _loadCanvasState(partNumber);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Loaded ${processObjects.length} processes for part $partNumber')),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading processes: $e')),
        );
      }
    }
  }

  Future<void> _updateProcessPositionFromGlobal(ProcessObject process,
      Offset globalOffset, BoxConstraints constraints) async {
    try {
      // Convert global position to local canvas coordinates
      final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
      if (renderBox == null) return;

      final localOffset = renderBox.globalToLocal(globalOffset);

      // Apply boundary checking to keep objects within the canvas
      final processWidth = process.size.width;
      final processHeight = process.size.height;

      double newX =
          localOffset.dx.clamp(0, constraints.maxWidth - processWidth);
      double newY =
          localOffset.dy.clamp(0, constraints.maxHeight - processHeight);

      final boundedPosition = Offset(newX, newY);

      await db.updateProcessPosition(
        process.id,
        boundedPosition.dx,
        boundedPosition.dy,
      );

      setState(() {
        final index = processes.indexWhere((p) => p.id == process.id);
        if (index != -1) {
          processes[index] = process.copyWith(
            position: boundedPosition,
          );
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating process position: $e')),
        );
      }
    }
  }

  Future<void> _updateProcessPosition(
      ProcessObject process, Offset newPosition) async {
    try {
      await db.updateProcessPosition(
        process.id,
        newPosition.dx,
        newPosition.dy,
      );

      // Refresh the specific process object with latest data to ensure all fields are current
      final processEntry = await db.getProcessesForValueStream(widget.valueStreamId);
      final updatedProcessEntry = processEntry.firstWhere((p) => p.id == process.id);
      
      final partNumber = await db.getSelectedPartNumber();
      ProcessPart? processPart;
      if (partNumber != null) {
        processPart = await db.getProcessPartByPartNumberAndProcessId(
            partNumber, updatedProcessEntry.id);
      }
      
      final calculatedCycleTime =
          await db.calculateAverageCycleTimeForProcess(updatedProcessEntry.id);

      final processObjectData = ProcessObjectData(
        process: updatedProcessEntry,
        processPart: processPart,
        calculatedCycleTime: calculatedCycleTime,
      );

      final updatedProcessObject = ProcessObject.fromProcessData(processObjectData)
          .copyWith(position: newPosition);

      setState(() {
        final index = processes.indexWhere((p) => p.id == process.id);
        if (index != -1) {
          processes[index] = updatedProcessObject;
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating process position: $e')),
        );
      }
    }
  }

  Future<void> _resetProcessPositions() async {
    try {
      setState(() {
        isLoading = true;
      });

      // Reset all process positions to a grid layout
      for (int i = 0; i < processes.length; i++) {
        final process = processes[i];
        final gridX = 50 + (i % 3) * 250; // 3 columns
        final gridY = 50 + (i ~/ 3) * 350; // New row every 3 processes

        final newPosition = Offset(gridX.toDouble(), gridY.toDouble());

        // Update database
        await db.updateProcessPosition(
          process.id,
          newPosition.dx,
          newPosition.dy,
        );

        // Update local state
        processes[i] = process.copyWith(position: newPosition);
      }

      setState(() {
        isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Reset ${processes.length} process positions to grid layout')),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error resetting positions: $e')),
        );
      }
    }
  }

  void _selectProcess(ProcessObject? process) {
    if (process != null && (connectionMode == ConnectionMode.selecting || connectionMode == ConnectionMode.connecting)) {
      // Handle connection mode
      _handleItemTapForConnection(
        process.id.toString(),
        'process',
        process.position,
        process.size,
      );
    } else if (process != null && connectionMode == ConnectionMode.materialConnectorSelecting) {
      // Handle material connector supplier selection
      
      // First show immediate feedback
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Supplier "${process.name}" selected. Now selecting customer...'),
          duration: const Duration(milliseconds: 1500),
        ),
      );
      
      setState(() {
        pendingSupplierProcess = process;
        connectionMode = ConnectionMode.materialConnectorConnecting;
      });
      
      // Show customer selection instruction after a brief delay
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && connectionMode == ConnectionMode.materialConnectorConnecting) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Now tap the customer process to create the material connector.'),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      });
    } else if (process != null && connectionMode == ConnectionMode.materialConnectorConnecting) {
      // Handle material connector customer selection
      
      if (pendingSupplierProcess != null && process.id != pendingSupplierProcess!.id) {
        _createMaterialConnector(pendingSupplierProcess!, process);
      } else if (process.id == pendingSupplierProcess!.id) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a different process for the customer.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else if (process != null && connectionMode == ConnectionMode.kanbanLoopConnecting) {
      // Handle kanban loop supplier selection - show connection handles for precise connection
      if (pendingSupermarketId != null) {
        _showConnectionHandles(process.id.toString(), 'process');
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Select a connection handle on the supplier process.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } else {
      // Normal selection mode
      setState(() {
        selectedProcess = process;
        // Clear other selections
        selectedCanvasIcon = null;
        selectedCustomerDataBox = null;
        selectedSupplierDataBox = null;
        selectedProductionControlDataBox = null;
        selectedTruckDataBox = null;
        selectedConnector = null;
      });
    }
  }

  Future<void> _showProcessOptions(ProcessObject process) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Process'),
                onTap: () => Navigator.pop(context, 'edit'),
              ),
              ListTile(
                leading: const Icon(Icons.palette),
                title: const Text('Change Color'),
                onTap: () => Navigator.pop(context, 'color'),
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Delete Process'),
                onTap: () => Navigator.pop(context, 'delete'),
              ),
            ],
          ),
        );
      },
    );

    if (result != null) {
      switch (result) {
        case 'edit':
          _showEditProcessDialog(process);
          break;
        case 'color':
          _showColorPicker(process);
          break;
        case 'delete':
          _showDeleteConfirmation(process);
          break;
      }
    }
  }

  Future<void> _showEditProcessDialog(ProcessObject process) async {
    final nameController = TextEditingController(text: process.name);
    final descriptionController =
        TextEditingController(text: process.description);
    final staffController =
        TextEditingController(text: process.staff?.toString() ?? '');
    final dailyDemandController =
        TextEditingController(text: process.dailyDemand?.toString() ?? '');
    final wipController =
        TextEditingController(text: process.wip?.toString() ?? '');
    final uptimeController = TextEditingController(
        text: process.uptime != null
            ? (process.uptime! * 100).toStringAsFixed(1)
            : '');
    final coTimeController = TextEditingController(text: process.coTime ?? '');
    final processTimeController =
        TextEditingController(text: process.processTime ?? '');
    final fpyController = TextEditingController(
        text:
            process.fpy != null ? (process.fpy! * 100).toStringAsFixed(1) : '');

    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Process'),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Process Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: staffController,
                          decoration: const InputDecoration(
                            labelText: 'Staffing',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: dailyDemandController,
                          decoration: const InputDecoration(
                            labelText: 'Daily Demand',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: wipController,
                          decoration: const InputDecoration(
                            labelText: 'WIP',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: uptimeController,
                          decoration: const InputDecoration(
                            labelText: 'Uptime %',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: coTimeController,
                          decoration: const InputDecoration(
                            labelText: 'Changeover Time (HH:MM:SS)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: processTimeController,
                          decoration: const InputDecoration(
                            labelText: 'Cycle Time (HH:MM:SS)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: fpyController,
                    decoration: const InputDecoration(
                      labelText: 'FPY %',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await _updateProcess(
        process,
        name: nameController.text.trim(),
        description: descriptionController.text.trim(),
        staff: int.tryParse(staffController.text.trim()),
        dailyDemand: int.tryParse(dailyDemandController.text.trim()),
        wip: int.tryParse(wipController.text.trim()),
        uptime: double.tryParse(uptimeController.text.trim()),
        coTime: coTimeController.text.trim().isEmpty
            ? null
            : coTimeController.text.trim(),
        processTime: processTimeController.text.trim().isEmpty
            ? null
            : processTimeController.text.trim(),
        fpy: double.tryParse(fpyController.text.trim()),
      );
    }
  }

  Future<void> _showColorPicker(ProcessObject process) async {
    final colors = [
      Colors.blue[100]!,
      Colors.green[100]!,
      Colors.orange[100]!,
      Colors.purple[100]!,
      Colors.pink[100]!,
      Colors.teal[100]!,
      Colors.amber[100]!,
      Colors.cyan[100]!,
    ];

    final selectedColor = await showDialog<Color>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose Color'),
          content: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: colors.map((color) {
              return GestureDetector(
                onTap: () => Navigator.pop(context, color),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );

    if (selectedColor != null) {
      await _updateProcess(process, color: selectedColor);
    }
  }

  Future<void> _showDeleteConfirmation(ProcessObject process) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Process'),
          content: Text('Are you sure you want to delete "${process.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await _deleteProcess(process);
    }
  }

  Future<void> _updateProcess(
    ProcessObject process, {
    String? name,
    String? description,
    Color? color,
    int? staff,
    int? dailyDemand,
    int? wip,
    double? uptime,
    String? coTime,
    String? processTime,
    double? fpy,
  }) async {
    try {
      String? colorHex;
      if (color != null) {
        colorHex = '#${color.value.toRadixString(16).padLeft(8, '0')}';
      }

      // Convert uptime from percentage to decimal
      double? uptimeDecimal;
      if (uptime != null) {
        uptimeDecimal = uptime / 100.0;
      }

      // Convert FPY from percentage to decimal
      double? fpyDecimal;
      if (fpy != null) {
        fpyDecimal = fpy / 100.0;
      }

      // Update process table
      await db.updateProcess(
        process.id,
        name: name,
        description: description,
        colorHex: colorHex,
        staff: staff,
        dailyDemand: dailyDemand,
        wip: wip,
        uptime: uptimeDecimal,
        coTime: coTime,
      );

      // Update process part table if we have process part data and part number
      if (processTime != null || fpy != null) {
        final partNumber = await db.getSelectedPartNumber();
        if (partNumber != null) {
          await db.updateProcessPart(
            partNumber,
            process.id,
            processTime: processTime,
            fpy: fpyDecimal,
          );
        }
      }

      // Reload processes to get updated data - ensure all ProcessObjects reflect latest changes
      await _loadProcesses();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Process updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating process: $e')),
        );
      }
    }
  }

  Future<void> _deleteProcess(ProcessObject process) async {
    try {
      await db.deleteProcess(process.id);

      setState(() {
        processes.removeWhere((p) => p.id == process.id);
        if (selectedProcess?.id == process.id) {
          selectedProcess = null;
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Process deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting process: $e')),
        );
      }
    }
  }

  // Canvas Icon Management Methods
  void _addCanvasIcon(CanvasIconTemplate template) {
    if (template.type == CanvasIconType.customerDataBox) {
      // Create a special customer data box
      final customerId = DateTime.now().millisecondsSinceEpoch.toString();
      setState(() {
        customerDataBoxPositions[customerId] = const Offset(100, 200);
        selectedCustomerDataBox = customerId;
        selectedCanvasIcon = null;
        selectedProcess = null;
      });
      _saveCanvasState(); // Auto-save when canvas state changes
    } else if (template.type == CanvasIconType.supplierDataBox) {
      // Create a special supplier data box
      final supplierId = DateTime.now().millisecondsSinceEpoch.toString();
      setState(() {
        supplierDataBoxPositions[supplierId] = const Offset(100, 100);
        selectedSupplierDataBox = supplierId;
        selectedCanvasIcon = null;
        selectedProcess = null;
      });
      _saveCanvasState(); // Auto-save when canvas state changes
    } else if (template.type == CanvasIconType.productionControlDataBox) {
      // Create a special production control data box
      final productionControlId = DateTime.now().millisecondsSinceEpoch.toString();
      setState(() {
        productionControlDataBoxPositions[productionControlId] = const Offset(100, 50);
        selectedProductionControlDataBox = productionControlId;
        selectedCanvasIcon = null;
        selectedProcess = null;
        selectedCustomerDataBox = null;
        selectedSupplierDataBox = null;
      });
      _saveCanvasState(); // Auto-save when canvas state changes
    } else if (template.type == CanvasIconType.truckDataBox) {
      // Create a special truck data box
      final truckId = DateTime.now().millisecondsSinceEpoch.toString();
      setState(() {
        truckDataBoxPositions[truckId] = const Offset(100, 400);
        selectedTruckDataBox = truckId;
        selectedCanvasIcon = null;
        selectedProcess = null;
        selectedCustomerDataBox = null;
        selectedSupplierDataBox = null;
        selectedProductionControlDataBox = null;
      });
      _saveCanvasState(); // Auto-save when canvas state changes
    } else if (template.type == CanvasIconType.informationArrow) {
      // Handle information arrow selection for connector mode
      _startConnectorMode(ConnectorType.information);
    } else if (template.type == CanvasIconType.electronicArrow) {
      // Handle electronic arrow selection for connector mode
      _startConnectorMode(ConnectorType.electronic);
    } else if (template.type == CanvasIconType.materialArrow) {
      // Handle material arrow selection for connector mode
      _startConnectorMode(ConnectorType.material);
    } else if (template.type == CanvasIconType.materialPush) {
      // Handle material push selection for connector mode
      _startConnectorMode(ConnectorType.materialPush);
    } else if (template.type == CanvasIconType.kanbanLoop) {
      // Handle kanban loop selection - special workflow for supermarket to supplier
      _startKanbanLoopMode();
    } else if (template.type == CanvasIconType.withdrawalLoop) {
      // Handle withdrawal loop selection for connector mode
      _startConnectorMode(ConnectorType.withdrawalLoop);
    } else if (MaterialConnectorHelper.isMaterialConnectorType(template.type)) {
      // Handle material connector types (FIFO, Buffer, etc.)
      _startMaterialConnectorMode(template.type);
    } else {
      // Create a regular canvas icon
      final newIcon = CanvasIcon(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: template.type,
        label: template.label,
        iconData: template.iconData,
        color: template.color,
        position: const Offset(100, 300), // Default position
      );

      setState(() {
        canvasIcons.add(newIcon);
        selectedCanvasIcon = newIcon;
        selectedProcess = null; // Deselect any selected process
        selectedCustomerDataBox = null;
      });
      _saveCanvasState(); // Auto-save when canvas state changes
    }
  }

  void _updateCanvasIconPosition(CanvasIcon icon, Offset newPosition) {
    setState(() {
      final index = canvasIcons.indexWhere((i) => i.id == icon.id);
      if (index != -1) {
        canvasIcons[index] = icon.copyWith(position: newPosition);
      }
    });
    _saveCanvasState(); // Auto-save when position changes
  }

  void _updateCustomerDataBoxPosition(String customerId, Offset newPosition) {
    setState(() {
      customerDataBoxPositions[customerId] = newPosition;
    });
    _saveCanvasState(); // Auto-save when position changes
  }

  void _selectCustomerDataBox(String customerId) {
    if (connectionMode == ConnectionMode.selecting || connectionMode == ConnectionMode.connecting) {
      // Handle connection mode
      final position = customerDataBoxPositions[customerId];
      if (position != null) {
        _handleItemTapForConnection(
          customerId,
          'customer',
          position,
          const Size(180, 150), // Customer data box size
        );
      }
    } else {
      // Normal selection mode
      setState(() {
        selectedCustomerDataBox = customerId;
        selectedProcess = null;
        selectedCanvasIcon = null;
        selectedSupplierDataBox = null;
        selectedProductionControlDataBox = null;
        selectedTruckDataBox = null;
        selectedConnector = null;
      });
    }
  }

  void _deleteCustomerDataBox(String customerId) {
    setState(() {
      customerDataBoxPositions.remove(customerId);
      if (selectedCustomerDataBox == customerId) {
        selectedCustomerDataBox = null;
      }
    });
    _saveCanvasState(); // Auto-save when item is deleted
  }

  void _updateSupplierDataBoxPosition(String supplierId, Offset newPosition) {
    setState(() {
      supplierDataBoxPositions[supplierId] = newPosition;
    });
    _saveCanvasState(); // Auto-save when position changes
  }

  void _updateSupplierDataBoxUserData(String supplierId, String userData) {
    supplierDataBoxUserData[supplierId] = userData;
    _saveCanvasState(); // Auto-save when user data changes
  }

  void _selectSupplierDataBox(String supplierId) {
    if (connectionMode == ConnectionMode.selecting || connectionMode == ConnectionMode.connecting) {
      // Handle connection mode
      final position = supplierDataBoxPositions[supplierId];
      if (position != null) {
        _handleItemTapForConnection(
          supplierId,
          'supplier',
          position,
          const Size(200, 140), // Supplier data box size
        );
      }
    } else {
      // Normal selection mode
      setState(() {
        selectedSupplierDataBox = supplierId;
        selectedProcess = null;
        selectedCanvasIcon = null;
        selectedCustomerDataBox = null;
        selectedProductionControlDataBox = null;
        selectedTruckDataBox = null;
        selectedConnector = null;
      });
    }
  }

  void _deleteSupplierDataBox(String supplierId) {
    setState(() {
      supplierDataBoxPositions.remove(supplierId);
      supplierDataBoxUserData.remove(supplierId);
      if (selectedSupplierDataBox == supplierId) {
        selectedSupplierDataBox = null;
      }
    });
    _saveCanvasState(); // Auto-save when item is deleted
  }

  void _updateProductionControlDataBoxPosition(String productionControlId, Offset newPosition) {
    setState(() {
      productionControlDataBoxPositions[productionControlId] = newPosition;
    });
    _saveCanvasState(); // Auto-save when position changes
  }

  void _selectProductionControlDataBox(String productionControlId) {
    if (connectionMode == ConnectionMode.selecting || connectionMode == ConnectionMode.connecting) {
      // Handle connection mode
      final position = productionControlDataBoxPositions[productionControlId];
      if (position != null) {
        _handleItemTapForConnection(
          productionControlId,
          'productionControl',
          position,
          const Size(180, 120), // Production control data box size
        );
      }
    } else {
      // Normal selection mode
      setState(() {
        selectedProductionControlDataBox = productionControlId;
        selectedProcess = null;
        selectedCanvasIcon = null;
        selectedCustomerDataBox = null;
        selectedSupplierDataBox = null;
        selectedTruckDataBox = null;
        selectedConnector = null;
      });
    }
  }

  void _deleteProductionControlDataBox(String productionControlId) {
    setState(() {
      productionControlDataBoxPositions.remove(productionControlId);
      if (selectedProductionControlDataBox == productionControlId) {
        selectedProductionControlDataBox = null;
      }
    });
    _saveCanvasState(); // Auto-save when item is deleted
  }

  void _updateTruckDataBoxPosition(String truckId, Offset newPosition) {
    setState(() {
      truckDataBoxPositions[truckId] = newPosition;
    });
    _saveCanvasState(); // Auto-save when position changes
  }

  void _updateTruckDataBoxUserData(String truckId, String userData) {
    truckDataBoxUserData[truckId] = userData;
    _saveCanvasState(); // Auto-save when user data changes
  }

  void _selectTruckDataBox(String truckId) {
    if (connectionMode == ConnectionMode.selecting || connectionMode == ConnectionMode.connecting) {
      // Handle connection mode
      final position = truckDataBoxPositions[truckId];
      if (position != null) {
        _handleItemTapForConnection(
          truckId,
          'truck',
          position,
          const Size(120, 90), // Truck data box size
        );
      }
    } else if (connectionMode == ConnectionMode.materialConnectorSelecting || connectionMode == ConnectionMode.materialConnectorConnecting) {
      // Handle material connector mode - create a virtual canvas icon from truck data box
      
      final position = truckDataBoxPositions[truckId];
      if (position != null) {
        // Create a virtual canvas icon to represent this truck data box for material connector purposes
        final virtualTruckIcon = CanvasIcon(
          id: truckId,
          type: CanvasIconType.truck,
          label: 'Shipment $truckId',
          iconData: Icons.local_shipping,
          position: position,
          color: Colors.brown,
        );
        
        // Call the canvas icon selection logic
        _selectCanvasIcon(virtualTruckIcon);
      }
    } else {
      // Normal selection mode
      setState(() {
        selectedTruckDataBox = truckId;
        selectedProcess = null;
        selectedCanvasIcon = null;
        selectedCustomerDataBox = null;
        selectedSupplierDataBox = null;
        selectedProductionControlDataBox = null;
        selectedConnector = null;
      });
    }
  }

  void _deleteTruckDataBox(String truckId) {
    setState(() {
      truckDataBoxPositions.remove(truckId);
      truckDataBoxUserData.remove(truckId);
      if (selectedTruckDataBox == truckId) {
        selectedTruckDataBox = null;
      }
    });
    _saveCanvasState(); // Auto-save when item is deleted
  }

  // Connector Management Methods
  void _startConnectorMode(ConnectorType connectorType) {
    setState(() {
      connectionMode = ConnectionMode.selecting;
      pendingConnection = null;
      currentConnectorType = connectorType; // Store the connector type
      // Clear all selections
      selectedProcess = null;
      selectedCanvasIcon = null;
      selectedCustomerDataBox = null;
      selectedSupplierDataBox = null;
      selectedProductionControlDataBox = null;
      selectedTruckDataBox = null;
      selectedConnector = null;
    });
    
    // Show instructions to user
    final typeName = connectorType.toString().split('.').last;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$typeName connector mode active. Tap the first item to connect.'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _startKanbanLoopMode() {
    setState(() {
      connectionMode = ConnectionMode.kanbanLoopSelecting;
      pendingSupermarketId = null;
      pendingKanbanSupplierProcess = null;
      // Clear all selections
      selectedProcess = null;
      selectedCanvasIcon = null;
      selectedCustomerDataBox = null;
      selectedSupplierDataBox = null;
      selectedProductionControlDataBox = null;
      selectedTruckDataBox = null;
      selectedConnector = null;
      selectedMaterialConnector = null;
      selectedKanbanLoop = null;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Kanban Loop mode active. First tap a supermarket material connector.'),
        duration: Duration(seconds: 4),
      ),
    );
  }

  void _startMaterialConnectorMode(CanvasIconType materialConnectorType) {
    setState(() {
      pendingMaterialConnectorType = materialConnectorType;
      connectionMode = ConnectionMode.materialConnectorSelecting;
      pendingSupplierProcess = null;
      pendingCustomerProcess = null;
      // Clear all selections
      selectedProcess = null;
      selectedCanvasIcon = null;
      selectedCustomerDataBox = null;
      selectedSupplierDataBox = null;
      selectedProductionControlDataBox = null;
      selectedTruckDataBox = null;
      selectedConnector = null;
      selectedMaterialConnector = null;
    });
    
    // Show instructions to user
    final typeName = materialConnectorType.toString().split('.').last.toUpperCase();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$typeName material connector mode active. Tap the supplier process first.'),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  String _getConnectionModeText() {
    final text = switch (connectionMode) {
      ConnectionMode.selecting => 'Select first item',
      ConnectionMode.connecting => 'Select second item', 
      ConnectionMode.materialConnectorSelecting => 'Select supplier process',
      ConnectionMode.materialConnectorConnecting => 'Select customer process',
      _ => 'Connection mode',
    };
    return text;
  }

  void _createMaterialConnector(ProcessObject supplier, ProcessObject customer) {
    if (pendingMaterialConnectorType == null) {
      return;
    }

    // Check if there are already 2 material connectors between these processes
    final existingConnectors = materialConnectors.where((connector) =>
      (connector.supplierProcessId == supplier.id.toString() && 
       connector.customerProcessId == customer.id.toString()) ||
      (connector.supplierProcessId == customer.id.toString() && 
       connector.customerProcessId == supplier.id.toString())
    ).toList();

    if (existingConnectors.length >= 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximum of 2 material connectors allowed between any two processes.'),
          duration: Duration(seconds: 3),
        ),
      );
      setState(() {
        connectionMode = ConnectionMode.none;
        pendingMaterialConnectorType = null;
        pendingSupplierProcess = null;
        pendingCustomerProcess = null;
      });
      return;
    }

    // Calculate position considering if either end is a shipment icon
    double connectorX, connectorY;
    
    // Check if supplier is a shipment icon (check both canvas icons and truck data boxes)
    final supplierCanvasIcon = canvasIcons.firstWhere(
      (icon) => icon.id == supplier.id.toString() && icon.type == CanvasIconType.truck,
      orElse: () => CanvasIcon(id: '', type: CanvasIconType.customer, label: '', iconData: Icons.error, position: Offset.zero),
    );
    final supplierTruckDataBox = truckDataBoxPositions[supplier.id.toString()];
    
    // Check if customer is a shipment icon (check both canvas icons and truck data boxes)
    final customerCanvasIcon = canvasIcons.firstWhere(
      (icon) => icon.id == customer.id.toString() && icon.type == CanvasIconType.truck,
      orElse: () => CanvasIcon(id: '', type: CanvasIconType.customer, label: '', iconData: Icons.error, position: Offset.zero),
    );
    final customerTruckDataBox = truckDataBoxPositions[customer.id.toString()];
    
    bool supplierIsShipment = supplierCanvasIcon.id.isNotEmpty || supplierTruckDataBox != null;
    bool customerIsShipment = customerCanvasIcon.id.isNotEmpty || customerTruckDataBox != null;
    
    if (supplierIsShipment) {
      // Supplier is shipment icon: center horizontally with shipment, vertically with customer data box
      Offset shipmentPosition;
      Size shipmentSize;
      
      if (supplierCanvasIcon.id.isNotEmpty) {
        // Use canvas icon position and size
        shipmentPosition = supplierCanvasIcon.position;
        shipmentSize = supplierCanvasIcon.size;
      } else {
        // Use truck data box position and size
        shipmentPosition = supplierTruckDataBox!;
        shipmentSize = const Size(120, 90); // Truck data box size
      }
      
      final shipmentCenterX = shipmentPosition.dx + shipmentSize.width / 2;
      final customerCenterY = customer.position.dy + customer.size.height / 2;
      
      connectorX = shipmentCenterX;
      connectorY = customerCenterY;
    } else if (customerIsShipment) {
      // Customer is shipment icon: center vertically with supplier data box, horizontally with shipment
      final supplierCenterY = supplier.position.dy + supplier.size.height / 2;
      
      Offset shipmentPosition;
      Size shipmentSize;
      
      if (customerCanvasIcon.id.isNotEmpty) {
        // Use canvas icon position and size
        shipmentPosition = customerCanvasIcon.position;
        shipmentSize = customerCanvasIcon.size;
      } else {
        // Use truck data box position and size
        shipmentPosition = customerTruckDataBox!;
        shipmentSize = const Size(120, 90); // Truck data box size
      }
      
      final shipmentCenterX = shipmentPosition.dx + shipmentSize.width / 2;
      
      connectorX = shipmentCenterX;
      connectorY = supplierCenterY;
    } else {
      // Normal case: both are data boxes or processes, center between them
      final supplierCenterX = supplier.position.dx + supplier.size.width / 2;
      final supplierCenterY = supplier.position.dy + supplier.size.height / 2;
      final customerCenterX = customer.position.dx + customer.size.width / 2;
      final customerCenterY = customer.position.dy + customer.size.height / 2;
      
      connectorX = (supplierCenterX + customerCenterX) / 2;
      connectorY = (supplierCenterY + customerCenterY) / 2;
    }

    // If there's already one connector, stack horizontally to the right
    final stackOffset = existingConnectors.isNotEmpty ? 100.0 : 0.0; // Stack to the right

    final newMaterialConnector = MaterialConnector(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: pendingMaterialConnectorType!,
      supplierProcessId: supplier.id.toString(),
      customerProcessId: customer.id.toString(),
      label: MaterialConnectorHelper.getColor(pendingMaterialConnectorType!).toString().split('.').last.toUpperCase(),
      position: Offset(connectorX + stackOffset, connectorY),
      numberOfPieces: null,
      color: MaterialConnectorHelper.getColor(pendingMaterialConnectorType!),
    );

    setState(() {
      materialConnectors.add(newMaterialConnector);
      selectedMaterialConnector = newMaterialConnector.id;
      connectionMode = ConnectionMode.none;
      pendingMaterialConnectorType = null;
      pendingSupplierProcess = null;
      pendingCustomerProcess = null;
    });

    _saveCanvasState();

    final typeName = newMaterialConnector.type.toString().split('.').last.toUpperCase();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$typeName material connector created between ${supplier.name} and ${customer.name}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _createKanbanLoopWithHandles(String supermarketId, ConnectionHandle supermarketHandle, ConnectionHandle supplierHandle) {
    // Find the supermarket material connector
    final supermarket = materialConnectors.firstWhere(
      (c) => c.id == supermarketId,
      orElse: () => MaterialConnector(
        id: '',
        type: CanvasIconType.fifo,
        supplierProcessId: '',
        customerProcessId: '',
        label: '',
        position: Offset.zero,
      ),
    );
    
    if (supermarket.id.isEmpty || supermarket.type != CanvasIconType.kanbanMarket) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid supermarket selected for kanban loop.'),
          duration: Duration(seconds: 2),
        ),
      );
      setState(() {
        connectionMode = ConnectionMode.none;
        pendingSupermarketId = null;
        pendingKanbanSupplierProcess = null;
        showConnectionHandles = false;
        selectedItemForHandles = null;
        selectedItemType = null;
        selectedHandle = null;
      });
      return;
    }

    // Get the supplier process to calculate absolute handle position
    final supplierProcess = processes.firstWhere((p) => p.id.toString() == supplierHandle.itemId);
    
    // Calculate absolute handle positions for both supermarket and supplier
    // For supermarket: convert center position to top-left, then add handle offset
    final supermarketTopLeft = Offset(
      supermarket.position.dx - supermarket.size.width / 2,
      supermarket.position.dy - supermarket.size.height / 2,
    );
    final absoluteSupermarketHandlePosition = supermarketTopLeft + supermarketHandle.offset;
    
    // For supplier process: position is already top-left, just add handle offset
    final absoluteSupplierHandlePosition = supplierProcess.position + supplierHandle.offset;
    
    // Create the kanban loop using both specific handles
    final newKanbanLoop = KanbanLoop.createWithHandles(
      supermarketId: supermarketId,
      supplierProcessId: supplierHandle.itemId,
      supermarketHandlePosition: absoluteSupermarketHandlePosition,
      supplierHandlePosition: absoluteSupplierHandlePosition,
    );

    setState(() {
      kanbanLoops.add(newKanbanLoop);
      selectedKanbanLoop = newKanbanLoop.id;
      connectionMode = ConnectionMode.none;
      pendingSupermarketId = null;
      pendingKanbanSupplierProcess = null;
      showConnectionHandles = false;
      selectedItemForHandles = null;
      selectedItemType = null;
      selectedHandle = null;
    });

    _saveCanvasState();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Kanban loop created with precise handle connections'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _updateKanbanLoop(KanbanLoop updatedLoop) {
    setState(() {
      final index = kanbanLoops.indexWhere((loop) => loop.id == updatedLoop.id);
      if (index != -1) {
        kanbanLoops[index] = updatedLoop;
      }
    });
    _saveCanvasState();
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.escape) {
        // Cancel kanban loop creation mode
        if (connectionMode == ConnectionMode.kanbanLoopSelecting || 
            connectionMode == ConnectionMode.kanbanLoopConnecting) {
          setState(() {
            connectionMode = ConnectionMode.none;
            pendingSupermarketId = null;
            showConnectionHandles = false;
            selectedItemForHandles = null;
            selectedItemType = null;
            selectedHandle = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Kanban loop creation cancelled.'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  void _showKanbanLoopDeleteConfirmation(KanbanLoop kanbanLoop) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Kanban Loop'),
          content: const Text('Are you sure you want to delete this kanban loop?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                _deleteKanbanLoop(kanbanLoop.id);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteKanbanLoop(String id) {
    setState(() {
      kanbanLoops.removeWhere((loop) => loop.id == id);
      if (selectedKanbanLoop == id) {
        selectedKanbanLoop = null;
      }
    });
    _saveCanvasState();
  }

  void _updateMaterialConnector(MaterialConnector updatedConnector) {
    setState(() {
      final index = materialConnectors.indexWhere((c) => c.id == updatedConnector.id);
      if (index != -1) {
        materialConnectors[index] = updatedConnector;
      }
    });
    _saveCanvasState();
  }

  void _handleItemTapForConnection(String itemId, String itemType, Offset itemPosition, Size itemSize) {
    if (connectionMode == ConnectionMode.selecting) {
      // First item selected - show connection handles
      _showConnectionHandles(itemId, itemType);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Select a connection handle, then tap the second item.'),
          duration: Duration(seconds: 3),
        ),
      );
    } else if (connectionMode == ConnectionMode.connecting && pendingConnection != null) {
      // Second item selected - show handles for precise connection
      if (itemId != pendingConnection!.itemId) {
        _showConnectionHandles(itemId, itemType);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Select where to connect on this item.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  /// Generate connection handles for an item
  List<ConnectionHandle> _generateConnectionHandles(String itemId, String itemType) {
    final itemPosition = _getItemPosition(itemId, itemType);
    final itemSize = _getItemSize(itemId, itemType);
    
    if (itemPosition == null) return [];
    
    return ConnectionHandleCalculator.calculateHandles(
      itemId: itemId,
      itemType: itemType,
      itemPosition: itemPosition,
      itemSize: itemSize,
    );
  }

  /// Get the position of an item
  Offset? _getItemPosition(String itemId, String itemType) {
    switch (itemType) {
      case 'process':
        final process = processes.firstWhere(
          (p) => p.id.toString() == itemId,
          orElse: () => ProcessObject(
            id: 0,
            name: '',
            description: '',
            color: Colors.grey,
            position: Offset.zero,
            valueStreamId: 0,
            size: Size.zero,
          ),
        );
        return process.id != 0 ? process.position : null;

      case 'icon':
        final icon = canvasIcons.firstWhere(
          (i) => i.id == itemId,
          orElse: () => CanvasIcon(
            id: '',
            type: CanvasIconType.informationArrow,
            iconData: Icons.arrow_forward,
            label: '',
            position: Offset.zero,
          ),
        );
        return icon.id.isNotEmpty ? icon.position : null;

      case 'materialConnector':
        final materialConnector = materialConnectors.firstWhere(
          (c) => c.id == itemId,
          orElse: () => MaterialConnector(
            id: '',
            type: CanvasIconType.fifo,
            supplierProcessId: '',
            customerProcessId: '',
            label: '',
            position: Offset.zero,
          ),
        );
        return materialConnector.id.isNotEmpty ? materialConnector.position : null;
      case 'customer':
        return customerDataBoxPositions[itemId];
      case 'supplier':
        return supplierDataBoxPositions[itemId];
      case 'productionControl':
        return productionControlDataBoxPositions[itemId];
      case 'truck':
        return truckDataBoxPositions[itemId];
      default:
        return null;
    }
  }

  /// Get the size of an item
  Size _getItemSize(String itemId, String itemType) {
    switch (itemType) {
      case 'process':
        final process = processes.firstWhere(
          (p) => p.id.toString() == itemId,
          orElse: () => ProcessObject(
            id: 0,
            name: '',
            description: '',
            color: Colors.grey,
            position: Offset.zero,
            valueStreamId: 0,
            size: Size.zero,
          ),
        );
        return process.id != 0 ? process.size : const Size(100, 50);

      case 'icon':
        return const Size(50, 50); // Standard icon size
      case 'materialConnector':
        final materialConnector = materialConnectors.firstWhere(
          (c) => c.id == itemId,
          orElse: () => MaterialConnector(
            id: '',
            type: CanvasIconType.fifo,
            supplierProcessId: '',
            customerProcessId: '',
            label: '',
            position: Offset.zero,
          ),
        );
        return materialConnector.id.isNotEmpty ? materialConnector.size : const Size(85, 130);
      case 'customer':
        return const Size(180, 150); // Customer data box actual rendered size
      case 'supplier':
        return const Size(180, 150); // Supplier data box actual rendered size
      case 'productionControl':
        return const Size(180, 120); // Production control actual rendered size
      case 'truck':
        return const Size(120, 90); // Truck actual rendered size
      default:
        return const Size(100, 50);
    }
  }

  /// Show connection handles for an item
  void _showConnectionHandles(String itemId, String itemType) {
    setState(() {
      selectedItemForHandles = itemId;
      selectedItemType = itemType;
      showConnectionHandles = true;
      selectedHandle = null;
    });
  }

  /// Hide connection handles
  void _hideConnectionHandles() {
    setState(() {
      selectedItemForHandles = null;
      selectedItemType = null;
      showConnectionHandles = false;
      selectedHandle = null;
    });
  }

  /// Select a connection handle
  void _selectConnectionHandle(ConnectionHandle handle) {
    setState(() {
      selectedHandle = handle;
    });
    
    // If we're in connection mode, use this handle
    if (connectionMode != ConnectionMode.none) {
      _handleConnectionWithHandle(handle);
    }
  }

  /// Handle connection using a specific handle
  void _handleConnectionWithHandle(ConnectionHandle handle) {
    // Handle kanban loop supermarket handle selection
    if (connectionMode == ConnectionMode.kanbanLoopSelecting && pendingSupermarketId != null) {
      // Store the selected supermarket handle and move to supplier selection
      setState(() {
        selectedHandle = handle; // Store the supermarket handle
        connectionMode = ConnectionMode.kanbanLoopConnecting;
        showConnectionHandles = false; // Hide supermarket handles
        selectedItemForHandles = null;
        selectedItemType = null;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Supermarket handle selected. Now tap the supplier process for the kanban loop.'),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }
    
    // Handle kanban loop supplier handle selection
    if (connectionMode == ConnectionMode.kanbanLoopConnecting && pendingSupermarketId != null && selectedHandle != null) {
      _createKanbanLoopWithHandles(pendingSupermarketId!, selectedHandle!, handle);
      return;
    }
    
    final endpoint = ConnectorEndpoint(
      itemId: handle.itemId,
      itemType: handle.itemType,
      handle: handle,
    );

    if (pendingConnection == null) {
      // First connection point
      setState(() {
        pendingConnection = endpoint;
      });
    } else {
      // Complete the connection
      _createConnector(pendingConnection!, endpoint);
      setState(() {
        pendingConnection = null;
        connectionMode = ConnectionMode.none;
        currentConnectorType = ConnectorType.information;
        selectedHandle = null;
        // Clear all selections to ensure clean state
        selectedConnector = null;
        selectedProcess = null;
        selectedCanvasIcon = null;
        selectedCustomerDataBox = null;
        selectedSupplierDataBox = null;
        selectedProductionControlDataBox = null;
        selectedTruckDataBox = null;
      });
      _hideConnectionHandles();
    }
  }

  void _createConnector(ConnectorEndpoint startPoint, ConnectorEndpoint endPoint) {
    final newConnector = CanvasConnector(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: currentConnectorType,
      startPoint: startPoint,
      endPoint: endPoint,
    );

    setState(() {
      connectors.add(newConnector);
      // Explicitly clear any selected connector to prevent blue appearance
      selectedConnector = null;
    });
    _saveCanvasState(); // Auto-save when connector is created
    
    // Show confirmation message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Connection created successfully!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _selectConnector(String connectorId) {
    setState(() {
      selectedConnector = connectorId;
      selectedProcess = null;
      selectedCanvasIcon = null;
      selectedCustomerDataBox = null;
      selectedSupplierDataBox = null;
      selectedProductionControlDataBox = null;
      selectedTruckDataBox = null;
      // Ensure we're not in connection mode when selecting a connector
      if (connectionMode != ConnectionMode.none) {
        connectionMode = ConnectionMode.none;
        pendingConnection = null;
      }
    });
  }

  void _selectMaterialConnector(String materialConnectorId) {
    // Handle kanban loop creation workflow
    if (connectionMode == ConnectionMode.kanbanLoopSelecting) {
      // Check if the selected material connector is a supermarket
      final materialConnector = materialConnectors.firstWhere(
        (c) => c.id == materialConnectorId,
        orElse: () => MaterialConnector(
          id: '',
          type: CanvasIconType.fifo,
          supplierProcessId: '',
          customerProcessId: '',
          label: '',
          position: Offset.zero,
        ),
      );
      
      if (materialConnector.type == CanvasIconType.kanbanMarket) {
        // Show connection handles on the supermarket for user to select
        _showConnectionHandles(materialConnectorId, 'materialConnector');
        
        setState(() {
          pendingSupermarketId = materialConnectorId;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Select a connection handle on the supermarket, then tap the supplier process.'),
            duration: Duration(seconds: 4),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a supermarket material connector for kanban loops.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }
    
    // Normal material connector selection
    setState(() {
      selectedMaterialConnector = materialConnectorId;
      selectedConnector = null;
      selectedProcess = null;
      selectedCanvasIcon = null;
      selectedCustomerDataBox = null;
      selectedSupplierDataBox = null;
      selectedProductionControlDataBox = null;
      selectedTruckDataBox = null;
      selectedKanbanLoop = null;
      
      // Don't automatically show connection handles when just selecting a material connector
      // Handles should only be shown when explicitly creating connections
      selectedItemForHandles = null;
      selectedItemType = null;
      showConnectionHandles = false;
      selectedHandle = null;
      
      // Ensure we're not in connection mode when selecting a material connector
      if (connectionMode != ConnectionMode.none) {
        connectionMode = ConnectionMode.none;
        pendingConnection = null;
      }
    });
  }

  void _selectKanbanLoop(String kanbanLoopId) {
    setState(() {
      selectedKanbanLoop = kanbanLoopId;
      selectedMaterialConnector = null;
      selectedConnector = null;
      selectedProcess = null;
      selectedCanvasIcon = null;
      selectedCustomerDataBox = null;
      selectedSupplierDataBox = null;
      selectedProductionControlDataBox = null;
      selectedTruckDataBox = null;
      
      // Clear connection handles
      selectedItemForHandles = null;
      selectedItemType = null;
      showConnectionHandles = false;
      selectedHandle = null;
      
      // Ensure we're not in connection mode when selecting a kanban loop
      if (connectionMode != ConnectionMode.none) {
        connectionMode = ConnectionMode.none;
        pendingConnection = null;
        pendingSupermarketId = null;
        pendingKanbanSupplierProcess = null;
      }
    });
  }

  void _deleteConnector(String connectorId) {
    setState(() {
      connectors.removeWhere((c) => c.id == connectorId);
      if (selectedConnector == connectorId) {
        selectedConnector = null;
      }
    });
    _saveCanvasState(); // Auto-save when connector is deleted
  }

  void _deleteMaterialConnector(String materialConnectorId) {
    setState(() {
      materialConnectors.removeWhere((c) => c.id == materialConnectorId);
      if (selectedMaterialConnector == materialConnectorId) {
        selectedMaterialConnector = null;
      }
    });
    _saveCanvasState(); // Auto-save when material connector is deleted
  }

  void _selectCanvasIcon(CanvasIcon icon) {
    if (connectionMode == ConnectionMode.selecting || connectionMode == ConnectionMode.connecting) {
      // Handle connection mode
      _handleItemTapForConnection(
        icon.id,
        'icon',
        icon.position,
        icon.size,
      );
    } else if (connectionMode == ConnectionMode.materialConnectorSelecting && icon.type == CanvasIconType.truck) {
      // Handle material connector supplier selection with shipment icon only
      
      // Convert canvas icon to a ProcessObject-like structure for material connector
      final supplierProcess = _convertCanvasIconToProcess(icon);
      
      // First show immediate feedback
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Supplier "${icon.label}" selected. Now selecting customer...'),
          duration: const Duration(milliseconds: 1500),
        ),
      );
      
      setState(() {
        pendingSupplierProcess = supplierProcess;
        connectionMode = ConnectionMode.materialConnectorConnecting;
      });
      
      // Show customer selection instruction after a brief delay
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && connectionMode == ConnectionMode.materialConnectorConnecting) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Now tap the customer process to create the material connector.'),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      });
    } else if (connectionMode == ConnectionMode.materialConnectorConnecting && icon.type == CanvasIconType.truck) {
      // Handle material connector customer selection with shipment icon only
      
      if (pendingSupplierProcess != null) {
        final customerProcess = _convertCanvasIconToProcess(icon);
        
        if (customerProcess.id != pendingSupplierProcess!.id) {
          _createMaterialConnector(pendingSupplierProcess!, customerProcess);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please select a different item for the customer.'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } else if ((connectionMode == ConnectionMode.materialConnectorSelecting || connectionMode == ConnectionMode.materialConnectorConnecting) && icon.type != CanvasIconType.truck) {
      // User clicked non-shipment icon during material connector mode
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Only shipment icons can be used with material connectors. Selected: ${icon.label}'),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      // Normal selection mode
      setState(() {
        selectedCanvasIcon = icon;
        selectedProcess = null; // Deselect any selected process
        selectedCustomerDataBox = null;
        selectedSupplierDataBox = null;
        selectedProductionControlDataBox = null;
        selectedTruckDataBox = null;
        selectedConnector = null;
      });
    }
  }

  /// Convert a CanvasIcon to a ProcessObject-like structure for material connector compatibility
  ProcessObject _convertCanvasIconToProcess(CanvasIcon icon) {
    return ProcessObject(
      id: int.tryParse(icon.id) ?? DateTime.now().millisecondsSinceEpoch, // Convert string ID to int, fallback to timestamp
      name: icon.label,
      description: 'Canvas Icon: ${icon.type.toString().split('.').last}',
      color: icon.color,
      position: icon.position,
      valueStreamId: widget.valueStreamId,
      size: icon.size,
    );
  }

  void _deleteCanvasIcon(CanvasIcon icon) {
    setState(() {
      canvasIcons.removeWhere((i) => i.id == icon.id);
      if (selectedCanvasIcon?.id == icon.id) {
        selectedCanvasIcon = null;
      }
    });
    _saveCanvasState(); // Auto-save when item is deleted
  }

  void _deselectAll() {
    setState(() {
      selectedProcess = null;
      selectedCanvasIcon = null;
      selectedCustomerDataBox = null;
      selectedSupplierDataBox = null;
      selectedProductionControlDataBox = null;
      selectedTruckDataBox = null;
      selectedConnector = null;
      selectedMaterialConnector = null;
      selectedKanbanLoop = null;
      
      // Only reset connection mode if NOT in kanban loop workflow
      // This allows users to click again if they miss a handle
      if (connectionMode != ConnectionMode.none && 
          connectionMode != ConnectionMode.kanbanLoopSelecting && 
          connectionMode != ConnectionMode.kanbanLoopConnecting) {
        connectionMode = ConnectionMode.none;
        pendingConnection = null;
        pendingMaterialConnectorType = null;
        pendingSupplierProcess = null;
        pendingCustomerProcess = null;
      }
      
      // Hide connection handles if clicking in empty space during kanban loop creation
      if (connectionMode == ConnectionMode.kanbanLoopConnecting) {
        showConnectionHandles = false;
        selectedItemForHandles = null;
        selectedItemType = null;
        selectedHandle = null;
        // Show message to try again
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Click on a supplier process to show its connection handles.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }

  // Canvas State Management Methods
  Future<void> _loadCanvasState(String partNumber) async {
    try {
      final canvasState = await db.loadCanvasState(
        valueStreamId: widget.valueStreamId,
        partNumber: partNumber,
      );

      if (canvasState.isEmpty) return;

      // Clear existing state
      customerDataBoxPositions.clear();
      supplierDataBoxPositions.clear();
      productionControlDataBoxPositions.clear();
      truckDataBoxPositions.clear();
      supplierDataBoxUserData.clear();
      truckDataBoxUserData.clear();
      canvasIcons.clear();
      connectors.clear(); // Clear connectors
      materialConnectors.clear(); // Clear material connectors
      kanbanLoops.clear(); // Clear kanban loops

      // Restore canvas state
      for (final state in canvasState) {
        final position = Offset(state.positionX, state.positionY);
        
        switch (state.iconType) {
          case 'customerDataBox':
            customerDataBoxPositions[state.iconId] = position;
            break;
          case 'supplierDataBox':
            supplierDataBoxPositions[state.iconId] = position;
            if (state.userData != null) {
              supplierDataBoxUserData[state.iconId] = state.userData!;
            }
            break;
          case 'productionControlDataBox':
            productionControlDataBoxPositions[state.iconId] = position;
            break;
          case 'truckDataBox':
            truckDataBoxPositions[state.iconId] = position;
            if (state.userData != null) {
              truckDataBoxUserData[state.iconId] = state.userData!;
            }
            break;
          case 'connector':
            // Restore connector from JSON data
            if (state.userData != null) {
              try {
                final connectorData = state.userData!;
                // Parse the JSON string back to connector
                // For now, using a simple approach since we have full connector data
                final connector = _parseConnectorFromString(connectorData);
                if (connector != null) {
                  connectors.add(connector);
                }
              } catch (e) {
                // Silently ignore connector parsing errors
              }
            }
            break;
          case 'materialConnector':
            // Restore material connector from JSON data
            if (state.userData != null) {
              try {
                final materialConnectorData = jsonDecode(state.userData!);
                final materialConnector = MaterialConnector.fromJson(materialConnectorData);
                materialConnectors.add(materialConnector);
              } catch (e) {
                // Silently ignore material connector parsing errors
              }
            }
            break;
          case 'kanbanLoop':
            // Restore kanban loop from JSON data
            if (state.userData != null) {
              try {
                final kanbanLoopData = jsonDecode(state.userData!);
                final kanbanLoop = KanbanLoop.fromJson(kanbanLoopData);
                kanbanLoops.add(kanbanLoop);
              } catch (e) {
                // Silently ignore kanban loop parsing errors
              }
            }
            break;
          default:
            // Regular canvas icons
            final iconType = _getCanvasIconTypeFromString(state.iconType);
            if (iconType != null) {
              final icon = CanvasIcon(
                id: state.iconId,
                type: iconType,
                label: state.iconType,
                iconData: _getIconDataForType(iconType),
                color: _getColorForType(iconType),
                position: position,
              );
              canvasIcons.add(icon);
            }
            break;
        }
      }

      setState(() {});
    } catch (e) {
      // Silently ignore canvas state loading errors
    }
  }

  Future<void> _saveCanvasState() async {
    if (currentPartNumber == null) return;

    try {
      // Clear existing state for this value stream and part
      await db.clearCanvasState(
        valueStreamId: widget.valueStreamId,
        partNumber: currentPartNumber!,
      );

      // Save customer data boxes
      for (final entry in customerDataBoxPositions.entries) {
        await db.saveCanvasState(
          valueStreamId: widget.valueStreamId,
          partNumber: currentPartNumber!,
          iconType: 'customerDataBox',
          iconId: entry.key,
          positionX: entry.value.dx,
          positionY: entry.value.dy,
        );
      }

      // Save supplier data boxes
      for (final entry in supplierDataBoxPositions.entries) {
        await db.saveCanvasState(
          valueStreamId: widget.valueStreamId,
          partNumber: currentPartNumber!,
          iconType: 'supplierDataBox',
          iconId: entry.key,
          positionX: entry.value.dx,
          positionY: entry.value.dy,
          userData: supplierDataBoxUserData[entry.key],
        );
      }

      // Save production control data boxes
      for (final entry in productionControlDataBoxPositions.entries) {
        await db.saveCanvasState(
          valueStreamId: widget.valueStreamId,
          partNumber: currentPartNumber!,
          iconType: 'productionControlDataBox',
          iconId: entry.key,
          positionX: entry.value.dx,
          positionY: entry.value.dy,
        );
      }

      // Save truck data boxes
      for (final entry in truckDataBoxPositions.entries) {
        await db.saveCanvasState(
          valueStreamId: widget.valueStreamId,
          partNumber: currentPartNumber!,
          iconType: 'truckDataBox',
          iconId: entry.key,
          positionX: entry.value.dx,
          positionY: entry.value.dy,
          userData: truckDataBoxUserData[entry.key],
        );
      }

      // Save regular canvas icons
      for (final icon in canvasIcons) {
        await db.saveCanvasState(
          valueStreamId: widget.valueStreamId,
          partNumber: currentPartNumber!,
          iconType: icon.type.toString(),
          iconId: icon.id,
          positionX: icon.position.dx,
          positionY: icon.position.dy,
        );
      }

      // Save connectors
      for (final connector in connectors) {
        await db.saveCanvasState(
          valueStreamId: widget.valueStreamId,
          partNumber: currentPartNumber!,
          iconType: 'connector',
          iconId: connector.id,
          positionX: 0, // Not applicable for connectors
          positionY: 0, // Not applicable for connectors
          userData: jsonEncode(connector.toJson()), // Store connector data as proper JSON
        );
      }

      // Save material connectors
      for (final materialConnector in materialConnectors) {
        await db.saveCanvasState(
          valueStreamId: widget.valueStreamId,
          partNumber: currentPartNumber!,
          iconType: 'materialConnector',
          iconId: materialConnector.id,
          positionX: materialConnector.position.dx,
          positionY: materialConnector.position.dy,
          userData: jsonEncode(materialConnector.toJson()), // Store material connector data as JSON
        );
      }

      // Save kanban loops
      for (final kanbanLoop in kanbanLoops) {
        await db.saveCanvasState(
          valueStreamId: widget.valueStreamId,
          partNumber: currentPartNumber!,
          iconType: 'kanbanLoop',
          iconId: kanbanLoop.id,
          positionX: kanbanLoop.kanbanIconPosition.dx,
          positionY: kanbanLoop.kanbanIconPosition.dy,
          userData: jsonEncode(kanbanLoop.toJson()), // Store kanban loop data as JSON
        );
      }
    } catch (e) {
      // Silently ignore canvas state saving errors
    }
  }

  CanvasIconType? _getCanvasIconTypeFromString(String typeString) {
    for (final type in CanvasIconType.values) {
      if (type.toString() == typeString) {
        return type;
      }
    }
    return null;
  }

  IconData _getIconDataForType(CanvasIconType type) {
    // Find the template for this type
    for (final template in CanvasIconTemplate.templates) {
      if (template.type == type) {
        return template.iconData;
      }
    }
    return Icons.help; // Default icon
  }

  Color _getColorForType(CanvasIconType type) {
    // Find the template for this type
    for (final template in CanvasIconTemplate.templates) {
      if (template.type == type) {
        return template.color;
      }
    }
    return Colors.grey; // Default color
  }

  CanvasConnector? _parseConnectorFromString(String jsonString) {
    try {
      // Parse the JSON string representation
      final Map<String, dynamic> json = jsonDecode(jsonString);
      return CanvasConnector.fromJson(json);
    } catch (e) {
      // Silently ignore connector parsing errors
    }
    return null;
  }

  String _getConnectorDisplayName(String connectorId) {
    final connector = connectors.firstWhere(
      (c) => c.id == connectorId,
      orElse: () => CanvasConnector(
        id: '',
        type: ConnectorType.information,
        startPoint: ConnectorEndpoint(itemId: '', itemType: '', connectionPoint: Offset.zero),
        endPoint: ConnectorEndpoint(itemId: '', itemType: '', connectionPoint: Offset.zero),
      ),
    );
    
    if (connector.id.isEmpty) return 'Connector';
    
    switch (connector.type) {
      case ConnectorType.information:
        return 'Information Arrow';
      case ConnectorType.electronic:
        return 'Electronic Arrow';
      case ConnectorType.material:
        return 'Material Flow';
      case ConnectorType.materialPush:
        return 'Material Push';
      case ConnectorType.kanbanLoop:
        return 'Kanban Loop';
      case ConnectorType.withdrawalLoop:
        return 'Withdrawal Loop';
    }
  }

  String _getMaterialConnectorDisplayName(String materialConnectorId) {
    final materialConnector = materialConnectors.firstWhere(
      (c) => c.id == materialConnectorId,
      orElse: () => MaterialConnector(
        id: '',
        type: CanvasIconType.fifo,
        supplierProcessId: '',
        customerProcessId: '',
        label: '',
        position: Offset.zero,
      ),
    );
    
    if (materialConnector.id.isEmpty) return 'Material Connector';
    
    switch (materialConnector.type) {
      case CanvasIconType.fifo:
        return 'FIFO';
      case CanvasIconType.buffer:
        return 'Buffer';
      case CanvasIconType.kanbanMarket:
        return 'Supermarket';
      case CanvasIconType.uncontrolled:
        return 'Uncontrolled';
      default:
        return 'Material Connector';
    }
  }

  /// Build connection handles for the currently selected item
  Widget _buildConnectionHandles() {
    if (selectedItemForHandles == null || selectedItemType == null) {
      return const SizedBox.shrink();
    }

    final itemPosition = _getItemPosition(selectedItemForHandles!, selectedItemType!);
    final itemSize = _getItemSize(selectedItemForHandles!, selectedItemType!);
    
    if (itemPosition == null) {
      return const SizedBox.shrink();
    }

    final handles = _generateConnectionHandles(selectedItemForHandles!, selectedItemType!);

    // Adjust position to account for handles extending outside the item bounds
    const handleExtension = 12.0;
    
    // Different items use different coordinate systems:
    // - MaterialConnector: position is center point
    // - ProcessObject: position is top-left point  
    // - DataBoxes: position is top-left point
    final bool usesCenterPosition = selectedItemType == 'materialConnector';
    
    final topLeftPosition = usesCenterPosition 
        ? Offset(
            itemPosition.dx - itemSize.width / 2,
            itemPosition.dy - itemSize.height / 2,
          )
        : itemPosition; // Already top-left for processes and data boxes
    
    return Positioned(
      left: topLeftPosition.dx - handleExtension,
      top: topLeftPosition.dy - handleExtension,
      child: ConnectionHandleWidget(
        handles: handles,
        selectedHandle: selectedHandle,
        showHandles: showConnectionHandles,
        itemSize: itemSize,
        paddingExtension: handleExtension,
        onHandleSelected: _selectConnectionHandle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Return loading indicator if still loading
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return HomeButtonWrapper(
      child: PopScope(
        onPopInvoked: (didPop) {
          // Save canvas state when back button is pressed
          _saveCanvasState();
        },
        child: Scaffold(
        appBar: AppBar(
          title: FutureBuilder<String?>(
            future: db.getSelectedPartNumber(),
            builder: (context, snapshot) {
              final partNumber = snapshot.data;
              if (partNumber != null && partNumber.isNotEmpty) {
                return Text('${widget.valueStreamName} Value Stream: Part Number $partNumber - Value Stream Mapping Canvas');
              } else {
                return Text('${widget.valueStreamName} - Value Stream Mapping Canvas');
              }
            },
          ),
          backgroundColor: Colors.grey[100],
          actions: [
            IconButton(
              icon: const Icon(Icons.grid_view),
              onPressed: _resetProcessPositions,
              tooltip: 'Reset Positions',
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () async {
                // Force complete refresh of all ProcessObject data
                await refreshProcessData();
                if (mounted && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Process data refreshed')),
                  );
                }
              },
              tooltip: 'Refresh All Data',
            ),
          ],
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : processes.isEmpty
                ? const Center(
                    child: Text(
                      'No processes found.\nAdd processes in the Value Stream Details screen.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : KeyboardListener(
                    focusNode: FocusNode()..requestFocus(),
                    onKeyEvent: _handleKeyEvent,
                    child: LayoutBuilder(
                    builder: (context, constraints) {
                      return GestureDetector(
                        onTap: _deselectAll, // Deselect when tapping empty space
                        child: DragTarget<ProcessObject>(
                          onAcceptWithDetails: (details) {
                            // Handle drops on the canvas background
                            final RenderBox? renderBox =
                                context.findRenderObject() as RenderBox?;
                            if (renderBox != null) {
                              final localOffset =
                                  renderBox.globalToLocal(details.offset);
                              _updateProcessPosition(details.data, localOffset);
                            }
                          },
                          builder: (context, candidateData, rejectedData) {
                            return Stack(
                              children: [
                                // Canvas background
                                Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  color: Colors.grey[50],
                                  child: CustomPaint(
                                    painter: GridPainter(),
                                  ),
                                ),
                                // Process widgets
                                ...processes.map((process) {
                                  return DraggableProcessWidget(
                                    key: ValueKey(process.id),
                                    process: process,
                                    isSelected:
                                        selectedProcess?.id == process.id,
                                    onTap: () => _selectProcess(process),
                                    onDragEnd: (globalOffset) {
                                      _updateProcessPositionFromGlobal(
                                          process, globalOffset, constraints);
                                    },
                                  );
                                }),
                                
                                // Canvas icons
                                ...canvasIcons.map((icon) {
                                  return DraggableCanvasIcon(
                                    key: ValueKey(icon.id),
                                    canvasIcon: icon,
                                    isSelected: selectedCanvasIcon?.id == icon.id,
                                    onTap: _selectCanvasIcon,
                                    onPositionChanged: _updateCanvasIconPosition,
                                    onDelete: _deleteCanvasIcon,
                                  );
                                }),
                                
                                // Connectors (arrows between items) - render before data boxes to avoid interfering with touch events
                                ...connectors.map((connector) {
                                  return ConnectorWidget(
                                    key: ValueKey(connector.id),
                                    connector: connector,
                                    processes: processes,
                                    canvasIcons: canvasIcons,
                                    customerDataBoxPositions: customerDataBoxPositions,
                                    supplierDataBoxPositions: supplierDataBoxPositions,
                                    productionControlDataBoxPositions: productionControlDataBoxPositions,
                                    truckDataBoxPositions: truckDataBoxPositions,
                                    isSelected: selectedConnector == connector.id,
                                    onTap: _selectConnector,
                                  );
                                }),
                                
                                // Material connectors (FIFO, Buffer, etc. between processes)
                                ...materialConnectors.map((materialConnector) {
                                  return MaterialConnectorWidget(
                                    key: ValueKey(materialConnector.id),
                                    materialConnector: materialConnector,
                                    processes: processes,
                                    isSelected: selectedMaterialConnector == materialConnector.id,
                                    showConnectionHandles: false, // Don't show handles by default
                                    selectedHandle: null,
                                    onTap: _selectMaterialConnector,
                                    onUpdate: _updateMaterialConnector,
                                    onHandleSelected: _selectConnectionHandle,
                                  );
                                }),
                                
                                // Kanban loops (information flow from supermarkets to suppliers)
                                ...kanbanLoops.map((kanbanLoop) {
                                  return KanbanLoopWidget(
                                    key: ValueKey(kanbanLoop.id),
                                    kanbanLoop: kanbanLoop,
                                    isSelected: selectedKanbanLoop == kanbanLoop.id,
                                    onTap: _selectKanbanLoop,
                                    onUpdate: _updateKanbanLoop,
                                  );
                                }),
                                
                                // Customer data boxes
                                ...customerDataBoxPositions.entries.map((entry) {
                                  return CustomerDataBox(
                                    key: ValueKey(entry.key),
                                    customerId: entry.key,
                                    position: entry.value,
                                    valueStreamId: widget.valueStreamId,
                                    isSelected: selectedCustomerDataBox == entry.key,
                                    onTap: _selectCustomerDataBox,
                                    onPositionChanged: _updateCustomerDataBoxPosition,
                                    onDelete: _deleteCustomerDataBox,
                                  );
                                }),
                                
                                // Supplier data boxes
                                ...supplierDataBoxPositions.entries.map((entry) {
                                  return SupplierDataBox(
                                    key: ValueKey(entry.key),
                                    supplierId: entry.key,
                                    position: entry.value,
                                    isSelected: selectedSupplierDataBox == entry.key,
                                    onTap: _selectSupplierDataBox,
                                    onPositionChanged: _updateSupplierDataBoxPosition,
                                    onDelete: _deleteSupplierDataBox,
                                    onDataChanged: _updateSupplierDataBoxUserData,
                                    initialUserData: supplierDataBoxUserData[entry.key],
                                  );
                                }),
                                
                                // Production control data boxes
                                ...productionControlDataBoxPositions.entries.map((entry) {
                                  return ProductionControlDataBox(
                                    key: ValueKey(entry.key),
                                    productionControlId: entry.key,
                                    position: entry.value,
                                    isSelected: selectedProductionControlDataBox == entry.key,
                                    onTap: _selectProductionControlDataBox,
                                    onPositionChanged: _updateProductionControlDataBoxPosition,
                                    onDelete: _deleteProductionControlDataBox,
                                  );
                                }),
                                
                                // Truck data boxes
                                ...truckDataBoxPositions.entries.map((entry) {
                                  return TruckDataBox(
                                    key: ValueKey(entry.key),
                                    truckId: entry.key,
                                    position: entry.value,
                                    isSelected: selectedTruckDataBox == entry.key,
                                    onTap: _selectTruckDataBox,
                                    onPositionChanged: _updateTruckDataBoxPosition,
                                    onDelete: _deleteTruckDataBox,
                                    onDataChanged: _updateTruckDataBoxUserData,
                                    initialUserData: truckDataBoxUserData[entry.key],
                                  );
                                }),
                                
                                // Selected process options
                                if (selectedProcess != null)
                                  Positioned(
                                    top: 16,
                                    right: 16,
                                    child: Card(
                                      elevation: 4,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              selectedProcess!.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            ElevatedButton.icon(
                                              onPressed: () =>
                                                  _showProcessOptions(
                                                      selectedProcess!),
                                              icon: const Icon(Icons.settings),
                                              label: const Text('Options'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.yellow[600],
                                                foregroundColor: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                
                                // Selected connector options
                                if (selectedConnector != null)
                                  Positioned(
                                    top: 16,
                                    left: 16,
                                    child: Card(
                                      elevation: 4,
                                      color: Colors.orange[50],
                                      child: Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              _getConnectorDisplayName(selectedConnector!),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            ElevatedButton.icon(
                                              onPressed: () => _deleteConnector(selectedConnector!),
                                              icon: const Icon(Icons.delete),
                                              label: const Text('Delete'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                                foregroundColor: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                // Selected material connector options
                                if (selectedMaterialConnector != null)
                                  Positioned(
                                    top: 16,
                                    left: 200, // Position next to connector control panel
                                    child: Card(
                                      elevation: 4,
                                      color: Colors.cyan[50],
                                      child: Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              _getMaterialConnectorDisplayName(selectedMaterialConnector!),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            ElevatedButton.icon(
                                              onPressed: () => _deleteMaterialConnector(selectedMaterialConnector!),
                                              icon: const Icon(Icons.delete),
                                              label: const Text('Delete'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                                foregroundColor: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                // Selected kanban loop options
                                if (selectedKanbanLoop != null)
                                  Positioned(
                                    top: 16,
                                    left: 400, // Position next to material connector panel
                                    child: Card(
                                      elevation: 4,
                                      color: Colors.amber[50],
                                      child: Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Text(
                                              'Kanban Loop',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            ElevatedButton.icon(
                                              onPressed: () {
                                                final kanbanLoop = kanbanLoops.firstWhere((loop) => loop.id == selectedKanbanLoop);
                                                _showKanbanLoopDeleteConfirmation(kanbanLoop);
                                              },
                                              icon: const Icon(Icons.delete),
                                              label: const Text('Delete'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                                foregroundColor: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                // Connection mode indicator
                                if (connectionMode != ConnectionMode.none)
                                  Positioned(
                                    bottom: 16,
                                    left: 16,
                                    child: Card(
                                      elevation: 4,
                                      color: Colors.blue[50],
                                      child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.link,
                                              color: Colors.blue[700],
                                              size: 24,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              _getConnectionModeText(),
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blue[700],
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            ElevatedButton(
                                              onPressed: () {
                                                setState(() {
                                                  connectionMode = ConnectionMode.none;
                                                  pendingConnection = null;
                                                  pendingMaterialConnectorType = null;
                                                  pendingSupplierProcess = null;
                                                  pendingCustomerProcess = null;
                                                });
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.grey,
                                                foregroundColor: Colors.white,
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              ),
                                              child: const Text('Cancel'),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                
                                // Connection handles for selected item
                                if (showConnectionHandles && selectedItemForHandles != null && selectedItemType != null)
                                  _buildConnectionHandles(),
                                
                                // Floating icon toolbar
                                FloatingIconToolbar(
                                  onIconSelected: _addCanvasIcon,
                                ),
                              ],
                            );
                          },
                        ),
                      );
                    },
                  ),
                ), // KeyboardListener
        ), // PopScope child (Scaffold)
      ), // PopScope
    ); // HomeButtonWrapper
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 0.5;

    const gridSize = 20.0;

    // Draw vertical lines
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Draw horizontal lines
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
