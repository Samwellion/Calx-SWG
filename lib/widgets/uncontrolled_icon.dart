import 'package:flutter/material.dart';

class UncontrolledIcon extends StatelessWidget {
  final Color color;
  final double size;

  const UncontrolledIcon({
    super.key,
    required this.color,
    this.size = 60.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: UncontrolledIconPainter(color: color),
      ),
    );
  }
}

class UncontrolledIconPainter extends CustomPainter {
  final Color color;

  UncontrolledIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final fillPaint = Paint()
      ..color = color.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final triangleSize = size.width * 0.7;

    // Calculate triangle points (equilateral triangle)
    final top = Offset(center.dx, center.dy - triangleSize / 2);
    final bottomLeft = Offset(
      center.dx - triangleSize * 0.433, // cos(30°) ≈ 0.866, sin(30°) = 0.5, so width = triangleSize * sin(60°) ≈ triangleSize * 0.866
      center.dy + triangleSize / 4,
    );
    final bottomRight = Offset(
      center.dx + triangleSize * 0.433,
      center.dy + triangleSize / 4,
    );

    // Create triangle path
    final trianglePath = Path()
      ..moveTo(top.dx, top.dy)
      ..lineTo(bottomLeft.dx, bottomLeft.dy)
      ..lineTo(bottomRight.dx, bottomRight.dy)
      ..close();

    // Draw filled triangle (background)
    canvas.drawPath(trianglePath, fillPaint);
    
    // Draw triangle border
    canvas.drawPath(trianglePath, paint);

    // Draw the "i" inside the triangle
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'i',
        style: TextStyle(
          color: color,
          fontSize: size.width * 0.4,
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.italic,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    
    // Position the "i" in the center of the triangle
    final textOffset = Offset(
      center.dx - textPainter.width / 2,
      center.dy - textPainter.height / 2 + triangleSize * 0.05, // Slight adjustment for visual centering
    );
    
    textPainter.paint(canvas, textOffset);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
