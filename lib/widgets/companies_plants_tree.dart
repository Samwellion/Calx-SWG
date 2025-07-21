import 'package:flutter/material.dart';
import '../models/organization_data.dart' as org_data;
import '../database_provider.dart';

class TreeItem {
  final String name;
  final bool isCompany;
  final int? plantIndex; // Index in the original plants list
  final String? companyName; // For plant items, which company they belong to

  TreeItem({
    required this.name,
    required this.isCompany,
    this.plantIndex,
    this.companyName,
  });
}

/// A reusable tree widget that displays companies and their associated plants
/// in a hierarchical structure. Companies are shown as expandable headers,
/// and plants are displayed as selectable items under their parent companies.
class CompaniesPlantsTree extends StatefulWidget {
  /// List of plant data to display in the tree
  final List<org_data.PlantData> plants;

  /// Index of the currently selected plant (if any)
  final int? selectedPlantIndex;

  /// Callback when a plant is selected. Only plants are selectable, not companies.
  final Function(int plantIndex) onPlantSelected;

  /// Optional width for the tree widget. Defaults to 280.
  final double? width;

  /// Optional height for the tree widget. If null, uses intrinsic height.
  final double? height;

  /// Whether to show a header title. Defaults to true.
  final bool showHeader;

  /// Custom header text. Defaults to 'Companies & Plants'.
  final String headerText;

  /// Whether companies should be expanded by default. Defaults to true.
  final bool expandedByDefault;

  const CompaniesPlantsTree({
    super.key,
    required this.plants,
    required this.selectedPlantIndex,
    required this.onPlantSelected,
    this.width,
    this.height,
    this.showHeader = true,
    this.headerText = 'Companies & Plants',
    this.expandedByDefault = true,
  });

  @override
  State<CompaniesPlantsTree> createState() => _CompaniesPlantsTreeState();
}

class _CompaniesPlantsTreeState extends State<CompaniesPlantsTree> {
  List<TreeItem> _treeItems = [];
  final Map<String, bool> _expandedCompanies = {};

  @override
  void initState() {
    super.initState();
    _buildTreeItems();
  }

  @override
  void didUpdateWidget(CompaniesPlantsTree oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.plants != widget.plants) {
      _buildTreeItems();
    }
  }

  Future<void> _buildTreeItems() async {
    try {
      final db = await DatabaseProvider.getInstance();

      // Get all organizations
      final organizations = await db.select(db.organizations).get();
      final plants = await db.select(db.plants).get();

      // Group plants by organization
      final Map<String, List<int>> companyPlants = {};

      for (int i = 0; i < widget.plants.length; i++) {
        final plant = widget.plants[i];
        // Find which organization this plant belongs to
        final dbPlant = plants.where((p) => p.name == plant.name).firstOrNull;
        if (dbPlant != null) {
          final org = organizations
              .where((o) => o.id == dbPlant.organizationId)
              .firstOrNull;
          if (org != null) {
            companyPlants.putIfAbsent(org.name, () => []).add(i);
          }
        }
      }

      // Build the tree structure
      final List<TreeItem> items = [];
      final sortedCompanies = companyPlants.keys.toList()..sort();

      for (final companyName in sortedCompanies) {
        // Add company header
        items.add(TreeItem(
          name: companyName,
          isCompany: true,
        ));

        // Add plants under this company if expanded
        if (_expandedCompanies[companyName] ?? widget.expandedByDefault) {
          final plantIndices = companyPlants[companyName]!
            ..sort((a, b) =>
                widget.plants[a].name.compareTo(widget.plants[b].name));

          for (final plantIdx in plantIndices) {
            items.add(TreeItem(
              name: widget.plants[plantIdx].name,
              isCompany: false,
              plantIndex: plantIdx,
              companyName: companyName,
            ));
          }
        }
      }

      if (mounted) {
        setState(() {
          _treeItems = items;
        });
      }
    } catch (e) {
      // Handle error gracefully
      debugPrint('Error building tree items: $e');
      if (mounted) {
        setState(() {
          _treeItems = [];
        });
      }
    }
  }

  void _toggleCompany(String companyName) {
    setState(() {
      _expandedCompanies[companyName] =
          !(_expandedCompanies[companyName] ?? widget.expandedByDefault);
    });
    _buildTreeItems();
  }

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Optional header
        if (widget.showHeader)
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              widget.headerText,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

        // Tree content
        if (widget.plants.isEmpty)
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              'No plants available',
              style: TextStyle(color: Colors.grey),
            ),
          )
        else
          ..._treeItems.map((item) => _buildTreeItemWidget(item)),
      ],
    );

    return Container(
      width: widget.width ?? 280,
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.yellow[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.yellow[300]!),
      ),
      child: widget.height != null
          ? SingleChildScrollView(child: content)
          : content,
    );
  }

  Widget _buildTreeItemWidget(TreeItem item) {
    if (item.isCompany) {
      // Company header
      final isExpanded =
          _expandedCompanies[item.name] ?? widget.expandedByDefault;
      return Material(
        color: Colors.transparent,
        child: ListTile(
          dense: true,
          leading: Icon(
            isExpanded ? Icons.expand_more : Icons.chevron_right,
            color: Colors.blue[700],
          ),
          title: Text(
            item.name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue[700],
              fontSize: 14,
            ),
          ),
          onTap: () => _toggleCompany(item.name),
        ),
      );
    } else {
      // Plant item
      final isSelected = item.plantIndex == widget.selectedPlantIndex;
      return Material(
        color: isSelected ? Colors.yellow[200] : Colors.transparent,
        child: ListTile(
          dense: true,
          contentPadding: const EdgeInsets.only(left: 40.0, right: 16.0),
          leading: Icon(
            Icons.business,
            size: 16,
            color: isSelected ? Colors.orange[700] : Colors.grey[600],
          ),
          title: Text(
            item.name,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
              color: isSelected ? Colors.black : Colors.grey[800],
            ),
          ),
          selected: isSelected,
          onTap: () => widget.onPlantSelected(item.plantIndex!),
        ),
      );
    }
  }
}

/// Extension to provide nullable first element for backwards compatibility
extension NullableFirst<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
