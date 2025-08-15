import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift;
import '../models/supplier.dart';
import '../database_provider.dart';

/// Optimized Supplier Manager for handling supplier entities on the canvas
class SupplierManager {
  final Function(String message)? _showMessage;
  final Function()? _onStateChanged;
  
  final Map<String, Supplier> _suppliers = {};
  String? _selectedSupplierId;

  SupplierManager({
    Function(String message)? showMessage,
    Function()? onStateChanged,
  }) : _showMessage = showMessage,
       _onStateChanged = onStateChanged;

  // Getters
  List<Supplier> get suppliers => _suppliers.values.toList();
  Supplier? get selectedSupplier => _selectedSupplierId != null 
      ? _suppliers[_selectedSupplierId] 
      : null;
  String? get selectedSupplierId => _selectedSupplierId;

  /// Create a new supplier on the canvas
  Future<Supplier> createSupplier({
    required int valueStreamId,
    required String partNumber,
    Offset position = const Offset(300, 200),
    String? customLabel,
  }) async {
    final supplierId = DateTime.now().millisecondsSinceEpoch.toString();
    
    // Load data from value stream
    final data = await _loadSupplierData(valueStreamId);
    
    final supplier = Supplier(
      id: supplierId,
      position: position,
      data: data,
      isSelected: true,
      valueStreamId: valueStreamId,
    );

    _suppliers[supplierId] = supplier;
    _selectedSupplierId = supplierId;
    _notifyStateChanged();
    
    // Auto-save to database
    await saveToDatabase(valueStreamId, partNumber);
    
    _showMessage?.call('Supplier created');
    return supplier;
  }

  /// Update supplier position
  Future<void> updatePosition(String supplierId, Offset newPosition, int valueStreamId, String partNumber) async {
    final supplier = _suppliers[supplierId];
    if (supplier != null) {
      _suppliers[supplierId] = supplier.copyWith(position: newPosition);
      _notifyStateChanged();
      
      // Auto-save to database
      await saveToDatabase(valueStreamId, partNumber);
    }
  }

  /// Update supplier data
  Future<void> updateData(String supplierId, SupplierData newData, int valueStreamId, String partNumber) async {
    final supplier = _suppliers[supplierId];
    if (supplier != null) {
      _suppliers[supplierId] = supplier.copyWith(data: newData);
      _notifyStateChanged();
      
      // Auto-save to database
      await saveToDatabase(valueStreamId, partNumber);
      _showMessage?.call('Supplier data updated');
    }
  }

  /// Select a supplier
  void selectSupplier(String supplierId) {
    // First deselect current supplier
    if (_selectedSupplierId != null) {
      final current = _suppliers[_selectedSupplierId!];
      if (current != null) {
        _suppliers[_selectedSupplierId!] = current.copyWith(isSelected: false);
      }
    }

    // Select new supplier
    final supplier = _suppliers[supplierId];
    if (supplier != null) {
      _suppliers[supplierId] = supplier.copyWith(isSelected: true);
      _selectedSupplierId = supplierId;
      _notifyStateChanged();
    }
  }

  /// Deselect all suppliers
  void deselectAll() {
    if (_selectedSupplierId != null) {
      final supplier = _suppliers[_selectedSupplierId!];
      if (supplier != null) {
        _suppliers[_selectedSupplierId!] = supplier.copyWith(isSelected: false);
      }
      _selectedSupplierId = null;
      _notifyStateChanged();
    }
  }

  /// Delete a supplier
  Future<void> deleteSupplier(String supplierId, int valueStreamId, String partNumber) async {
    if (_suppliers.containsKey(supplierId)) {
      _suppliers.remove(supplierId);
      if (_selectedSupplierId == supplierId) {
        _selectedSupplierId = null;
      }
      _notifyStateChanged();
      _showMessage?.call('Supplier deleted');
      
      // Auto-save to database
      await saveToDatabase(valueStreamId, partNumber);
    }
  }

  /// Check if a supplier can be used as a connection point
  bool canConnectToSupplier(String supplierId) {
    return _suppliers.containsKey(supplierId);
  }

  /// Get supplier connection point for material connectors
  Offset? getConnectionPoint(String supplierId) {
    final supplier = _suppliers[supplierId];
    if (supplier != null) {
      // Return center-right point for outgoing connections
      return Offset(
        supplier.position.dx + 100, // Width of supplier box
        supplier.position.dy + 50,  // Half height of supplier box
      );
    }
    return null;
  }

