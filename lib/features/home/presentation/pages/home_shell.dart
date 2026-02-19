import 'package:flutter/material.dart';

import '../../../auth/domain/entities/app_user.dart';

class HomeShell extends StatelessWidget {
  final AppUser user;

  const HomeShell({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes biens'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'Connecté: ${user.email ?? user.uid}\n\nÉtape suivante: CRUD des biens + opérations.',
        ),
      ),
    );
  }
}
