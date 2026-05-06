import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/user_model.dart';
import '../models/catch_model.dart';
import '../models/comment_model.dart';
import '../models/notification_model.dart';
import '../config/constants.dart';

/// Service for loading mock data from JSON asset files.
///
/// Simulates API responses with realistic delays.
class MockDataService {
  List<UserModel>? _cachedUsers;
  List<CatchModel>? _cachedCatches;
  List<CommentModel>? _cachedComments;
  List<NotificationModel>? _cachedNotifications;

  /// Simulate network delay.
  Future<void> _simulateDelay() async {
    await Future.delayed(
      const Duration(milliseconds: AppConstants.mockNetworkDelay),
    );
  }

  /// Load and parse users from mock JSON.
  Future<List<UserModel>> getUsers() async {
    if (_cachedUsers != null) return _cachedUsers!;
    await _simulateDelay();

    final jsonString = await rootBundle.loadString('assets/mock/users.json');
    final List<dynamic> jsonList = jsonDecode(jsonString);
    _cachedUsers = jsonList.map((e) => UserModel.fromJson(e)).toList();
    return _cachedUsers!;
  }

  /// Get a single user by ID.
  Future<UserModel?> getUserById(String id) async {
    final users = await getUsers();
    try {
      return users.firstWhere((u) => u.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Search users by name or username.
  Future<List<UserModel>> searchUsers(String query) async {
    await _simulateDelay();
    final users = await getUsers();
    if (query.isEmpty) return users;

    final lowerQuery = query.toLowerCase();
    return users
        .where((u) =>
            u.name.toLowerCase().contains(lowerQuery) ||
            u.username.toLowerCase().contains(lowerQuery))
        .toList();
  }

  /// Filter users by fishing type.
  Future<List<UserModel>> getUsersByFishingType(String fishingType) async {
    final users = await getUsers();
    return users.where((u) => u.fishingType == fishingType).toList();
  }

  /// Load and parse catches from mock JSON.
  Future<List<CatchModel>> getCatches({int page = 1, int perPage = 10}) async {
    if (_cachedCatches == null) {
      await _simulateDelay();
      final jsonString =
          await rootBundle.loadString('assets/mock/catches.json');
      final List<dynamic> jsonList = jsonDecode(jsonString);
      _cachedCatches = jsonList.map((e) => CatchModel.fromJson(e)).toList();
    }

    // Simulate pagination
    final start = (page - 1) * perPage;
    if (start >= _cachedCatches!.length) return [];
    final end = (start + perPage).clamp(0, _cachedCatches!.length);
    return _cachedCatches!.sublist(start, end);
  }

  /// Get catches by user ID.
  Future<List<CatchModel>> getCatchesByUserId(String userId) async {
    await _simulateDelay();
    final catches = await getCatches(perPage: 100);
    return catches.where((c) => c.userId == userId).toList();
  }

  /// Get a single catch by ID.
  Future<CatchModel?> getCatchById(String id) async {
    final catches = await getCatches(perPage: 100);
    try {
      return catches.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Load comments for a specific catch.
  Future<List<CommentModel>> getComments(String catchId) async {
    if (_cachedComments == null) {
      await _simulateDelay();
      final jsonString =
          await rootBundle.loadString('assets/mock/comments.json');
      final List<dynamic> jsonList = jsonDecode(jsonString);
      _cachedComments = jsonList.map((e) => CommentModel.fromJson(e)).toList();
    }
    return _cachedComments!.where((c) => c.catchId == catchId).toList();
  }

  /// Load notifications.
  Future<List<NotificationModel>> getNotifications() async {
    if (_cachedNotifications == null) {
      await _simulateDelay();
      final jsonString =
          await rootBundle.loadString('assets/mock/notifications.json');
      final List<dynamic> jsonList = jsonDecode(jsonString);
      _cachedNotifications =
          jsonList.map((e) => NotificationModel.fromJson(e)).toList();
    }
    return _cachedNotifications!;
  }

  /// Clear all caches (for refresh).
  void clearCache() {
    _cachedUsers = null;
    _cachedCatches = null;
    _cachedComments = null;
    _cachedNotifications = null;
  }
}
