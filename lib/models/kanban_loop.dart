import 'package:flutter/material.dart';
import 'connection_handle.dart';

class KanbanLoop {
  final String id;
  final String supermarketId; // ID of the supermarket material connector
  final String supplierProcessId; // ID of the supplier process
  final Offset supermarketHandlePosition; // Position of the supermarket top center handle
  final Offset supplierHandlePosition; // Position of the supplier process handle
  final List<Offset> pathPoints; // Points defining the 90-degree path
  final Offset kanbanIconPosition; // Position of the 5-sided kanban icon (center of path)
  final double? hoursValue; // Hours value in HH format
  final HandlePosition? supermarketHandlePositionSide; // Which side of supermarket the handle is on
  final HandlePosition? supplierHandlePositionSide; // Which side of supplier the handle is on
  
  const KanbanLoop({
    required this.id,
    required this.supermarketId,
    required this.supplierProcessId,
    required this.supermarketHandlePosition,
    required this.supplierHandlePosition,
    required this.pathPoints,
    required this.kanbanIconPosition,
    this.hoursValue,
    this.supermarketHandlePositionSide,
    this.supplierHandlePositionSide,
  });

  /// Calculate the 90-degree path from supermarket handle through kanban icon to supplier handle
  /// Ensures proper arrow direction by making both start and end approaches perpendicular to handle sides
  static List<Offset> calculatePath(Offset start, Offset end, Offset kanbanPosition, [ConnectionHandle? endHandle, ConnectionHandle? startHandle]) {
    // Create a path with 90-degree angles that goes through the kanban icon position
    final kanbanX = kanbanPosition.dx;
    final kanbanY = kanbanPosition.dy;
    const double minPerpendicularDistance = 15.0;
    
    // If we have both handle information, create optimal path and place kanban icon along it
    if (endHandle != null && startHandle != null) {
      final pathPoints = _createControlledPath(start, end, kanbanPosition, startHandle, endHandle, minPerpendicularDistance);
      return pathPoints;
    }
    
    // If we have only end handle information, use it to determine the correct approach direction
    if (endHandle != null) {
      switch (endHandle.position) {
        case HandlePosition.top:
          // Handle is on top side - approach from above, but initially aim 10 pixels below target
          final approachY = end.dy + 10; // Aim 10 pixels below the target handle
          return [
            start,                        // Start at supermarket handle
            Offset(start.dx, kanbanY),    // Go vertically to kanban Y level
            Offset(kanbanX, kanbanY),     // Go horizontally to kanban icon
            Offset(end.dx, approachY),    // Go to position 10 pixels below target
            end,                          // Go up to target handle
          ];
          
        case HandlePosition.bottom:
          // Handle is on bottom side - approach from below, but initially aim 10 pixels below target
          final approachY = end.dy + 10; // Aim 10 pixels below the target handle
          return [
            start,                        // Start at supermarket handle
            Offset(start.dx, kanbanY),    // Go vertically to kanban Y level
            Offset(kanbanX, kanbanY),     // Go horizontally to kanban icon
            Offset(end.dx, approachY),    // Go to position 10 pixels below target
            end,                          // Go up to target handle
          ];
          
        case HandlePosition.left:
          // Handle is on left side - approach from the left, but initially aim 10 pixels below target
          final approachX = end.dx - minPerpendicularDistance;
          final approachY = end.dy + 10; // Aim 10 pixels below the target handle
          return [
            start,                        // Start at supermarket handle
            Offset(start.dx, kanbanY),    // Go vertically to kanban Y level
            Offset(kanbanX, kanbanY),     // Go horizontally to kanban icon
            Offset(approachX, kanbanY),   // Go to approach position left of target
            Offset(approachX, approachY), // Go to position 10 pixels below target
            end,                          // Go to target handle
          ];
          
        case HandlePosition.right:
          // Handle is on right side - approach from the right, but initially aim 10 pixels below target
          final approachX = end.dx + minPerpendicularDistance;
          final approachY = end.dy + 10; // Aim 10 pixels below the target handle
          return [
            start,                        // Start at supermarket handle
            Offset(start.dx, kanbanY),    // Go vertically to kanban Y level
            Offset(kanbanX, kanbanY),     // Go horizontally to kanban icon
            Offset(approachX, kanbanY),   // Go to approach position right of target
            Offset(approachX, approachY), // Go to position 10 pixels below target
            end,                          // Go to target handle
          ];
      }
    }
    
    // Fallback: If no handle info, use intelligent routing based on distance
    final kanbanToEndX = (end.dx - kanbanX).abs();
    final kanbanToEndY = (end.dy - kanbanY).abs();
    
    if (kanbanToEndY > kanbanToEndX) {
      // End point is primarily vertical from kanban icon - route vertically
      final intermediateY = kanbanToEndY >= minPerpendicularDistance ? end.dy : 
          (end.dy > kanbanY ? kanbanY + minPerpendicularDistance : kanbanY - minPerpendicularDistance);
      
      return [
        start,                          // Start at supermarket handle
        Offset(start.dx, kanbanY),      // Go vertically to kanban Y level
        Offset(kanbanX, kanbanY),       // Go horizontally to kanban icon
        Offset(kanbanX, intermediateY), // Go vertically with minimum distance
        end,                            // Go horizontally to end handle
      ];
    } else {
      // End point is primarily horizontal from kanban icon - route horizontally
      final intermediateX = kanbanToEndX >= minPerpendicularDistance ? end.dx :
          (end.dx > kanbanX ? kanbanX + minPerpendicularDistance : kanbanX - minPerpendicularDistance);
      
      return [
        start,                          // Start at supermarket handle
        Offset(start.dx, kanbanY),      // Go vertically to kanban Y level
        Offset(kanbanX, kanbanY),       // Go horizontally to kanban icon
        Offset(intermediateX, kanbanY), // Go horizontally with minimum distance
        end,                            // Go vertically to end handle
      ];
    }
  }

