import 'package:flutter/material.dart';
import 'canvas_icon.dart';

/// Represents a material connector that connects two process items on the canvas
class MaterialConnector {
  final String id;
  final CanvasIconType type;
  final String supplierProcessId;
  final String customerProcessId;
  final String label;
  final int? numberOfPieces;
  final Color color;
  Offset position; // Center position between the two processes
  final Size size;

  MaterialConnector({
    required this.id,
    required this.type,
    required this.supplierProcessId,
    required this.customerProcessId,
    required this.label,
    required this.position,
    this.numberOfPieces,
    this.color = Colors.cyan,
    this.size = const Size(85, 130), // Increased height to prevent overflow and add spacing
  });

  MaterialConnector copyWith({
    String? id,
    CanvasIconType? type,
    String? supplierProcessId,
    String? customerProcessId,
    String? label,
    int? numberOfPieces,
    Color? color,
    Offset? position,
    Size? size,
  }) {
    return MaterialConnector(
      id: id ?? this.id,
      type: type ?? this.type,
      supplierProcessId: supplierProcessId ?? this.supplierProcessId,
      customerProcessId: customerProcessId ?? this.customerProcessId,
      label: label ?? this.label,
      numberOfPieces: numberOfPieces ?? this.numberOfPieces,
      color: color ?? this.color,
      position: position ?? this.position,
      size: size ?? this.size,
    );
  }

  /// Calculate the estimated lead time based on number of pieces and supplier TT
  String calculateEstimatedLeadTime(String? supplierTaktTime) {
    if (numberOfPieces == null || 
        numberOfPieces! <= 0 || 
        supplierTaktTime == null || 
        supplierTaktTime.isEmpty ||
        supplierTaktTime == 'N/A') {
      return 'N/A';
    }

    try {
      // Parse takt time in HH:MM:SS format
      final parts = supplierTaktTime.split(':');
      if (parts.length == 3) {
        final hours = int.parse(parts[0]);
        final minutes = int.parse(parts[1]);
        final seconds = int.parse(parts[2]);

        final taktTimeSeconds = hours * 3600 + minutes * 60 + seconds;
        final totalSeconds = taktTimeSeconds * numberOfPieces!;

        // Convert back to days, hours, minutes
        final days = (totalSeconds / 86400).floor(); // 86400 seconds in a day
        final remainingAfterDays = totalSeconds % 86400;
        final hoursRemaining = (remainingAfterDays / 3600).floor();
        final minutesRemaining = ((remainingAfterDays % 3600) / 60).floor();

        // Format as DD"d" HH"h" MM"m"
        String result = '';
        if (days > 0) {
          result += '${days}d ';
        }
        if (hoursRemaining > 0) {
          result += '${hoursRemaining}h ';
        }
        if (minutesRemaining > 0) {
          result += '${minutesRemaining}m';
        }

        return result.trim().isNotEmpty ? result.trim() : '0m';
      }
    } catch (e) {
      // Parsing failed
    }

    return 'N/A';
  }

  /// Convert to JSON for persistence
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString(),
      'supplierProcessId': supplierProcessId,
      'customerProcessId': customerProcessId,
      'label': label,
      'numberOfPieces': numberOfPieces,
      'color': color.value,
      'positionX': position.dx,
      'positionY': position.dy,
      'width': size.width,
      'height': size.height,
    };
  }

  /// Create from JSON for persistence
  factory MaterialConnector.fromJson(Map<String, dynamic> json) {
    return MaterialConnector(
      id: json['id'],
      type: CanvasIconType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => CanvasIconType.fifo,
      ),
      supplierProcessId: json['supplierProcessId'],
      customerProcessId: json['customerProcessId'],
      label: json['label'],
      numberOfPieces: json['numberOfPieces'],
      color: Color(json['color']),
      position: Offset(json['positionX'], json['positionY']),
      size: Size(json['width'], json['height']),
    );
  }
}

/// Helper class to determine if a MaterialConnector type is valid
class MaterialConnectorHelper {
  static const List<CanvasIconType> materialConnectorTypes = [
    CanvasIconType.fifo,
    CanvasIconType.buffer,
    CanvasIconType.kanbanMarket,
    CanvasIconType.uncontrolled,
  ];

  static bool isMaterialConnectorType(CanvasIconType type) {
    return materialConnectorTypes.contains(type);
  }

  static IconData getIconData(CanvasIconType type) {
    switch (type) {
      case CanvasIconType.fifo:
        return Icons.queue;
      case CanvasIconType.buffer:
        return Icons.storage;
      case CanvasIconType.kanbanMarket:
        return Icons.store;
      case CanvasIconType.uncontrolled:
        return Icons.help_outline;
      default:
        return Icons.error;
    }
  }

  static Color getColor(CanvasIconType type) {
    switch (type) {
      case CanvasIconType.fifo:
        return Colors.cyan;
      case CanvasIconType.buffer:
        return Colors.grey;
      case CanvasIconType.kanbanMarket:
        return Colors.amber;
      case CanvasIconType.uncontrolled:
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
}
