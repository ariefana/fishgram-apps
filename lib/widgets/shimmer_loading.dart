import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Shimmer loading placeholder widgets.
class ShimmerLoading extends StatelessWidget {
  final Widget child;

  const ShimmerLoading({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: child,
    );
  }

  /// Shimmer placeholder for a feed card.
  static Widget feedCard() {
    return ShimmerLoading(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User row
            Row(
              children: [
                const CircleAvatar(radius: 20, backgroundColor: Colors.white),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 120, height: 14, color: Colors.white),
                    const SizedBox(height: 4),
                    Container(width: 80, height: 10, color: Colors.white),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Photo placeholder
            Container(
              width: double.infinity,
              height: 240,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 12),
            // Caption
            Container(width: double.infinity, height: 14, color: Colors.white),
            const SizedBox(height: 6),
            Container(width: 200, height: 14, color: Colors.white),
            const SizedBox(height: 12),
            // Actions row
            Row(
              children: [
                Container(width: 60, height: 14, color: Colors.white),
                const SizedBox(width: 16),
                Container(width: 60, height: 14, color: Colors.white),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Shimmer placeholder for a user card.
  static Widget userCard() {
    return ShimmerLoading(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            const CircleAvatar(radius: 28, backgroundColor: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 140, height: 14, color: Colors.white),
                  const SizedBox(height: 6),
                  Container(width: 100, height: 12, color: Colors.white),
                ],
              ),
            ),
            Container(
              width: 80,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Multiple feed card shimmer placeholders.
  static Widget feedList({int count = 3}) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: count,
      itemBuilder: (context, index) => feedCard(),
    );
  }

  /// Multiple user card shimmer placeholders.
  static Widget userList({int count = 5}) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: count,
      itemBuilder: (context, index) => userCard(),
    );
  }
}
