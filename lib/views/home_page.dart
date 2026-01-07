import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/enums.dart';
import '../data/models.dart';
import '../logic/wallet_cubit.dart';
import '../logic/ui_cubit.dart';
import '../theme/app_theme.dart';
import '../widgets/balance_header.dart';
import '../widgets/property_accordion.dart';
import '../widgets/forms/add_entry_form.dart';
import '../widgets/forms/add_expense_form.dart';
import 'profile_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
        automaticallyImplyLeading: false,
        leadingWidth: 170,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            'assets/images/logo.png',
            fit: BoxFit.cover,
            width: 100,
            height: 100,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              icon: const Icon(Icons.person_outline),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ProfilePage(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: BlocBuilder<WalletCubit, WalletStateData>(
        builder: (context, walletState) {
          return BlocBuilder<UiCubit, UiState>(
            builder: (context, uiState) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(AppTheme.padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    BalanceHeader(
                      balance: walletState.balance,
                      totalIn: walletState.totalIn,
                      totalOut: walletState.totalOut,
                    ),
                    const SizedBox(height: AppTheme.padding * 1.5),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.accentColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.home_work,
                            color: AppTheme.accentColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: AppTheme.smallPadding),
                        Text(
                          'Biens immobiliers',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.padding),
                    ...ImmoProperty.values.asMap().entries.map((entry) {
                      final index = entry.key;
                      final property = entry.value;
                      final entries = context
                          .read<WalletCubit>()
                          .entriesByProperty(property);
                      final expenses = context
                          .read<WalletCubit>()
                          .expensesByProperty(property);
                      return PropertyAccordion(
                        property: property,
                        entries: entries,
                        expenses: expenses,
                        expanded: uiState.expanded[property] ?? false,
                        onToggle: () {
                          context.read<UiCubit>().toggle(property);
                        },
                        index: index,
                      );
                    }),
                  ],
                ),
              );
            },
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
}

