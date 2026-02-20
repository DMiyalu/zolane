import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../data/enums.dart';
import '../../data/models.dart';
import '../../logic/wallet_cubit.dart';
import '../../theme/app_theme.dart';
import '../primary_bottom_sheet.dart';

class AddExpenseForm extends StatefulWidget {
  const AddExpenseForm({super.key});

  @override
  State<AddExpenseForm> createState() => _AddExpenseFormState();
}

class _AddExpenseFormState extends State<AddExpenseForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  ExpenseType _selectedType = ExpenseType.chargesImmo;
  ImmoProperty? _selectedProperty;
  ImmoChargeReason? _selectedImmoReason;
  PersonalReason? _selectedPersonalReason;
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
      if (_selectedType == ExpenseType.chargesImmo) {
        if (_selectedProperty == null || _selectedImmoReason == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Veuillez sélectionner un bien et une raison')),
          );
          return;
        }
      } else {
        if (_selectedPersonalReason == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Veuillez sélectionner une raison')),
          );
          return;
        }
      }

      final expense = WalletExpense(
        type: _selectedType,
        property: _selectedType == ExpenseType.chargesImmo
            ? _selectedProperty
            : null,
        immoReason: _selectedType == ExpenseType.chargesImmo
            ? _selectedImmoReason
            : null,
        personalReason: _selectedType == ExpenseType.personnelle
            ? _selectedPersonalReason
            : null,
        amount: double.parse(_amountController.text),
        note: _noteController.text.isEmpty ? null : _noteController.text,
        date: _selectedDate,
      );

      context.read<WalletCubit>().addExpense(expense);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dépense ajoutée avec succès')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PrimaryBottomSheet(
      title: 'Nouvelle dépense',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Type',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            SegmentedButton<ExpenseType>(
              segments: ExpenseType.values
                  .map((type) => ButtonSegment(
                        value: type,
                        label: Text(type.label),
                      ))
                  .toList(),
              selected: {_selectedType},
              onSelectionChanged: (Set<ExpenseType> newSelection) {
                setState(() {
                  _selectedType = newSelection.first;
                  if (_selectedType == ExpenseType.personnelle) {
                    _selectedProperty = null;
                    _selectedImmoReason = null;
                  } else {
                    _selectedPersonalReason = null;
                  }
                });
              },
            ),
            const SizedBox(height: AppTheme.padding),
            if (_selectedType == ExpenseType.chargesImmo) ...[
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
              Text(
                'Raison',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<ImmoChargeReason>(
                initialValue: _selectedImmoReason,
                decoration: const InputDecoration(
                  hintText: 'Sélectionner une raison',
                ),
                items: ImmoChargeReason.values
                    .map((reason) => DropdownMenuItem(
                          value: reason,
                          child: Text(reason.label),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedImmoReason = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Veuillez sélectionner une raison';
                  }
                  return null;
                },
              ),
            ] else ...[
              Text(
                'Raison',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<PersonalReason>(
                initialValue: _selectedPersonalReason,
                decoration: const InputDecoration(
                  hintText: 'Sélectionner une raison',
                ),
                items: PersonalReason.values
                    .map((reason) => DropdownMenuItem(
                          value: reason,
                          child: Text(reason.label),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPersonalReason = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Veuillez sélectionner une raison';
                  }
                  return null;
                },
              ),
            ],
            const SizedBox(height: AppTheme.padding),
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

