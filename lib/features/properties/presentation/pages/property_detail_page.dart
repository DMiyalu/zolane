import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/property.dart';
import '../../../operations/data/repositories/operations_repository_impl.dart';
import '../../../operations/domain/entities/operation.dart';
import '../../../operations/presentation/cubit/operations_cubit.dart';
import '../../../operations/presentation/widgets/operation_form_sheet.dart';
import '../../../../theme/app_theme.dart';

class PropertyDetailPage extends StatelessWidget {
  final Property property;

  const PropertyDetailPage({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OperationsCubit(
        OperationsRepositoryImpl(),
        uid: property.userId,
        propertyId: property.id,
      )..load(),
      child: _PropertyDetailView(property: property),
    );
  }
}

class _PropertyDetailView extends StatelessWidget {
  final Property property;

  const _PropertyDetailView({required this.property});

  @override
  Widget build(BuildContext context) {
    return BlocListener<OperationsCubit, OperationsState>(
      listener: (context, state) {
        if (state is OperationsStateError) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(property.label),
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: null,
          onPressed: () => _openCreate(context),
          child: const Icon(Icons.add_rounded),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppTheme.backgroundColor,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.home_outlined),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              property.city,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              property.address,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 12),
                            BlocBuilder<OperationsCubit, OperationsState>(
                              builder: (context, state) {
                                final ops = switch (state) {
                                  OperationsStateLoaded(:final operations) =>
                                    operations,
                                  _ => const <Operation>[],
                                };

                                final totals = _Totals.fromOperations(ops);
                                return _TotalsRow(totals: totals);
                              },
                            ),
                            if ((property.note ?? '').trim().isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                property.note!,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<OperationsCubit, OperationsState>(
                builder: (context, state) {
                  return switch (state) {
                    OperationsStateLoading() =>
                      const Center(child: CircularProgressIndicator()),
                    OperationsStateError() => const SizedBox.shrink(),
                    OperationsStateLoaded(:final operations) => operations.isEmpty
                        ? const _EmptyOperations()
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            itemCount: operations.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final op = operations[index];
                              return _OperationTile(
                                operation: op,
                                onTap: () => _openEdit(context, op),
                                onDelete: () =>
                                    context.read<OperationsCubit>().delete(op.id),
                              );
                            },
                          ),
                  };
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> _openCreate(BuildContext context) async {
    final result = await OperationFormSheet.open(context);
    if (result == null || !context.mounted) return;

    await context.read<OperationsCubit>().create(
          kind: result.kind,
          category: result.category,
          amountCents: result.amountCents,
          occurredAtMs: result.occurredAtMs,
          rentMonthMs: result.rentMonthMs,
          note: result.note,
        );
  }

  static Future<void> _openEdit(BuildContext context, Operation operation) async {
    final result = await OperationFormSheet.open(context, existing: operation);
    if (result == null || !context.mounted) return;

    await context.read<OperationsCubit>().update(
          id: operation.id,
          kind: result.kind,
          category: result.category,
          amountCents: result.amountCents,
          occurredAtMs: result.occurredAtMs,
          rentMonthMs: result.rentMonthMs,
          note: result.note,
        );
  }
}

class _EmptyOperations extends StatelessWidget {
  const _EmptyOperations();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Aucune opération',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Ajoute une dépense ou un revenu pour ce bien.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _OperationTile extends StatelessWidget {
  final Operation operation;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _OperationTile({
    required this.operation,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isExpense = operation.kind == OperationKind.expense;
    final amount = (operation.amountCents / 100).toStringAsFixed(2);
    final sign = isExpense ? '-' : '+';
    final color = isExpense ? AppTheme.errorColor : AppTheme.successColor;

    final rentMonthMs = operation.rentMonthMs;
    final rentMonthText = (operation.category == 'Loyer' && rentMonthMs != null)
      ? _formatMonth(DateTime.fromMillisecondsSinceEpoch(rentMonthMs))
      : null;

    return Dismissible(
      key: ValueKey(operation.id),
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
                content: const Text('Supprimer cette opération ?'),
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
      onDismissed: (_) => onDelete(),
      child: Card(
        child: ListTile(
          title: Text(operation.category),
          subtitle: Text(
            rentMonthText == null
                ? _formatDate(
                    DateTime.fromMillisecondsSinceEpoch(operation.occurredAtMs),
                  )
                : 'Versement: ${_formatDate(DateTime.fromMillisecondsSinceEpoch(operation.occurredAtMs))} • Mois: $rentMonthText',
          ),
          trailing: Text(
            '$sign$amount €',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
          ),
          onTap: onTap,
        ),
      ),
    );
  }

  static String _formatDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yyyy = d.year.toString();
    return '$dd/$mm/$yyyy';
  }

  static String _formatMonth(DateTime d) {
    final mm = d.month.toString().padLeft(2, '0');
    final yyyy = d.year.toString();
    return '$mm/$yyyy';
  }
}

class _Totals {
  final int incomeCents;
  final int expenseCents;

  const _Totals({required this.incomeCents, required this.expenseCents});

  int get balanceCents => incomeCents - expenseCents;

  static _Totals fromOperations(List<Operation> operations) {
    var inCents = 0;
    var outCents = 0;

    for (final op in operations) {
      if (op.kind == OperationKind.income) {
        inCents += op.amountCents;
      } else {
        outCents += op.amountCents;
      }
    }

    return _Totals(incomeCents: inCents, expenseCents: outCents);
  }
}

class _TotalsRow extends StatelessWidget {
  final _Totals totals;

  const _TotalsRow({required this.totals});

  @override
  Widget build(BuildContext context) {
    final inText = _formatEuros(totals.incomeCents);
    final outText = _formatEuros(totals.expenseCents);
    final balText = _formatEuros(totals.balanceCents);

    final balanceColor = totals.balanceCents >= 0
        ? AppTheme.successColor
        : AppTheme.errorColor;

    return Row(
      children: [
        Expanded(
          child: _MetricChip(
            label: 'Revenus',
            value: '+$inText',
            valueColor: AppTheme.successColor,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MetricChip(
            label: 'Dépenses',
            value: '-$outText',
            valueColor: AppTheme.errorColor,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MetricChip(
            label: 'Balance',
            value: balText,
            valueColor: balanceColor,
          ),
        ),
      ],
    );
  }

  static String _formatEuros(int cents) {
    final euros = (cents / 100).toStringAsFixed(2);
    return '$euros €';
  }
}

class _MetricChip extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _MetricChip({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: valueColor,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}
