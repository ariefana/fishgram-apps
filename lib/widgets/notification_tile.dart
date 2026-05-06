import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../config/theme.dart';
import '../models/notification_model.dart';
import 'avatar_widget.dart';

/// Single notification row widget.
class NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;

  const NotificationTile({super.key, required this.notification, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: notification.isRead ? null : AppTheme.primaryBlue.withValues(alpha: 0.04),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Stack(
              children: [
                AvatarWidget(imageUrl: notification.actorAvatar, name: notification.actorName, radius: 24),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: Icon(_typeIcon, size: 14, color: _typeColor),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.bodyMedium,
                  children: [
                    TextSpan(text: notification.actorName, style: const TextStyle(fontWeight: FontWeight.w600)),
                    TextSpan(text: ' ${notification.message}'),
                    TextSpan(text: ' · ${_timeAgo(notification.createdAt)}', style: TextStyle(color: AppTheme.textHint, fontSize: 12)),
                  ],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (notification.referenceImage != null) ...[
              const SizedBox(width: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(imageUrl: notification.referenceImage!, width: 48, height: 48, fit: BoxFit.cover),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData get _typeIcon {
    switch (notification.type) {
      case NotificationType.like: return Icons.favorite;
      case NotificationType.comment: return Icons.chat_bubble;
      case NotificationType.follow: return Icons.person_add;
      case NotificationType.friendRequest: return Icons.group_add;
    }
  }

  Color get _typeColor {
    switch (notification.type) {
      case NotificationType.like: return AppTheme.likeRed;
      case NotificationType.comment: return AppTheme.primaryBlue;
      case NotificationType.follow: return AppTheme.accentGreen;
      case NotificationType.friendRequest: return AppTheme.warningOrange;
    }
  }

  String _timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}j';
    if (diff.inDays < 7) return '${diff.inDays}h';
    return '${diff.inDays ~/ 7}mg';
  }
}