  /// Create a fully controlled path with perpendicular approaches from both handles
  /// Routes through the specified kanban icon position with 90-degree angles
  static List<Offset> _createControlledPath(Offset start, Offset end, Offset kanbanPosition, 
      ConnectionHandle startHandle, ConnectionHandle endHandle, double minDistance) {
    
    final kanbanX = kanbanPosition.dx;
    final kanbanY = kanbanPosition.dy;
    
    // Calculate departure point from start handle (perpendicular to start handle side)
    late Offset departurePoint;
    switch (startHandle.position) {
      case HandlePosition.top:
        departurePoint = Offset(start.dx, start.dy - minDistance);
        break;
      case HandlePosition.bottom:
        departurePoint = Offset(start.dx, start.dy + minDistance);
        break;
      case HandlePosition.left:
        departurePoint = Offset(start.dx - minDistance, start.dy);
        break;
      case HandlePosition.right:
        departurePoint = Offset(start.dx + minDistance, start.dy);
        break;
    }
    
    // Calculate approach point to end handle (perpendicular to end handle side)
    late Offset approachPoint;
    switch (endHandle.position) {
      case HandlePosition.top:
        approachPoint = Offset(end.dx, end.dy - minDistance);
        break;
      case HandlePosition.bottom:
        approachPoint = Offset(end.dx, end.dy + minDistance);
        break;
      case HandlePosition.left:
        approachPoint = Offset(end.dx - minDistance, end.dy);
        break;
      case HandlePosition.right:
        approachPoint = Offset(end.dx + minDistance, end.dy);
        break;
    }
    
    // Create path that routes through the kanban icon with 90-degree angles
    List<Offset> pathPoints = [start, departurePoint];
    
    // Route from departure point to kanban icon
    if (departurePoint.dx != kanbanX) {
      pathPoints.add(Offset(kanbanX, departurePoint.dy));
    }
    if (departurePoint.dy != kanbanY) {
      pathPoints.add(Offset(kanbanX, kanbanY));
    }
    
    // Ensure we're at the kanban icon
    if (pathPoints.last != Offset(kanbanX, kanbanY)) {
      pathPoints.add(Offset(kanbanX, kanbanY));
    }
    
    // Route from kanban icon to approach point
    if (kanbanX != approachPoint.dx) {
      pathPoints.add(Offset(approachPoint.dx, kanbanY));
    }
    if (kanbanY != approachPoint.dy) {
      pathPoints.add(Offset(approachPoint.dx, approachPoint.dy));
    }
    
    // Ensure we're at the approach point
    if (pathPoints.last != approachPoint) {
      pathPoints.add(approachPoint);
    }
    
    // Final segment to end handle
    pathPoints.add(end);
    
    return pathPoints;
  }
  
