import 'package:flutter/material.dart';
import '../database_provider.dart';
import '../logic/app_database.dart';

class FullTreeItem {
  final String name;
  final TreeItemType type;
  final int? index; // Index in respective lists
  final String? parentName; // Name of parent item
  final int? id; // Database ID for value streams and processes

  FullTreeItem({
    required this.name,
    required this.type,
    this.index,
    this.parentName,
    this.id,
  });
}

enum TreeItemType {
  company,
  plant,
  valueStream,
  process,
}

/// A callback function that provides context about the selected item
typedef OnItemSelectedCallback = void Function({
  String? companyName,
  String? plantName,
  String? valueStreamName,
  String? processName,
  int? plantIndex,
  int? valueStreamId,
  int? processId,
});

/// A callback function for adding new items at different hierarchy levels
typedef OnAddItemCallback = void Function({
  TreeItemType itemType,
  String? companyName,
  String? plantName,
  String? valueStreamName,
  int? valueStreamId,
});

/// A comprehensive tree widget that displays the full organizational hierarchy:
/// Companies -> Plants -> Value Streams -> Processes
/// Users can navigate and select items at any level of the hierarchy.
class FullHierarchyTree extends StatefulWidget {
  /// Width of the tree widget. Defaults to 320.
  final double? width;

  /// Height of the tree widget. If null, uses intrinsic height.
  final double? height;

  /// Whether to show a header title. Defaults to true.
  final bool showHeader;

  /// Custom header text. Defaults to 'Full Hierarchy'.
  final String headerText;

  /// Whether tree nodes should be expanded by default. Defaults to false.
  final bool expandedByDefault;

  /// Callback when any item in the tree is selected
  final OnItemSelectedCallback? onItemSelected;

  /// Callback when user wants to add a new item at any level
  final OnAddItemCallback? onAddItem;

  /// Currently selected company name
  final String? selectedCompany;

  /// Currently selected plant name
  final String? selectedPlant;

  /// Currently selected value stream name
  final String? selectedValueStream;

  /// Currently selected process name
  final String? selectedProcess;

  const FullHierarchyTree({
    super.key,
    this.width,
    this.height,
    this.showHeader = true,
    this.headerText = 'Full Hierarchy',
    this.expandedByDefault = false,
    this.onItemSelected,
    this.onAddItem,
    this.selectedCompany,
    this.selectedPlant,
    this.selectedValueStream,
    this.selectedProcess,
  });

  @override
  State<FullHierarchyTree> createState() => _FullHierarchyTreeState();
}

class _FullHierarchyTreeState extends State<FullHierarchyTree> {
  List<FullTreeItem> _treeItems = [];
  final Map<String, bool> _expanded = {};
  bool _isLoading = true;

