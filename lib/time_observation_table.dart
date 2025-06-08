// time_observation_table.dart
import 'package:flutter/material.dart';
import 'global_table_data.dart';

class TimeObservationTable extends StatefulWidget {
  const TimeObservationTable({super.key});

  @override
  State<TimeObservationTable> createState() => TimeObservationTableState();
}

class TimeObservationTableState extends State<TimeObservationTable> {
  static const double _columnWidth =
      120.0; // Define uniform column width for most columns
  static const double _lapColumnWidth =
      _columnWidth * 0.8; // 20% reduction for Lap columns
  static const double _firstColumnWidth =
      _columnWidth * 0.4; // Reduced width for the first column
  static const double _commentsColumnWidth =
      _columnWidth * 2; // Double width for comments

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
  final Map<int, TextEditingController> _commentsControllers = {};
  final Map<int, TextEditingController> _lowestRepeatableControllers = {};
  @override
  void dispose() {
    for (final controller in _elementControllers.values) {
      controller.dispose();
    }
    for (final node in _elementFocusNodes.values) {
      node.dispose();
    }
    for (final controller in _commentsControllers.values) {
      controller.dispose();
    }
    for (final controller in _lowestRepeatableControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  int? _focusRowIndex;
  List<Duration> _footerLapTotals = [];
  final List<String> _ovrdValues = [];
  final List<String> _summaryValues = [];
  Duration? _footerLowestRepeatable;

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

  void _updateFooterTotals() {
    final int currentLapCount = _rows.fold<int>(
        0, // Start with 0 if no rows or no times
        (maxVal, row) => (row['times'] as List<Duration>).length > maxVal
            ? (row['times'] as List<Duration>).length
            : maxVal);
    if (currentLapCount == 0) {
      _footerLapTotals = [];
      return;
    }
    _footerLapTotals = List<Duration>.generate(currentLapCount, (i) {
      return _rows.fold(Duration.zero, (sum, row) {
        final times = row['times'] as List<Duration>;
        return i < times.length ? sum + times[i] : sum;
      });
    });
  }

  void updateFooterLowestRepeatables() {
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
  }

  void unhideOvrdColumn() {
    setState(() {});
  }

  void showFooterLowestRepeatables() {
    setState(() {
      updateFooterLowestRepeatables();
      // Calculate lowest repeatable for total lap (footer)
      if (_footerLapTotals.isNotEmpty) {
        final roundedTotals = _footerLapTotals
            .map((t) => Duration(seconds: (t.inMilliseconds / 1000).round()))
            .toList();
        final counts = <Duration, int>{};
        for (final t in roundedTotals) {
          counts[t] = (counts[t] ?? 0) + 1;
        }
        final sorted = roundedTotals.toSet().toList()..sort();
        _footerLowestRepeatable = sorted
            .cast<Duration?>()
            .firstWhere((t) => counts[t]! >= 2, orElse: () => null);
      } else {
        _footerLowestRepeatable = null;
      }
    });
  }

  String timeToString(Duration time) {
    final h = time.inHours;
    final m = time.inMinutes.remainder(60);
    final s = time.inSeconds.remainder(60);
    return [
      if (h > 0) h.toString().padLeft(2, '0'),
      m.toString().padLeft(2, '0'),
      s.toString().padLeft(2, '0')
    ].join(':');
  }

  void storeTableDataGlobally() {
    globalTableData = List<Map<String, dynamic>>.from(_rows.map((row) => {
          'element': row['element'],
          'times': List<Duration>.from(row['times']),
          'comments': row['comments'],
          'lowestRepeatable': row['lowestRepeatable'],
        }));
  }

  @override
  Widget build(BuildContext context) {
    final displayLapCount = _rows.fold<int>(
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
            color: Colors.black.withValues(alpha: 0.12),
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
              columnSpacing: 0.0,
              horizontalMargin: 0.0,
              dividerThickness: 1.0,
              headingRowColor: WidgetStateProperty.all(Colors.yellow[200]),
              columns: [
                DataColumn(
                    label: Container(
                        width: _firstColumnWidth, // Use reduced width
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: const Text('#',
                            style: TextStyle(fontWeight: FontWeight.bold)))),
                DataColumn(
                    label: Container(
                        width: _lapColumnWidth, // Reduced width for Lap columns
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: const Text('Element',
                            style: TextStyle(fontWeight: FontWeight.bold)))),
                ...List.generate(
                  displayLapCount, // Use calculated displayLapCount
                  (lapIdx) => DataColumn(
                    label: Container(
                        width: _lapColumnWidth,
                        alignment: Alignment.center, // Already centered
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Text('Lap${lapIdx + 1}',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold))),
                  ),
                ),
                DataColumn(
                    label: Container(
                        width: _columnWidth * 1.1, // 10% wider
                        alignment: Alignment.center, // Already centered
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: const Text(
                          'Lowest Repeatable',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                          softWrap: true,
                          maxLines: 2,
                        ))),
                DataColumn(
                    label: Container(
                        width: _commentsColumnWidth, // Use doubled width
                        alignment: Alignment
                            .center, // Changed from centerLeft to center
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: const Text('Comments',
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                            softWrap: true,
                            maxLines: 2))),
              ],
              rows: List<DataRow>.generate(
                _rows.length,
                (rowIdx) {
                  final row = _rows[rowIdx];
                  _elementControllers.putIfAbsent(rowIdx,
                      () => TextEditingController(text: row['element'] ?? ''));
                  _elementFocusNodes.putIfAbsent(rowIdx, () => FocusNode());
                  _commentsControllers.putIfAbsent(rowIdx,
                      () => TextEditingController(text: row['comments'] ?? ''));
                  _lowestRepeatableControllers.putIfAbsent(
                      rowIdx,
                      () => TextEditingController(
                          text: row['lowestRepeatable'] == 'N/A'
                              ? ''
                              : (row['lowestRepeatable']?.toString() ?? '')));
                  final controller = _elementControllers[rowIdx]!;
                  final focusNode = _elementFocusNodes[rowIdx]!;
                  final commentsController = _commentsControllers[rowIdx]!;
                  final lowestRepeatableController =
                      _lowestRepeatableControllers[rowIdx]!;
                  if (controller.text != (row['element'] ?? '')) {
                    controller.text = row['element'] ?? '';
                    controller.selection = TextSelection.fromPosition(
                        TextPosition(offset: controller.text.length));
                  }
                  if (commentsController.text != (row['comments'] ?? '')) {
                    commentsController.text = row['comments'] ?? '';
                  }
                  if (lowestRepeatableController.text !=
                      (row['lowestRepeatable'] == 'N/A'
                          ? ''
                          : (row['lowestRepeatable']?.toString() ?? ''))) {
                    lowestRepeatableController.text =
                        row['lowestRepeatable'] == 'N/A'
                            ? ''
                            : (row['lowestRepeatable']?.toString() ?? '');
                  }
                  if (_focusRowIndex == rowIdx) {
                    Future.delayed(Duration.zero, () {
                      if (!mounted) return;
                      FocusScope.of(context).requestFocus(focusNode);
                      _focusRowIndex = null;
                    });
                  }
                  return DataRow(
                    cells: [
                      DataCell(Container(
                        width: _firstColumnWidth, // Use reduced width
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          color: Colors.transparent,
                        ),
                        child: Text('${rowIdx + 1}'),
                      )),
                      DataCell(
                        Container(
                          width: _columnWidth, // Standard width
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4.0), // Keep padding for TextField
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            color: Colors.white,
                          ),
                          child: TextField(
                            controller: controller,
                            focusNode: focusNode,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Enter element',
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 8),
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
                                _updateFooterTotals();
                              });
                            },
                            onChanged: (value) {
                              row['element'] = value;
                            },
                          ),
                        ),
                      ),
                      ...List.generate(displayLapCount, (lapIdx) {
                        // Use displayLapCount
                        final times = row['times'] as List<Duration>;
                        final hasValue = lapIdx < times.length;
                        return DataCell(
                          Container(
                            width: _lapColumnWidth,
                            alignment: Alignment.center,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              color: Colors.transparent,
                            ),
                            child: Text(
                              hasValue ? timeToString(times[lapIdx]) : '',
                              style: TextStyle(
                                color: hasValue ? Colors.black : Colors.grey,
                              ),
                            ),
                          ),
                        );
                      }),
                      DataCell(
                        (row['lowestRepeatable'] == null ||
                                row['lowestRepeatable'] == '' ||
                                row['lowestRepeatable'] == 'N/A')
                            ? Container(
                                width: _columnWidth,
                                alignment: Alignment.center,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4.0),
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                  color: Colors.white,
                                ),
                                child: TextField(
                                  controller: lowestRepeatableController,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Enter time',
                                    isDense: true,
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: 8),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      row['lowestRepeatable'] = value;
                                    });
                                  },
                                ),
                              )
                            : Container(
                                width: _columnWidth,
                                alignment: Alignment.center,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4.0),
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                  color: Colors.transparent,
                                ),
                                child: Text(
                                  row['lowestRepeatable'] is Duration
                                      ? timeToString(
                                          row['lowestRepeatable'] as Duration)
                                      : (row['lowestRepeatable']?.toString() ??
                                          ''),
                                ),
                              ),
                      ),
                      DataCell(
                        Container(
                          width: _commentsColumnWidth, // Use doubled width
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            color: Colors.white,
                          ),
                          child: TextField(
                            controller: commentsController,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Enter comment',
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 8),
                            ),
                            onChanged: (value) {
                              setState(() {
                                row['comments'] = value;
                              });
                            },
                          ),
                        ),
                      ),
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
                0: const FixedColumnWidth(_firstColumnWidth +
                    _columnWidth), // Merged: reduced first col + standard second col
                for (int i = 0; i < displayLapCount; i++)
                  1 + i: const FixedColumnWidth(
                      _lapColumnWidth), // Lap columns (index shifted)
                1 + displayLapCount: const FixedColumnWidth(
                    _columnWidth), // Lowest Repeatable (index shifted)
                2 + displayLapCount: const FixedColumnWidth(
                    _commentsColumnWidth), // Comments (index shifted, use doubled width)
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                TableRow(
                  children: [
                    // Merged Cell for first two columns ('#' and 'Element')
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Container(
                        width: _firstColumnWidth +
                            _columnWidth, // Span updated first and second column widths
                        decoration: BoxDecoration(
                          color: Colors
                              .yellow[300], // Color for the 'Total Lap' cell
                          border: const Border(
                            top: BorderSide(color: Colors.black26),
                            // No right border here if it's the start of a visually merged cell group
                            // but if it should look like one wide cell with a right border, add it.
                            // For now, assume it's part of the continuous row look.
                            //right: BorderSide(color: Colors.black26), // Keep right border for the merged cell
                          ),
                        ),
                        alignment:
                            Alignment.centerRight, // Right-align the text
                        height: 40,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0), // Standard padding
                        child: const Text(
                          'Total Lap',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    // Lap columns (indices are effectively shifted due to the merge)
                    ...List.generate(displayLapCount, (lapIdx) {
                      return TableCell(
                        child: Container(
                          width: _columnWidth, // Ensure width consistency
                          decoration: BoxDecoration(
                            color: Colors.yellow[100],
                            border: const Border(
                              top: BorderSide(color: Colors.black26),
                              right: BorderSide(color: Colors.black26),
                            ),
                          ),
                          alignment: Alignment.center,
                          height: 40,
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            _footerLapTotals.length > lapIdx &&
                                    _footerLapTotals[lapIdx] != Duration.zero
                                ? timeToString(_footerLapTotals[lapIdx])
                                : '',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    }),
                    // Empty cell for 'Lowest Repeatable'
                    TableCell(
                      child: _footerLowestRepeatable == null
                          ? Container(
                              width: _columnWidth * 1.1, // Match header width
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                border: Border(
                                  top: BorderSide(color: Colors.black26),
                                  right: BorderSide(color: Colors.black26),
                                ),
                              ),
                              height: 40,
                              alignment: Alignment.center,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: TextField(
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Enter time',
                                  isDense: true,
                                  contentPadding:
                                      EdgeInsets.symmetric(vertical: 8),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    // Store as string for footer lowest repeatable if needed
                                    // You may want to parse/validate as needed
                                  });
                                },
                              ),
                            )
                          : Container(
                              width: _columnWidth * 1.1, // Match header width
                              decoration: BoxDecoration(
                                color: Colors.yellow[100],
                                border: const Border(
                                  top: BorderSide(color: Colors.black26),
                                  right: BorderSide(color: Colors.black26),
                                ),
                              ),
                              height: 40,
                              alignment: Alignment.center,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text(
                                timeToString(_footerLowestRepeatable!),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                    ),
                    // Empty cell for 'Comments'
                    TableCell(
                      child: Container(
                        width: _commentsColumnWidth, // Use doubled width
                        decoration: BoxDecoration(
                          color:
                              Colors.yellow[300], // Match Total Lap cell color
                          border: const Border(
                            top: BorderSide(color: Colors.black26),
                            // No right border for the last cell in the row
                          ),
                        ),
                        height: 40,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: const Text(''),
                      ),
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

  void hideRowsWithoutElement() {
    setState(() {
      _rows.removeWhere((row) => (row['element'] as String).trim().isEmpty);
      // Clean up controllers and focus nodes for removed rows
      final validIndices = List.generate(_rows.length, (i) => i);
      _elementControllers.removeWhere((key, _) => !validIndices.contains(key));
      _elementFocusNodes.removeWhere((key, _) => !validIndices.contains(key));
      _updateFooterTotals();
    });
  }

  void enterLowestRepeatedIntoTimeColumn() {
    setState(() {
      updateFooterLowestRepeatables();
    });
  }
}
