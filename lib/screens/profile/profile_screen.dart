import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/feed_provider.dart';
import '../../widgets/avatar_widget.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';

/// Current user's profile screen.
///
/// Displays data from the Google account (displayName, email, photoURL)
/// via the AuthProvider's UserModel which is built from Firebase User.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          final user = auth.user;
          if (user == null) {
            return const Center(child: Text('Tidak ada data pengguna'));
          }

          final catches = context
              .watch<FeedProvider>()
              .catches
              .where((c) => c.userId == user.id)
              .toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // ── Avatar from Google photoURL ──────────────────────
                AvatarWidget(
                  imageUrl: user.avatar,
                  name: user.name,
                  radius: 50,
                ),
                const SizedBox(height: 14),

                // ── Display Name from Google ─────────────────────────
                Text(
                  user.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 4),

                // ── Username ─────────────────────────────────────────
                Text(
                  '@${user.username}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 4),

                // ── Email from Google ────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.email_outlined,
                      size: 14,
                      color: AppTheme.textHint,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      user.email,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textHint,
                          ),
                    ),
                  ],
                ),

                if (user.bio != null && user.bio!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      user.bio!,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],

                // ── Fishing type & location badges ───────────────────
                if (user.fishingType != null || user.location != null) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      if (user.fishingType != null)
                        Chip(
                          avatar: const Icon(Icons.phishing, size: 16),
                          label: Text(user.fishingType!, style: TextStyle(color: Colors.black),),
                          visualDensity: VisualDensity.compact,
                        ),
                      if (user.location != null)
                        Chip(
                          avatar: const Icon(Icons.location_on, size: 16),
                          label: Text(user.location!, style: TextStyle(color: Colors.black)),
                          visualDensity: VisualDensity.compact,
                        ),
                    ],
                  ),
                ],

                const SizedBox(height: 20),

                // ── Stats ────────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _statCol(
                        context, user.catchesCount.toString(), 'Tangkapan'),
                    _statCol(
                        context, user.followersCount.toString(), 'Pengikut'),
                    _statCol(
                        context, user.followingCount.toString(), 'Mengikuti'),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Edit Profile button ──────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const EditProfileScreen()),
                    ),
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Edit Profil'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 44),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Divider(),

                // ── Catches grid ─────────────────────────────────────
                if (catches.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Icon(Icons.phishing,
                            size: 48, color: AppTheme.textHint),
                        const SizedBox(height: 12),
                        Text(
                          'Belum ada tangkapan',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(2),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 2,
                      mainAxisSpacing: 2,
                    ),
                    itemCount: catches.length,
                    itemBuilder: (context, index) {
                      return CachedNetworkImage(
                        imageUrl: catches[index].photoUrl,
                        fit: BoxFit.cover,
                      );
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
        Text(
          count,
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
