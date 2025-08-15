import '../models/canvas_connector.dart';
import 'connector_creation_handler.dart';

/// Example of how to integrate ConnectorCreationHandler into ProcessCanvasScreen
/// This shows the integration pattern for the common connection routine
class ConnectorCreationIntegrationExample {
  
  /// Example of how to initialize the handler in your canvas screen
  static ConnectorCreationHandler createHandler({
    required Function(String message, {Duration? duration}) showMessage,
    required Function(String itemId, String itemType) showConnectionHandles,
    required Function() hideConnectionHandles,
    required Function(CanvasConnector connector) addConnector,
    required Function() onConnectionCancelled,
  }) {
    return ConnectorCreationHandler(
      onShowMessage: showMessage,
      onShowConnectionHandles: showConnectionHandles,
      onHideConnectionHandles: hideConnectionHandles,
      onConnectorCreated: addConnector,
      onConnectionCancelled: onConnectionCancelled,
    );
  }

  /// Example of integration in ProcessCanvasScreen
  static String getIntegrationInstructions() {
    return '''
INTEGRATION STEPS:

1. Add handler to _ProcessCanvasScreenState:
   
   late ConnectorCreationHandler _connectorHandler;

2. Initialize in initState():

   _connectorHandler = ConnectorCreationHandler(
     onShowMessage: (message, {duration}) {
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text(message), duration: duration ?? Duration(seconds: 3))
       );
     },
     onShowConnectionHandles: _showConnectionHandles,
     onHideConnectionHandles: _hideConnectionHandles,
     onConnectorCreated: (connector) {
       setState(() {
         connectors.add(connector);
         selectedConnector = null;
       });
       _saveCanvasState();
     },
     onConnectionCancelled: () {
       setState(() {
         // Reset any UI state
       });
     },
   );

3. Update toolbar connector buttons:

   void _startConnectorMode(ConnectorType connectorType) {
     setState(() {
       selectedConnector = null;
     });
     _connectorHandler.startConnection(connectorType);
   }

4. Replace _handleItemTapForConnection logic:

   void _handleItemTapForConnection(String itemId, String itemType, Offset itemPosition, Size itemSize) {
     // Check if using common connection routine
     if (_connectorHandler.isConnecting) {
       _connectorHandler.handleItemSelection(itemId, itemType, itemPosition, itemSize);
       return;
     }
     
     // Keep existing logic for special cases (material connectors, kanban loops, etc.)
     // ... existing code for material connectors, kanban loops, withdrawal loops
   }

5. Update handle selection:

   void _selectConnectionHandle(ConnectionHandle handle) {
     setState(() {
       selectedHandle = handle;
     });
     
     // Check if using common connection routine
     if (_connectorHandler.isConnecting) {
       _connectorHandler.handleHandleSelection(handle);
       return;
     }
     
     // Keep existing logic for special workflows
     if (connectionMode != ConnectionMode.none) {
       _handleConnectionWithHandle(handle);
     }
   }

6. Add cancel support (ESC key, etc.):

   void _handleKeyEvent(KeyEvent event) {
     if (event is KeyDownEvent) {
       if (event.logicalKey == LogicalKeyboardKey.escape) {
         if (_connectorHandler.isConnecting) {
           _connectorHandler.cancelConnection();
           return;
         }
         
         // Keep existing cancel logic for other modes
         // ... existing cancel code
       }
     }
   }

ITEMS THAT USE COMMON ROUTINE:
✅ Processes (ProcessObject)
✅ Customer Data Boxes
✅ Supplier Data Boxes  
✅ Production Control Data Boxes
✅ Truck Data Boxes
✅ Canvas Icons (truck, factory, etc.)
✅ Kanban Posts

ITEMS THAT KEEP SPECIAL WORKFLOWS:
❌ Material Connectors (Supermarkets, FIFO, Uncontrolled, Buffer)
❌ Kanban Loops (need supermarket + process workflow)
❌ Withdrawal Loops (need process + supermarket workflow)

BENEFITS:
🎯 Consistent 4-step process: Supplier → Supplier Handle → Customer → Customer Handle
🔗 Connections stay attached to handles when items move
📍 Precise handle-to-handle connections
🎮 Better UX with clear step-by-step guidance
🛠️ Easier to maintain and debug
🚀 Extensible for new connector types
''';
  }
}
