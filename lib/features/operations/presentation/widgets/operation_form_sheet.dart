import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../theme/app_theme.dart';
import '../../domain/entities/operation.dart';

class OperationFormResult {
  final OperationKind kind;
  final String category;
  final int amountCents;
  final int occurredAtMs;
  final int? rentMonthMs;
  final String? note;

  const OperationFormResult({
    required this.kind,
    required this.category,
    required this.amountCents,
    required this.occurredAtMs,
    required this.rentMonthMs,
    required this.note,
  });
}

class OperationFormSheet extends StatefulWidget {
  final Operation? existing;

  const OperationFormSheet({super.key, this.existing});

  static Future<OperationFormResult?> open(
    BuildContext context, {
    Operation? existing,
  }) {
    return showModalBottomSheet<OperationFormResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.cardColor,
      builder: (_) => OperationFormSheet(existing: existing),
    );
  }

  @override
  State<OperationFormSheet> createState() => _OperationFormSheetState();
}

class _OperationFormSheetState extends State<OperationFormSheet> {
  final _formKey = GlobalKey<FormState>();

  late OperationKind _kind;
  late DateTime _date;

  late String _selectedCategory;
  DateTime? _selectedRentMonth;
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;

  static const List<String> _expenseCategories = [
    'Crédits',
    'Électricité',
    'Eau',
    'Assurances',
    'Travaux',
    'Gaz',
    'Divers',
  ];

  static const List<String> _incomeCategories = [
    'Loyer',
    'Remboursement',
  ];

  static List<String> _baseCategoriesFor(OperationKind kind) {
    return kind == OperationKind.expense ? _expenseCategories : _incomeCategories;
  }

  List<String> _categoryItemsForCurrentKind() {
    final base = _baseCategoriesFor(_kind);
    if (base.contains(_selectedCategory)) return base;
    return [_selectedCategory, ...base];
  }

