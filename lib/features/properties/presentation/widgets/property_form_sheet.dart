import 'package:flutter/material.dart';

import '../../domain/entities/property.dart';
import '../../../../theme/app_theme.dart';

class PropertyFormResult {
  final String label;
  final String city;
  final String address;
  final String? note;

  const PropertyFormResult({
    required this.label,
    required this.city,
    required this.address,
    required this.note,
  });
}

class PropertyFormSheet extends StatefulWidget {
  final Property? existing;

  const PropertyFormSheet({super.key, this.existing});

  @override
  State<PropertyFormSheet> createState() => _PropertyFormSheetState();

  static Future<PropertyFormResult?> open(
    BuildContext context, {
    Property? existing,
  }) {
    return showModalBottomSheet<PropertyFormResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.cardColor,
      builder: (_) => PropertyFormSheet(existing: existing),
    );
  }
}

class _PropertyFormSheetState extends State<PropertyFormSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _labelController;
  late final TextEditingController _cityController;
  late final TextEditingController _addressController;
  late final TextEditingController _noteController;

  @override
  void initState() {
    super.initState();

    _labelController = TextEditingController(text: widget.existing?.label ?? '');
    _cityController = TextEditingController(text: widget.existing?.city ?? '');
    _addressController =
        TextEditingController(text: widget.existing?.address ?? '');
    _noteController = TextEditingController(text: widget.existing?.note ?? '');
  }

  @override
  void dispose() {
    _labelController.dispose();
    _cityController.dispose();
    _addressController.dispose();
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
              isEditing ? 'Modifier le bien' : 'Nouveau bien',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _labelController,
              decoration: const InputDecoration(labelText: 'Nom du bien'),
              textInputAction: TextInputAction.next,
              validator: (v) {
                final value = v?.trim() ?? '';
                if (value.isEmpty) return 'Champ obligatoire';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _cityController,
              decoration: const InputDecoration(labelText: 'Ville'),
              textInputAction: TextInputAction.next,
              validator: (v) {
                final value = v?.trim() ?? '';
                if (value.isEmpty) return 'Champ obligatoire';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'Adresse'),
              textInputAction: TextInputAction.next,
              validator: (v) {
                final value = v?.trim() ?? '';
                if (value.isEmpty) return 'Champ obligatoire';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Note (optionnel)',
              ),
              minLines: 1,
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (!(_formKey.currentState?.validate() ?? false)) return;

                  Navigator.of(context).pop(
                    PropertyFormResult(
                      label: _labelController.text.trim(),
                      city: _cityController.text.trim(),
                      address: _addressController.text.trim(),
                      note: _noteController.text.trim().isEmpty
                          ? null
                          : _noteController.text.trim(),
                    ),
                  );
                },
                child: Text(isEditing ? 'Enregistrer' : 'Créer'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
