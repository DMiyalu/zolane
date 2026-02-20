import 'dart:async';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  final Database db;

  const AppDatabase._(this.db);

  static const _dbName = 'zolane.db';
  static const _dbVersion = 2;

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
  property_id TEXT NOT NULL,
  kind INTEGER NOT NULL,
  category TEXT NOT NULL,
  amount_cents INTEGER NOT NULL,
  note TEXT,
  occurred_at_ms INTEGER NOT NULL,
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
