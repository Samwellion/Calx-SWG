import 'package:flutter/material.dart';

class KanbanPost {
  final String id;
  final String label;
  final Offset position;
  final Size size;

  const KanbanPost({
    required this.id,
    required this.label,
    required this.position,
    this.size = const Size(54, 49), // Icon only: 50px + 4px padding (2px each side)
  });

  KanbanPost copyWith({
    String? id,
    String? label,
    Offset? position,
    Size? size,
  }) {
    return KanbanPost(
      id: id ?? this.id,
      label: label ?? this.label,
      position: position ?? this.position,
      size: size ?? this.size,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'position': {
        'dx': position.dx,
        'dy': position.dy,
      },
      'size': {
        'width': size.width,
        'height': size.height,
      },
    };
  }

  factory KanbanPost.fromJson(Map<String, dynamic> json) {
    return KanbanPost(
      id: json['id'] as String,
      label: json['label'] as String,
      position: Offset(
        (json['position']['dx'] as num).toDouble(),
        (json['position']['dy'] as num).toDouble(),
      ),
      size: Size(
        (json['size']['width'] as num).toDouble(),
        (json['size']['height'] as num).toDouble(),
      ),
    );
  }

  @override
  String toString() {
    return 'KanbanPost(id: $id, label: $label, position: $position, size: $size)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is KanbanPost &&
        other.id == id &&
        other.label == label &&
        other.position == position &&
        other.size == size;
  }

  @override
  int get hashCode {
    return Object.hash(id, label, position, size);
  }
}
