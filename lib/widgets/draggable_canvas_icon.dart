import 'package:flutter/material.dart';
import '../models/canvas_icon.dart';
import '../utils/canvas_drag_handler.dart';

class DraggableCanvasIcon extends StatefulWidget {
  final CanvasIcon canvasIcon;
  final Function(CanvasIcon, Offset) onPositionChanged;
  final Function(CanvasIcon)? onTap;
  final Function(CanvasIcon)? onDelete;
  final bool isSelected;

  const DraggableCanvasIcon({
    super.key,
    required this.canvasIcon,
    required this.onPositionChanged,
    this.onTap,
    this.onDelete,
    this.isSelected = false,
  });

  @override
  State<DraggableCanvasIcon> createState() => _DraggableCanvasIconState();
}

class _DraggableCanvasIconState extends State<DraggableCanvasIcon> with CanvasDragHandler {

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.canvasIcon.position.dx,
      top: widget.canvasIcon.position.dy,
      child: createDraggableWrapper(
        currentPosition: widget.canvasIcon.position,
        onPositionChanged: (newPosition) {
          widget.onPositionChanged(widget.canvasIcon, newPosition);
        },
        onTap: () => widget.onTap?.call(widget.canvasIcon),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: widget.canvasIcon.size.width,
          height: widget.canvasIcon.size.height,
          decoration: BoxDecoration(
            color: widget.canvasIcon.color.withOpacity(isDragging ? 0.8 : 0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: widget.isSelected
                  ? Colors.blue
                  : widget.canvasIcon.color.withOpacity(isDragging ? 1.0 : 0.5),
              width: widget.isSelected ? 2 : 1,
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
              // Main icon
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      widget.canvasIcon.iconData,
                      color: widget.canvasIcon.color,
                      size: 20,
                    ),
                    if (widget.canvasIcon.size.height > 30)
                      Text(
                        widget.canvasIcon.label,
                        style: TextStyle(
                          fontSize: 8,
                          color: widget.canvasIcon.color.withOpacity(0.8),
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
                    onTap: () => widget.onDelete?.call(widget.canvasIcon),
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 12,
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
