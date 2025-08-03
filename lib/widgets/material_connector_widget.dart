import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/material_connector.dart';
import '../models/process_object.dart';
import '../models/canvas_icon.dart';
import 'fifo_icon.dart';

class MaterialConnectorWidget extends StatefulWidget {
  final MaterialConnector materialConnector;
  final List<ProcessObject> processes;
  final Function(MaterialConnector)? onUpdate;
  final Function(String)? onTap;
  final bool isSelected;

  const MaterialConnectorWidget({
    super.key,
    required this.materialConnector,
    required this.processes,
    this.onUpdate,
    this.onTap,
    this.isSelected = false,
  });

  @override
  State<MaterialConnectorWidget> createState() => _MaterialConnectorWidgetState();
}

class _MaterialConnectorWidgetState extends State<MaterialConnectorWidget> {
  late TextEditingController _piecesController;
  bool _isUserEditing = false; // Track if user is actively typing
  ProcessObject? _supplierProcess;
  ProcessObject? _customerProcess;

  @override
  void initState() {
    super.initState();
    final initialValue = widget.materialConnector.numberOfPieces?.toString() ?? '';
    print('DEBUG: Initializing controller with value: "$initialValue" (numberOfPieces: ${widget.materialConnector.numberOfPieces})');
    _piecesController = TextEditingController(
      text: initialValue,
    );
    _findProcesses();
  }

  @override
  void didUpdateWidget(MaterialConnectorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update the text field if the user is not actively editing
    if (!_isUserEditing && oldWidget.materialConnector.numberOfPieces != widget.materialConnector.numberOfPieces) {
      _piecesController.text = widget.materialConnector.numberOfPieces?.toString() ?? '';
    }
    if (oldWidget.processes != widget.processes) {
      _findProcesses();
    }
  }

  void _findProcesses() {
    _supplierProcess = widget.processes.firstWhere(
      (p) => p.id.toString() == widget.materialConnector.supplierProcessId,
      orElse: () => ProcessObject(
        id: 0,
        name: '',
        description: '',
        color: Colors.grey,
        position: Offset.zero,
        valueStreamId: 0,
      ),
    );
    if (_supplierProcess!.id == 0) _supplierProcess = null;

    _customerProcess = widget.processes.firstWhere(
      (p) => p.id.toString() == widget.materialConnector.customerProcessId,
      orElse: () => ProcessObject(
        id: 0,
        name: '',
        description: '',
        color: Colors.grey,
        position: Offset.zero,
        valueStreamId: 0,
      ),
    );
    if (_customerProcess!.id == 0) _customerProcess = null;
  }

  @override
  void dispose() {
    _piecesController.dispose();
    super.dispose();
  }
  
  void _onPiecesChanged(String value) {
    print('DEBUG: _onPiecesChanged called with value: "$value"');
    _isUserEditing = true; // Mark that user is actively editing
    
    // Parse the raw number directly
    final pieces = int.tryParse(value);
    print('DEBUG: Parsed pieces: $pieces');
    if (pieces != widget.materialConnector.numberOfPieces) {
      print('DEBUG: Updating connector with pieces: $pieces');
      final updatedConnector = widget.materialConnector.copyWith(
        numberOfPieces: pieces,
      );
      widget.onUpdate?.call(updatedConnector);
    } else {
      print('DEBUG: No update needed, pieces unchanged');
    }
    
    // Don't reset the editing flag automatically - let onSubmitted handle it
  }
  
  void _onPiecesSubmitted(String value) {
    print('DEBUG: _onPiecesSubmitted called with value: "$value"');
    _isUserEditing = false; // User finished editing
    // Just process the final value - no need to call _onPiecesChanged again
    final pieces = int.tryParse(value);
    if (pieces != widget.materialConnector.numberOfPieces) {
      final updatedConnector = widget.materialConnector.copyWith(
        numberOfPieces: pieces,
      );
      widget.onUpdate?.call(updatedConnector);
    }
  }

  String _getEstimatedLeadTime() {
    return widget.materialConnector.calculateEstimatedLeadTime(
      _supplierProcess?.taktTime,
    );
  }