  /// Calculate optimal kanban icon position at the middle of the efficient path
  static Offset _calculateOptimalKanbanPosition(Offset start, Offset end, 
      ConnectionHandle startHandle, ConnectionHandle endHandle, double minDistance) {
    
    // Calculate departure and approach points
    late Offset departurePoint;
    switch (startHandle.position) {
      case HandlePosition.top:
        departurePoint = Offset(start.dx, start.dy - minDistance);
        break;
      case HandlePosition.bottom:
        departurePoint = Offset(start.dx, start.dy + minDistance);
        break;
      case HandlePosition.left:
        departurePoint = Offset(start.dx - minDistance, start.dy);
        break;
      case HandlePosition.right:
        departurePoint = Offset(start.dx + minDistance, start.dy);
        break;
    }
    
    late Offset approachPoint;
    switch (endHandle.position) {
      case HandlePosition.top:
        approachPoint = Offset(end.dx, end.dy - minDistance);
        break;
      case HandlePosition.bottom:
        approachPoint = Offset(end.dx, end.dy + minDistance);
        break;
      case HandlePosition.left:
        approachPoint = Offset(end.dx - minDistance, end.dy);
        break;
      case HandlePosition.right:
        approachPoint = Offset(end.dx + minDistance, end.dy);
        break;
    }
    
    // Create the efficient L-shaped path
    final needsHorizontalFirst = (departurePoint.dx - approachPoint.dx).abs() > 
                                (departurePoint.dy - approachPoint.dy).abs();
    
    late Offset cornerPoint;
    if (needsHorizontalFirst) {
      // Corner is at (approachPoint.dx, departurePoint.dy)
      cornerPoint = Offset(approachPoint.dx, departurePoint.dy);
    } else {
      // Corner is at (departurePoint.dx, approachPoint.dy)
      cornerPoint = Offset(departurePoint.dx, approachPoint.dy);
    }
    
    // Calculate the total path length to find the midpoint
    final segment1Length = (cornerPoint - departurePoint).distance;
    final segment2Length = (approachPoint - cornerPoint).distance;
    final totalLength = segment1Length + segment2Length;
    final midLength = totalLength / 2;
    
    // Place kanban icon at the midpoint of the path
    if (midLength <= segment1Length) {
      // Midpoint is on the first segment (departure -> corner)
      final ratio = midLength / segment1Length;
      return Offset(
        departurePoint.dx + (cornerPoint.dx - departurePoint.dx) * ratio,
        departurePoint.dy + (cornerPoint.dy - departurePoint.dy) * ratio,
      );
    } else {
      // Midpoint is on the second segment (corner -> approach)
      final remainingLength = midLength - segment1Length;
      final ratio = remainingLength / segment2Length;
      return Offset(
        cornerPoint.dx + (approachPoint.dx - cornerPoint.dx) * ratio,
        cornerPoint.dy + (approachPoint.dy - cornerPoint.dy) * ratio,
      );
    }
  }

  /// Calculate initial kanban icon position (midpoint between start and end)
  static Offset calculateInitialKanbanPosition(Offset start, Offset end) {
    return Offset(
      (start.dx + end.dx) / 2,
      (start.dy + end.dy) / 2,
    );
  }

