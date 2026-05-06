import 'package:shared_preferences/shared_preferences.dart';
import '../config/constants.dart';

/// Local storage service wrapping SharedPreferences.
class StorageService {
  SharedPreferences? _prefs;

  Future<SharedPreferences> get _instance async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // ── Auth Token ──────────────────────────────────────────────────────
  Future<void> saveToken(String token) async {
    final prefs = await _instance;
    await prefs.setString(AppConstants.tokenKey, token);
  }

  Future<String?> getToken() async {
    final prefs = await _instance;
    return prefs.getString(AppConstants.tokenKey);
  }

  Future<void> removeToken() async {
    final prefs = await _instance;
    await prefs.remove(AppConstants.tokenKey);
  }

  // ── User ID ─────────────────────────────────────────────────────────
  Future<void> saveUserId(String userId) async {
    final prefs = await _instance;
    await prefs.setString(AppConstants.userIdKey, userId);
  }

  Future<String?> getUserId() async {
    final prefs = await _instance;
    return prefs.getString(AppConstants.userIdKey);
  }

  // ── Login State ─────────────────────────────────────────────────────
  Future<void> setLoggedIn(bool value) async {
    final prefs = await _instance;
    await prefs.setBool(AppConstants.isLoggedInKey, value);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await _instance;
    return prefs.getBool(AppConstants.isLoggedInKey) ?? false;
  }

  // ── Onboarding ──────────────────────────────────────────────────────
  Future<void> setOnboardingComplete(bool value) async {
    final prefs = await _instance;
    await prefs.setBool(AppConstants.onboardingKey, value);
  }

  Future<bool> isOnboardingComplete() async {
    final prefs = await _instance;
    return prefs.getBool(AppConstants.onboardingKey) ?? false;
  }

  // ── Clear All ───────────────────────────────────────────────────────
  Future<void> clearAll() async {
    final prefs = await _instance;
    await prefs.clear();
  }
}
