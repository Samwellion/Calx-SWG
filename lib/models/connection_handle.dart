import 'dart:ui';

/// Represents a connection handle on a canvas item
class ConnectionHandle {
  final String itemId;
  final String itemType;
  final HandlePosition position;
  final HandleAlignment alignment;
  final Offset offset;

  ConnectionHandle({
    required this.itemId,
    required this.itemType,
    required this.position,
    required this.alignment,
    required this.offset,
  });

  String get id => '${itemId}_${itemType}_${position.name}_${alignment.name}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConnectionHandle &&
          runtimeType == other.runtimeType &&
          itemId == other.itemId &&
          itemType == other.itemType &&
          position == other.position &&
          alignment == other.alignment;

  @override
  int get hashCode =>
      itemId.hashCode ^
      itemType.hashCode ^
      position.hashCode ^
      alignment.hashCode;

  Map<String, dynamic> toJson() => {
        'itemId': itemId,
        'itemType': itemType,
        'position': position.name,
        'alignment': alignment.name,
        'offset': {'dx': offset.dx, 'dy': offset.dy},
      };

  factory ConnectionHandle.fromJson(Map<String, dynamic> json) {
    return ConnectionHandle(
      itemId: json['itemId'],
      itemType: json['itemType'],
      position: HandlePosition.values.firstWhere(
        (e) => e.name == json['position'],
      ),
      alignment: HandleAlignment.values.firstWhere(
        (e) => e.name == json['alignment'],
      ),
      offset: Offset(
        json['offset']['dx'].toDouble(),
        json['offset']['dy'].toDouble(),
      ),
    );
  }
}

/// Position of the handle on the item (which side)
enum HandlePosition {
  top,
  right,
  bottom,
  left,
}

/// Alignment of the handle along that side
enum HandleAlignment {
  start,    // Left/top of the side
  center,   // Center of the side (default)
  end,      // Right/bottom of the side
}

/// Utility class for calculating connection handles
class ConnectionHandleCalculator {
  /// Calculate all connection handles for an item
  static List<ConnectionHandle> calculateHandles({
    required String itemId,
    required String itemType,
    required Offset itemPosition,
    required Size itemSize,
  }) {
    final handles = <ConnectionHandle>[];
    
    // Calculate handle offsets for each side
    for (final position in HandlePosition.values) {
      for (final alignment in HandleAlignment.values) {
        final offset = _calculateHandleOffset(
          position: position,
          alignment: alignment,
          itemPosition: itemPosition,
          itemSize: itemSize,
        );
        
        handles.add(ConnectionHandle(
          itemId: itemId,
          itemType: itemType,
          position: position,
          alignment: alignment,
          offset: offset,
        ));
      }
    }
    
    return handles;
  }

  /// Get the default (center) handle for a specific side
  static ConnectionHandle getDefaultHandle({
    required String itemId,
    required String itemType,
    required HandlePosition position,
    required Offset itemPosition,
    required Size itemSize,
  }) {
    final offset = _calculateHandleOffset(
      position: position,
      alignment: HandleAlignment.center,
      itemPosition: itemPosition,
      itemSize: itemSize,
    );
    
    return ConnectionHandle(
      itemId: itemId,
      itemType: itemType,
      position: position,
      alignment: HandleAlignment.center,
      offset: offset,
    );
  }

  /// Calculate the exact offset for a handle (relative to item position)
  static Offset _calculateHandleOffset({
    required HandlePosition position,
    required HandleAlignment alignment,
    required Offset itemPosition,
    required Size itemSize,
  }) {
    
    switch (position) {
      case HandlePosition.top:
        return Offset(
          _getAlignedX(alignment, 0, itemSize.width),
          0, // Place handle on the top edge
        );
      case HandlePosition.right:
        return Offset(
          itemSize.width, // Place handle on the right edge
          _getAlignedY(alignment, 0, itemSize.height),
        );
      case HandlePosition.bottom:
        return Offset(
          _getAlignedX(alignment, 0, itemSize.width),
          itemSize.height, // Place handle on the bottom edge
        );
      case HandlePosition.left:
        return Offset(
          0, // Place handle on the left edge
          _getAlignedY(alignment, 0, itemSize.height),
        );
    }
  }

  static double _getAlignedX(HandleAlignment alignment, double left, double width) {
    switch (alignment) {
      case HandleAlignment.start:
        return left + width * 0.25;
      case HandleAlignment.center:
        return left + width * 0.5;
      case HandleAlignment.end:
        return left + width * 0.75;
    }
  }

  static double _getAlignedY(HandleAlignment alignment, double top, double height) {
    switch (alignment) {
      case HandleAlignment.start:
        return top + height * 0.25;
      case HandleAlignment.center:
        return top + height * 0.5;
      case HandleAlignment.end:
        return top + height * 0.75;
    }
  }

  /// Find the closest handle to a given point
  static ConnectionHandle? findClosestHandle(
    List<ConnectionHandle> handles,
    Offset point,
    {double maxDistance = 30.0}
  ) {
    ConnectionHandle? closest;
    double minDistance = maxDistance;
    
    for (final handle in handles) {
      final distance = (handle.offset - point).distance;
      if (distance < minDistance) {
        minDistance = distance;
        closest = handle;
      }
    }
    
    return closest;
  }
}
