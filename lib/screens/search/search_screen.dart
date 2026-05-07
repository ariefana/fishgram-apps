import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../providers/search_provider.dart';
import '../../widgets/user_card.dart';
import '../../widgets/shimmer_loading.dart';
import '../../widgets/empty_state.dart';
import '../other_profile/other_profile_screen.dart';

/// Search / Find friends screen.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SearchProvider>().loadRecommendations();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cari Teman'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Rekomendasi'),
            Tab(text: 'Permintaan'),
            Tab(text: 'Mengikuti'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari berdasarkan nama atau username...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          context.read<SearchProvider>().clearSearch();
                          setState(() {});
                        },
                      )
                    : null,
              ),
              onChanged: (v) {
                context.read<SearchProvider>().searchUsers(v);
                setState(() {});
              },
            ),
          ),
          // Filter chips
          SizedBox(
            height: 40,
            child: Consumer<SearchProvider>(
              builder: (context, sp, _) {
                return ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildFilterChip('Semua', null, sp),
                    ...AppConstants.fishingTypes.map(
                      (type) => _buildFilterChip(type, type, sp),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          // Results
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildRecommendationsTab(),
                const EmptyState(
                  icon: Icons.group_add,
                  title: 'Tidak ada permintaan',
                  subtitle: 'Permintaan pertemanan akan muncul di sini',
                ),
                const EmptyState(
                  icon: Icons.people,
                  title: 'Belum mengikuti siapapun',
                  subtitle: 'Cari dan ikuti pemancing lainnya!',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String? type, SearchProvider sp) {
    final isSelected = sp.selectedFishingType == type;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label, style: const TextStyle(color: AppTheme.primaryBlue)),
        selected: isSelected,
        onSelected: (_) => sp.filterByFishingType(type),
        selectedColor: AppTheme.primaryBlue.withValues(alpha: 0.12),
        checkmarkColor: AppTheme.primaryBlue,
      ),
    );
  }

  Widget _buildRecommendationsTab() {
    return Consumer<SearchProvider>(
      builder: (context, sp, _) {
        final list = sp.query.isNotEmpty
            ? sp.searchResults
            : sp.recommendations;

        if (sp.isLoading) return ShimmerLoading.userList();
        if (list.isEmpty) {
          return EmptyState(
            icon: Icons.person_search,
            title: sp.query.isNotEmpty
                ? 'Tidak ditemukan'
                : 'Tidak ada rekomendasi',
            subtitle: sp.query.isNotEmpty
                ? 'Coba kata kunci lain'
                : 'Belum ada pengguna terdaftar',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.only(bottom: 100),
          itemCount: list.length,
          separatorBuilder: (_, _) => const Divider(),
          itemBuilder: (context, index) {
            final user = list[index];
            return UserCard(
              user: user,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OtherProfileScreen(userId: user.id),
                ),
              ),
              onFollow: () => sp.toggleFollow(user.id),
            );
          },
        );
      },
    );
  }
}
