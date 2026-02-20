import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/properties_repository_impl.dart';
import '../cubit/properties_cubit.dart';
import '../widgets/properties_list.dart';
import '../widgets/property_form_sheet.dart';

class PropertiesPage extends StatelessWidget {
  const PropertiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PropertiesCubit(PropertiesRepositoryImpl())..load(),
      child: const _PropertiesView(),
    );
  }
}

class _PropertiesView extends StatelessWidget {
  const _PropertiesView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PropertiesCubit, PropertiesState>(
      builder: (context, state) {
        return switch (state) {
          PropertiesStateLoading() =>
            const Center(child: CircularProgressIndicator()),
          PropertiesStateError(:final message) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Erreur: $message'),
              ),
            ),
          PropertiesStateLoaded(:final properties) => properties.isEmpty
              ? _EmptyState(
                  onAdd: () => _openCreate(context),
                )
              : PropertiesList(properties: properties),
        };
      },
    );
  }

  Future<void> _openCreate(BuildContext context) async {
    final result = await PropertyFormSheet.open(context);
    if (result == null || !context.mounted) return;

    await context.read<PropertiesCubit>().create(
          label: result.label,
          city: result.city,
          address: result.address,
          note: result.note,
        );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Ajoutez votre premier bien',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            "Créez un bien pour commencer à suivre dépenses et revenus.",
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onAdd,
              child: const Text('Créer un bien'),
            ),
          ),
        ],
      ),
    );
  }
}
