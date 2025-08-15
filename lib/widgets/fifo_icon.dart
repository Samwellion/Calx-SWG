import 'package:flutter/material.dart';

/// Custom painter for the FIFO icon to match VSM standards
class FifoIconPainter extends CustomPainter {
  final Color color;
  final double size;

  FifoIconPainter({
    required this.color,
    this.size = 24.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Draw the main FIFO rectangle (similar to the image)
    final rect = Rect.fromLTWH(
      size.width * 0.1,
      size.height * 0.2,
      size.width * 0.8,
      size.height * 0.6,
    );

    // Fill the rectangle with white background
    canvas.drawRect(rect, fillPaint);
    
    // Draw the black border
    canvas.drawRect(rect, paint);

    // Draw "FIFO" text in black
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'FIFO',
        style: TextStyle(
          color: Colors.black,
          fontSize: 8,
          fontWeight: FontWeight.bold,
          fontFamily: 'Arial',
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    
    final textOffset = Offset(
      rect.left + (rect.width - textPainter.width) / 2,
      rect.top + (rect.height - textPainter.height) / 2,
    );

    textPainter.paint(canvas, textOffset);

    // Draw horizontal line below FIFO text (like in the image)
    final lineY = rect.bottom - rect.height * 0.25;
    canvas.drawLine(
      Offset(rect.left + rect.width * 0.1, lineY),
      Offset(rect.right - rect.width * 0.1, lineY),
      paint,
    );

    // Draw input arrow (left side)
    final arrowPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final inputY = rect.center.dy;
    final inputStart = Offset(0, inputY);
    final inputEnd = Offset(rect.left, inputY);

    // Input arrow line
    canvas.drawLine(inputStart, inputEnd, arrowPaint);
    
    // Input arrow head
    final arrowSize = 2.5;
    final inputArrowHead = Path();
    inputArrowHead.moveTo(inputEnd.dx - arrowSize, inputEnd.dy - arrowSize);
    inputArrowHead.lineTo(inputEnd.dx, inputEnd.dy);
    inputArrowHead.lineTo(inputEnd.dx - arrowSize, inputEnd.dy + arrowSize);
    canvas.drawPath(inputArrowHead, arrowPaint);

    // Draw output arrow (right side)
    final outputY = rect.center.dy;
    final outputStart = Offset(rect.right, outputY);
    final outputEnd = Offset(size.width, outputY);

    // Output arrow line
    canvas.drawLine(outputStart, outputEnd, arrowPaint);
    
    // Output arrow head
    final outputArrowHead = Path();
    outputArrowHead.moveTo(outputEnd.dx - arrowSize, outputEnd.dy - arrowSize);
    outputArrowHead.lineTo(outputEnd.dx, outputEnd.dy);
    outputArrowHead.lineTo(outputEnd.dx - arrowSize, outputEnd.dy + arrowSize);
    canvas.drawPath(outputArrowHead, arrowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is! FifoIconPainter ||
        oldDelegate.color != color ||
        oldDelegate.size != size;
  }
}

/// Custom FIFO icon widget
class FifoIcon extends StatelessWidget {
  final Color color;
  final double size;

  const FifoIcon({
    super.key,
    this.color = Colors.cyan,
    this.size = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: FifoIconPainter(
        color: color,
        size: size,
      ),
    );
  }
}
