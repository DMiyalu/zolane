import '../../domain/entities/property.dart';

class PropertyModel {
  final String id;
  final String userId;
  final String label;
  final String city;
  final String address;
  final String? note;
  final int createdAtMs;
  final int updatedAtMs;
  final int syncStatus;

  const PropertyModel({
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

  factory PropertyModel.fromMap(Map<String, Object?> map) {
    return PropertyModel(
      id: map['id'] as String,
      userId: (map['user_id'] as String?) ?? '',
      label: map['label'] as String,
      city: map['city'] as String,
      address: map['address'] as String,
      note: map['note'] as String?,
      createdAtMs: (map['created_at_ms'] as num).toInt(),
      updatedAtMs: (map['updated_at_ms'] as num).toInt(),
      syncStatus: (map['sync_status'] as num).toInt(),
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'label': label,
      'city': city,
      'address': address,
      'note': note,
      'created_at_ms': createdAtMs,
      'updated_at_ms': updatedAtMs,
      'sync_status': syncStatus,
    };
  }

  Property toEntity() {
    return Property(
      id: id,
      userId: userId,
      label: label,
      city: city,
      address: address,
      note: note,
      createdAtMs: createdAtMs,
      updatedAtMs: updatedAtMs,
      syncStatus: syncStatus,
    );
  }
}
