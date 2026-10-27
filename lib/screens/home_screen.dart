import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/post_model.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';
import '../widgets/post_card.dart';
import '../widgets/user_avatar.dart';
import 'comments_screen.dart';
import 'create_post_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedFilter = 'All';

  final List<String> _filters = [
    'All',
    'Notices',
    'Events',
    'Lost & Found',
    'Discussions',
  ];

  String _getTimeBasedGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  void _showStoryPreview(BuildContext context, String title, String subtitle, String iconPath) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/images.png',
                  width: 72,
                  height: 72,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.cstuDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 13, color: AppTheme.cstuSlate),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.cstuGold,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('View Highlights'),
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
    final currentUser = firestoreService.currentUser;
    final allPosts = firestoreService.posts;

    // Filter posts
    final posts = allPosts.where((p) {
      if (_selectedFilter == 'All') return true;
      if (_selectedFilter == 'Notices') return p.postType == PostType.announcement;
      if (_selectedFilter == 'Events') return p.postType == PostType.event;
      if (_selectedFilter == 'Lost & Found') return p.postType == PostType.lostFound;
      if (_selectedFilter == 'Discussions') return p.postType == PostType.general;
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/images.png',
                width: 36,
                height: 36,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CSTU Connect',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    color: AppTheme.cstuDark,
                    letterSpacing: -0.4,
                  ),
                ),
                Text(
                  'Campus Quad • Chandpur',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.cstuSlate.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFA7F3D0)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 3.5,
                  backgroundColor: AppTheme.cstuEmerald,
                ),
                SizedBox(width: 5),
                Text(
                  'Online',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.cstuEmerald,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(milliseconds: 300));
        },
        color: AppTheme.cstuGold,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
          children: [
            // ─── Welcome Hero Banner ─────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppTheme.heroGradient,
                borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                border: Border.all(
                  color: AppTheme.cstuGoldBorder,
                  width: 1.2,
                ),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Row(
                children: [
                  UserAvatar(user: currentUser, radius: 25),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_getTimeBasedGreeting()}, ${currentUser.name.split(' ').first}! 👋',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.cstuDark,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${currentUser.department} • ${currentUser.batch}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.cstuSlate,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ─── Campus Moments & Stories Carousel ───────────────────────────
            SizedBox(
              height: 94,
              child: ListView(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                children: [
                  // Add Story
                  _StoryAvatar(
                    isUserAdd: true,
                    label: 'Add Story',
                    avatarWidget: UserAvatar(user: currentUser, radius: 24),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CreatePostScreen()),
                      );
                    },
                  ),
                  const SizedBox(width: 14),

                  // CSTU Official
                  _StoryAvatar(
                    label: 'CSTU Official',
                    avatarWidget: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/images.png',
                        width: 50,
                        height: 50,
                        fit: BoxFit.contain,
                      ),
                    ),
                    onTap: () => _showStoryPreview(
                      context,
                      'CSTU Official Notices',
                      'Direct announcements from university administration & registrar',
                      'assets/images.png',
                    ),
                  ),
                  const SizedBox(width: 14),

                  // CSTU Computer Club
                  _StoryAvatar(
                    label: 'CSTU CC',
                    avatarWidget: const CircleAvatar(
                      radius: 25,
                      backgroundColor: Color(0xFF0F172A),
                      child: Icon(Icons.code_rounded, color: AppTheme.cstuGold, size: 24),
                    ),
                    onTap: () => _showStoryPreview(
                      context,
                      'CSTU Computer Club',
                      'Competitive programming, hackathons & tech workshop updates',
                      'assets/images.png',
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Cultural Club
                  _StoryAvatar(
                    label: 'Cultural Club',
                    avatarWidget: const CircleAvatar(
                      radius: 25,
                      backgroundColor: Color(0xFFBE185D),
                      child: Icon(Icons.music_note_rounded, color: Colors.white, size: 24),
                    ),
                    onTap: () => _showStoryPreview(
                      context,
                      'Cultural Society',
                      'Spring campus fest, drama performances & music evenings',
                      'assets/images.png',
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Sports Club
                  _StoryAvatar(
                    label: 'Sports Club',
                    avatarWidget: const CircleAvatar(
                      radius: 25,
                      backgroundColor: Color(0xFF047857),
                      child: Icon(Icons.sports_cricket_rounded, color: Colors.white, size: 24),
                    ),
                    onTap: () => _showStoryPreview(
                      context,
                      'CSTU Sports Club',
                      'Annual cricket tournament and inter-department leagues',
                      'assets/images.png',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ─── Quick Composer Capsule ──────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                border: Border.all(color: AppTheme.borderLight),
                boxShadow: AppTheme.cardShadow,
              ),
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  Row(
                    children: [
                      UserAvatar(user: currentUser, radius: 19),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const CreatePostScreen()),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: AppTheme.borderLight),
                            ),
                            child: const Text(
                              "What's happening at CSTU?",
                              style: TextStyle(
                                color: AppTheme.cstuSlate,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: AppTheme.borderSubtle),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _QuickActionBtn(
                        icon: Icons.image_outlined,
                        label: 'Photo',
                        color: AppTheme.cstuRiverCyan,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const CreatePostScreen()),
                          );
                        },
                      ),
                      _QuickActionBtn(
                        icon: Icons.event_available_rounded,
                        label: 'Event',
                        color: AppTheme.cstuEmerald,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const CreatePostScreen()),
                          );
                        },
                      ),
                      _QuickActionBtn(
                        icon: Icons.campaign_rounded,
                        label: 'Notice',
                        color: AppTheme.cstuGold,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const CreatePostScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // ─── Filter Chips Row ────────────────────────────────────────────
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _filters.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final filter = _filters[index];
                  final isSelected = _selectedFilter == filter;
                  return ChoiceChip(
                    label: Text(filter),
                    selected: isSelected,
                    showCheckmark: false,
                    selectedColor: AppTheme.cstuGold,
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected ? Colors.white : AppTheme.cstuDark,
                    ),
                    side: BorderSide(
                      color: isSelected ? AppTheme.cstuGold : AppTheme.borderLight,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    onSelected: (val) {
                      if (val) {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedFilter = filter);
                      }
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 14),

            // ─── Feed Posts List ─────────────────────────────────────────────
            if (posts.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 20),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                  border: Border.all(color: AppTheme.borderLight),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.feed_outlined,
                      size: 48,
                      color: Color(0xFFCBD5E1),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No $_selectedFilter posts found',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.cstuDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Be the first to share an update in this category!',
                      style: TextStyle(fontSize: 13, color: AppTheme.cstuSlate),
                    ),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: posts.length,
                separatorBuilder: (context, index) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final post = posts[index];
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
        ),
      ),
    );
  }
}

class _StoryAvatar extends StatelessWidget {
  final String label;
  final Widget avatarWidget;
  final bool isUserAdd;
  final VoidCallback onTap;

  const _StoryAvatar({
    required this.label,
    required this.avatarWidget,
    this.isUserAdd = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(2.5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: isUserAdd ? null : AppTheme.goldGradient,
                  border: isUserAdd
                      ? Border.all(color: const Color(0xFFCBD5E1), width: 1.5)
                      : null,
                ),
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: avatarWidget,
                ),
              ),
              if (isUserAdd)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: AppTheme.cstuGold,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add, size: 12, color: Colors.white),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 68,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppTheme.cstuDark,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppTheme.cstuDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}