/// App-wide constants for FishGram
class AppConstants {
  AppConstants._();

  // ── App Info ──────────────────────────────────────────────────────────
  static const String appName = 'FishGram';
  static const String appTagline = 'Pamer Tangkapanmu!';
  static const String appVersion = '1.0.0';

  // ── API ───────────────────────────────────────────────────────────────
  static const String apiBaseUrl = 'http://localhost:8000/api';

  // ── Storage Keys ──────────────────────────────────────────────────────
  static const String tokenKey = 'auth_token';
  static const String userIdKey = 'user_id';
  static const String onboardingKey = 'onboarding_complete';
  static const String isLoggedInKey = 'is_logged_in';

  // ── Fishing Types ─────────────────────────────────────────────────────
  static const List<String> fishingTypes = [
    'Laut',
    'Sungai',
    'Danau',
    'Rawa',
    'Waduk',
  ];

  // ── Fish Species (common in Indonesia) ────────────────────────────────
  static const List<String> fishSpecies = [
    'Ikan Kakap',
    'Ikan Tenggiri',
    'Ikan Tongkol',
    'Ikan Tuna',
    'Ikan Bawal',
    'Ikan Gurame',
    'Ikan Lele',
    'Ikan Nila',
    'Ikan Patin',
    'Ikan Mujair',
    'Ikan Mas',
    'Ikan Gabus',
    'Ikan Bandeng',
    'Ikan Kerapu',
    'Ikan Baronang',
    'Ikan GT (Giant Trevally)',
    'Ikan Marlin',
    'Ikan Cakalang',
    'Lainnya',
  ];

  // ── Common Baits ──────────────────────────────────────────────────────
  static const List<String> commonBaits = [
    'Cacing',
    'Udang',
    'Ikan kecil (umpan hidup)',
    'Lure / Softbait',
    'Lure / Hardbait',
    'Jig',
    'Popper',
    'Pelet',
    'Roti',
    'Jagung',
    'Lumut',
    'Lainnya',
  ];

  // ── Pagination ────────────────────────────────────────────────────────
  static const int feedPageSize = 10;
  static const int searchPageSize = 20;

  // ── Mock Delay (ms) ───────────────────────────────────────────────────
  static const int mockNetworkDelay = 800;

  // ── Placeholder Images ────────────────────────────────────────────────
  static const String defaultAvatarUrl =
      'https://ui-avatars.com/api/?background=0077B6&color=fff&size=200';

  static String avatarUrl(String name) =>
      'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&background=0077B6&color=fff&size=200';

  static String catchPhotoUrl(int index) =>
      'https://picsum.photos/seed/fish$index/800/600';
}
