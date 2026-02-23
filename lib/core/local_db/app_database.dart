import 'dart:async';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  final Database db;

  const AppDatabase._(this.db);

  static const _dbName = 'zolane.db';
  static const _dbVersion = 4;

  static Future<AppDatabase> open() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, _dbName);

    final db = await openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
CREATE TABLE meta (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL
);
''');

        await db.execute('''
CREATE TABLE properties (
  id TEXT PRIMARY KEY,
  user_id TEXT,
  label TEXT NOT NULL,
  city TEXT NOT NULL,
  address TEXT NOT NULL,
  note TEXT,
  created_at_ms INTEGER NOT NULL,
  updated_at_ms INTEGER NOT NULL,
  sync_status INTEGER NOT NULL
);
''');

        await db.execute('''
CREATE TABLE operations (
  id TEXT PRIMARY KEY,
  user_id TEXT,
  property_id TEXT NOT NULL,
  kind INTEGER NOT NULL,
  category TEXT NOT NULL,
  amount_cents INTEGER NOT NULL,
  note TEXT,
  occurred_at_ms INTEGER NOT NULL,
  rent_month_ms INTEGER,
  created_at_ms INTEGER NOT NULL,
  updated_at_ms INTEGER NOT NULL,
  sync_status INTEGER NOT NULL,
  FOREIGN KEY(property_id) REFERENCES properties(id) ON DELETE CASCADE
);
''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
CREATE TABLE meta (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL
);
''');
        }

        if (oldVersion < 3) {
          final columns = await db.rawQuery('PRAGMA table_info(operations)');
          final hasRentMonthColumn = columns.any(
            (c) => (c['name'] as String?) == 'rent_month_ms',
          );

          if (!hasRentMonthColumn) {
            await db.execute(
              'ALTER TABLE operations ADD COLUMN rent_month_ms INTEGER',
            );
          }

          // Backfill rent month for existing rent income operations.
          // Default assumption: rent month == month of the payment date.
          // Only runs if the column exists (either previously or just added).
          final columnsAfter = hasRentMonthColumn
              ? columns
              : await db.rawQuery('PRAGMA table_info(operations)');
          final canBackfill = columnsAfter.any(
            (c) => (c['name'] as String?) == 'rent_month_ms',
          );
          if (!canBackfill) return;

          final rows = await db.query(
            'operations',
            columns: ['id', 'occurred_at_ms', 'sync_status'],
            where: 'kind = ? AND category = ? AND rent_month_ms IS NULL',
            whereArgs: [1, 'Loyer'],
          );

          for (final row in rows) {
            final id = row['id'] as String?;
            final occurredAt = (row['occurred_at_ms'] as num?)?.toInt();
            final syncStatus = (row['sync_status'] as num?)?.toInt();

            if (id == null || occurredAt == null || syncStatus == null) continue;
            if (syncStatus == SyncStatus.deleted) continue;

            final d = DateTime.fromMillisecondsSinceEpoch(occurredAt);
            final monthStart = DateTime(d.year, d.month, 1).millisecondsSinceEpoch;

            await db.update(
              'operations',
              {
                'rent_month_ms': monthStart,
                'sync_status': SyncStatus.dirty,
              },
              where: 'id = ?',
              whereArgs: [id],
              conflictAlgorithm: ConflictAlgorithm.abort,
            );
          }
        }

        if (oldVersion < 4) {
          // Add per-user scoping columns (nullable for legacy rows).
          final propCols = await db.rawQuery('PRAGMA table_info(properties)');
          final hasPropUserId = propCols.any((c) => (c['name'] as String?) == 'user_id');
          if (!hasPropUserId) {
            await db.execute('ALTER TABLE properties ADD COLUMN user_id TEXT');
          }

          final opCols = await db.rawQuery('PRAGMA table_info(operations)');
          final hasOpUserId = opCols.any((c) => (c['name'] as String?) == 'user_id');
          if (!hasOpUserId) {
            await db.execute('ALTER TABLE operations ADD COLUMN user_id TEXT');
          }
        }
      },
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );

    return AppDatabase._(db);
  }
}

/// 0 = synced, 1 = dirty (needs push), 2 = deleted (tombstone)
class SyncStatus {
  static const int synced = 0;
  static const int dirty = 1;
  static const int deleted = 2;
}
