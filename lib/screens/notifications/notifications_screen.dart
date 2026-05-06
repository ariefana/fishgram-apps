import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/notification_tile.dart';
import '../../widgets/shimmer_loading.dart';
import '../../widgets/empty_state.dart';

/// Notifications screen.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) {
              final np = context.read<NotificationProvider>();
              if (v == 'read') np.markAllAsRead();
              if (v == 'clear') np.clearAll();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'read', child: Text('Tandai semua dibaca')),
              PopupMenuItem(value: 'clear', child: Text('Hapus semua')),
            ],
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, np, _) {
          if (np.isLoading) return ShimmerLoading.userList(count: 6);
          if (np.notifications.isEmpty) {
            return const EmptyState(
              icon: Icons.notifications_off,
              title: 'Belum ada notifikasi',
              subtitle: 'Notifikasi akan muncul di sini',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.only(bottom: 100),
            itemCount: np.notifications.length,
            separatorBuilder: (_, _) => const Divider(),
            itemBuilder: (context, index) {
              final notif = np.notifications[index];
              return NotificationTile(
                notification: notif,
                onTap: () => np.markAsRead(notif.id),
              );
            },
          );
        },
      ),
    );
  }
}
