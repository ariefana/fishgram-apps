import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../providers/auth_provider.dart';
import 'package:ionicons/ionicons.dart';

/// Login screen with Google Sign-In.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isGoogleLoading = false;

  Future<void> _signInWithGoogle() async {
    setState(() => _isGoogleLoading = true);

    final success = await context.read<AuthProvider>().signInWithGoogle();

    if (mounted) {
      setState(() => _isGoogleLoading = false);

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
    final authProvider = context.watch<AuthProvider>();
    final isLoading =
        authProvider.state == AuthState.loading || _isGoogleLoading;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Logo ──────────────────────────────────────────────
                Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.phishing,
                    size: 52,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 28),

                // ── Title ─────────────────────────────────────────────
                Text(
                  AppConstants.appName,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  AppConstants.appTagline,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // ── Illustration text ─────────────────────────────────
                // Container(
                //   padding: const EdgeInsets.all(24),
                //   decoration: BoxDecoration(
                //     color: AppTheme.primaryBlue.withValues(alpha: 0.04),
                //     borderRadius: BorderRadius.circular(20),
                //     border: Border.all(
                //       color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                //     ),
                //   ),
                //   child: Column(
                //     children: [
                //       Icon(
                //         Icons.waves,
                //         size: 48,
                //         color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                //       ),
                //       const SizedBox(height: 12),
                //       // Text(
                //       //   'Bagikan hasil tangkapanmu,\ntemukan teman pemancing baru!',
                //       //   style:
                //       //       Theme.of(context).textTheme.bodyMedium?.copyWith(
                //       //             color: AppTheme.textSecondary,
                //       //             height: 1.5,
                //       //           ),
                //       //   textAlign: TextAlign.center,
                //       // ),
                //     ],
                //   ),
                // ),
                const SizedBox(height: 20),

                // ── Google Sign-In Button ─────────────────────────────
                _GoogleSignInButton(
                  isLoading: isLoading,
                  onPressed: isLoading ? null : _signInWithGoogle,
                ),
                const SizedBox(height: 16),

                // ── Divider ───────────────────────────────────────────
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'atau',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textHint,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Email login placeholder ───────────────────────────
                OutlinedButton.icon(
                  onPressed: isLoading
                      ? null
                      : () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Login email/password akan tersedia segera',
                              ),
                            ),
                          );
                        },
                  icon: const Icon(Icons.email_outlined, size: 20),
                  label: const Text('Masuk dengan Email'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // ── Terms ─────────────────────────────────────────────
                Text(
                  'Dengan masuk, kamu menyetujui\nSyarat & Ketentuan dan Kebijakan Privasi',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textHint,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom Google Sign-In button matching Google brand guidelines.
class _GoogleSignInButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onPressed;

  const _GoogleSignInButton({required this.isLoading, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppTheme.textPrimary,
          elevation: 1,
          shadowColor: Colors.black.withValues(alpha: 0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: AppTheme.dividerColor),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // // Google "G" logo
                  // Container(
                  //   width: 24,
                  //   height: 24,
                  //   decoration: BoxDecoration(
                  //     borderRadius: BorderRadius.circular(4),
                  //   ),
                  //   child: CustomPaint(painter: _GoogleLogoPainter()),
                  // ),
                  const Icon(Ionicons.logo_google, size: 25),
                  const SizedBox(width: 12),
                  Text(
                    'Masuk dengan Google',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Custom painter for the Google "G" logo.
// class _GoogleLogoPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final double w = size.width;
//     final double h = size.height;
//     final double cx = w / 2;
//     final double cy = h / 2;
//     final double r = w * 0.45;

//     // Blue arc (top-right)
//     final bluePaint = Paint()
//       ..color = const Color(0xFF4285F4)
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = w * 0.18
//       ..strokeCap = StrokeCap.butt;
//     canvas.drawArc(
//       Rect.fromCircle(center: Offset(cx, cy), radius: r),
//       -0.8, // start angle
//       1.6, // sweep angle
//       false,
//       bluePaint,
//     );

//     // Red arc (top-left)
//     final redPaint = Paint()
//       ..color = const Color(0xFFEA4335)
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = w * 0.18
//       ..strokeCap = StrokeCap.butt;
//     canvas.drawArc(
//       Rect.fromCircle(center: Offset(cx, cy), radius: r),
//       -0.8 + 1.6, // start
//       1.2, // sweep
//       false,
//       redPaint,
//     );

//     // Yellow arc (bottom-left)
//     final yellowPaint = Paint()
//       ..color = const Color(0xFFFBBC05)
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = w * 0.18
//       ..strokeCap = StrokeCap.butt;
//     canvas.drawArc(
//       Rect.fromCircle(center: Offset(cx, cy), radius: r),
//       -0.8 + 1.6 + 1.2, // start
//       1.2, // sweep
//       false,
//       yellowPaint,
//     );

//     // Green arc (bottom-right)
//     final greenPaint = Paint()
//       ..color = const Color(0xFF34A853)
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = w * 0.18
//       ..strokeCap = StrokeCap.butt;
//     canvas.drawArc(
//       Rect.fromCircle(center: Offset(cx, cy), radius: r),
//       -0.8 + 1.6 + 1.2 + 1.2, // start
//       1.0, // sweep
//       false,
//       greenPaint,
//     );

//     // Center horizontal bar (part of the "G")
//     final barPaint = Paint()
//       ..color = const Color(0xFF4285F4)
//       ..style = PaintingStyle.fill;
//     canvas.drawRect(
//       Rect.fromLTWH(cx - w * 0.02, cy - h * 0.08, w * 0.48, h * 0.16),
//       barPaint,
//     );
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }
