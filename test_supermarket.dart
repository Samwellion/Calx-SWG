import 'lib/models/canvas_icon.dart';
import 'lib/models/material_connector.dart';

void main() {
  print('Testing supermarket material connector detection...');
  
  // Find the supermarket template
  final supermarketTemplate = CanvasIconTemplate.templates.firstWhere(
    (template) => template.label == 'Supermarket',
    orElse: () => throw Exception('Supermarket template not found'),
  );
  
  print('Found supermarket template:');
  print('  Type: ${supermarketTemplate.type}');
  print('  Label: ${supermarketTemplate.label}');
  print('  Icon: ${supermarketTemplate.iconData}');
  
  // Test if it's recognized as a material connector type
  final isMaterialConnector = MaterialConnectorHelper.isMaterialConnectorType(supermarketTemplate.type);
  print('  Is material connector: $isMaterialConnector');
  
  // Test getting icon data
  final iconData = MaterialConnectorHelper.getIconData(supermarketTemplate.type);
  print('  Material connector icon: $iconData');
  
  // Test getting color
  final color = MaterialConnectorHelper.getColor(supermarketTemplate.type);
  print('  Material connector color: $color');
  
  if (isMaterialConnector) {
    print('✅ Supermarket is properly configured as a material connector!');
  } else {
    print('❌ ERROR: Supermarket is NOT recognized as a material connector!');
  }
}
