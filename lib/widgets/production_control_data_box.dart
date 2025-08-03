import 'package:flutter/material.dart';

class ProductionControlDataBox extends StatefulWidget {
  final String productionControlId;
  final Offset position;
  final Function(String, Offset) onPositionChanged;
  final Function(String)? onTap;
  final Function(String)? onDelete;
  final bool isSelected;

  const ProductionControlDataBox({
    super.key,
    required this.productionControlId,
    required this.position,
    required this.onPositionChanged,
    this.onTap,
    this.onDelete,
    this.isSelected = false,
  });

  @override
  State<ProductionControlDataBox> createState() => _ProductionControlDataBoxState();
}

class _ProductionControlDataBoxState extends State<ProductionControlDataBox> {
  bool _isDragging = false;
  Offset? _startPosition;
  Offset? _initialTouchPosition;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.position.dx,
      top: widget.position.dy,
      child: GestureDetector(
        onTap: () => widget.onTap?.call(widget.productionControlId),
        onPanStart: (details) {
          setState(() {
            _isDragging = true;
            _startPosition = widget.position;
            _initialTouchPosition = details.globalPosition;
          });
        },
        onPanUpdate: (details) {
          if (_startPosition != null && _initialTouchPosition != null) {
            final delta = details.globalPosition - _initialTouchPosition!;
            final newPosition = _startPosition! + delta;
            widget.onPositionChanged(widget.productionControlId, newPosition);
          }
        },
        onPanEnd: (details) {
          setState(() {
            _isDragging = false;
            _startPosition = null;
            _initialTouchPosition = null;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 180,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: widget.isSelected ? Colors.blue : Colors.black,
              width: widget.isSelected ? 3 : 2,
            ),
            boxShadow: _isDragging || widget.isSelected
                ? [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Stack(
            children: [
              // Main content
              Column(
                children: [
                  // Header section with "Production Control" text
                  Container(
                    width: double.infinity,
                    height: 30,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.black,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Production Control',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  // Empty content area
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              
              // Delete button when selected
              if (widget.isSelected && widget.onDelete != null)
                Positioned(
                  top: -2,
                  right: -2,
                  child: GestureDetector(
                    onTap: () => widget.onDelete?.call(widget.productionControlId),
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 16,
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
