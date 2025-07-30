import 'package:flutter/material.dart';
import '../database_provider.dart';
import '../logic/app_database.dart';
import '../models/process_object.dart';
import '../widgets/draggable_process_widget.dart';
import '../widgets/home_button_wrapper.dart';

class ProcessCanvasScreen extends StatefulWidget {
  final int valueStreamId;
  final String valueStreamName;

  const ProcessCanvasScreen({
    super.key,
    required this.valueStreamId,
    required this.valueStreamName,
  });

  @override
  State<ProcessCanvasScreen> createState() => _ProcessCanvasScreenState();
}

class _ProcessCanvasScreenState extends State<ProcessCanvasScreen> {
  List<ProcessObject> processes = [];
  ProcessObject? selectedProcess;
  bool isLoading = true;
  late AppDatabase db;

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    db = await DatabaseProvider.getInstance();
    await _loadProcesses();
  }

  Future<void> _loadProcesses() async {
    setState(() {
      isLoading = true;
    });

    try {
      final processEntries =
          await db.getProcessesForValueStream(widget.valueStreamId);

      // Get selected part number from shared preferences
      final partNumber = await db.getSelectedPartNumber();

      List<ProcessObject> processObjects = [];

      for (final processEntry in processEntries) {
        ProcessPart? processPart;
        String? calculatedCycleTime;

        if (partNumber != null) {
          processPart = await db.getProcessPartByPartNumberAndProcessId(
              partNumber, processEntry.id);
        }

        // Calculate average cycle time from all ProcessParts for this process
        calculatedCycleTime =
            await db.calculateAverageCycleTimeForProcess(processEntry.id);

        final processObjectData = ProcessObjectData(
          process: processEntry,
          processPart: processPart,
          calculatedCycleTime: calculatedCycleTime,
        );

        var processObject = ProcessObject.fromProcessData(processObjectData);

        // Ensure processes have valid positions - if they're at default (100,100) or invalid positions,
        // place them in a grid pattern to make them visible
        if (processObject.position.dx < 0 ||
            processObject.position.dy < 0 ||
            (processObject.position.dx == 100 &&
                processObject.position.dy == 100)) {
          final index = processObjects.length;
          final gridX = 50 + (index % 3) * 250; // 3 columns
          final gridY = 50 + (index ~/ 3) * 350; // New row every 3 processes

          processObject = processObject.copyWith(
              position: Offset(gridX.toDouble(), gridY.toDouble()));

          // Update the database with the new position
          await db.updateProcessPosition(
            processObject.id,
            processObject.position.dx,
            processObject.position.dy,
          );
        }

        processObjects.add(processObject);
      }

      setState(() {
        processes = processObjects;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading processes: $e')),
        );
      }
    }
  }

  Future<void> _updateProcessPositionFromGlobal(ProcessObject process,
      Offset globalOffset, BoxConstraints constraints) async {
    try {
      // Convert global position to local canvas coordinates
      final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
      if (renderBox == null) return;

      final localOffset = renderBox.globalToLocal(globalOffset);

      // Apply boundary checking to keep objects within the canvas
      final processWidth = process.size.width;
      final processHeight = process.size.height;

      double newX =
          localOffset.dx.clamp(0, constraints.maxWidth - processWidth);
      double newY =
          localOffset.dy.clamp(0, constraints.maxHeight - processHeight);

      final boundedPosition = Offset(newX, newY);

      await db.updateProcessPosition(
        process.id,
        boundedPosition.dx,
        boundedPosition.dy,
      );

      setState(() {
        final index = processes.indexWhere((p) => p.id == process.id);
        if (index != -1) {
          processes[index] = process.copyWith(
            position: boundedPosition,
          );
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating process position: $e')),
        );
      }
    }
  }

  Future<void> _updateProcessPosition(
      ProcessObject process, Offset newPosition) async {
    try {
      await db.updateProcessPosition(
        process.id,
        newPosition.dx,
        newPosition.dy,
      );

      setState(() {
        final index = processes.indexWhere((p) => p.id == process.id);
        if (index != -1) {
          processes[index] = process.copyWith(
            position: newPosition,
          );
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating process position: $e')),
        );
      }
    }
  }

  Future<void> _resetProcessPositions() async {
    try {
      setState(() {
        isLoading = true;
      });

      // Reset all process positions to a grid layout
      for (int i = 0; i < processes.length; i++) {
        final process = processes[i];
        final gridX = 50 + (i % 3) * 250; // 3 columns
        final gridY = 50 + (i ~/ 3) * 350; // New row every 3 processes

        final newPosition = Offset(gridX.toDouble(), gridY.toDouble());

        // Update database
        await db.updateProcessPosition(
          process.id,
          newPosition.dx,
          newPosition.dy,
        );

        // Update local state
        processes[i] = process.copyWith(position: newPosition);
      }

      setState(() {
        isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Reset ${processes.length} process positions to grid layout')),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error resetting positions: $e')),
        );
      }
    }
  }

  void _selectProcess(ProcessObject? process) {
    setState(() {
      selectedProcess = process;
    });
  }

  Future<void> _showProcessOptions(ProcessObject process) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Process'),
                onTap: () => Navigator.pop(context, 'edit'),
              ),
              ListTile(
                leading: const Icon(Icons.palette),
                title: const Text('Change Color'),
                onTap: () => Navigator.pop(context, 'color'),
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Delete Process'),
                onTap: () => Navigator.pop(context, 'delete'),
              ),
            ],
          ),
        );
      },
    );

    if (result != null) {
      switch (result) {
        case 'edit':
          _showEditProcessDialog(process);
          break;
        case 'color':
          _showColorPicker(process);
          break;
        case 'delete':
          _showDeleteConfirmation(process);
          break;
      }
    }
  }

  Future<void> _showEditProcessDialog(ProcessObject process) async {
    final nameController = TextEditingController(text: process.name);
    final descriptionController =
        TextEditingController(text: process.description);
    final staffController =
        TextEditingController(text: process.staff?.toString() ?? '');
    final dailyDemandController =
        TextEditingController(text: process.dailyDemand?.toString() ?? '');
    final wipController =
        TextEditingController(text: process.wip?.toString() ?? '');
    final uptimeController = TextEditingController(
        text: process.uptime != null
            ? (process.uptime! * 100).toStringAsFixed(1)
            : '');
    final coTimeController = TextEditingController(text: process.coTime ?? '');
    final cycleTimeController =
        TextEditingController(text: process.cycleTime ?? '');
    final fpyController = TextEditingController(
        text:
            process.fpy != null ? (process.fpy! * 100).toStringAsFixed(1) : '');

    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Process'),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Process Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: staffController,
                          decoration: const InputDecoration(
                            labelText: 'Staffing',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: dailyDemandController,
                          decoration: const InputDecoration(
                            labelText: 'Daily Demand',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: wipController,
                          decoration: const InputDecoration(
                            labelText: 'WIP',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: uptimeController,
                          decoration: const InputDecoration(
                            labelText: 'Uptime %',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: coTimeController,
                          decoration: const InputDecoration(
                            labelText: 'Changeover Time (HH:MM:SS)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: cycleTimeController,
                          decoration: const InputDecoration(
                            labelText: 'Cycle Time (HH:MM:SS)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: fpyController,
                    decoration: const InputDecoration(
                      labelText: 'FPY %',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await _updateProcess(
        process,
        name: nameController.text.trim(),
        description: descriptionController.text.trim(),
        staff: int.tryParse(staffController.text.trim()),
        dailyDemand: int.tryParse(dailyDemandController.text.trim()),
        wip: int.tryParse(wipController.text.trim()),
        uptime: double.tryParse(uptimeController.text.trim()),
        coTime: coTimeController.text.trim().isEmpty
            ? null
            : coTimeController.text.trim(),
        cycleTime: cycleTimeController.text.trim().isEmpty
            ? null
            : cycleTimeController.text.trim(),
        fpy: double.tryParse(fpyController.text.trim()),
      );
    }
  }

  Future<void> _showColorPicker(ProcessObject process) async {
    final colors = [
      Colors.blue[100]!,
      Colors.green[100]!,
      Colors.orange[100]!,
      Colors.purple[100]!,
      Colors.pink[100]!,
      Colors.teal[100]!,
      Colors.amber[100]!,
      Colors.cyan[100]!,
    ];

    final selectedColor = await showDialog<Color>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose Color'),
          content: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: colors.map((color) {
              return GestureDetector(
                onTap: () => Navigator.pop(context, color),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );

    if (selectedColor != null) {
      await _updateProcess(process, color: selectedColor);
    }
  }

  Future<void> _showDeleteConfirmation(ProcessObject process) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Process'),
          content: Text('Are you sure you want to delete "${process.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await _deleteProcess(process);
    }
  }

  Future<void> _updateProcess(
    ProcessObject process, {
    String? name,
    String? description,
    Color? color,
    int? staff,
    int? dailyDemand,
    int? wip,
    double? uptime,
    String? coTime,
    String? cycleTime,
    double? fpy,
  }) async {
    try {
      String? colorHex;
      if (color != null) {
        colorHex = '#${color.value.toRadixString(16).padLeft(8, '0')}';
      }

      // Convert uptime from percentage to decimal
      double? uptimeDecimal;
      if (uptime != null) {
        uptimeDecimal = uptime / 100.0;
      }

      // Convert FPY from percentage to decimal
      double? fpyDecimal;
      if (fpy != null) {
        fpyDecimal = fpy / 100.0;
      }

      // Update process table
      await db.updateProcess(
        process.id,
        name: name,
        description: description,
        colorHex: colorHex,
        staff: staff,
        dailyDemand: dailyDemand,
        wip: wip,
        uptime: uptimeDecimal,
        coTime: coTime,
      );

      // Update process part table if we have process part data and part number
      if (cycleTime != null || fpy != null) {
        final partNumber = await db.getSelectedPartNumber();
        if (partNumber != null) {
          await db.updateProcessPart(
            partNumber,
            process.id,
            cycleTime: cycleTime,
            fpy: fpyDecimal,
          );
        }
      }

      // Reload processes to get updated data
      await _loadProcesses();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Process updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating process: $e')),
        );
      }
    }
  }

  Future<void> _deleteProcess(ProcessObject process) async {
    try {
      await db.deleteProcess(process.id);

      setState(() {
        processes.removeWhere((p) => p.id == process.id);
        if (selectedProcess?.id == process.id) {
          selectedProcess = null;
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Process deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting process: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return HomeButtonWrapper(
      child: Scaffold(
        appBar: AppBar(
          title: Text('${widget.valueStreamName} - Process Canvas'),
          backgroundColor: Colors.grey[100],
          actions: [
            IconButton(
              icon: const Icon(Icons.grid_view),
              onPressed: _resetProcessPositions,
              tooltip: 'Reset Positions',
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadProcesses,
              tooltip: 'Refresh',
            ),
          ],
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : processes.isEmpty
                ? const Center(
                    child: Text(
                      'No processes found.\nAdd processes in the Value Stream Details screen.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      return GestureDetector(
                        onTap: () => _selectProcess(
                            null), // Deselect when tapping empty space
                        child: DragTarget<ProcessObject>(
                          onAcceptWithDetails: (details) {
                            // Handle drops on the canvas background
                            final RenderBox? renderBox =
                                context.findRenderObject() as RenderBox?;
                            if (renderBox != null) {
                              final localOffset =
                                  renderBox.globalToLocal(details.offset);
                              _updateProcessPosition(details.data, localOffset);
                            }
                          },
                          builder: (context, candidateData, rejectedData) {
                            return Stack(
                              children: [
                                // Canvas background
                                Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  color: Colors.grey[50],
                                  child: CustomPaint(
                                    painter: GridPainter(),
                                  ),
                                ),
                                // Process widgets
                                ...processes.map((process) {
                                  return DraggableProcessWidget(
                                    key: ValueKey(process.id),
                                    process: process,
                                    isSelected:
                                        selectedProcess?.id == process.id,
                                    onTap: () => _selectProcess(process),
                                    onDragEnd: (globalOffset) {
                                      _updateProcessPositionFromGlobal(
                                          process, globalOffset, constraints);
                                    },
                                  );
                                }),
                                // Selected process options
                                if (selectedProcess != null)
                                  Positioned(
                                    top: 16,
                                    right: 16,
                                    child: Card(
                                      elevation: 4,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              selectedProcess!.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            ElevatedButton.icon(
                                              onPressed: () =>
                                                  _showProcessOptions(
                                                      selectedProcess!),
                                              icon: const Icon(Icons.settings),
                                              label: const Text('Options'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.yellow[600],
                                                foregroundColor: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 0.5;

    const gridSize = 20.0;

    // Draw vertical lines
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Draw horizontal lines
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
