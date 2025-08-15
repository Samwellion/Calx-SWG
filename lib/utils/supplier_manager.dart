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

  /// Get all suppliers as a list
  List<Supplier> get suppliers => _suppliers.values.toList();

  /// Get selected supplier ID
  String? get selectedSupplierId => _selectedSupplierId;

  /// Create a new supplier on the canvas
  Future<Supplier> createSupplier({
    required int valueStreamId,
    required String partNumber,
    Offset position = const Offset(100, 200),
    String? customLabel,
  }) async {
    final supplierId = DateTime.now().millisecondsSinceEpoch.toString();
    
    // Load data from value stream
    final data = await _loadSupplierData(valueStreamId);
    
    final supplier = Supplier(
      id: supplierId,
      position: position,
      data: data,
      valueStreamId: valueStreamId,
    );
    
    _suppliers[supplierId] = supplier;
    _selectedSupplierId = supplierId;
    _onStateChanged?.call();
    
    _showMessage?.call('Supplier created at position (${position.dx.toInt()}, ${position.dy.toInt()})');
    
    // Auto-save to database
    await saveToDatabase(valueStreamId, partNumber);
    
    return supplier;
  }

  /// Update supplier position
  Future<void> updatePosition(String supplierId, Offset newPosition, int valueStreamId, String partNumber) async {
    final supplier = _suppliers[supplierId];
    if (supplier != null) {
      _suppliers[supplierId] = supplier.copyWith(position: newPosition);
      _onStateChanged?.call();
      
      // Auto-save to database
      await saveToDatabase(valueStreamId, partNumber);
    }
  }

  /// Update supplier data
  void updateData(String supplierId, SupplierData newData) {
    final supplier = _suppliers[supplierId];
    if (supplier != null) {
      _suppliers[supplierId] = supplier.copyWith(data: newData);
      _onStateChanged?.call();
      
      // Persist the update
      _persistSupplier(_suppliers[supplierId]!);
    }
  }

  /// Select a supplier
  void selectSupplier(String supplierId) {
    if (_suppliers.containsKey(supplierId)) {
      _selectedSupplierId = supplierId;
      _onStateChanged?.call();
    }
  }

  /// Deselect all suppliers
  void deselectAll() {
    _selectedSupplierId = null;
    _onStateChanged?.call();
  }

  /// Delete a supplier
  Future<void> deleteSupplier(String supplierId, int valueStreamId, String partNumber) async {
    if (_suppliers.containsKey(supplierId)) {
      _suppliers.remove(supplierId);
      
      if (_selectedSupplierId == supplierId) {
        _selectedSupplierId = null;
      }
      
      _onStateChanged?.call();
      _showMessage?.call('Supplier deleted');
      
      // Auto-save to database
      await saveToDatabase(valueStreamId, partNumber);
    }
  }

  /// Get supplier by ID
  Supplier? getSupplier(String supplierId) {
    return _suppliers[supplierId];
  }

  /// Check if supplier is selected
  bool isSelected(String supplierId) {
    return _selectedSupplierId == supplierId;
  }

  /// Clear all suppliers
  void clearAll() {
    _suppliers.clear();
    _selectedSupplierId = null;
    _onStateChanged?.call();
  }

  /// Load supplier data from value stream database
  Future<SupplierData> _loadSupplierData(int valueStreamId) async {
    try {
      final db = await DatabaseProvider.getInstance();
      final valueStream = await (db.select(db.valueStreams)
            ..where((vs) => vs.id.equals(valueStreamId)))
          .getSingleOrNull();
      
      if (valueStream != null) {
        return SupplierData(
          leadTime: '0',  // Start with empty/zero values
          expediteTime: '0',  // Start with empty/zero values
          additionalData: {
            'valueStreamId': valueStream.id.toString(),
            'valueStreamName': valueStream.name,
          },
        );
      }
    } catch (e) {
      _showMessage?.call('Error loading supplier data: $e');
    }
    
    // Return default data if loading fails
    return const SupplierData();
  }

  /// Persist supplier to database
  Future<void> _persistSupplier(Supplier supplier) async {
    try {
      // TODO: Implement supplier persistence to database
      // For now, we'll store in a simple format
    } catch (e) {
      _showMessage?.call('Error saving supplier: $e');
    }
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
      
      final canvasStates = await (db.select(db.canvasStates)
        ..where((cs) => 
          cs.valueStreamId.equals(valueStreamId) &
          cs.partNumber.equals(partNumber) &
          cs.iconType.equals('supplier'))
      ).get();
      
      _suppliers.clear();
      _selectedSupplierId = null;
      
      for (final state in canvasStates) {
        try {
          final supplier = Supplier.fromJson(
            state.userData!,
            id: state.iconId,
            position: Offset(
              state.positionX,
              state.positionY,
            ),
          );
          _suppliers[supplier.id] = supplier;
        } catch (e) {
          // Skip invalid supplier data
        }
      }
      
      _onStateChanged?.call();
    } catch (e) {
      _showMessage?.call('Warning: Could not load supplier data');
    }
  }

  /// Load all suppliers from database
  Future<void> loadSuppliersFromDatabase() async {
    try {
      // TODO: Implement loading suppliers from database
    } catch (e) {
      _showMessage?.call('Error loading suppliers: $e');
    }
  }

  /// Export suppliers data
  Map<String, dynamic> exportData() {
    return {
      'suppliers': _suppliers.values.map((s) => s.toJson()).toList(),
      'selectedSupplierId': _selectedSupplierId,
    };
  }

  /// Import suppliers data
  void importData(Map<String, dynamic> data) {
    try {
      _suppliers.clear();
      
      final suppliersData = data['suppliers'] as List<dynamic>? ?? [];
      for (final supplierJson in suppliersData) {
        final supplierMap = supplierJson as Map<String, dynamic>;
        final supplier = Supplier.fromJsonMap(supplierMap);
        _suppliers[supplier.id] = supplier;
      }
      
      _selectedSupplierId = data['selectedSupplierId'] as String?;
      _onStateChanged?.call();
      
      _showMessage?.call('Loaded ${_suppliers.length} suppliers');
    } catch (e) {
      _showMessage?.call('Error importing suppliers: $e');
    }
  }

  /// Get suppliers count
  int get supplierCount => _suppliers.length;

  /// Get all supplier IDs
  List<String> get supplierIds => _suppliers.keys.toList();

  /// Check if any suppliers exist
  bool get hasSuppliers => _suppliers.isNotEmpty;
}
