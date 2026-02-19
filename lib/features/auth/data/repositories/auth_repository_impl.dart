import 'package:firebase_auth/firebase_auth.dart' as fb;

import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/firebase_auth_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDataSource? _dataSource;

  AuthRepositoryImpl(this._dataSource);

  @override
  Stream<AppUser?> authStateChanges() {
    final ds = _dataSource;
    if (ds == null) return const Stream<AppUser?>.empty();

    return ds.authStateChanges().map(_mapUser);
  }

  @override
  Future<void> signInWithGoogle() async {
    final ds = _dataSource;
    if (ds == null) {
      throw StateError('Firebase not configured');
    }

    await ds.signInWithGoogle();
  }

  @override
  Future<void> signOut() async {
    final ds = _dataSource;
    if (ds == null) return;

    await ds.signOut();
  }

  AppUser? _mapUser(fb.User? user) {
    if (user == null) return null;

    return AppUser(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoURL,
    );
  }
}
