import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Production Control data container for value stream information
class ProductionControlData {
  final String controlType;
  final String frequency;
  final Map<String, dynamic> additionalData;

  const ProductionControlData({
    this.controlType = 'Daily',
    this.frequency = 'Schedule',
    this.additionalData = const {},
  });

  /// Create ProductionControlData from value stream database
  factory ProductionControlData.fromValueStream(Map<String, dynamic> valueStreamData) {
    return ProductionControlData(
      controlType: valueStreamData['controlType']?.toString() ?? 'Daily',
      frequency: valueStreamData['frequency']?.toString() ?? 'Schedule',
      additionalData: Map<String, dynamic>.from(valueStreamData['additional'] ?? {}),
    );
  }

  /// Convert to JSON for persistence
  Map<String, dynamic> toJson() {
    return {
      'controlType': controlType,
      'frequency': frequency,
      'additional': additionalData,
    };
  }

  /// Create from JSON
  factory ProductionControlData.fromJson(Map<String, dynamic> json) {
    return ProductionControlData(
      controlType: json['controlType'] as String? ?? 'Daily',
      frequency: json['frequency'] as String? ?? '1',
      additionalData: Map<String, dynamic>.from(json['additional'] as Map? ?? {}),
    );
  }

  /// Create copy with updated fields
  ProductionControlData copyWith({
    String? controlType,
    String? frequency,
    Map<String, dynamic>? additionalData,
  }) {
    return ProductionControlData(
      controlType: controlType ?? this.controlType,
      frequency: frequency ?? this.frequency,
      additionalData: additionalData ?? this.additionalData,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProductionControlData &&
        other.controlType == controlType &&
        other.frequency == frequency &&
        mapEquals(other.additionalData, additionalData);
  }

  @override
  int get hashCode {
    return controlType.hashCode ^
        frequency.hashCode ^
        additionalData.hashCode;
  }
}

/// Optimized Production Control model for VSM canvas
class ProductionControl {
  final String id;
  final Offset position;
  final ProductionControlData data;
  final bool isSelected;
  final int valueStreamId;

  const ProductionControl({
    required this.id,
    required this.position,
    required this.data,
    this.isSelected = false,
    this.valueStreamId = 1,
  });

  /// Create copy with updated properties
  ProductionControl copyWith({
    String? id,
    Offset? position,
    ProductionControlData? data,
    bool? isSelected,
    int? valueStreamId,
  }) {
    return ProductionControl(
      id: id ?? this.id,
      position: position ?? this.position,
      data: data ?? this.data,
      isSelected: isSelected ?? this.isSelected,
      valueStreamId: valueStreamId ?? this.valueStreamId,
    );
  }

  /// Convert to JSON for persistence
  String toJson() {
    return jsonEncode({
      'id': id,
      'position': {'dx': position.dx, 'dy': position.dy},
      'data': data.toJson(),
      'valueStreamId': valueStreamId,
    });
  }

  /// Create from JSON string
  factory ProductionControl.fromJson(String jsonString, {required String id, required Offset position}) {
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return ProductionControl(
      id: id,
      position: position,
      data: ProductionControlData.fromJson(json['data'] as Map<String, dynamic>),
      valueStreamId: json['valueStreamId'] as int,
    );
  }

  /// Create from JSON Map (for backward compatibility)
  factory ProductionControl.fromJsonMap(Map<String, dynamic> json) {
    final positionData = json['position'] as Map<String, dynamic>;
    return ProductionControl(
      id: json['id'] as String,
      position: Offset(
        (positionData['dx'] as num).toDouble(),
        (positionData['dy'] as num).toDouble(),
      ),
      data: ProductionControlData.fromValueStream(json['data'] as Map<String, dynamic>),
      valueStreamId: json['valueStreamId'] as int? ?? 1,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProductionControl &&
        other.id == id &&
        other.position == position &&
        other.data == data &&
        other.isSelected == isSelected &&
        other.valueStreamId == valueStreamId;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        position.hashCode ^
        data.hashCode ^
        isSelected.hashCode ^
        valueStreamId.hashCode;
  }

  @override
  String toString() {
    return 'ProductionControl(id: $id, position: $position, controlType: ${data.controlType}, frequency: ${data.frequency})';
  }
}
