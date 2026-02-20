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
  Future<List<Property>> getAll() async {
    final models = await _local.getAllActive();
    return models.map((m) => m.toEntity()).toList(growable: false);
  }

  @override
  Future<Property> create({
    required String label,
    required String city,
    required String address,
    String? note,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    final model = PropertyModel(
      id: _uuid.v4(),
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
    required String id,
    required String label,
    required String city,
    required String address,
    String? note,
  }) async {
    final existing = await _local.getById(id);
    if (existing == null) {
      throw StateError('Property not found');
    }
    final now = DateTime.now().millisecondsSinceEpoch;

    final updated = PropertyModel(
      id: id,
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
  Future<void> delete(String id) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await _local.softDelete(id: id, updatedAtMs: now);
  }
}