  // Cache for database data
  List<Organization> _organizations = [];
  List<PlantData> _plants = [];
  List<ValueStream> _valueStreams = [];
  List<ProcessesData> _processes = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didUpdateWidget(FullHierarchyTree oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedCompany != widget.selectedCompany ||
        oldWidget.selectedPlant != widget.selectedPlant ||
        oldWidget.selectedValueStream != widget.selectedValueStream ||
        oldWidget.selectedProcess != widget.selectedProcess) {
      _buildTreeItems();
    }
  }

  Future<void> _loadData() async {
    try {
      final db = await DatabaseProvider.getInstance();

      final organizations = await db.select(db.organizations).get();
      final plants = await db.select(db.plants).get();
      final valueStreams = await db.select(db.valueStreams).get();
      final processes = await db.select(db.processes).get();

      if (mounted) {
        setState(() {
          _organizations = organizations;
          _plants = plants;
          _valueStreams = valueStreams;
          _processes = processes;
          _isLoading = false;
        });
        _buildTreeItems();
      }
    } catch (e) {
      debugPrint('Error loading hierarchy data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _buildTreeItems() {
    final List<FullTreeItem> items = [];

    // Group data by hierarchy
    final sortedOrganizations = _organizations.toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    for (final org in sortedOrganizations) {
      final companyKey = 'company_${org.name}';

      // Add company
      items.add(FullTreeItem(
        name: org.name,
        type: TreeItemType.company,
        index: org.id,
      ));

      // Add plants under this company if expanded
      if (_expanded[companyKey] ?? widget.expandedByDefault) {
        final companyPlants = _plants
            .where((p) => p.organizationId == org.id)
            .toList()
          ..sort((a, b) => a.name.compareTo(b.name));
        for (final plant in companyPlants) {
          final plantKey = 'plant_${org.name}_${plant.name}';

          items.add(FullTreeItem(
            name: plant.name,
            type: TreeItemType.plant,
            index: plant.id,
            parentName: org.name,
          ));

          // Add value streams under this plant if expanded
          if (_expanded[plantKey] ?? widget.expandedByDefault) {
            final plantValueStreams = _valueStreams
                .where((vs) => vs.plantId == plant.id)
                .toList()
              ..sort((a, b) => a.name.compareTo(b.name));

            for (final valueStream in plantValueStreams) {
              final valueStreamKey =
                  'valuestream_${org.name}_${plant.name}_${valueStream.name}';

              items.add(FullTreeItem(
                name: valueStream.name,
                type: TreeItemType.valueStream,
                index: valueStream.id,
                parentName: plant.name,
                id: valueStream.id,
              ));

              // Add processes under this value stream if expanded
              if (_expanded[valueStreamKey] ?? widget.expandedByDefault) {
                final valueStreamProcesses = _processes
                    .where((p) => p.valueStreamId == valueStream.id)
                    .toList()
                  ..sort((a, b) => a.processName.compareTo(b.processName));

                for (final process in valueStreamProcesses) {
                  items.add(FullTreeItem(
                    name: process.processName,
                    type: TreeItemType.process,
                    index: process.id,
                    parentName: valueStream.name,
                    id: process.id,
                  ));
                }
              }
            }
          }
        }
      }
    }

    setState(() {
      _treeItems = items;
    });
  }

  void _toggleExpansion(String key) {
    setState(() {
      _expanded[key] = !(_expanded[key] ?? widget.expandedByDefault);
    });
    debugPrint('Toggled expansion for $key: ${_expanded[key]}');
    _buildTreeItems();
  }

  void _onItemTap(FullTreeItem item) {
    if (widget.onItemSelected == null) return;

    // Find the full hierarchy path for this item
    String? companyName;
    String? plantName;
    String? valueStreamName;
    String? processName;
    int? plantIndex;
    int? valueStreamId;
    int? processId;

    switch (item.type) {
      case TreeItemType.company:
        companyName = item.name;
        break;

      case TreeItemType.plant:
        companyName = item.parentName;
        plantName = item.name;
        plantIndex = item.index;
        break;

      case TreeItemType.valueStream:
        // Find plant and company for this value stream
        final valueStream =
            _valueStreams.where((vs) => vs.id == item.id).firstOrNull;
        if (valueStream != null) {
          final plant =
              _plants.where((p) => p.id == valueStream.plantId).firstOrNull;
          if (plant != null) {
            final org = _organizations
                .where((o) => o.id == plant.organizationId)
                .firstOrNull;
            if (org != null) {
              companyName = org.name;
              plantName = plant.name;
              valueStreamName = item.name;
              valueStreamId = item.id;
            }
          }
        }
        break;

      case TreeItemType.process:
        // Find value stream, plant, and company for this process
        final process = _processes.where((p) => p.id == item.id).firstOrNull;
        if (process != null) {
          final valueStream = _valueStreams
              .where((vs) => vs.id == process.valueStreamId)
              .firstOrNull;
          if (valueStream != null) {
            final plant =
                _plants.where((p) => p.id == valueStream.plantId).firstOrNull;
            if (plant != null) {
              final org = _organizations
                  .where((o) => o.id == plant.organizationId)
                  .firstOrNull;
              if (org != null) {
                companyName = org.name;
                plantName = plant.name;
                valueStreamName = valueStream.name;
                processName = item.name;
                valueStreamId = valueStream.id;
                processId = item.id;
              }
            }
          }
        }
        break;
    }

    widget.onItemSelected!(
      companyName: companyName,
      plantName: plantName,
      valueStreamName: valueStreamName,
      processName: processName,
      plantIndex: plantIndex,
      valueStreamId: valueStreamId,
      processId: processId,
    );
  }

  String _getItemKey(FullTreeItem item) {
    switch (item.type) {
      case TreeItemType.company:
        return 'company_${item.name}';
      case TreeItemType.plant:
        return 'plant_${item.parentName}_${item.name}';
      case TreeItemType.valueStream:
        // Find the plant name for this value stream
        final valueStream =
            _valueStreams.where((vs) => vs.id == item.id).firstOrNull;
        if (valueStream != null) {
          final plant =
              _plants.where((p) => p.id == valueStream.plantId).firstOrNull;
          if (plant != null) {
            final org = _organizations
                .where((o) => o.id == plant.organizationId)
                .firstOrNull;
            if (org != null) {
              return 'valuestream_${org.name}_${plant.name}_${item.name}';
            }
          }
        }
        return 'valuestream_unknown_${item.name}';
      case TreeItemType.process:
        // Find the value stream, plant, and company for this process
        final process = _processes.where((p) => p.id == item.id).firstOrNull;
        if (process != null) {
          final valueStream = _valueStreams
              .where((vs) => vs.id == process.valueStreamId)
              .firstOrNull;
          if (valueStream != null) {
            final plant =
                _plants.where((p) => p.id == valueStream.plantId).firstOrNull;
            if (plant != null) {
              final org = _organizations
                  .where((o) => o.id == plant.organizationId)
                  .firstOrNull;
              if (org != null) {
                return 'process_${org.name}_${plant.name}_${valueStream.name}_${item.name}';
              }
            }
          }
        }
        return 'process_unknown_${item.name}';
    }
  }

  bool _isItemSelected(FullTreeItem item) {
    switch (item.type) {
      case TreeItemType.company:
        return widget.selectedCompany == item.name;
      case TreeItemType.plant:
        return widget.selectedPlant == item.name;
      case TreeItemType.valueStream:
        return widget.selectedValueStream == item.name;
      case TreeItemType.process:
        // For processes, check both the process name AND the parent value stream
        return widget.selectedProcess == item.name &&
            widget.selectedValueStream == item.parentName;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        width: widget.width ?? 320,
        height: widget.height,
        decoration: BoxDecoration(
          color: Colors.yellow[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.yellow[300]!),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_treeItems.isEmpty) {
      return Container(
        width: widget.width ?? 320,
        height: widget.height,
        decoration: BoxDecoration(
          color: Colors.yellow[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.yellow[300]!),
        ),
        child: Column(
          children: [
            if (widget.showHeader)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.yellow[100],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(11),
                    topRight: Radius.circular(11),
                  ),
                ),
                child: Text(
                  widget.headerText,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            const Expanded(
              child: Center(
                child: Text(
                  'No data available',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: widget.width ?? 320,
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.yellow[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.yellow[300]!),
      ),
      child: Column(
        children: [
          // Header
          if (widget.showHeader)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.yellow[100],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(11),
                  topRight: Radius.circular(11),
                ),
              ),
              child: Text(
                widget.headerText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),

          // Tree content
          Expanded(
            child: Column(
              children: [
                // Add Company button at the top
                if (widget.onAddItem != null)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 4.0),
                    child: Material(
                      color: Colors.transparent,
                      child: ListTile(
                        dense: true,
                        contentPadding:
                            const EdgeInsets.only(left: 16.0, right: 8.0),
                        leading: Icon(
                          Icons.add,
                          color: Colors.blue[700],
                          size: 20,
                        ),
                        title: Text(
                          'Add Company',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 13.0,
                            color: Colors.blue[700],
                          ),
                        ),
                        onTap: () {
                          widget.onAddItem!(
                            itemType: TreeItemType.company,
                          );
                        },
                      ),
                    ),
                  ),

                // Tree items
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: _treeItems.length,
                    itemBuilder: (context, index) {
                      return _buildTreeItemWidget(_treeItems[index]);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTreeItemWidget(FullTreeItem item) {
    final isSelected = _isItemSelected(item);
    final itemKey = _getItemKey(item);
    final canExpand = _canItemExpand(item);
    final isExpanded = _expanded[itemKey] ?? widget.expandedByDefault;

    // Calculate indentation based on tree level
    double leftPadding = 16.0;
    switch (item.type) {
      case TreeItemType.company:
        leftPadding = 16.0;
        break;
      case TreeItemType.plant:
        leftPadding = 32.0;
        break;
      case TreeItemType.valueStream:
        leftPadding = 48.0;
        break;
      case TreeItemType.process:
        leftPadding = 64.0;
        break;
    }

    return Material(
      color: isSelected ? Colors.yellow[200] : Colors.transparent,
      child: ListTile(
        dense: true,
        contentPadding: EdgeInsets.only(left: leftPadding, right: 8.0),
        leading: canExpand
            ? Icon(
                isExpanded
                    ? Icons.keyboard_arrow_down
                    : Icons.keyboard_arrow_right,
                color: _getItemColor(item.type),
                size: 20,
              )
            : SizedBox(width: 20), // No icon for leaf items, just spacing
        title: Text(
          item.name,
          style: TextStyle(
            fontWeight:
                isSelected ? FontWeight.bold : _getItemFontWeight(item.type),
            fontSize: _getItemFontSize(item.type),
            color: isSelected ? Colors.black : _getItemTextColor(item.type),
          ),
        ),
        trailing:
            (widget.onAddItem != null && item.type != TreeItemType.process)
                ? _buildAddButton(item)
                : null,
        selected: isSelected,
        onTap: () {
          if (canExpand) {
            _toggleExpansion(itemKey);
          }
          _onItemTap(item);
        },
      ),
    );
  }

  Widget _buildAddButton(FullTreeItem item) {
    // Get the color of the item type being ADDED, not the parent
    Color buttonColor;
    switch (item.type) {
      case TreeItemType.company:
        buttonColor = Colors.green[600]!; // Adding a plant (green)
        break;
      case TreeItemType.plant:
        buttonColor = Colors.purple[600]!; // Adding a value stream (purple)
        break;
      case TreeItemType.valueStream:
        buttonColor = Colors.orange[600]!; // Adding a process (orange)
        break;
      case TreeItemType.process:
        // This should not happen since processes don't have add buttons
        buttonColor = Colors.grey[600]!;
        break;
    }

    return IconButton(
      icon: const Icon(Icons.add, size: 16),
      color: buttonColor,
      tooltip: _getAddTooltip(item.type),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      onPressed: () => _onAddButtonPressed(item),
    );
  }

  String _getAddTooltip(TreeItemType type) {
    switch (type) {
      case TreeItemType.company:
        return 'Add new plant to ${type.name}';
      case TreeItemType.plant:
        return 'Add new value stream to ${type.name}';
      case TreeItemType.valueStream:
        return 'Add new process to ${type.name}';
      case TreeItemType.process:
        return 'Add item'; // Should not be used as processes don't have children
    }
  }

  void _onAddButtonPressed(FullTreeItem item) {
    if (widget.onAddItem == null) return;

    switch (item.type) {
      case TreeItemType.company:
        // Add plant to this company
        widget.onAddItem!(
          itemType: TreeItemType.plant,
          companyName: item.name,
        );
        break;
      case TreeItemType.plant:
        // Add value stream to this plant
        widget.onAddItem!(
          itemType: TreeItemType.valueStream,
          companyName: item.parentName,
          plantName: item.name,
        );
        break;
      case TreeItemType.valueStream:
        // Add process to this value stream
        widget.onAddItem!(
          itemType: TreeItemType.process,
          companyName: _getCompanyNameForValueStream(item),
          plantName: item.parentName,
          valueStreamName: item.name,
          valueStreamId: item.id,
        );
        break;
      case TreeItemType.process:
        // Processes don't have children, so no add action
        break;
    }
  }

  String? _getCompanyNameForValueStream(FullTreeItem valueStreamItem) {
    // Find the plant for this value stream, then find its company
    final plant = _plants.firstWhere(
      (p) => p.name == valueStreamItem.parentName,
      orElse: () => PlantData(
          id: -1,
          organizationId: -1,
          name: '',
          street: '',
          city: '',
          state: '',
          zip: ''),
    );

    if (plant.id > 0) {
      final company = _organizations.firstWhere(
        (org) => org.id == plant.organizationId,
        orElse: () => Organization(id: -1, name: ''),
      );
      return company.id > 0 ? company.name : null;
    }
    return null;
  }

  bool _canItemExpand(FullTreeItem item) {
    switch (item.type) {
      case TreeItemType.company:
        return _plants.any((p) => p.organizationId == item.index);
      case TreeItemType.plant:
        return _valueStreams.any((vs) => vs.plantId == item.index);
      case TreeItemType.valueStream:
        return _processes.any((p) => p.valueStreamId == item.id);
      case TreeItemType.process:
        return false; // Processes are leaf nodes
    }
  }

  Color _getItemColor(TreeItemType type) {
    switch (type) {
      case TreeItemType.company:
        return Colors.blue[700]!;
      case TreeItemType.plant:
        return Colors.green[600]!;
      case TreeItemType.valueStream:
        return Colors.purple[600]!;
      case TreeItemType.process:
        return Colors.orange[600]!;
    }
  }

  Color _getItemTextColor(TreeItemType type) {
    switch (type) {
      case TreeItemType.company:
        return Colors.blue[700]!;
      case TreeItemType.plant:
        return Colors.green[700]!;
      case TreeItemType.valueStream:
        return Colors.purple[700]!;
      case TreeItemType.process:
        return Colors
            .orange[600]!; // Match the "+" button color on value streams
    }
  }

  FontWeight _getItemFontWeight(TreeItemType type) {
    switch (type) {
      case TreeItemType.company:
        return FontWeight.bold;
      case TreeItemType.plant:
        return FontWeight.w600;
      case TreeItemType.valueStream:
        return FontWeight.w500;
      case TreeItemType.process:
        return FontWeight.normal;
    }
  }

  double _getItemFontSize(TreeItemType type) {
    switch (type) {
      case TreeItemType.company:
        return 14.0;
      case TreeItemType.plant:
        return 13.5;
      case TreeItemType.valueStream:
        return 13.0;
      case TreeItemType.process:
        return 12.5;
    }
  }
}
