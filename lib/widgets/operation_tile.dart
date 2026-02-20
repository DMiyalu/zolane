import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';

class OperationTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final double amount;
  final DateTime date;
  final bool isPositive;

  const OperationTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.amount,
    required this.date,
    this.isPositive = true,
  });

  String _formatCurrency(double amount) {
    return NumberFormat.currency(
      symbol: '€',
      decimalDigits: 2,
      locale: 'fr_FR',
    ).format(amount);
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy', 'fr_FR').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final color = isPositive ? AppTheme.successColor : AppTheme.errorColor;
    
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.smallPadding),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppTheme.padding,
          vertical: AppTheme.smallPadding,
        ),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isPositive ? Icons.arrow_upward : Icons.arrow_downward,
            color: color,
            size: 18,
          ),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        subtitle: subtitle != null
            ? Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              )
            : null,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${isPositive ? '+' : '-'}${_formatCurrency(amount)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              _formatDate(date),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

