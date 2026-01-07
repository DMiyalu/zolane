import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import 'animated_fade_in.dart';

class BalanceHeader extends StatelessWidget {
  final double balance;
  final double totalIn;
  final double totalOut;

  const BalanceHeader({
    super.key,
    required this.balance,
    required this.totalIn,
    required this.totalOut,
  });

  String _formatCurrency(double amount) {
    return NumberFormat.currency(
      symbol: '€',
      decimalDigits: 2,
      locale: 'fr_FR',
    ).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final isPositive = balance >= 0;
    
    return AnimatedFadeIn(
      delay: const Duration(milliseconds: 100),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isPositive
                ? [
                    AppTheme.successColor.withOpacity(0.1),
                    AppTheme.successColor.withOpacity(0.05),
                  ]
                : [
                    AppTheme.errorColor.withOpacity(0.1),
                    AppTheme.errorColor.withOpacity(0.05),
                  ],
          ),
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
          border: Border.all(
            color: isPositive
                ? AppTheme.successColor.withOpacity(0.2)
                : AppTheme.errorColor.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.padding * 1.5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isPositive
                          ? AppTheme.successColor.withOpacity(0.15)
                          : AppTheme.errorColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isPositive ? Icons.trending_up : Icons.trending_down,
                      color: isPositive ? AppTheme.successColor : AppTheme.errorColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppTheme.smallPadding),
                  Text(
                    'Solde du portefeuille',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: const Color(0xFF6B7280),
                        ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.padding),
              Text(
                _formatCurrency(balance),
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: isPositive ? AppTheme.successColor : AppTheme.errorColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: AppTheme.padding),
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      context,
                      'Entrées',
                      _formatCurrency(totalIn),
                      AppTheme.successColor,
                      Icons.arrow_upward,
                    ),
                  ),
                  const SizedBox(width: AppTheme.padding),
                  Expanded(
                    child: _buildStatItem(
                      context,
                      'Sorties',
                      _formatCurrency(totalOut),
                      AppTheme.errorColor,
                      Icons.arrow_downward,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.smallPadding),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF9CA3AF),
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

