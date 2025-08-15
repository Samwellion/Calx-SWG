import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift;
import '../models/customer.dart';
import '../database_provider.dart';

/// Optimized Customer Manager for handling customer entities on the canvas
class CustomerManager {
  final Function(String message)? _showMessage;
  final Function()? _onStateChanged;
  
  final Map<String, Customer> _customers = {};
  String? _selectedCustomerId;

  CustomerManager({
    Function(String message)? showMessage,
    Function()? onStateChanged,
  }) : _showMessage = showMessage,
       _onStateChanged = onStateChanged;

  // Getters
  List<Customer> get customers => _customers.values.toList();
  Customer? get selectedCustomer => _selectedCustomerId != null 
      ? _customers[_selectedCustomerId] 
      : null;
  String? get selectedCustomerId => _selectedCustomerId;

  /// Create a new customer on the canvas
  Future<Customer> createCustomer({
    required int valueStreamId,
    required String partNumber,
    Offset position = const Offset(100, 200),
    String? customLabel,
  }) async {
    final customerId = DateTime.now().millisecondsSinceEpoch.toString();
    
    // Load data from value stream
    final data = await _loadCustomerData(valueStreamId);
    
    final customer = Customer(
      id: customerId,
      position: position,
      label: customLabel ?? 'All Customers',
      data: data,
      isSelected: true,
    );

    _customers[customerId] = customer;
    _selectedCustomerId = customerId;
    _notifyStateChanged();
    
    // Auto-save to database
    await saveToDatabase(valueStreamId, partNumber);
    
    _showMessage?.call('Customer created');
    return customer;
  }

  /// Update customer position
  Future<void> updatePosition(String customerId, Offset newPosition, int valueStreamId, String partNumber) async {
    final customer = _customers[customerId];
    if (customer != null) {
      _customers[customerId] = customer.copyWith(position: newPosition);
      _notifyStateChanged();
      
      // Auto-save to database
      await saveToDatabase(valueStreamId, partNumber);
    }
  }

  /// Select a customer
  void selectCustomer(String customerId) {
    // First deselect current customer
    if (_selectedCustomerId != null) {
      final current = _customers[_selectedCustomerId!];
      if (current != null) {
        _customers[_selectedCustomerId!] = current.copyWith(isSelected: false);
      }
    }

    // Select new customer
    final customer = _customers[customerId];
    if (customer != null) {
      _customers[customerId] = customer.copyWith(isSelected: true);
      _selectedCustomerId = customerId;
      _notifyStateChanged();
    }
  }

  /// Deselect all customers
  void deselectAll() {
    if (_selectedCustomerId != null) {
      final customer = _customers[_selectedCustomerId!];
      if (customer != null) {
        _customers[_selectedCustomerId!] = customer.copyWith(isSelected: false);
      }
      _selectedCustomerId = null;
      _notifyStateChanged();
    }
  }

  /// Delete a customer
  Future<void> deleteCustomer(String customerId, int valueStreamId, String partNumber) async {
    if (_customers.containsKey(customerId)) {
      _customers.remove(customerId);
      if (_selectedCustomerId == customerId) {
        _selectedCustomerId = null;
      }
      _notifyStateChanged();
      _showMessage?.call('Customer deleted');
      
      // Auto-save to database
      await saveToDatabase(valueStreamId, partNumber);
    }
  }

  /// Check if a customer can be used as a connection point
  bool canConnectToCustomer(String customerId) {
    return _customers.containsKey(customerId);
  }

  /// Get customer connection point for material connectors
  Offset? getConnectionPoint(String customerId) {
    final customer = _customers[customerId];
    if (customer != null) {
      // Return center-left point for incoming connections
      return Offset(
        customer.position.dx,
        customer.position.dy + 75, // Half height of customer box
      );
    }
    return null;
  }

  /// Clear all customers
  void clear() {
    _customers.clear();
    _selectedCustomerId = null;
    _notifyStateChanged();
  }

