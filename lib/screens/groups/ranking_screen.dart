import 'package:afterlife_projects/widgets/effects/animated_entry.dart';
import 'package:afterlife_projects/widgets/effects/glass_card.dart';
import 'package:afterlife_projects/services/ranking_service.dart';
import 'package:afterlife_projects/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final RankingService _rankingService = RankingService();
  final String? _currentUserId = FirebaseAuth.instance.currentUser?.uid;

  String _sortBy = 'points';
  List<UserRankData> _worldData = [];
  List<UserRankData> _friendsData = [];
  bool _worldLoading = true;
  bool _friendsLoading = true;

  static const _sortOptions = [
    ('points', 'Puntos', Icons.star_rounded),
    ('nightsCompleted', 'Noches', Icons.nightlight_round),
    ('nightsCreated', 'Creadas', Icons.add_circle_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
    _loadAll();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    _loadWorld();
    _loadFriends();
  }

  Future<void> _loadWorld() async {
    setState(() => _worldLoading = true);
    try {
      final data = await _rankingService.getWorldRanking(sortBy: _sortBy);
      if (mounted) setState(() { _worldData = data; _worldLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _worldLoading = false);
    }
  }

  Future<void> _loadFriends() async {
    final userId = _currentUserId;
    if (userId == null) return;
    setState(() => _friendsLoading = true);
    try {
      final data = await _rankingService.getFriendsRanking(
        userId: userId,
        sortBy: _sortBy,
      );
      if (mounted) setState(() { _friendsData = data; _friendsLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _friendsLoading = false);
    }
  }

  void _changeSortBy(String newSort) {
    if (_sortBy == newSort) return;
    setState(() => _sortBy = newSort);
    _loadAll();
  }

  String _sortLabel(String sortBy) {
    switch (sortBy) {
      case 'nightsCompleted': return 'noches';
      case 'nightsCreated': return 'creadas';
      default: return 'pts';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AfterlifeColors.isDark(context);
    final textSecondary = AfterlifeColors.textSecondaryAdaptive(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverAppBar(
            pinned: true,
            expandedHeight: MediaQuery.of(context).padding.top + 80,
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: AfterlifeColors.headerGradient(context),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        ShaderMask(
                          shaderCallback: (b) => const LinearGradient(
                            colors: [Color(0xFFA855F7), Color(0xFFEC4899)],
                          ).createShader(b),
                          child: const Icon(Icons.emoji_events_rounded,
                              color: Colors.white, size: 32),
                        ),
                        const SizedBox(width: 12),
                        ShaderMask(
                          shaderCallback: (b) => const LinearGradient(
                            colors: [Color(0xFFA855F7), Color(0xFFEC4899), Color(0xFF06B6D4)],
                          ).createShader(b),
                          child: const Text(
                            'RANKING',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Container(
                color: isDark ? const Color(0xFF0D0D1A) : Colors.white.withValues(alpha: 0.7),
                child: TabBar(
                  controller: _tabController,
                  labelColor: AfterlifeColors.electricPurple,
                  unselectedLabelColor: textSecondary,
                  indicatorColor: AfterlifeColors.electricPurple,
                  indicatorWeight: 2,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, letterSpacing: 1.5),
                  tabs: const [
                    Tab(text: 'AMIGOS'),
                    Tab(text: 'MUNDIAL'),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: Column(
          children: [
            _buildFilterChips(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildRankingTab(_friendsData, _friendsLoading, isFriends: true),
                  _buildRankingTab(_worldData, _worldLoading, isFriends: false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final textSecondary = AfterlifeColors.textSecondaryAdaptive(context);

    return GlassCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: _sortOptions.map((option) {
          final (value, label, icon) = option;
          final isSelected = _sortBy == value;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => _changeSortBy(value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [Color(0xFFA855F7), Color(0xFFEC4899)],
                        )
                      : null,
                  color: isSelected ? null : textSecondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : textSecondary.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 14,
                        color: isSelected ? Colors.white : textSecondary),
                    const SizedBox(width: 5),
                    Text(
                      label,
                      style: TextStyle(
                        color: isSelected ? Colors.white : textSecondary,
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRankingTab(List<UserRankData> data, bool loading, {required bool isFriends}) {
    final isDark = AfterlifeColors.isDark(context);
    final textSecondary = AfterlifeColors.textSecondaryAdaptive(context);

    if (loading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(AfterlifeColors.electricPurple),
        ),
      );
    }

    if (data.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isFriends ? Icons.group_outlined : Icons.public_outlined,
              color: textSecondary.withValues(alpha: 0.4),
              size: 56,
            ),
            const SizedBox(height: 16),
            Text(
              isFriends ? 'Añade amigos para ver\nel ranking de amigos' : 'Sin datos disponibles',
              textAlign: TextAlign.center,
              style: TextStyle(color: textSecondary, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAll,
      color: AfterlifeColors.electricPurple,
      backgroundColor: isDark ? const Color(0xFF1A0533) : Colors.white,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 20),
        children: [
          if (data.length >= 3) AnimatedEntry(child: _buildPodium(data.take(3).toList())),
          const SizedBox(height: 8),
          ...List.generate(data.length > 3 ? data.length - 3 : 0, (i) {
            return AnimatedEntry(
              delay: Duration(milliseconds: i * 60),
              child: _buildListItem(data[i + 3], i + 4),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPodium(List<UserRankData> top3) {

    final textPrimary = AfterlifeColors.textPrimaryAdaptive(context);
    final ordered = [top3[1], top3[0], top3[2]];
    final heights = [80.0, 110.0, 60.0];
    final positions = [2, 1, 3];
    final colors = [
      const Color(0xFF9CA3AF), // silver
      const Color(0xFFFBBF24), // gold
      const Color(0xFFCD7C32), // bronze
    ];
    final medals = ['🥈', '🥇', '🥉'];

    return GlassCard(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (i) {
              final user = ordered[i];
              final isCurrentUser = user.isCurrentUser;
              return Expanded(
                child: Column(
                  children: [
                    Text(medals[i], style: const TextStyle(fontSize: 24)),
                    const SizedBox(height: 6),
                    Container(
                      width: 54,
                      height: 54,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            colors[i].withValues(alpha: 0.8),
                            colors[i].withValues(alpha: 0.4),
                          ],
                        ),
                        border: Border.all(
                          color: isCurrentUser
                              ? AfterlifeColors.electricPurple
                              : colors[i],
                          width: isCurrentUser ? 2.5 : 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          user.username.isNotEmpty
                              ? user.username[0].toUpperCase()
                              : 'U',
                          style: TextStyle(
                            color: colors[i],
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user.username.length > 8
                          ? '${user.username.substring(0, 8)}…'
                          : user.username,
                      style: TextStyle(
                        color: isCurrentUser
                            ? AfterlifeColors.electricPurple
                            : textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: heights[i],
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            colors[i].withValues(alpha: 0.4),
                            colors[i].withValues(alpha: 0.1),
                          ],
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                        border: Border.all(
                          color: colors[i].withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${positions[i]}',
                            style: TextStyle(
                              color: colors[i],
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            '${user.getValueFor(_sortBy)} ${_sortLabel(_sortBy)}',
                            style: TextStyle(
                              color: colors[i].withValues(alpha: 0.8),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(UserRankData user, int position) {
    final isCurrentUser = user.isCurrentUser;

    final textPrimary = AfterlifeColors.textPrimaryAdaptive(context);
    return GlassCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      tint: isCurrentUser
          ? AfterlifeColors.electricPurple.withValues(alpha: 0.1)
          : null,
      border: BorderSide(
        color: isCurrentUser
            ? AfterlifeColors.electricPurple.withValues(alpha: 0.5)
            : textPrimary.withValues(alpha: 0.06),
        width: isCurrentUser ? 1.5 : 1,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(
              '$position',
              style: TextStyle(
                color: isCurrentUser
                    ? AfterlifeColors.electricPurple
                    : textPrimary.withValues(alpha: 0.4),
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: isCurrentUser
                    ? [
                        AfterlifeColors.electricPurple.withValues(alpha: 0.7),
                        AfterlifeColors.neonPink.withValues(alpha: 0.5),
                      ]
                    : [
                        textPrimary.withValues(alpha: 0.15),
                        textPrimary.withValues(alpha: 0.05),
                      ],
              ),
              border: Border.all(
                color: isCurrentUser
                    ? AfterlifeColors.electricPurple
                    : textPrimary.withValues(alpha: 0.12),
              ),
            ),
            child: Center(
              child: Text(
                user.username.isNotEmpty ? user.username[0].toUpperCase() : 'U',
                style: TextStyle(
                  color: isCurrentUser
                      ? Colors.white
                      : textPrimary.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      user.username,
                      style: TextStyle(
                        color: isCurrentUser
                            ? textPrimary
                            : textPrimary.withValues(alpha: 0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (isCurrentUser) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AfterlifeColors.electricPurple.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'TÚ',
                          style: TextStyle(
                            color: AfterlifeColors.electricPurple,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  'Nivel ${user.level}',
                  style: TextStyle(
                    color: textPrimary.withValues(alpha: 0.38),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${user.getValueFor(_sortBy)}',
                style: TextStyle(
                  color: isCurrentUser
                      ? AfterlifeColors.electricPurple
                      : AfterlifeColors.neonPink,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                _sortLabel(_sortBy),
                style: TextStyle(color: textPrimary.withValues(alpha: 0.38), fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
