import 'package:flutter/material.dart';
import '../models/canvas_icon.dart';
import '../models/process_object.dart';

/// Unified state manager for material connector creation workflow
/// Eliminates state collisions and provides a single source of truth
class MaterialConnectorStateManager {
  // Core state
  CanvasIconType? _connectorType;
  bool _isActive = false;
  
  // Supplier state (can be process, data box, or existing material connector)
  ProcessObject? _supplierProcess;
  String? _supplierDataBoxId;
  Offset? _supplierDataBoxPosition;
  String? _supplierDataBoxType; // 'customer', 'supplier', 'productionControl', 'truck'
  String? _supplierMaterialConnectorId;
  
  // Customer state (can be process or data box)
  ProcessObject? _customerProcess;
  String? _customerDataBoxId;
  Offset? _customerDataBoxPosition;
  String? _customerDataBoxType;
  
  // Connection state
  bool _supplierSelected = false;
  bool _readyToConnect = false;

  // Getters
  bool get isActive => _isActive;
  bool get isSupplierSelected => _supplierSelected;
  bool get isReadyToConnect => _readyToConnect;
  CanvasIconType? get connectorType => _connectorType;
  
  // Supplier getters
  ProcessObject? get supplierProcess => _supplierProcess;
  String? get supplierDataBoxId => _supplierDataBoxId;
  Offset? get supplierDataBoxPosition => _supplierDataBoxPosition;
  String? get supplierDataBoxType => _supplierDataBoxType;
  String? get supplierMaterialConnectorId => _supplierMaterialConnectorId;
  
  // Customer getters
  ProcessObject? get customerProcess => _customerProcess;
  String? get customerDataBoxId => _customerDataBoxId;
  Offset? get customerDataBoxPosition => _customerDataBoxPosition;
  String? get customerDataBoxType => _customerDataBoxType;

  /// Start material connector creation workflow
  void startConnectorCreation(CanvasIconType connectorType) {
    
    _reset();
    _connectorType = connectorType;
    _isActive = true;
    
  }

  /// Set supplier process
  bool setSupplierProcess(ProcessObject process) {
    
    if (!_isActive || _supplierSelected) {
      return false;
    }
    
    _supplierProcess = process;
    _supplierSelected = true;
    _readyToConnect = true;
    _clearSupplierDataBox();
    _clearSupplierMaterialConnector();
    
    return true;
  }

  /// Set supplier data box
  bool setSupplierDataBox(String dataBoxId, Offset position, String dataBoxType) {
    
    if (!_isActive || _supplierSelected) {
      return false;
    }
    
    _supplierDataBoxId = dataBoxId;
    _supplierDataBoxPosition = position;
    _supplierDataBoxType = dataBoxType;
    _supplierSelected = true;
    _readyToConnect = true;
    _clearSupplierProcess();
    _clearSupplierMaterialConnector();
    
    return true;
  }

  /// Set supplier material connector
  bool setSupplierMaterialConnector(String materialConnectorId) {
    if (!_isActive || _supplierSelected) return false;
    
    _supplierMaterialConnectorId = materialConnectorId;
    _supplierSelected = true;
    _readyToConnect = true;
    _clearSupplierProcess();
    _clearSupplierDataBox();
    return true;
  }

  /// Set customer process
  bool setCustomerProcess(ProcessObject process) {
    
    if (!_isActive || !_readyToConnect) {
      return false;
    }
    
    // Check for self-connection
    if (_supplierProcess != null && _supplierProcess!.id == process.id) {
      return false;
    }
    
    _customerProcess = process;
    _clearCustomerDataBox();
    
    return true;
  }

  /// Set customer data box
  bool setCustomerDataBox(String dataBoxId, Offset position, String dataBoxType) {
    
    if (!_isActive || !_readyToConnect) {
      return false;
    }
    
    _customerDataBoxId = dataBoxId;
    _customerDataBoxPosition = position;
    _customerDataBoxType = dataBoxType;
    _clearCustomerProcess();
    
    return true;
  }

  /// Check if we have both supplier and customer selected
  bool canCreateConnector() {
    
    if (!_isActive || !_readyToConnect) {
      return false;
    }
    
    bool hasSupplier = _supplierProcess != null || 
                      _supplierDataBoxId != null || 
                      _supplierMaterialConnectorId != null;
    
    bool hasCustomer = _customerProcess != null || _customerDataBoxId != null;
    
    
    return hasSupplier && hasCustomer;
  }

  /// Get connection description for user feedback
  String getConnectionDescription() {
    if (!_isActive) return '';
    
    final typeName = _connectorType.toString().split('.').last.toUpperCase();
    
    if (!_supplierSelected) {
      return '$typeName mode: Select supplier (process, data box, or material connector)';
    }
    
    if (!canCreateConnector()) {
      String supplierDesc = _getSupplierDescription();
      return '$typeName mode: Supplier "$supplierDesc" selected. Now select customer (process or data box)';
    }
    
    return '$typeName mode: Ready to create connector';
  }

  String _getSupplierDescription() {
    if (_supplierProcess != null) return _supplierProcess!.name;
    if (_supplierDataBoxId != null) return _supplierDataBoxId!;
    if (_supplierMaterialConnectorId != null) return 'Material Connector $_supplierMaterialConnectorId';
    return 'Unknown';
  }

  /// Public method to reset all state
  void reset() {
    _reset();
  }

  /// Reset all state
  void _reset() {
    _connectorType = null;
    _isActive = false;
    _supplierSelected = false;
    _readyToConnect = false;
    
    _clearSupplierProcess();
    _clearSupplierDataBox();
    _clearSupplierMaterialConnector();
    _clearCustomerProcess();
    _clearCustomerDataBox();
  }

  void _clearSupplierProcess() {
    _supplierProcess = null;
  }

  void _clearSupplierDataBox() {
    _supplierDataBoxId = null;
    _supplierDataBoxPosition = null;
    _supplierDataBoxType = null;
  }

  void _clearSupplierMaterialConnector() {
    _supplierMaterialConnectorId = null;
  }

  void _clearCustomerProcess() {
    _customerProcess = null;
  }

  void _clearCustomerDataBox() {
    _customerDataBoxId = null;
    _customerDataBoxPosition = null;
    _customerDataBoxType = null;
  }

  /// Cancel connector creation and reset state
  void cancel() {
    _reset();
  }

  /// Complete connector creation and reset state
  void complete() {
    _reset();
  }
}
