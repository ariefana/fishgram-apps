import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../providers/feed_provider.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/catch_card.dart';
import '../../widgets/shimmer_loading.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_state.dart';
import '../catch_detail/catch_detail_screen.dart';
import '../other_profile/other_profile_screen.dart';

/// Home feed screen showing fishing catch posts.
class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FeedProvider>().loadFeed();
      context.read<NotificationProvider>().loadNotifications();
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<FeedProvider>().loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Consumer<FeedProvider>(
        builder: (context, feedProvider, _) {
          if (feedProvider.isLoading) {
            return ShimmerLoading.feedList();
          }
          if (feedProvider.errorMessage != null) {
            return ErrorState(message: feedProvider.errorMessage!, onRetry: feedProvider.loadFeed);
          }
          if (feedProvider.catches.isEmpty) {
            return const EmptyState(icon: Icons.phishing, title: 'Belum ada tangkapan', subtitle: 'Jadilah yang pertama membagikan tangkapanmu!');
          }
          return RefreshIndicator(
            onRefresh: feedProvider.refreshFeed,
            color: AppTheme.primaryBlue,
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.only(top: 8, bottom: 100),
              itemCount: feedProvider.catches.length + (feedProvider.isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == feedProvider.catches.length) {
                  return const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
                }
                final catchItem = feedProvider.catches[index];
                return CatchCard(
                  catchItem: catchItem,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CatchDetailScreen(catchId: catchItem.id))),
                  onLike: () => feedProvider.toggleLike(catchItem.id),
                  onComment: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CatchDetailScreen(catchId: catchItem.id))),
                  onBookmark: () => feedProvider.toggleBookmark(catchItem.id),
                  onUserTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OtherProfileScreen(userId: catchItem.userId))),
                );
              },
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(gradient: AppTheme.primaryGradient, shape: BoxShape.circle),
            child: const Icon(Icons.phishing, size: 20, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Text(AppConstants.appName, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
        ],
      ),
      centerTitle: false,
      actions: [
        Consumer<NotificationProvider>(
          builder: (context, np, _) {
            final unread = np.unreadCount;
            return Stack(
              children: [
                IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
                if (unread > 0)
                  Positioned(
                    right: 8, top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: AppTheme.likeRed, shape: BoxShape.circle),
                      child: Text('$unread', style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
