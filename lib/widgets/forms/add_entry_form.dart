import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../data/enums.dart';
import '../../data/models.dart';
import '../../logic/wallet_cubit.dart';
import '../../theme/app_theme.dart';
import '../primary_bottom_sheet.dart';

class AddEntryForm extends StatefulWidget {
  const AddEntryForm({super.key});

  @override
  State<AddEntryForm> createState() => _AddEntryFormState();
}

class _AddEntryFormState extends State<AddEntryForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  EntrySource _selectedSource = EntrySource.immo;
  ImmoProperty? _selectedProperty;
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('fr', 'FR'),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_selectedSource == EntrySource.immo && _selectedProperty == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez sélectionner un bien')),
        );
        return;
      }

      final entry = WalletEntry(
        source: _selectedSource,
        property: _selectedSource == EntrySource.immo ? _selectedProperty : null,
        amount: double.parse(_amountController.text),
        note: _noteController.text.isEmpty ? null : _noteController.text,
        date: _selectedDate,
      );

      context.read<WalletCubit>().addEntry(entry);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entrée ajoutée avec succès')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PrimaryBottomSheet(
      title: 'Nouvelle entrée',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Source',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            SegmentedButton<EntrySource>(
              segments: EntrySource.values
                  .map((source) => ButtonSegment(
                        value: source,
                        label: Text(source.label),
                      ))
                  .toList(),
              selected: {_selectedSource},
              onSelectionChanged: (Set<EntrySource> newSelection) {
                setState(() {
                  _selectedSource = newSelection.first;
                  if (_selectedSource != EntrySource.immo) {
                    _selectedProperty = null;
                  }
                });
              },
            ),
            const SizedBox(height: AppTheme.padding),
            if (_selectedSource == EntrySource.immo) ...[
              Text(
                'Bien',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<ImmoProperty>(
                initialValue: _selectedProperty,
                decoration: const InputDecoration(
                  hintText: 'Sélectionner un bien',
                ),
                items: ImmoProperty.values
                    .map((property) => DropdownMenuItem(
                          value: property,
                          child: Text(property.label),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedProperty = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Veuillez sélectionner un bien';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppTheme.padding),
            ],
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Montant (€)',
                prefixText: '€ ',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer un montant';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'Le montant doit être supérieur à 0';
                }
                return null;
              },
            ),
            const SizedBox(height: AppTheme.padding),
            TextFormField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Note (optionnel)',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: AppTheme.padding),
            InkWell(
              onTap: () => _selectDate(context),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  DateFormat('dd/MM/yyyy', 'fr_FR').format(_selectedDate),
                ),
              ),
            ),
            const SizedBox(height: AppTheme.padding),
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(AppTheme.padding),
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }
}

