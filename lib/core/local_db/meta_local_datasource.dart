import 'package:sqflite/sqflite.dart';

import 'app_database_provider.dart';

class MetaLocalDataSource {
  Future<String?> getValue(String key) async {
    final db = (await AppDatabaseProvider.getInstance()).db;

    final rows = await db.query(
      'meta',
      columns: ['value'],
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );

    if (rows.isEmpty) return null;
    return rows.first['value'] as String;
  }

  Future<void> setValue(String key, String value) async {
    final db = (await AppDatabaseProvider.getInstance()).db;

    await db.insert(
      'meta',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
