import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/gradient_button.dart';

/// Register screen — redirects to Google Sign-In.
///
/// Since authentication is handled via Google Sign-In,
/// this screen prompts the user to create an account using Google.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _isLoading = false;

  Future<void> _signUpWithGoogle() async {
    setState(() => _isLoading = true);

    final success = await context.read<AuthProvider>().signInWithGoogle();

    if (mounted) {
      setState(() => _isLoading = false);
      if (!success) {
        final error = context.read<AuthProvider>().errorMessage;
        if (error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error), backgroundColor: AppTheme.errorRed),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buat Akun')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Illustration ──────────────────────────────────
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_add,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  'Bergabung dengan ${AppConstants.appName}',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Buat akun untuk mulai pamer tangkapanmu!\nDaftar dengan akun Google kamu.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                        height: 1.5,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // ── Google Sign-Up Button ─────────────────────────
                GradientButton(
                  text: 'Daftar dengan Google',
                  isLoading: _isLoading,
                  icon: Icons.login,
                  onPressed: _isLoading ? null : _signUpWithGoogle,
                ),
                const SizedBox(height: 24),

                // ── Login link ────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Sudah punya akun? ',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Masuk'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
