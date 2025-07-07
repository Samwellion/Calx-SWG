import 'package:shared_preferences/shared_preferences.dart';

class HomeScreenPrefs {
  static const String _companyKey = 'selectedCompany';
  static const String _plantKey = 'selectedPlant';
  static const String _valueStreamKey = 'selectedValueStream';
  static const String _processKey = 'selectedProcess';

  static Future<void> saveSelections({
    String? company,
    String? plant,
    String? valueStream,
    String? process,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (company != null) await prefs.setString(_companyKey, company);
    if (plant != null) await prefs.setString(_plantKey, plant);
    if (valueStream != null) {
      await prefs.setString(_valueStreamKey, valueStream);
    }
    if (process != null) await prefs.setString(_processKey, process);
  }

  static Future<Map<String, String?>> loadSelections() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'company': prefs.getString(_companyKey),
      'plant': prefs.getString(_plantKey),
      'valueStream': prefs.getString(_valueStreamKey),
      'process': prefs.getString(_processKey),
    };
  }

  static Future<void> clearSelections() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_companyKey);
    await prefs.remove(_plantKey);
    await prefs.remove(_valueStreamKey);
    await prefs.remove(_processKey);
  }
}
