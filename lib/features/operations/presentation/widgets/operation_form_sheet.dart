import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../domain/entities/operation.dart';

class OperationFormResult {
  final OperationKind kind;
  final String category;
  final int amountCents;
  final int occurredAtMs;
  final String? note;

  const OperationFormResult({
    required this.kind,
    required this.category,
    required this.amountCents,
    required this.occurredAtMs,
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

  late final TextEditingController _categoryController;
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;

  @override
  void initState() {
    super.initState();

    final existing = widget.existing;
    _kind = existing?.kind ?? OperationKind.expense;
    _date = DateTime.fromMillisecondsSinceEpoch(
      existing?.occurredAtMs ?? DateTime.now().millisecondsSinceEpoch,
    );

    _categoryController =
        TextEditingController(text: existing?.category ?? '');
    _amountController = TextEditingController(
      text: existing == null
          ? ''
          : (existing.amountCents / 100).toStringAsFixed(2),
    );
    _noteController = TextEditingController(text: existing?.note ?? '');
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.viewInsetsOf(context);
    final isEditing = widget.existing != null;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: 20 + viewInsets.bottom,
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
                setState(() => _kind = s.first);
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _categoryController,
              decoration: const InputDecoration(labelText: 'Catégorie'),
              textInputAction: TextInputAction.next,
              validator: (v) {
                final value = v?.trim() ?? '';
                if (value.isEmpty) return 'Champ obligatoire';
                return null;
              },
            ),
            const SizedBox(height: 12),
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
              title: const Text('Date'),
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
                      category: _categoryController.text.trim(),
                      amountCents: cents,
                      occurredAtMs: _date.millisecondsSinceEpoch,
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
