import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/auth_cubit.dart';
import '../../../../theme/app_theme.dart';

enum _SignInMethod {
  email,
  google,
}

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  _SignInMethod _method = _SignInMethod.google;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return false;
    return RegExp(r'^\S+@\S+\.\S+$').hasMatch(value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = context.watch<AuthCubit>().state;
    final isLoading = state is AuthStateSigningIn;

    final isEmail = _method == _SignInMethod.email;

    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (previous, current) {
        return current is AuthStateSignedOut && current.message != null;
      },
      listener: (context, state) {
        final msg = (state is AuthStateSignedOut) ? state.message : null;
        if (msg == null) return;

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(msg)));
      },
      child: Scaffold(
        backgroundColor: AppTheme.cardColor,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 18,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 8),
                        const _SplashIllustration(),
                        const SizedBox(height: 28),
                        Text(
                          'Gérez vos biens',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineLarge,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Suivez dépenses et revenus, même hors ligne. La synchronisation se fera automatiquement dès que vous aurez internet.",
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge,
                        ),
                        const Spacer(),
                        SegmentedButton<_SignInMethod>(
                          segments: const [
                            ButtonSegment(
                              value: _SignInMethod.email,
                              label: Text('Email / Mot de passe'),
                            ),
                            ButtonSegment(
                              value: _SignInMethod.google,
                              label: Text('Par Google'),
                            ),
                          ],
                          selected: {_method},
                          onSelectionChanged: isLoading
                              ? null
                              : (s) {
                                  setState(() => _method = s.first);
                                },
                        ),
                        const SizedBox(height: 14),
                        if (isEmail) ...[
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: _emailController,
                                  enabled: !isLoading,
                                  decoration: const InputDecoration(
                                    labelText: 'Email',
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  validator: (v) {
                                    if (!_isValidEmail(v ?? '')) {
                                      return 'Email invalide';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _passwordController,
                                  enabled: !isLoading,
                                  decoration: const InputDecoration(
                                    labelText: 'Mot de passe',
                                  ),
                                  obscureText: true,
                                  textInputAction: TextInputAction.done,
                                  onFieldSubmitted: (_) {
                                    if (isLoading) return;
                                    final ok =
                                        _formKey.currentState?.validate() ??
                                            false;
                                    if (!ok) return;
                                    context
                                        .read<AuthCubit>()
                                        .signInWithEmailPassword(
                                          email: _emailController.text,
                                          password: _passwordController.text,
                                        );
                                  },
                                  validator: (v) {
                                    final value = (v ?? '').trim();
                                    if (value.isEmpty) {
                                      return 'Mot de passe requis';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                        ],
                        _PageDots(
                          activeIndex: 0,
                          activeColor: AppTheme.accentColor,
                          inactiveColor:
                              AppTheme.accentColor.withValues(alpha: 0.18),
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.accentColor,
                              minimumSize: const Size.fromHeight(56),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                            onPressed: isLoading
                                ? null
                                : () {
                                    if (_method == _SignInMethod.google) {
                                      context
                                          .read<AuthCubit>()
                                          .signInWithGoogle();
                                      return;
                                    }

                                    final ok =
                                        _formKey.currentState?.validate() ??
                                            false;
                                    if (!ok) return;

                                    context
                                        .read<AuthCubit>()
                                        .signInWithEmailPassword(
                                          email: _emailController.text,
                                          password: _passwordController.text,
                                        );
                                  },
                            child: isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    _method == _SignInMethod.google
                                        ? 'Continuer avec Google'
                                        : 'Se connecter',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Connexion requise pour continuer.',
                                      ),
                                    ),
                                  );
                                },
                          child: Text(
                            "Passer pour l'instant",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.textTheme.bodySmall?.color,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PageDots extends StatelessWidget {
  final int activeIndex;
  final Color activeColor;
  final Color inactiveColor;

  const _PageDots({
    required this.activeIndex,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _Dot(active: activeIndex == 0, activeColor: activeColor, inactiveColor: inactiveColor),
        const SizedBox(width: 10),
        _Dot(active: activeIndex == 1, activeColor: activeColor, inactiveColor: inactiveColor),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  final bool active;
  final Color activeColor;
  final Color inactiveColor;

  const _Dot({
    required this.active,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: active ? activeColor : inactiveColor,
        borderRadius: BorderRadius.circular(99),
      ),
    );
  }
}

class _SplashIllustration extends StatelessWidget {
  const _SplashIllustration();

  @override
  Widget build(BuildContext context) {
    final dividerColor = Theme.of(context).dividerColor;

    return Center(
      child: SizedBox(
        height: 320,
        width: 320,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(36),
                  border: Border.all(color: dividerColor),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: AppTheme.backgroundColor,
                          borderRadius: BorderRadius.circular(28),
                        ),
                        padding: const EdgeInsets.all(18),
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _MiniCard(icon: Icons.home_outlined),
                          const SizedBox(width: 12),
                          _MiniCard(icon: Icons.receipt_long_outlined),
                          const SizedBox(width: 12),
                          _MiniCard(icon: Icons.paid_outlined),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniCard extends StatelessWidget {
  final IconData icon;

  const _MiniCard({required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, color: theme.colorScheme.secondary),
    );
  }
}