  /// Calculate the center position along the path for placing the kanban icon
  static Offset calculateKanbanIconPosition(List<Offset> pathPoints) {
    if (pathPoints.length < 2) return Offset.zero;
    
    // Calculate total path length
    double totalLength = 0;
    for (int i = 0; i < pathPoints.length - 1; i++) {
      final segment = pathPoints[i + 1] - pathPoints[i];
      totalLength += segment.distance;
    }
    
    // Find the midpoint along the path
    final targetLength = totalLength / 2;
    double currentLength = 0;
    
    for (int i = 0; i < pathPoints.length - 1; i++) {
      final start = pathPoints[i];
      final end = pathPoints[i + 1];
      final segmentLength = (end - start).distance;
      
      if (currentLength + segmentLength >= targetLength) {
        // The midpoint is within this segment
        final remaining = targetLength - currentLength;
        final ratio = remaining / segmentLength;
        return Offset.lerp(start, end, ratio)!;
      }
      
      currentLength += segmentLength;
    }
    
    // Fallback to geometric center if calculation fails
    return pathPoints.isNotEmpty ? pathPoints[pathPoints.length ~/ 2] : Offset.zero;
  }

  /// Create a new KanbanLoop from supermarket and supplier handle positions
  factory KanbanLoop.createWithHandle({
    required String supermarketId,
    required String supplierProcessId,
    required Offset supermarketPosition,
    required Size supermarketSize,
    required Offset supplierHandlePosition, // Specific handle position
  }) {
    // Calculate the top center handle position of the supermarket
    final supermarketHandle = Offset(
      supermarketPosition.dx + supermarketSize.width / 2,
      supermarketPosition.dy,
    );
    
    // Calculate initial kanban icon position
    final kanbanIconPosition = calculateInitialKanbanPosition(supermarketHandle, supplierHandlePosition);
    
    // Calculate the path points through the kanban icon with enhanced perpendicular requirements
    final pathPoints = calculatePath(supermarketHandle, supplierHandlePosition, kanbanIconPosition);
    
    return KanbanLoop(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      supermarketId: supermarketId,
      supplierProcessId: supplierProcessId,
      supermarketHandlePosition: supermarketHandle,
      supplierHandlePosition: supplierHandlePosition,
      pathPoints: pathPoints,
      kanbanIconPosition: kanbanIconPosition,
      hoursValue: null, // Initialize with null
    );
  }

  /// Create a new KanbanLoop from specific supermarket and supplier handle positions
  factory KanbanLoop.createWithHandles({
    required String supermarketId,
    required String supplierProcessId,
    required Offset supermarketHandlePosition, // Specific supermarket handle position
    required Offset supplierHandlePosition, // Specific supplier handle position
    ConnectionHandle? supplierHandle, // Optional supplier handle for proper approach direction
    ConnectionHandle? supermarketHandle, // Optional supermarket handle for proper departure direction
  }) {
    // If we have both handles, calculate optimal kanban position along the efficient path
    Offset kanbanIconPosition;
    List<Offset> pathPoints;
    
    if (supplierHandle != null && supermarketHandle != null) {
      // Calculate optimal kanban position along the most efficient path
      kanbanIconPosition = _calculateOptimalKanbanPosition(
        supermarketHandlePosition, 
        supplierHandlePosition, 
        supermarketHandle, 
        supplierHandle, 
        15.0
      );
      
      // Calculate path using the optimal kanban position
      pathPoints = calculatePath(supermarketHandlePosition, supplierHandlePosition, kanbanIconPosition, supplierHandle, supermarketHandle);
    } else {
      // Fallback to original logic
      kanbanIconPosition = calculateInitialKanbanPosition(supermarketHandlePosition, supplierHandlePosition);
      pathPoints = calculatePath(supermarketHandlePosition, supplierHandlePosition, kanbanIconPosition, supplierHandle, supermarketHandle);
    }
    
    return KanbanLoop(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      supermarketId: supermarketId,
      supplierProcessId: supplierProcessId,
      supermarketHandlePosition: supermarketHandlePosition,
      supplierHandlePosition: supplierHandlePosition,
      pathPoints: pathPoints,
      kanbanIconPosition: kanbanIconPosition,
      hoursValue: null, // Initialize with null
      supermarketHandlePositionSide: supermarketHandle?.position,
      supplierHandlePositionSide: supplierHandle?.position,
    );
  }

