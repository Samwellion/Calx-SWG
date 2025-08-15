import 'package:flutter/material.dart';
import '../logic/app_database.dart';

class ProcessObjectData {
  final ProcessesData process;
  final ProcessPart? processPart;
  final String? calculatedCycleTime; // Average cycle time from all ProcessParts

  ProcessObjectData({
    required this.process,
    this.processPart,
    this.calculatedCycleTime,
  });
}

class ProcessObject {
  final int id;
  final String name;
  final String description;
  final Color color;
  Offset position;
  final Size size;
  final int valueStreamId;

  // Process data fields
  final int? staff;
  final int? dailyDemand;
  final int? wip;
  final double? uptime; // as decimal (0.85 for 85%)
  final String? coTime; // HH:MM:SS format
  final String? taktTime; // HH:MM:SS format

  // ProcessPart data fields
  final String? processTime; // HH:MM:SS format
  final double? fpy; // as decimal (0.95 for 95%)

  ProcessObject({
    required this.id,
    required this.name,
    required this.description,
    required this.color,
    required this.position,
    required this.valueStreamId,
    this.size = const Size(140, 160), // Further reduced height for tighter fit
    this.staff,
    this.dailyDemand,
    this.wip,
    this.uptime,
    this.coTime,
    this.taktTime,
    this.processTime,
    this.fpy,
  });

  factory ProcessObject.fromProcessData(ProcessObjectData data) {
    final process = data.process;
    final processPart = data.processPart;

    // Parse color from hex string or use default
    Color processColor = Colors.blue[200]!;
    if (process.color != null && process.color!.isNotEmpty) {
      try {
        processColor =
            Color(int.parse(process.color!.replaceFirst('#', '0xFF')));
      } catch (e) {
        // Use default color if parsing fails
      }
    }

    // Get position or use default
    Offset processPosition = const Offset(100, 100);
    if (process.positionX != null && process.positionY != null) {
      processPosition = Offset(process.positionX!, process.positionY!);
    }

    return ProcessObject(
      id: process.id,
      name: process.processName,
      description: process.processDescription ?? '',
      color: processColor,
      position: processPosition,
      valueStreamId: process.valueStreamId,
      staff: process.staff,
      dailyDemand: process.dailyDemand,
      wip: process.wip,
      uptime: process.uptime,
      coTime: process.coTime,
      taktTime: process.taktTime,
      processTime: processPart?.userOverrideTime ?? processPart?.processTime ?? data.calculatedCycleTime,
      fpy: processPart?.fpy,
    );
  }

  String get colorHex {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
  }

  String get staffingDisplay => staff?.toString() ?? 'N/A';
  String get dailyDemandDisplay => dailyDemand?.toString() ?? 'N/A';
  String get taktTimeDisplay => taktTime ?? 'N/A';
  String get wipDisplay => wip?.toString() ?? 'N/A';

  // LT (Lead Time) should be the processpart processTime 
  String get leadTimeDisplay => processTime ?? 'N/A';

  // CT (Cycle Time) should be the processTime divided by the WIP
  String get cycleTimeDisplay {
    if (processTime != null && wip != null && wip! > 0) {
      try {
        final parts = processTime!.split(':');
        if (parts.length == 3) {
          final hours = int.parse(parts[0]);
          final minutes = int.parse(parts[1]);
          final seconds = int.parse(parts[2]);

          final totalSeconds = hours * 3600 + minutes * 60 + seconds;
          final cycleTimeSeconds = totalSeconds / wip!;

          final cycleHours = (cycleTimeSeconds / 3600).floor();
          final cycleMinutes = ((cycleTimeSeconds % 3600) / 60).floor();
          final cycleSecs = (cycleTimeSeconds % 60).floor();

          return '${cycleHours.toString().padLeft(2, '0')}:${cycleMinutes.toString().padLeft(2, '0')}:${cycleSecs.toString().padLeft(2, '0')}';
        }
      } catch (e) {
        // Fall through to default
      }
    }
    return processTime ?? 'N/A';
  }

  String get uptimeDisplay {
    if (uptime != null) {
      return '${(uptime! * 100).toStringAsFixed(1)}%';
    }
    return 'N/A';
  }

  String get fpyDisplay {
    if (fpy != null) {
      return '${(fpy! * 100).toStringAsFixed(1)}%';
    }
    return 'N/A';
  }

  String get changeoverDisplay => coTime ?? 'N/A';

  ProcessObject copyWith({
    int? id,
    String? name,
    String? description,
    Color? color,
    Offset? position,
    Size? size,
    int? valueStreamId,
    int? staff,
    int? dailyDemand,
    int? wip,
    double? uptime,
    String? coTime,
    String? taktTime,
    String? processTime,
    double? fpy,
  }) {
    return ProcessObject(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      position: position ?? this.position,
      size: size ?? this.size,
      valueStreamId: valueStreamId ?? this.valueStreamId,
      staff: staff ?? this.staff,
      dailyDemand: dailyDemand ?? this.dailyDemand,
      wip: wip ?? this.wip,
      uptime: uptime ?? this.uptime,
      coTime: coTime ?? this.coTime,
      taktTime: taktTime ?? this.taktTime,
      processTime: processTime ?? this.processTime,
      fpy: fpy ?? this.fpy,
    );
  }
}
