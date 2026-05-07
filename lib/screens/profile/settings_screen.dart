import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/avatar_widget.dart';

/// Settings screen with account info, preferences, and logout.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        children: [
          // ── Signed-in account card ─────────────────────────────────
          if (user != null)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                ),
              ),
              child: Row(
                children: [
                  AvatarWidget(
                    imageUrl: user.avatar,
                    name: user.name,
                    radius: 28,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user.email,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.accentGreen.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Google Account',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.accentGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          const _SectionHeader(title: 'Akun'),
          _SettingsTile(
            icon: Icons.email_outlined,
            title: 'Ubah Email',
            subtitle: user?.email ?? 'Tidak tersedia',
            onTap: () => _showSnack(context, 'Fitur ubah email (Firebase)'),
          ),
          _SettingsTile(
            icon: Icons.lock_outlined,
            title: 'Ubah Password',
            subtitle: 'Verifikasi via Firebase',
            onTap: () =>
                _showSnack(context, 'Fitur ubah password (Firebase)'),
          ),
          const Divider(),

          const _SectionHeader(title: 'Preferensi'),
          _SettingsTile(
            icon: Icons.notifications_outlined,
            title: 'Notifikasi',
            subtitle: 'Kelola notifikasi push',
            trailing: Switch(
              value: true,
              onChanged: (_) => _showSnack(context, 'Toggle notifikasi'),
            ),
          ),
          _SettingsTile(
            icon: Icons.dark_mode_outlined,
            title: 'Mode Gelap',
            subtitle: 'Segera hadir',
            trailing: Switch(
              value: false,
              onChanged: (_) =>
                  _showSnack(context, 'Dark mode segera hadir'),
            ),
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

          // ── Logout Button ──────────────────────────────────────────
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
          const SizedBox(height: 8),
          Text(
            'Ini akan keluar dari Google dan FishGram',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textHint,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _showSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  /// Show logout confirmation dialog.
  ///
  /// Performs both Google Sign-Out and Firebase Sign-Out via AuthProvider.
  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Keluar?'),
        content: const Text(
          'Kamu akan keluar dari akun Google dan FishGram. '
          'Yakin ingin melanjutkan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              // This calls AuthService.signOut() which does:
              // 1. GoogleSignIn.signOut() — clears Google session
              // 2. FirebaseAuth.signOut() — clears Firebase session
              // Then clears SharedPreferences
              context.read<AuthProvider>().logout();
            },
            child: const Text(
              'Keluar',
              style: TextStyle(color: AppTheme.errorRed),
            ),
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
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .titleSmall
            ?.copyWith(color: AppTheme.textSecondary),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryBlue),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing:
          trailing ?? (onTap != null ? const Icon(Icons.chevron_right) : null),
      onTap: onTap,
    );
  }
}
