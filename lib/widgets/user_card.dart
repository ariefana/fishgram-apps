import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/user_model.dart';
import 'avatar_widget.dart';

/// Mini user profile card for search results.
class UserCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback? onTap;
  final VoidCallback? onFollow;

  const UserCard({super.key, required this.user, this.onTap, this.onFollow});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            AvatarWidget(imageUrl: user.avatar, name: user.name, radius: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.name, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                  const SizedBox(height: 2),
                  Text('@${user.username}', style: Theme.of(context).textTheme.bodySmall),
                  if (user.fishingType != null) ...[
                    const SizedBox(height: 4),
                    Row(children: [
                      Icon(Icons.phishing, size: 12, color: AppTheme.primaryBlue),
                      const SizedBox(width: 4),
                      Text(user.fishingType!, style: TextStyle(fontSize: 11, color: AppTheme.primaryBlue, fontWeight: FontWeight.w500)),
                      if (user.location != null) ...[
                        const SizedBox(width: 8),
                        Icon(Icons.location_on, size: 12, color: AppTheme.textHint),
                        const SizedBox(width: 2),
                        Text(user.location!, style: TextStyle(fontSize: 11, color: AppTheme.textHint)),
                      ],
                    ]),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 34,
              child: user.isFollowing
                  ? OutlinedButton(
                      onPressed: onFollow,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      child: const Text('Mengikuti'),
                    )
                  : ElevatedButton(
                      onPressed: onFollow,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      child: const Text('Ikuti'),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
