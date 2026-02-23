class Property {
  final String id;
  final String userId;
  final String label;
  final String city;
  final String address;
  final String? note;
  final int createdAtMs;
  final int updatedAtMs;
  final int syncStatus;

  const Property({
    required this.id,
    required this.userId,
    required this.label,
    required this.city,
    required this.address,
    required this.note,
    required this.createdAtMs,
    required this.updatedAtMs,
    required this.syncStatus,
  });
}
