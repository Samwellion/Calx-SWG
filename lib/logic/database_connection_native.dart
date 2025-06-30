// Native (mobile/desktop) database connection
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

Future<QueryExecutor> createDriftConnection() async {
  final dbFolder = await getApplicationDocumentsDirectory();
  final file = File(p.join(dbFolder.path, 'swg.sqlite'));
  return NativeDatabase(file);
}
