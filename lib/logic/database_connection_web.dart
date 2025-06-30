// Web database connection
import 'package:drift/drift.dart';
import 'package:drift/web.dart';

Future<QueryExecutor> createDriftConnection() async {
  return WebDatabase('swg');
}
