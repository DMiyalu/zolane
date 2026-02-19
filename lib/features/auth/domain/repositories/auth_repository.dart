import '../entities/app_user.dart';

abstract interface class AuthRepository {
  Stream<AppUser?> authStateChanges();

  Future<void> signInWithGoogle();

  Future<void> signOut();
}