  /// Clear all suppliers
  void clear() {
    _suppliers.clear();
    _selectedSupplierId = null;
    _notifyStateChanged();
  }

  /// Load supplier data from value stream - removed hardcoded defaults
  Future<SupplierData> _loadSupplierData(int valueStreamId) async {
    try {
      // Note: ValueStream table doesn't have leadTime/expediteTime fields
      // Return empty defaults (0) instead of hardcoded values
      return const SupplierData(
        leadTime: '0',
        expediteTime: '0',
      );
    } catch (e) {
      _showMessage?.call('Warning: Could not load supplier data');
      // Return empty defaults instead of hardcoded values
      return const SupplierData(
        leadTime: '0',
        expediteTime: '0',
      );
    }
  }

  void _notifyStateChanged() {
    _onStateChanged?.call();
  }

  /// Save suppliers to persistence (placeholder for future implementation)
  Map<String, dynamic> toJson() {
    return {
      'suppliers': _suppliers.map((key, supplier) => MapEntry(key, {
        'id': supplier.id,
        'position': {'dx': supplier.position.dx, 'dy': supplier.position.dy},
        'data': supplier.data.toJson(),
        'valueStreamId': supplier.valueStreamId,
      })),
      'selectedSupplierId': _selectedSupplierId,
    };
  }

  /// Load suppliers from persistence (placeholder for future implementation)
  void fromJson(Map<String, dynamic> json) {
    _suppliers.clear();
    
    final suppliersData = json['suppliers'] as Map<String, dynamic>?;
    if (suppliersData != null) {
      for (final entry in suppliersData.entries) {
        final data = entry.value as Map<String, dynamic>;
        final positionData = data['position'] as Map<String, dynamic>;
        final supplierData = data['data'] as Map<String, dynamic>;
        
        _suppliers[entry.key] = Supplier(
          id: data['id'] as String,
          position: Offset(
            positionData['dx'] as double,
            positionData['dy'] as double,
          ),
          data: SupplierData.fromJson(supplierData),
          valueStreamId: data['valueStreamId'] as int,
        );
      }
    }
    
    _selectedSupplierId = json['selectedSupplierId'] as String?;
    _notifyStateChanged();
  }

  /// Save suppliers to database
  Future<void> saveToDatabase(int valueStreamId, String partNumber) async {
    try {
      final db = await DatabaseProvider.getInstance();
      
      // Clear existing supplier entities for this value stream and part
      await db.customStatement(
        'DELETE FROM canvas_states WHERE value_stream_id = ? AND part_number = ? AND icon_type = ?',
        [valueStreamId, partNumber, 'supplier']
      );
      
      // Save all current suppliers
      for (final supplier in _suppliers.values) {
        await db.saveCanvasState(
          valueStreamId: valueStreamId,
          partNumber: partNumber,
          iconType: 'supplier',
          iconId: supplier.id,
          positionX: supplier.position.dx,
          positionY: supplier.position.dy,
          userData: supplier.toJson(),
        );
      }
    } catch (e) {
      _showMessage?.call('Warning: Could not save supplier data');
    }
  }

  /// Load suppliers from database
  Future<void> loadFromDatabase(int valueStreamId, String partNumber) async {
    try {
      final db = await DatabaseProvider.getInstance();
      
      final canvasStates = await db.customSelect(
        'SELECT * FROM canvas_states WHERE value_stream_id = ? AND part_number = ? AND icon_type = ?',
        variables: [
          drift.Variable.withInt(valueStreamId),
          drift.Variable.withString(partNumber), 
          drift.Variable.withString('supplier')
        ]
      ).get();
      
      _suppliers.clear();
      _selectedSupplierId = null;
      
      for (final state in canvasStates) {
        try {
          final supplier = Supplier.fromJson(
            state.data['userData'] as String,
            id: state.data['icon_id'] as String,
            position: Offset(
              state.data['position_x'] as double,
              state.data['position_y'] as double,
            ),
          );
          _suppliers[supplier.id] = supplier;
        } catch (e) {
          // Skip invalid supplier data
        }
      }
      
      _notifyStateChanged();
    } catch (e) {
      _showMessage?.call('Warning: Could not load supplier data');
    }
  }
}
