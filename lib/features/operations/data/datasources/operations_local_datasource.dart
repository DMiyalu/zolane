import 'package:sqflite/sqflite.dart';

import '../../../../core/local_db/app_database.dart';
import '../../../../core/local_db/app_database_provider.dart';
import '../models/operation_model.dart';

class OperationsLocalDataSource {
  Future<AppDatabase> _db() => AppDatabaseProvider.getInstance();

  Future<List<OperationModel>> getByPropertyActive({
    required String uid,
    required String propertyId,
  }) async {
    final database = await _db();

    final rows = await database.db.query(
      'operations',
      where: 'user_id = ? AND property_id = ? AND sync_status != ?',
      whereArgs: [uid, propertyId, SyncStatus.deleted],
      orderBy: 'occurred_at_ms DESC, updated_at_ms DESC',
    );

    return rows.map(OperationModel.fromMap).toList(growable: false);
  }

  Future<List<OperationModel>> getDirty(String uid) async {
    final database = await _db();

    final rows = await database.db.query(
      'operations',
      where: 'user_id = ? AND sync_status = ?',
      whereArgs: [uid, SyncStatus.dirty],
      orderBy: 'updated_at_ms ASC',
    );

    return rows.map(OperationModel.fromMap).toList(growable: false);
  }

  Future<List<OperationModel>> getDeleted(String uid) async {
    final database = await _db();

    final rows = await database.db.query(
      'operations',
      where: 'user_id = ? AND sync_status = ?',
      whereArgs: [uid, SyncStatus.deleted],
      orderBy: 'updated_at_ms ASC',
    );

    return rows.map(OperationModel.fromMap).toList(growable: false);
  }

  Future<OperationModel?> getById({required String uid, required String id}) async {
    final database = await _db();

    final rows = await database.db.query(
      'operations',
      where: 'user_id = ? AND id = ?',
      whereArgs: [uid, id],
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
      where: 'user_id = ? AND id = ?',
      whereArgs: [model.userId, model.id],
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<void> markSynced({
    required String uid,
    required String id,
    required int updatedAtMs,
  }) async {
    final database = await _db();
    await database.db.update(
      'operations',
      {
        'sync_status': SyncStatus.synced,
        'updated_at_ms': updatedAtMs,
      },
      where: 'user_id = ? AND id = ?',
      whereArgs: [uid, id],
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<void> softDelete({
    required String uid,
    required String id,
    required int updatedAtMs,
  }) async {
    final database = await _db();

    await database.db.update(
      'operations',
      {
        'sync_status': SyncStatus.deleted,
        'updated_at_ms': updatedAtMs,
      },
      where: 'user_id = ? AND id = ?',
      whereArgs: [uid, id],
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<void> hardDelete({required String uid, required String id}) async {
    final database = await _db();
    await database.db.delete(
      'operations',
      where: 'user_id = ? AND id = ?',
      whereArgs: [uid, id],
    );
  }
}
