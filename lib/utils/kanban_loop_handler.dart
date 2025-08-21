import 'package:flutter/material.dart';
import '../models/kanban_loop.dart';
import '../models/kanban_post.dart';
import '../models/material_connector.dart';

/// Handles kanban loop creation workflow
/// Manages the connection between supermarkets and kanban posts
class KanbanLoopHandler {
  final Function(String message, {Duration? duration}) _showMessage;
  final Function(KanbanLoop loop) _addKanbanLoop;
  // ignore: unused_field
  final Function() _onConnectionCancelled;

  // Connection state
  bool _isActive = false;
  MaterialConnector? _selectedSupermarket;
  KanbanPost? _selectedKanbanPost;

  KanbanLoopHandler({
    required Function(String message, {Duration? duration}) showMessage,
    required Function(KanbanLoop loop) addKanbanLoop,
    required Function() onConnectionCancelled,
  }) : _showMessage = showMessage,
       _addKanbanLoop = addKanbanLoop,
       _onConnectionCancelled = onConnectionCancelled;

  /// Start kanban loop creation mode
  void startKanbanLoopCreation() {
    _isActive = true;
    _selectedSupermarket = null;
    _selectedKanbanPost = null;
    _showMessage('Kanban Loop mode: Select supermarket (material connector) first');
  }

  /// Check if kanban loop creation is active
  bool get isActive => _isActive;

  /// Check if supermarket is selected
  bool get isSupermarketSelected => _selectedSupermarket != null;

  /// Select a supermarket (material connector) as the source
  bool selectSupermarket(MaterialConnector supermarket) {

    if (!_isActive) {
      return false;
    }

    if (_selectedSupermarket != null) {
      return false;
    }

    _selectedSupermarket = supermarket;
    _showMessage('Supermarket selected. Now select kanban post as supplier.');
    return true;
  }

  /// Select a kanban post as the supplier
  bool selectKanbanPost(KanbanPost kanbanPost) {

    if (!_isActive) {
      return false;
    }

    if (_selectedSupermarket == null) {
      _showMessage('Please select a supermarket first');
      return false;
    }

    if (_selectedKanbanPost != null) {
      return false;
    }

    _selectedKanbanPost = kanbanPost;
    
    return _createKanbanLoop();
  }

  /// Create the kanban loop connection
  bool _createKanbanLoop() {
    
    if (_selectedSupermarket == null || _selectedKanbanPost == null) {
      return false;
    }

    try {
      // Calculate positions for the kanban loop
      final supermarketPosition = _selectedSupermarket!.position;
      final kanbanPostPosition = _selectedKanbanPost!.position;
      
      // Calculate intermediate positions
      final midX = (supermarketPosition.dx + kanbanPostPosition.dx) / 2;
      final midY = (supermarketPosition.dy + kanbanPostPosition.dy) / 2;
      final kanbanIconPosition = Offset(midX, midY);
      
      // Create simple path points
      final pathPoints = [
        supermarketPosition,
        Offset(midX, supermarketPosition.dy),
        kanbanIconPosition,
        Offset(midX, kanbanPostPosition.dy),
        kanbanPostPosition,
      ];
      
      // Create the kanban loop with all required parameters
      final kanbanLoop = KanbanLoop(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        supermarketId: _selectedSupermarket!.id,
        supplierProcessId: _selectedKanbanPost!.id, // Kanban post acts as supplier
        supermarketHandlePosition: supermarketPosition,
        supplierHandlePosition: kanbanPostPosition,
        pathPoints: pathPoints,
        kanbanIconPosition: kanbanIconPosition,
      );
      
      
      _addKanbanLoop(kanbanLoop);
      _showMessage('Kanban loop created: Supermarket → Kanban Post');
      
      // Reset state
      reset();
      return true;
      
    } catch (e) {
      _showMessage('Error creating kanban loop: $e');
      return false;
    }
  }

  /// Reset the handler state
  void reset() {
    _isActive = false;
    _selectedSupermarket = null;
    _selectedKanbanPost = null;
  }

  /// Check if kanban loop can be created
  bool canCreateKanbanLoop() {
    return _isActive && _selectedSupermarket != null && _selectedKanbanPost != null;
  }

  /// Get current state information for debugging
  Map<String, dynamic> getState() {
    return {
      'isActive': _isActive,
      'supermarketSelected': _selectedSupermarket != null,
      'kanbanPostSelected': _selectedKanbanPost != null,
      'supermarketId': _selectedSupermarket?.id,
      'kanbanPostId': _selectedKanbanPost?.id,
    };
  }
}
