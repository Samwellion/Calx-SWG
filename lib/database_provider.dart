import 'logic/app_database.dart';

class DatabaseProvider {
  static AppDatabase? _instance;

  static Future<AppDatabase> getInstance() async {
    _instance ??= await AppDatabase.open();
    return _instance!;
  }
}
