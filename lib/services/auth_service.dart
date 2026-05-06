import '../models/user_model.dart';

/// Mock authentication service.
///
/// Simulates Firebase Auth behavior without requiring actual Firebase setup.
/// Replace with real Firebase Auth integration when ready.
class AuthService {
  UserModel? _currentUser;
  String? _token;

  bool get isLoggedIn => _currentUser != null;
  UserModel? get currentUser => _currentUser;
  String? get token => _token;

  /// Simulate login with email & password.
  Future<AuthResult> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 800));

    // Mock validation
    if (email.isEmpty || password.isEmpty) {
      return AuthResult.failure('Email dan password tidak boleh kosong');
    }

    if (password.length < 6) {
      return AuthResult.failure('Password minimal 6 karakter');
    }

    // Mock successful login — return a default user
    _currentUser = UserModel(
      id: '1',
      name: 'Budi Santoso',
      username: 'budi_mancing',
      email: email,
      avatar:
          'https://ui-avatars.com/api/?name=Budi+Santoso&background=0077B6&color=fff&size=200',
      bio: 'Pemancing profesional 🎣 | Spesialis ikan laut dalam | Jakarta',
      fishingType: 'Laut',
      location: 'Jakarta',
      followersCount: 1250,
      followingCount: 340,
      catchesCount: 87,
      createdAt: DateTime(2024, 1, 15),
    );
    _token = 'mock_firebase_token_${DateTime.now().millisecondsSinceEpoch}';

    return AuthResult.success(_currentUser!, _token!);
  }

  /// Simulate registration.
  Future<AuthResult> register(
    String name,
    String email,
    String password,
    String confirmPassword,
  ) async {
    await Future.delayed(const Duration(milliseconds: 1000));

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      return AuthResult.failure('Semua field harus diisi');
    }
    if (password != confirmPassword) {
      return AuthResult.failure('Password dan konfirmasi tidak cocok');
    }
    if (password.length < 6) {
      return AuthResult.failure('Password minimal 6 karakter');
    }
    if (!email.contains('@')) {
      return AuthResult.failure('Format email tidak valid');
    }

    // Create new mock user
    final username = name.toLowerCase().replaceAll(' ', '_');
    _currentUser = UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      username: username,
      email: email,
      avatar:
          'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&background=0077B6&color=fff&size=200',
      createdAt: DateTime.now(),
    );
    _token = 'mock_firebase_token_${DateTime.now().millisecondsSinceEpoch}';

    return AuthResult.success(_currentUser!, _token!);
  }

  /// Simulate forgot password.
  Future<AuthResult> forgotPassword(String email) async {
    await Future.delayed(const Duration(milliseconds: 800));

    if (email.isEmpty || !email.contains('@')) {
      return AuthResult.failure('Masukkan email yang valid');
    }

    return AuthResult.success(null, null,
        message: 'Link reset password telah dikirim ke $email');
  }

  /// Update the current user profile.
  Future<void> updateProfile({
    String? name,
    String? username,
    String? bio,
    String? avatar,
    String? fishingType,
    String? location,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(
        name: name,
        username: username,
        bio: bio,
        avatar: avatar,
        fishingType: fishingType,
        location: location,
      );
    }
  }

  /// Simulate logout.
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = null;
    _token = null;
  }
}

/// Result of an auth operation.
class AuthResult {
  final bool isSuccess;
  final UserModel? user;
  final String? token;
  final String? errorMessage;
  final String? message;

  const AuthResult._({
    required this.isSuccess,
    this.user,
    this.token,
    this.errorMessage,
    this.message,
  });

  factory AuthResult.success(UserModel? user, String? token, {String? message}) {
    return AuthResult._(
      isSuccess: true,
      user: user,
      token: token,
      message: message,
    );
  }

  factory AuthResult.failure(String error) {
    return AuthResult._(isSuccess: false, errorMessage: error);
  }
}
