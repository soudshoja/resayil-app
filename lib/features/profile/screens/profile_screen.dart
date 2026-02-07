import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/theme/app_colors.dart';
import '../../../core/widgets/chat_avatar.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        children: [
          const SizedBox(height: 24),
          // Avatar
          Center(
            child: Stack(
              children: [
                const ChatAvatar(name: 'Resayil', size: 120),
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
            icon: Icons.person,
            label: 'Name',
            value: 'Resayil Business',
            onTap: () {},
          ),
          _buildProfileField(
            icon: Icons.info_outline,
            label: 'About',
            value: 'WhatsApp Business Platform',
            onTap: () {},
          ),
          _buildProfileField(
            icon: Icons.phone,
            label: 'Phone',
            value: '+965 XXXX XXXX',
            onTap: null,
          ),
          _buildProfileField(
            icon: Icons.business,
            label: 'Business Name',
            value: 'Resayil',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildProfileField({
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
        value,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
        ),
      ),
      trailing: onTap != null
          ? const Icon(Icons.edit, color: AppColors.accent, size: 20)
          : null,
      onTap: onTap,
    );
  }
}
