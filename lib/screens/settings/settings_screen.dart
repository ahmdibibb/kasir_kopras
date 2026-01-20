import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
      ),
      body: ListView(
        children: [
          // User Info
          Obx(() {
            final user = authController.user;
            return Container(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              color: AppTheme.primaryColor.withOpacity(0.1),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: AppTheme.primaryColor,
                    child: Text(
                      user?.displayName?.substring(0, 1).toUpperCase() ?? 'U',
                      style: const TextStyle(
                        fontSize: 32,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.displayName ?? 'User',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          user?.email ?? '',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.textSecondaryColor,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
          
          const SizedBox(height: AppTheme.spacingM),
          
          // Settings Items
          _buildSettingsItem(
            context,
            icon: Icons.person_outline,
            title: 'Profil',
            subtitle: 'Edit profil Anda',
            onTap: () {
              // TODO: Navigate to profile edit
            },
          ),
          
          _buildSettingsItem(
            context,
            icon: Icons.notifications_outline,
            title: 'Notifikasi',
            subtitle: 'Pengaturan notifikasi',
            onTap: () {
              // TODO: Navigate to notification settings
            },
          ),
          
          _buildSettingsItem(
            context,
            icon: Icons.backup_outlined,
            title: 'Backup & Restore',
            subtitle: 'Cadangkan data Anda',
            onTap: () {
              // TODO: Navigate to backup settings
            },
          ),
          
          _buildSettingsItem(
            context,
            icon: Icons.help_outline,
            title: 'Bantuan',
            subtitle: 'Panduan penggunaan aplikasi',
            onTap: () {
              // TODO: Navigate to help
            },
          ),
          
          _buildSettingsItem(
            context,
            icon: Icons.info_outline,
            title: 'Tentang Aplikasi',
            subtitle: 'Versi 1.0.0',
            onTap: () {
              _showAboutDialog(context);
            },
          ),
          
          const Divider(height: 32),
          
          // Logout
          _buildSettingsItem(
            context,
            icon: Icons.logout,
            title: 'Keluar',
            subtitle: 'Logout dari aplikasi',
            iconColor: AppTheme.errorColor,
            onTap: () {
              _showLogoutDialog(context, authController);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(AppTheme.spacingS),
        decoration: BoxDecoration(
          color: (iconColor ?? AppTheme.primaryColor).withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppTheme.radiusS),
        ),
        child: Icon(
          icon,
          color: iconColor ?? AppTheme.primaryColor,
        ),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Kasir Kopras',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(
        Icons.point_of_sale_rounded,
        size: 48,
        color: AppTheme.primaryColor,
      ),
      children: [
        const Text(
          'Aplikasi kasir mobile dengan Firebase untuk manajemen penjualan, produk, dan laporan bisnis.',
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context, AuthController authController) {
    Get.dialog(
      AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              authController.logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }
}
