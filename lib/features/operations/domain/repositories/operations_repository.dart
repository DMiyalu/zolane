import '../entities/operation.dart';

abstract interface class OperationsRepository {
  Future<List<Operation>> getByProperty(String propertyId);

  Future<Operation> create({
    required String propertyId,
    required OperationKind kind,
    required String category,
    required int amountCents,
    required int occurredAtMs,
    String? note,
  });

  Future<Operation> update({
    required String id,
    required String propertyId,
    required OperationKind kind,
    required String category,
    required int amountCents,
    required int occurredAtMs,
    String? note,
  });

  Future<void> delete(String id);
}
