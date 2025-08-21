import 'dart:convert';
import 'package:flutter/material.dart';

/// Optimized Customer model for VSM canvas entities
class Customer {
  final String id;
  final Offset position;
  final String label;
  final CustomerData data;
  final bool isSelected;

  const Customer({
    required this.id,
    required this.position,
    this.label = 'All Customers',
    required this.data,
    this.isSelected = false,
  });

  Customer copyWith({
    String? id,
    Offset? position,
    String? label,
    CustomerData? data,
    bool? isSelected,
  }) {
    return Customer(
      id: id ?? this.id,
      position: position ?? this.position,
      label: label ?? this.label,
      data: data ?? this.data,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Customer &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  // JSON serialization methods
  String toJson() {
    return jsonEncode({
      'id': id,
      'position': {'dx': position.dx, 'dy': position.dy},
      'label': label,
      'data': data.toJson(),
      'isSelected': isSelected,
    });
  }

  factory Customer.fromJson(String jsonString, {required String id, required Offset position}) {
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return Customer(
      id: id,
      position: position,
      label: json['label'] as String? ?? 'All Customers',
      data: CustomerData.fromJson(json['data'] as Map<String, dynamic>),
      isSelected: json['isSelected'] as bool? ?? false,
    );
  }
}

/// Customer data container for display information
class CustomerData {
  final String monthlyDemand;
  final String taktTime;
  final String? additionalInfo;

  const CustomerData({
    required this.monthlyDemand,
    required this.taktTime,
    this.additionalInfo,
  });

  CustomerData copyWith({
    String? monthlyDemand,
    String? taktTime,
    String? additionalInfo,
  }) {
    return CustomerData(
      monthlyDemand: monthlyDemand ?? this.monthlyDemand,
      taktTime: taktTime ?? this.taktTime,
      additionalInfo: additionalInfo ?? this.additionalInfo,
    );
  }

  // Create from value stream data
  factory CustomerData.fromValueStream({
    int? monthlyDemand,
    String? taktTime,
  }) {
    return CustomerData(
      monthlyDemand: monthlyDemand?.toString() ?? 'N/A',
      taktTime: taktTime ?? 'N/A',
    );
  }

  static const empty = CustomerData(
    monthlyDemand: 'N/A',
    taktTime: 'N/A',
  );

  // JSON serialization methods
  Map<String, dynamic> toJson() {
    return {
      'monthlyDemand': monthlyDemand,
      'taktTime': taktTime,
      'additionalInfo': additionalInfo,
    };
  }

  factory CustomerData.fromJson(Map<String, dynamic> json) {
    return CustomerData(
      monthlyDemand: json['monthlyDemand'] as String? ?? 'N/A',
      taktTime: json['taktTime'] as String? ?? 'N/A',
      additionalInfo: json['additionalInfo'] as String?,
    );
  }
}
