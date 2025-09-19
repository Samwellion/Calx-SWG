import 'package:flutter/material.dart';

/// Mixin to provide common delete functionality for canvas objects
mixin DeletableCanvasObject {
  /// Creates a standardized delete button widget
  Widget buildDeleteButton({
    required bool isSelected,
    required VoidCallback onDelete,
    double top = -2,
    double right = -2,
    double size = 20,
    Color backgroundColor = Colors.red,
    Color iconColor = Colors.white,
    double iconSize = 14,
  }) {
    if (!isSelected) return const SizedBox.shrink();
    
    return Positioned(
      top: top,
      right: right,
      child: GestureDetector(
        onTap: onDelete,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Icon(
            Icons.close,
            color: iconColor,
            size: iconSize,
          ),
        ),
      ),
    );
  }
}