import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../logic/app_database.dart';
import '../database_provider.dart';
import '../models/process_object.dart';
import '../models/canvas_icon.dart';
import '../models/canvas_connector.dart';
import '../models/material_connector.dart';
import '../models/kanban_loop.dart';
import '../models/withdrawal_loop.dart';
import '../models/kanban_post.dart';
import '../models/customer.dart';
import '../models/supplier.dart';
import '../models/production_control.dart';
import '../utils/material_connector_state_manager.dart';
import '../utils/material_connector_creator.dart';
import '../utils/connector_creation_handler.dart';
import '../utils/error_handler.dart';
import '../utils/kanban_loop_handler.dart';
import '../utils/customer_manager.dart';
import '../utils/supplier_manager.dart';
import '../utils/production_control_manager.dart';
import '../widgets/draggable_process_widget.dart';
import '../widgets/draggable_canvas_icon.dart';
import '../widgets/material_connector_widget.dart';
import '../widgets/kanban_loop_widget.dart';
import '../widgets/kanban_post_widget.dart';
import '../widgets/floating_icon_toolbar.dart';
import '../widgets/customer_widget.dart';
import '../widgets/supplier_widget.dart';
import '../widgets/production_control_widget.dart';

// Connection modes for different workflows
enum ConnectionMode {
  none,
  selecting,
  connecting,
  materialConnectorSelecting,
  materialConnectorConnecting,
  kanbanLoopSelecting,
  kanbanLoopConnecting,
  withdrawalLoopSelecting,
  withdrawalLoopConnecting,
}

/// Refactored ProcessCanvasScreen with utility classes and reduced complexity
class ProcessCanvasScreenRefactored extends StatefulWidget {
  final int valueStreamId;
  final String partNumber;

  const ProcessCanvasScreenRefactored({
    super.key,
    required this.valueStreamId,
    required this.partNumber,
  });

  @override
  State<ProcessCanvasScreenRefactored> createState() => _ProcessCanvasScreenRefactoredState();
}

class _ProcessCanvasScreenRefactoredState extends State<ProcessCanvasScreenRefactored> {
  // Database and core data
  late AppDatabase db;
  bool isLoading = true;
  String? currentPartNumber;

  // Canvas data
  List<ProcessObject> processes = [];
  List<CanvasIcon> canvasIcons = [];
  List<CanvasConnector> connectors = [];
  List<MaterialConnector> materialConnectors = [];
  List<KanbanLoop> kanbanLoops = [];
  List<WithdrawalLoop> withdrawalLoops = [];
  List<KanbanPost> kanbanPosts = [];

  // Data box positions
  Map<String, Offset> customerDataBoxPositions = {};
  Map<String, Offset> supplierDataBoxPositions = {};
  Map<String, Offset> productionControlDataBoxPositions = {};
  Map<String, Offset> truckDataBoxPositions = {};
  Map<String, String> supplierDataBoxUserData = {};

  // Timer for debounced saves
  Timer? _saveTimer;

  // Selection state
  ProcessObject? selectedProcess;
  CanvasIcon? selectedCanvasIcon;
  Customer? selectedCustomer;
  Supplier? selectedSupplier;
  ProductionControl? selectedProductionControl;
  String? selectedConnector;
  String? selectedMaterialConnector;
  String? selectedKanbanLoop;
  String? selectedWithdrawalLoop;
  String? selectedKanbanPost;
  String? selectedCustomerDataBox;
  String? selectedSupplierDataBox;
  String? selectedProductionControlDataBox;
  String? selectedTruckDataBox;

  // Connection state
  ConnectionMode connectionMode = ConnectionMode.none;

  // Utility handlers
  late MaterialConnectorStateManager materialConnectorState;
  late MaterialConnectorCreator materialConnectorCreator;
  late ConnectorCreationHandler connectorHandler;
  late ErrorHandler errorHandler;
  late KanbanLoopHandler kanbanLoopHandler;
  late CustomerManager customerManager;
  late SupplierManager supplierManager;
  late ProductionControlManager productionControlManager;

  @override
  void initState() {
    super.initState();
    _initializeUtilities();
    _initializeDatabase(); // This is async but we don't await it here
  }