  /// Load customer data from value stream
  Future<CustomerData> _loadCustomerData(int valueStreamId) async {
    try {
      final db = await DatabaseProvider.getInstance();
      final valueStream = await (db.select(db.valueStreams)
            ..where((vs) => vs.id.equals(valueStreamId)))
          .getSingleOrNull();
      
      return CustomerData.fromValueStream(
        monthlyDemand: valueStream?.mDemand,
        taktTime: valueStream?.taktTime,
      );
    } catch (e) {
      _showMessage?.call('Warning: Could not load customer data');
      return CustomerData.empty;
    }
  }

  void _notifyStateChanged() {
    _onStateChanged?.call();
  }

  /// Save customers to persistence (placeholder for future implementation)
  Map<String, dynamic> toJson() {
    return {
      'customers': _customers.map((key, customer) => MapEntry(key, {
        'id': customer.id,
        'position': {'dx': customer.position.dx, 'dy': customer.position.dy},
        'label': customer.label,
        'data': {
          'monthlyDemand': customer.data.monthlyDemand,
          'taktTime': customer.data.taktTime,
          'additionalInfo': customer.data.additionalInfo,
        },
      })),
      'selectedCustomerId': _selectedCustomerId,
    };
  }

  /// Load customers from persistence (placeholder for future implementation)
  void fromJson(Map<String, dynamic> json) {
    _customers.clear();
    
    final customersData = json['customers'] as Map<String, dynamic>?;
    if (customersData != null) {
      for (final entry in customersData.entries) {
        final data = entry.value as Map<String, dynamic>;
        final positionData = data['position'] as Map<String, dynamic>;
        final customerData = data['data'] as Map<String, dynamic>;
        
        _customers[entry.key] = Customer(
          id: data['id'] as String,
          position: Offset(
            positionData['dx'] as double,
            positionData['dy'] as double,
          ),
          label: data['label'] as String,
          data: CustomerData(
            monthlyDemand: customerData['monthlyDemand'] as String,
            taktTime: customerData['taktTime'] as String,
            additionalInfo: customerData['additionalInfo'] as String?,
          ),
        );
      }
    }
    
    _selectedCustomerId = json['selectedCustomerId'] as String?;
    _notifyStateChanged();
  }

  /// Save customers to database
  Future<void> saveToDatabase(int valueStreamId, String partNumber) async {
    try {
      final db = await DatabaseProvider.getInstance();
      
      // Clear existing customer entities for this value stream and part
      await db.customStatement(
        'DELETE FROM canvas_states WHERE value_stream_id = ? AND part_number = ? AND icon_type = ?',
        [valueStreamId, partNumber, 'customer']
      );
      
      // Save all current customers
      for (final customer in _customers.values) {
        await db.saveCanvasState(
          valueStreamId: valueStreamId,
          partNumber: partNumber,
          iconType: 'customer',
          iconId: customer.id,
          positionX: customer.position.dx,
          positionY: customer.position.dy,
          userData: customer.toJson(),
        );
      }
    } catch (e) {
      _showMessage?.call('Warning: Could not save customer data');
    }
  }

  /// Load customers from database
  Future<void> loadFromDatabase(int valueStreamId, String partNumber) async {
    try {
      final db = await DatabaseProvider.getInstance();
      
      final canvasStates = await db.customSelect(
        'SELECT * FROM canvas_states WHERE value_stream_id = ? AND part_number = ? AND icon_type = ?',
        variables: [
          drift.Variable.withInt(valueStreamId),
          drift.Variable.withString(partNumber), 
          drift.Variable.withString('customer')
        ]
      ).get();
      
      _customers.clear();
      _selectedCustomerId = null;
      
      for (final state in canvasStates) {
        try {
          final customer = Customer.fromJson(
            state.data['userData'] as String,
            id: state.data['icon_id'] as String,
            position: Offset(
              state.data['position_x'] as double,
              state.data['position_y'] as double,
            ),
          );
          _customers[customer.id] = customer;
        } catch (e) {
          // Skip invalid customer data
        }
      }
      
      _notifyStateChanged();
    } catch (e) {
      _showMessage?.call('Warning: Could not load customer data');
    }
  }
}
