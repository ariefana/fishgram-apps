import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/mock_data_service.dart';

/// Provider managing notifications.
class NotificationProvider extends ChangeNotifier {
  final MockDataService _mockDataService;

  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _errorMessage;

  NotificationProvider({required MockDataService mockDataService})
      : _mockDataService = mockDataService;

  // ── Getters ───────────────────────────────────────────────────────────
  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get unreadCount =>
      _notifications.where((n) => !n.isRead).length;

  // ── Load Notifications ────────────────────────────────────────────────
  Future<void> loadNotifications() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _notifications = await _mockDataService.getNotifications();
    } catch (e) {
      _errorMessage = 'Gagal memuat notifikasi: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── Mark as Read ──────────────────────────────────────────────────────
  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index == -1) return;
    _notifications[index] = _notifications[index].copyWith(isRead: true);
    notifyListeners();
  }

  // ── Mark All as Read ──────────────────────────────────────────────────
  void markAllAsRead() {
    _notifications = _notifications
        .map((n) => n.copyWith(isRead: true))
        .toList();
    notifyListeners();
  }

  // ── Clear All ─────────────────────────────────────────────────────────
  void clearAll() {
    _notifications = [];
    notifyListeners();
  }
}
