import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

/// Provider managing user search and friend discovery.
class SearchProvider extends ChangeNotifier {
  final ApiService _apiService;

  List<UserModel> _searchResults = [];
  List<UserModel> _recommendations = [];
  bool _isLoading = false;
  String _query = '';
  String? _selectedFishingType;
  String? _errorMessage;

  SearchProvider({required ApiService apiService})
      : _apiService = apiService;

  // ── Getters ───────────────────────────────────────────────────────────
  List<UserModel> get searchResults => _searchResults;
  List<UserModel> get recommendations => _recommendations;
  bool get isLoading => _isLoading;
  String get query => _query;
  String? get selectedFishingType => _selectedFishingType;
  String? get errorMessage => _errorMessage;

  // ── Load Recommendations (Laravel API) ────────────────────────────────
  Future<void> loadRecommendations() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.get('/users');
      if (response.isSuccess) {
        final List<dynamic> list = response.data;
        _recommendations = list.map((json) => UserModel.fromJson(json)).toList();
      } else {
        _errorMessage = response.errorMessage ?? 'Gagal memuat rekomendasi';
      }
    } catch (e) {
      _errorMessage = 'Gagal memuat rekomendasi: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── Search Users (Laravel API) ────────────────────────────────────────
  Future<void> searchUsers(String query) async {
    _query = query;
    if (query.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.get('/users', queryParams: {
        'search': query,
      });

      if (response.isSuccess) {
        final List<dynamic> list = response.data;
        _searchResults = list.map((json) => UserModel.fromJson(json)).toList();
      } else {
        _errorMessage = response.errorMessage ?? 'Gagal mencari pengguna';
      }
    } catch (e) {
      _errorMessage = 'Gagal mencari: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── Filter by Fishing Type (Laravel API) ──────────────────────────────
  Future<void> filterByFishingType(String? type) async {
    _selectedFishingType = type;
    _isLoading = true;
    notifyListeners();

    try {
      final queryParams = <String, String>{};
      if (type != null && type.isNotEmpty) {
        queryParams['fishing_type'] = type;
      }

      final response = await _apiService.get('/users', queryParams: queryParams);
      if (response.isSuccess) {
        final List<dynamic> list = response.data;
        _recommendations = list.map((json) => UserModel.fromJson(json)).toList();
      } else {
        _errorMessage = response.errorMessage ?? 'Gagal memfilter rekomendasi';
      }
    } catch (e) {
      _errorMessage = 'Gagal memfilter: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── Toggle Follow (Laravel API) ───────────────────────────────────────
  Future<void> toggleFollow(String userId) async {
    // Optimistic UI Update
    _updateFollowInList(_searchResults, userId);
    _updateFollowInList(_recommendations, userId);
    notifyListeners();

    try {
      final response = await _apiService.post('/friends/toggle', body: {
        'user_id': userId,
      });

      if (response.isSuccess) {
        final data = response.data;
        final isFollowing = data['is_following'] as bool;
        _setFollowInList(_searchResults, userId, isFollowing);
        _setFollowInList(_recommendations, userId, isFollowing);
        notifyListeners();
      } else {
        // Revert on failure
        _updateFollowInList(_searchResults, userId);
        _updateFollowInList(_recommendations, userId);
        _errorMessage = response.errorMessage ?? 'Gagal memperbarui pertemanan';
        notifyListeners();
      }
    } catch (e) {
      // Revert on failure
      _updateFollowInList(_searchResults, userId);
      _updateFollowInList(_recommendations, userId);
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void _updateFollowInList(List<UserModel> list, String userId) {
    final index = list.indexWhere((u) => u.id == userId);
    if (index == -1) return;
    final user = list[index];
    list[index] = user.copyWith(
      isFollowing: !user.isFollowing,
      followersCount: user.isFollowing ? user.followersCount - 1 : user.followersCount + 1,
    );
  }

  void _setFollowInList(List<UserModel> list, String userId, bool isFollowing) {
    final index = list.indexWhere((u) => u.id == userId);
    if (index == -1) return;
    final user = list[index];
    // Update count based on actual response if different
    if (user.isFollowing != isFollowing) {
      list[index] = user.copyWith(
        isFollowing: isFollowing,
        followersCount: isFollowing ? user.followersCount + 1 : user.followersCount - 1,
      );
    }
  }

  // ── Clear Search ──────────────────────────────────────────────────────
  void clearSearch() {
    _query = '';
    _searchResults = [];
    notifyListeners();
  }
}
