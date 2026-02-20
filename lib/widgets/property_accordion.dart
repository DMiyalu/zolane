import 'package:flutter/material.dart';
import '../data/enums.dart';
import '../data/models.dart';
import '../theme/app_theme.dart';
import 'operation_tile.dart';
import 'animated_slide_in.dart';

class PropertyAccordion extends StatelessWidget {
  final ImmoProperty property;
  final List<WalletEntry> entries;
  final List<WalletExpense> expenses;
  final bool expanded;
  final VoidCallback onToggle;
  final int index;

  const PropertyAccordion({
    super.key,
    required this.property,
    required this.entries,
    required this.expenses,
    required this.expanded,
    required this.onToggle,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    final totalOps = entries.length + expenses.length;
    
    return AnimatedSlideIn(
      delay: Duration(milliseconds: 150 + (index * 50)),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppTheme.smallPadding),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            dividerColor: Colors.transparent,
          ),
          child: ExpansionTile(
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
            subtitle: totalOps > 0
                ? Text(
                    '$totalOps opération${totalOps > 1 ? 's' : ''}',
                    style: Theme.of(context).textTheme.bodySmall,
                  )
                : null,
            trailing: AnimatedRotation(
              turns: expanded ? 0.5 : 0,
              duration: AppTheme.shortAnimation,
              curve: AppTheme.defaultCurve,
              child: const Icon(
                Icons.keyboard_arrow_down,
                color: AppTheme.accentColor,
              ),
            ),
            initiallyExpanded: expanded,
            onExpansionChanged: (_) => onToggle(),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.cardRadius),
            ),
            children: [
              AnimatedContainer(
                duration: AppTheme.mediumAnimation,
                curve: AppTheme.defaultCurve,
                padding: const EdgeInsets.all(AppTheme.padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.smallPadding,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Opérations liées à ce bien',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF6B7280),
                            ),
                      ),
                    ),
                    const SizedBox(height: AppTheme.padding),
                    if (entries.isEmpty && expenses.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(AppTheme.padding),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.inbox_outlined,
                                size: 48,
                                color: Colors.grey.shade300,
                              ),
                              const SizedBox(height: AppTheme.smallPadding),
                              Text(
                                'Aucune opération pour ce bien',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: const Color(0xFF9CA3AF),
                                    ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ..._buildOperationsList(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildOperationsList(BuildContext context) {
    final widgets = <Widget>[];

    if (entries.isNotEmpty) {
      widgets.add(
        Text(
          'Entrées (loyers Immo)',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      );
      widgets.add(const SizedBox(height: 4));
      for (final entry in entries) {
        widgets.add(
          OperationTile(
            title: entry.note ?? entry.source.label,
            amount: entry.amount,
            date: entry.date,
            isPositive: true,
          ),
        );
      }
      if (expenses.isNotEmpty) {
        widgets.add(const SizedBox(height: 8));
      }
    }

    if (expenses.isNotEmpty) {
      widgets.add(
        Text(
          'Charges immobilières',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      );
      widgets.add(const SizedBox(height: 4));
      for (final expense in expenses) {
        widgets.add(
          OperationTile(
            title: expense.note ??
                (expense.immoReason?.label ?? 'Charge immobilière'),
            amount: expense.amount,
            date: expense.date,
            isPositive: false,
          ),
        );
      }
    }

    return widgets;
  }
}

