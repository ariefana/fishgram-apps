import 'package:flutter/material.dart';
import '../models/catch_model.dart';
import '../services/mock_data_service.dart';

/// Provider managing the feed of fishing catch posts.
class FeedProvider extends ChangeNotifier {
  final MockDataService _mockDataService;

  List<CatchModel> _catches = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _currentPage = 1;
  String? _errorMessage;

  FeedProvider({required MockDataService mockDataService})
      : _mockDataService = mockDataService;

  // ── Getters ───────────────────────────────────────────────────────────
  List<CatchModel> get catches => _catches;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  String? get errorMessage => _errorMessage;

  // ── Load Initial Feed ─────────────────────────────────────────────────
  Future<void> loadFeed() async {
    _isLoading = true;
    _errorMessage = null;
    _currentPage = 1;
    notifyListeners();

    try {
      _catches = await _mockDataService.getCatches(page: 1);
      _hasMore = _catches.length >= 10;
    } catch (e) {
      _errorMessage = 'Gagal memuat feed: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── Load More (Pagination) ────────────────────────────────────────────
  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      _currentPage++;
      final moreCatches =
          await _mockDataService.getCatches(page: _currentPage);
      if (moreCatches.isEmpty) {
        _hasMore = false;
      } else {
        _catches.addAll(moreCatches);
      }
    } catch (e) {
      _currentPage--;
      _errorMessage = 'Gagal memuat lebih banyak: ${e.toString()}';
    }

    _isLoadingMore = false;
    notifyListeners();
  }

  // ── Refresh Feed ──────────────────────────────────────────────────────
  Future<void> refreshFeed() async {
    _mockDataService.clearCache();
    await loadFeed();
  }

  // ── Toggle Like ───────────────────────────────────────────────────────
  void toggleLike(String catchId) {
    final index = _catches.indexWhere((c) => c.id == catchId);
    if (index == -1) return;

    final item = _catches[index];
    _catches[index] = item.copyWith(
      isLiked: !item.isLiked,
      likesCount: item.isLiked ? item.likesCount - 1 : item.likesCount + 1,
    );
    notifyListeners();
  }

  // ── Toggle Bookmark ───────────────────────────────────────────────────
  void toggleBookmark(String catchId) {
    final index = _catches.indexWhere((c) => c.id == catchId);
    if (index == -1) return;

    final item = _catches[index];
    _catches[index] = item.copyWith(isBookmarked: !item.isBookmarked);
    notifyListeners();
  }

  // ── Add a New Catch (after creating post) ─────────────────────────────
  void addCatch(CatchModel newCatch) {
    _catches.insert(0, newCatch);
    notifyListeners();
  }
}
