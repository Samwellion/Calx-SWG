import 'package:flutter/material.dart';
import '../models/organization_data.dart' as org_data;

class PlantList extends StatelessWidget {
  final List<org_data.PlantData> plants;
  final int? selectedPlantIdx;
  final Function(int) onPlantSelected;

  const PlantList({
    super.key,
    required this.plants,
    required this.selectedPlantIdx,
    required this.onPlantSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: Colors.yellow[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.yellow[300]!),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: plants.length,
        itemBuilder: (context, idx) {
          final isSelected = idx == selectedPlantIdx;
          return Material(
            color: isSelected ? Colors.yellow[100] : Colors.transparent,
            child: ListTile(
              title: Text(plants[idx].name,
                  style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal)),
              selected: isSelected,
              onTap: () => onPlantSelected(idx),
            ),
          );
        },
      ),
    );
  }
}
