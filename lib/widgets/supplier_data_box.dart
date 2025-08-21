import 'package:flutter/material.dart';
import '../utils/canvas_drag_handler.dart';

class SupplierDataBox extends StatefulWidget {
  final String supplierId;
  final Offset position;
  final Function(String, Offset) onPositionChanged;
  final Function(String)? onTap;
  final Function(String)? onDelete;
  final Function(String, String)? onDataChanged; // New callback for data changes
  final bool isSelected;
  final String? initialUserData; // Initial data to restore

  const SupplierDataBox({
    super.key,
    required this.supplierId,
    required this.position,
    required this.onPositionChanged,
    this.onTap,
    this.onDelete,
    this.onDataChanged,
    this.isSelected = false,
    this.initialUserData,
  });

  @override
  State<SupplierDataBox> createState() => _SupplierDataBoxState();
}

class _SupplierDataBoxState extends State<SupplierDataBox> with CanvasDragHandler {
  final TextEditingController _leadTimeController = TextEditingController();
  final TextEditingController _expediteTimeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize with default values in working days
    _leadTimeController.text = '0';
    _expediteTimeController.text = '0';
    
    // Restore initial user data if provided
    if (widget.initialUserData != null) {
      setUserData(widget.initialUserData);
    }
    
    // Add listeners to notify when data changes
    _leadTimeController.addListener(_onDataChanged);
    _expediteTimeController.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    _leadTimeController.removeListener(_onDataChanged);
    _expediteTimeController.removeListener(_onDataChanged);
    _leadTimeController.dispose();
    _expediteTimeController.dispose();
    super.dispose();
  }

  void _onDataChanged() {
    // Notify the canvas when user data changes
    if (widget.onDataChanged != null) {
      widget.onDataChanged!(widget.supplierId, getUserData());
    }
  }

  // Method to get current user data as JSON string
  String getUserData() {
    return '{"leadTime":"${_leadTimeController.text}","expediteTime":"${_expediteTimeController.text}"}';
  }

  // Method to set user data from JSON string
  void setUserData(String? userData) {
    if (userData == null || userData.isEmpty) return;
    
    try {
      // Simple parsing since we know the format
      final data = userData.replaceAll('{', '').replaceAll('}', '').split(',');
      for (final item in data) {
        final parts = item.split(':');
        if (parts.length == 2) {
          final key = parts[0].replaceAll('"', '').trim();
          final value = parts[1].replaceAll('"', '').trim();
          
          if (key == 'leadTime') {
            _leadTimeController.text = value;
          } else if (key == 'expediteTime') {
            _expediteTimeController.text = value;
          }
        }
      }
    } catch (e) {
      // Silently ignore parsing errors
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.position.dx,
      top: widget.position.dy,
      child: createDraggableWrapper(
        currentPosition: widget.position,
        onPositionChanged: (newPosition) {
          widget.onPositionChanged(widget.supplierId, newPosition);
        },
        onTap: () => widget.onTap?.call(widget.supplierId),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 180,
          height: 150,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: widget.isSelected ? Colors.blue : Colors.black,
              width: widget.isSelected ? 3 : 2,
            ),
            boxShadow: isDragging || widget.isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Stack(
            children: [
              // Main content
              Padding(
                padding: const EdgeInsets.all(6.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Factory roof design
                    CustomPaint(
                      size: const Size(168, 18),
                      painter: FactoryRoofPainter(),
                    ),
                    const SizedBox(height: 6),
                    
                    // Title
                    const Center(
                      child: Text(
                        'Supplier',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    
                    // Divider line
                    Container(
                      height: 1,
                      color: Colors.black,
                    ),
                    const SizedBox(height: 8),
                    
                    // Editable fields
                    Expanded(
                      child: Column(
                        children: [
                          // LT (leadtime) field
                          Row(
                            children: [
                              const Text(
                                'LT (leadtime):',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: SizedBox(
                                  height: 25,
                                  child: TextField(
                                    controller: _leadTimeController,
                                    style: const TextStyle(fontSize: 11),
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.right,
                                    decoration: const InputDecoration(
                                      border: UnderlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(
                                        vertical: 2,
                                        horizontal: 4,
                                      ),
                                      isDense: true,
                                      hintText: 'Working Days',
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          
                          // Expedite Time field
                          Row(
                            children: [
                              const Text(
                                'Expedite Time:',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: SizedBox(
                                  height: 25,
                                  child: TextField(
                                    controller: _expediteTimeController,
                                    style: const TextStyle(fontSize: 11),
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.right,
                                    decoration: const InputDecoration(
                                      border: UnderlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(
                                        vertical: 2,
                                        horizontal: 4,
                                      ),
                                      isDense: true,
                                      hintText: 'Working Days',
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Delete button when selected
              if (widget.isSelected && widget.onDelete != null)
                Positioned(
                  top: -2,
                  right: -2,
                  child: GestureDetector(
                    onTap: () => widget.onDelete?.call(widget.supplierId),
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class FactoryRoofPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    
    // Draw sawtooth roof pattern
    final double segmentWidth = size.width / 3;
    
    // Start from bottom left
    path.moveTo(0, size.height);
    
    // First triangle
    path.lineTo(segmentWidth * 0.8, 0);
    path.lineTo(segmentWidth, size.height);
    
    // Second triangle
    path.lineTo(segmentWidth * 1.8, 0);
    path.lineTo(segmentWidth * 2, size.height);
    
    // Third triangle
    path.lineTo(segmentWidth * 2.8, 0);
    path.lineTo(size.width, size.height);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
