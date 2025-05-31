// time_observation_table.dart
import 'package:flutter/material.dart';

class TimeObservationTable extends StatefulWidget {
  const TimeObservationTable({super.key});

  @override
  State<TimeObservationTable> createState() => TimeObservationTableState();
}

class TimeObservationTableState extends State<TimeObservationTable> {
  final List<Map<String, dynamic>> _rows = [
    {'element': '', 'times': <Duration>[]}
  ];
  List<Duration> _footerLapTotals = [];
  Object? _footerLowestRepeatable;
  bool _showOvrdColumn = false;
  final List<String> _ovrdValues = [];
  final List<String> _summaryValues = [];
  bool _editable = false;

  void insertTime(Duration time) {
    setState(() {
      final rounded = Duration(seconds: (time.inMilliseconds / 1000).round());
      final nonEmptyRows = _rows
          .where((row) => (row['element'] as String).trim().isNotEmpty)
          .toList();
      if (nonEmptyRows.isEmpty) return;
      final minTimes = nonEmptyRows
          .map((row) => (row['times'] as List<Duration>).length)
          .reduce((a, b) => a < b ? a : b);
      final row = nonEmptyRows.firstWhere(
          (row) => (row['times'] as List<Duration>).length == minTimes);
      (row['times'] as List<Duration>).add(rounded);
      _ovrdValues.add('');
      _summaryValues.add('');
      _updateFooterTotals();
    });
  }

  void clearTimeColumns() {
    setState(() {
      for (final row in _rows) {
        (row['times'] as List<Duration>).clear();
        row['lowestRepeatable'] = null;
      }
      _footerLapTotals = [];
      _footerLowestRepeatable = null;
      _ovrdValues.clear();
      _summaryValues.clear();
      _editable = false;
      _showOvrdColumn = false;
    });
  }

  void hideRowsWithoutElement() {
    setState(() {
      _rows.removeWhere((row) => (row['element'] as String).trim().isEmpty);
      if (_rows.isEmpty) {
        _rows.add({'element': '', 'times': <Duration>[]});
      }
    });
  }

  void _updateFooterTotals() {
    final int lapCount = _rows.fold<int>(
        1,
        (max, row) => (row['times'] as List<Duration>).length > max
            ? (row['times'] as List<Duration>).length
            : max);
    _footerLapTotals = List<Duration>.generate(lapCount, (i) {
      return _rows.fold(Duration.zero, (sum, row) {
        final times = row['times'] as List<Duration>;
        return i < times.length ? sum + times[i] : sum;
      });
    });
  }

  void enterLowestRepeatedIntoTimeColumn() {
    setState(() {
      for (final row in _rows) {
        final times = row['times'] as List<Duration>;
        if (times.isNotEmpty) {
          final roundedTimes = times
              .map((t) => Duration(seconds: (t.inMilliseconds / 1000).round()))
              .toList();
          final counts = <Duration, int>{};
          for (final t in roundedTimes) {
            counts[t] = (counts[t] ?? 0) + 1;
          }
          final sorted = roundedTimes.toSet().toList()..sort();
          final lowestRepeatable = sorted
              .cast<Duration?>()
              .firstWhere((t) => counts[t]! >= 2, orElse: () => null);
          row['lowestRepeatable'] = lowestRepeatable ?? 'N/A';
        } else {
          row['lowestRepeatable'] = null;
        }
      }
      if (_footerLapTotals.isNotEmpty) {
        final roundedTotals = _footerLapTotals
            .map((t) => Duration(seconds: (t.inMilliseconds / 1000).round()))
            .toList();
        final counts = <Duration, int>{};
        for (final t in roundedTotals) {
          counts[t] = (counts[t] ?? 0) + 1;
        }
        final sorted = roundedTotals.toSet().toList()..sort();
        final lowestRepeatable = sorted
            .cast<Duration?>()
            .firstWhere((t) => counts[t]! >= 2, orElse: () => null);
        _footerLowestRepeatable = lowestRepeatable ?? 'N/A';
      } else {
        _footerLowestRepeatable = null;
      }
    });
  }

  void unhideOvrdColumn() {
    setState(() {
      _showOvrdColumn = true;
      _editable = true;
    });
  }

