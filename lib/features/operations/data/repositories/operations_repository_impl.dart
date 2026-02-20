import 'package:uuid/uuid.dart';

import '../../../../core/local_db/app_database.dart';
import '../../domain/entities/operation.dart';
import '../../domain/repositories/operations_repository.dart';
import '../datasources/operations_local_datasource.dart';
import '../models/operation_model.dart';

class OperationsRepositoryImpl implements OperationsRepository {
  final OperationsLocalDataSource _local;
  final Uuid _uuid;

  OperationsRepositoryImpl({OperationsLocalDataSource? local, Uuid? uuid})
      : _local = local ?? OperationsLocalDataSource(),
        _uuid = uuid ?? const Uuid();

  @override
  Future<List<Operation>> getByProperty(String propertyId) async {
    final models = await _local.getByPropertyActive(propertyId);
    final operations = models
        .map((m) => m.toEntity())
        .toList(growable: true);

    operations.sort((a, b) {
      final occurredCompare = b.occurredAtMs.compareTo(a.occurredAtMs);
      if (occurredCompare != 0) return occurredCompare;

      final updatedCompare = b.updatedAtMs.compareTo(a.updatedAtMs);
      if (updatedCompare != 0) return updatedCompare;

      return b.createdAtMs.compareTo(a.createdAtMs);
    });

    return operations;
  }

  @override
  Future<Operation> create({
    required String propertyId,
    required OperationKind kind,
    required String category,
    required int amountCents,
    required int occurredAtMs,
    int? rentMonthMs,
    String? note,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    final model = OperationModel(
      id: _uuid.v4(),
      propertyId: propertyId,
      kind: kind.sqlValue,
      category: category.trim(),
      amountCents: amountCents,
      note: (note == null || note.trim().isEmpty) ? null : note.trim(),
      occurredAtMs: occurredAtMs,
      rentMonthMs: rentMonthMs,
      createdAtMs: now,
      updatedAtMs: now,
      syncStatus: SyncStatus.dirty,
    );

    await _local.insert(model);
    return model.toEntity();
  }

  @override
  Future<Operation> update({
    required String id,
    required String propertyId,
    required OperationKind kind,
    required String category,
    required int amountCents,
    required int occurredAtMs,
    int? rentMonthMs,
    String? note,
  }) async {
    final existing = await _local.getById(id);
    if (existing == null) {
      throw StateError('Operation not found');
    }

    final now = DateTime.now().millisecondsSinceEpoch;

    final updated = OperationModel(
      id: id,
      propertyId: propertyId,
      kind: kind.sqlValue,
      category: category.trim(),
      amountCents: amountCents,
      note: (note == null || note.trim().isEmpty) ? null : note.trim(),
      occurredAtMs: occurredAtMs,
      rentMonthMs: rentMonthMs,
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
