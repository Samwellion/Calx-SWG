import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift;
import '../models/production_control.dart';
import '../database_provider.dart';

/// Optimized Production Control Manager for handling production control entities on the canvas
class ProductionControlManager {
  final Function(String message)? _showMessage;
  final Function()? _onStateChanged;
  
  final Map<String, ProductionControl> _productionControls = {};
  String? _selectedProductionControlId;

  ProductionControlManager({
    Function(String message)? showMessage,
    Function()? onStateChanged,
  }) : _showMessage = showMessage,
       _onStateChanged = onStateChanged;

  /// Get all production controls as a list
  List<ProductionControl> get productionControls => _productionControls.values.toList();

  /// Get selected production control ID
  String? get selectedProductionControlId => _selectedProductionControlId;

  /// Create a new production control on the canvas
  Future<ProductionControl> createProductionControl({
    required int valueStreamId,
    required String partNumber,
    Offset position = const Offset(100, 200),
    String? customLabel,
  }) async {
    final productionControlId = DateTime.now().millisecondsSinceEpoch.toString();
    
    // Load data from value stream
    final data = await _loadProductionControlData(valueStreamId);
    
    final productionControl = ProductionControl(
      id: productionControlId,
      position: position,
      data: data,
      valueStreamId: valueStreamId,
    );
    
    _productionControls[productionControlId] = productionControl;
    _selectedProductionControlId = productionControlId;
    _onStateChanged?.call();
    
    _showMessage?.call('Production Control created at position (${position.dx.toInt()}, ${position.dy.toInt()})');
    
    // Auto-save to database
    await saveToDatabase(valueStreamId, partNumber);
    
    return productionControl;
  }

  /// Update production control position
  Future<void> updatePosition(String productionControlId, Offset newPosition, int valueStreamId, String partNumber) async {
    final productionControl = _productionControls[productionControlId];
    if (productionControl != null) {
      _productionControls[productionControlId] = productionControl.copyWith(position: newPosition);
      _onStateChanged?.call();
      
      // Auto-save to database
      await saveToDatabase(valueStreamId, partNumber);
    }
  }

  /// Update production control data
  void updateData(String productionControlId, ProductionControlData newData) {
    final productionControl = _productionControls[productionControlId];
    if (productionControl != null) {
      _productionControls[productionControlId] = productionControl.copyWith(data: newData);
      _onStateChanged?.call();
      
      // Persist the update
      _persistProductionControl(_productionControls[productionControlId]!);
    }
  }

  /// Select a production control
  void selectProductionControl(String productionControlId) {
    if (_productionControls.containsKey(productionControlId)) {
      _selectedProductionControlId = productionControlId;
      _onStateChanged?.call();
    }
  }

  /// Deselect all production controls
  void deselectAll() {
    _selectedProductionControlId = null;
    _onStateChanged?.call();
  }

  /// Delete a production control
  Future<void> deleteProductionControl(String productionControlId, int valueStreamId, String partNumber) async {
    if (_productionControls.containsKey(productionControlId)) {
      _productionControls.remove(productionControlId);
      
      if (_selectedProductionControlId == productionControlId) {
        _selectedProductionControlId = null;
      }
      
      _onStateChanged?.call();
      _showMessage?.call('Production Control deleted');
      
      // Auto-save to database
      await saveToDatabase(valueStreamId, partNumber);
    }
  }

  /// Get production control by ID
  ProductionControl? getProductionControl(String productionControlId) {
    return _productionControls[productionControlId];
  }

  /// Check if production control is selected
  bool isSelected(String productionControlId) {
    return _selectedProductionControlId == productionControlId;
  }

  /// Clear all production controls
  void clearAll() {
    _productionControls.clear();
    _selectedProductionControlId = null;
    _onStateChanged?.call();
  }

