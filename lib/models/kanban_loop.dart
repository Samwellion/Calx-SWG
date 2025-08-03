import 'package:flutter/material.dart';

class KanbanLoop {
  final String id;
  final String supermarketId; // ID of the supermarket material connector
  final String supplierProcessId; // ID of the supplier process
  final Offset supermarketHandlePosition; // Position of the supermarket top center handle
  final Offset supplierHandlePosition; // Position of the supplier process handle
  final List<Offset> pathPoints; // Points defining the 90-degree path
  final Offset kanbanIconPosition; // Position of the 5-sided kanban icon (center of path)
  
  const KanbanLoop({
    required this.id,
    required this.supermarketId,
    required this.supplierProcessId,
    required this.supermarketHandlePosition,
    required this.supplierHandlePosition,
    required this.pathPoints,
    required this.kanbanIconPosition,
  });

  /// Calculate the 90-degree path from supermarket handle through kanban icon to supplier handle
  static List<Offset> calculatePath(Offset start, Offset end, Offset kanbanPosition) {
    // Create a path with 90-degree angles that goes through the kanban icon position
    final kanbanX = kanbanPosition.dx;
    final kanbanY = kanbanPosition.dy;
    
    return [
      start, // Start at supermarket handle (top center)
      Offset(start.dx, kanbanY), // Go vertically to kanban Y level
      Offset(kanbanX, kanbanY), // Go horizontally to kanban icon
      Offset(end.dx, kanbanY), // Go horizontally to supplier X level
      end, // Go vertically down to supplier handle
    ];
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
    
    // Calculate the path points through the kanban icon
    final pathPoints = calculatePath(supermarketHandle, supplierHandlePosition, kanbanIconPosition);
    
    return KanbanLoop(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      supermarketId: supermarketId,
      supplierProcessId: supplierProcessId,
      supermarketHandlePosition: supermarketHandle,
      supplierHandlePosition: supplierHandlePosition,
      pathPoints: pathPoints,
      kanbanIconPosition: kanbanIconPosition,
    );
  }

  /// Create a new KanbanLoop from specific supermarket and supplier handle positions
  factory KanbanLoop.createWithHandles({
    required String supermarketId,
    required String supplierProcessId,
    required Offset supermarketHandlePosition, // Specific supermarket handle position
    required Offset supplierHandlePosition, // Specific supplier handle position
  }) {
    // Calculate initial kanban icon position
    final kanbanIconPosition = calculateInitialKanbanPosition(supermarketHandlePosition, supplierHandlePosition);
    
    // Calculate the path points through the kanban icon
    final pathPoints = calculatePath(supermarketHandlePosition, supplierHandlePosition, kanbanIconPosition);
    
    return KanbanLoop(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      supermarketId: supermarketId,
      supplierProcessId: supplierProcessId,
      supermarketHandlePosition: supermarketHandlePosition,
      supplierHandlePosition: supplierHandlePosition,
      pathPoints: pathPoints,
      kanbanIconPosition: kanbanIconPosition,
    );
  }

  /// Update the kanban loop when the kanban icon is moved
  KanbanLoop updateKanbanPosition(Offset newKanbanPosition) {
    final newPathPoints = calculatePath(
      supermarketHandlePosition, 
      supplierHandlePosition, 
      newKanbanPosition
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
  }) {
    return KanbanLoop(
      id: id ?? this.id,
      supermarketId: supermarketId ?? this.supermarketId,
      supplierProcessId: supplierProcessId ?? this.supplierProcessId,
      supermarketHandlePosition: supermarketHandlePosition ?? this.supermarketHandlePosition,
      supplierHandlePosition: supplierHandlePosition ?? this.supplierHandlePosition,
      pathPoints: pathPoints ?? this.pathPoints,
      kanbanIconPosition: kanbanIconPosition ?? this.kanbanIconPosition,
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
    );
  }
}
