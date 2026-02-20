import 'package:sqflite/sqflite.dart';

import '../../../../core/local_db/app_database.dart';
import '../../../../core/local_db/app_database_provider.dart';
import '../models/operation_model.dart';

class OperationsLocalDataSource {
  Future<AppDatabase> _db() => AppDatabaseProvider.getInstance();

  Future<List<OperationModel>> getByPropertyActive(String propertyId) async {
    final database = await _db();

    final rows = await database.db.query(
      'operations',
      where: 'property_id = ? AND sync_status != ?',
      whereArgs: [propertyId, SyncStatus.deleted],
      orderBy: 'occurred_at_ms DESC, updated_at_ms DESC',
    );

    return rows.map(OperationModel.fromMap).toList(growable: false);
  }

  Future<List<OperationModel>> getDirty() async {
    final database = await _db();

    final rows = await database.db.query(
      'operations',
      where: 'sync_status = ?',
      whereArgs: [SyncStatus.dirty],
      orderBy: 'updated_at_ms ASC',
    );

    return rows.map(OperationModel.fromMap).toList(growable: false);
  }

  Future<List<OperationModel>> getDeleted() async {
    final database = await _db();

    final rows = await database.db.query(
      'operations',
      where: 'sync_status = ?',
      whereArgs: [SyncStatus.deleted],
      orderBy: 'updated_at_ms ASC',
    );

    return rows.map(OperationModel.fromMap).toList(growable: false);
  }

  Future<OperationModel?> getById(String id) async {
    final database = await _db();

    final rows = await database.db.query(
      'operations',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (rows.isEmpty) return null;
    return OperationModel.fromMap(rows.first);
  }

  Future<void> insert(OperationModel model) async {
    final database = await _db();

    await database.db.insert(
      'operations',
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<void> upsert(OperationModel model) async {
    final database = await _db();
    await database.db.insert(
      'operations',
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> update(OperationModel model) async {
    final database = await _db();

    await database.db.update(
      'operations',
      model.toMap(),
      where: 'id = ?',
      whereArgs: [model.id],
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<void> markSynced({required String id, required int updatedAtMs}) async {
    final database = await _db();
    await database.db.update(
      'operations',
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

    await database.db.update(
      'operations',
      {
        'sync_status': SyncStatus.deleted,
        'updated_at_ms': updatedAtMs,
      },
      where: 'id = ?',
      whereArgs: [id],
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<void> hardDelete(String id) async {
    final database = await _db();
    await database.db.delete(
      'operations',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
