import 'package:flutter/material.dart';

class SupermarketIcon extends StatelessWidget {
  final Color color;
  final double size;

  const SupermarketIcon({
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
        painter: SupermarketIconPainter(color: color),
      ),
    );
  }
}

class SupermarketIconPainter extends CustomPainter {
  final Color color;

  SupermarketIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final width = size.width;
    final height = size.height;
    
    // Draw three horizontal "C" shapes stacked vertically (like shelves)
    final cupHeight = height * 0.2;
    final cupWidth = width * 0.6;
    final startX = width * 0.2;
    final spacing = height * 0.05;
    
    // Top cup
    _drawSideCup(canvas, paint, startX, height * 0.15, cupWidth, cupHeight);
    
    // Middle cup
    _drawSideCup(canvas, paint, startX, height * 0.15 + cupHeight + spacing, cupWidth, cupHeight);
    
    // Bottom cup
    _drawSideCup(canvas, paint, startX, height * 0.15 + 2 * (cupHeight + spacing), cupWidth, cupHeight);
  }
  
  void _drawSideCup(Canvas canvas, Paint paint, double x, double y, double width, double height) {
    final path = Path();
    
    // Draw "C" shape (cup on its side, opening to the left)
    path.moveTo(x, y); // Top left
    path.lineTo(x + width, y); // Top right
    path.lineTo(x + width, y + height); // Bottom right
    path.lineTo(x, y + height); // Bottom left
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
