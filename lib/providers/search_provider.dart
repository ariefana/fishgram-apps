import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/mock_data_service.dart';

/// Provider managing user search and friend discovery.
class SearchProvider extends ChangeNotifier {
  final MockDataService _mockDataService;

  List<UserModel> _searchResults = [];
  List<UserModel> _recommendations = [];
  bool _isLoading = false;
  String _query = '';
  String? _selectedFishingType;
  String? _errorMessage;

  SearchProvider({required MockDataService mockDataService})
      : _mockDataService = mockDataService;

  // ── Getters ───────────────────────────────────────────────────────────
  List<UserModel> get searchResults => _searchResults;
  List<UserModel> get recommendations => _recommendations;
  bool get isLoading => _isLoading;
  String get query => _query;
  String? get selectedFishingType => _selectedFishingType;
  String? get errorMessage => _errorMessage;

  // ── Load Recommendations ──────────────────────────────────────────────
  Future<void> loadRecommendations() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _recommendations = await _mockDataService.getUsers();
    } catch (e) {
      _errorMessage = 'Gagal memuat rekomendasi: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── Search Users ──────────────────────────────────────────────────────
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
      _searchResults = await _mockDataService.searchUsers(query);
    } catch (e) {
      _errorMessage = 'Gagal mencari: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── Filter by Fishing Type ────────────────────────────────────────────
  Future<void> filterByFishingType(String? type) async {
    _selectedFishingType = type;
    _isLoading = true;
    notifyListeners();

    try {
      if (type == null || type.isEmpty) {
        _recommendations = await _mockDataService.getUsers();
      } else {
        _recommendations = await _mockDataService.getUsersByFishingType(type);
      }
    } catch (e) {
      _errorMessage = 'Gagal memfilter: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── Toggle Follow ─────────────────────────────────────────────────────
  void toggleFollow(String userId) {
    _updateFollowInList(_searchResults, userId);
    _updateFollowInList(_recommendations, userId);
    notifyListeners();
  }

  void _updateFollowInList(List<UserModel> list, String userId) {
    final index = list.indexWhere((u) => u.id == userId);
    if (index == -1) return;
    final user = list[index];
    list[index] = user.copyWith(isFollowing: !user.isFollowing);
  }

  // ── Clear Search ──────────────────────────────────────────────────────
  void clearSearch() {
    _query = '';
    _searchResults = [];
    notifyListeners();
  }
}
