import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'config/constants.dart';
import 'providers/auth_provider.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/onboarding_screen.dart';
import 'screens/main/main_screen.dart';

/// Root widget that listens to auth state and shows appropriate screen.
class FishGramApp extends StatelessWidget {
  const FishGramApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routes: {
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/forgot-password': (_) => const ForgotPasswordScreen(),
        '/onboarding': (_) => const OnboardingScreen(),
        '/main': (_) => const MainScreen(),
      },
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          switch (auth.state) {
            case AuthState.initial:
            case AuthState.loading:
              return const SplashScreen();
            case AuthState.unauthenticated:
              return const LoginScreen();
            case AuthState.onboarding:
              return const OnboardingScreen();
            case AuthState.authenticated:
              return const MainScreen();
          }
        },
      ),
    );
  }
}
