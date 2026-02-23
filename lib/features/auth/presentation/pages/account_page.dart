import 'package:flutter/material.dart';

import '../../domain/entities/app_user.dart';

class AccountPage extends StatelessWidget {
  final AppUser user;

  const AccountPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final displayName = (user.displayName ?? '').trim();
    final email = (user.email ?? '').trim();

    final base = displayName.isNotEmpty
      ? displayName
      : (email.isNotEmpty ? email : user.uid);
    final initial = base.isNotEmpty ? base.substring(0, 1).toUpperCase() : '?';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Compte'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        child: Text(initial),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName.isNotEmpty
                                  ? displayName
                                  : 'Utilisateur',
                              style: theme.textTheme.titleLarge,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (email.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                email,
                                style: theme.textTheme.bodyMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'UID',
                    style: theme.textTheme.labelLarge,
                  ),
                  const SizedBox(height: 4),
                  SelectableText(
                    user.uid,
                    style: theme.textTheme.bodyMedium,
                  ),
                  if (user.photoUrl != null && user.photoUrl!.trim().isNotEmpty)
                    ...[
                      const SizedBox(height: 16),
                      Text(
                        'Photo URL',
                        style: theme.textTheme.labelLarge,
                      ),
                      const SizedBox(height: 4),
                      SelectableText(
                        user.photoUrl!.trim(),
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
