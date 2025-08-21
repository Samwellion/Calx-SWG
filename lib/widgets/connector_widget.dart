import 'package:flutter/material.dart';
import '../models/canvas_connector.dart';
import '../models/process_object.dart';
import '../models/canvas_icon.dart';
import '../models/material_connector.dart';
import 'dart:math' as math;

class ConnectorWidget extends StatelessWidget {
  final CanvasConnector connector;
  final List<ProcessObject> processes;
  final List<CanvasIcon> canvasIcons;
  final List<MaterialConnector> materialConnectors;
  final Map<String, Offset> customerDataBoxPositions;
  final Map<String, Offset> supplierDataBoxPositions;
  final Map<String, Offset> productionControlDataBoxPositions;
  final Map<String, Offset> truckDataBoxPositions;
  final Function(String)? onTap;
  final bool isSelected;

  const ConnectorWidget({
    super.key,
    required this.connector,
    required this.processes,
    required this.canvasIcons,
    required this.materialConnectors,
    required this.customerDataBoxPositions,
    required this.supplierDataBoxPositions,
    required this.productionControlDataBoxPositions,
    required this.truckDataBoxPositions,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final startPos = _getItemPosition(connector.startPoint);
    final endPos = _getItemPosition(connector.endPoint);

    if (startPos == null || endPos == null) {
      return const SizedBox(); // Hide connector if items not found
    }

    // Calculate the bounds of the connector line for better tap detection
    final startPoint = _getConnectorEndpoint(connector.startPoint, startPos);
    final endPoint = _getConnectorEndpoint(connector.endPoint, endPos);
    
    final left = math.min(startPoint.dx, endPoint.dx) - 10;
    final top = math.min(startPoint.dy, endPoint.dy) - 10;
    final width = (startPoint.dx - endPoint.dx).abs() + 20;
    final height = (startPoint.dy - endPoint.dy).abs() + 20;

    return Positioned(
      left: left,
      top: top,
      width: width,
      height: height,
      child: GestureDetector(
        onTap: () => onTap?.call(connector.id),
        child: CustomPaint(
          painter: ArrowPainter(
            startPoint: Offset(startPoint.dx - left, startPoint.dy - top),
            endPoint: Offset(endPoint.dx - left, endPoint.dy - top),
            color: isSelected ? Colors.blue : connector.color,
            strokeWidth: isSelected ? connector.strokeWidth + 1 : connector.strokeWidth,
            label: connector.label,
            connectorType: connector.type,
          ),
          child: Container(
            width: width,
            height: height,
            color: Colors.transparent,
          ),
        ),
      ),
    );
  }

  /// Get the actual connection point for an endpoint, supporting both handles and legacy connection points
  Offset _getConnectorEndpoint(ConnectorEndpoint endpoint, Offset itemPosition) {
    // If we have a handle, convert relative position to absolute position
    if (endpoint.handle != null) {
      // Different items use different coordinate systems:
      // - MaterialConnector: itemPosition is center point, but handles are calculated from top-left
      // - ProcessObject: itemPosition is top-left point
      // - DataBoxes: itemPosition is top-left point
      
      if (endpoint.itemType == 'materialConnector') {
        // For material connectors, convert center position to top-left, then add handle offset
        final materialConnector = materialConnectors.firstWhere(
          (mc) => mc.id == endpoint.itemId,
          orElse: () => MaterialConnector(
            id: '',
            type: CanvasIconType.fifo,
            supplierProcessId: '',
            customerProcessId: '',
            label: '',
            position: Offset.zero,
            size: const Size(85, 130),
          ),
        );
        
        final topLeftPosition = Offset(
          itemPosition.dx - materialConnector.size.width / 2,
          itemPosition.dy - materialConnector.size.height / 2,
        );
        
        return topLeftPosition + endpoint.handle!.offset;
      } else {
        // For processes and data boxes, itemPosition is already top-left
        return itemPosition + endpoint.handle!.offset;
      }
    }
    
    // Fall back to legacy connection point if available
    if (endpoint.connectionPoint != null) {
      return itemPosition + endpoint.connectionPoint!;
    }
    
    // Default to center of item if no specific connection point
    return itemPosition + const Offset(50, 25); // Approximate center for most items
  }

  /// Get the position of an item by its ID and type
  Offset? _getItemPosition(ConnectorEndpoint endpoint) {
    switch (endpoint.itemType) {
      case 'process':
        final process = processes.firstWhere(
          (p) => p.id.toString() == endpoint.itemId,
          orElse: () => ProcessObject(
            id: 0,
            name: '',
            description: '',
            color: Colors.grey,
            position: Offset.zero,
            valueStreamId: 0,
            size: Size.zero,
          ),
        );
        return process.id != 0 ? process.position : null;

      case 'icon':
        final icon = canvasIcons.firstWhere(
          (i) => i.id == endpoint.itemId,
          orElse: () => CanvasIcon(
            id: '',
            type: CanvasIconType.informationArrow,
            label: '',
            iconData: Icons.error,
            position: Offset.zero,
          ),
        );
        return icon.id.isNotEmpty ? icon.position : null;

      case 'materialConnector':
        final materialConnector = materialConnectors.firstWhere(
          (mc) => mc.id == endpoint.itemId,
          orElse: () => MaterialConnector(
            id: '',
            type: CanvasIconType.fifo,
            supplierProcessId: '',
            customerProcessId: '',
            label: '',
            position: Offset.zero,
          ),
        );
        return materialConnector.id.isNotEmpty ? materialConnector.position : null;

      case 'customer':
        return customerDataBoxPositions[endpoint.itemId];

      case 'supplier':
        return supplierDataBoxPositions[endpoint.itemId];

      case 'productionControl':
        return productionControlDataBoxPositions[endpoint.itemId];

      case 'truck':
        return truckDataBoxPositions[endpoint.itemId];

      default:
        return null;
    }
  }
}

class ArrowPainter extends CustomPainter {
  final Offset startPoint;
  final Offset endPoint;
  final Color color;
  final double strokeWidth;
  final String label;
  final ConnectorType connectorType;

