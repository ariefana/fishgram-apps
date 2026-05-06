import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/comment_model.dart';
import 'avatar_widget.dart';

/// Single comment row widget.
class CommentTile extends StatelessWidget {
  final CommentModel comment;
  final VoidCallback? onUserTap;

  const CommentTile({super.key, required this.comment, this.onUserTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onUserTap,
            child: AvatarWidget(imageUrl: comment.userAvatar, name: comment.userName, radius: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: onUserTap,
                      child: Text(comment.userName, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                    ),
                    const SizedBox(width: 6),
                    Text(_timeAgo(comment.createdAt), style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11, color: AppTheme.textHint)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(comment.content, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
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
