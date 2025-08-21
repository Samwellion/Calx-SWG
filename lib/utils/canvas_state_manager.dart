import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../logic/app_database.dart';
import '../models/canvas_icon.dart';
import '../models/material_connector.dart';
import '../models/kanban_loop.dart';
import '../models/kanban_post.dart';
import '../models/withdrawal_loop.dart';
import '../models/customer.dart';

/// Optimized Canvas State Manager for efficient saving and loading
/// Handles debounced saves and modular persistence operations
class CanvasStateManager {
  static const Duration _debounceDuration = Duration(milliseconds: 500);
  
  final AppDatabase _database;
  final int _valueStreamId;
  final Function(String message)? _showMessage;
  
  Timer? _saveTimer;
  String? _currentPartNumber;
  
  CanvasStateManager({
    required AppDatabase database,
    required int valueStreamId,
    Function(String message)? showMessage,
  }) : _database = database,
       _valueStreamId = valueStreamId,
       _showMessage = showMessage;

  /// Set the current part number for saves
  void setPartNumber(String? partNumber) {
    _currentPartNumber = partNumber;
  }

  /// Debounced save method to reduce excessive database writes
  void debouncedSave({
    required List<CanvasIcon> canvasIcons,
    required List<MaterialConnector> materialConnectors,
    required List<KanbanLoop> kanbanLoops,
    required List<KanbanPost> kanbanPosts,
    required List<WithdrawalLoop> withdrawalLoops,
    required List<Customer> customers,
    Map<String, Offset> customerDataBoxPositions = const {},
    Map<String, Offset> supplierDataBoxPositions = const {},
    Map<String, Offset> productionControlDataBoxPositions = const {},
    Map<String, Offset> truckDataBoxPositions = const {},
    Map<String, String> supplierDataBoxUserData = const {},
    Map<String, String> truckDataBoxUserData = const {},
  }) {
    _saveTimer?.cancel();
    _saveTimer = Timer(_debounceDuration, () {
      saveCanvasState(
        canvasIcons: canvasIcons,
        materialConnectors: materialConnectors,
        kanbanLoops: kanbanLoops,
        kanbanPosts: kanbanPosts,
        withdrawalLoops: withdrawalLoops,
        customers: customers,
        customerDataBoxPositions: customerDataBoxPositions,
        supplierDataBoxPositions: supplierDataBoxPositions,
        productionControlDataBoxPositions: productionControlDataBoxPositions,
        truckDataBoxPositions: truckDataBoxPositions,
        supplierDataBoxUserData: supplierDataBoxUserData,
        truckDataBoxUserData: truckDataBoxUserData,
      );
    });
  }

