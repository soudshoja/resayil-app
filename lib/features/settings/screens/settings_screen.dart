import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/theme/app_colors.dart';
import '../../../core/widgets/chat_avatar.dart';
import '../../auth/providers/auth_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
      ),
      body: ListView(
        children: [
          // Profile section
          ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: const ChatAvatar(name: 'Resayil', size: 56),
            title: const Text(
              'Resayil Business',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            subtitle: const Text(
              'wa.resayil.io',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            trailing: const Icon(Icons.qr_code, color: AppColors.accent),
            onTap: () => context.go('/settings/profile'),
          ),
          const Divider(),

          // Settings items
          _buildSettingsTile(
            icon: Icons.key,
            iconBg: const Color(0xFF1a73e8),
            title: 'API Key',
            subtitle: 'Manage your API connection',
            onTap: () {},
          ),
          _buildSettingsTile(
            icon: Icons.notifications,
            iconBg: const Color(0xFFe91e63),
            title: 'Notifications',
            subtitle: 'Message and group notifications',
            onTap: () {},
          ),
          _buildSettingsTile(
            icon: Icons.language,
            iconBg: const Color(0xFF9c27b0),
            title: 'Language',
            subtitle: 'English',
            onTap: () {},
          ),
          _buildSettingsTile(
            icon: Icons.storage,
            iconBg: AppColors.accent,
            title: 'Storage and Data',
            subtitle: 'Network usage, storage',
            onTap: () {},
          ),
          _buildSettingsTile(
            icon: Icons.help,
            iconBg: const Color(0xFF00bcd4),
            title: 'Help',
            subtitle: 'FAQ, contact us',
            onTap: () {},
          ),
          _buildSettingsTile(
            icon: Icons.info,
            iconBg: const Color(0xFF607d8b),
            title: 'About',
            subtitle: 'Version 1.0.0',
            onTap: () {},
          ),
          const Divider(),

          // Logout
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.logout, color: AppColors.error),
            ),
            title: const Text(
              'Logout',
              style: TextStyle(color: AppColors.error),
            ),
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Logout',
                          style: TextStyle(color: AppColors.error)),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                await ref.read(authStateProvider.notifier).logout();
                if (context.mounted) context.go('/login');
              }
            },
          ),
          const SizedBox(height: 24),

          // Footer
          const Center(
            child: Text(
              'Resayil WhatsApp Business\nwa.resayil.io',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required Color iconBg,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconBg.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconBg, size: 22),
      ),
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
      ),
      onTap: onTap,
    );
  }
}
