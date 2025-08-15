import 'package:flutter/material.dart';

/// UNIFIED Canvas Drag Solution - Use this for ALL draggable objects
/// This ensures consistent drag behavior without snap-back
mixin UnifiedCanvasDrag<T> {
  
  /// Creates a standard Draggable widget for any canvas object
  /// All canvas objects should use this method for consistency
  Widget createUnifiedDraggable<ObjectType extends Object>({
    required ObjectType data,
    required Offset position,
    required Widget Function(bool isDragging, bool isGhost) childBuilder,
    required Function(ObjectType, Offset) onDragEnd,
    VoidCallback? onTap,
    Size? size,
  }) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: Draggable<ObjectType>(
        data: data,
        
        // Feedback widget (what user sees while dragging)
        feedback: Material(
          color: Colors.transparent,
          elevation: 8,
          child: Opacity(
            opacity: 0.8,
            child: childBuilder(true, false), // isDragging=true, isGhost=false
          ),
        ),
        
        // Child when dragging (faded version at original position)
        childWhenDragging: Opacity(
          opacity: 0.3,
          child: childBuilder(false, true), // isDragging=false, isGhost=true
        ),
        
        // Normal child
        child: GestureDetector(
          onTap: onTap,
          child: childBuilder(false, false), // isDragging=false, isGhost=false
        ),
        
        // CRITICAL: Always update position - no conditions
        onDragEnd: (details) {
          onDragEnd(data, details.offset);
        },
      ),
    );
  }
  
  /// Standard position update method with coordinate conversion and constraints
  /// All position updates should use this method
  void updatePositionWithConstraints({
    required BuildContext context,
    required void Function() setState,
    required Offset globalOffset,
    required Size objectSize,
    required BoxConstraints constraints,
    required Function(Offset) updateCallback,
  }) {
    // Convert global offset to local canvas coordinates
    final RenderBox? canvasRenderBox = context.findRenderObject() as RenderBox?;
    final localOffset = canvasRenderBox?.globalToLocal(globalOffset) ?? globalOffset;
    
    // Apply boundary constraints to keep object within canvas
    final constrainedOffset = _applyBoundaryConstraints(localOffset, objectSize, constraints);
    
    // Update with setState
    setState();
    updateCallback(constrainedOffset);
  }
  
  /// Helper method to apply boundary constraints
  Offset _applyBoundaryConstraints(Offset position, Size objectSize, BoxConstraints constraints) {
    final double constrainedX = position.dx.clamp(0.0, constraints.maxWidth - objectSize.width);
    final double constrainedY = position.dy.clamp(0.0, constraints.maxHeight - objectSize.height);
    return Offset(constrainedX, constrainedY);
  }
}

/// Standard drag configuration for all canvas objects
class CanvasDragConfig {
  static const Duration animationDuration = Duration(milliseconds: 150);
  static const double feedbackOpacity = 0.8;
  static const double ghostOpacity = 0.3;
  static const double dragElevation = 8.0;
  
  /// Standard shadow for dragged objects
  static List<BoxShadow> get dragShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.2),
      spreadRadius: 2,
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
  ];
  
  /// Standard shadow for selected objects
  static List<BoxShadow> get selectionShadow => [
    BoxShadow(
      color: Colors.blue.withOpacity(0.3),
      spreadRadius: 3,
      blurRadius: 8,
      offset: const Offset(0, 3),
    ),
  ];
}
