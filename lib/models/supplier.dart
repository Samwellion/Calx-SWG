import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Supplier data container for value stream information
class SupplierData {
  final String leadTime;
  final String expediteTime;
  final Map<String, dynamic> additionalData;

  const SupplierData({
    this.leadTime = '0',
    this.expediteTime = '0',
    this.additionalData = const {},
  });

  /// Create SupplierData from value stream database
  factory SupplierData.fromValueStream(Map<String, dynamic> valueStreamData) {
    return SupplierData(
      leadTime: valueStreamData['leadTime']?.toString() ?? '0',
      expediteTime: valueStreamData['expediteTime']?.toString() ?? '0',
      additionalData: Map<String, dynamic>.from(valueStreamData['additional'] ?? {}),
    );
  }

  /// Convert to JSON for persistence
  Map<String, dynamic> toJson() {
    return {
      'leadTime': leadTime,
      'expediteTime': expediteTime,
      'additional': additionalData,
    };
  }

  /// Create from JSON
  factory SupplierData.fromJson(Map<String, dynamic> json) {
    return SupplierData(
      leadTime: json['leadTime'] as String? ?? '0',
      expediteTime: json['expediteTime'] as String? ?? '0',
      additionalData: Map<String, dynamic>.from(json['additional'] as Map? ?? {}),
    );
  }

  /// Create copy with updated fields
  SupplierData copyWith({
    String? leadTime,
    String? expediteTime,
    Map<String, dynamic>? additionalData,
  }) {
    return SupplierData(
      leadTime: leadTime ?? this.leadTime,
      expediteTime: expediteTime ?? this.expediteTime,
      additionalData: additionalData ?? this.additionalData,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SupplierData &&
        other.leadTime == leadTime &&
        other.expediteTime == expediteTime &&
        mapEquals(other.additionalData, additionalData);
  }

  @override
  int get hashCode {
    return leadTime.hashCode ^
        expediteTime.hashCode ^
        additionalData.hashCode;
  }
}

/// Optimized Supplier model for VSM canvas
class Supplier {
  final String id;
  final Offset position;
  final SupplierData data;
  final bool isSelected;
  final int valueStreamId;

  const Supplier({
    required this.id,
    required this.position,
    required this.data,
    this.isSelected = false,
    this.valueStreamId = 1,
  });

  /// Create copy with updated properties
  Supplier copyWith({
    String? id,
    Offset? position,
    SupplierData? data,
    bool? isSelected,
    int? valueStreamId,
  }) {
    return Supplier(
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
  factory Supplier.fromJson(String jsonString, {required String id, required Offset position}) {
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return Supplier(
      id: id,
      position: position,
      data: SupplierData.fromJson(json['data'] as Map<String, dynamic>),
      valueStreamId: json['valueStreamId'] as int,
    );
  }

  /// Create from JSON Map (for backward compatibility)
  factory Supplier.fromJsonMap(Map<String, dynamic> json) {
    final positionData = json['position'] as Map<String, dynamic>;
    return Supplier(
      id: json['id'] as String,
      position: Offset(
        (positionData['dx'] as num).toDouble(),
        (positionData['dy'] as num).toDouble(),
      ),
      data: SupplierData.fromValueStream(json['data'] as Map<String, dynamic>),
      valueStreamId: json['valueStreamId'] as int? ?? 1,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Supplier &&
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
    return 'Supplier(id: $id, position: $position, leadTime: ${data.leadTime}, expediteTime: ${data.expediteTime})';
  }
}
