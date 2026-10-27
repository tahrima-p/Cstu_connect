import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/club_model.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';

class ClubsScreen extends StatefulWidget {
  const ClubsScreen({super.key});

  @override
  State<ClubsScreen> createState() => _ClubsScreenState();
}

class _ClubsScreenState extends State<ClubsScreen> {
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Technology',
    'Arts & Culture',
    'Sports',
    'Business',
  ];

  @override
  Widget build(BuildContext context) {
    final firestoreService = context.watch<FirestoreService>();
    final allClubs = firestoreService.clubs;

    final clubs = allClubs.where((c) {
      if (_selectedCategory == 'All') return true;
      return c.category.toLowerCase().contains(_selectedCategory.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: const Row(
          children: [
            Icon(Icons.groups_rounded, color: AppTheme.cstuGold, size: 24),
            SizedBox(width: 8),
            Text(
              'Student Societies',
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
      body: Column(
        children: [
          // Filter Chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = _selectedCategory == cat;
                  return ChoiceChip(
                    label: Text(cat),
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
                        setState(() => _selectedCategory = cat);
                      }
                    },
                  );
                },
              ),
            ),
          ),

          // Clubs List
          Expanded(
            child: clubs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.groups_outlined,
                          size: 54,
                          color: Color(0xFFCBD5E1),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No $_selectedCategory clubs found',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.cstuDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Discover other societies or create a new student hub.',
                          style: TextStyle(fontSize: 13, color: AppTheme.cstuSlate),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                    itemCount: clubs.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final club = clubs[index];
                      return _ClubCard(
                        club: club,
                        onToggle: () {
                          HapticFeedback.mediumImpact();
                          firestoreService.toggleClubMembership(club.id);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ClubCard extends StatelessWidget {
  final Club club;
  final VoidCallback onToggle;

  const _ClubCard({required this.club, required this.onToggle});

  Color get _categoryColor {
    switch (club.category) {
      case 'Technology':
        return AppTheme.cstuRiverCyan;
      case 'Arts & Culture':
        return const Color(0xFFBE185D);
      case 'Business':
        return AppTheme.cstuEmerald;
      case 'Sports':
        return const Color(0xFFEA580C);
      default:
        return AppTheme.cstuGold;
    }
  }

  IconData get _categoryIcon {
    switch (club.category) {
      case 'Technology':
        return Icons.terminal_rounded;
      case 'Arts & Culture':
        return Icons.palette_rounded;
      case 'Business':
        return Icons.trending_up_rounded;
      case 'Sports':
        return Icons.sports_cricket_rounded;
      default:
        return Icons.hub_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = context.read<FirestoreService>().currentUser.id;
    final isJoined = club.isJoined || club.joinedUserIds.contains(currentUserId);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(color: AppTheme.borderLight),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Accent Color Strip
          Container(
            height: 5,
            width: double.infinity,
            decoration: BoxDecoration(
              color: _categoryColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _categoryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(_categoryIcon, color: _categoryColor, size: 26),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  club.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.cstuDark,
                                    letterSpacing: -0.3,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFECFDF5),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Recruiting',
                                  style: TextStyle(
                                    color: AppTheme.cstuEmerald,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Text(
                                club.category,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: _categoryColor,
                                ),
                              ),
                              const Text(' • ', style: TextStyle(color: Color(0xFFCBD5E1))),
                              Text(
                                '${club.memberCount} CSTUians',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.cstuSlate,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Description
                Text(
                  club.description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.cstuSlate,
                    height: 1.45,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 14),
                const Divider(height: 1, color: AppTheme.borderSubtle),
                const SizedBox(height: 10),

                // Action Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isJoined ? 'You are a registered member' : 'Open to all students',
                      style: TextStyle(
                        fontSize: 11,
                        color: isJoined ? AppTheme.cstuEmerald : AppTheme.cstuSlate,
                        fontWeight: isJoined ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                    InkWell(
                      onTap: onToggle,
                      borderRadius: BorderRadius.circular(12),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isJoined ? const Color(0xFFECFDF5) : AppTheme.cstuGold,
                          borderRadius: BorderRadius.circular(12),
                          border: isJoined
                              ? Border.all(color: AppTheme.cstuEmerald, width: 1.5)
                              : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isJoined ? Icons.check_circle_rounded : Icons.person_add_rounded,
                              size: 15,
                              color: isJoined ? AppTheme.cstuEmerald : Colors.white,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isJoined ? 'Joined ✓' : 'Join Society',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: isJoined ? AppTheme.cstuEmerald : Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
