import 'package:flutter/material.dart';

enum CanvasIconType {
  // Entities
  customer,
  customerDataBox, // Special data-driven customer box
  supplierDataBox, // Special data box for supplier
  productionControl,
  productionControlDataBox, // Special data box for production control
  truck, // Shipping
  truckDataBox, // Special data box for truck/shipment with frequency input
  supplier,
  tugger, // TODO: Implement tugger icon
  
  // Material and Info Connectors
  electronicArrow, // Electronic information flow connector
  informationArrow, // Information flow connector
  materialArrow, // Material flow connector
  materialPush, // Material push connector
  kanbanLoop, // TODO: Implement kanban loop connector
  withdrawalLoop, // TODO: Implement withdrawal loop connector
  
  // Material Types
  buffer, // TODO: Implement buffer icon
  fifo, // FIFO material connector with piece count and lead time calculation
  kanbanMarket, // TODO: Implement kanban market icon
  uncontrolled, // TODO: Implement uncontrolled icon
  
  // Other
  kaizenBurst, // TODO: Implement kaizen burst
  leadtimeLadder, // TODO: Implement leadtime ladder
  
  // Legacy/Internal types (keep for compatibility)
  dataBox,
  connector, // Special connector type for arrow connections
}

class CanvasIcon {
  final String id;
  final CanvasIconType type;
  final String label;
  final IconData iconData;
  final Color color;
  Offset position;
  final Size size;

  CanvasIcon({
    required this.id,
    required this.type,
    required this.label,
    required this.iconData,
    required this.position,
    this.color = Colors.blue,
    this.size = const Size(40, 40),
  });

  CanvasIcon copyWith({
    String? id,
    CanvasIconType? type,
    String? label,
    IconData? iconData,
    Color? color,
    Offset? position,
    Size? size,
  }) {
    return CanvasIcon(
      id: id ?? this.id,
      type: type ?? this.type,
      label: label ?? this.label,
      iconData: iconData ?? this.iconData,
      color: color ?? this.color,
      position: position ?? this.position,
      size: size ?? this.size,
    );
  }
}

class CanvasIconTemplate {
  final CanvasIconType type;
  final String label;
  final IconData iconData;
  final Color color;

  const CanvasIconTemplate({
    required this.type,
    required this.label,
    required this.iconData,
    required this.color,
  });

  static const List<CanvasIconTemplate> templates = [
    // === ENTITIES ===
    CanvasIconTemplate(
      type: CanvasIconType.customer,
      label: 'Customer',
      iconData: Icons.person,
      color: Colors.blue,
    ),
    CanvasIconTemplate(
      type: CanvasIconType.dataBox,
      label: 'Data Box',
      iconData: Icons.data_usage,
      color: Colors.teal,
    ),
    CanvasIconTemplate(
      type: CanvasIconType.productionControl,
      label: 'Production Control',
      iconData: Icons.settings_applications,
      color: Colors.deepOrange,
    ),
    CanvasIconTemplate(
      type: CanvasIconType.truck,
      label: 'Shipping',
      iconData: Icons.local_shipping,
      color: Colors.orange,
    ),
    CanvasIconTemplate(
      type: CanvasIconType.supplier,
      label: 'Supplier',
      iconData: Icons.factory,
      color: Colors.green,
    ),
    CanvasIconTemplate(
      type: CanvasIconType.tugger,
      label: 'Tugger', // TODO: Implement tugger functionality
      iconData: Icons.agriculture,
      color: Colors.brown,
    ),
    
    // === MATERIAL AND INFO CONNECTORS ===
    CanvasIconTemplate(
      type: CanvasIconType.electronicArrow,
      label: 'Electronic Arrow',
      iconData: Icons.electric_bolt,
      color: Colors.lightBlue,
    ),
    CanvasIconTemplate(
      type: CanvasIconType.informationArrow,
      label: 'Info Arrow',
      iconData: Icons.arrow_forward,
      color: Colors.blue,
    ),
    CanvasIconTemplate(
      type: CanvasIconType.materialArrow,
      label: 'Material Flow',
      iconData: Icons.double_arrow,
      color: Colors.green,
    ),
    CanvasIconTemplate(
      type: CanvasIconType.materialPush,
      label: 'Material Push', // TODO: Implement material push connector
      iconData: Icons.double_arrow,
      color: Colors.red,
    ),
    CanvasIconTemplate(
      type: CanvasIconType.kanbanLoop,
      label: 'Kanban Loop', // TODO: Implement kanban loop connector
      iconData: Icons.loop,
      color: Colors.amber,
    ),
    CanvasIconTemplate(
      type: CanvasIconType.withdrawalLoop,
      label: 'Withdrawal Loop', // TODO: Implement withdrawal loop connector
      iconData: Icons.replay,
      color: Colors.purple,
    ),
    
    // === MATERIAL TYPES ===
    CanvasIconTemplate(
      type: CanvasIconType.buffer,
      label: 'Buffer', // TODO: Implement buffer icon
      iconData: Icons.storage,
      color: Colors.grey,
    ),
    CanvasIconTemplate(
      type: CanvasIconType.fifo,
      label: 'FIFO', // FIFO material connector implemented
      iconData: Icons.queue,
      color: Colors.cyan,
    ),
    CanvasIconTemplate(
      type: CanvasIconType.kanbanMarket,
      label: 'Kanban Market', // TODO: Implement kanban market icon
      iconData: Icons.store,
      color: Colors.amber,
    ),
    CanvasIconTemplate(
      type: CanvasIconType.uncontrolled,
      label: 'Uncontrolled', // TODO: Implement uncontrolled icon
      iconData: Icons.help_outline,
      color: Colors.red,
    ),
    
    // === OTHER ===
    CanvasIconTemplate(
      type: CanvasIconType.kaizenBurst,
      label: 'Kaizen Burst', // TODO: Implement kaizen burst
      iconData: Icons.flash_on,
      color: Colors.yellow,
    ),
    CanvasIconTemplate(
      type: CanvasIconType.leadtimeLadder,
      label: 'Leadtime Ladder', // TODO: Implement leadtime ladder
      iconData: Icons.stairs,
      color: Colors.indigo,
    ),
  ];
}