  /// Update the kanban loop when the kanban icon is moved
  KanbanLoop updateKanbanPosition(Offset newKanbanPosition) {
    // Create mock ConnectionHandle objects from stored handle position data
    ConnectionHandle? endHandle;
    ConnectionHandle? startHandle;
    
    if (supplierHandlePositionSide != null) {
      endHandle = ConnectionHandle(
        itemId: supplierProcessId,
        itemType: 'process', // Default type for processes
        position: supplierHandlePositionSide!,
        alignment: HandleAlignment.center, // Default alignment
        offset: Offset.zero, // Not needed for path calculation
      );
    }
    
    if (supermarketHandlePositionSide != null) {
      startHandle = ConnectionHandle(
        itemId: supermarketId,
        itemType: 'supermarket', // Default type for supermarkets
        position: supermarketHandlePositionSide!,
        alignment: HandleAlignment.center, // Default alignment
        offset: Offset.zero, // Not needed for path calculation
      );
    }

    // Always respect the user's positioned kanban icon - don't force optimal positioning during updates
    final newPathPoints = calculatePath(
      supermarketHandlePosition, 
      supplierHandlePosition, 
      newKanbanPosition,
      endHandle,
      startHandle,
    );
    
    return copyWith(
      pathPoints: newPathPoints,
      kanbanIconPosition: newKanbanPosition,
    );
  }

  KanbanLoop copyWith({
    String? id,
    String? supermarketId,
    String? supplierProcessId,
    Offset? supermarketHandlePosition,
    Offset? supplierHandlePosition,
    List<Offset>? pathPoints,
    Offset? kanbanIconPosition,
    double? hoursValue,
    HandlePosition? supermarketHandlePositionSide,
    HandlePosition? supplierHandlePositionSide,
  }) {
    return KanbanLoop(
      id: id ?? this.id,
      supermarketId: supermarketId ?? this.supermarketId,
      supplierProcessId: supplierProcessId ?? this.supplierProcessId,
      supermarketHandlePosition: supermarketHandlePosition ?? this.supermarketHandlePosition,
      supplierHandlePosition: supplierHandlePosition ?? this.supplierHandlePosition,
      pathPoints: pathPoints ?? this.pathPoints,
      kanbanIconPosition: kanbanIconPosition ?? this.kanbanIconPosition,
      hoursValue: hoursValue ?? this.hoursValue,
      supermarketHandlePositionSide: supermarketHandlePositionSide ?? this.supermarketHandlePositionSide,
      supplierHandlePositionSide: supplierHandlePositionSide ?? this.supplierHandlePositionSide,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'supermarketId': supermarketId,
      'supplierProcessId': supplierProcessId,
      'supermarketHandlePosition': {
        'dx': supermarketHandlePosition.dx,
        'dy': supermarketHandlePosition.dy,
      },
      'supplierHandlePosition': {
        'dx': supplierHandlePosition.dx,
        'dy': supplierHandlePosition.dy,
      },
      'pathPoints': pathPoints.map((point) => {
        'dx': point.dx,
        'dy': point.dy,
      }).toList(),
      'kanbanIconPosition': {
        'dx': kanbanIconPosition.dx,
        'dy': kanbanIconPosition.dy,
      },
      'hoursValue': hoursValue,
    };
  }

  /// Create from JSON
  factory KanbanLoop.fromJson(Map<String, dynamic> json) {
    return KanbanLoop(
      id: json['id'],
      supermarketId: json['supermarketId'],
      supplierProcessId: json['supplierProcessId'],
      supermarketHandlePosition: Offset(
        json['supermarketHandlePosition']['dx'].toDouble(),
        json['supermarketHandlePosition']['dy'].toDouble(),
      ),
      supplierHandlePosition: Offset(
        json['supplierHandlePosition']['dx'].toDouble(),
        json['supplierHandlePosition']['dy'].toDouble(),
      ),
      pathPoints: (json['pathPoints'] as List).map((point) => Offset(
        point['dx'].toDouble(),
        point['dy'].toDouble(),
      )).toList(),
      kanbanIconPosition: Offset(
        json['kanbanIconPosition']['dx'].toDouble(),
        json['kanbanIconPosition']['dy'].toDouble(),
      ),
      hoursValue: json['hoursValue']?.toDouble(),
    );
  }
}