  @override
  void initState() {
    super.initState();

    final existing = widget.existing;
    _kind = existing?.kind ?? OperationKind.expense;
    _date = DateTime.fromMillisecondsSinceEpoch(
      existing?.occurredAtMs ?? DateTime.now().millisecondsSinceEpoch,
    );

    final initialCategory = (existing?.category ?? '').trim();
    _selectedCategory = initialCategory.isNotEmpty
        ? initialCategory
        : _baseCategoriesFor(_kind).first;

    final existingRentMonthMs = existing?.rentMonthMs;
    if (_kind == OperationKind.income && _selectedCategory == 'Loyer' && existingRentMonthMs != null) {
      final d = DateTime.fromMillisecondsSinceEpoch(existingRentMonthMs);
      _selectedRentMonth = DateTime(d.year, d.month, 1);
    } else if (_selectedCategory == 'Loyer' && _kind == OperationKind.income) {
      _selectedRentMonth = DateTime(_date.year, _date.month, 1);
    }
    _amountController = TextEditingController(
      text: existing == null
          ? ''
          : (existing.amountCents / 100).toStringAsFixed(2),
    );
    _noteController = TextEditingController(text: existing?.note ?? '');
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.viewInsetsOf(context);
    final safePadding = MediaQuery.paddingOf(context);
    final isEditing = widget.existing != null;
    final showRentMonth = _kind == OperationKind.income && _selectedCategory == 'Loyer';

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: 20 + safePadding.bottom + viewInsets.bottom,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEditing ? 'Modifier opération' : 'Nouvelle opération',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 14),
              SegmentedButton<OperationKind>(
                segments: const [
                  ButtonSegment(
                    value: OperationKind.expense,
                    label: Text('Dépense'),
                  ),
                  ButtonSegment(
                    value: OperationKind.income,
                    label: Text('Revenu'),
                  ),
                ],
                selected: {_kind},
                onSelectionChanged: (s) {
                  final nextKind = s.first;
                  final nextBase = _baseCategoriesFor(nextKind);
                  setState(() {
                    _kind = nextKind;
                    if (!nextBase.contains(_selectedCategory)) {
                      _selectedCategory = nextBase.first;
                    }
                  });
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                key: ValueKey('category_${_kind.name}'),
                initialValue: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Catégorie'),
                items: _categoryItemsForCurrentKind()
                    .map(
                      (c) => DropdownMenuItem(
                        value: c,
                        child: Text(c),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _selectedCategory = value;
                    if (_kind == OperationKind.income && _selectedCategory == 'Loyer') {
                      _selectedRentMonth ??= DateTime(_date.year, _date.month, 1);
                    } else {
                      _selectedRentMonth = null;
                    }
                  });
                },
                validator: (v) {
                  final value = v?.trim() ?? '';
                  if (value.isEmpty) return 'Champ obligatoire';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              if (showRentMonth) ...[
                DropdownButtonFormField<DateTime>(
                  key: ValueKey(
                    'rentMonth_${_selectedRentMonth?.millisecondsSinceEpoch ?? 'null'}',
                  ),
                  initialValue: _selectedRentMonth,
                  decoration: const InputDecoration(labelText: 'Mois du loyer'),
                  items: _rentMonthOptions()
                      .map(
                        (m) => DropdownMenuItem(
                          value: m,
                          child: Text(_formatRentMonth(m)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _selectedRentMonth = value);
                  },
                  validator: (v) {
                    if (!showRentMonth) return null;
                    if (v == null) return 'Champ obligatoire';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
              ],
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Montant (€)'),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: false,
                ),
                textInputAction: TextInputAction.next,
                validator: (v) {
                  final cents = _parseAmountToCents(v);
                  if (cents == null || cents <= 0) return 'Montant invalide';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Date du versement'),
                subtitle: Text(_formatDate(_date)),
                trailing: const Icon(Icons.calendar_today_outlined),
                onTap: () => _pickDate(context),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(labelText: 'Note (optionnel)'),
                minLines: 1,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (!(_formKey.currentState?.validate() ?? false)) return;

                    final cents = _parseAmountToCents(_amountController.text) ?? 0;
                    final note = _noteController.text.trim().isEmpty
                        ? null
                        : _noteController.text.trim();

                    Navigator.of(context).pop(
                      OperationFormResult(
                        kind: _kind,
                        category: _selectedCategory.trim(),
                        amountCents: cents,
                        occurredAtMs: _date.millisecondsSinceEpoch,
                        rentMonthMs: showRentMonth
                            ? _selectedRentMonth?.millisecondsSinceEpoch
                            : null,
                        note: note,
                      ),
                    );
                  },
                  child: Text(isEditing ? 'Enregistrer' : 'Ajouter'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (!mounted || picked == null) return;
    setState(() => _date = DateTime(picked.year, picked.month, picked.day));
  }

  List<DateTime> _rentMonthOptions() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month - 18, 1);
    final end = DateTime(now.year, now.month + 6, 1);

    final months = <DateTime>[];
    var cursor = start;
    while (!cursor.isAfter(end)) {
      months.add(cursor);
      cursor = DateTime(cursor.year, cursor.month + 1, 1);
    }

    final current = _selectedRentMonth;
    if (current != null && !months.contains(current)) {
      months.add(current);
      months.sort((a, b) => a.compareTo(b));
    }

    return months;
  }

  static String _formatRentMonth(DateTime d) {
    // Ex: "février 2026"
    return DateFormat('MMMM yyyy', 'fr_FR').format(d);
  }

  static int? _parseAmountToCents(String? input) {
    final raw = (input ?? '').trim();
    if (raw.isEmpty) return null;

    final normalized = raw.replaceAll(' ', '').replaceAll(',', '.');
    final value = double.tryParse(normalized);
    if (value == null) return null;

    return (value * 100).round();
  }

  static String _formatDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yyyy = d.year.toString();
    return '$dd/$mm/$yyyy';
  }
}
