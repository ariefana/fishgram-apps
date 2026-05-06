import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import '../../config/theme.dart';
import '../../models/catch_model.dart';
import '../../models/comment_model.dart';
import '../../providers/feed_provider.dart';
import '../../services/mock_data_service.dart';
import '../../widgets/avatar_widget.dart';
import '../../widgets/comment_tile.dart';

/// Detail screen for a single catch post.
class CatchDetailScreen extends StatefulWidget {
  final String catchId;
  const CatchDetailScreen({super.key, required this.catchId});

  @override
  State<CatchDetailScreen> createState() => _CatchDetailScreenState();
}

class _CatchDetailScreenState extends State<CatchDetailScreen> {
  final _commentController = TextEditingController();
  List<CommentModel> _comments = [];
  bool _loadingComments = true;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  Future<void> _loadComments() async {
    final mockService = MockDataService();
    final comments = await mockService.getComments(widget.catchId);
    if (mounted) setState(() { _comments = comments; _loadingComments = false; });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FeedProvider>(
      builder: (context, fp, _) {
        CatchModel? catchItem;
        try {
          catchItem = fp.catches.firstWhere((c) => c.id == widget.catchId);
        } catch (_) {}

        if (catchItem == null) {
          return Scaffold(appBar: AppBar(), body: const Center(child: Text('Tangkapan tidak ditemukan')));
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Detail Tangkapan')),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Zoomable photo
                      GestureDetector(
                        onTap: () => _showFullPhoto(context, catchItem!.photoUrl),
                        child: AspectRatio(
                          aspectRatio: 4 / 3,
                          child: CachedNetworkImage(imageUrl: catchItem.photoUrl, fit: BoxFit.cover),
                        ),
                      ),
                      // Actions
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(catchItem.isLiked ? Icons.favorite : Icons.favorite_border, color: catchItem.isLiked ? AppTheme.likeRed : null),
                              onPressed: () => fp.toggleLike(catchItem!.id),
                            ),
                            Text('${catchItem.likesCount}', style: const TextStyle(fontWeight: FontWeight.w600)),
                            const SizedBox(width: 16),
                            const Icon(Icons.chat_bubble_outline, size: 22),
                            const SizedBox(width: 4),
                            Text('${_comments.length}', style: const TextStyle(fontWeight: FontWeight.w600)),
                            const Spacer(),
                            IconButton(icon: const Icon(Icons.share_outlined), onPressed: () {}),
                            IconButton(
                              icon: Icon(catchItem.isBookmarked ? Icons.bookmark : Icons.bookmark_border, color: catchItem.isBookmarked ? AppTheme.primaryBlue : null),
                              onPressed: () => fp.toggleBookmark(catchItem!.id),
                            ),
                          ],
                        ),
                      ),
                      // User info
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            AvatarWidget(imageUrl: catchItem.userAvatar, name: catchItem.userName, radius: 20),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(catchItem.userName, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                                if (catchItem.location != null)
                                  Text(catchItem.location!, style: Theme.of(context).textTheme.bodySmall),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Fish info
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            _chip(Icons.phishing, catchItem.fishType),
                            _chip(Icons.scale, '${catchItem.weight} kg'),
                            _chip(Icons.restaurant, catchItem.bait),
                          ],
                        ),
                      ),
                      if (catchItem.caption != null) ...[
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(catchItem.caption!, style: Theme.of(context).textTheme.bodyMedium),
                        ),
                      ],
                      const SizedBox(height: 16),
                      const Divider(),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text('Komentar', style: Theme.of(context).textTheme.titleSmall),
                      ),
                      // Comments
                      if (_loadingComments)
                        const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator(strokeWidth: 2)))
                      else if (_comments.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Center(child: Text('Belum ada komentar', style: Theme.of(context).textTheme.bodySmall)),
                        )
                      else
                        ..._comments.map((c) => CommentTile(comment: c)),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
              // Comment input
              Container(
                padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, -1))]),
                child: SafeArea(
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          decoration: InputDecoration(
                            hintText: 'Tulis komentar...',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                            filled: true,
                            fillColor: AppTheme.surfaceWhite,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.send, color: AppTheme.primaryBlue),
                        onPressed: () {
                          if (_commentController.text.trim().isEmpty) return;
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Komentar terkirim!'), backgroundColor: AppTheme.successGreen));
                          _commentController.clear();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _chip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: AppTheme.accentGreen.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppTheme.accentGreen),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.accentGreen, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  void _showFullPhoto(BuildContext context, String url) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(backgroundColor: Colors.black, foregroundColor: Colors.white),
        body: PhotoView(imageProvider: CachedNetworkImageProvider(url)),
      ),
    ));
  }
}
