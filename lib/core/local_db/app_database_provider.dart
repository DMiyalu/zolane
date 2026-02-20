import 'app_database.dart';

class AppDatabaseProvider {
  static AppDatabase? _instance;

  static void setInstance(AppDatabase database) {
    _instance = database;
  }

  static Future<AppDatabase> getInstance() async {
    final existing = _instance;
    if (existing != null) return existing;

    final opened = await AppDatabase.open();
    _instance = opened;
    return opened;
  }
}
