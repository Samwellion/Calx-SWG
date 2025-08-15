import 'package:flutter/material.dart';

/// Mixin that provides common dragging functionality for canvas items
mixin CanvasDragHandler<T extends StatefulWidget> on State<T> {
  bool _isDragging = false;
  Offset? _startPosition;
  Offset? _initialTouchPosition;

  bool get isDragging => _isDragging;

  /// Call this in onPanStart to initialize dragging
  void startDrag(Offset currentPosition, Offset globalTouchPosition) {
    setState(() {
      _isDragging = true;
      _startPosition = currentPosition;
      _initialTouchPosition = globalTouchPosition;
    });
  }

  /// Call this in onPanUpdate to handle position changes
  /// Returns the new calculated position based on drag delta
  Offset? updateDragPosition(Offset globalTouchPosition) {
    if (_startPosition != null && _initialTouchPosition != null) {
      final delta = globalTouchPosition - _initialTouchPosition!;
      return _startPosition! + delta;
    }
    return null;
  }

  /// Call this in onPanEnd to finish dragging
  void endDrag() {
    setState(() {
      _isDragging = false;
      _startPosition = null;
      _initialTouchPosition = null;
    });
  }

  /// Creates a complete GestureDetector with drag handling
  /// Use this to wrap your widget content
  Widget createDraggableWrapper({
    required Widget child,
    required Offset currentPosition,
    required Function(Offset) onPositionChanged,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      onPanStart: (details) {
        startDrag(currentPosition, details.globalPosition);
      },
      onPanUpdate: (details) {
        final newPosition = updateDragPosition(details.globalPosition);
        if (newPosition != null) {
          onPositionChanged(newPosition);
        }
      },
      onPanEnd: (details) {
        endDrag();
      },
      child: child,
    );
  }
}

/// Utility class for common drag-related calculations
class DragUtils {
  /// Calculates if drag has moved beyond a threshold (useful for drag detection)
  static bool hasDraggedBeyondThreshold(Offset start, Offset current, {double threshold = 5.0}) {
    final distance = (current - start).distance;
    return distance > threshold;
  }

  /// Constrains a position within given bounds
  static Offset constrainPosition(Offset position, Size itemSize, Size canvasBounds) {
    return Offset(
      position.dx.clamp(0, canvasBounds.width - itemSize.width),
      position.dy.clamp(0, canvasBounds.height - itemSize.height),
    );
  }
}