  void _initializeUtilities() {
    // Initialize material connector system
    materialConnectorState = MaterialConnectorStateManager();
    materialConnectorCreator = MaterialConnectorCreator(
      stateManager: materialConnectorState,
      addConnectorCallback: _addMaterialConnector,
      showMessageCallback: _showMessage,
    );

    // Initialize connector creation handler
    connectorHandler = ConnectorCreationHandler(
      onShowMessage: _showMessage,
      onShowConnectionHandles: _showConnectionHandles,
      onHideConnectionHandles: _hideConnectionHandles,
      onConnectorCreated: _addConnector,
      onConnectionCancelled: _cancelConnection,
    );

    // Initialize error handler
    errorHandler = ErrorHandler();

    // Initialize drag handler - remove problematic CanvasDragHandler

    // Initialize kanban loop handler
    kanbanLoopHandler = KanbanLoopHandler(
      showMessage: _showMessage,
      addKanbanLoop: _addKanbanLoop,
      onConnectionCancelled: _cancelConnection,
    );

    // Initialize customer manager
    customerManager = CustomerManager(
      showMessage: _showMessage,
      onStateChanged: () => setState(() {}),
    );

    // Initialize supplier manager
    supplierManager = SupplierManager(
      showMessage: _showMessage,
      onStateChanged: () => setState(() {}),
    );

    // Initialize production control manager
    productionControlManager = ProductionControlManager(
      showMessage: _showMessage,
      onStateChanged: () => setState(() {}),
    );
  }

  void _initializeDatabase() async {
    setState(() => isLoading = true);
    
    try {
      _showMessage('Initializing database...');
      db = await DatabaseProvider.getInstance();
      
      // Set the current part number from widget parameter
      currentPartNumber = widget.partNumber;
      
      _showMessage('Database initialized successfully');
      
      _showMessage('Loading canvas data...');
      await _loadCanvasData();
      _showMessage('Canvas data loaded successfully');
    } catch (e) {
      setState(() => isLoading = false);
      _showMessage('Error initializing database: $e');
    }
  }

  // Add missing kanban loop method
  void _addKanbanLoop(KanbanLoop kanbanLoop) {
    setState(() {
      kanbanLoops.add(kanbanLoop);
      selectedKanbanLoop = kanbanLoop.id;
    });
    _saveCanvasState();
  }

  // Save canvas state (simplified)
  // Canvas state management methods
  void _saveCanvasState() {
    _debouncedSaveCanvasState();
  }

