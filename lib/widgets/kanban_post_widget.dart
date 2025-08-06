import 'package:flutter/material.dart';
import '../models/kanban_post.dart';
import '../models/connection_handle.dart';
import 'connection_handle_widget.dart';

class KanbanPostWidget extends StatefulWidget {
  final KanbanPost kanbanPost;
  final bool isSelected;
  final Function(String)? onTap;
  final Function(KanbanPost)? onUpdate;
  final Function(ConnectionHandle)? onHandleSelected;
  final bool showConnectionHandles;
  final ConnectionHandle? selectedHandle;

  const KanbanPostWidget({
    super.key,
    required this.kanbanPost,
    this.isSelected = false,
    this.onTap,
    this.onUpdate,
    this.onHandleSelected,
    this.showConnectionHandles = false,
    this.selectedHandle,
  });

  @override
  State<KanbanPostWidget> createState() => _KanbanPostWidgetState();
}

class _KanbanPostWidgetState extends State<KanbanPostWidget> {
  /// Generate connection handles for kanban post
  List<ConnectionHandle> _generateConnectionHandles() {
    return ConnectionHandleCalculator.calculateHandles(
      itemId: widget.kanbanPost.id,
      itemType: 'kanbanPost',
      itemPosition: widget.kanbanPost.position,
      itemSize: widget.kanbanPost.size,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main kanban post widget
        Positioned(
          left: widget.kanbanPost.position.dx - widget.kanbanPost.size.width / 2,
          top: widget.kanbanPost.position.dy - widget.kanbanPost.size.height / 2,
          child: Draggable<String>(
            data: widget.kanbanPost.id,
            feedback: Container(
              width: widget.kanbanPost.size.width,
              height: widget.kanbanPost.size.height,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(2.0), // Minimal padding
                child: CustomPaint(
                  painter: KanbanPostIconPainter(color: Colors.brown),
                  size: const Size(50, 45), // Icon only - no text field
                ),
              ),
            ),
            childWhenDragging: Container(
              width: widget.kanbanPost.size.width,
              height: widget.kanbanPost.size.height,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onDragEnd: (details) {
              // Convert global coordinates to local canvas coordinates
              final overlay = Overlay.of(context);
              final renderBox = overlay.context.findRenderObject() as RenderBox?;
              if (renderBox != null) {
                try {
                  final localPosition = renderBox.globalToLocal(details.offset);
                  final updatedKanbanPost = widget.kanbanPost.copyWith(position: localPosition);
                  widget.onUpdate?.call(updatedKanbanPost);
                } catch (e) {
                  // Fallback to using offset directly
                  final updatedKanbanPost = widget.kanbanPost.copyWith(position: details.offset);
                  widget.onUpdate?.call(updatedKanbanPost);
                }
              } else {
                // Fallback to using offset directly
                final updatedKanbanPost = widget.kanbanPost.copyWith(position: details.offset);
                widget.onUpdate?.call(updatedKanbanPost);
              }
            },
            child: GestureDetector(
              onTap: () => widget.onTap?.call(widget.kanbanPost.id),
              child: Container(
                width: widget.kanbanPost.size.width,
                height: widget.kanbanPost.size.height,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(2.0), // Minimal padding
                  child: CustomPaint(
                    painter: KanbanPostIconPainter(
                      color: widget.isSelected ? Colors.blue : Colors.black,
                    ),
                    size: const Size(50, 45), // Icon only - no text field
                  ),
                ),
              ),
            ),
          ),
        ),
        
        // Connection handles overlay
        if (widget.showConnectionHandles)
          Positioned(
            left: widget.kanbanPost.position.dx - widget.kanbanPost.size.width / 2 - 12,
            top: widget.kanbanPost.position.dy - widget.kanbanPost.size.height / 2 - 12,
            child: ConnectionHandleWidget(
              handles: _generateConnectionHandles(),
              selectedHandle: widget.selectedHandle,
              showHandles: widget.showConnectionHandles,
              itemSize: widget.kanbanPost.size,
              paddingExtension: 12.0,
              onHandleSelected: widget.onHandleSelected ?? (_) {},
            ),
          ),
      ],
    );
  }
}

class KanbanPostIconPainter extends CustomPainter {
  final Color color;

  KanbanPostIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Use consistent thickness for all elements
    final lineThickness = size.width * 0.025;

    // Draw the cup/container at the top first to establish position
    final cupWidth = size.width * 0.3;
    final cupHeight = size.height * 0.24; // Increased from 0.18 to add ~3 pixels (0.06 * 50 = 3px)
    final cupLeft = (size.width - cupWidth) / 2;
    final cupTop = size.height * 0.1;
    
    // Draw left wall of cup
    final leftWall = Rect.fromLTWH(cupLeft, cupTop, lineThickness, cupHeight);
    canvas.drawRect(leftWall, fillPaint);
    
    // Draw right wall of cup
    final rightWall = Rect.fromLTWH(cupLeft + cupWidth - lineThickness, cupTop, lineThickness, cupHeight);
    canvas.drawRect(rightWall, fillPaint);
    
    // Draw bottom of cup
    final cupBottom = Rect.fromLTWH(cupLeft, cupTop + cupHeight - lineThickness, cupWidth, lineThickness);
    canvas.drawRect(cupBottom, fillPaint);

    // Draw the vertical post starting from the bottom of the cup
    final postWidth = lineThickness;
    final postHeight = size.height * 0.20; // Reduced from 0.23 to accommodate larger cup
    final postLeft = (size.width - postWidth) / 2;
    final postTop = cupTop + cupHeight; // Start directly at bottom of cup

    final postRect = Rect.fromLTWH(postLeft, postTop, postWidth, postHeight);
    canvas.drawRect(postRect, fillPaint);

    // Draw the horizontal base at the bottom of the vertical post
    final baseWidth = size.width * 0.35;
    final baseHeight = lineThickness;
    final baseLeft = (size.width - baseWidth) / 2;
    final baseTop = postTop + postHeight; // Position at bottom of post

    final baseRect = Rect.fromLTWH(baseLeft, baseTop, baseWidth, baseHeight);
    canvas.drawRect(baseRect, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is! KanbanPostIconPainter || oldDelegate.color != color;
  }
}
