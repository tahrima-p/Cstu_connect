import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/post_model.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';
import '../widgets/post_card.dart';
import 'events_screen.dart';
import 'clubs_screen.dart';
import 'lost_found_screen.dart';
import 'comments_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<String> _trendingTags = [
    '#TechFest2026',
    '#MidtermRoutine',
    '#CSTUHackathon',
    '#SportsMeet',
    '#BloodDonation',
    '#CSE_Batch22',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showNoticeModal(BuildContext context, List<Post> announcements) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(ctx).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.cstuGoldLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.campaign_rounded, color: AppTheme.cstuGold, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Official University Notices',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.cstuDark,
                        ),
                      ),
                      Text(
                        '${announcements.length} active announcements',
                        style: const TextStyle(fontSize: 12, color: AppTheme.cstuSlate),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, color: AppTheme.borderLight),
              const SizedBox(height: 12),
              Expanded(
                child: announcements.isEmpty
                    ? const Center(
                        child: Text(
                          'No official notices at this moment.',
                          style: TextStyle(color: AppTheme.cstuSlate),
                        ),
                      )
                    : ListView.separated(
                        itemCount: announcements.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (ctx, i) {
                          final post = announcements[i];
                          return PostCard(
                            post: post,
                            onCommentTap: () {
                              Navigator.pop(ctx);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CommentsScreen(post: post),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showQuickInfoSheet(BuildContext context, String title, String info) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.cstuDark,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                info,
                style: const TextStyle(fontSize: 14, color: AppTheme.cstuSlate, height: 1.5),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.cstuGold,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Got it'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = context.watch<FirestoreService>();
    final allPosts = firestoreService.posts;
    final announcements = allPosts.where((p) => p.postType == PostType.announcement).toList();

    final searchResults = _searchQuery.trim().isEmpty
        ? <Post>[]
        : allPosts
            .where((p) =>
                p.content.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                p.author.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                p.author.department.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: const Row(
          children: [
            Icon(Icons.explore_rounded, color: AppTheme.cstuGold, size: 24),
            SizedBox(width: 8),
            Text(
              'Explore Campus',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 20,
                color: AppTheme.cstuDark,
                letterSpacing: -0.4,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 90),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Search Bar ──────────────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                border: Border.all(color: AppTheme.borderLight),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 14),
                    child: Icon(Icons.search_rounded, color: AppTheme.cstuGold, size: 22),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                      },
                      decoration: const InputDecoration(
                        hintText: 'Search posts, departments, topics...',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        contentPadding: EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  if (_searchQuery.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear_rounded, color: AppTheme.cstuSlate, size: 20),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ─── Trending Campus Hashtags ────────────────────────────────────
            if (_searchQuery.isEmpty) ...[
              SizedBox(
                height: 32,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _trendingTags.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final tag = _trendingTags[index];
                    return ActionChip(
                      label: Text(tag),
                      labelStyle: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.cstuDark,
                      ),
                      backgroundColor: const Color(0xFFF1F5F9),
                      side: const BorderSide(color: AppTheme.borderLight),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        _searchController.text = tag.replaceAll('#', '');
                        setState(() {
                          _searchQuery = tag.replaceAll('#', '');
                        });
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),
            ],

            // ─── Dynamic Search Results ──────────────────────────────────────
            if (_searchQuery.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${searchResults.length} result${searchResults.length == 1 ? '' : 's'} for "$_searchQuery"',
                    style: const TextStyle(
                      color: AppTheme.cstuDark,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                    child: const Text('Clear', style: TextStyle(color: AppTheme.cstuGold)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (searchResults.isEmpty)
                Container(
                  padding: const EdgeInsets.all(36),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                    border: Border.all(color: AppTheme.borderLight),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.search_off_rounded, size: 48, color: Color(0xFFCBD5E1)),
                      const SizedBox(height: 12),
                      const Text(
                        'No matching campus content',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.cstuDark,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Try searching for different keywords or department abbreviations.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: AppTheme.cstuSlate),
                      ),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: searchResults.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final post = searchResults[index];
                    return PostCard(
                      post: post,
                      onCommentTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CommentsScreen(post: post),
                          ),
                        );
                      },
                    );
                  },
                ),
            ],

            // ─── Bento Grid Hub (Default View) ───────────────────────────────
            if (_searchQuery.isEmpty) ...[
              const Text(
                'Campus Hub',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.cstuDark,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 12),

              // 1. Featured Spotlight Banner (Large Bento)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppTheme.goldGradient,
                  borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                  boxShadow: AppTheme.goldGlow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.bolt_rounded, size: 14, color: Colors.white),
                              SizedBox(width: 4),
                              Text(
                                'CAMPUS SPOTLIGHT',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            'assets/images.png',
                            width: 32,
                            height: 32,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Annual CSTU Tech Sprint 2026',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      '36-hour hackathon, project showcase & inter-department coding battle in Chandpur.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const EventsScreen()),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'View Events',
                              style: TextStyle(
                                color: AppTheme.cstuDark,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(Icons.arrow_forward_rounded, size: 14, color: AppTheme.cstuDark),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // 2. Bento Grid 2x2 Tiles
              Row(
                children: [
                  // Bento 1: Events
                  Expanded(
                    child: _BentoTile(
                      icon: Icons.event_available_rounded,
                      iconColor: AppTheme.cstuEmerald,
                      title: 'Events & Meets',
                      subtitle: '${firestoreService.events.length} Upcoming',
                      accentTag: 'RSVP Open',
                      accentTagColor: AppTheme.cstuEmerald,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const EventsScreen()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Bento 2: Clubs
                  Expanded(
                    child: _BentoTile(
                      icon: Icons.groups_rounded,
                      iconColor: AppTheme.cstuRiverCyan,
                      title: 'Student Clubs',
                      subtitle: '${firestoreService.clubs.length} Societies',
                      accentTag: 'Recruiting',
                      accentTagColor: AppTheme.cstuRiverCyan,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ClubsScreen()),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  // Bento 3: Lost & Found
                  Expanded(
                    child: _BentoTile(
                      icon: Icons.find_in_page_rounded,
                      iconColor: AppTheme.cstuCrimson,
                      title: 'Lost & Found',
                      subtitle: '${firestoreService.lostFoundItems.length} Reports',
                      accentTag: 'Active Desk',
                      accentTagColor: AppTheme.cstuCrimson,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const LostFoundScreen()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Bento 4: Notices
                  Expanded(
                    child: _BentoTile(
                      icon: Icons.campaign_rounded,
                      iconColor: AppTheme.cstuGold,
                      title: 'Notices Desk',
                      subtitle: '${announcements.length} Official',
                      accentTag: 'Registrar',
                      accentTagColor: AppTheme.cstuGold,
                      onTap: () => _showNoticeModal(context, announcements),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ─── Campus Utilities & Fast Links ─────────────────────────────
              const Text(
                'Campus Utilities',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.cstuDark,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _UtilityCard(
                      icon: Icons.directions_bus_rounded,
                      label: 'Transport Bus',
                      desc: 'Schedule & routes',
                      onTap: () => _showQuickInfoSheet(
                        context,
                        'Campus Transport Bus Schedule',
                        'Bus 1: Chandpur Town Hall ➔ Campus (7:45 AM, 1:30 PM)\nBus 2: Rail Station ➔ Campus (8:15 AM, 4:00 PM)',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _UtilityCard(
                      icon: Icons.local_library_rounded,
                      label: 'Library Desk',
                      desc: 'Open: 9 AM - 6 PM',
                      onTap: () => _showQuickInfoSheet(
                        context,
                        'Central Library Status',
                        'Main Library Hall: Open today until 6:00 PM.\nDigital e-Library Portal available 24/7 on university intranet.',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BentoTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String accentTag;
  final Color accentTagColor;
  final VoidCallback onTap;

  const _BentoTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.accentTag,
    required this.accentTagColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusCard),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
          border: Border.all(color: AppTheme.borderLight),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: accentTagColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    accentTag,
                    style: TextStyle(
                      color: accentTagColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppTheme.cstuDark,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppTheme.cstuSlate,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UtilityCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String desc;
  final VoidCallback onTap;

  const _UtilityCard({
    required this.icon,
    required this.label,
    required this.desc,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderLight),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.cstuGold, size: 24),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.cstuDark,
                    ),
                  ),
                  Text(
                    desc,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.cstuSlate,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}