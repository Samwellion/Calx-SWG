// database_connection.dart
// Platform-aware Drift database connection for web and mobile/desktop

import 'package:drift/drift.dart';

// Conditional imports for web vs. native
import 'database_connection_web.dart'
    if (dart.library.io) 'database_connection_native.dart';

Future<QueryExecutor> openConnection() => createDriftConnection();
