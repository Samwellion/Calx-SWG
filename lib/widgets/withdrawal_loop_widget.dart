import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/withdrawal_loop.dart';

class WithdrawalLoopWidget extends StatefulWidget {
  final WithdrawalLoop withdrawalLoop;
  final bool isSelected;
  final Function(String)? onTap;
  final Function(WithdrawalLoop)? onUpdate; // New callback for updating withdrawal loop

  const WithdrawalLoopWidget({
    super.key,
    required this.withdrawalLoop,
    this.isSelected = false,
    this.onTap,
    this.onUpdate,
  });

  @override
  State<WithdrawalLoopWidget> createState() => _WithdrawalLoopWidgetState();
}

class _WithdrawalLoopWidgetState extends State<WithdrawalLoopWidget> {
  late TextEditingController _hoursController;
  late FocusNode _hoursFocusNode;
  bool _isUserEditing = false;
  bool _showHoursInput = false; // Track if we should show input field or display text
  bool _isDragging = false;
  Offset? _startPosition;
  Offset? _initialTouchPosition;

  @override
  void initState() {
    super.initState();
    final initialValue = widget.withdrawalLoop.hoursValue?.toStringAsFixed(0) ?? '';
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
  void didUpdateWidget(WithdrawalLoopWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update the text field if the user is not actively editing
    if (!_isUserEditing && oldWidget.withdrawalLoop.hoursValue != widget.withdrawalLoop.hoursValue) {
      _hoursController.text = widget.withdrawalLoop.hoursValue?.toStringAsFixed(0) ?? '';
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
    if (hours != widget.withdrawalLoop.hoursValue) {
      final updatedWithdrawalLoop = widget.withdrawalLoop.copyWith(
        hoursValue: hours,
      );
      widget.onUpdate?.call(updatedWithdrawalLoop);
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
    final hours = widget.withdrawalLoop.hoursValue;
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
            painter: WithdrawalLoopPathPainter(
              pathPoints: widget.withdrawalLoop.pathPoints,
              isSelected: widget.isSelected,
            ),
            child: Container(),
          ),
        ),
        
        // 5-sided kanban icon at the center (draggable) - only this small area should be interactive
        Positioned(
          left: widget.withdrawalLoop.kanbanIconPosition.dx - 15,
          top: widget.withdrawalLoop.kanbanIconPosition.dy - 15,
          child: SizedBox(
            width: 30,
            height: 30,
            child: GestureDetector(
              onTap: () => widget.onTap?.call(widget.withdrawalLoop.id),
              onPanStart: (details) {
                setState(() {
                  _isDragging = true;
                  _startPosition = widget.withdrawalLoop.kanbanIconPosition;
                  _initialTouchPosition = details.globalPosition;
                });
              },
              onPanUpdate: (details) {
                if (_startPosition != null && _initialTouchPosition != null) {
                  final delta = details.globalPosition - _initialTouchPosition!;
                  final newPosition = _startPosition! + delta;
                  final updatedLoop = widget.withdrawalLoop.updateKanbanPosition(newPosition);
                  widget.onUpdate?.call(updatedLoop);
                }
              },
              onPanEnd: (details) {
                setState(() {
                  _isDragging = false;
                  _startPosition = null;
                  _initialTouchPosition = null;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: _isDragging
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
                  painter: WithdrawalKanbanIconPainter(
                    color: widget.isSelected ? Colors.blue : Colors.orange,
                  ),
                ),
              ),
            ),
          ),
        ),
        
        // Hours display/input field below the kanban icon
        Positioned(
          left: widget.withdrawalLoop.kanbanIconPosition.dx - 30,
          top: widget.withdrawalLoop.kanbanIconPosition.dy + 20,
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
      ],
    );
  }
}

class WithdrawalLoopPathPainter extends CustomPainter {
  final List<Offset> pathPoints;
  final bool isSelected;

