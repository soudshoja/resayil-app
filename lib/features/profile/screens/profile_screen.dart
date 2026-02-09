import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/theme/app_colors.dart';
import '../../../core/widgets/chat_avatar.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Profile')),
      body: profileState.when(
        data: (profile) => ListView(
          children: [
            const SizedBox(height: 24),
            // Avatar
            Center(
              child: Stack(
                children: [
                  ChatAvatar(
                    name: profile.name ?? 'User',
                    size: 120,
                    imageUrl: profile.avatar,
                  ),
                  Positioned(
                    right: 4,
                    bottom: 4,
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.accent,
                      child: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Name
            _buildProfileField(
              context: context,
              ref: ref,
              icon: Icons.person,
              label: 'Name',
              value: profile.name ?? '',
              onTap: () => _showEditDialog(
                context: context,
                ref: ref,
                title: 'Edit Name',
                currentValue: profile.name ?? '',
                onSave: (value) async {
                  await ref.read(profileProvider.notifier).updateProfile(name: value);
                },
              ),
            ),
            _buildProfileField(
              context: context,
              ref: ref,
              icon: Icons.info_outline,
              label: 'About',
              value: profile.about ?? '',
              onTap: () => _showEditDialog(
                context: context,
                ref: ref,
                title: 'Edit About',
                currentValue: profile.about ?? '',
                onSave: (value) async {
                  await ref.read(profileProvider.notifier).updateProfile(about: value);
                },
              ),
            ),
            _buildProfileField(
              context: context,
              ref: ref,
              icon: Icons.phone,
              label: 'Phone',
              value: profile.phone ?? '',
              onTap: null,
            ),
            _buildProfileField(
              context: context,
              ref: ref,
              icon: Icons.business,
              label: 'Business Name',
              value: profile.businessName ?? '',
              onTap: () => _showEditDialog(
                context: context,
                ref: ref,
                title: 'Edit Business Name',
                currentValue: profile.businessName ?? '',
                onSave: (value) async {
                  await ref.read(profileProvider.notifier).updateProfile(businessName: value);
                },
              ),
            ),
          ],
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text(
                'Failed to load profile',
                style: const TextStyle(color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.read(profileProvider.notifier).refresh(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileField({
    required BuildContext context,
    required WidgetRef ref,
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(
        label,
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
      ),
      subtitle: Text(
        value.isEmpty ? 'Not set' : value,
        style: TextStyle(
          color: value.isEmpty ? AppColors.textSecondary : AppColors.textPrimary,
          fontSize: 16,
        ),
      ),
      trailing: onTap != null
          ? const Icon(Icons.edit, color: AppColors.accent, size: 20)
          : null,
      onTap: onTap,
    );
  }

  Future<void> _showEditDialog({
    required BuildContext context,
    required WidgetRef ref,
    required String title,
    required String currentValue,
    required Future<void> Function(String) onSave,
  }) async {
    final controller = TextEditingController(text: currentValue);
    final messenger = ScaffoldMessenger.of(context);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(title, style: const TextStyle(color: AppColors.textPrimary)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Enter value',
            hintStyle: const TextStyle(color: AppColors.textSecondary),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.accent),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              final value = controller.text.trim();
              Navigator.of(context).pop();

              if (value.isEmpty) {
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Value cannot be empty'),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }

              try {
                await onSave(value);
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Profile updated successfully'),
                    backgroundColor: AppColors.accent,
                  ),
                );
              } catch (e) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('Failed to update: $e'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            child: const Text('Save', style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );

    controller.dispose();
  }
}
