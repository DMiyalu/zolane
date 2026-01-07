import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/enums.dart';
import '../data/models.dart';
import '../logic/wallet_cubit.dart';
import '../logic/ui_cubit.dart';
import '../theme/app_theme.dart';
import '../widgets/property_accordion.dart';

class ImmosPage extends StatelessWidget {
  const ImmosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Immos'),
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
                    Container(
                      padding: const EdgeInsets.all(AppTheme.padding),
                      decoration: BoxDecoration(
                        color: AppTheme.accentColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.accentColor.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.accentColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.info_outline,
                              color: AppTheme.accentColor,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: AppTheme.smallPadding),
                          Expanded(
                            child: Text(
                              'Gestion des biens immobiliers',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: const Color(0xFF6B7280),
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppTheme.padding * 1.5),
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
    );
  }
}

