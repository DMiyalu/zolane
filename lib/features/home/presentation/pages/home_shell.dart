import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../properties/data/repositories/properties_repository_impl.dart';
import '../../../properties/domain/entities/property.dart';
import '../../../properties/presentation/pages/property_detail_page.dart';
import '../../../properties/presentation/cubit/properties_cubit.dart';
import '../../../properties/presentation/widgets/property_form_sheet.dart';
import '../../../sync/sync_runner.dart';

class HomeShell extends StatelessWidget {
  final AppUser user;

  const HomeShell({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PropertiesCubit(PropertiesRepositoryImpl())..load(),
      child: _HomeShellView(uid: user.uid),
    );
  }
}

class _HomeShellView extends StatelessWidget {
  final String uid;

  const _HomeShellView({required this.uid});

  @override
  Widget build(BuildContext context) {
    return BlocListener<PropertiesCubit, PropertiesState>(
      listener: (context, state) {
        if (state is PropertiesStateError) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mes biens'),
          actions: [
            IconButton(
              tooltip: 'Se déconnecter',
              onPressed: () => context.read<AuthCubit>().signOut(),
              icon: const Icon(Icons.logout_rounded),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: null,
          onPressed: () => _openCreate(context),
          child: const Icon(Icons.add_rounded),
        ),
        body: BlocBuilder<PropertiesCubit, PropertiesState>(
          builder: (context, state) {
            return switch (state) {
              PropertiesStateLoading() =>
                const Center(child: CircularProgressIndicator()),
              PropertiesStateError() => _EmptyState(
                  title: 'Impossible de charger',
                  subtitle: 'Réessaie ou vérifie la configuration locale.',
                  actionLabel: 'Réessayer',
                  onAction: () => context.read<PropertiesCubit>().load(),
                ),
              PropertiesStateLoaded(:final properties) => properties.isEmpty
                  ? _EmptyState(
                      title: 'Ajoutez votre premier bien',
                      subtitle:
                          'Créez un bien pour commencer à suivre dépenses et revenus.',
                      actionLabel: 'Créer un bien',
                      onAction: () => _openCreate(context),
                    )
                  : _PropertiesList(
                      properties: properties,
                      onOpen: (p) => _openDetail(context, p),
                      onEdit: (p) => _openEdit(context, p),
                      onDelete: (p) =>
                          context.read<PropertiesCubit>().delete(p.id),
                    ),
            };
          },
        ),
        bottomNavigationBar: SyncRunner(uid: uid),
      ),
    );
  }

  static Future<void> _openCreate(BuildContext context) async {
    final result = await PropertyFormSheet.open(context);
    if (result == null || !context.mounted) return;

    await context.read<PropertiesCubit>().create(
          label: result.label,
          city: result.city,
          address: result.address,
          note: result.note,
        );
  }

  static Future<void> _openEdit(BuildContext context, Property property) async {
    final result = await PropertyFormSheet.open(context, existing: property);
    if (result == null || !context.mounted) return;

    await context.read<PropertiesCubit>().update(
          id: property.id,
          label: result.label,
          city: result.city,
          address: result.address,
          note: result.note,
        );
  }

  static void _openDetail(BuildContext context, Property property) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PropertyDetailPage(property: property),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;

  const _EmptyState({
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onAction,
                  child: Text(actionLabel),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PropertiesList extends StatelessWidget {
  final List<Property> properties;
  final ValueChanged<Property> onOpen;
  final ValueChanged<Property> onEdit;
  final ValueChanged<Property> onDelete;

  const _PropertiesList({
    required this.properties,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: properties.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final p = properties[index];

        return Dismissible(
          key: ValueKey(p.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.error.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.delete_outline,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          confirmDismiss: (_) async {
            return await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Supprimer ?'),
                    content: Text('Supprimer "${p.label}" ?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Annuler'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Supprimer'),
                      ),
                    ],
                  ),
                ) ??
                false;
          },
          onDismissed: (_) => onDelete(p),
          child: Card(
            child: ListTile(
              title: Text(p.label),
              subtitle: Text('${p.city} • ${p.address}'),
              trailing: IconButton(
                tooltip: 'Modifier',
                onPressed: () => onEdit(p),
                icon: const Icon(Icons.edit_outlined),
              ),
              onTap: () => onOpen(p),
            ),
          ),
        );
      },
    );
  }
}
