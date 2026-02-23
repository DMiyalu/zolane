import '../../domain/entities/operation.dart';

class OperationModel {
  final String id;
  final String userId;
  final String propertyId;
  final int kind;
  final String category;
  final int amountCents;
  final String? note;
  final int occurredAtMs;
  final int? rentMonthMs;
  final int createdAtMs;
  final int updatedAtMs;
  final int syncStatus;

  const OperationModel({
    required this.id,
    required this.userId,
    required this.propertyId,
    required this.kind,
    required this.category,
    required this.amountCents,
    required this.note,
    required this.occurredAtMs,
    required this.rentMonthMs,
    required this.createdAtMs,
    required this.updatedAtMs,
    required this.syncStatus,
  });

  factory OperationModel.fromMap(Map<String, Object?> map) {
    return OperationModel(
      id: map['id'] as String,
      userId: (map['user_id'] as String?) ?? '',
      propertyId: map['property_id'] as String,
      kind: (map['kind'] as num).toInt(),
      category: map['category'] as String,
      amountCents: (map['amount_cents'] as num).toInt(),
      note: map['note'] as String?,
      occurredAtMs: (map['occurred_at_ms'] as num).toInt(),
      rentMonthMs: (map['rent_month_ms'] as num?)?.toInt(),
      createdAtMs: (map['created_at_ms'] as num).toInt(),
      updatedAtMs: (map['updated_at_ms'] as num).toInt(),
      syncStatus: (map['sync_status'] as num).toInt(),
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'property_id': propertyId,
      'kind': kind,
      'category': category,
      'amount_cents': amountCents,
      'note': note,
      'occurred_at_ms': occurredAtMs,
      'rent_month_ms': rentMonthMs,
      'created_at_ms': createdAtMs,
      'updated_at_ms': updatedAtMs,
      'sync_status': syncStatus,
    };
  }

  Operation toEntity() {
    return Operation(
      id: id,
      userId: userId,
      propertyId: propertyId,
      kind: OperationKindSql.fromSqlValue(kind),
      category: category,
      amountCents: amountCents,
      note: note,
      occurredAtMs: occurredAtMs,
      rentMonthMs: rentMonthMs,
      createdAtMs: createdAtMs,
      updatedAtMs: updatedAtMs,
      syncStatus: syncStatus,
    );
  }
}
