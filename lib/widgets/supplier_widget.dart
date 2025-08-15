// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import '../models/supplier.dart';
import '../utils/unified_canvas_drag.dart';

/// Optimized Supplier Widget for VSM canvas
class SupplierWidget extends StatefulWidget {
  final Supplier supplier;
  final Function(String supplierId) onTap;
  final Function(String supplierId, Offset position) onPositionChanged;
  final Function(String supplierId)? onDelete;
  final Function(String supplierId, SupplierData data)? onDataChanged;

  const SupplierWidget({
    super.key,
    required this.supplier,
    required this.onTap,
    required this.onPositionChanged,
    this.onDelete,
    this.onDataChanged,
  });

  @override
  State<SupplierWidget> createState() => _SupplierWidgetState();
}

class _SupplierWidgetState extends State<SupplierWidget> with UnifiedCanvasDrag {
  static const Size _supplierSize = Size(180, 150);

  @override
  Widget build(BuildContext context) {
    return createUnifiedDraggable<Supplier>(
      data: widget.supplier,
      position: widget.supplier.position,
      size: _supplierSize,
      childBuilder: (isDragging, isGhost) => _buildSupplierBox(
        isDragging: isDragging,
        isGhost: isGhost,
      ),
      onDragEnd: (supplierData, globalOffset) {
        widget.onPositionChanged(widget.supplier.id, globalOffset);
      },
      onTap: () => widget.onTap(widget.supplier.id),
    );
  }

  Widget _buildSupplierBox({required bool isDragging, required bool isGhost}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 180,
      height: 150,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: isDragging || widget.supplier.isSelected
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
          // Supplier building outline covering entire widget
          CustomPaint(
            size: Size.infinite,
            painter: _SupplierBuildingPainter(),
          ),
          
          // Main content
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20), // Space for building outline
                
                // Title
                Center(
                  child: Text(
                    'Supplier',
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
                      _buildEditableField('Lead Time:', widget.supplier.data.leadTime, (value) {
                        if (widget.onDataChanged != null) {
                          final updatedData = widget.supplier.data.copyWith(leadTime: value);
                          widget.onDataChanged!(widget.supplier.id, updatedData);
                        }
                      }),
                      const SizedBox(height: 6),
                      _buildEditableField('Expedite Time:', widget.supplier.data.expediteTime, (value) {
                        if (widget.onDataChanged != null) {
                          final updatedData = widget.supplier.data.copyWith(expediteTime: value);
                          widget.onDataChanged!(widget.supplier.id, updatedData);
                        }
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Delete button when selected
          if (widget.supplier.isSelected && widget.onDelete != null)
            Positioned(
              top: -2,
              right: -2,
              child: GestureDetector(
                onTap: () => widget.onDelete?.call(widget.supplier.id),
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

  Widget _buildEditableField(String label, String value, Function(String) onChanged) {
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
        SizedBox(
          width: 40,
          height: 20,
          child: TextField(
            controller: TextEditingController(text: value),
            style: const TextStyle(
              color: Colors.black,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              border: OutlineInputBorder(),
            ),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

/// Custom painter for supplier building outline (matching customer factory roof)
class _SupplierBuildingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    final segmentWidth = size.width / 3;
    final roofHeight = 30.0; // Height of the roof area
    
    // Draw sawtooth roof pattern at the top (same as customer)
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
    
    // Bottom edge: horizontal line at widget bottom
    canvas.drawLine(
      Offset(0, size.height), // Start at left bottom corner
      Offset(size.width, size.height), // End at right bottom corner
      paint
    );

    // Draw the sawtooth roof path
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
