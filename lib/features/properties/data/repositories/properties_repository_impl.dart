import 'package:uuid/uuid.dart';

import '../../../../core/local_db/app_database.dart';
import '../datasources/properties_local_datasource.dart';
import '../models/property_model.dart';
import '../../domain/entities/property.dart';
import '../../domain/repositories/properties_repository.dart';

class PropertiesRepositoryImpl implements PropertiesRepository {
  final PropertiesLocalDataSource _local;
  final Uuid _uuid;

  PropertiesRepositoryImpl({PropertiesLocalDataSource? local, Uuid? uuid})
      : _local = local ?? PropertiesLocalDataSource(),
        _uuid = uuid ?? const Uuid();

  @override
  Future<List<Property>> getAll(String uid) async {
    // Migrate legacy local data (pre multi-user) to the current account.
    await _local.claimUnowned(uid);

    final models = await _local.getAllActive(uid);
    return models.map((m) => m.toEntity()).toList(growable: false);
  }

  @override
  Future<Property> create({
    required String uid,
    required String label,
    required String city,
    required String address,
    String? note,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    final model = PropertyModel(
      id: _uuid.v4(),
      userId: uid,
      label: label.trim(),
      city: city.trim(),
      address: address.trim(),
      note: (note == null || note.trim().isEmpty) ? null : note.trim(),
      createdAtMs: now,
      updatedAtMs: now,
      syncStatus: SyncStatus.dirty,
    );

    await _local.insert(model);
    return model.toEntity();
  }

  @override
  Future<Property> update({
    required String uid,
    required String id,
    required String label,
    required String city,
    required String address,
    String? note,
  }) async {
    final existing = await _local.getById(uid, id);
    if (existing == null) {
      throw StateError('Property not found');
    }
    final now = DateTime.now().millisecondsSinceEpoch;

    final updated = PropertyModel(
      id: id,
      userId: uid,
      label: label.trim(),
      city: city.trim(),
      address: address.trim(),
      note: (note == null || note.trim().isEmpty) ? null : note.trim(),
      createdAtMs: existing.createdAtMs,
      updatedAtMs: now,
      syncStatus: SyncStatus.dirty,
    );

    await _local.update(updated);
    return updated.toEntity();
  }

  @override
  Future<void> delete(String uid, String id) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await _local.softDelete(uid: uid, id: id, updatedAtMs: now);
  }
}
