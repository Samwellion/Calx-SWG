// ignore_for_file: unused_local_variable

import 'lib/models/canvas_icon.dart';
import 'lib/models/material_connector.dart';

void main() {
  
  // Find the supermarket template
  final supermarketTemplate = CanvasIconTemplate.templates.firstWhere(
    (template) => template.label == 'Supermarket',
    orElse: () => throw Exception('Supermarket template not found'),
  );
  
  
  // Test if it's recognized as a material connector type
  final isMaterialConnector = MaterialConnectorHelper.isMaterialConnectorType(supermarketTemplate.type);
  
  // Test getting icon data
  final iconData = MaterialConnectorHelper.getIconData(supermarketTemplate.type);
  
  // Test getting color
  final color = MaterialConnectorHelper.getColor(supermarketTemplate.type);
  
  if (isMaterialConnector) {
  } else {
  }
}
