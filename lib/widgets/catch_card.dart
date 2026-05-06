import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../config/theme.dart';
import '../models/catch_model.dart';
import 'avatar_widget.dart';

/// Card widget displaying a fishing catch post in the feed.
class CatchCard extends StatelessWidget {
  final CatchModel catchItem;
  final VoidCallback? onTap;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onBookmark;
  final VoidCallback? onUserTap;

  const CatchCard({
    super.key,
    required this.catchItem,
    this.onTap,
    this.onLike,
    this.onComment,
    this.onBookmark,
    this.onUserTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            _buildImage(),
            _buildActions(context),
            _buildInfo(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: onUserTap,
            child: AvatarWidget(
              imageUrl: catchItem.userAvatar,
              name: catchItem.userName,
              radius: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: onUserTap,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    catchItem.userName,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                  ),
                  if (catchItem.location != null)
                    Text(
                      catchItem.location!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 11,
                            color: AppTheme.textHint,
                          ),
                    ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _timeAgo(catchItem.createdAt),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                    color: AppTheme.primaryBlue,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AspectRatio(
          aspectRatio: 4 / 3,
          child: CachedNetworkImage(
            imageUrl: catchItem.photoUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: Colors.grey.shade200,
              child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            errorWidget: (context, url, error) => Container(
              color: Colors.grey.shade200,
              child: const Icon(Icons.broken_image, size: 48, color: Colors.grey),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Row(
        children: [
          _actionBtn(
            catchItem.isLiked ? Icons.favorite : Icons.favorite_border,
            catchItem.isLiked ? AppTheme.likeRed : AppTheme.textSecondary,
            catchItem.likesCount > 0 ? catchItem.likesCount.toString() : null,
            onLike,
          ),
          const SizedBox(width: 4),
          _actionBtn(
            Icons.chat_bubble_outline,
            AppTheme.textSecondary,
            catchItem.commentsCount > 0 ? catchItem.commentsCount.toString() : null,
            onComment,
          ),
          const Spacer(),
          _actionBtn(
            catchItem.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
            catchItem.isBookmarked ? AppTheme.primaryBlue : AppTheme.textSecondary,
            null,
            onBookmark,
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(IconData icon, Color color, String? label, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: color),
            if (label != null) ...[
              const SizedBox(width: 4),
              Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: color)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              _infoChip(Icons.phishing, catchItem.fishType),
              _infoChip(Icons.scale, '${catchItem.weight} kg'),
              _infoChip(Icons.restaurant, catchItem.bait),
            ],
          ),
          if (catchItem.caption != null && catchItem.caption!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(catchItem.caption!, style: Theme.of(context).textTheme.bodyMedium, maxLines: 3, overflow: TextOverflow.ellipsis),
          ],
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.accentGreen.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.accentGreen),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppTheme.accentGreen)),
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
    if (diff.inDays < 30) return '${diff.inDays ~/ 7}mg';
    return '${diff.inDays ~/ 30}bln';
  }
}
