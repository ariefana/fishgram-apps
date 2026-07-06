import '../config/constants.dart';

/// Notification types in FishGram.
enum NotificationType { like, comment, follow, friendRequest }

/// Model representing a notification.
class NotificationModel {
  final String id;
  final NotificationType type;
  final String actorId;
  final String actorName;
  final String actorUsername;
  final String? actorAvatar;
  final String? referenceId; // catch ID for like/comment
  final String? referenceImage; // thumbnail of the catch
  final String message;
  final bool isRead;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.type,
    required this.actorId,
    required this.actorName,
    required this.actorUsername,
    this.actorAvatar,
    this.referenceId,
    this.referenceImage,
    required this.message,
    this.isRead = false,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'].toString(),
      type: _parseType(json['type'] as String),
      actorId: json['actor_id'].toString(),
      actorName: json['actor_name'] as String,
      actorUsername: json['actor_username'] as String? ?? '',
      actorAvatar: AppConstants.processUrl(json['actor_avatar'] as String?),
      referenceId: json['reference_id']?.toString(),
      referenceImage: AppConstants.processUrl(json['reference_image'] as String?),
      message: json['message'] as String,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  static NotificationType _parseType(String type) {
    switch (type) {
      case 'like':
        return NotificationType.like;
      case 'comment':
        return NotificationType.comment;
      case 'follow':
        return NotificationType.follow;
      case 'friend_request':
        return NotificationType.friendRequest;
      default:
        return NotificationType.like;
    }
  }

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      type: type,
      actorId: actorId,
      actorName: actorName,
      actorUsername: actorUsername,
      actorAvatar: actorAvatar,
      referenceId: referenceId,
      referenceImage: referenceImage,
      message: message,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }
}
