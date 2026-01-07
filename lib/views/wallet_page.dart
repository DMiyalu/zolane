import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/enums.dart';
import '../data/models.dart';
import '../logic/wallet_cubit.dart';
import '../theme/app_theme.dart';
import '../widgets/operation_tile.dart';
import '../widgets/forms/add_entry_form.dart';
import '../widgets/forms/add_expense_form.dart';

enum WalletFilter { all, entries, personalExpenses }

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  WalletFilter _currentFilter = WalletFilter.all;

  String? _getPropertyLabel(ImmoProperty? property) {
    if (property == null) return null;
    return property.label;
  }

  void _showAddMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppTheme.cardRadius),
          ),
        ),
        padding: const EdgeInsets.all(AppTheme.padding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppTheme.padding),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            _buildMenuOption(
              context,
              icon: Icons.add_circle_outline,
              title: 'Nouvelle entrée',
              subtitle: 'Ajouter une recette',
              color: AppTheme.successColor,
              onTap: () {
                Navigator.of(context).pop();
                Future.delayed(const Duration(milliseconds: 200), () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => const AddEntryForm(),
                  );
                });
              },
            ),
            const SizedBox(height: AppTheme.smallPadding),
            _buildMenuOption(
              context,
              icon: Icons.remove_circle_outline,
              title: 'Nouvelle dépense',
              subtitle: 'Ajouter une sortie',
              color: AppTheme.errorColor,
              onTap: () {
                Navigator.of(context).pop();
                Future.delayed(const Duration(milliseconds: 200), () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => const AddExpenseForm(),
                  );
                });
              },
            ),
            const SizedBox(height: AppTheme.padding),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(AppTheme.padding),
          decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: AppTheme.padding),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Portefeuille'),
      ),
      body: BlocBuilder<WalletCubit, WalletStateData>(
        builder: (context, walletState) {
          final entries = walletState.entries.toList()
            ..sort((a, b) => b.date.compareTo(a.date));
          final personalExpenses = walletState.expenses
              .where((e) => e.type == ExpenseType.personnelle)
              .toList()
            ..sort((a, b) => b.date.compareTo(a.date));

          return Column(
            children: [
              Container(
                margin: const EdgeInsets.all(AppTheme.padding),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildFilterButton(
                        'Toutes',
                        _currentFilter == WalletFilter.all,
                        () => setState(() => _currentFilter = WalletFilter.all),
                      ),
                    ),
                    Expanded(
                      child: _buildFilterButton(
                        'Entrées',
                        _currentFilter == WalletFilter.entries,
                        () => setState(() => _currentFilter = WalletFilter.entries),
                      ),
                    ),
                    Expanded(
                      child: _buildFilterButton(
                        'Dépenses',
                        _currentFilter == WalletFilter.personalExpenses,
                        () => setState(() => _currentFilter = WalletFilter.personalExpenses),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _buildContent(entries, personalExpenses),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMenu(context),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterButton(String label, bool isSelected, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: AppTheme.shortAnimation,
          curve: AppTheme.defaultCurve,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isSelected ? Colors.white : const Color(0xFF6B7280),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(List<WalletEntry> entries, List<WalletExpense> personalExpenses) {
    if (_currentFilter == WalletFilter.entries) {
      if (entries.isEmpty) {
        return _buildEmptyState(
          icon: Icons.inbox_outlined,
          message: 'Aucune entrée',
          subtitle: 'Ajoutez une entrée pour commencer',
        );
      }
      return ListView(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.padding),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: AppTheme.padding),
            child: Text(
              'Entrées',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          ...entries.map((entry) => OperationTile(
                title: entry.note ?? entry.source.label,
                subtitle: _getPropertyLabel(entry.property),
                amount: entry.amount,
                date: entry.date,
                isPositive: true,
              )),
          const SizedBox(height: AppTheme.padding),
        ],
      );
    } else if (_currentFilter == WalletFilter.personalExpenses) {
      if (personalExpenses.isEmpty) {
        return _buildEmptyState(
          icon: Icons.shopping_bag_outlined,
          message: 'Aucune dépense personnelle',
          subtitle: 'Ajoutez une dépense pour commencer',
        );
      }
      return ListView(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.padding),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: AppTheme.padding),
            child: Text(
              'Dépenses personnelles',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          ...personalExpenses.map((expense) => OperationTile(
                title: expense.note ??
                    (expense.personalReason?.label ?? 'Dépense personnelle'),
                amount: expense.amount,
                date: expense.date,
                isPositive: false,
              )),
          const SizedBox(height: AppTheme.padding),
        ],
      );
    } else {
      if (entries.isEmpty && personalExpenses.isEmpty) {
        return _buildEmptyState(
          icon: Icons.wallet_outlined,
          message: 'Aucune opération',
          subtitle: 'Commencez par ajouter une entrée ou une dépense',
        );
      }
      return ListView(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.padding),
        children: [
          if (entries.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: AppTheme.padding),
              child: Text(
                'Entrées',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            ...entries.map((entry) => OperationTile(
                  title: entry.note ?? entry.source.label,
                  subtitle: _getPropertyLabel(entry.property),
                  amount: entry.amount,
                  date: entry.date,
                  isPositive: true,
                )),
            const SizedBox(height: AppTheme.padding * 1.5),
          ],
          if (personalExpenses.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: AppTheme.padding),
              child: Text(
                'Dépenses personnelles',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            ...personalExpenses.map((expense) => OperationTile(
                  title: expense.note ??
                      (expense.personalReason?.label ??
                          'Dépense personnelle'),
                  amount: expense.amount,
                  date: expense.date,
                  isPositive: false,
                )),
          ],
          const SizedBox(height: AppTheme.padding),
        ],
      );
    }
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.padding * 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: Colors.grey.shade300,
              ),
            ),
            const SizedBox(height: AppTheme.padding * 1.5),
            Text(
              message,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF374151),
                  ),
            ),
            const SizedBox(height: AppTheme.smallPadding),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF9CA3AF),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

