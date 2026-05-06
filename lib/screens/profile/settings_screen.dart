import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';

/// Settings screen with account options and logout.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        children: [
          const _SectionHeader(title: 'Akun'),
          _SettingsTile(
            icon: Icons.email_outlined,
            title: 'Ubah Email',
            subtitle: 'Verifikasi via Firebase',
            onTap: () => _showSnack(context, 'Fitur ubah email (Firebase)'),
          ),
          _SettingsTile(
            icon: Icons.lock_outlined,
            title: 'Ubah Password',
            subtitle: 'Verifikasi via Firebase',
            onTap: () => _showSnack(context, 'Fitur ubah password (Firebase)'),
          ),
          const Divider(),
          const _SectionHeader(title: 'Preferensi'),
          _SettingsTile(
            icon: Icons.notifications_outlined,
            title: 'Notifikasi',
            subtitle: 'Kelola notifikasi push',
            trailing: Switch(value: true, onChanged: (_) => _showSnack(context, 'Toggle notifikasi')),
          ),
          _SettingsTile(
            icon: Icons.dark_mode_outlined,
            title: 'Mode Gelap',
            subtitle: 'Segera hadir',
            trailing: Switch(value: false, onChanged: (_) => _showSnack(context, 'Dark mode segera hadir')),
          ),
          const Divider(),
          const _SectionHeader(title: 'Lainnya'),
          _SettingsTile(
            icon: Icons.info_outlined,
            title: 'Tentang FishGram',
            subtitle: 'Versi 1.0.0',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.help_outlined,
            title: 'Bantuan',
            onTap: () {},
          ),
          const SizedBox(height: 16),
          // Logout
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton.icon(
              onPressed: () => _confirmLogout(context),
              icon: const Icon(Icons.logout),
              label: const Text('Keluar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorRed,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _showSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar?'),
        content: const Text('Apakah kamu yakin ingin keluar dari FishGram?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthProvider>().logout();
            },
            child: const Text('Keluar', style: TextStyle(color: AppTheme.errorRed)),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppTheme.textSecondary)),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _SettingsTile({required this.icon, required this.title, this.subtitle, this.onTap, this.trailing});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryBlue),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right) : null),
      onTap: onTap,
    );
  }
}
