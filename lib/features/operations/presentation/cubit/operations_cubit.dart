import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/operation.dart';
import '../../domain/repositories/operations_repository.dart';

sealed class OperationsState {
  const OperationsState();
}

class OperationsStateLoading extends OperationsState {
  const OperationsStateLoading();
}

class OperationsStateLoaded extends OperationsState {
  final List<Operation> operations;

  const OperationsStateLoaded(this.operations);
}

class OperationsStateError extends OperationsState {
  final String message;

  const OperationsStateError(this.message);
}

class OperationsCubit extends Cubit<OperationsState> {
  final OperationsRepository _repository;
  final String _propertyId;
  final String _uid;

  OperationsCubit(this._repository, {required String uid, required String propertyId})
      : _uid = uid,
        _propertyId = propertyId,
        super(const OperationsStateLoading());

  Future<void> load() async {
    emit(const OperationsStateLoading());
    try {
      final operations = await _repository.getByProperty(
        uid: _uid,
        propertyId: _propertyId,
      );
      emit(OperationsStateLoaded(operations));
    } catch (e) {
      emit(OperationsStateError(e.toString()));
    }
  }

  Future<void> create({
    required OperationKind kind,
    required String category,
    required int amountCents,
    required int occurredAtMs,
    int? rentMonthMs,
    String? note,
  }) async {
    try {
      await _repository.create(
        uid: _uid,
        propertyId: _propertyId,
        kind: kind,
        category: category,
        amountCents: amountCents,
        occurredAtMs: occurredAtMs,
        rentMonthMs: rentMonthMs,
        note: note,
      );
      await load();
    } catch (e) {
      emit(OperationsStateError(e.toString()));
    }
  }

  Future<void> update({
    required String id,
    required OperationKind kind,
    required String category,
    required int amountCents,
    required int occurredAtMs,
    int? rentMonthMs,
    String? note,
  }) async {
    try {
      await _repository.update(
        uid: _uid,
        id: id,
        propertyId: _propertyId,
        kind: kind,
        category: category,
        amountCents: amountCents,
        occurredAtMs: occurredAtMs,
        rentMonthMs: rentMonthMs,
        note: note,
      );
      await load();
    } catch (e) {
      emit(OperationsStateError(e.toString()));
    }
  }

  Future<void> delete(String id) async {
    try {
      await _repository.delete(uid: _uid, id: id);
      await load();
    } catch (e) {
      emit(OperationsStateError(e.toString()));
    }
  }
}
