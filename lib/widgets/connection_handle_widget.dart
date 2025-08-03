import 'package:flutter/material.dart';
import '../models/connection_handle.dart';

/// Widget that displays connection handles around a canvas item
class ConnectionHandleWidget extends StatelessWidget {
  final List<ConnectionHandle> handles;
  final ConnectionHandle? selectedHandle;
  final Function(ConnectionHandle) onHandleSelected;
  final bool showHandles;
  final Size itemSize;

  const ConnectionHandleWidget({
    super.key,
    required this.handles,
    required this.onHandleSelected,
    required this.itemSize,
    this.selectedHandle,
    this.showHandles = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!showHandles) return const SizedBox.shrink();

    // Create a container that's slightly larger than the item to accommodate handles that extend outside
    const handleExtension = 12.0;
    final expandedWidth = itemSize.width + (handleExtension * 2);
    final expandedHeight = itemSize.height + (handleExtension * 2);

    return Transform.translate(
      offset: const Offset(-handleExtension, -handleExtension), // Offset the entire widget
      child: SizedBox(
        width: expandedWidth,
        height: expandedHeight,
        child: Stack(
          children: handles.map((handle) => _buildHandle(handle)).toList(),
        ),
      ),
    );
  }

  Widget _buildHandle(ConnectionHandle handle) {
    final isSelected = selectedHandle?.id == handle.id;
    final isDefault = handle.alignment == HandleAlignment.center;
    
    // Since we offset the container by 12px, we need to add that back to position handles correctly
    const handleExtension = 12.0;
    
    // Position handles on the edges of the original item (accounting for container offset)
    double leftOffset = handle.offset.dx + handleExtension - 6; // Add extension offset, then center the 12px handle
    double topOffset = handle.offset.dy + handleExtension - 6;
    
    // For edge handles, adjust to sit exactly on the edge with slight extension for visibility
    switch (handle.position) {
      case HandlePosition.top:
        topOffset = handle.offset.dy + handleExtension - 12; // Extend above the top edge
        break;
      case HandlePosition.right:
        leftOffset = handle.offset.dx + handleExtension; // Extend beyond the right edge
        break;
      case HandlePosition.bottom:
        topOffset = handle.offset.dy + handleExtension; // Extend below the bottom edge
        break;
      case HandlePosition.left:
        leftOffset = handle.offset.dx + handleExtension - 12; // Extend beyond the left edge
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

    // Create a container that's slightly larger than the item to accommodate hints that extend outside
    const handleExtension = 12.0;
    final expandedWidth = itemSize.width + (handleExtension * 2);
    final expandedHeight = itemSize.height + (handleExtension * 2);

    return Transform.translate(
      offset: const Offset(-handleExtension, -handleExtension), // Offset the entire widget
      child: SizedBox(
        width: expandedWidth,
        height: expandedHeight,
        child: Stack(
          children: centerHandles.map((handle) => _buildHint(handle)).toList(),
        ),
      ),
    );
  }

  Widget _buildHint(ConnectionHandle handle) {
    // Position hints accounting for the container offset
    const handleExtension = 12.0;
    
    double leftOffset = handle.offset.dx + handleExtension - 4; // Add extension offset, then center the 8px hint
    double topOffset = handle.offset.dy + handleExtension - 4;
    
    // For edge hints, adjust to sit exactly on the edge with slight extension for visibility
    switch (handle.position) {
      case HandlePosition.top:
        topOffset = handle.offset.dy + handleExtension - 8; // Extend above the top edge
        break;
      case HandlePosition.right:
        leftOffset = handle.offset.dx + handleExtension; // Extend beyond the right edge
        break;
      case HandlePosition.bottom:
        topOffset = handle.offset.dy + handleExtension; // Extend below the bottom edge
        break;
      case HandlePosition.left:
        leftOffset = handle.offset.dx + handleExtension - 8; // Extend beyond the left edge
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
