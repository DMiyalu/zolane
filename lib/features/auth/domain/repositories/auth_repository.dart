import '../entities/app_user.dart';

abstract interface class AuthRepository {
  Stream<AppUser?> authStateChanges();

  Future<void> signInWithGoogle();

  Future<void> signInWithEmailPassword({
    required String email,
    required String password,
  });

  Future<void> signOut();
}
