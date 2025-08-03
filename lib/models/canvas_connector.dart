import 'package:flutter/material.dart';
import 'connection_handle.dart';

/// Enum for different types of connectors/arrows
enum ConnectorType {
  // Material and Info Connectors (from toolbox)
  electronic,      // Electronic information arrow
  information,     // Information flow arrow  
  material,        // Material flow arrow
  materialPush,    // Material push connector (TODO)
  kanbanLoop,      // Kanban loop connector (TODO)
  withdrawalLoop,   // Withdrawal loop connector (TODO)
}

/// Represents a connection endpoint (where an arrow connects to an item)
class ConnectorEndpoint {
  final String itemId; // ID of the connected item (process, icon, or data box)
  final String itemType; // Type: 'process', 'icon', 'customer', 'supplier', 'productionControl', 'truck'
  final ConnectionHandle? handle; // Connection handle with position and alignment
  final Offset? connectionPoint; // Legacy support - will be deprecated

  ConnectorEndpoint({
    required this.itemId,
    required this.itemType,
    this.handle,
    this.connectionPoint,
  });

  ConnectorEndpoint copyWith({
    String? itemId,
    String? itemType,
    ConnectionHandle? handle,
    Offset? connectionPoint,
  }) {
    return ConnectorEndpoint(
      itemId: itemId ?? this.itemId,
      itemType: itemType ?? this.itemType,
      handle: handle ?? this.handle,
      connectionPoint: connectionPoint ?? this.connectionPoint,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itemId': itemId,
      'itemType': itemType,
      if (handle != null) 'handle': handle!.toJson(),
      if (connectionPoint != null) 'connectionPointX': connectionPoint!.dx,
      if (connectionPoint != null) 'connectionPointY': connectionPoint!.dy,
    };
  }

  factory ConnectorEndpoint.fromJson(Map<String, dynamic> json) {
    return ConnectorEndpoint(
      itemId: json['itemId'],
      itemType: json['itemType'],
      handle: json['handle'] != null 
        ? ConnectionHandle.fromJson(json['handle'])
        : null,
      connectionPoint: json['connectionPointX'] != null && json['connectionPointY'] != null
        ? Offset(
            json['connectionPointX'].toDouble(),
            json['connectionPointY'].toDouble(),
          )
        : null,
    );
  }
}

/// Represents a connector (arrow) between two items on the canvas
class CanvasConnector {
  final String id;
  final ConnectorType type; // Type of connector
  final ConnectorEndpoint startPoint;
  final ConnectorEndpoint endPoint;
  final Color color;
  final double strokeWidth;
  final String label; // Optional label for the connector

  CanvasConnector({
    required this.id,
    required this.type,
    required this.startPoint,
    required this.endPoint,
    Color? color,
    this.strokeWidth = 2.0,
    this.label = '',
  }) : color = color ?? _getDefaultColorForType(type);

  static Color _getDefaultColorForType(ConnectorType type) {
    switch (type) {
      case ConnectorType.electronic:
        return Colors.lightBlue;
      case ConnectorType.information:
        return Colors.blue;
      case ConnectorType.material:
        return Colors.green;
      case ConnectorType.materialPush:
        return Colors.red;
      case ConnectorType.kanbanLoop:
        return Colors.amber;
      case ConnectorType.withdrawalLoop:
        return Colors.purple;
    }
  }

  CanvasConnector copyWith({
    String? id,
    ConnectorType? type,
    ConnectorEndpoint? startPoint,
    ConnectorEndpoint? endPoint,
    Color? color,
    double? strokeWidth,
    String? label,
  }) {
    return CanvasConnector(
      id: id ?? this.id,
      type: type ?? this.type,
      startPoint: startPoint ?? this.startPoint,
      endPoint: endPoint ?? this.endPoint,
      color: color ?? this.color,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      label: label ?? this.label,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString(),
      'startPoint': startPoint.toJson(),
      'endPoint': endPoint.toJson(),
      'colorValue': color.value,
      'strokeWidth': strokeWidth,
      'label': label,
    };
  }

  factory CanvasConnector.fromJson(Map<String, dynamic> json) {
    return CanvasConnector(
      id: json['id'],
      type: ConnectorType.values.firstWhere(
        (t) => t.toString() == json['type'],
        orElse: () => ConnectorType.information,
      ),
      startPoint: ConnectorEndpoint.fromJson(json['startPoint']),
      endPoint: ConnectorEndpoint.fromJson(json['endPoint']),
      color: Color(json['colorValue']),
      strokeWidth: json['strokeWidth'].toDouble(),
      label: json['label'] ?? '',
    );
  }
}

/// Enum for connection mode states
enum ConnectionMode {
  none,                    // Normal mode - no connections being made
  selecting,               // User clicked arrow tool, waiting for first item selection
  connecting,              // First item selected, waiting for second item selection
  materialConnectorSelecting,  // User clicked material connector tool, waiting for supplier selection
  materialConnectorConnecting, // Supplier selected, waiting for customer selection
  kanbanLoopSelecting,     // User clicked kanban loop tool, waiting for supermarket selection
  kanbanLoopConnecting,    // Supermarket selected, waiting for supplier selection
}
