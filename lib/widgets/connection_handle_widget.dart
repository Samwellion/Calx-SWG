import 'package:flutter/material.dart';
import '../models/connection_handle.dart';

/// Widget that displays connection handles around a canvas item
class ConnectionHandleWidget extends StatelessWidget {
  final List<ConnectionHandle> handles;
  final ConnectionHandle? selectedHandle;
  final Function(ConnectionHandle) onHandleSelected;
  final bool showHandles;
  final Size itemSize;
  final double paddingExtension;

  const ConnectionHandleWidget({
    super.key,
    required this.handles,
    required this.onHandleSelected,
    required this.itemSize,
    this.selectedHandle,
    this.showHandles = false,
    this.paddingExtension = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    if (!showHandles) return const SizedBox.shrink();

    return SizedBox(
      width: itemSize.width + (paddingExtension * 2),
      height: itemSize.height + (paddingExtension * 2),
      child: Stack(
        children: handles.map((handle) => _buildHandle(handle)).toList(),
      ),
    );
  }

  Widget _buildHandle(ConnectionHandle handle) {
    final isSelected = selectedHandle?.id == handle.id;
    final isDefault = handle.alignment == HandleAlignment.center;
    
    // Position handle based on its calculated offset, accounting for padding
    double leftOffset = handle.offset.dx + paddingExtension - 6; // Center the 12px handle
    double topOffset = handle.offset.dy + paddingExtension - 6;
    
    // For edge handles, adjust to extend slightly outside the item bounds for better visibility
    switch (handle.position) {
      case HandlePosition.top:
        topOffset = handle.offset.dy + paddingExtension - 12; // Extend above the top edge
        break;
      case HandlePosition.right:
        leftOffset = handle.offset.dx + paddingExtension; // Extend beyond the right edge
        break;
      case HandlePosition.bottom:
        topOffset = handle.offset.dy + paddingExtension; // Extend below the bottom edge
        break;
      case HandlePosition.left:
        leftOffset = handle.offset.dx + paddingExtension - 12; // Extend beyond the left edge
        break;
    }
    
    return Positioned(
      left: leftOffset,
      top: topOffset,
      child: GestureDetector(
        onTap: () => onHandleSelected(handle),
        child: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: isSelected 
                ? Colors.orange 
                : isDefault 
                    ? Colors.blue 
                    : Colors.lightBlue,
            border: Border.all(
              color: Colors.white,
              width: 2,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: isDefault
              ? Icon(
                  Icons.fiber_manual_record,
                  size: 4,
                  color: Colors.white,
                )
              : null,
        ),
      ),
    );
  }
}

/// Widget that shows hover hints for available handles
class ConnectionHandleHints extends StatelessWidget {
  final List<ConnectionHandle> handles;
  final Size itemSize;
  final bool showHints;

  const ConnectionHandleHints({
    super.key,
    required this.handles,
    required this.itemSize,
    this.showHints = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!showHints) return const SizedBox.shrink();

    // Only show center handles as hints
    final centerHandles = handles.where(
      (h) => h.alignment == HandleAlignment.center
    ).toList();

    return SizedBox(
      width: itemSize.width,
      height: itemSize.height,
      child: Stack(
        children: centerHandles.map((handle) => _buildHint(handle)).toList(),
      ),
    );
  }

  Widget _buildHint(ConnectionHandle handle) {
    // Position hints based on the handle's calculated offset
    double leftOffset = handle.offset.dx - 4; // Center the 8px hint
    double topOffset = handle.offset.dy - 4;
    
    // For edge hints, adjust to extend slightly outside the item bounds
    switch (handle.position) {
      case HandlePosition.top:
        topOffset = handle.offset.dy - 8; // Extend above the top edge
        break;
      case HandlePosition.right:
        leftOffset = handle.offset.dx; // Extend beyond the right edge
        break;
      case HandlePosition.bottom:
        topOffset = handle.offset.dy; // Extend below the bottom edge
        break;
      case HandlePosition.left:
        leftOffset = handle.offset.dx - 8; // Extend beyond the left edge
        break;
    }
    
    return Positioned(
      left: leftOffset,
      top: topOffset,
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.6),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
