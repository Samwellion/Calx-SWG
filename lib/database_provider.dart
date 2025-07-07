import 'logic/app_database.dart';
import 'logic/database_connection.dart';

class DatabaseProvider {
  static AppDatabase? _instance;

  static Future<AppDatabase> getInstance() async {
    _instance ??= AppDatabase(await openConnection());
    return _instance!;
  }
}
