import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../data/enums.dart';
import '../data/models.dart';
import '../logic/wallet_cubit.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_fade_in.dart';
import '../widgets/animated_slide_in.dart';

class SummaryPage extends StatelessWidget {
  const SummaryPage({super.key});

  String _formatCurrency(double amount) {
    return NumberFormat.currency(
      symbol: '€',
      decimalDigits: 2,
      locale: 'fr_FR',
    ).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bilan'),
      ),
      body: BlocBuilder<WalletCubit, WalletStateData>(
        builder: (context, walletState) {
          final isPositive = walletState.balance >= 0;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Solde total sur sa propre ligne
                AnimatedFadeIn(
                  delay: const Duration(milliseconds: 100),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isPositive
                            ? [
                                AppTheme.successColor.withValues(
                                  alpha: 0.15,
                                ),
                                AppTheme.successColor.withValues(
                                  alpha: 0.08,
                                ),
                              ]
                            : [
                                AppTheme.errorColor.withValues(
                                  alpha: 0.15,
                                ),
                                AppTheme.errorColor.withValues(
                                  alpha: 0.08,
                                ),
                              ],
                      ),
                      borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                      border: Border.all(
                        color: isPositive
                            ? AppTheme.successColor.withValues(
                              alpha: 0.3,
                            )
                            : AppTheme.errorColor.withValues(
                              alpha: 0.3,
                            ),
                        width: 1.5,
                      ),
                    ),
                    padding: const EdgeInsets.all(AppTheme.padding * 1.5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: (isPositive
                                        ? AppTheme.successColor
                                        : AppTheme.errorColor)
                                    .withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                isPositive ? Icons.account_balance_wallet : Icons.warning,
                                color: isPositive
                                    ? AppTheme.successColor
                                    : AppTheme.errorColor,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: AppTheme.smallPadding),
                            Text(
                              'Solde total',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: const Color(0xFF6B7280),
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppTheme.padding),
                        Text(
                          _formatCurrency(walletState.balance),
                          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                color: isPositive
                                    ? AppTheme.successColor
                                    : AppTheme.errorColor,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.padding),
                // Entrées et Sorties sur la même ligne
                Row(
                  children: [
                    Expanded(
                      child: AnimatedSlideIn(
                        delay: const Duration(milliseconds: 150),
                        begin: const Offset(-0.1, 0),
                        child: _buildStatCard(
                          context,
                          'Entrées totales',
                          _formatCurrency(walletState.totalIn),
                          AppTheme.successColor,
                          Icons.trending_up,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppTheme.padding),
                    Expanded(
                      child: AnimatedSlideIn(
                        delay: const Duration(milliseconds: 200),
                        begin: const Offset(0.1, 0),
                        child: _buildStatCard(
                          context,
                          'Sorties totales',
                          _formatCurrency(walletState.totalOut),
                          AppTheme.errorColor,
                          Icons.trending_down,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.padding * 1.5),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.accentColor.withValues(
                          alpha: 0.1,
                        ),
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
                  final totalEntries = entries.fold(
                      0.0, (sum, entry) => sum + entry.amount);
                  final totalExpenses = expenses.fold(
                      0.0, (sum, expense) => sum + expense.amount);
                  final balance = totalEntries - totalExpenses;

                  return AnimatedSlideIn(
                    delay: Duration(milliseconds: 250 + (index * 50)),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: AppTheme.smallPadding),
                      decoration: BoxDecoration(
                        color: AppTheme.cardColor,
                        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: 0.04,
                            ),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(AppTheme.padding),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.accentColor.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.home,
                            color: AppTheme.accentColor,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          property.label,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '${entries.length + expenses.length} opération${entries.length + expenses.length > 1 ? 's' : ''}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _formatCurrency(balance),
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: balance >= 0
                                        ? AppTheme.successColor
                                        : AppTheme.errorColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppTheme.padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: AppTheme.smallPadding),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF9CA3AF),
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.padding),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}

