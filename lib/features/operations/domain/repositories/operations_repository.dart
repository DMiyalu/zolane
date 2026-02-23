import '../entities/operation.dart';

abstract interface class OperationsRepository {
  Future<List<Operation>> getByProperty({
    required String uid,
    required String propertyId,
  });

  Future<Operation> create({
    required String uid,
    required String propertyId,
    required OperationKind kind,
    required String category,
    required int amountCents,
    required int occurredAtMs,
    int? rentMonthMs,
    String? note,
  });

  Future<Operation> update({
    required String uid,
    required String id,
    required String propertyId,
    required OperationKind kind,
    required String category,
    required int amountCents,
    required int occurredAtMs,
    int? rentMonthMs,
    String? note,
  });

  Future<void> delete({required String uid, required String id});
}
