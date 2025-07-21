import 'package:flutter/material.dart';
import '../models/organization_data.dart' as org_data;
import 'companies_plants_tree.dart';

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
    return CompaniesPlantsTree(
      plants: plants,
      selectedPlantIndex: selectedPlantIdx,
      onPlantSelected: onPlantSelected,
      headerText: 'Companies & Plants',
    );
  }
}
