import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift;
import '../logic/app_database.dart';
import '../database_provider.dart';

class ElementListCard extends StatefulWidget {
  final int? processPartId;
  final String? setupName;
  final VoidCallback? onElementChanged; // Callback to notify parent of changes

  const ElementListCard({
    super.key,
    required this.processPartId,
    required this.setupName,
    this.onElementChanged,
  });

  @override
  State<ElementListCard> createState() => _ElementListCardState();
}

class _ElementListCardState extends State<ElementListCard> {
  late AppDatabase db;
  List<SetupElement> setupElements = [];
  bool loadingElements = false;
  Map<int, String> elementNameEdits = {};
  Map<int, String> timeEdits = {};
  Map<int, bool> editingStates = {};

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  @override
  void didUpdateWidget(ElementListCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Refetch elements if the setup parameters changed
    if (oldWidget.processPartId != widget.processPartId ||
        oldWidget.setupName != widget.setupName) {
      _fetchSetupElements();
    }
  }

  Future<void> _initializeDatabase() async {
    try {
      db = await DatabaseProvider.getInstance();
      // Wait a moment to ensure the database is fully ready
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) {
        await _fetchSetupElements();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          setupElements = [];
          loadingElements = false;
        });
      }
    }
  }

  void _toggleEditing(int elementId, bool isEditing) {
    setState(() {
      editingStates[elementId] = isEditing;
      if (!isEditing) {
        elementNameEdits.remove(elementId);
        timeEdits.remove(elementId);
      }
    });
  }

  Future<void> _updateElement(SetupElement element) async {
    final updatedName = elementNameEdits[element.id] ?? element.elementName;
    final updatedTime = timeEdits[element.id] ?? element.time;

    await (db.update(db.setupElements)
          ..where((tbl) => tbl.id.equals(element.id)))
        .write(
      SetupElementsCompanion(
        elementName: drift.Value(updatedName),
        time: drift.Value(updatedTime),
      ),
    );
    _toggleEditing(element.id, false);
    await _fetchSetupElements();

    // Notify parent that elements have changed
    if (widget.onElementChanged != null) {
      widget.onElementChanged!();
    }
  }

  Future<void> _deleteElement(SetupElement element) async {
    await db.delete(db.setupElements).delete(element);
    await _fetchSetupElements();

    // Notify parent that elements have changed
    if (widget.onElementChanged != null) {
      widget.onElementChanged!();
    }
  }

  Future<void> _fetchSetupElements() async {
    if (widget.processPartId == null || widget.setupName == null) {
      if (mounted) {
        setState(() {
          setupElements = [];
          loadingElements = false;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        loadingElements = true;
      });
    }

    try {
      // First get the setup ID
      final setup = await (db.select(db.setups)
            ..where((setup) =>
                setup.processPartId.equals(widget.processPartId!) &
                setup.setupName.equals(widget.setupName!)))
          .getSingleOrNull();

      if (setup != null) {
        final elements = await (db.select(db.setupElements)
              ..where((tbl) =>
                  tbl.processPartId.equals(widget.processPartId!) &
                  tbl.setupId.equals(setup.id))
              ..orderBy([(tbl) => drift.OrderingTerm.asc(tbl.orderIndex)]))
            .get();

        if (mounted) {
          setState(() {
            setupElements = elements;
            loadingElements = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            setupElements = [];
            loadingElements = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          setupElements = [];
          loadingElements = false;
        });
      }
    }
  }

  Future<void> _onReorder(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    setState(() {
      final element = setupElements.removeAt(oldIndex);
      setupElements.insert(newIndex, element);
    });

    // Update the order in the database
    await _updateElementOrder();

    // Notify parent that elements have changed
    if (widget.onElementChanged != null) {
      widget.onElementChanged!();
    }
  }

  Future<void> _updateElementOrder() async {
    try {
      // Update each element's order index in the database
      for (int i = 0; i < setupElements.length; i++) {
        await (db.update(db.setupElements)
              ..where((tbl) => tbl.id.equals(setupElements[i].id)))
            .write(
          SetupElementsCompanion(
            orderIndex: drift.Value(i),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error updating element order: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.yellow[50],
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.setupName != null)
              loadingElements
                  ? const Center(child: CircularProgressIndicator())
                  : Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Text(
                              'Elements for Setup: ${widget.setupName}',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: setupElements.isEmpty
                                ? const Center(
                                    child: Text(
                                      'No elements added yet',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  )
                                : ReorderableListView.builder(
                                    itemCount: setupElements.length,
                                    onReorder: _onReorder,
                                    itemBuilder: (context, index) {
                                      final element = setupElements[index];
                                      return Card(
                                        key: ValueKey(element.id),
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 2.0, horizontal: 4.0),
                                        elevation: 2,
                                        color: Colors.yellow[100],
                                        child: ListTile(
                                          leading: ReorderableDragStartListener(
                                            index: index,
                                            child: const Icon(
                                              Icons.drag_handle,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          title: editingStates[element.id] ??
                                                  false
                                              ? TextFormField(
                                                  initialValue:
                                                      element.elementName,
                                                  onChanged: (value) {
                                                    elementNameEdits[
                                                        element.id] = value;
                                                  },
                                                  decoration:
                                                      const InputDecoration(
                                                    border:
                                                        OutlineInputBorder(),
                                                    isDense: true,
                                                  ),
                                                )
                                              : Text(
                                                  element.elementName,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                          subtitle: editingStates[element.id] ??
                                                  false
                                              ? TextFormField(
                                                  initialValue: element.time,
                                                  onChanged: (value) {
                                                    timeEdits[element.id] =
                                                        value;
                                                  },
                                                  decoration:
                                                      const InputDecoration(
                                                    border:
                                                        OutlineInputBorder(),
                                                    isDense: true,
                                                    labelText: 'Time',
                                                  ),
                                                )
                                              : Text(
                                                  'Time: ${element.time}',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              if (editingStates[element.id] ??
                                                  false)
                                                IconButton(
                                                  icon: const Icon(Icons.check,
                                                      color: Colors.green),
                                                  onPressed: () =>
                                                      _updateElement(element),
                                                )
                                              else
                                                IconButton(
                                                  icon: const Icon(Icons.edit,
                                                      color: Colors.blue),
                                                  onPressed: () =>
                                                      _toggleEditing(
                                                          element.id, true),
                                                ),
                                              IconButton(
                                                icon: const Icon(Icons.delete,
                                                    color: Colors.red),
                                                onPressed: () =>
                                                    _deleteElement(element),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
                    )
            else
              const Center(
                child: Text('Please complete setup to add elements.'),
              ),
          ],
        ),
      ),
    );
  }
}
