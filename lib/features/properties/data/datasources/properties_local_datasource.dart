import 'package:sqflite/sqflite.dart';

import '../../../../core/local_db/app_database.dart';
import '../../../../core/local_db/app_database_provider.dart';

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

  Future<PropertyModel?> getById(String id) async {
    final database = await _db();

    final rows = await database.db.query(
      'properties',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (rows.isEmpty) return null;
    return PropertyModel.fromMap(rows.first);
  }

  Future<List<PropertyModel>> getDirty() async {
    final database = await _db();

    final rows = await database.db.query(
      'properties',
      where: 'sync_status = ?',
      whereArgs: [SyncStatus.dirty],
      orderBy: 'updated_at_ms ASC',
    );

    return rows.map(PropertyModel.fromMap).toList(growable: false);
  }

  Future<List<PropertyModel>> getDeleted() async {
    final database = await _db();

    final rows = await database.db.query(
      'properties',
      where: 'sync_status = ?',
      whereArgs: [SyncStatus.deleted],
      orderBy: 'updated_at_ms ASC',
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

  Future<void> upsert(PropertyModel model) async {
    final database = await _db();
    await database.db.insert(
      'properties',
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
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

  Future<void> markSynced({required String id, required int updatedAtMs}) async {
    final database = await _db();
    await database.db.update(
      'properties',
      {
        'sync_status': SyncStatus.synced,
        'updated_at_ms': updatedAtMs,
      },
      where: 'id = ?',
      whereArgs: [id],
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<void> softDelete({required String id, required int updatedAtMs}) async {
    final database = await _db();

    await database.db.transaction((txn) async {
      await txn.update(
        'properties',
        {
          'sync_status': SyncStatus.deleted,
          'updated_at_ms': updatedAtMs,
        },
        where: 'id = ?',
        whereArgs: [id],
        conflictAlgorithm: ConflictAlgorithm.abort,
      );

      // Also tombstone linked operations so they won't sync back.
      await txn.update(
        'operations',
        {
          'sync_status': SyncStatus.deleted,
          'updated_at_ms': updatedAtMs,
        },
        where: 'property_id = ?',
        whereArgs: [id],
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
    });
  }

  Future<void> hardDelete(String id) async {
    final database = await _db();
    await database.db.delete(
      'properties',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
