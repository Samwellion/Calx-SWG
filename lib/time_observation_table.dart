// time_observation_table.dart
import 'package:flutter/material.dart';
import 'global_table_data.dart';

class TimeObservationTable extends StatefulWidget {
  const TimeObservationTable({super.key});

  @override
  State<TimeObservationTable> createState() => TimeObservationTableState();
}

class TimeObservationTableState extends State<TimeObservationTable> {
  // Hide rows where the 'element' is empty
  void hideRowsWithoutElement() {
    setState(() {
      _rows.removeWhere((row) => (row['element'] == null ||
          (row['element'] as String).trim().isEmpty));
      if (_rows.isEmpty) {
        _rows.add({'element': '', 'times': <Duration>[]});
      }
    });
  }

  // Set elements from setup selection
  void setElements(List<String> elements) {
    setState(() {
      _rows.clear();
      for (final e in elements) {
        _rows.add({'element': e, 'times': <Duration>[]});
      }
      if (_rows.isEmpty) {
        _rows.add({'element': '', 'times': <Duration>[]});
      }
      _elementControllers.clear();
      _elementFocusNodes.clear();
      _commentsControllers.clear();
      _lowestRepeatableControllers.clear();
    });
  }

  // Get observed times data for saving
  List<Map<String, dynamic>> getObservedTimesData() {
    List<Map<String, dynamic>> data = [];
    for (final row in _rows) {
      final element = row['element'] as String;
      final times = row['times'] as List<Duration>;

      if (element.isNotEmpty && times.isNotEmpty) {
        // Calculate the average time or use the lowest repeatable time
        Duration observedTime = Duration.zero;
        if (times.isNotEmpty) {
          // Use the shortest time as the observed time (common practice in time studies)
          observedTime = times.reduce((a, b) => a < b ? a : b);
        }

        data.add({
          'elementName': element,
          'observedTime': _formatDuration(observedTime),
          'times': times.map((t) => _formatDuration(t)).toList(),
        });
      }
    }
    return data;
  }

  // Helper method to format duration to HH:MM:SS string
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  static const double _columnWidth = 120.0;
  static const double _lapColumnWidth = _columnWidth * 0.8;
  static const double _firstColumnWidth = _columnWidth * 0.4;
  static const double _elementsColumnWidth = _columnWidth * 2;
  static const double _commentsColumnWidth = _columnWidth * 2;

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
  late TextEditingController _totalLapLowestRepeatableController;
  bool _editingEnabled = false; // Track if editing is enabled after stop

