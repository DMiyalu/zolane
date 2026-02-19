import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

sealed class AuthState {
  const AuthState();
}

class AuthStateInitial extends AuthState {
  const AuthStateInitial();
}

class AuthStateSignedOut extends AuthState {
  const AuthStateSignedOut();
}

class AuthStateSignedIn extends AuthState {
  final AppUser user;

  const AuthStateSignedIn(this.user);
}

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  StreamSubscription<AppUser?>? _sub;

  AuthCubit(this._authRepository) : super(const AuthStateInitial());

  void start() {
    _sub?.cancel();
    _sub = _authRepository.authStateChanges().listen((user) {
      if (user == null) {
        emit(const AuthStateSignedOut());
      } else {
        emit(AuthStateSignedIn(user));
      }
    });
  }

  Future<void> signInWithGoogle() => _authRepository.signInWithGoogle();

  Future<void> signOut() => _authRepository.signOut();

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}
