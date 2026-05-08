import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

/// Authentication service using Firebase Auth + Google Sign-In.
///
/// Provides Google Sign-In, sign-out, token management, and auth state streams.
class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // ── Current State ─────────────────────────────────────────────────────
  /// The currently signed-in Firebase user, or null.
  User? get firebaseUser => _firebaseAuth.currentUser;

  /// Whether a user is currently signed in.
  bool get isLoggedIn => firebaseUser != null;

  /// Stream of auth state changes (sign-in / sign-out).
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Stream of ID token changes (token refresh, sign-in, sign-out).
  Stream<User?> get idTokenChanges => _firebaseAuth.idTokenChanges();

  /// Build a [UserModel] from the current Firebase user.
  UserModel? get currentUser {
    final user = firebaseUser;
    if (user == null) return null;
    return _userModelFromFirebase(user);
  }

  // ── Google Sign-In ────────────────────────────────────────────────────
  /// Sign in with Google and return an [AuthResult].
  ///
  /// Flow:
  /// 1. Show Google account picker
  /// 2. Get Google auth tokens
  /// 3. Create Firebase credential
  /// 4. Sign in to Firebase with credential
  /// 5. Return user data + Firebase ID token
  Future<AuthResult> signInWithGoogle() async {
    try {
      // 1. Trigger Google Sign-In flow
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User cancelled the sign-in
        return AuthResult.failure('Login dibatalkan');
      }

      // 2. Obtain auth details
      final googleAuth = await googleUser.authentication;

      // 3. Create Firebase credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Sign in to Firebase
      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user == null) {
        return AuthResult.failure('Gagal mendapatkan data pengguna');
      }

      // 5. Get Firebase ID token
      final token = await user.getIdToken();

      return AuthResult.success(
        _userModelFromFirebase(user),
        token,
        isNewUser: userCredential.additionalUserInfo?.isNewUser ?? false,
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_firebaseErrorMessage(e.code));
    } catch (e) {
      return AuthResult.failure('Terjadi kesalahan: ${e.toString()}');
    }
  }

  // ── Email/Password Sign-In ────────────────────────────────────────────
  /// Sign in with email and password via Firebase Auth.
  Future<AuthResult> signInWithEmail(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = userCredential.user;
      if (user == null) {
        return AuthResult.failure('Gagal mendapatkan data pengguna');
      }
      final token = await user.getIdToken();
      return AuthResult.success(
        _userModelFromFirebase(user),
        token,
        isNewUser: false,
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_firebaseErrorMessage(e.code));
    } catch (e) {
      return AuthResult.failure('Terjadi kesalahan: ${e.toString()}');
    }
  }

  // ── Email/Password Registration ───────────────────────────────────────
  /// Create a new account with email and password via Firebase Auth.
  Future<AuthResult> registerWithEmail(
    String name,
    String email,
    String password,
  ) async {
    try {
      final userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = userCredential.user;
      if (user == null) {
        return AuthResult.failure('Gagal membuat akun');
      }
      // Set display name
      await user.updateDisplayName(name.trim());
      await user.reload();

      final token = await _firebaseAuth.currentUser?.getIdToken();
      return AuthResult.success(
        _userModelFromFirebase(_firebaseAuth.currentUser!),
        token,
        isNewUser: true,
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_firebaseErrorMessage(e.code));
    } catch (e) {
      return AuthResult.failure('Terjadi kesalahan: ${e.toString()}');
    }
  }

  // ── Token Management ──────────────────────────────────────────────────
  /// Get the current Firebase ID token.
  ///
  /// If [forceRefresh] is true, the token is refreshed even if not expired.
  /// Returns null if no user is signed in.
  Future<String?> getIdToken({bool forceRefresh = false}) async {
    final user = firebaseUser;
    if (user == null) return null;
    return await user.getIdToken(forceRefresh);
  }

  // ── Sign Out ──────────────────────────────────────────────────────────
  /// Sign out from both Google and Firebase.
  ///
  /// Clears Google session so account picker shows on next sign-in.
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }

  // ── Update Profile ────────────────────────────────────────────────────
  /// Update display name and/or photo URL on the Firebase user.
  Future<void> updateProfile({
    String? name,
    String? username,
    String? bio,
    String? avatar,
    String? fishingType,
    String? location,
  }) async {
    final user = firebaseUser;
    if (user == null) return;

    // Firebase only supports displayName and photoURL directly
    if (name != null || avatar != null) {
      await user.updateDisplayName(name ?? user.displayName);
      if (avatar != null) {
        await user.updatePhotoURL(avatar);
      }
      // Reload to pick up changes
      await user.reload();
    }
    // Other fields (username, bio, fishingType, location) would be
    // saved to the Laravel backend in the future.
  }

  // ── Forgot Password ──────────────────────────────────────────────────
  /// Send a password reset email via Firebase (for email/password accounts).
  Future<AuthResult> forgotPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return AuthResult.success(null, null,
          message: 'Link reset password telah dikirim ke $email');
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_firebaseErrorMessage(e.code));
    } catch (e) {
      return AuthResult.failure('Terjadi kesalahan: ${e.toString()}');
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────
  /// Convert a Firebase [User] to a [UserModel].
  UserModel _userModelFromFirebase(User user) {
    return UserModel(
      id: user.uid,
      name: user.displayName ?? 'Pemancing',
      username: _generateUsername(user.displayName ?? user.email ?? 'user'),
      email: user.email ?? '',
      avatar: user.photoURL,
      createdAt: user.metadata.creationTime ?? DateTime.now(),
    );
  }

  /// Generate a username from name/email.
  String _generateUsername(String input) {
    return input
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
  }

  /// Map Firebase error codes to user-friendly Indonesian messages.
  String _firebaseErrorMessage(String code) {
    switch (code) {
      case 'account-exists-with-different-credential':
        return 'Akun sudah ada dengan metode login lain';
      case 'invalid-credential':
        return 'Kredensial tidak valid';
      case 'operation-not-allowed':
        return 'Metode login ini belum diaktifkan';
      case 'user-disabled':
        return 'Akun ini telah dinonaktifkan';
      case 'user-not-found':
        return 'Pengguna tidak ditemukan';
      case 'wrong-password':
        return 'Password salah';
      case 'invalid-email':
        return 'Format email tidak valid';
      case 'email-already-in-use':
        return 'Email sudah digunakan akun lain';
      case 'weak-password':
        return 'Password terlalu lemah, minimal 6 karakter';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan, coba lagi nanti';
      case 'network-request-failed':
        return 'Koneksi jaringan bermasalah';
      default:
        return 'Terjadi kesalahan ($code)';
    }
  }
}

/// Result of an auth operation.
class AuthResult {
  final bool isSuccess;
  final UserModel? user;
  final String? token;
  final String? errorMessage;
  final String? message;
  final bool isNewUser;

  const AuthResult._({
    required this.isSuccess,
    this.user,
    this.token,
    this.errorMessage,
    this.message,
    this.isNewUser = false,
  });

  factory AuthResult.success(
    UserModel? user,
    String? token, {
    String? message,
    bool isNewUser = false,
  }) {
    return AuthResult._(
      isSuccess: true,
      user: user,
      token: token,
      message: message,
      isNewUser: isNewUser,
    );
  }

  factory AuthResult.failure(String error) {
    return AuthResult._(isSuccess: false, errorMessage: error);
  }
}
