import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../services/api_service.dart';

/// Authentication state.
enum AuthState { initial, loading, authenticated, unauthenticated, onboarding, unverified }

/// Provider managing authentication state with Firebase Auth + Google Sign-In.
class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final StorageService _storageService;
  final ApiService _apiService;

  AuthState _state = AuthState.initial;
  UserModel? _user;
  String? _errorMessage;
  String? _successMessage;
  StreamSubscription<User?>? _authSubscription;

  AuthProvider({
    required AuthService authService,
    required StorageService storageService,
    required ApiService apiService,
  })  : _authService = authService,
        _storageService = storageService,
        _apiService = apiService;

  // ── Getters ───────────────────────────────────────────────────────────
  AuthState get state => _state;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  bool get isAuthenticated => _state == AuthState.authenticated;

  /// Get the current Firebase ID token for API calls.
  Future<String?> getIdToken({bool forceRefresh = false}) {
    return _authService.getIdToken(forceRefresh: forceRefresh);
  }

  // ── Initialize ────────────────────────────────────────────────────────
  /// Check Firebase auth state and determine initial screen.
  ///
  /// - If user is signed in and onboarding complete → authenticated
  /// - If user is signed in but onboarding not complete → onboarding
  /// - If no user → unauthenticated
  Future<void> initialize() async {
    _state = AuthState.loading;
    notifyListeners();

    // Listen to auth state changes for auto sign-out / token expiry
    _authSubscription?.cancel();
    _authSubscription = _authService.authStateChanges.listen((firebaseUser) {
      if (firebaseUser == null && _state == AuthState.authenticated) {
        // User signed out externally
        _user = null;
        _state = AuthState.unauthenticated;
        _apiService.setToken(null);
        notifyListeners();
      }
    });

    final firebaseUser = _authService.firebaseUser;
    if (firebaseUser != null) {
      // User is signed in to Firebase
      _user = _authService.currentUser;

      // Save token for API use
      final token = await _authService.getIdToken();
      if (token != null) {
        await _storageService.saveToken(token);
        _apiService.setToken(token);
      }
      await _storageService.saveUserId(firebaseUser.uid);
      await _storageService.setLoggedIn(true);

      if (!firebaseUser.emailVerified) {
        _state = AuthState.unverified;
      } else {
        try {
          final response = await _apiService.get('/profile');
          if (response.isSuccess) {
            _user = UserModel.fromJson(response.data);
            if (_user?.fishingType != null && _user?.location != null) {
              await _storageService.setOnboardingComplete(true);
              _state = AuthState.authenticated;
            } else {
              await _storageService.setOnboardingComplete(false);
              _state = AuthState.onboarding;
            }
          } else {
            final onboardingDone = await _storageService.isOnboardingComplete();
            _state = onboardingDone ? AuthState.authenticated : AuthState.onboarding;
          }
        } catch (_) {
          final onboardingDone = await _storageService.isOnboardingComplete();
          _state = onboardingDone ? AuthState.authenticated : AuthState.onboarding;
        }
      }
    } else {
      _state = AuthState.unauthenticated;
    }
    notifyListeners();
  }

  // ── Google Sign-In ────────────────────────────────────────────────────
  /// Sign in with Google. Returns true on success.
  Future<bool> signInWithGoogle() async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.signInWithGoogle();
    return _handleAuthResult(result);
  }

  // ── Email/Password Sign-In ────────────────────────────────────────────
  /// Sign in with email and password. Returns true on success.
  Future<bool> signInWithEmail(String email, String password) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.signInWithEmail(email, password);
    return _handleAuthResult(result);
  }

  // ── Email/Password Register ───────────────────────────────────────────
  /// Register a new account with email and password. Returns true on success.
  Future<bool> registerWithEmail(
    String name,
    String email,
    String password,
  ) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    final result =
        await _authService.registerWithEmail(name, email, password);
    return _handleAuthResult(result);
  }

  /// Shared handler for auth results (Google, email sign-in, register).
  Future<bool> _handleAuthResult(AuthResult result) async {
    if (result.isSuccess) {
      _user = result.user;

      if (result.token != null) {
        await _storageService.saveToken(result.token!);
        _apiService.setToken(result.token!);
      }
      if (result.user != null) {
        await _storageService.saveUserId(result.user!.id);
      }
      await _storageService.setLoggedIn(true);

      final firebaseUser = _authService.firebaseUser;
      if (firebaseUser != null && !firebaseUser.emailVerified) {
        _state = AuthState.unverified;
      } else {
        try {
          final response = await _apiService.get('/profile');
          if (response.isSuccess) {
            _user = UserModel.fromJson(response.data);
            if (_user?.fishingType != null && _user?.location != null) {
              await _storageService.setOnboardingComplete(true);
              _state = AuthState.authenticated;
            } else {
              await _storageService.setOnboardingComplete(false);
              _state = AuthState.onboarding;
            }
          } else {
            if (result.isNewUser) {
              _state = AuthState.onboarding;
            } else {
              final onboardingDone = await _storageService.isOnboardingComplete();
              _state = onboardingDone ? AuthState.authenticated : AuthState.onboarding;
            }
          }
        } catch (_) {
          if (result.isNewUser) {
            _state = AuthState.onboarding;
          } else {
            final onboardingDone = await _storageService.isOnboardingComplete();
            _state = onboardingDone ? AuthState.authenticated : AuthState.onboarding;
          }
        }
      }
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
    // Update on Firebase Auth
    await _authService.updateProfile(
      fishingType: fishingType,
      location: location,
    );

    // Sync to Laravel Backend API
    final response = await _apiService.post('/profile', body: {
      'fishing_type': fishingType,
      'location': location,
    });

    if (response.isSuccess) {
      _user = UserModel.fromJson(response.data);
    } else {
      _user = _authService.currentUser;
    }

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
    File? avatarFile,
  }) async {
    // Update on Firebase Auth
    await _authService.updateProfile(
      name: name,
      username: username,
      bio: bio,
      avatar: avatar,
    );

    // Sync to Laravel Backend API
    ApiResponse response;
    if (avatarFile != null) {
      final fields = <String, String>{};
      if (name != null) fields['name'] = name;
      if (username != null) fields['username'] = username;
      if (bio != null) fields['bio'] = bio;

      response = await _apiService.postMultipart(
        '/profile',
        fields,
        avatarFile,
        'avatar',
      );
    } else {
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (username != null) body['username'] = username;
      if (bio != null) body['bio'] = bio;
      if (avatar != null) body['avatar'] = avatar;

      response = await _apiService.post('/profile', body: body);
    }

    if (response.isSuccess) {
      _user = UserModel.fromJson(response.data);
    } else {
      _user = _authService.currentUser;
    }
    notifyListeners();
  }

  // ── Email Verification ────────────────────────────────────────────────
  /// Force-reloads user credentials and checks if email has been verified.
  Future<bool> checkEmailVerified() async {
    final firebaseUser = _authService.firebaseUser;
    if (firebaseUser != null) {
      await firebaseUser.reload();
      final updatedUser = _authService.firebaseUser;
      if (updatedUser != null && updatedUser.emailVerified) {
        final onboardingDone = await _storageService.isOnboardingComplete();
        _state = onboardingDone ? AuthState.authenticated : AuthState.onboarding;
        _user = _authService.currentUser;
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  /// Sends a new verification link to the user's email address.
  Future<void> resendVerificationEmail() async {
    final firebaseUser = _authService.firebaseUser;
    if (firebaseUser != null && !firebaseUser.emailVerified) {
      await firebaseUser.sendEmailVerification();
    }
  }

  // ── Logout ────────────────────────────────────────────────────────────
  /// Sign out from Google + Firebase, clear local storage.
  Future<void> logout() async {
    _state = AuthState.loading;
    notifyListeners();

    await _authService.signOut();
    await _storageService.clearAll();
    _apiService.setToken(null);
    _user = null;
    _state = AuthState.unauthenticated;
    notifyListeners();
  }

  // ── Clear Messages ────────────────────────────────────────────────────
  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
