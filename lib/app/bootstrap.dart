import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';

import '../core/local_db/app_database.dart';
import '../core/local_db/app_database_provider.dart';
import '../firebase_options.dart';
import '../features/auth/data/datasources/firebase_auth_datasource.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';

class AppBootstrapResult {
  final bool firebaseReady;
  final AuthRepository authRepository;
  final AppDatabase database;

  const AppBootstrapResult({
    required this.firebaseReady,
    required this.authRepository,
    required this.database,
  });
}

class AppBootstrap {
  static Future<AppBootstrapResult> init() async {
    WidgetsFlutterBinding.ensureInitialized();

    final database = await AppDatabase.open();
    AppDatabaseProvider.setInstance(database);

    var firebaseReady = false;
    AuthRepository authRepository;

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      firebaseReady = true;

      final firebaseAuthDataSource = FirebaseAuthDataSource();
      authRepository = AuthRepositoryImpl(firebaseAuthDataSource);
    } catch (_) {
      firebaseReady = false;
      authRepository = AuthRepositoryImpl(null);
    }

    return AppBootstrapResult(
      firebaseReady: firebaseReady,
      authRepository: authRepository,
      database: database,
    );
  }
}
