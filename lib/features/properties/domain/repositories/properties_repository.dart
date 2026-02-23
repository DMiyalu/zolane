import '../entities/property.dart';

abstract interface class PropertiesRepository {
  Future<List<Property>> getAll(String uid);

  Future<Property> create({
    required String uid,
    required String label,
    required String city,
    required String address,
    String? note,
  });

  Future<Property> update({
    required String uid,
    required String id,
    required String label,
    required String city,
    required String address,
    String? note,
  });

  Future<void> delete(String uid, String id);
}
