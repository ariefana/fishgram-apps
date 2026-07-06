import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/api_service.dart';

/// Provider managing notifications.
class NotificationProvider extends ChangeNotifier {
  final ApiService _apiService;

  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _errorMessage;

  NotificationProvider({required ApiService apiService})
      : _apiService = apiService;

  // ── Getters ───────────────────────────────────────────────────────────
  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get unreadCount =>
      _notifications.where((n) => !n.isRead).length;

  // ── Load Notifications (Laravel API) ──────────────────────────────────
  Future<void> loadNotifications() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.get('/notifications');
      if (response.isSuccess) {
        final List<dynamic> list = response.data;
        _notifications = list.map((json) => NotificationModel.fromJson(json)).toList();
      } else {
        _errorMessage = response.errorMessage ?? 'Gagal memuat notifikasi';
      }
    } catch (e) {
      _errorMessage = 'Gagal memuat notifikasi: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── Mark as Read (Laravel API) ────────────────────────────────────────
  Future<void> markAsRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index == -1) return;
    
    final original = _notifications[index];
    if (original.isRead) return;

    // Optimistic UI Update
    _notifications[index] = _notifications[index].copyWith(isRead: true);
    notifyListeners();

    try {
      final response = await _apiService.put('/notifications/$id/read');
      if (!response.isSuccess) {
        // Revert back on failure
        _notifications[index] = original;
        _errorMessage = response.errorMessage ?? 'Gagal memperbarui notifikasi';
        notifyListeners();
      }
    } catch (e) {
      _notifications[index] = original;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // ── Mark All as Read (Laravel API) ────────────────────────────────────
  Future<void> markAllAsRead() async {
    final unreadList = _notifications.where((n) => !n.isRead).toList();
    if (unreadList.isEmpty) return;

    // Optimistic UI Update
    _notifications = _notifications
        .map((n) => n.copyWith(isRead: true))
        .toList();
    notifyListeners();

    try {
      for (final n in unreadList) {
        await _apiService.put('/notifications/${n.id}/read');
      }
    } catch (e) {
      // Load from server to sync state on exception
      await loadNotifications();
    }
  }

  // ── Clear All ─────────────────────────────────────────────────────────
  void clearAll() {
    _notifications = [];
    notifyListeners();
  }
}