  @override
  Widget build(BuildContext context) {
    final iconData = MaterialConnectorHelper.getIconData(widget.materialConnector.type);
    final color = widget.isSelected 
        ? Colors.blue 
        : MaterialConnectorHelper.getColor(widget.materialConnector.type);

    return Positioned(
      left: widget.materialConnector.position.dx - widget.materialConnector.size.width / 2,
      top: widget.materialConnector.position.dy - widget.materialConnector.size.height / 2,
      child: GestureDetector(
        onTap: () => widget.onTap?.call(widget.materialConnector.id),
        child: Container(
          width: widget.materialConnector.size.width,
          height: widget.materialConnector.size.height,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: widget.isSelected ? Colors.blue : Colors.grey,
              width: widget.isSelected ? 2.0 : 1.0,
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(4.0), // Increased padding for better spacing
            child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // Better spacing
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              widget.materialConnector.type == CanvasIconType.fifo
                  ? FifoIcon(
                      color: color,
                      size: 60, // Reduced from 70 to fit better
                    )
                  : Icon(
                      iconData,
                      size: 20,
                      color: color,
                    ),

              // Label (optional, can be removed if not needed)
              if (widget.materialConnector.type != CanvasIconType.fifo)
                Text(
                  widget.materialConnector.label,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              
              // Number of pieces input field
              SizedBox(
                width: 75, // Adjusted width
                height: 18, // Reduced height
                child: TextField(
                  controller: _piecesController,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 9), // Smaller font
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly, // Built-in digits-only filter
                  ],
                  decoration: const InputDecoration(
                    hintText: '# pcs',
                    hintStyle: TextStyle(fontSize: 8),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                    isDense: true,
                  ),
                  onChanged: _onPiecesChanged,
                  onSubmitted: _onPiecesSubmitted,
                ),
              ),
              
              // Calculated lead time
              Container(
                width: 75, // Adjusted to match input field
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  _getEstimatedLeadTime(),
                  style: const TextStyle(
                    fontSize: 8,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }
}

/// Widget to handle the selection mode for material connectors
class MaterialConnectorSelectionWidget extends StatefulWidget {
  final CanvasIconType materialConnectorType;
  final List<ProcessObject> processes;
  final Function(ProcessObject, ProcessObject) onProcessesSelected;
  final VoidCallback onCancel;

  const MaterialConnectorSelectionWidget({
    super.key,
    required this.materialConnectorType,
    required this.processes,
    required this.onProcessesSelected,
    required this.onCancel,
  });

  @override
  State<MaterialConnectorSelectionWidget> createState() => _MaterialConnectorSelectionWidgetState();
}

class _MaterialConnectorSelectionWidgetState extends State<MaterialConnectorSelectionWidget> {
  ProcessObject? _selectedSupplier;
  ProcessObject? _selectedCustomer;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Processes for ${widget.materialConnectorType.toString().split('.').last.toUpperCase()}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Supplier selection
              const Text('Select Supplier Process:'),
              const SizedBox(height: 8),
              DropdownButton<ProcessObject>(
                value: _selectedSupplier,
                hint: const Text('Choose supplier process'),
                isExpanded: true,
                items: widget.processes.map((process) {
                  return DropdownMenuItem(
                    value: process,
                    child: Text(process.name),
                  );
                }).toList(),
                onChanged: (ProcessObject? value) {
                  setState(() {
                    _selectedSupplier = value;
                  });
                },
              ),
              
              const SizedBox(height: 16),
              
              // Customer selection
              const Text('Select Customer Process:'),
              const SizedBox(height: 8),
              DropdownButton<ProcessObject>(
                value: _selectedCustomer,
                hint: const Text('Choose customer process'),
                isExpanded: true,
                items: widget.processes.map((process) {
                  return DropdownMenuItem(
                    value: process,
                    child: Text(process.name),
                  );
                }).toList(),
                onChanged: (ProcessObject? value) {
                  setState(() {
                    _selectedCustomer = value;
                  });
                },
              ),
              
              const SizedBox(height: 20),
              
              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: widget.onCancel,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                    ),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: _selectedSupplier != null && _selectedCustomer != null
                        ? () => widget.onProcessesSelected(_selectedSupplier!, _selectedCustomer!)
                        : null,
                    child: const Text('Create'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
