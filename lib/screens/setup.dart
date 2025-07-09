import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift;
import '../widgets/home_header.dart';

import '../logic/app_database.dart';
import '../database_provider.dart';

class SetupScreen extends StatefulWidget {
  final String? companyName;
  final String? plantName;
  final String? valueStreamName;
  final String? processName;

  const SetupScreen({
    super.key,
    this.companyName,
    this.plantName,
    this.valueStreamName,
    this.processName,
  });

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  late AppDatabase db;
  List<String> partNumbers = [];
  String? selectedPartNumber;
  TextEditingController setupNameController = TextEditingController();
  bool dialogShown = false;
  int? processPartId;
  String? setupName;

  @override
  void initState() {
    super.initState();
    // Do not prefill setup name with process name; leave it empty for user input
    DatabaseProvider.getInstance().then((database) {
      db = database;
      _fetchPartNumbers();
    });
  }

  Future<void> _fetchPartNumbers() async {
    if (widget.processName == null) return;
    // Find process for the selected processName
    final process = await (db.select(db.processes)
          ..where((p) => p.processName.equals(widget.processName!)))
        .getSingleOrNull();
    if (process == null) return;
    // Get all part numbers for the value stream linked to this process
    final parts = await (db.select(db.parts)
          ..where((part) => part.valueStreamId.equals(process.valueStreamId)))
        .get();
    setState(() {
      partNumbers = parts.map((p) => p.partNumber).toList();
      if (partNumbers.isNotEmpty) {
        selectedPartNumber = partNumbers.first;
      }
    });
    // Show dialog after part numbers are loaded
    if (!dialogShown) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showSetupDialog());
      dialogShown = true;
    }
  }

  Future<void> _showSetupDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text('Setup for ${widget.processName ?? ''}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedPartNumber,
                items: partNumbers
                    .map((pn) => DropdownMenuItem(
                          value: pn,
                          child: Text(pn),
                        ))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    selectedPartNumber = val;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Part Number',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: setupNameController,
                decoration: const InputDecoration(
                  labelText: 'Setup Name',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                // On OK: ensure ProcessPart exists for process and part number, insert if not, and store id
                if (widget.processName == null || selectedPartNumber == null) {
                  Navigator.of(context).pop();
                  return;
                }
                final process = await (db.select(db.processes)
                      ..where((p) => p.processName.equals(widget.processName!)))
                    .getSingleOrNull();
                if (process == null) {
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pop();
                  return;
                }
                final existing = await (db.select(db.processParts)
                      ..where((pp) =>
                          pp.processId.equals(process.id) &
                          pp.partNumber.equals(selectedPartNumber!)))
                    .getSingleOrNull();
                int id;
                if (existing != null) {
                  id = existing.id;
                } else {
                  id = await db.into(db.processParts).insert(
                        ProcessPartsCompanion(
                          partNumber: drift.Value(selectedPartNumber!),
                          processId: drift.Value(process.id),
                        ),
                      );
                }
                setState(() {
                  processPartId = id;
                  setupName = setupNameController.text;
                });
                // ignore: use_build_context_synchronously
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[100],
      body: Column(
        children: [
          HomeHeader(
            companyName: widget.companyName,
            plantName: widget.plantName,
            valueStreamName: widget.valueStreamName,
            processName: widget.processName,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 24.0, left: 24.0, right: 24.0, bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (selectedPartNumber != null)
                  Text('Part Number: $selectedPartNumber', style: const TextStyle(fontSize: 18)),
                if (selectedPartNumber != null && processPartId != null)
                  const SizedBox(width: 32),
                if (processPartId != null)
                  Text('Process Part ID: $processPartId', style: const TextStyle(fontSize: 18)),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (setupName != null)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Setup Name: $setupName',
                          style: const TextStyle(fontSize: 20)),
                    ),
                ],
              ),
            ),
          ),
          // Replace AppFooter with a valid widget or ensure AppFooter is defined in app_footer.dart
          SizedBox(height: 50), // Placeholder for footer
        ],
      ),
    );
  }
}
