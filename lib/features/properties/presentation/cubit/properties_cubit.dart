import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/property.dart';
import '../../domain/repositories/properties_repository.dart';

sealed class PropertiesState {
  const PropertiesState();
}

class PropertiesStateLoading extends PropertiesState {
  const PropertiesStateLoading();
}

class PropertiesStateLoaded extends PropertiesState {
  final List<Property> properties;

  const PropertiesStateLoaded(this.properties);
}

class PropertiesStateError extends PropertiesState {
  final String message;

  const PropertiesStateError(this.message);
}

class PropertiesCubit extends Cubit<PropertiesState> {
  final PropertiesRepository _repository;
  final String _uid;

  PropertiesCubit(this._repository, {required String uid})
      : _uid = uid,
        super(const PropertiesStateLoading());

  Future<void> load() async {
    emit(const PropertiesStateLoading());
    try {
      final properties = await _repository.getAll(_uid);
      emit(PropertiesStateLoaded(properties));
    } catch (e) {
      emit(PropertiesStateError(e.toString()));
    }
  }

  Future<void> create({
    required String label,
    required String city,
    required String address,
    String? note,
  }) async {
    try {
      await _repository.create(
        uid: _uid,
        label: label,
        city: city,
        address: address,
        note: note,
      );
      await load();
    } catch (e) {
      emit(PropertiesStateError(e.toString()));
    }
  }

  Future<void> update({
    required String id,
    required String label,
    required String city,
    required String address,
    String? note,
  }) async {
    try {
      await _repository.update(
        uid: _uid,
        id: id,
        label: label,
        city: city,
        address: address,
        note: note,
      );
      await load();
    } catch (e) {
      emit(PropertiesStateError(e.toString()));
    }
  }

  Future<void> delete(String id) async {
    try {
      await _repository.delete(_uid, id);
      await load();
    } catch (e) {
      emit(PropertiesStateError(e.toString()));
    }
  }
}
