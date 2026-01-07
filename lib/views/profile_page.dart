import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../logic/profile_cubit.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_fade_in.dart';
import '../widgets/animated_slide_in.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          return SingleChildScrollView(
            child: Column(
              children: [
                // Header avec image de profil
                AnimatedFadeIn(
                  delay: const Duration(milliseconds: 100),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.accentColor.withOpacity(0.1),
                          AppTheme.accentColor.withOpacity(0.05),
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.only(
                      top: AppTheme.padding * 2,
                      bottom: AppTheme.padding * 2,
                    ),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppTheme.accentColor,
                                  width: 4,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.accentColor.withOpacity(0.3),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: state.profileImagePath != null
                                    ? Image.file(
                                        File(state.profileImagePath!),
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              AppTheme.accentColor,
                                              AppTheme.accentColor.withOpacity(0.7),
                                            ],
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.person,
                                          size: 60,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () => _showImagePicker(context),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 3,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppTheme.padding * 1.5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              state.name,
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(width: AppTheme.smallPadding),
                            GestureDetector(
                              onTap: () => _showEditNameDialog(context, state.name),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppTheme.accentColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.edit,
                                  size: 18,
                                  color: AppTheme.accentColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppTheme.smallPadding),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.phone,
                              size: 16,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              state.phone,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: const Color(0xFF6B7280),
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.padding),
                // Section Informations
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.padding),
                  child: Column(
                    children: [
                      AnimatedSlideIn(
                        delay: const Duration(milliseconds: 200),
                        child: _buildInfoCard(
                          context,
                          icon: Icons.person_outline,
                          title: 'Informations personnelles',
                          items: [
                            _InfoItem(
                              label: 'Nom complet',
                              value: state.name,
                              onTap: () => _showEditNameDialog(context, state.name),
                            ),
                            _InfoItem(
                              label: 'Téléphone',
                              value: state.phone,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppTheme.padding),
                      AnimatedSlideIn(
                        delay: const Duration(milliseconds: 300),
                        child: _buildInfoCard(
                          context,
                          icon: Icons.settings_outlined,
                          title: 'Paramètres',
                          items: [
                            _InfoItem(
                              label: 'Notifications',
                              value: 'Activées',
                              trailing: Switch(
                                value: true,
                                onChanged: (value) {},
                                activeColor: AppTheme.accentColor,
                              ),
                            ),
                            _InfoItem(
                              label: 'Thème',
                              value: 'Clair',
                              trailing: const Icon(
                                Icons.chevron_right,
                                color: Color(0xFF9CA3AF),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppTheme.padding),
                      AnimatedSlideIn(
                        delay: const Duration(milliseconds: 400),
                        child: _buildInfoCard(
                          context,
                          icon: Icons.info_outline,
                          title: 'À propos',
                          items: [
                            _InfoItem(
                              label: 'Version',
                              value: '1.0.0',
                            ),
                            _InfoItem(
                              label: 'Support',
                              value: 'Contactez-nous',
                              trailing: const Icon(
                                Icons.chevron_right,
                                color: Color(0xFF9CA3AF),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppTheme.padding * 2),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required List<_InfoItem> items,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppTheme.padding),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: AppTheme.accentColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppTheme.smallPadding),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...items.map((item) => _buildInfoItem(context, item)),
        ],
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, _InfoItem item) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(0),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.padding,
            vertical: AppTheme.padding,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.label,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF9CA3AF),
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.value,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              ),
              if (item.trailing != null) item.trailing!,
            ],
          ),
        ),
      ),
    );
  }

  void _showEditNameDialog(BuildContext context, String currentName) {
    final controller = TextEditingController(text: currentName);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        ),
        title: const Text('Modifier le nom'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Nom complet',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                context.read<ProfileCubit>().updateName(controller.text.trim());
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Nom modifié avec succès'),
                    backgroundColor: AppTheme.successColor,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  void _showImagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppTheme.cardRadius),
          ),
        ),
        padding: const EdgeInsets.all(AppTheme.padding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppTheme.padding),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.photo_library,
                  color: AppTheme.accentColor,
                ),
              ),
              title: const Text('Choisir depuis la galerie'),
              onTap: () async {
                Navigator.of(context).pop();
                final picker = ImagePicker();
                final image = await picker.pickImage(source: ImageSource.gallery);
                if (image != null && context.mounted) {
                  context.read<ProfileCubit>().updateProfileImage(image.path);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Photo de profil mise à jour'),
                      backgroundColor: AppTheme.successColor,
                    ),
                  );
                }
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: AppTheme.accentColor,
                ),
              ),
              title: const Text('Prendre une photo'),
              onTap: () async {
                Navigator.of(context).pop();
                final picker = ImagePicker();
                final image = await picker.pickImage(source: ImageSource.camera);
                if (image != null && context.mounted) {
                  context.read<ProfileCubit>().updateProfileImage(image.path);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Photo de profil mise à jour'),
                      backgroundColor: AppTheme.successColor,
                    ),
                  );
                }
              },
            ),
            if (context.read<ProfileCubit>().state.profileImagePath != null)
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.errorColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    color: AppTheme.errorColor,
                  ),
                ),
                title: const Text('Supprimer la photo'),
                onTap: () {
                  Navigator.of(context).pop();
                  context.read<ProfileCubit>().updateProfileImage(null);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Photo de profil supprimée'),
                      backgroundColor: AppTheme.successColor,
                    ),
                  );
                },
              ),
            const SizedBox(height: AppTheme.padding),
          ],
        ),
      ),
    );
  }
}

class _InfoItem {
  final String label;
  final String value;
  final VoidCallback? onTap;
  final Widget? trailing;

  _InfoItem({
    required this.label,
    required this.value,
    this.onTap,
    this.trailing,
  });
}