  String timeToString(Duration time) {
    final h = time.inHours;
    final m = time.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = time.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final int lapCount = _rows.fold<int>(
        1,
        (max, row) => (row['times'] as List<Duration>).length > max
            ? (row['times'] as List<Duration>).length
            : max);
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black26),
        color: Colors.yellow[100],
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 8,
            offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.resolveWith<Color?>(
                        (states) => Colors.yellow[300]),
                    columns: [
                      const DataColumn(
                          label: Center(
                        child: Text('#',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                      )),
                      const DataColumn(
                          label: Center(
                        child: Text('Element',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                      )),
                      ...List.generate(
                        lapCount,
                        (index) => DataColumn(
                          label: Center(
                            child: Text('Lap ${index + 1}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                          numeric: false,
                          tooltip: 'Lap ${index + 1}',
                        ),
                      ),
                      const DataColumn(
                        label: Center(
                          child: Text('Lowest Repeat',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ),
                      const DataColumn(
                          label: Center(
                        child: Text('Summary',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                      )),
                      if (_showOvrdColumn)
                        const DataColumn(
                          label: Center(
                            child: Text('OVRD',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                        ),
                    ],
                  rows: [
                    ...List.generate(_rows.length, (rowIdx) {
                      final row = _rows[rowIdx];
                      final times = row['times'] as List<Duration>;
                      final ovrdCell = _showOvrdColumn
                          ? DataCell(_editable
                              ? Container(
                                  color: Colors.white,
                                  child: TextFormField(
                                    initialValue: _ovrdValues[rowIdx],
                                    onChanged: (val) {
                                      _ovrdValues[rowIdx] = val;
                                    },
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 8, horizontal: 4),
                                      fillColor: Colors.white,
                                      filled: true,
                                    ),
                                  ),
                                )
                              : Text(_ovrdValues[rowIdx]))
                          : null;
                      final summaryCell = _showOvrdColumn
                          ? DataCell(_editable
                              ? Container(
                                  color: Colors.white,
                                  child: TextFormField(
                                    initialValue: _summaryValues[rowIdx],
                                    onChanged: (val) {
                                      _summaryValues[rowIdx] = val;
                                    },
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 8, horizontal: 4),
                                      fillColor: Colors.white,
                                      filled: true,
                                    ),
                                  ),
                                )
                              : Text(_summaryValues[rowIdx]))
                          : null;
                      return DataRow(
                        cells: [
                          DataCell(Text((rowIdx + 1).toString(),
                              style: const TextStyle(fontSize: 16))),
                          DataCell(
                            TextFormField(
                              initialValue: row['element'],
                              style: const TextStyle(fontSize: 16),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Enter element',
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 4, horizontal: 2),
                              ),
                              onChanged: (val) {
                                setState(() {
                                  row['element'] = val;
                                  if (rowIdx == _rows.length - 1 &&
                                      val.trim().isNotEmpty) {
                                    _rows.add({
                                      'element': '',
                                      'times': <Duration>[]
                                    });
                                  }
                                });
                              },
                            ),
                          ),
                          ...List.generate(
                            lapCount,
                            (i) {
                              final isActive = i == times.length &&
                                  (row['element'] as String)
                                      .trim()
                                      .isNotEmpty &&
                                  rowIdx ==
                                      _rows.indexWhere((r) =>
                                          (r['element'] as String)
                                              .trim()
                                              .isNotEmpty &&
                                          (r['times'] as List<Duration>)
                                                  .length ==
                                              times.length);
                              return DataCell(
                                Container(
                                  color: isActive ? Colors.white : null,
                                  constraints: const BoxConstraints(
                                      minWidth: 40, maxWidth: 70),
                                  alignment: Alignment.center,
                                  child: i < times.length
                                      ? Text(timeToString(times[i]),
                                          style:
                                              const TextStyle(fontSize: 16))
                                      : const Text('-',
                                          style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 16)),
                                ),
                              );
                            },
                          ),
                          DataCell(
                            row['lowestRepeatable'] == null
                                ? const Text('',
                                    style: TextStyle(fontSize: 16))
                                : row['lowestRepeatable'] is Duration
                                    ? Text(
                                        timeToString(row['lowestRepeatable']
                                            as Duration),
                                        style: const TextStyle(fontSize: 16))
                                    : Text(row['lowestRepeatable'].toString(),
                                        style: const TextStyle(fontSize: 16)),
                          ),
                          const DataCell(
                              Text('', style: TextStyle(fontSize: 16))),
                          if (_showOvrdColumn)
                            ovrdCell!,
                          if (_showOvrdColumn)
                            summaryCell!,
                        ],
                      );
                    }),
                    DataRow(
                      color: WidgetStateProperty.resolveWith<Color?>(
                          (states) => Colors.yellow[300]),
                      cells: [
                        const DataCell(Text('')),
                        const DataCell(Text('Total Lap Time',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16))),
                        ...List.generate(
                          lapCount,
                          (i) => DataCell(
                            Text(
                              _footerLapTotals.isNotEmpty &&
                                      i < _footerLapTotals.length &&
                                      _footerLapTotals[i] > Duration.zero
                                  ? timeToString(_footerLapTotals[i])
                                  : '',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        DataCell(
                          _footerLowestRepeatable == null
                              ? const Text('', style: TextStyle(fontSize: 16))
                              : _footerLowestRepeatable is Duration
                                  ? Text(
                                      timeToString(_footerLowestRepeatable
                                          as Duration),
                                      style: const TextStyle(fontSize: 16))
                                  : Text(_footerLowestRepeatable.toString(),
                                      style: const TextStyle(fontSize: 16)),
                        ),
                        const DataCell(Text('')),
                      ],
                    ),
                  ],
                )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
