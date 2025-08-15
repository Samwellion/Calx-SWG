import 'package:flutter/material.dart';

class WithdrawalLoop {
  final String id;
  final String supermarketId; // ID of the supermarket material connector
  final String customerProcessId; // ID of the customer process
  final Offset customerHandlePosition; // Position of the customer process handle (start)
  final Offset supermarketHandlePosition; // Position of the supermarket handle (end)
  final List<Offset> pathPoints; // Points defining the 90-degree path
  final Offset kanbanIconPosition; // Position of the 5-sided kanban icon (center of path)
  final double? hoursValue; // Hours value in HH format
  
  const WithdrawalLoop({
    required this.id,
    required this.supermarketId,
    required this.customerProcessId,
    required this.customerHandlePosition,
    required this.supermarketHandlePosition,
    required this.pathPoints,
    required this.kanbanIconPosition,
    this.hoursValue,
  });

  /// Calculate the 90-degree path from customer handle through kanban icon to supermarket handle
  static List<Offset> calculatePath(Offset start, Offset end, Offset kanbanPosition) {
    // Create a path with 90-degree angles that goes through the kanban icon position
    final kanbanX = kanbanPosition.dx;
    final kanbanY = kanbanPosition.dy;
    
    return [
      start, // Start at customer handle
      Offset(start.dx, kanbanY), // Go vertically to kanban Y level
      Offset(kanbanX, kanbanY), // Go horizontally to kanban icon
      Offset(end.dx, kanbanY), // Go horizontally to supermarket X level
      end, // Go vertically to supermarket handle
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

  /// Create a new WithdrawalLoop from customer and supermarket handle positions
  factory WithdrawalLoop.createWithHandle({
    required String supermarketId,
    required String customerProcessId,
    required Offset customerHandlePosition, // Specific customer handle position
    required Offset supermarketPosition,
    required Size supermarketSize,
  }) {
    // Calculate the top center handle position of the supermarket
    final supermarketHandle = Offset(
      supermarketPosition.dx + supermarketSize.width / 2,
      supermarketPosition.dy,
    );
    
    // Calculate initial kanban icon position
    final kanbanIconPosition = calculateInitialKanbanPosition(customerHandlePosition, supermarketHandle);
    
    // Calculate the path points through the kanban icon
    final pathPoints = calculatePath(customerHandlePosition, supermarketHandle, kanbanIconPosition);
    
    return WithdrawalLoop(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      supermarketId: supermarketId,
      customerProcessId: customerProcessId,
      customerHandlePosition: customerHandlePosition,
      supermarketHandlePosition: supermarketHandle,
      pathPoints: pathPoints,
      kanbanIconPosition: kanbanIconPosition,
      hoursValue: null, // Initialize with null
    );
  }

  /// Create a new WithdrawalLoop from specific customer and supermarket handle positions
  factory WithdrawalLoop.createWithHandles({
    required String supermarketId,
    required String customerProcessId,
    required Offset customerHandlePosition, // Specific customer handle position
    required Offset supermarketHandlePosition, // Specific supermarket handle position
  }) {
    // Calculate initial kanban icon position
    final kanbanIconPosition = calculateInitialKanbanPosition(customerHandlePosition, supermarketHandlePosition);
    
    // Calculate the path points through the kanban icon
    final pathPoints = calculatePath(customerHandlePosition, supermarketHandlePosition, kanbanIconPosition);
    
    return WithdrawalLoop(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      supermarketId: supermarketId,
      customerProcessId: customerProcessId,
      customerHandlePosition: customerHandlePosition,
      supermarketHandlePosition: supermarketHandlePosition,
      pathPoints: pathPoints,
      kanbanIconPosition: kanbanIconPosition,
      hoursValue: null, // Initialize with null
    );
  }

  /// Update the withdrawal loop when the kanban icon is moved
  WithdrawalLoop updateKanbanPosition(Offset newKanbanPosition) {
    final newPathPoints = calculatePath(
      customerHandlePosition, 
      supermarketHandlePosition, 
      newKanbanPosition
    );
    
    return copyWith(
      pathPoints: newPathPoints,
      kanbanIconPosition: newKanbanPosition,
    );
  }

  WithdrawalLoop copyWith({
    String? id,
    String? supermarketId,
    String? customerProcessId,
    Offset? customerHandlePosition,
    Offset? supermarketHandlePosition,
    List<Offset>? pathPoints,
    Offset? kanbanIconPosition,
    double? hoursValue,
  }) {
    return WithdrawalLoop(
      id: id ?? this.id,
      supermarketId: supermarketId ?? this.supermarketId,
      customerProcessId: customerProcessId ?? this.customerProcessId,
      customerHandlePosition: customerHandlePosition ?? this.customerHandlePosition,
      supermarketHandlePosition: supermarketHandlePosition ?? this.supermarketHandlePosition,
      pathPoints: pathPoints ?? this.pathPoints,
      kanbanIconPosition: kanbanIconPosition ?? this.kanbanIconPosition,
      hoursValue: hoursValue ?? this.hoursValue,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'supermarketId': supermarketId,
      'customerProcessId': customerProcessId,
      'customerHandlePosition': {
        'dx': customerHandlePosition.dx,
        'dy': customerHandlePosition.dy,
      },
      'supermarketHandlePosition': {
        'dx': supermarketHandlePosition.dx,
        'dy': supermarketHandlePosition.dy,
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
  factory WithdrawalLoop.fromJson(Map<String, dynamic> json) {
    return WithdrawalLoop(
      id: json['id'],
      supermarketId: json['supermarketId'],
      customerProcessId: json['customerProcessId'],
      customerHandlePosition: Offset(
        json['customerHandlePosition']['dx'].toDouble(),
        json['customerHandlePosition']['dy'].toDouble(),
      ),
      supermarketHandlePosition: Offset(
        json['supermarketHandlePosition']['dx'].toDouble(),
        json['supermarketHandlePosition']['dy'].toDouble(),
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
