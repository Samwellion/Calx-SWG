// Web database connection
import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

Future<QueryExecutor> createDriftConnection() async {
  final result = await WasmDatabase.open(
    databaseName: 'swg',
    sqlite3Uri: Uri.parse('sqlite3.wasm'),
    driftWorkerUri: Uri.parse('drift_worker.js'),
  );
  return result.resolvedExecutor;
}
