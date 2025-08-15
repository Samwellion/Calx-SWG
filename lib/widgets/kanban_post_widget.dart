import 'package:flutter/material.dart';
import '../models/kanban_post.dart';
import '../utils/unified_canvas_drag.dart';

class KanbanPostWidget extends StatelessWidget with UnifiedCanvasDrag {
  final KanbanPost kanbanPost;
  final bool isSelected;
  final Function(String)? onTap;
  final Function(String, Offset) onPositionChanged;

  const KanbanPostWidget({
    super.key,
    required this.kanbanPost,
    this.isSelected = false,
    this.onTap,
    required this.onPositionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return createUnifiedDraggable<KanbanPost>(
      data: kanbanPost,
      position: kanbanPost.position,
      size: kanbanPost.size,
      childBuilder: (isDragging, isGhost) => _buildKanbanPost(
        isDragging: isDragging,
        isGhost: isGhost,
      ),
      onDragEnd: (postData, globalOffset) {
        onPositionChanged(kanbanPost.id, globalOffset);
      },
      onTap: () => onTap?.call(kanbanPost.id),
    );
  }

  Widget _buildKanbanPost({bool isDragging = false, bool isGhost = false}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: kanbanPost.size.width,
      height: kanbanPost.size.height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: isDragging || isSelected
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(isDragging ? 0.3 : 0.1),
                  blurRadius: isDragging ? 8 : 4,
                  offset: Offset(0, isDragging ? 4 : 2),
                ),
              ]
            : [
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
            color: isSelected ? Colors.blue : Colors.black,
          ),
          size: const Size(50, 45), // Icon only - no text field
        ),
      ),
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
