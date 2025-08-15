import 'package:flutter/material.dart';
import '../models/material_connector.dart';
import 'material_connector_state_manager.dart';

/// Unified material connector creation handler
/// Eliminates code duplication and provides consistent connector creation
class MaterialConnectorCreator {
  final MaterialConnectorStateManager _stateManager;
  final Function(MaterialConnector) _addConnectorCallback;
  final Function(String) _showMessageCallback;

  MaterialConnectorCreator({
    required MaterialConnectorStateManager stateManager,
    required Function(MaterialConnector) addConnectorCallback,
    required Function(String) showMessageCallback,
  }) : _stateManager = stateManager,
       _addConnectorCallback = addConnectorCallback,
       _showMessageCallback = showMessageCallback;

  /// Create material connector from current state
  bool createConnector() {
    
    if (!_stateManager.canCreateConnector()) {
      return false;
    }


    try {
      final connector = _buildMaterialConnector();
      
      _addConnectorCallback(connector);
      
      final typeName = _stateManager.connectorType.toString().split('.').last.toUpperCase();
      final supplierDesc = _getSupplierDescription();
      final customerDesc = _getCustomerDescription();
      
      _showMessageCallback('$typeName connector created: $supplierDesc → $customerDesc');
      
      _stateManager.complete();
      
      return true;
    } catch (e) {
      _showMessageCallback('Error creating connector: $e');
      return false;
    }
  }

  MaterialConnector _buildMaterialConnector() {
    final position = _calculateConnectorPosition();
    
    return MaterialConnector(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: _stateManager.connectorType!,
      supplierProcessId: _getSupplierProcessId(),
      customerProcessId: _getCustomerProcessId(),
      label: _stateManager.connectorType.toString().split('.').last.toUpperCase(),
      position: position,
      numberOfPieces: null,
      color: MaterialConnectorHelper.getColor(_stateManager.connectorType!),
    );
  }

  String _getSupplierProcessId() {
    if (_stateManager.supplierProcess != null) {
      return _stateManager.supplierProcess!.id.toString();
    }
    if (_stateManager.supplierDataBoxId != null) {
      return _stateManager.supplierDataBoxId!;
    }
    if (_stateManager.supplierMaterialConnectorId != null) {
      return _stateManager.supplierMaterialConnectorId!;
    }
    throw Exception('No supplier selected');
  }

  String _getCustomerProcessId() {
    if (_stateManager.customerProcess != null) {
      return _stateManager.customerProcess!.id.toString();
    }
    if (_stateManager.customerDataBoxId != null) {
      return _stateManager.customerDataBoxId!;
    }
    throw Exception('No customer selected');
  }

  Offset _calculateConnectorPosition() {
    final supplierPos = _getSupplierPosition();
    final customerPos = _getCustomerPosition();
    
    // Place connector at midpoint
    return Offset(
      (supplierPos.dx + customerPos.dx) / 2,
      (supplierPos.dy + customerPos.dy) / 2,
    );
  }

  Offset _getSupplierPosition() {
    if (_stateManager.supplierProcess != null) {
      final process = _stateManager.supplierProcess!;
      return Offset(
        process.position.dx + process.size.width / 2,
        process.position.dy + process.size.height / 2,
      );
    }
    if (_stateManager.supplierDataBoxPosition != null) {
      final pos = _stateManager.supplierDataBoxPosition!;
      final size = _getDataBoxSize(_stateManager.supplierDataBoxType!);
      return Offset(
        pos.dx + size.width / 2,
        pos.dy + size.height / 2,
      );
    }
    // For material connector suppliers, we'd need access to the material connector list
    // For now, return a default position
    return const Offset(100, 100);
  }

  Offset _getCustomerPosition() {
    if (_stateManager.customerProcess != null) {
      final process = _stateManager.customerProcess!;
      return Offset(
        process.position.dx + process.size.width / 2,
        process.position.dy + process.size.height / 2,
      );
    }
    if (_stateManager.customerDataBoxPosition != null) {
      final pos = _stateManager.customerDataBoxPosition!;
      final size = _getDataBoxSize(_stateManager.customerDataBoxType!);
      return Offset(
        pos.dx + size.width / 2,
        pos.dy + size.height / 2,
      );
    }
    return const Offset(200, 200);
  }

  Size _getDataBoxSize(String dataBoxType) {
    switch (dataBoxType) {
      case 'customer':
        return const Size(180, 150);
      case 'supplier':
        return const Size(200, 140);
      case 'productionControl':
        return const Size(160, 120);
      case 'truck':
        return const Size(120, 90);
      default:
        return const Size(150, 120);
    }
  }

  String _getSupplierDescription() {
    if (_stateManager.supplierProcess != null) {
      return _stateManager.supplierProcess!.name;
    }
    if (_stateManager.supplierDataBoxId != null) {
      return '${_stateManager.supplierDataBoxType} ${_stateManager.supplierDataBoxId}';
    }
    if (_stateManager.supplierMaterialConnectorId != null) {
      return 'Material Connector ${_stateManager.supplierMaterialConnectorId}';
    }
    return 'Unknown Supplier';
  }

  String _getCustomerDescription() {
    if (_stateManager.customerProcess != null) {
      return _stateManager.customerProcess!.name;
    }
    if (_stateManager.customerDataBoxId != null) {
      return '${_stateManager.customerDataBoxType} ${_stateManager.customerDataBoxId}';
    }
    return 'Unknown Customer';
  }
}
