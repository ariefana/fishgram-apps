import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

/// Authentication state.
enum AuthState { initial, loading, authenticated, unauthenticated, onboarding }

/// Provider managing authentication state.
class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final StorageService _storageService;

  AuthState _state = AuthState.initial;
  UserModel? _user;
  String? _errorMessage;
  String? _successMessage;

  AuthProvider({
    required AuthService authService,
    required StorageService storageService,
  })  : _authService = authService,
        _storageService = storageService;

  // ── Getters ───────────────────────────────────────────────────────────
  AuthState get state => _state;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  bool get isAuthenticated => _state == AuthState.authenticated;

  // ── Initialize ────────────────────────────────────────────────────────
  Future<void> initialize() async {
    _state = AuthState.loading;
    notifyListeners();

    final isLoggedIn = await _storageService.isLoggedIn();
    if (isLoggedIn) {
      // In real app, verify token with Firebase and refresh if needed
      _user = _authService.currentUser;
      if (_user != null) {
        _state = AuthState.authenticated;
      } else {
        // Token exists but no user — re-login needed
        _state = AuthState.unauthenticated;
      }
    } else {
      _state = AuthState.unauthenticated;
    }
    notifyListeners();
  }

  // ── Login ─────────────────────────────────────────────────────────────
  Future<bool> login(String email, String password) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.login(email, password);

    if (result.isSuccess) {
      _user = result.user;
      await _storageService.saveToken(result.token!);
      await _storageService.saveUserId(result.user!.id);
      await _storageService.setLoggedIn(true);

      final onboardingDone = await _storageService.isOnboardingComplete();
      _state = onboardingDone ? AuthState.authenticated : AuthState.onboarding;
      notifyListeners();
      return true;
    }

    _errorMessage = result.errorMessage;
    _state = AuthState.unauthenticated;
    notifyListeners();
    return false;
  }

  // ── Register ──────────────────────────────────────────────────────────
  Future<bool> register(
    String name,
    String email,
    String password,
    String confirmPassword,
  ) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    final result =
        await _authService.register(name, email, password, confirmPassword);

    if (result.isSuccess) {
      _user = result.user;
      await _storageService.saveToken(result.token!);
      await _storageService.saveUserId(result.user!.id);
      await _storageService.setLoggedIn(true);
      _state = AuthState.onboarding;
      notifyListeners();
      return true;
    }

    _errorMessage = result.errorMessage;
    _state = AuthState.unauthenticated;
    notifyListeners();
    return false;
  }

  // ── Forgot Password ──────────────────────────────────────────────────
  Future<bool> forgotPassword(String email) async {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    final result = await _authService.forgotPassword(email);

    if (result.isSuccess) {
      _successMessage = result.message;
      notifyListeners();
      return true;
    }

    _errorMessage = result.errorMessage;
    notifyListeners();
    return false;
  }

  // ── Complete Onboarding ───────────────────────────────────────────────
  Future<void> completeOnboarding({
    required String fishingType,
    required String location,
  }) async {
    await _authService.updateProfile(
      fishingType: fishingType,
      location: location,
    );
    _user = _authService.currentUser;
    await _storageService.setOnboardingComplete(true);
    _state = AuthState.authenticated;
    notifyListeners();
  }

  // ── Update Profile ────────────────────────────────────────────────────
  Future<void> updateProfile({
    String? name,
    String? username,
    String? bio,
    String? avatar,
  }) async {
    await _authService.updateProfile(
      name: name,
      username: username,
      bio: bio,
      avatar: avatar,
    );
    _user = _authService.currentUser;
    notifyListeners();
  }

  // ── Logout ────────────────────────────────────────────────────────────
  Future<void> logout() async {
    _state = AuthState.loading;
    notifyListeners();

    await _authService.logout();
    await _storageService.clearAll();
    _user = null;
    _state = AuthState.unauthenticated;
    notifyListeners();
  }

  // ── Clear Messages ────────────────────────────────────────────────────
  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
  }
}
