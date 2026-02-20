import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/presentation/cubit/auth_cubit.dart';
import '../features/auth/presentation/pages/sign_in_page.dart';
import '../features/home/presentation/pages/home_shell.dart';
import '../theme/app_theme.dart';

class ZolaneApp extends StatelessWidget {
  final bool firebaseReady;
  final AuthRepository authRepository;

  const ZolaneApp({
    super.key,
    required this.firebaseReady,
    required this.authRepository,
  });

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: authRepository,
      child: BlocProvider(
        create: (context) => AuthCubit(context.read<AuthRepository>())..start(),
        child: MaterialApp(
          title: 'Zolane',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: _AppGate(firebaseReady: firebaseReady),
        ),
      ),
    );
  }
}

class _AppGate extends StatelessWidget {
  final bool firebaseReady;

  const _AppGate({required this.firebaseReady});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (!firebaseReady) {
          return const _FirebaseNotConfiguredPage();
        }

        return switch (state) {
          AuthStateInitial() => const _SplashPage(),
          AuthStateSignedOut() => const SignInPage(),
          AuthStateSigningIn() => const SignInPage(),
          AuthStateSignedIn(:final user) => HomeShell(user: user),
          AuthStateSigningOut(:final user) => HomeShell(user: user),
        };
      },
    );
  }
}

class _SplashPage extends StatelessWidget {
  const _SplashPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

class _FirebaseNotConfiguredPage extends StatelessWidget {
  const _FirebaseNotConfiguredPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Firebase non configuré',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              Text(
                "Ajoute la config Firebase (Android: google-services.json, iOS: GoogleService-Info.plist), puis relance l'app.",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