  /// Immediate save method for critical operations
  Future<void> saveCanvasState({
    required List<CanvasIcon> canvasIcons,
    required List<MaterialConnector> materialConnectors,
    required List<KanbanLoop> kanbanLoops,
    required List<KanbanPost> kanbanPosts,
    required List<WithdrawalLoop> withdrawalLoops,
    required List<Customer> customers,
    Map<String, Offset> customerDataBoxPositions = const {},
    Map<String, Offset> supplierDataBoxPositions = const {},
    Map<String, Offset> productionControlDataBoxPositions = const {},
    Map<String, Offset> truckDataBoxPositions = const {},
    Map<String, String> supplierDataBoxUserData = const {},
    Map<String, String> truckDataBoxUserData = const {},
  }) async {
    if (_currentPartNumber == null) return;

    try {
      // Clear existing state for this value stream and part
      await _database.clearCanvasState(
        valueStreamId: _valueStreamId,
        partNumber: _currentPartNumber!,
      );

      // Save all canvas elements in parallel for efficiency
      await Future.wait([
        _saveCustomers(customers),
        _saveCustomerDataBoxes(customerDataBoxPositions),
        _saveSupplierDataBoxes(supplierDataBoxPositions, supplierDataBoxUserData),
        _saveProductionControlDataBoxes(productionControlDataBoxPositions),
        _saveTruckDataBoxes(truckDataBoxPositions, truckDataBoxUserData),
        _saveCanvasIcons(canvasIcons),
        _saveMaterialConnectors(materialConnectors),
        _saveKanbanLoops(kanbanLoops),
        _saveKanbanPosts(kanbanPosts),
        _saveWithdrawalLoops(withdrawalLoops),
      ]);

      if (kDebugMode) {
        _showMessage?.call('Canvas state saved successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        _showMessage?.call('Error saving canvas state: $e');
      }
      // Silently ignore errors in production
    }
  }

  /// Save optimized customers using CustomerManager persistence
  Future<void> _saveCustomers(List<Customer> customers) async {
    for (final customer in customers) {
      await _database.saveCanvasState(
        valueStreamId: _valueStreamId,
        partNumber: _currentPartNumber!,
        iconType: 'customer',
        iconId: customer.id,
        positionX: customer.position.dx,
        positionY: customer.position.dy,
        userData: jsonEncode(customer.toJson()),
      );
    }
  }

  /// Save legacy customer data boxes (for backward compatibility)
  Future<void> _saveCustomerDataBoxes(Map<String, Offset> positions) async {
    for (final entry in positions.entries) {
      await _database.saveCanvasState(
        valueStreamId: _valueStreamId,
        partNumber: _currentPartNumber!,
        iconType: 'customerDataBox',
        iconId: entry.key,
        positionX: entry.value.dx,
        positionY: entry.value.dy,
      );
    }
  }

  /// Save supplier data boxes with user data
  Future<void> _saveSupplierDataBoxes(
    Map<String, Offset> positions,
    Map<String, String> userData,
  ) async {
    for (final entry in positions.entries) {
      await _database.saveCanvasState(
        valueStreamId: _valueStreamId,
        partNumber: _currentPartNumber!,
        iconType: 'supplierDataBox',
        iconId: entry.key,
        positionX: entry.value.dx,
        positionY: entry.value.dy,
        userData: userData[entry.key],
      );
    }
  }

  /// Save production control data boxes
  Future<void> _saveProductionControlDataBoxes(Map<String, Offset> positions) async {
    for (final entry in positions.entries) {
      await _database.saveCanvasState(
        valueStreamId: _valueStreamId,
        partNumber: _currentPartNumber!,
        iconType: 'productionControlDataBox',
        iconId: entry.key,
        positionX: entry.value.dx,
        positionY: entry.value.dy,
      );
    }
  }

  /// Save truck data boxes with user data
  Future<void> _saveTruckDataBoxes(
    Map<String, Offset> positions,
    Map<String, String> userData,
  ) async {
    for (final entry in positions.entries) {
      await _database.saveCanvasState(
        valueStreamId: _valueStreamId,
        partNumber: _currentPartNumber!,
        iconType: 'truckDataBox',
        iconId: entry.key,
        positionX: entry.value.dx,
        positionY: entry.value.dy,
        userData: userData[entry.key],
      );
    }
  }

  /// Save regular canvas icons
  Future<void> _saveCanvasIcons(List<CanvasIcon> icons) async {
    for (final icon in icons) {
      await _database.saveCanvasState(
        valueStreamId: _valueStreamId,
        partNumber: _currentPartNumber!,
        iconType: icon.type.toString(),
        iconId: icon.id,
        positionX: icon.position.dx,
        positionY: icon.position.dy,
      );
    }
  }

  /// Save material connectors
  Future<void> _saveMaterialConnectors(List<MaterialConnector> connectors) async {
    for (final connector in connectors) {
      await _database.saveCanvasState(
        valueStreamId: _valueStreamId,
        partNumber: _currentPartNumber!,
        iconType: 'materialConnector',
        iconId: connector.id,
        positionX: connector.position.dx,
        positionY: connector.position.dy,
        userData: jsonEncode(connector.toJson()),
      );
    }
  }

  /// Save kanban loops
  Future<void> _saveKanbanLoops(List<KanbanLoop> loops) async {
    for (final loop in loops) {
      await _database.saveCanvasState(
        valueStreamId: _valueStreamId,
        partNumber: _currentPartNumber!,
        iconType: 'kanbanLoop',
        iconId: loop.id,
        positionX: loop.kanbanIconPosition.dx,
        positionY: loop.kanbanIconPosition.dy,
        userData: jsonEncode(loop.toJson()),
      );
    }
  }

  /// Save kanban posts
  Future<void> _saveKanbanPosts(List<KanbanPost> posts) async {
    for (final post in posts) {
      await _database.saveCanvasState(
        valueStreamId: _valueStreamId,
        partNumber: _currentPartNumber!,
        iconType: 'kanbanPost',
        iconId: post.id,
        positionX: post.position.dx,
        positionY: post.position.dy,
        userData: jsonEncode(post.toJson()),
      );
    }
  }

  /// Save withdrawal loops
  Future<void> _saveWithdrawalLoops(List<WithdrawalLoop> loops) async {
    for (final loop in loops) {
      await _database.saveCanvasState(
        valueStreamId: _valueStreamId,
        partNumber: _currentPartNumber!,
        iconType: 'withdrawalLoop',
        iconId: loop.id,
        positionX: loop.kanbanIconPosition.dx,
        positionY: loop.kanbanIconPosition.dy,
        userData: jsonEncode(loop.toJson()),
      );
    }
  }

  /// Load canvas state for the current part number
  Future<void> loadCanvasState(String partNumber) async {
    try {
      setPartNumber(partNumber);
      
      final canvasState = await _database.loadCanvasState(
        valueStreamId: _valueStreamId,
        partNumber: partNumber,
      );

      if (kDebugMode && canvasState.isNotEmpty) {
        _showMessage?.call('Canvas state loaded: ${canvasState.length} items');
      }
    } catch (e) {
      if (kDebugMode) {
        _showMessage?.call('Error loading canvas state: $e');
      }
      // Silently ignore errors in production
    }
  }

  /// Cleanup resources
  void dispose() {
    _saveTimer?.cancel();
  }
}
