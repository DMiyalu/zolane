import '../../../../core/local_db/app_database.dart';
import '../../../../core/local_db/app_database_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/property_model.dart';

class PropertiesLocalDataSource {
  Future<AppDatabase> _db() => AppDatabaseProvider.getInstance();

  Future<List<PropertyModel>> getAllActive() async {
    final database = await _db();

    final rows = await database.db.query(
      'properties',
      where: 'sync_status != ?',
      whereArgs: [SyncStatus.deleted],
      orderBy: 'updated_at_ms DESC',
    );

    return rows.map(PropertyModel.fromMap).toList(growable: false);
  }

  Future<void> insert(PropertyModel model) async {
    final database = await _db();

    await database.db.insert(
      'properties',
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<void> update(PropertyModel model) async {
    final database = await _db();

    await database.db.update(
      'properties',
      model.toMap(),
      where: 'id = ?',
      whereArgs: [model.id],
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<void> softDelete({required String id, required int updatedAtMs}) async {
    final database = await _db();

    await database.db.update(
      'properties',
      {
        'sync_status': SyncStatus.deleted,
        'updated_at_ms': updatedAtMs,
      },
      where: 'id = ?',
      whereArgs: [id],
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }
}
