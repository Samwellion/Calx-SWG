import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/kanban_loop.dart';
import '../utils/canvas_drag_handler.dart';

class KanbanLoopWidget extends StatefulWidget {
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
  State<KanbanLoopWidget> createState() => _KanbanLoopWidgetState();
}

class _KanbanLoopWidgetState extends State<KanbanLoopWidget> with CanvasDragHandler {
  late TextEditingController _hoursController;
  late FocusNode _hoursFocusNode;
  bool _isUserEditing = false;
  bool _showHoursInput = false; // Track if we should show input field or display text

  @override
  void initState() {
    super.initState();
    final initialValue = widget.kanbanLoop.hoursValue?.toStringAsFixed(0) ?? '';
    _hoursController = TextEditingController(text: initialValue);
    _hoursFocusNode = FocusNode();
    
    // Listen for focus changes to save when field loses focus
    _hoursFocusNode.addListener(() {
      if (!_hoursFocusNode.hasFocus && _isUserEditing) {
        _onHoursEditingComplete();
      }
    });
  }

  @override
  void didUpdateWidget(KanbanLoopWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update the text field if the user is not actively editing
    if (!_isUserEditing && oldWidget.kanbanLoop.hoursValue != widget.kanbanLoop.hoursValue) {
      _hoursController.text = widget.kanbanLoop.hoursValue?.toStringAsFixed(0) ?? '';
    }
  }

  @override
  void dispose() {
    _hoursController.dispose();
    _hoursFocusNode.dispose();
    super.dispose();
  }

  void _onHoursChanged(String value) {
    _isUserEditing = true; // Mark that user is actively editing
    // Don't update the model while user is typing - this prevents focus loss
  }

  void _onHoursSubmitted(String value) {
    _isUserEditing = false; // User finished editing
    _showHoursInput = false; // Hide input field
    _updateHoursValue(value);
  }

  void _onHoursEditingComplete() {
    _isUserEditing = false; // User finished editing
    _showHoursInput = false; // Hide input field
    _updateHoursValue(_hoursController.text);
  }

  void _updateHoursValue(String value) {
    final hours = double.tryParse(value);
    if (hours != widget.kanbanLoop.hoursValue) {
      final updatedKanbanLoop = widget.kanbanLoop.copyWith(
        hoursValue: hours,
      );
      widget.onUpdate?.call(updatedKanbanLoop);
    }
  }

  void _startHoursEditing() {
    setState(() {
      _showHoursInput = true;
      _isUserEditing = true;
    });
    // Focus the input field after a short delay to ensure it's built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _hoursFocusNode.requestFocus();
    });
  }

  String _getFormattedHours() {
    final hours = widget.kanbanLoop.hoursValue;
    if (hours == null) return 'hrs';
    return '${hours.toStringAsFixed(0)} hrs';
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Dotted line path - this should not intercept touch events
        IgnorePointer(
          child: CustomPaint(
            painter: KanbanLoopPathPainter(
              pathPoints: widget.kanbanLoop.pathPoints,
              isSelected: widget.isSelected,
            ),
            child: Container(),
          ),
        ),
        
        // 5-sided kanban icon at the center (draggable) - only this small area should be interactive
        Positioned(
          left: widget.kanbanLoop.kanbanIconPosition.dx - 15,
          top: widget.kanbanLoop.kanbanIconPosition.dy - 15,
          child: SizedBox(
            width: 30,
            height: 30,
            child: createDraggableWrapper(
              currentPosition: widget.kanbanLoop.kanbanIconPosition,
              onPositionChanged: (newPosition) {
                final updatedLoop = widget.kanbanLoop.updateKanbanPosition(newPosition);
                widget.onUpdate?.call(updatedLoop);
              },
              onTap: () => widget.onTap?.call(widget.kanbanLoop.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: isDragging
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
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
                child: CustomPaint(
                  painter: KanbanIconPainter(
                    color: widget.isSelected ? Colors.blue : Colors.amber,
                  ),
                ),
              ),
            ),
          ),
        ),
        
        // Hours display/input field below the kanban icon
        Positioned(
          left: widget.kanbanLoop.kanbanIconPosition.dx - 30,
          top: widget.kanbanLoop.kanbanIconPosition.dy + 20,
          child: SizedBox(
            width: 60,
            height: 20,
            child: _showHoursInput
                ? // Show input field when editing
                  TextField(
                    controller: _hoursController,
                    focusNode: _hoursFocusNode,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 10),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                      isDense: true,
                    ),
                    onChanged: _onHoursChanged,
                    onSubmitted: _onHoursSubmitted,
                  )
                : // Show formatted display text when not editing
                  GestureDetector(
                    onTap: _startHoursEditing,
                    child: Container(
                      width: 60,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        border: Border.all(color: Colors.grey.withOpacity(0.5)),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                        child: Text(
                          _getFormattedHours(),
                          style: const TextStyle(
                            fontSize: 9,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
          ),
        ),
        
        // Arrowhead at the supplier end - this should not intercept touch events
        Positioned(
          left: widget.kanbanLoop.supplierHandlePosition.dx - 8,
          top: widget.kanbanLoop.supplierHandlePosition.dy - 4,
          child: IgnorePointer(
            child: CustomPaint(
              painter: ArrowheadPainter(
                color: widget.isSelected ? Colors.blue : Colors.amber,
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
    if (widget.kanbanLoop.pathPoints.length < 2) return 0;
    
    final lastSegment = widget.kanbanLoop.pathPoints.last - widget.kanbanLoop.pathPoints[widget.kanbanLoop.pathPoints.length - 2];
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

