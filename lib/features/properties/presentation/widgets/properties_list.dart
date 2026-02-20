import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/property.dart';
import '../cubit/properties_cubit.dart';

class PropertiesList extends StatelessWidget {
  final List<Property> properties;

  const PropertiesList({super.key, required this.properties});

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
            );
          },
          onDismissed: (_) => context.read<PropertiesCubit>().delete(p.id),
          child: Card(
            child: ListTile(
              title: Text(p.label),
              subtitle: Text('${p.city} • ${p.address}'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => PropertiesActions.edit(context, p),
            ),
          ),
        );
      },
    );
  }
}

class PropertiesActions {
  static Future<void> edit(BuildContext context, Property property) async {
    // Implemented in HomeShell where the cubit is available.
    // This helper is here only for a single call site.
  }
}
