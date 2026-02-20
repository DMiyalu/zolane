enum OperationKind {
  expense,
  income,
}

extension OperationKindSql on OperationKind {
  int get sqlValue {
    return switch (this) {
      OperationKind.expense => 0,
      OperationKind.income => 1,
    };
  }

  static OperationKind fromSqlValue(int value) {
    return switch (value) {
      0 => OperationKind.expense,
      1 => OperationKind.income,
      _ => OperationKind.expense,
    };
  }
}

class Operation {
  final String id;
  final String propertyId;
  final OperationKind kind;
  final String category;
  final int amountCents;
  final String? note;
  final int occurredAtMs;
  /// For rent payments: month concerned by the payment (stored as a month start timestamp).
  final int? rentMonthMs;
  final int createdAtMs;
  final int updatedAtMs;
  final int syncStatus;

  const Operation({
    required this.id,
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
}
