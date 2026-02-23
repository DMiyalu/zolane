import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/local_db/meta_local_datasource.dart';
import '../operations/data/datasources/operations_local_datasource.dart';
import '../operations/data/models/operation_model.dart';
import '../properties/data/datasources/properties_local_datasource.dart';
import '../properties/data/models/property_model.dart';

class SyncService {
  final FirebaseFirestore _firestore;
  final PropertiesLocalDataSource _propertiesLocal;
  final OperationsLocalDataSource _operationsLocal;
  final MetaLocalDataSource _meta;

  SyncService({
    FirebaseFirestore? firestore,
    PropertiesLocalDataSource? propertiesLocal,
    OperationsLocalDataSource? operationsLocal,
    MetaLocalDataSource? meta,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _propertiesLocal = propertiesLocal ?? PropertiesLocalDataSource(),
        _operationsLocal = operationsLocal ?? OperationsLocalDataSource(),
        _meta = meta ?? MetaLocalDataSource();

  Future<void> syncNow({required String uid}) async {
    final lastSyncKey = 'last_sync_ms:$uid';

    final lastSyncRaw = await _meta.getValue(lastSyncKey);
    final lastSyncMs = int.tryParse(lastSyncRaw ?? '') ?? 0;

    var maxProcessedMs = lastSyncMs;

    await _pushLocal(uid, onProcessed: (ms) {
      maxProcessedMs = math.max(maxProcessedMs, ms);
    });

    await _pullRemote(uid, lastSyncMs: lastSyncMs, onProcessed: (ms) {
      maxProcessedMs = math.max(maxProcessedMs, ms);
    });

    await _meta.setValue(lastSyncKey, maxProcessedMs.toString());
  }

  CollectionReference<Map<String, dynamic>> _propertiesRef(String uid) {
    return _firestore.collection('users').doc(uid).collection('properties');
  }

  CollectionReference<Map<String, dynamic>> _operationsRef(String uid) {
    return _firestore.collection('users').doc(uid).collection('operations');
  }

  Future<void> _pushLocal(String uid, {required void Function(int) onProcessed}) async {
    // Push creates/updates first so remote has the base documents.
    final propertiesDirty = await _propertiesLocal.getDirty(uid);
    for (final p in propertiesDirty) {
      await _propertiesRef(uid).doc(p.id).set(
        {
          'id': p.id,
          'label': p.label,
          'city': p.city,
          'address': p.address,
          'note': p.note,
          'user_id': uid,
          'created_at_ms': p.createdAtMs,
          'updated_at_ms': p.updatedAtMs,
          'deleted': false,
        },
        SetOptions(merge: true),
      );

      await _propertiesLocal.markSynced(uid: uid, id: p.id, updatedAtMs: p.updatedAtMs);
      onProcessed(p.updatedAtMs);
    }

    final operationsDirty = await _operationsLocal.getDirty(uid);
    for (final op in operationsDirty) {
      await _operationsRef(uid).doc(op.id).set(
        {
          'id': op.id,
          'property_id': op.propertyId,
          'kind': op.kind,
          'category': op.category,
          'amount_cents': op.amountCents,
          'note': op.note,
          'occurred_at_ms': op.occurredAtMs,
          'rent_month_ms': op.rentMonthMs,
          'user_id': uid,
          'created_at_ms': op.createdAtMs,
          'updated_at_ms': op.updatedAtMs,
          'deleted': false,
        },
        SetOptions(merge: true),
      );

      await _operationsLocal.markSynced(uid: uid, id: op.id, updatedAtMs: op.updatedAtMs);
      onProcessed(op.updatedAtMs);
    }

    // Push operation tombstones BEFORE property hard-delete cascades remove them locally.
    final operationsDeleted = await _operationsLocal.getDeleted(uid);
    for (final op in operationsDeleted) {
      await _operationsRef(uid).doc(op.id).set(
        {
          'id': op.id,
          'updated_at_ms': op.updatedAtMs,
          'deleted': true,
        },
        SetOptions(merge: true),
      );

      await _operationsLocal.hardDelete(uid: uid, id: op.id);
      onProcessed(op.updatedAtMs);
    }

    // Finally push property tombstones and then cleanup locally.
    final propertiesDeleted = await _propertiesLocal.getDeleted(uid);
    for (final p in propertiesDeleted) {
      await _propertiesRef(uid).doc(p.id).set(
        {
          'id': p.id,
          'updated_at_ms': p.updatedAtMs,
          'deleted': true,
        },
        SetOptions(merge: true),
      );

      await _propertiesLocal.hardDelete(uid: uid, id: p.id);
      onProcessed(p.updatedAtMs);
    }
  }

  Future<void> _pullRemote(
    String uid, {
    required int lastSyncMs,
    required void Function(int) onProcessed,
  }) async {
    final propSnap = await _propertiesRef(uid)
        .where('updated_at_ms', isGreaterThan: lastSyncMs)
        .get();

    for (final doc in propSnap.docs) {
      final data = doc.data();
      final updatedAtMs = _asInt(data['updated_at_ms']);
      if (updatedAtMs == null) continue;

      onProcessed(updatedAtMs);

      final deleted = (data['deleted'] == true);
      final local = await _propertiesLocal.getById(uid, doc.id);

      if (local != null && local.updatedAtMs > updatedAtMs) {
        continue;
      }

      if (deleted) {
        await _propertiesLocal.hardDelete(uid: uid, id: doc.id);
        continue;
      }

      final model = _propertyFromRemote(doc.id, data);
      if (model == null) continue;

      final scoped = PropertyModel(
        id: model.id,
        userId: uid,
        label: model.label,
        city: model.city,
        address: model.address,
        note: model.note,
        createdAtMs: model.createdAtMs,
        updatedAtMs: model.updatedAtMs,
        syncStatus: model.syncStatus,
      );

      await _propertiesLocal.upsert(scoped);
      await _propertiesLocal.markSynced(uid: uid, id: scoped.id, updatedAtMs: scoped.updatedAtMs);
    }

    final opSnap = await _operationsRef(uid)
        .where('updated_at_ms', isGreaterThan: lastSyncMs)
        .get();

    for (final doc in opSnap.docs) {
      final data = doc.data();
      final updatedAtMs = _asInt(data['updated_at_ms']);
      if (updatedAtMs == null) continue;

      onProcessed(updatedAtMs);

      final deleted = (data['deleted'] == true);
      final local = await _operationsLocal.getById(uid: uid, id: doc.id);

      final localUpdatedAt = local?.updatedAtMs;
      if (localUpdatedAt != null && localUpdatedAt > updatedAtMs) {
        continue;
      }

      if (deleted) {
        await _operationsLocal.hardDelete(uid: uid, id: doc.id);
        continue;
      }

      final model = _operationFromRemote(doc.id, data);
      if (model == null) continue;

      final scoped = OperationModel(
        id: model.id,
        userId: uid,
        propertyId: model.propertyId,
        kind: model.kind,
        category: model.category,
        amountCents: model.amountCents,
        note: model.note,
        occurredAtMs: model.occurredAtMs,
        rentMonthMs: model.rentMonthMs,
        createdAtMs: model.createdAtMs,
        updatedAtMs: model.updatedAtMs,
        syncStatus: model.syncStatus,
      );

      // Skip operations that reference a property not present locally
      // (prevents foreign key errors). Properties are pulled first.
      final hasProperty = await _propertiesLocal.getById(uid, scoped.propertyId);
      if (hasProperty == null) continue;

      await _operationsLocal.upsert(scoped);
      await _operationsLocal.markSynced(uid: uid, id: scoped.id, updatedAtMs: scoped.updatedAtMs);
    }
  }

  static PropertyModel? _propertyFromRemote(String id, Map<String, dynamic> data) {
    final label = data['label'] as String?;
    final city = data['city'] as String?;
    final address = data['address'] as String?;

    final createdAtMs = _asInt(data['created_at_ms']);
    final updatedAtMs = _asInt(data['updated_at_ms']);

    if (label == null || city == null || address == null) return null;
    if (createdAtMs == null || updatedAtMs == null) return null;

    return PropertyModel(
      id: id,
      userId: (data['user_id'] as String?) ?? '',
      label: label,
      city: city,
      address: address,
      note: data['note'] as String?,
      createdAtMs: createdAtMs,
      updatedAtMs: updatedAtMs,
      syncStatus: 0,
    );
  }

  static OperationModel? _operationFromRemote(String id, Map<String, dynamic> data) {
    final propertyId = data['property_id'] as String?;
    final kind = _asInt(data['kind']);
    final category = data['category'] as String?;
    final amountCents = _asInt(data['amount_cents']);
    final occurredAtMs = _asInt(data['occurred_at_ms']);
    final rentMonthMs = _asInt(data['rent_month_ms']);
    final createdAtMs = _asInt(data['created_at_ms']);
    final updatedAtMs = _asInt(data['updated_at_ms']);

    if (propertyId == null) return null;
    if (kind == null) return null;
    if (category == null) return null;
    if (amountCents == null) return null;
    if (occurredAtMs == null) return null;
    if (createdAtMs == null) return null;
    if (updatedAtMs == null) return null;

    return OperationModel(
      id: id,
      userId: (data['user_id'] as String?) ?? '',
      propertyId: propertyId,
      kind: kind,
      category: category,
      amountCents: amountCents,
      note: data['note'] as String?,
      occurredAtMs: occurredAtMs,
      rentMonthMs: rentMonthMs,
      createdAtMs: createdAtMs,
      updatedAtMs: updatedAtMs,
      syncStatus: 0,
    );
  }

  static int? _asInt(Object? v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }
}
