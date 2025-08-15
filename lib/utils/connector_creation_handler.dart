import 'package:flutter/material.dart';
import '../models/canvas_connector.dart';
import '../models/connection_handle.dart';

/// Common routine for connecting canvas items with precise handle selection
/// Handles: Processes, Data Boxes, Canvas Icons, and other connectible items
/// Excludes: Supermarkets, Buffer, Uncontrolled Inventory, FIFO, Kanban and Withdrawal Loops
class ConnectorCreationHandler {
  
  /// Current state of the connection process
  ConnectionState _connectionState = ConnectionState.none;
  ConnectorType _connectorType = ConnectorType.information;
  
  /// Connection endpoints with handles
  ConnectorEndpoint? _supplierEndpoint;
  ConnectorEndpoint? _customerEndpoint;
  
  /// Callbacks for UI updates
  Function(String message, {Duration? duration})? onShowMessage;
  Function(String itemId, String itemType)? onShowConnectionHandles;
  Function()? onHideConnectionHandles;
  Function(CanvasConnector connector)? onConnectorCreated;
  Function()? onConnectionCancelled;
  
  ConnectorCreationHandler({
    this.onShowMessage,
    this.onShowConnectionHandles,
    this.onHideConnectionHandles,
    this.onConnectorCreated,
    this.onConnectionCancelled,
  });
  
  /// Get current connection state
  ConnectionState get connectionState => _connectionState;
  
  /// Get current connector type being created
  ConnectorType get connectorType => _connectorType;
  
  /// Check if currently in connection mode
  bool get isConnecting => _connectionState != ConnectionState.none;
  
  /// Get progress message for current state
  String get progressMessage {
    switch (_connectionState) {
      case ConnectionState.none:
        return 'Select a connector type to begin';
      case ConnectionState.selectingSupplier:
        return 'Select the supplier item';
      case ConnectionState.selectingSupplierHandle:
        return 'Select connection handle on supplier';
      case ConnectionState.selectingCustomer:
        return 'Select the customer item';
      case ConnectionState.selectingCustomerHandle:
        return 'Select connection handle on customer';
      case ConnectionState.creating:
        return 'Creating connection...';
    }
  }
  
  /// Start connection creation with specified connector type
  void startConnection(ConnectorType connectorType) {
    _connectorType = connectorType;
    _connectionState = ConnectionState.selectingSupplier;
    _supplierEndpoint = null;
    _customerEndpoint = null;
    
    final typeName = _getConnectorTypeName(connectorType);
    onShowMessage?.call('Select the supplier item for $typeName connection');
  }
  
  /// Handle item selection during connection process
  void handleItemSelection(String itemId, String itemType, Offset itemPosition, Size itemSize) {
    if (!_isConnectableItem(itemType)) {
      onShowMessage?.call('This item type cannot be connected with standard connectors');
      return;
    }
    
    switch (_connectionState) {
      case ConnectionState.selectingSupplier:
        _handleSupplierSelection(itemId, itemType);
        break;
      case ConnectionState.selectingCustomer:
        _handleCustomerSelection(itemId, itemType);
        break;
      default:
        // Ignore taps when not in selection mode
        break;
    }
  }
  
  /// Handle connection handle selection
  void handleHandleSelection(ConnectionHandle handle) {
    switch (_connectionState) {
      case ConnectionState.selectingSupplierHandle:
        _handleSupplierHandleSelection(handle);
        break;
      case ConnectionState.selectingCustomerHandle:
        _handleCustomerHandleSelection(handle);
        break;
      default:
        // Ignore handle selection when not in handle selection mode
        break;
    }
  }
  
  /// Cancel current connection process
  void cancelConnection() {
    _connectionState = ConnectionState.none;
    _supplierEndpoint = null;
    _customerEndpoint = null;
    onHideConnectionHandles?.call();
    onConnectionCancelled?.call();
    onShowMessage?.call('Connection cancelled');
  }
  