  void _debouncedSaveCanvasState() {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 500), () {
      _immediateSaveCanvasState();
    });
  }

  Future<void> _immediateSaveCanvasState() async {
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

      // Save kanban posts
      for (final kanbanPost in kanbanPosts) {
        await db.saveCanvasState(
          valueStreamId: widget.valueStreamId,
          partNumber: currentPartNumber!,
          iconType: 'kanbanPost',
          iconId: kanbanPost.id,
          positionX: kanbanPost.position.dx,
          positionY: kanbanPost.position.dy,
          userData: jsonEncode(kanbanPost.toJson()),
        );
      }
      
      print('Debug: Canvas state saved - ${customerDataBoxPositions.length} customers, ${supplierDataBoxPositions.length} suppliers, ${productionControlDataBoxPositions.length} production controls');
    } catch (e) {
      print('Debug: Error saving canvas state: $e');
    }
  }
  
  /// Helper method to convert Map&lt;String, Map&lt;String, dynamic&gt;&gt; to Map&lt;String, String&gt;

  // Add error handling to load canvas data
  Future<void> _loadCanvasData() async {
    setState(() => isLoading = true);
    
    try {
      await Future.wait([
        _loadProcesses(),
        _loadCanvasIcons(),
        _loadConnectors(),
        _loadMaterialConnectors(),
        _loadKanbanLoops(),
        _loadWithdrawalLoops(),
        _loadKanbanPosts(),
        _loadDataBoxes(),
      ]);
      
      setState(() => isLoading = false);
      _showMessage('Canvas loaded successfully');
    } catch (e) {
      setState(() => isLoading = false);
      _showMessage('Error loading canvas data: $e');
    }
  }

  Future<void> _loadProcesses() async {
    final processEntries = await db.getProcessesForValueStream(widget.valueStreamId);
    
    List<ProcessObject> processObjects = [];
    
    for (final processEntry in processEntries) {
      // Create ProcessObject with all required parameters
      final processObject = ProcessObject(
        id: processEntry.id,
        name: processEntry.processName,
        description: processEntry.processDescription ?? '',
        valueStreamId: processEntry.valueStreamId,
        position: Offset(processEntry.positionX ?? 100, processEntry.positionY ?? 100),
        size: const Size(140, 160),
        color: Colors.lightBlue[100]!,
        staff: processEntry.staff,
        dailyDemand: processEntry.dailyDemand,
        wip: processEntry.wip,
        uptime: processEntry.uptime,
        coTime: processEntry.coTime,
        taktTime: processEntry.taktTime,
      );
      processObjects.add(processObject);
    }
    
    processes = processObjects;
  }

  Future<void> _loadCanvasIcons() async {
    try {
      final canvasState = await db.loadCanvasState(
        valueStreamId: widget.valueStreamId,
        partNumber: widget.partNumber,
      );
      
      canvasIcons = [];
      for (final state in canvasState) {
        // Regular canvas icons (not data boxes or special types)
        if (!['customerDataBox', 'supplierDataBox', 'productionControlDataBox', 
               'truckDataBox', 'kanbanPost', 'kanbanLoop', 'withdrawalLoop', 
               'materialConnector', 'customer'].contains(state.iconType)) {
          final iconType = _getCanvasIconTypeFromString(state.iconType);
          if (iconType != null) {
            final icon = CanvasIcon(
              id: state.iconId,
              type: iconType,
              label: state.iconType,
              iconData: _getIconDataForType(iconType),
              color: _getColorForType(iconType),
              position: Offset(state.positionX, state.positionY),
            );
            canvasIcons.add(icon);
          }
        }
      }
      print('Debug: Loaded ${canvasIcons.length} canvas icons');
    } catch (e) {
      print('Debug: Error loading canvas icons: $e');
      canvasIcons = [];
    }
  }

  Future<void> _loadConnectors() async {
    // Note: Regular connectors are not yet stored in database
    // This will be implemented when connector persistence is added
    connectors = [];
  }

  Future<void> _loadMaterialConnectors() async {
    try {
      final canvasState = await db.loadCanvasState(
        valueStreamId: widget.valueStreamId,
        partNumber: widget.partNumber,
      );
      
      materialConnectors = [];
      for (final state in canvasState) {
        if (state.iconType == 'materialConnector' && state.userData != null) {
          try {
            final connectorData = jsonDecode(state.userData!);
            final connector = MaterialConnector.fromJson(connectorData);
            materialConnectors.add(connector);
          } catch (e) {
            print('Debug: Error parsing material connector: $e');
          }
        }
      }
      print('Debug: Loaded ${materialConnectors.length} material connectors');
    } catch (e) {
      print('Debug: Error loading material connectors: $e');
      materialConnectors = [];
    }
  }

  Future<void> _loadKanbanLoops() async {
    try {
      final canvasState = await db.loadCanvasState(
        valueStreamId: widget.valueStreamId,
        partNumber: widget.partNumber,
      );
      
      kanbanLoops = [];
      for (final state in canvasState) {
        if (state.iconType == 'kanbanLoop' && state.userData != null) {
          try {
            final loopData = jsonDecode(state.userData!);
            final loop = KanbanLoop.fromJson(loopData);
            kanbanLoops.add(loop);
          } catch (e) {
            print('Debug: Error parsing kanban loop: $e');
          }
        }
      }
      print('Debug: Loaded ${kanbanLoops.length} kanban loops');
    } catch (e) {
      print('Debug: Error loading kanban loops: $e');
      kanbanLoops = [];
    }
  }

  Future<void> _loadWithdrawalLoops() async {
    try {
      final canvasState = await db.loadCanvasState(
        valueStreamId: widget.valueStreamId,
        partNumber: widget.partNumber,
      );
      
      withdrawalLoops = [];
      for (final state in canvasState) {
        if (state.iconType == 'withdrawalLoop' && state.userData != null) {
          try {
            final loopData = jsonDecode(state.userData!);
            final loop = WithdrawalLoop.fromJson(loopData);
            withdrawalLoops.add(loop);
          } catch (e) {
            print('Debug: Error parsing withdrawal loop: $e');
          }
        }
      }
      print('Debug: Loaded ${withdrawalLoops.length} withdrawal loops');
    } catch (e) {
      print('Debug: Error loading withdrawal loops: $e');
      withdrawalLoops = [];
    }
  }

  Future<void> _loadKanbanPosts() async {
    try {
      final canvasState = await db.loadCanvasState(
        valueStreamId: widget.valueStreamId,
        partNumber: widget.partNumber,
      );
      
      kanbanPosts = [];
      for (final state in canvasState) {
        if (state.iconType == 'kanbanPost' && state.userData != null) {
          try {
            final postData = jsonDecode(state.userData!);
            final post = KanbanPost.fromJson(postData);
            kanbanPosts.add(post);
          } catch (e) {
            print('Debug: Error parsing kanban post: $e');
          }
        }
      }
      print('Debug: Loaded ${kanbanPosts.length} kanban posts');
    } catch (e) {
      print('Debug: Error loading kanban posts: $e');
      kanbanPosts = [];
    }
  }

  Future<void> _loadDataBoxes() async {
    try {
      final canvasState = await db.loadCanvasState(
        valueStreamId: widget.valueStreamId,
        partNumber: widget.partNumber,
      );

      // Clear existing legacy data boxes
      customerDataBoxPositions.clear();
      supplierDataBoxPositions.clear();
      productionControlDataBoxPositions.clear();
      truckDataBoxPositions.clear();
      supplierDataBoxUserData.clear();

      // Restore legacy data boxes from canvas state
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
            break;
        }
      }
      
      print('Debug: Loaded ${customerDataBoxPositions.length} customer data boxes');
      print('Debug: Loaded ${supplierDataBoxPositions.length} supplier data boxes');
      print('Debug: Loaded ${productionControlDataBoxPositions.length} production control data boxes');
      
      // Also load using new managers for any objects managed by them
      await Future.wait([
        customerManager.loadFromDatabase(widget.valueStreamId, widget.partNumber),
        supplierManager.loadFromDatabase(widget.valueStreamId, widget.partNumber),
        productionControlManager.loadFromDatabase(widget.valueStreamId, widget.partNumber),
      ]);
    } catch (e) {
      print('Debug: Error loading data boxes: $e');
      // Initialize empty maps on error
      customerDataBoxPositions = {};
      supplierDataBoxPositions = {};
      productionControlDataBoxPositions = {};
      truckDataBoxPositions = {};
      supplierDataBoxUserData = {};
    }
  }

  // Helper methods for canvas icon management
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

  // Message display
  void _showMessage(String message, {Duration? duration}) {
    // Defer message showing until after the frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            duration: duration ?? const Duration(seconds: 3),
          ),
        );
      }
    });
  }

  // Canvas icon management - optimized for key workflows
  void _addCanvasIcon(CanvasIconTemplate template) {
    switch (template.type) {
      case CanvasIconType.informationArrow:
        _showMessage('Information Arrow mode: Select source process');
        break;
        
      case CanvasIconType.electronicArrow:
        _showMessage('Electronic Arrow mode: Select source process');
        break;
        
      case CanvasIconType.materialArrow:
        materialConnectorState.startConnectorCreation(template.type);
        _showMessage('Material Arrow mode: Select supplier process');
        break;
        
      case CanvasIconType.materialPush:
        materialConnectorState.startConnectorCreation(template.type);
        _showMessage('Material Push mode: Select supplier process');
        break;
        
      case CanvasIconType.kanbanLoop:
        kanbanLoopHandler.startKanbanLoopCreation();
        _showMessage('Kanban Loop mode: Select supermarket first, then kanban post');
        break;
        
      case CanvasIconType.kanbanPost:
        _createKanbanPost();
        break;
        
      case CanvasIconType.withdrawalLoop:
        _showMessage('Withdrawal Loop mode: Select customer first, then supermarket');
        break;
        
      case CanvasIconType.customerDataBox:
        _createCustomerDataBox();
        break;
        
      case CanvasIconType.supplierDataBox:
        _createSupplierDataBox();
        break;
        
      case CanvasIconType.productionControlDataBox:
        _createProductionControlDataBox();
        break;
        
      case CanvasIconType.fifo:
      case CanvasIconType.buffer:
      case CanvasIconType.kanbanMarket:
        materialConnectorState.startConnectorCreation(template.type);
        _showMessage('${template.label} mode: Select supplier process');
        break;
        
      default:
        // Create regular canvas icon for static elements
        final newIcon = CanvasIcon(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          type: template.type,
          label: template.label,
          iconData: template.iconData,
          color: template.color,
          position: const Offset(100, 300),
        );
        
        setState(() {
          canvasIcons.add(newIcon);
          selectedCanvasIcon = newIcon;
          _clearOtherSelections();
        });
        _saveCanvasState();
        break;
    }
  }

  // Connection handle management
  void _showConnectionHandles(String itemId, String itemType) {
    // Implementation for showing connection handles
  }

  void _hideConnectionHandles() {
    // Implementation for hiding connection handles
  }

  // Connector creation callbacks
  void _addConnector(CanvasConnector connector) {
    setState(() {
      connectors.add(connector);
      selectedConnector = connector.id;
    });
  }

  void _addMaterialConnector(MaterialConnector connector) {
    setState(() {
      materialConnectors.add(connector);
      selectedMaterialConnector = connector.id;
    });
    _saveCanvasState();
  }

  void _cancelConnection() {
    materialConnectorState.reset();
  }

  // Selection methods
  void _selectProcess(ProcessObject process) {
    if (materialConnectorState.isActive) {
      _handleProcessConnectionModes(process);
    } else {
      setState(() {
        selectedProcess = process;
        _clearOtherSelections();
      });
    }
  }

  void _handleProcessConnectionModes(ProcessObject process) {
    if (!materialConnectorState.isSupplierSelected) {
      materialConnectorState.setSupplierProcess(process);
      _showMessage('Supplier "${process.name}" selected. Now select customer.');
    } else {
      materialConnectorState.setCustomerProcess(process);
      if (materialConnectorState.canCreateConnector()) {
        materialConnectorCreator.createConnector();
      }
    }
  }

  void _clearOtherSelections() {
    selectedCanvasIcon = null;
    selectedCustomer = null;
    selectedSupplier = null;
    selectedProductionControl = null;
    selectedConnector = null;
    selectedMaterialConnector = null;
    selectedKanbanLoop = null;
    selectedWithdrawalLoop = null;
    selectedKanbanPost = null;
    selectedCustomerDataBox = null;
    selectedSupplierDataBox = null;
    selectedProductionControlDataBox = null;
    selectedTruckDataBox = null;
  }

  void _clearSelectionsExceptCustomer() {
    selectedCanvasIcon = null;
    selectedSupplier = null;
    selectedProductionControl = null;
    selectedConnector = null;
    selectedMaterialConnector = null;
    selectedKanbanLoop = null;
    selectedWithdrawalLoop = null;
    selectedKanbanPost = null;
    selectedCustomerDataBox = null;
    selectedSupplierDataBox = null;
    selectedProductionControlDataBox = null;
    selectedTruckDataBox = null;
  }

  void _clearSelectionsExceptSupplier() {
    selectedCanvasIcon = null;
    selectedCustomer = null;
    selectedProductionControl = null;
    selectedConnector = null;
    selectedMaterialConnector = null;
    selectedKanbanLoop = null;
    selectedWithdrawalLoop = null;
    selectedKanbanPost = null;
    selectedCustomerDataBox = null;
    selectedSupplierDataBox = null;
    selectedProductionControlDataBox = null;
    selectedTruckDataBox = null;
  }

  void _clearSelectionsExceptProductionControl() {
    selectedCanvasIcon = null;
    selectedCustomer = null;
    selectedSupplier = null;
    selectedConnector = null;
    selectedMaterialConnector = null;
    selectedKanbanLoop = null;
    selectedWithdrawalLoop = null;
    selectedKanbanPost = null;
    selectedCustomerDataBox = null;
    selectedSupplierDataBox = null;
    selectedProductionControlDataBox = null;
    selectedTruckDataBox = null;
  }

  void _deselectAll() {
    setState(() {
      selectedProcess = null;
      _clearOtherSelections();
      materialConnectorState.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Canvas - ${widget.partNumber}'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : processes.isEmpty
              ? _buildEmptyCanvasWithDebug()
              : _buildCanvas(),
    );
  }

  Widget _buildCanvas() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTap: _deselectAll,
          child: Stack(
            children: [
              // Canvas background with simple grid
              Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.grey[50],
                child: CustomPaint(
                  painter: _GridPainter(),
                ),
              ),
              
              // Process widgets
              ...processes.map((process) => DraggableProcessWidget(
                key: ValueKey(process.id),
                process: process,
                isSelected: selectedProcess?.id == process.id,
                onTap: () => _selectProcess(process),
                onDragEnd: (processData, globalOffset) => _updateProcessPosition(processData, globalOffset, constraints),
              )),
              
              // Canvas icons
              ...canvasIcons.map((icon) => DraggableCanvasIcon(
                key: ValueKey(icon.id),
                canvasIcon: icon,
                isSelected: selectedCanvasIcon?.id == icon.id,
                onTap: (selectedIcon) => _selectCanvasIcon(selectedIcon),
                onPositionChanged: (selectedIcon, position) => _updateCanvasIconPosition(selectedIcon, position),
                onDelete: (selectedIcon) => _deleteCanvasIcon(selectedIcon),
              )),
              
              // Customer widgets
              ...customerManager.customers.map((customer) => CustomerWidget(
                key: ValueKey(customer.id),
                customer: customer.copyWith(isSelected: selectedCustomer?.id == customer.id),
                onTap: (customerId) => _selectCustomer(customer),
                onPositionChanged: (customerId, globalOffset) => _updateCustomerPosition(customer, globalOffset),
                onDelete: (customerId) => _deleteCustomer(customer),
              )),
              
              // Supplier widgets
              ...supplierManager.suppliers.map((supplier) => SupplierWidget(
                key: ValueKey(supplier.id),
                supplier: supplier.copyWith(isSelected: selectedSupplier?.id == supplier.id),
                onTap: (supplierId) => _selectSupplier(supplier),
                onPositionChanged: (supplierId, globalOffset) => _updateSupplierPosition(supplier, globalOffset),
                onDelete: (supplierId) => _deleteSupplier(supplier),
                onDataChanged: (supplierId, newData) => _updateSupplierData(supplierId, newData),
              )),
              
              // Production Control widgets
              ...productionControlManager.productionControls.map((productionControl) => ProductionControlWidget(
                key: ValueKey(productionControl.id),
                productionControl: productionControl.copyWith(isSelected: selectedProductionControl?.id == productionControl.id),
                onTap: (productionControlId) => _selectProductionControl(productionControl),
                onPositionChanged: (productionControlId, globalOffset) => _updateProductionControlPosition(productionControl, globalOffset),
                onDelete: (productionControlId) => _deleteProductionControl(productionControl),
              )),
              
              // Material connectors
              ...materialConnectors.map((connector) => MaterialConnectorWidget(
                key: ValueKey(connector.id),
                materialConnector: connector,
                processes: processes,
                isSelected: selectedMaterialConnector == connector.id,
                onTap: (connectorId) => _selectMaterialConnector(connector),
                onUpdate: (updated) => _updateMaterialConnector(updated),
                showConnectionHandles: false,
                selectedHandle: null,
                onHandleSelected: (handle) => {},
              )),
              
              // Kanban loops  
              ...kanbanLoops.map((loop) => KanbanLoopWidget(
                key: ValueKey(loop.id),
                kanbanLoop: loop,
                isSelected: selectedKanbanLoop == loop.id,
                onTap: (loopId) => _selectKanbanLoop(loop),
                onUpdate: (updated) => _updateKanbanLoop(updated),
              )),
              
              // Kanban posts
              ...kanbanPosts.map((kanbanPost) => KanbanPostWidget(
                key: ValueKey(kanbanPost.id),
                kanbanPost: kanbanPost,
                isSelected: selectedKanbanPost == kanbanPost.id,
                onTap: (postId) => _selectKanbanPost(kanbanPost),
                onUpdate: (updated) => _updateKanbanPost(updated),
              )),
              
              // Floating icon toolbar for adding canvas elements
              FloatingIconToolbar(
                onIconSelected: _addCanvasIcon,
              ),
              
              // Debug information positioned at bottom of screen
              Positioned(
                bottom: 20,
                left: 20,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Debug Info:',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Processes: ${processes.length}',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      Text(
                        'Customers: ${customerManager.customers.length}',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      Text(
                        'Suppliers: ${supplierManager.suppliers.length}',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      Text(
                        'Production Control: ${productionControlManager.productionControls.length}',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      if (selectedProcess != null)
                        Text(
                          'Selected: ${selectedProcess!.name}',
                          style: const TextStyle(color: Colors.yellow, fontSize: 12),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyCanvasWithDebug() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTap: _deselectAll,
          child: Stack(
            children: [
              // Canvas background with simple grid
              Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.grey[50],
                child: CustomPaint(
                  painter: _GridPainter(),
                ),
              ),
              
              // No processes message
              const Center(
                child: Text(
                  'No processes found.\nAdd processes in the Value Stream Details screen.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
              
              // Floating icon toolbar for adding canvas elements
              FloatingIconToolbar(
                onIconSelected: _addCanvasIcon,
              ),
              
              // Debug information positioned at bottom of screen
              Positioned(
                bottom: 20,
                left: 20,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Debug Info:',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'ValueStreamId: ${widget.valueStreamId}',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      Text(
                        'PartNumber: ${widget.partNumber}',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      Text(
                        'Processes: ${processes.length}',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      Text(
                        'Customers: ${customerManager.customers.length}',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      Text(
                        'Suppliers: ${supplierManager.suppliers.length}',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      Text(
                        'Production Control: ${productionControlManager.productionControls.length}',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      Text(
                        'Loading: $isLoading',
                        style: const TextStyle(color: Colors.yellow, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Update process position with unified coordinate handling
  void _updateProcessPosition(ProcessObject process, Offset globalOffset, BoxConstraints constraints) {
    print('--- Updating Process Position ---');
    print('Received globalOffset: $globalOffset');
    
    // Manual coordinate correction: account for AppBar height
    const appBarHeight = 56.0; // Standard Material AppBar height
    final correctedOffset = Offset(globalOffset.dx, globalOffset.dy - appBarHeight);
    print('Corrected for AppBar: $correctedOffset');
    
    // Apply boundary constraints to keep process within canvas
    final constrainedOffset = _applyBoundaryConstraints(correctedOffset, process.size, constraints);
    print('Final constrainedOffset: $constrainedOffset');
    
    setState(() {
      // Find and update the process in the list
      final index = processes.indexWhere((p) => p.id == process.id);
      if (index != -1) {
        processes[index] = process.copyWith(position: constrainedOffset);
      }
    });
    
    // Save the updated position to database
    _saveProcessPosition(process.id, constrainedOffset);
  }
  
  // Helper method to apply boundary constraints
  Offset _applyBoundaryConstraints(Offset position, Size objectSize, BoxConstraints constraints) {
    final double constrainedX = position.dx.clamp(0.0, constraints.maxWidth - objectSize.width);
    final double constrainedY = position.dy.clamp(0.0, constraints.maxHeight - objectSize.height);
    return Offset(constrainedX, constrainedY);
  }
  
  // Save process position to database
  Future<void> _saveProcessPosition(int processId, Offset position) async {
    try {
      await db.updateProcessPosition(processId, position.dx, position.dy);
    } catch (e) {
      print('Error saving process position: $e');
    }
  }
  
  void _selectCanvasIcon(CanvasIcon icon) {
    setState(() {
      selectedCanvasIcon = icon;
      _clearOtherSelections();
    });
  }
  
  void _updateCanvasIconPosition(CanvasIcon icon, Offset position) {
    // Implementation for updating icon position
  }
  
  void _deleteCanvasIcon(CanvasIcon icon) {
    // Implementation for deleting icon
  }
  
  // Customer methods
  void _selectCustomer(Customer customer) {
    setState(() {
      _clearSelectionsExceptCustomer();
      selectedCustomer = customer;
    });
  }
  
  void _updateCustomerPosition(Customer customer, Offset globalOffset) {
    print('--- Updating Customer Position ---');
    print('Received globalOffset: $globalOffset');
    
    // Manual coordinate correction: account for AppBar height
    const appBarHeight = 56.0; // Standard Material AppBar height
    final correctedOffset = Offset(globalOffset.dx, globalOffset.dy - appBarHeight);
    print('Corrected for AppBar: $correctedOffset');
    
    setState(() {
      customerManager.updatePosition(customer.id, correctedOffset, widget.valueStreamId, widget.partNumber);
    });
    _debouncedSaveCanvasState();
  }
  
  void _deleteCustomer(Customer customer) {
    customerManager.deleteCustomer(customer.id, widget.valueStreamId, widget.partNumber);
    _saveCanvasState();
  }
  
  void _createCustomerDataBox() async {
    final customer = await customerManager.createCustomer(
      valueStreamId: widget.valueStreamId,
      partNumber: widget.partNumber,
      position: const Offset(100, 300),
    );
    setState(() {
      selectedCustomer = customer;
      _clearOtherSelections();
    });
    _saveCanvasState();
    _showMessage('Customer created. You can drag it to position and configure its data.');
  }
  
  // Supplier methods
  void _selectSupplier(Supplier supplier) {
    setState(() {
      _clearSelectionsExceptSupplier();
      selectedSupplier = supplier;
    });
  }
  
  void _updateSupplierPosition(Supplier supplier, Offset globalOffset) {
    print('--- Updating Supplier Position ---');
    print('Received globalOffset: $globalOffset');
    
    // Manual coordinate correction: account for AppBar height
    const appBarHeight = 56.0; // Standard Material AppBar height
    final correctedOffset = Offset(globalOffset.dx, globalOffset.dy - appBarHeight);
    print('Corrected for AppBar: $correctedOffset');
    
    setState(() {
      supplierManager.updatePosition(supplier.id, correctedOffset, widget.valueStreamId, widget.partNumber);
    });
  }

  /// Update supplier data when fields are changed
  void _updateSupplierData(String supplierId, SupplierData newData) {
    supplierManager.updateData(supplierId, newData, widget.valueStreamId, widget.partNumber);
    _debouncedSaveCanvasState();
  }
  
  void _deleteSupplier(Supplier supplier) {
    supplierManager.deleteSupplier(supplier.id, widget.valueStreamId, widget.partNumber);
  }
  
  void _createSupplierDataBox() async {
    final supplier = await supplierManager.createSupplier(
      valueStreamId: widget.valueStreamId,
      partNumber: widget.partNumber,
      position: const Offset(300, 300),
    );
    setState(() {
      _clearSelectionsExceptSupplier();
      selectedSupplier = supplier;
    });
    _showMessage('Supplier created. You can drag it to position and configure its data.');
  }
  
  // Production Control methods
  void _selectProductionControl(ProductionControl productionControl) {
    setState(() {
      _clearSelectionsExceptProductionControl();
      selectedProductionControl = productionControl;
    });
  }
  
  void _updateProductionControlPosition(ProductionControl productionControl, Offset globalOffset) {
    print('--- Updating Production Control Position ---');
    print('Received globalOffset: $globalOffset');
    
    // Manual coordinate correction: account for AppBar height
    const appBarHeight = 56.0; // Standard Material AppBar height
    final correctedOffset = Offset(globalOffset.dx, globalOffset.dy - appBarHeight);
    print('Corrected for AppBar: $correctedOffset');
    
    setState(() {
      productionControlManager.updatePosition(productionControl.id, correctedOffset, widget.valueStreamId, widget.partNumber);
    });
  }
  
  void _deleteProductionControl(ProductionControl productionControl) {
    productionControlManager.deleteProductionControl(productionControl.id, widget.valueStreamId, widget.partNumber);
  }
  
  void _createProductionControlDataBox() async {
    final productionControl = await productionControlManager.createProductionControl(
      valueStreamId: widget.valueStreamId,
      partNumber: widget.partNumber,
      position: const Offset(500, 300),
    );
    setState(() {
      _clearSelectionsExceptProductionControl();
      selectedProductionControl = productionControl;
    });
    _showMessage('Production Control created. You can drag it to position and configure its data.');
  }
  
  // Kanban Post methods
  void _createKanbanPost() {
    final newKanbanPost = KanbanPost(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      label: 'Kanban Post',
      position: const Offset(200, 300),
      size: const Size(50, 45),
    );
    
    setState(() {
      kanbanPosts.add(newKanbanPost);
      selectedKanbanPost = newKanbanPost.id;
      _clearOtherSelections();
    });
    _saveCanvasState();
    _showMessage('Kanban Post created. You can drag it to position.');
  }
  
  void _selectKanbanPost(KanbanPost kanbanPost) {
    setState(() {
      selectedKanbanPost = kanbanPost.id;
      _clearOtherSelections();
    });
  }
  
  void _updateKanbanPost(KanbanPost kanbanPost) {
    setState(() {
      final index = kanbanPosts.indexWhere((p) => p.id == kanbanPost.id);
      if (index != -1) {
        kanbanPosts[index] = kanbanPost;
      }
    });
    _saveCanvasState();
  }
  
  void _selectMaterialConnector(MaterialConnector connector) {
    setState(() {
      selectedMaterialConnector = connector.id;
      _clearOtherSelections();
    });
  }
  
  void _updateMaterialConnector(MaterialConnector connector) {
    // Implementation for updating material connector
  }
  
  void _selectKanbanLoop(KanbanLoop loop) {
    setState(() {
      selectedKanbanLoop = loop.id;
      _clearOtherSelections();
    });
  }
  
  void _updateKanbanLoop(KanbanLoop loop) {
    // Implementation for updating kanban loop
  }

  // Lifecycle management
  @override
  void dispose() {
    // Cancel any pending save timer
    _saveTimer?.cancel();
    
    super.dispose();
  }
}

// Simple grid painter for canvas background
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 0.5;

    const gridSize = 20.0;
    
    // Draw vertical lines
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    
    // Draw horizontal lines
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
