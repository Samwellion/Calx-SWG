import 'package:flutter/material.dart';
import '../models/kanban_loop.dart';

class KanbanLoopWidget extends StatelessWidget {
  final KanbanLoop kanbanLoop;
  final bool isSelected;
  final Function(String)? onTap;
  final Function(KanbanLoop)? onUpdate; // New callback for updating kanban loop

  const KanbanLoopWidget({
    super.key,
    required this.kanbanLoop,
    this.isSelected = false,
    this.onTap,
    this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Dotted line path - this should not intercept touch events
        IgnorePointer(
          child: CustomPaint(
            painter: KanbanLoopPathPainter(
              pathPoints: kanbanLoop.pathPoints,
              isSelected: isSelected,
            ),
            child: Container(),
          ),
        ),
        
        // 5-sided kanban icon at the center (draggable) - only this small area should be interactive
        Positioned(
          left: kanbanLoop.kanbanIconPosition.dx - 15,
          top: kanbanLoop.kanbanIconPosition.dy - 15,
          child: SizedBox(
            width: 30,
            height: 30,
            child: LongPressDraggable<String>(
              data: kanbanLoop.id,
              feedback: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.amber.withOpacity(0.8),
                  border: Border.all(color: Colors.amber, width: 2.0),
                ),
                child: CustomPaint(
                  painter: KanbanIconPainter(color: Colors.amber),
                ),
              ),
              childWhenDragging: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.5),
                  border: Border.all(color: Colors.amber, width: 1.0),
                ),
              ),
              onDragEnd: (details) {
                // Convert global coordinates to local canvas coordinates
                // Get the main canvas RenderBox from the context
                final overlay = Overlay.of(context);
                final renderBox = overlay.context.findRenderObject() as RenderBox?;
                if (renderBox != null) {
                  try {
                    final localPosition = renderBox.globalToLocal(details.offset);
                    final updatedLoop = kanbanLoop.updateKanbanPosition(localPosition);
                    onUpdate?.call(updatedLoop);
                  } catch (e) {
                    // Fallback to using offset directly
                    final updatedLoop = kanbanLoop.updateKanbanPosition(details.offset);
                    onUpdate?.call(updatedLoop);
                  }
                } else {
                  // Fallback to using offset directly
                  final updatedLoop = kanbanLoop.updateKanbanPosition(details.offset);
                  onUpdate?.call(updatedLoop);
                }
              },
              child: GestureDetector(
                onTap: () => onTap?.call(kanbanLoop.id),
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: CustomPaint(
                    painter: KanbanIconPainter(
                      color: isSelected ? Colors.blue : Colors.amber,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        
        // Arrowhead at the supplier end - this should not intercept touch events
        Positioned(
          left: kanbanLoop.supplierHandlePosition.dx - 8,
          top: kanbanLoop.supplierHandlePosition.dy - 4,
          child: IgnorePointer(
            child: CustomPaint(
              painter: ArrowheadPainter(
                color: isSelected ? Colors.blue : Colors.amber,
                direction: _getArrowDirection(),
              ),
              size: const Size(16, 8),
            ),
          ),
        ),
      ],
    );
  }

  /// Determine the direction the arrow should point based on the last path segment
  double _getArrowDirection() {
    if (kanbanLoop.pathPoints.length < 2) return 0;
    
    final lastSegment = kanbanLoop.pathPoints.last - kanbanLoop.pathPoints[kanbanLoop.pathPoints.length - 2];
    return lastSegment.direction;
  }
}

class KanbanLoopPathPainter extends CustomPainter {
  final List<Offset> pathPoints;
  final bool isSelected;

  KanbanLoopPathPainter({
    required this.pathPoints,
    required this.isSelected,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (pathPoints.length < 2) return;

    final paint = Paint()
      ..color = isSelected ? Colors.blue : Colors.amber
      ..strokeWidth = isSelected ? 2.0 : 1.5
      ..style = PaintingStyle.stroke;

    // Create dotted line effect
    const dashWidth = 5.0;
    const dashSpace = 3.0;

    for (int i = 0; i < pathPoints.length - 1; i++) {
      final start = pathPoints[i];
      final end = pathPoints[i + 1];
      
      _drawDottedLine(canvas, start, end, paint, dashWidth, dashSpace);
    }
  }

  void _drawDottedLine(Canvas canvas, Offset start, Offset end, Paint paint, double dashWidth, double dashSpace) {
    final path = Path()..moveTo(start.dx, start.dy);
    
    final distance = (end - start).distance;
    final direction = (end - start) / distance;
    
    double currentDistance = 0;
    bool isDash = true;
    
    while (currentDistance < distance) {
      final segmentLength = isDash ? dashWidth : dashSpace;
      final nextDistance = (currentDistance + segmentLength).clamp(0.0, distance);
      final nextPoint = start + direction * nextDistance;
      
      if (isDash) {
        path.lineTo(nextPoint.dx, nextPoint.dy);
        canvas.drawPath(path, paint);
        path.reset();
        path.moveTo(nextPoint.dx, nextPoint.dy);
      } else {
        path.moveTo(nextPoint.dx, nextPoint.dy);
      }
      
      currentDistance = nextDistance;
      isDash = !isDash;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is! KanbanLoopPathPainter ||
           oldDelegate.pathPoints != pathPoints ||
           oldDelegate.isSelected != isSelected;
  }
}

class KanbanIconPainter extends CustomPainter {
  final Color color;

  KanbanIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    // Define the kanban card shape (rectangle with cut-off top-right corner)
    final padding = size.width * 0.15; // Small padding from edges
    final left = padding;
    final top = padding;
    final right = size.width - padding;
    final bottom = size.height - padding;
    final cutSize = (right - left) * 0.25; // Size of the cut-off corner

    final path = Path();
    // Start from top-left
    path.moveTo(left, top);
    // Go to top-right minus the cut
    path.lineTo(right - cutSize, top);
    // Diagonal cut to create the folded corner
    path.lineTo(right, top + cutSize);
    // Go down to bottom-right
    path.lineTo(right, bottom);
    // Go left to bottom-left
    path.lineTo(left, bottom);
    // Close back to top-left
    path.close();

    // Draw only the black outline (no fill)
    final strokePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    
    canvas.drawPath(path, strokePaint);
    
    // Draw the fold line to show the cut corner
    final foldPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    
    canvas.drawLine(
      Offset(right - cutSize, top),
      Offset(right - cutSize, top + cutSize),
      foldPaint,
    );
    canvas.drawLine(
      Offset(right - cutSize, top + cutSize),
      Offset(right, top + cutSize),
      foldPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is! KanbanIconPainter || oldDelegate.color != color;
  }
}

class ArrowheadPainter extends CustomPainter {
  final Color color;
  final double direction; // Direction in radians

  ArrowheadPainter({
    required this.color,
    required this.direction,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    
    // Create an arrowhead pointing in the specified direction
    final tipX = size.width;
    final tipY = size.height / 2;
    final baseX = 0.0;
    final baseTopY = 0.0;
    final baseBottomY = size.height;

    path.moveTo(tipX, tipY);
    path.lineTo(baseX, baseTopY);
    path.lineTo(baseX, baseBottomY);
    path.close();

    // Rotate the canvas to point the arrow in the correct direction
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(direction);
    canvas.translate(-size.width / 2, -size.height / 2);
    
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is! ArrowheadPainter ||
           oldDelegate.color != color ||
           oldDelegate.direction != direction;
  }
}

