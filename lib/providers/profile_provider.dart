import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/catch_model.dart';
import '../services/mock_data_service.dart';

/// Provider managing user profile data and user catches.
class ProfileProvider extends ChangeNotifier {
  final MockDataService _mockDataService;

  UserModel? _viewedUser;
  List<CatchModel> _userCatches = [];
  bool _isLoading = false;
  String? _errorMessage;

  ProfileProvider({required MockDataService mockDataService})
      : _mockDataService = mockDataService;

  // ── Getters ───────────────────────────────────────────────────────────
  UserModel? get viewedUser => _viewedUser;
  List<CatchModel> get userCatches => _userCatches;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ── Load User Profile ─────────────────────────────────────────────────
  Future<void> loadUserProfile(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _viewedUser = await _mockDataService.getUserById(userId);
      _userCatches = await _mockDataService.getCatchesByUserId(userId);
    } catch (e) {
      _errorMessage = 'Gagal memuat profil: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── Toggle Follow ─────────────────────────────────────────────────────
  void toggleFollow() {
    if (_viewedUser == null) return;
    _viewedUser = _viewedUser!.copyWith(
      isFollowing: !_viewedUser!.isFollowing,
      followersCount: _viewedUser!.isFollowing
          ? _viewedUser!.followersCount - 1
          : _viewedUser!.followersCount + 1,
    );
    notifyListeners();
  }

  // ── Clear ─────────────────────────────────────────────────────────────
  void clear() {
    _viewedUser = null;
    _userCatches = [];
    _errorMessage = null;
    notifyListeners();
  }
}