  WithdrawalLoopPathPainter({
    required this.pathPoints,
    this.isSelected = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (pathPoints.length < 2) return;

    final paint = Paint()
      ..color = isSelected ? Colors.blue : Colors.orange
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // Create dotted path
    final path = Path();
    path.moveTo(pathPoints.first.dx, pathPoints.first.dy);
    
    for (int i = 1; i < pathPoints.length; i++) {
      _drawDottedLine(canvas, pathPoints[i - 1], pathPoints[i], paint);
    }

    // Draw arrow at the end (pointing to supermarket)
    if (pathPoints.length >= 2) {
      final lastPoint = pathPoints.last;
      final secondLastPoint = pathPoints[pathPoints.length - 2];
      _drawArrowhead(canvas, secondLastPoint, lastPoint, paint);
    }
  }

  void _drawDottedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashWidth = 8.0;
    const dashSpace = 4.0;
    final distance = (end - start).distance;
    final dashCount = (distance / (dashWidth + dashSpace)).floor();

    for (int i = 0; i < dashCount; i++) {
      final startT = i * (dashWidth + dashSpace) / distance;
      final endT = (i * (dashWidth + dashSpace) + dashWidth) / distance;
      
      if (endT > 1.0) break;
      
      final dashStart = Offset.lerp(start, end, startT)!;
      final dashEnd = Offset.lerp(start, end, endT)!;
      
      canvas.drawLine(dashStart, dashEnd, paint);
    }
  }

  void _drawArrowhead(Canvas canvas, Offset from, Offset to, Paint paint) {
    const arrowSize = 8.0;
    final direction = (to - from);
    if (direction.distance == 0) return;
    
    final normalizedDirection = direction / direction.distance;
    final perpendicular = Offset(-normalizedDirection.dy, normalizedDirection.dx);
    
    final arrowTip = to;
    final arrowBase = to - normalizedDirection * arrowSize;
    final arrowLeft = arrowBase + perpendicular * arrowSize / 2;
    final arrowRight = arrowBase - perpendicular * arrowSize / 2;
    
    final arrowPath = Path()
      ..moveTo(arrowTip.dx, arrowTip.dy)
      ..lineTo(arrowLeft.dx, arrowLeft.dy)
      ..lineTo(arrowRight.dx, arrowRight.dy)
      ..close();
    
    canvas.drawPath(arrowPath, paint..style = PaintingStyle.fill);
    paint.style = PaintingStyle.stroke; // Reset to stroke for next operations
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is! WithdrawalLoopPathPainter || 
           oldDelegate.pathPoints != pathPoints ||
           oldDelegate.isSelected != isSelected;
  }
}

class WithdrawalKanbanIconPainter extends CustomPainter {
  final Color color;

  WithdrawalKanbanIconPainter({required this.color});

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
    // Start from top-left corner
    path.moveTo(left, top);
    // Go to top-right minus the cut (straight line)
    path.lineTo(right - cutSize, top);
    // Diagonal cut to create the folded corner (straight line)
    path.lineTo(right, top + cutSize);
    // Go down to bottom-right corner (straight line)
    path.lineTo(right, bottom);
    // Go left to bottom-left corner (straight line)
    path.lineTo(left, bottom);
    // Close back to top-left corner (straight line)
    path.lineTo(left, top);
    path.close();

    // Draw only the black outline (no fill)
    final strokePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    
    canvas.drawPath(path, strokePaint);
    
    // Draw the fold lines to show the cut corner (straight lines only)
    final foldPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    
    // Draw the vertical fold line
    canvas.drawLine(
      Offset(right - cutSize, top),
      Offset(right - cutSize, top + cutSize),
      foldPaint,
    );
    
    // Draw the horizontal fold line
    canvas.drawLine(
      Offset(right - cutSize, top + cutSize),
      Offset(right, top + cutSize),
      foldPaint,
    );

    // Draw diagonal lines pattern to distinguish from regular kanban loop
    final diagonalPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    // Create a clipping path to ensure lines only appear within the card shape
    canvas.save();
    canvas.clipPath(path);
    
    // Draw parallel diagonal stripes from top-left to bottom-right
    const stripeSpacing = 3.0;
    final cardWidth = right - left;
    final cardHeight = bottom - top;
    
    // Calculate starting position to ensure full coverage
    final startOffset = -cardHeight; // Start above the card
    final endOffset = cardWidth + stripeSpacing; // End beyond the card width
    
    // Draw diagonal lines with consistent spacing
    for (double x = startOffset; x <= endOffset; x += stripeSpacing) {
      // Each line goes from top edge to bottom edge at a 45-degree angle
      final lineStartX = left + x;
      final lineStartY = top;
      final lineEndX = left + x + cardHeight; // 45-degree angle
      final lineEndY = bottom;
      
      canvas.drawLine(
        Offset(lineStartX, lineStartY),
        Offset(lineEndX, lineEndY),
        diagonalPaint,
      );
    }
    
    canvas.restore(); // Restore the canvas state (removes clipping)
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is! WithdrawalKanbanIconPainter || oldDelegate.color != color;
  }
}