  /// Check if item type can be connected with standard connectors
  bool _isConnectableItem(String itemType) {
    // Material connectors use special workflows for creation/placement
    // They can only be TARGETS of Material Flow/Push arrows, not sources via common routine
    const excludedTypes = {
      'kanbanLoop',
      'withdrawalLoop',
    };
    return !excludedTypes.contains(itemType);
  }
  
  /// Handle supplier item selection
  void _handleSupplierSelection(String itemId, String itemType) {
    _connectionState = ConnectionState.selectingSupplierHandle;
    
    // Show connection handles on supplier
    onShowConnectionHandles?.call(itemId, itemType);
    onShowMessage?.call('Select connection handle on supplier item');
  }
  
  /// Handle supplier handle selection
  void _handleSupplierHandleSelection(ConnectionHandle handle) {
    _supplierEndpoint = ConnectorEndpoint(
      itemId: handle.itemId,
      itemType: handle.itemType,
      handle: handle,
    );
    
    _connectionState = ConnectionState.selectingCustomer;
    onHideConnectionHandles?.call();
    
    final typeName = _getConnectorTypeName(_connectorType);
    onShowMessage?.call('Supplier selected. Now select the customer item for $typeName connection');
  }
  
  /// Handle customer item selection
  void _handleCustomerSelection(String itemId, String itemType) {
    // Check if trying to connect to same item
    if (_supplierEndpoint != null && _supplierEndpoint!.itemId == itemId) {
      onShowMessage?.call('Cannot connect item to itself. Please select a different customer item');
      return;
    }
    
    _connectionState = ConnectionState.selectingCustomerHandle;
    
    // Show connection handles on customer
    onShowConnectionHandles?.call(itemId, itemType);
    onShowMessage?.call('Select connection handle on customer item');
  }
  
  /// Handle customer handle selection
  void _handleCustomerHandleSelection(ConnectionHandle handle) {
    _customerEndpoint = ConnectorEndpoint(
      itemId: handle.itemId,
      itemType: handle.itemType,
      handle: handle,
    );
    
    _connectionState = ConnectionState.creating;
    onHideConnectionHandles?.call();
    
    // Create the connector
    _createConnector();
  }
  
  /// Create the final connector
  void _createConnector() {
    if (_supplierEndpoint == null || _customerEndpoint == null) {
      onShowMessage?.call('Error: Missing connection endpoints');
      cancelConnection();
      return;
    }
    
    final connector = CanvasConnector(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: _connectorType,
      startPoint: _supplierEndpoint!,
      endPoint: _customerEndpoint!,
    );
    
    // Reset state
    _connectionState = ConnectionState.none;
    _supplierEndpoint = null;
    _customerEndpoint = null;
    
    // Notify creation
    onConnectorCreated?.call(connector);
    
    final typeName = _getConnectorTypeName(_connectorType);
    onShowMessage?.call('$typeName connection created successfully!', duration: const Duration(seconds: 2));
  }
  
  /// Get user-friendly name for connector type
  String _getConnectorTypeName(ConnectorType type) {
    switch (type) {
      case ConnectorType.information:
        return 'Information flow';
      case ConnectorType.electronic:
        return 'Electronic information';
      case ConnectorType.material:
        return 'Material flow';
      case ConnectorType.materialPush:
        return 'Material push';
      default:
        return type.toString().split('.').last;
    }
  }
}

/// States during connection creation process
enum ConnectionState {
  none,                    // Not creating any connection
  selectingSupplier,       // Waiting for supplier item selection
  selectingSupplierHandle, // Waiting for supplier handle selection
  selectingCustomer,       // Waiting for customer item selection
  selectingCustomerHandle, // Waiting for customer handle selection
  creating,               // Creating the connection
}

/// Result of connection creation
class ConnectionResult {
  final bool success;
  final String message;
  final CanvasConnector? connector;
  
  ConnectionResult({
    required this.success,
    required this.message,
    this.connector,
  });
  
  factory ConnectionResult.success(CanvasConnector connector, String message) {
    return ConnectionResult(
      success: true,
      message: message,
      connector: connector,
    );
  }
  
  factory ConnectionResult.error(String message) {
    return ConnectionResult(
      success: false,
      message: message,
    );
  }
}