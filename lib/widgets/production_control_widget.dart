import 'package:flutter/material.dart';
import '../models/production_control.dart';
import '../utils/unified_canvas_drag.dart';
import '../utils/deletable_canvas_object.dart';

/// Optimized Production Control Widget for VSM canvas
class ProductionControlWidget extends StatefulWidget {
  final ProductionControl productionControl;
  final Function(String productionControlId) onTap;
  final Function(String productionControlId, Offset position) onPositionChanged;
  final Function(String productionControlId)? onDelete;

  const ProductionControlWidget({
    super.key,
    required this.productionControl,
    required this.onTap,
    required this.onPositionChanged,
    this.onDelete,
  });

  @override
  State<ProductionControlWidget> createState() => _ProductionControlWidgetState();
}

class _ProductionControlWidgetState extends State<ProductionControlWidget> with UnifiedCanvasDrag, DeletableCanvasObject {
  static const Size _productionControlSize = Size(200, 100);

  @override
  Widget build(BuildContext context) {
    return createUnifiedDraggable<ProductionControl>(
      data: widget.productionControl,
      position: widget.productionControl.position,
      size: _productionControlSize,
      childBuilder: (isDragging, isGhost) => _buildProductionControlBox(
        isDragging: isDragging,
        isGhost: isGhost,
      ),
      onDragEnd: (productionControlData, globalOffset) {
        widget.onPositionChanged(widget.productionControl.id, globalOffset);
      },
      onTap: () => widget.onTap(widget.productionControl.id),
    );
  }

  Widget _buildProductionControlBox({required bool isDragging, required bool isGhost}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 200,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.lightBlue[50],
        border: Border.all(color: Colors.blue, width: 2),
        borderRadius: BorderRadius.circular(8),
        boxShadow: isDragging || widget.productionControl.isSelected
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
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Center(
                  child: Text(
                    'Production Control',
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
                  color: Colors.blue,
                ),
                const SizedBox(height: 8),
                
                // Data fields - Empty for now, can be configured later
                Expanded(
                  child: Container(
                    // Empty space for production control data
                    // User can configure this as needed
                  ),
                ),
              ],
            ),
          ),
          
          // Delete button using common mixin
          if (widget.onDelete != null)
            buildDeleteButton(
              isSelected: widget.productionControl.isSelected,
              onDelete: () => widget.onDelete!(widget.productionControl.id),
            ),
        ],
      ),
    );
  }

}
