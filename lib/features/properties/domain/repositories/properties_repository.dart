import '../entities/property.dart';

abstract interface class PropertiesRepository {
  Future<List<Property>> getAll();

  Future<Property> create({
    required String label,
    required String city,
    required String address,
    String? note,
  });

  Future<Property> update({
    required String id,
    required String label,
    required String city,
    required String address,
    String? note,
  });

  Future<void> delete(String id);
}
