import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/catch_model.dart';
import '../services/api_service.dart';

/// Provider managing user profile data and user catches.
class ProfileProvider extends ChangeNotifier {
  final ApiService _apiService;

  UserModel? _viewedUser;
  List<CatchModel> _userCatches = [];
  bool _isLoading = false;
  String? _errorMessage;

  ProfileProvider({required ApiService apiService})
      : _apiService = apiService;

  // ── Getters ───────────────────────────────────────────────────────────
  UserModel? get viewedUser => _viewedUser;
  List<CatchModel> get userCatches => _userCatches;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ── Load User Profile (Laravel API) ───────────────────────────────────
  Future<void> loadUserProfile(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Fetch user profile details
      final profileResponse = await _apiService.get('/profile/$userId');
      
      if (profileResponse.isSuccess) {
        _viewedUser = UserModel.fromJson(profileResponse.data);

        // 2. Fetch catches uploaded by this user
        final catchesResponse = await _apiService.get('/feed', queryParams: {
          'user_id': userId,
        });

        if (catchesResponse.isSuccess) {
          final List<dynamic> list = catchesResponse.data;
          _userCatches = list.map((json) => CatchModel.fromJson(json)).toList();
        } else {
          _errorMessage = catchesResponse.errorMessage ?? 'Gagal memuat catches user';
        }
      } else {
        _errorMessage = profileResponse.errorMessage ?? 'Gagal memuat profil';
      }
    } catch (e) {
      _errorMessage = 'Gagal memuat profil: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── Toggle Follow (Laravel API) ───────────────────────────────────────
  Future<void> toggleFollow() async {
    if (_viewedUser == null) return;
    
    final targetUserId = _viewedUser!.id;
    final originalUser = _viewedUser;

    // Optimistic UI Update
    _viewedUser = _viewedUser!.copyWith(
      isFollowing: !_viewedUser!.isFollowing,
      followersCount: _viewedUser!.isFollowing
          ? _viewedUser!.followersCount - 1
          : _viewedUser!.followersCount + 1,
    );
    notifyListeners();

    try {
      final response = await _apiService.post('/friends/toggle', body: {
        'user_id': targetUserId,
      });

      if (response.isSuccess) {
        final data = response.data;
        _viewedUser = _viewedUser!.copyWith(
          isFollowing: data['is_following'] as bool,
          followersCount: data['followers_count'] as int,
        );
        notifyListeners();
      } else {
        // Revert on API failure
        _viewedUser = originalUser;
        _errorMessage = response.errorMessage ?? 'Gagal memperbarui pertemanan';
        notifyListeners();
      }
    } catch (e) {
      _viewedUser = originalUser;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // ── Clear ─────────────────────────────────────────────────────────────
  void clear() {
    _viewedUser = null;
    _userCatches = [];
    _errorMessage = null;
    notifyListeners();
  }
}
