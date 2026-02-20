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
  final String? message;

  const AuthStateSignedOut({this.message});
}

class AuthStateSigningIn extends AuthState {
  const AuthStateSigningIn();
}

class AuthStateSigningOut extends AuthState {
  final AppUser user;

  const AuthStateSigningOut(this.user);
}

class AuthStateSignedIn extends AuthState {
  final AppUser user;

  const AuthStateSignedIn(this.user);
}

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  StreamSubscription<AppUser?>? _sub;
  AppUser? _lastUser;

  AuthCubit(this._authRepository) : super(const AuthStateInitial());

  void start() {
    _sub?.cancel();
    _sub = _authRepository.authStateChanges().listen((user) {
      _lastUser = user;
      if (user == null) {
        emit(const AuthStateSignedOut());
      } else {
        emit(AuthStateSignedIn(user));
      }
    });
  }

  Future<void> signInWithGoogle() async {
    emit(const AuthStateSigningIn());

    try {
      await _authRepository.signInWithGoogle();

      // If the user cancelled the Google picker, Firebase won't emit a user.
      // Bring the UI back to signed-out state.
      if (_lastUser == null) {
        emit(const AuthStateSignedOut());
      }
    } catch (e) {
      emit(AuthStateSignedOut(message: _humanMessage(e)));
    }
  }

  Future<void> signOut() async {
    final user = _lastUser;
    if (user != null) emit(AuthStateSigningOut(user));

    try {
      await _authRepository.signOut();
    } catch (e) {
      emit(AuthStateSignedOut(message: _humanMessage(e)));
    }
  }

  static String _humanMessage(Object error) {
    final raw = error.toString();

    if (raw.contains('Firebase not configured')) {
      return 'Firebase non configuré. Vérifie la configuration puis relance.';
    }

    // Common Google Sign-In misconfiguration signals on Android.
    // Example: ApiException: 10 (DEVELOPER_ERROR)
    if (raw.contains('DEVELOPER_ERROR') ||
        raw.contains('ApiException: 10') ||
        raw.contains('sign_in_failed')) {
      return 'Connexion Google non configurée (OAuth / SHA-1). Vérifie Firebase puis réessaie.';
    }

    if (raw.contains('network') || raw.contains('Network')) {
      return 'Connexion réseau indisponible. Réessaie.';
    }

    return 'Connexion impossible. Réessaie.';
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}
