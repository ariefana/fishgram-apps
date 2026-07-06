import 'dart:io';
import 'package:flutter/material.dart';
import '../models/catch_model.dart';
import '../models/comment_model.dart';
import '../services/api_service.dart';

/// Provider managing the feed of fishing catch posts.
class FeedProvider extends ChangeNotifier {
  final ApiService _apiService;

  List<CatchModel> _catches = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _currentPage = 1;
  String? _errorMessage;

  FeedProvider({required ApiService apiService})
      : _apiService = apiService;

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
      final response = await _apiService.get('/feed', queryParams: {
        'page': '1',
        'perPage': '10',
      });
      
      if (response.isSuccess) {
        final List<dynamic> list = response.data;
        _catches = list.map((json) => CatchModel.fromJson(json)).toList();
        _hasMore = _catches.length >= 10;
      } else {
        _errorMessage = response.errorMessage ?? 'Gagal memuat feed';
      }
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
      final response = await _apiService.get('/feed', queryParams: {
        'page': _currentPage.toString(),
        'perPage': '10',
      });

      if (response.isSuccess) {
        final List<dynamic> list = response.data;
        final moreCatches = list.map((json) => CatchModel.fromJson(json)).toList();
        if (moreCatches.isEmpty) {
          _hasMore = false;
        } else {
          _catches.addAll(moreCatches);
        }
      } else {
        _currentPage--;
        _errorMessage = response.errorMessage ?? 'Gagal memuat lebih banyak';
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
    await loadFeed();
  }

  // ── Toggle Like (Laravel API) ─────────────────────────────────────────
  Future<void> toggleLike(String catchId) async {
    final index = _catches.indexWhere((c) => c.id == catchId);
    if (index == -1) return;

    final item = _catches[index];
    
    // Optimistic UI Update
    _catches[index] = item.copyWith(
      isLiked: !item.isLiked,
      likesCount: item.isLiked ? item.likesCount - 1 : item.likesCount + 1,
    );
    notifyListeners();

    final response = await _apiService.post('/catches/$catchId/like');
    if (response.isSuccess) {
      final data = response.data;
      _catches[index] = _catches[index].copyWith(
        isLiked: data['is_liked'] as bool,
        likesCount: data['likes_count'] as int,
      );
      notifyListeners();
    } else {
      // Revert back on failure
      _catches[index] = item;
      notifyListeners();
    }
  }

  // ── Toggle Bookmark (Laravel API) ─────────────────────────────────────
  Future<void> toggleBookmark(String catchId) async {
    final index = _catches.indexWhere((c) => c.id == catchId);
    if (index == -1) return;

    final item = _catches[index];
    
    // Optimistic UI Update
    _catches[index] = item.copyWith(isBookmarked: !item.isBookmarked);
    notifyListeners();

    final response = await _apiService.post('/catches/$catchId/bookmark');
    if (response.isSuccess) {
      final data = response.data;
      _catches[index] = _catches[index].copyWith(
        isBookmarked: data['is_bookmarked'] as bool,
      );
      notifyListeners();
    } else {
      // Revert back on failure
      _catches[index] = item;
      notifyListeners();
    }
  }

  // ── Create Catch Post (Laravel Multipart upload) ──────────────────────
  Future<bool> createCatch({
    required String fishType,
    required double weight,
    required String bait,
    required String caption,
    required File photo,
    String? spotId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final fields = <String, String>{
      'fish_type': fishType,
      'weight': weight.toString(),
      'bait': bait,
      'caption': caption,
    };
    if (spotId != null) {
      fields['spot_id'] = spotId;
    }

    final response = await _apiService.postMultipart(
      '/catches',
      fields,
      photo,
      'photo',
    );

    _isLoading = false;
    if (response.isSuccess) {
      final newCatch = CatchModel.fromJson(response.data);
      addCatch(newCatch);
      return true;
    } else {
      _errorMessage = response.errorMessage ?? 'Gagal memposting tangkapan';
      notifyListeners();
      return false;
    }
  }

  // ── Add a New Catch ───────────────────────────────────────────────────
  void addCatch(CatchModel newCatch) {
    _catches.insert(0, newCatch);
    notifyListeners();
  }

  // ── Comments (Laravel API) ───────────────────────────────────────────
  Future<List<CommentModel>> fetchComments(String catchId) async {
    try {
      final response = await _apiService.get('/catches/$catchId/comments');
      if (response.isSuccess) {
        final List<dynamic> list = response.data;
        return list.map((json) => CommentModel.fromJson(json)).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<CommentModel?> postComment(String catchId, String content) async {
    try {
      final response = await _apiService.post('/catches/$catchId/comments', body: {
        'content': content,
      });
      if (response.isSuccess) {
        final newComment = CommentModel.fromJson(response.data);
        
        // Update local comments count for this catch
        final index = _catches.indexWhere((c) => c.id == catchId);
        if (index != -1) {
          _catches[index] = _catches[index].copyWith(
            commentsCount: _catches[index].commentsCount + 1,
          );
          notifyListeners();
        }
        return newComment;
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
