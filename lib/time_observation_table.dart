// time_observation_table.dart
import 'package:flutter/material.dart';

class TimeObservationTable extends StatefulWidget {
  const TimeObservationTable({super.key});

  @override
  State<TimeObservationTable> createState() => TimeObservationTableState();
}

class TimeObservationTableState extends State<TimeObservationTable> {
  // Helper to get the current number of laps (columns)
  int get lapCount => _rows.fold<int>(
      1,
      (max, row) => (row['times'] as List<Duration>).length > max
          ? (row['times'] as List<Duration>).length
          : max);
  final List<Map<String, dynamic>> _rows = [
    {'element': '', 'times': <Duration>[]}
  ];
  final Map<int, TextEditingController> _elementControllers = {};
  final Map<int, FocusNode> _elementFocusNodes = {};
  int? _focusRowIndex;
  List<Duration> _footerLapTotals = [];
  final List<String> _ovrdValues = [];
  final List<String> _summaryValues = [];

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
      _ovrdValues.clear();
      _summaryValues.clear();
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
        // Removed unused 'sorted' variable.
      } else {}
    });
  }

  void unhideOvrdColumn() {
    setState(() {});
  }

  String timeToString(Duration time) {
    final h = time.inHours;
    final m = time.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = time.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
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
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(Colors.yellow[200]),
              columns: [
                const DataColumn(
                    label: Text('#',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                const DataColumn(
                    label: Text('Element',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                ...List.generate(
                  lapCount,
                  (lapIdx) => DataColumn(
                    label: Text('Lap${lapIdx + 1}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const DataColumn(
                    label: Text('Lowest Repeatable',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                const DataColumn(
                    label: Text('Comments',
                        style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: List<DataRow>.generate(
                _rows.length,
                (rowIdx) {
                  final row = _rows[rowIdx];
                  _elementControllers.putIfAbsent(rowIdx,
                      () => TextEditingController(text: row['element'] ?? ''));
                  _elementFocusNodes.putIfAbsent(rowIdx, () => FocusNode());
                  final controller = _elementControllers[rowIdx]!;
                  final focusNode = _elementFocusNodes[rowIdx]!;
                  if (controller.text != (row['element'] ?? '')) {
                    controller.text = row['element'] ?? '';
                    controller.selection = TextSelection.fromPosition(
                        TextPosition(offset: controller.text.length));
                  }
                  if (_focusRowIndex == rowIdx) {
                    Future.delayed(Duration.zero, () {
                      FocusScope.of(context).requestFocus(focusNode);
                      _focusRowIndex = null;
                    });
                  }
                  return DataRow(
                    cells: [
                      DataCell(Text('${rowIdx + 1}')),
                      DataCell(
                        Container(
                          color: focusNode.hasFocus
                              ? Colors.white
                              : Colors.transparent,
                          child: TextField(
                            controller: controller,
                            focusNode: focusNode,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Enter element',
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 4),
                            ),
                            onSubmitted: (value) {
                              setState(() {
                                row['element'] = value;
                                if (rowIdx == _rows.length - 1 &&
                                    value.trim().isNotEmpty) {
                                  _rows.add(
                                      {'element': '', 'times': <Duration>[]});
                                  _focusRowIndex = _rows.length - 1;
                                }
                              });
                            },
                            onChanged: (value) {
                              row['element'] = value;
                            },
                          ),
                        ),
                      ),
                      ...List.generate(lapCount, (lapIdx) {
                        final times = row['times'] as List<Duration>;
                        final isLastRow = rowIdx == _rows.length - 1;
                        final isLastLap = lapIdx == lapCount - 1;
                        final hasValue = lapIdx < times.length;
                        return DataCell(
                          GestureDetector(
                            onTap: () async {
                              // Optionally, you could show a dialog or input for manual entry
                            },
                            child: InkWell(
                              child: Text(
                                hasValue ? timeToString(times[lapIdx]) : '',
                                style: TextStyle(
                                  color: hasValue ? Colors.black : Colors.grey,
                                ),
                              ),
                              onTap: () async {
                                // Only allow entry in the last lap column of the last row
                                if (isLastRow && isLastLap) {
                                  // Simulate entering a value (in real use, you would show a dialog or input)
                                  setState(() {
                                    // Add a dummy value for demonstration
                                    times.add(const Duration(seconds: 0));
                                    // After all rows have a value for this lap, add a new lap column
                                    final allRowsHaveValue = _rows.every((r) =>
                                        (r['times'] as List).length > lapIdx);
                                    if (allRowsHaveValue) {
                                      for (final r in _rows) {
                                        (r['times'] as List<Duration>)
                                            .add(const Duration());
                                      }
                                    }
                                  });
                                }
                              },
                            ),
                          ),
                        );
                      }),
                      DataCell(
                        Text(
                          row['lowestRepeatable'] is Duration
                              ? timeToString(
                                  row['lowestRepeatable'] as Duration)
                              : (row['lowestRepeatable']?.toString() ?? ''),
                        ),
                      ),
                      DataCell(Text(row['comments'] ?? '')),
                    ],
                  );
                },
              ),
            ),
          ),
          // Footer row below the DataTable, perfectly aligned
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Table(
              columnWidths: {
                0: const IntrinsicColumnWidth(),
                1: const IntrinsicColumnWidth(),
                for (int i = 0; i < lapCount; i++)
                  2 + i: const IntrinsicColumnWidth(),
                2 + lapCount: const IntrinsicColumnWidth(),
                3 + lapCount: const IntrinsicColumnWidth(),
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                TableRow(
                  children: [
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.yellow[300],
                          border: const Border(
                            top: BorderSide(color: Colors.black26),
                            right: BorderSide(color: Colors.black26),
                          ),
                        ),
                        alignment: Alignment.centerLeft,
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: const Text(
                          'Total Lap',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    // Merge the first two columns
                    for (int i = 1; i < 2; i++) const SizedBox.shrink(),
                    // Lap columns
                    ...List.generate(lapCount, (lapIdx) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.yellow[100],
                          border: const Border(
                            top: BorderSide(color: Colors.black26),
                            right: BorderSide(color: Colors.black26),
                          ),
                        ),
                        alignment: Alignment.center,
                        height: 40,
                        child: Text(
                          _footerLapTotals.length > lapIdx
                              ? timeToString(_footerLapTotals[lapIdx])
                              : '',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      );
                    }),
                    // Lowest Repeatable column
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.yellow[100],
                        border: const Border(
                          top: BorderSide(color: Colors.black26),
                          right: BorderSide(color: Colors.black26),
                        ),
                      ),
                      alignment: Alignment.center,
                      height: 40,
                      child: const Text(''),
                    ),
                    // Comments column
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.yellow[100],
                        border: const Border(
                          top: BorderSide(color: Colors.black26),
                        ),
                      ),
                      alignment: Alignment.center,
                      height: 40,
                      child: const Text(''),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
