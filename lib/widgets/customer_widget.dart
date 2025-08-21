import 'package:flutter/material.dart';
import '../models/customer.dart';
import '../utils/unified_canvas_drag.dart';

/// Optimized Customer Widget for VSM canvas
class CustomerWidget extends StatefulWidget {
  final Customer customer;
  final Function(String customerId) onTap;
  final Function(String customerId, Offset position) onPositionChanged;
  final Function(String customerId)? onDelete;

  const CustomerWidget({
    super.key,
    required this.customer,
    required this.onTap,
    required this.onPositionChanged,
    this.onDelete,
  });

  @override
  State<CustomerWidget> createState() => _CustomerWidgetState();
}

class _CustomerWidgetState extends State<CustomerWidget> with UnifiedCanvasDrag {
  static const Size _customerSize = Size(180, 150);

  @override
  Widget build(BuildContext context) {
    return createUnifiedDraggable<Customer>(
      data: widget.customer,
      position: widget.customer.position,
      size: _customerSize,
      childBuilder: (isDragging, isGhost) => _buildCustomerBox(
        isDragging: isDragging,
        isGhost: isGhost,
      ),
      onDragEnd: (customerData, globalOffset) {
        widget.onPositionChanged(widget.customer.id, globalOffset);
      },
      onTap: () => widget.onTap(widget.customer.id),
    );
  }

  Widget _buildCustomerBox({required bool isDragging, required bool isGhost}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 180,
      height: 150,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: isDragging || widget.customer.isSelected
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
          // Factory building outline covering entire widget
          CustomPaint(
            size: Size.infinite,
            painter: _FactoryRoofPainter(),
          ),
          
          // Main content
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40), // Space for roof area
                
                // Title
                Center(
                  child: Text(
                    widget.customer.label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                
                // Divider line
                Container(
                  height: 1,
                  color: Colors.black,
                ),
                const SizedBox(height: 8),
                
                // Data fields
                Expanded(
                  child: Column(
                    children: [
                      _buildDataRow('Monthly Demand:', widget.customer.data.monthlyDemand),
                      const SizedBox(height: 6),
                      _buildDataRow('TT(takt):', widget.customer.data.taktTime),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Delete button when selected
          if (widget.customer.isSelected && widget.onDelete != null)
            Positioned(
              top: -2,
              right: -2,
              child: GestureDetector(
                onTap: () => widget.onDelete?.call(widget.customer.id),
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
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

/// Optimized factory roof painter
class _FactoryRoofPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    final segmentWidth = size.width / 3;
    final roofHeight = 30.0; // Height of the roof area
    
    // Draw sawtooth roof pattern at the top
    path.moveTo(0, roofHeight);
    
    for (int i = 0; i < 3; i++) {
      final startX = segmentWidth * i;
      final peakX = startX + (segmentWidth * 0.8);
      final endX = segmentWidth * (i + 1);
      
      path.lineTo(peakX, 0); // Peak at top
      path.lineTo(endX, roofHeight); // Back down to roof baseline
    }

    // Add factory building sides and bottom
    // Left side: vertical line from roof baseline down to widget bottom
    canvas.drawLine(
      Offset(0, roofHeight), // Start at roof baseline
      Offset(0, size.height), // Extend to full widget bottom
      paint
    );
    
    // Right side: vertical line from roof baseline down to widget bottom
    canvas.drawLine(
      Offset(size.width, roofHeight), // Start at roof baseline
      Offset(size.width, size.height), // Extend to full widget bottom
      paint
    );
    
    // Bottom line: connecting left and right sides at widget bottom
    canvas.drawLine(
      Offset(0, size.height), // Bottom left of widget
      Offset(size.width, size.height), // Bottom right of widget
      paint
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