  ArrowPainter({
    required this.startPoint,
    required this.endPoint,
    required this.color,
    required this.strokeWidth,
    required this.label,
    required this.connectorType,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    // Draw line based on connector type
    switch (connectorType) {
      case ConnectorType.electronic:
        _drawElectronicArrow(canvas, paint);
        break;
      case ConnectorType.information:
        _drawInformationArrow(canvas, paint);
        break;
      case ConnectorType.material:
        _drawMaterialArrow(canvas, paint);
        break;
      case ConnectorType.materialPush:
        _drawMaterialPushArrow(canvas, paint);
        break;
      case ConnectorType.kanbanLoop:
        _drawKanbanLoopArrow(canvas, paint);
        break;
      case ConnectorType.withdrawalLoop:
        _drawWithdrawalLoopArrow(canvas, paint);
        break;
    }

    // Draw label if provided
    if (label.isNotEmpty) {
      _drawLabel(canvas);
    }
  }

  void _drawInformationArrow(Canvas canvas, Paint paint) {
    // Draw solid line for information flow with anti-aliasing
    paint.style = PaintingStyle.stroke;
    canvas.drawLine(startPoint, endPoint, paint);

    // Draw standard arrowhead
    _drawArrowHead(canvas, paint);
  }

  void _drawElectronicArrow(Canvas canvas, Paint paint) {
    // Draw electronic information arrow with zigzag pattern (every inch or so)
    _drawElectronicZigzagLine(canvas, paint);
    
    // Draw standard arrowhead
    _drawArrowHead(canvas, paint);
  }

  void _drawMaterialArrow(Canvas canvas, Paint paint) {
    // Material flow arrow: thick white body with black outline
    const materialArrowWidth = 6.0;
    const arrowHeadLength = 20.0;
    const arrowHeadWidth = 16.0;
    
    // Calculate the direction vector
    final dx = endPoint.dx - startPoint.dx;
    final dy = endPoint.dy - startPoint.dy;
    final distance = math.sqrt(dx * dx + dy * dy);
    
    if (distance == 0) return;
    
    // Unit vectors for direction and perpendicular
    final unitX = dx / distance;
    final unitY = dy / distance;
    final perpX = -unitY;
    final perpY = unitX;
    
    // Calculate shaft end point (before arrowhead)
    final shaftEndX = endPoint.dx - arrowHeadLength * unitX;
    final shaftEndY = endPoint.dy - arrowHeadLength * unitY;
    
    // Create shaft path (thick rectangle)
    final shaftPath = Path();
    final halfWidth = materialArrowWidth / 2;
    
    // Shaft corners
    final shaftStartTop = Offset(
      startPoint.dx + halfWidth * perpX,
      startPoint.dy + halfWidth * perpY,
    );
    final shaftStartBottom = Offset(
      startPoint.dx - halfWidth * perpX,
      startPoint.dy - halfWidth * perpY,
    );
    final shaftEndTop = Offset(
      shaftEndX + halfWidth * perpX,
      shaftEndY + halfWidth * perpY,
    );
    final shaftEndBottom = Offset(
      shaftEndX - halfWidth * perpX,
      shaftEndY - halfWidth * perpY,
    );
    
    shaftPath.moveTo(shaftStartTop.dx, shaftStartTop.dy);
    shaftPath.lineTo(shaftEndTop.dx, shaftEndTop.dy);
    shaftPath.lineTo(shaftEndBottom.dx, shaftEndBottom.dy);
    shaftPath.lineTo(shaftStartBottom.dx, shaftStartBottom.dy);
    shaftPath.close();
    
    // Create arrowhead path
    final arrowPath = Path();
    final arrowHeadHalfWidth = arrowHeadWidth / 2;
    
    // Arrowhead points
    final arrowTip = endPoint;
    final arrowBaseTop = Offset(
      shaftEndX + arrowHeadHalfWidth * perpX,
      shaftEndY + arrowHeadHalfWidth * perpY,
    );
    final arrowBaseBottom = Offset(
      shaftEndX - arrowHeadHalfWidth * perpX,
      shaftEndY - arrowHeadHalfWidth * perpY,
    );
    
    arrowPath.moveTo(arrowTip.dx, arrowTip.dy);
    arrowPath.lineTo(arrowBaseTop.dx, arrowBaseTop.dy);
    arrowPath.lineTo(arrowBaseBottom.dx, arrowBaseBottom.dy);
    arrowPath.close();
    
    // Draw white fill for shaft
    final fillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawPath(shaftPath, fillPaint);
    canvas.drawPath(arrowPath, fillPaint);
    
    // Draw black outline for shaft
    final outlinePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawPath(shaftPath, outlinePaint);
    canvas.drawPath(arrowPath, outlinePaint);
  }

  void _drawMaterialPushArrow(Canvas canvas, Paint paint) {
    // Material Push arrow: thick black line with white dashed segments inside
    const materialArrowWidth = 8.0;
    const arrowHeadLength = 20.0;
    const arrowHeadWidth = 16.0;
    const dashLength = 12.0;
    const dashGap = 8.0;
    
    // Calculate the direction vector
    final dx = endPoint.dx - startPoint.dx;
    final dy = endPoint.dy - startPoint.dy;
    final distance = math.sqrt(dx * dx + dy * dy);
    
    if (distance == 0) return;
    
    // Unit vectors for direction and perpendicular
    final unitX = dx / distance;
    final unitY = dy / distance;
    final perpX = -unitY;
    final perpY = unitX;
    
    // Calculate shaft end point (before arrowhead)
    final shaftEndX = endPoint.dx - arrowHeadLength * unitX;
    final shaftEndY = endPoint.dy - arrowHeadLength * unitY;
    
    // Create shaft path (thick rectangle)
    final shaftPath = Path();
    final halfWidth = materialArrowWidth / 2;
    
    // Shaft corners
    final shaftStartTop = Offset(
      startPoint.dx + halfWidth * perpX,
      startPoint.dy + halfWidth * perpY,
    );
    final shaftStartBottom = Offset(
      startPoint.dx - halfWidth * perpX,
      startPoint.dy - halfWidth * perpY,
    );
    final shaftEndTop = Offset(
      shaftEndX + halfWidth * perpX,
      shaftEndY + halfWidth * perpY,
    );
    final shaftEndBottom = Offset(
      shaftEndX - halfWidth * perpX,
      shaftEndY - halfWidth * perpY,
    );
    
    shaftPath.moveTo(shaftStartTop.dx, shaftStartTop.dy);
    shaftPath.lineTo(shaftEndTop.dx, shaftEndTop.dy);
    shaftPath.lineTo(shaftEndBottom.dx, shaftEndBottom.dy);
    shaftPath.lineTo(shaftStartBottom.dx, shaftStartBottom.dy);
    shaftPath.close();
    
    // Create arrowhead path
    final arrowPath = Path();
    final arrowHeadHalfWidth = arrowHeadWidth / 2;
    
    // Arrowhead points
    final arrowTip = endPoint;
    final arrowBaseTop = Offset(
      shaftEndX + arrowHeadHalfWidth * perpX,
      shaftEndY + arrowHeadHalfWidth * perpY,
    );
    final arrowBaseBottom = Offset(
      shaftEndX - arrowHeadHalfWidth * perpX,
      shaftEndY - arrowHeadHalfWidth * perpY,
    );
    
    arrowPath.moveTo(arrowTip.dx, arrowTip.dy);
    arrowPath.lineTo(arrowBaseTop.dx, arrowBaseTop.dy);
    arrowPath.lineTo(arrowBaseBottom.dx, arrowBaseBottom.dy);
    arrowPath.close();
    
    // Draw black outline for shaft and arrowhead
    final outlinePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    canvas.drawPath(shaftPath, outlinePaint);
    canvas.drawPath(arrowPath, outlinePaint);
    
    // Draw white dashed line inside the shaft
    final shaftDistance = math.sqrt(
      (shaftEndX - startPoint.dx) * (shaftEndX - startPoint.dx) +
      (shaftEndY - startPoint.dy) * (shaftEndY - startPoint.dy)
    );
    
    if (shaftDistance > 0) {
      final dashCount = (shaftDistance / (dashLength + dashGap)).floor();
      final whitePaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      
      for (int i = 0; i < dashCount; i++) {
        final startDistance = i * (dashLength + dashGap) + dashGap / 2;
        final endDistance = startDistance + dashLength;
        
        if (endDistance <= shaftDistance) {
          final dashStartX = startPoint.dx + startDistance * unitX;
          final dashStartY = startPoint.dy + startDistance * unitY;
          final dashEndX = startPoint.dx + endDistance * unitX;
          final dashEndY = startPoint.dy + endDistance * unitY;
          
          canvas.drawLine(
            Offset(dashStartX, dashStartY),
            Offset(dashEndX, dashEndY),
            whitePaint,
          );
        }
      }
    }
  }

  void _drawKanbanLoopArrow(Canvas canvas, Paint paint) {
    // TODO: Implement kanban loop connector
    // For now, draw a simple line with arrow
    canvas.drawLine(startPoint, endPoint, paint);
    _drawArrowHead(canvas, paint);
  }

  void _drawWithdrawalLoopArrow(Canvas canvas, Paint paint) {
    // TODO: Implement withdrawal loop connector
    // For now, draw a simple line with arrow
    canvas.drawLine(startPoint, endPoint, paint);
    _drawArrowHead(canvas, paint);
  }

  void _drawElectronicZigzagLine(Canvas canvas, Paint paint) {
    // TODO: Implement electronic information arrow with VSM-standard zigzag pattern
    // For now, draw a simple line
    canvas.drawLine(startPoint, endPoint, paint);
  }

  void _drawArrowHead(Canvas canvas, Paint paint) {
    const arrowLength = 15.0;
    const arrowAngle = 25 * math.pi / 180; // 25 degrees in radians

    final angle = math.atan2(endPoint.dy - startPoint.dy, endPoint.dx - startPoint.dx);

    // Arrow head points
    final arrowPoint1 = Offset(
      endPoint.dx - arrowLength * math.cos(angle - arrowAngle),
      endPoint.dy - arrowLength * math.sin(angle - arrowAngle),
    );

    final arrowPoint2 = Offset(
      endPoint.dx - arrowLength * math.cos(angle + arrowAngle),
      endPoint.dy - arrowLength * math.sin(angle + arrowAngle),
    );

    // Draw arrow head
    final arrowPath = Path()
      ..moveTo(endPoint.dx, endPoint.dy)
      ..lineTo(arrowPoint1.dx, arrowPoint1.dy)
      ..moveTo(endPoint.dx, endPoint.dy)
      ..lineTo(arrowPoint2.dx, arrowPoint2.dy);

    canvas.drawPath(arrowPath, paint);
  }

  void _drawLabel(Canvas canvas) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    // Position label at midpoint of the line
    final midPoint = Offset(
      (startPoint.dx + endPoint.dx) / 2,
      (startPoint.dy + endPoint.dy) / 2,
    );

    // Offset label slightly to avoid overlapping with line
    final labelOffset = Offset(
      midPoint.dx - textPainter.width / 2,
      midPoint.dy - textPainter.height / 2 - 10,
    );

    // Draw background for label
    final labelRect = Rect.fromLTWH(
      labelOffset.dx - 2,
      labelOffset.dy - 1,
      textPainter.width + 4,
      textPainter.height + 2,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(labelRect, const Radius.circular(4)),
      Paint()..color = Colors.white.withOpacity(0.8),
    );

    textPainter.paint(canvas, labelOffset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is! ArrowPainter ||
        oldDelegate.startPoint != startPoint ||
        oldDelegate.endPoint != endPoint ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.label != label;
  }
}
