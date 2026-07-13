import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/avatar_widget.dart';
import '../../widgets/custom_text_field.dart';

/// Settings screen with account info, preferences, and logout.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

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
                            color: (auth.isGoogleUser
                                    ? AppTheme.accentGreen
                                    : AppTheme.primaryBlue)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            auth.isGoogleUser ? 'Google Account' : 'Email Account',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: auth.isGoogleUser
                                  ? AppTheme.accentGreen
                                  : AppTheme.primaryBlue,
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
            onTap: () {
              if (auth.isGoogleUser) {
                _showGoogleUserWarning(context, 'mengubah email');
              } else {
                _showChangeEmailDialog(context);
              }
            },
          ),
          _SettingsTile(
            icon: Icons.lock_outlined,
            title: 'Ubah Password',
            subtitle: 'Verifikasi via Firebase',
            onTap: () {
              if (auth.isGoogleUser) {
                _showGoogleUserWarning(context, 'mengubah kata sandi');
              } else {
                _showChangePasswordDialog(context);
              }
            },
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

  void _showGoogleUserWarning(BuildContext context, String actionName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Akun Terhubung Google'),
        content: Text(
          'Akun Anda terhubung langsung dengan Google. '
          'Untuk $actionName, silakan lakukan langsung dari pengaturan akun Google Anda.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Mengerti'),
          ),
        ],
      ),
    );
  }

  void _showChangeEmailDialog(BuildContext context) {
    final passwordController = TextEditingController();
    final emailController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        bool isLoading = false;
        String? dialogError;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Ubah Alamat Email'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (dialogError != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.likeRed.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          dialogError!,
                          style: const TextStyle(color: AppTheme.likeRed, fontSize: 12),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    CustomTextField(
                      controller: passwordController,
                      labelText: 'Kata Sandi Saat Ini',
                      prefixIcon: Icons.lock_outlined,
                      obscureText: true,
                      validator: (v) => v == null || v.isEmpty ? 'Masukkan kata sandi saat ini' : null,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: emailController,
                      labelText: 'Email Baru',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Masukkan email baru';
                        if (!v.contains('@') || !v.contains('.')) return 'Format email tidak valid';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(ctx),
                  child: const Text('Batal'),
                ),
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          setDialogState(() {
                            isLoading = true;
                            dialogError = null;
                          });

                          final error = await context.read<AuthProvider>().changeEmail(
                                currentPassword: passwordController.text,
                                newEmail: emailController.text.trim(),
                              );

                          if (!context.mounted) return;

                          if (error != null) {
                            setDialogState(() {
                              isLoading = false;
                              dialogError = error;
                            });
                          } else {
                            Navigator.pop(ctx);
                            _showSnack(context, 'Email berhasil diperbarui!');
                          }
                        },
                  child: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        bool isLoading = false;
        String? dialogError;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Ubah Kata Sandi'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (dialogError != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppTheme.likeRed.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            dialogError!,
                            style: const TextStyle(color: AppTheme.likeRed, fontSize: 12),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      CustomTextField(
                        controller: currentPasswordController,
                        labelText: 'Kata Sandi Saat Ini',
                        prefixIcon: Icons.lock_outlined,
                        obscureText: true,
                        validator: (v) => v == null || v.isEmpty ? 'Masukkan kata sandi saat ini' : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: newPasswordController,
                        labelText: 'Kata Sandi Baru',
                        prefixIcon: Icons.vpn_key_outlined,
                        obscureText: true,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Masukkan kata sandi baru';
                          if (v.length < 6) return 'Minimal 6 karakter';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: confirmPasswordController,
                        labelText: 'Konfirmasi Kata Sandi Baru',
                        prefixIcon: Icons.check_circle_outline,
                        obscureText: true,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Konfirmasi kata sandi baru';
                          if (v != newPasswordController.text) return 'Kata sandi baru tidak cocok';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(ctx),
                  child: const Text('Batal'),
                ),
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          setDialogState(() {
                            isLoading = true;
                            dialogError = null;
                          });

                          final error = await context.read<AuthProvider>().changePassword(
                                currentPassword: currentPasswordController.text,
                                newPassword: newPasswordController.text,
                              );

                          if (!context.mounted) return;

                          if (error != null) {
                            setDialogState(() {
                              isLoading = false;
                              dialogError = error;
                            });
                          } else {
                            Navigator.pop(ctx);
                            _showSnack(context, 'Kata sandi berhasil diperbarui!');
                          }
                        },
                  child: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Show logout confirmation dialog.
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
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
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