  @override
  void initState() {
    super.initState();
    _totalLapLowestRepeatableController = TextEditingController();
  }

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
    _totalLapLowestRepeatableController.dispose();
    super.dispose();
  }

  // Enable editing mode for lowest repeatable cells
  void enableLowestRepeatableEditing() {
    setState(() {
      _editingEnabled = true;
    });
  }

  // Disable editing mode for lowest repeatable cells
  void disableLowestRepeatableEditing() {
    setState(() {
      _editingEnabled = false;
    });
  }

  int? _focusRowIndex;
  List<Duration> _footerLapTotals = [];
  final List<String> _ovrdValues = [];
  final List<String> _summaryValues = [];
  bool _showTotalRow = false;
  Duration? _totalLapLowestRepeatable;

  void showTotalRow() {
    setState(() {
      _showTotalRow = true;
    });
  }

  void hideTotalRow() {
    setState(() {
      _showTotalRow = false;
    });
  }

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
      _showTotalRow = false;
      _totalLapLowestRepeatable = null;

      for (final controller in _lowestRepeatableControllers.values) {
        controller.clear();
      }
    });
  }

  void _updateFooterTotals() {
    final int currentLapCount = _rows.fold<int>(
        0,
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

        final sortedUniqueTimes = roundedTimes.toSet().toList()..sort();
        Duration? lowestRepeatable;

        for (final time in sortedUniqueTimes) {
          if (counts[time]! >= 2) {
            lowestRepeatable = time;
            break;
          }
        }

        row['lowestRepeatable'] = lowestRepeatable;
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
      if (_footerLapTotals.isNotEmpty) {
        final roundedTotals = _footerLapTotals
            .map((t) => Duration(seconds: (t.inMilliseconds / 1000).round()))
            .toList();
        final counts = <Duration, int>{};
        for (final t in roundedTotals) {
          counts[t] = (counts[t] ?? 0) + 1;
        }

        final sortedUniqueTotals = roundedTotals.toSet().toList()..sort();
        Duration? totalLapLowestRepeatable;

        for (final time in sortedUniqueTotals) {
          if (counts[time]! >= 2) {
            totalLapLowestRepeatable = time;
            break;
          }
        }

        _totalLapLowestRepeatable = totalLapLowestRepeatable;
      } else {
        _totalLapLowestRepeatable = null;
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
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 0.0,
                  horizontalMargin: 0.0,
                  dividerThickness: 1.0,
                  dataRowMinHeight: 48.0,
                  dataRowMaxHeight: double.infinity,
                  headingRowColor: WidgetStateProperty.all(Colors.yellow[200]),
                  columns: [
                    DataColumn(
                        label: Container(
                            width: _firstColumnWidth,
                            alignment: Alignment.center,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                            child: const Text('#',
                                style:
                                    TextStyle(fontWeight: FontWeight.bold)))),
                    DataColumn(
                        label: Container(
                            width: _elementsColumnWidth,
                            alignment: Alignment.center,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                            child: const Text('Element',
                                style:
                                    TextStyle(fontWeight: FontWeight.bold)))),
                    ...List.generate(
                      displayLapCount,
                      (lapIdx) => DataColumn(
                        label: Container(
                            width: _lapColumnWidth,
                            alignment: Alignment.center,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                            child: Text('Lap${lapIdx + 1}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold))),
                      ),
                    ),
                    DataColumn(
                        label: Container(
                            width: _columnWidth * 1.1,
                            alignment: Alignment.center,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                            child: const Text('Lowest Repeatable',
                                style: TextStyle(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                                softWrap: true,
                                maxLines: 2))),
                    DataColumn(
                        label: Container(
                            width: _commentsColumnWidth,
                            alignment: Alignment.center,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                            child: const Text('Comments',
                                style: TextStyle(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                                softWrap: true,
                                maxLines: 2))),
                  ],
                  rows: [
                    ...List<DataRow>.generate(
                      _rows.length,
                      (rowIdx) {
                        final row = _rows[rowIdx];
                        _elementControllers.putIfAbsent(
                            rowIdx,
                            () => TextEditingController(
                                text: row['element'] ?? ''));
                        _elementFocusNodes.putIfAbsent(
                            rowIdx, () => FocusNode());
                        _commentsControllers.putIfAbsent(
                            rowIdx,
                            () => TextEditingController(
                                text: row['comments'] ?? ''));
                        _lowestRepeatableControllers.putIfAbsent(
                            rowIdx,
                            () => TextEditingController(
                                text: row['lowestRepeatable'] is Duration
                                    ? timeToString(
                                        row['lowestRepeatable'] as Duration)
                                    : (row['lowestRepeatable']?.toString() ??
                                        '')));
                        final controller = _elementControllers[rowIdx]!;
                        final focusNode = _elementFocusNodes[rowIdx]!;
                        final commentsController =
                            _commentsControllers[rowIdx]!;
                        final lowestRepeatableController =
                            _lowestRepeatableControllers[rowIdx]!;
                        if (controller.text != (row['element'] ?? '')) {
                          controller.text = row['element'] ?? '';
                          controller.selection = TextSelection.fromPosition(
                              TextPosition(offset: controller.text.length));
                        }
                        if (commentsController.text !=
                            (row['comments'] ?? '')) {
                          commentsController.text = row['comments'] ?? '';
                        }
                        final expectedLowestText = row['lowestRepeatable']
                                is Duration
                            ? timeToString(row['lowestRepeatable'] as Duration)
                            : (row['lowestRepeatable']?.toString() ?? '');
                        if (lowestRepeatableController.text !=
                            expectedLowestText) {
                          lowestRepeatableController.text = expectedLowestText;
                        }
                        if (_focusRowIndex == rowIdx) {
                          Future.delayed(Duration.zero, () {
                            if (!mounted) return;
                            // ignore: use_build_context_synchronously
                            FocusScope.of(context).requestFocus(focusNode);
                            _focusRowIndex = null;
                          });
                        }
                        return DataRow(
                          cells: [
                            DataCell(Container(
                              width: _firstColumnWidth,
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4.0, vertical: 8.0),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                color: Colors.transparent,
                              ),
                              child: Text('${rowIdx + 1}'),
                            )),
                            DataCell(
                              Container(
                                width: _elementsColumnWidth,
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4.0, vertical: 8.0),
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                  color: Colors.white,
                                ),
                                child: TextField(
                                  controller: controller,
                                  focusNode: focusNode,
                                  maxLines: null,
                                  minLines: 1,
                                  textInputAction: TextInputAction.done,
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
                                        _rows.add({
                                          'element': '',
                                          'times': <Duration>[]
                                        });
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
                              final times = row['times'] as List<Duration>;
                              final hasValue = lapIdx < times.length;
                              return DataCell(
                                Container(
                                  width: _lapColumnWidth,
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4.0, vertical: 8.0),
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                    color: Colors.transparent,
                                  ),
                                  child: Text(
                                    hasValue ? timeToString(times[lapIdx]) : '',
                                    style: TextStyle(
                                      color:
                                          hasValue ? Colors.black : Colors.grey,
                                    ),
                                  ),
                                ),
                              );
                            }),
                            DataCell(
                              (row['lowestRepeatable'] == null &&
                                      _editingEnabled)
                                  ? Container(
                                      width: _columnWidth,
                                      alignment: Alignment.center,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4.0, vertical: 8.0),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.grey.shade300),
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
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4.0, vertical: 8.0),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.grey.shade300),
                                        color: Colors.green[50],
                                      ),
                                      child: Text(
                                        row['lowestRepeatable'] is Duration
                                            ? timeToString(
                                                row['lowestRepeatable']
                                                    as Duration)
                                            : (row['lowestRepeatable']
                                                    ?.toString() ??
                                                'N/A'),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: row['lowestRepeatable']
                                                  is Duration
                                              ? Colors.green[800]
                                              : Colors.grey[600],
                                        ),
                                      ),
                                    ),
                            ),
                            DataCell(
                              Container(
                                width: _commentsColumnWidth,
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4.0, vertical: 8.0),
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                  color: Colors.white,
                                ),
                                child: TextField(
                                  controller: commentsController,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Enter comment',
                                    isDense: true,
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: 8),
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
                    if (_showTotalRow) ...[
                      DataRow(
                        color: WidgetStateProperty.all(Colors.blue[50]),
                        cells: [
                          DataCell(
                            Container(
                              width: _firstColumnWidth,
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4.0, vertical: 8.0),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.blue.shade300),
                                color: Colors.blue[100],
                              ),
                            ),
                          ),
                          DataCell(
                            Container(
                              width: _elementsColumnWidth,
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4.0, vertical: 8.0),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.blue.shade300),
                                color: Colors.blue[100],
                              ),
                              child: const Text(
                                'Total Lap',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ),
                          ...List.generate(displayLapCount, (lapIdx) {
                            final hasTotal = lapIdx < _footerLapTotals.length;
                            return DataCell(
                              Container(
                                width: _lapColumnWidth,
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4.0, vertical: 8.0),
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.blue.shade300),
                                  color: Colors.blue[50],
                                ),
                                child: Text(
                                  hasTotal
                                      ? timeToString(_footerLapTotals[lapIdx])
                                      : '',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            );
                          }),
                          DataCell(
                            (_totalLapLowestRepeatable == null &&
                                    _editingEnabled)
                                ? Container(
                                    width: _columnWidth,
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4.0, vertical: 8.0),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.blue.shade300),
                                      color: Colors.white,
                                    ),
                                    child: TextField(
                                      controller:
                                          _totalLapLowestRepeatableController,
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        hintText: 'Enter time',
                                        isDense: true,
                                        contentPadding:
                                            EdgeInsets.symmetric(vertical: 8),
                                      ),
                                      onChanged: (value) {
                                        setState(() {
                                          if (value.isNotEmpty) {
                                            // Try to parse the time string
                                            try {
                                              final parts = value.split(':');
                                              if (parts.length >= 2) {
                                                final minutes =
                                                    int.parse(parts[0]);
                                                final seconds =
                                                    int.parse(parts[1]);
                                                _totalLapLowestRepeatable =
                                                    Duration(
                                                  minutes: minutes,
                                                  seconds: seconds,
                                                );
                                              }
                                            } catch (e) {
                                              // If parsing fails, keep the text value
                                            }
                                          } else {
                                            _totalLapLowestRepeatable = null;
                                          }
                                        });
                                      },
                                    ),
                                  )
                                : Container(
                                    width: _columnWidth,
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4.0, vertical: 8.0),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.blue.shade300),
                                      color: _totalLapLowestRepeatable != null
                                          ? Colors.green[50]
                                          : Colors.blue[50],
                                    ),
                                    child: Text(
                                      _totalLapLowestRepeatable != null
                                          ? timeToString(
                                              _totalLapLowestRepeatable!)
                                          : '',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: _totalLapLowestRepeatable != null
                                            ? Colors.green[800]
                                            : Colors.blue,
                                      ),
                                    ),
                                  ),
                          ),
                          DataCell(
                            Container(
                              width: _commentsColumnWidth,
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4.0, vertical: 8.0),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.blue.shade300),
                                color: Colors.blue[50],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
