import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/gradient_button.dart';

/// Screen instructing users to verify their email address.
class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _isChecking = false;
  bool _isResending = false;
  int _cooldownSeconds = 0;
  Timer? _cooldownTimer;

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    setState(() {
      _cooldownSeconds = 30;
    });
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_cooldownSeconds > 0) {
        setState(() {
          _cooldownSeconds--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _checkVerification() async {
    setState(() => _isChecking = true);
    final verified = await context.read<AuthProvider>().checkEmailVerified();
    if (!mounted) return;
    setState(() => _isChecking = false);

    if (verified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email berhasil diverifikasi! Selamat datang 🎣'),
          backgroundColor: AppTheme.successGreen,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email belum diverifikasi. Silakan periksa inbox atau folder spam email Anda.'),
          backgroundColor: AppTheme.likeRed,
        ),
      );
    }
  }

  Future<void> _resendEmail() async {
    if (_cooldownSeconds > 0) return;
    setState(() => _isResending = true);
    try {
      await context.read<AuthProvider>().resendVerificationEmail();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email verifikasi baru telah dikirim! 📩'),
          backgroundColor: AppTheme.successGreen,
        ),
      );
      _startCooldown();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengirim email: ${e.toString()}'),
          backgroundColor: AppTheme.likeRed,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final userEmail = auth.user?.email ?? 'email Anda';

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, AppTheme.surfaceWhite],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                // Icon Illustration with ambient glow effect
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.mark_email_read_outlined,
                      size: 80,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Title
                const Text(
                  'Verifikasi Email Anda',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                // Subtitle
                Text(
                  'Kami telah mengirimkan tautan verifikasi ke email:\n',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textHint,
                  ),
                ),
                Text(
                  userEmail,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlue,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Silakan klik tautan di email tersebut untuk mengaktifkan akun Anda sebelum masuk ke FishGram.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textHint,
                  ),
                ),
                const SizedBox(height: 40),
                // Primary action: check verification
                GradientButton(
                  text: 'Saya Sudah Verifikasi 🎣',
                  isLoading: _isChecking,
                  onPressed: _isChecking ? null : _checkVerification,
                ),
                const SizedBox(height: 16),
                // Secondary action: resend
                Center(
                  child: TextButton(
                    onPressed: (_isResending || _cooldownSeconds > 0) ? null : _resendEmail,
                    child: Text(
                      _cooldownSeconds > 0
                          ? 'Kirim ulang email dalam ${_cooldownSeconds}s'
                          : 'Kirim Ulang Email',
                      style: TextStyle(
                        color: _cooldownSeconds > 0 ? AppTheme.textHint : AppTheme.primaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                // Back to login (Logout)
                TextButton.icon(
                  onPressed: () => auth.logout(),
                  icon: const Icon(Icons.arrow_back, color: AppTheme.textHint, size: 18),
                  label: const Text(
                    'Kembali ke Login',
                    style: TextStyle(color: AppTheme.textHint, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
