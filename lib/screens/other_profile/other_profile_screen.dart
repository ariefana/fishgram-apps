import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/theme.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/avatar_widget.dart';
import '../../widgets/shimmer_loading.dart';
import '../../widgets/error_state.dart';

/// View another user's profile.
class OtherProfileScreen extends StatefulWidget {
  final String userId;
  const OtherProfileScreen({super.key, required this.userId});

  @override
  State<OtherProfileScreen> createState() => _OtherProfileScreenState();
}

class _OtherProfileScreenState extends State<OtherProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().loadUserProfile(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: Consumer<ProfileProvider>(
        builder: (context, pp, _) {
          if (pp.isLoading) {
            return ShimmerLoading.userList(count: 4);
          }
          if (pp.errorMessage != null) {
            return ErrorState(message: pp.errorMessage!, onRetry: () => pp.loadUserProfile(widget.userId));
          }
          final user = pp.viewedUser;
          if (user == null) {
            return const Center(child: Text('Pengguna tidak ditemukan'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              children: [
                const SizedBox(height: 20),
                AvatarWidget(imageUrl: user.avatar, name: user.name, radius: 50),
                const SizedBox(height: 14),
                Text(user.name, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 4),
                Text('@${user.username}', style: Theme.of(context).textTheme.bodySmall),
                if (user.bio != null && user.bio!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(user.bio!, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
                  ),
                ],
                const SizedBox(height: 20),
                // Stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _statCol(context, user.catchesCount.toString(), 'Tangkapan'),
                    _statCol(context, user.followersCount.toString(), 'Pengikut'),
                    _statCol(context, user.followingCount.toString(), 'Mengikuti'),
                  ],
                ),
                const SizedBox(height: 20),
                // Follow / Message buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: user.isFollowing
                            ? OutlinedButton(onPressed: () => pp.toggleFollow(), child: const Text('Mengikuti'))
                            : ElevatedButton(onPressed: () => pp.toggleFollow(), child: const Text('Ikuti')),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.phishing, size: 18),
                          label: const Text('Ajak Mancing'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Divider(),
                // Catches grid
                if (pp.userCatches.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(children: [
                      Icon(Icons.phishing, size: 48, color: AppTheme.textHint),
                      const SizedBox(height: 12),
                      Text('Belum ada tangkapan', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary)),
                    ]),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(2),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 2, mainAxisSpacing: 2),
                    itemCount: pp.userCatches.length,
                    itemBuilder: (context, index) {
                      return CachedNetworkImage(imageUrl: pp.userCatches[index].photoUrl, fit: BoxFit.cover);
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _statCol(BuildContext context, String count, String label) {
    return Column(
      children: [
        Text(count, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