  /// Load production control data from value stream database
  Future<ProductionControlData> _loadProductionControlData(int valueStreamId) async {
    try {
      final db = await DatabaseProvider.getInstance();
      final valueStream = await (db.select(db.valueStreams)
            ..where((vs) => vs.id.equals(valueStreamId)))
          .getSingleOrNull();
      
      if (valueStream != null) {
        return ProductionControlData(
          controlType: 'Daily',  // Default control type
          frequency: 'Schedule', // Default frequency
          additionalData: {
            'valueStreamId': valueStream.id.toString(),
            'valueStreamName': valueStream.name,
          },
        );
      }
    } catch (e) {
      _showMessage?.call('Error loading production control data: $e');
    }
    
    // Return default data if loading fails
    return const ProductionControlData();
  }

  /// Persist production control to database
  Future<void> _persistProductionControl(ProductionControl productionControl) async {
    try {
      // TODO: Implement production control persistence to database
      // For now, we'll store in a simple format
    } catch (e) {
      _showMessage?.call('Error saving production control: $e');
    }
  }

  /// Save production controls to database
  Future<void> saveToDatabase(int valueStreamId, String partNumber) async {
    try {
      final db = await DatabaseProvider.getInstance();
      
      // Clear existing production control entities for this value stream and part
      await db.customStatement(
        'DELETE FROM canvas_states WHERE value_stream_id = ? AND part_number = ? AND icon_type = ?',
        [valueStreamId, partNumber, 'productionControl']
      );
      
      // Save all current production controls
      for (final productionControl in _productionControls.values) {
        await db.saveCanvasState(
          valueStreamId: valueStreamId,
          partNumber: partNumber,
          iconType: 'productionControl',
          iconId: productionControl.id,
          positionX: productionControl.position.dx,
          positionY: productionControl.position.dy,
          userData: productionControl.toJson(),
        );
      }
    } catch (e) {
      _showMessage?.call('Warning: Could not save production control data');
    }
  }

  /// Load production controls from database
  Future<void> loadFromDatabase(int valueStreamId, String partNumber) async {
    try {
      final db = await DatabaseProvider.getInstance();
      
      final canvasStates = await (db.select(db.canvasStates)
        ..where((cs) => 
          cs.valueStreamId.equals(valueStreamId) &
          cs.partNumber.equals(partNumber) &
          cs.iconType.equals('productionControl'))
      ).get();
      
      _productionControls.clear();
      _selectedProductionControlId = null;
      
      for (final state in canvasStates) {
        try {
          final productionControl = ProductionControl.fromJson(
            state.userData!,
            id: state.iconId,
            position: Offset(
              state.positionX,
              state.positionY,
            ),
          );
          _productionControls[productionControl.id] = productionControl;
        } catch (e) {
          // Skip invalid production control data
        }
      }
      
      _onStateChanged?.call();
    } catch (e) {
      _showMessage?.call('Warning: Could not load production control data');
    }
  }

  /// Load all production controls from database
  Future<void> loadProductionControlsFromDatabase() async {
    try {
      // TODO: Implement loading production controls from database
    } catch (e) {
      _showMessage?.call('Error loading production controls: $e');
    }
  }

  /// Export production controls data
  Map<String, dynamic> exportData() {
    return {
      'productionControls': _productionControls.values.map((pc) => pc.toJson()).toList(),
      'selectedProductionControlId': _selectedProductionControlId,
    };
  }

  /// Import production controls data
  void importData(Map<String, dynamic> data) {
    try {
      _productionControls.clear();
      
      final productionControlsData = data['productionControls'] as List<dynamic>? ?? [];
      for (final productionControlJson in productionControlsData) {
        final productionControlMap = productionControlJson as Map<String, dynamic>;
        final productionControl = ProductionControl.fromJsonMap(productionControlMap);
        _productionControls[productionControl.id] = productionControl;
      }
      
      _selectedProductionControlId = data['selectedProductionControlId'] as String?;
      _onStateChanged?.call();
      
      _showMessage?.call('Loaded ${_productionControls.length} production controls');
    } catch (e) {
      _showMessage?.call('Error importing production controls: $e');
    }
  }

  /// Get production controls count
  int get productionControlCount => _productionControls.length;

  /// Get all production control IDs
  List<String> get productionControlIds => _productionControls.keys.toList();

  /// Check if any production controls exist
  bool get hasProductionControls => _productionControls.isNotEmpty;
}
