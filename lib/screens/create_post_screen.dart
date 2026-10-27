import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/post_model.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';
import '../widgets/user_avatar.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _textController = TextEditingController();
  PostType _selectedType = PostType.general;
  String _selectedVisibility = 'Everyone at CSTU';

  static const int _maxChars = 500;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  bool get _canPost => _textController.text.trim().isNotEmpty;

  void _showVisibilityOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Post Visibility',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.cstuDark,
                ),
              ),
              const SizedBox(height: 8),
              _VisibilityOption(
                icon: Icons.public,
                title: 'Everyone at CSTU',
                selected: _selectedVisibility == 'Everyone at CSTU',
                onTap: () {
                  setState(() => _selectedVisibility = 'Everyone at CSTU');
                  Navigator.pop(ctx);
                },
              ),
              _VisibilityOption(
                icon: Icons.computer,
                title: 'CSE Department',
                selected: _selectedVisibility == 'CSE Department',
                onTap: () {
                  setState(() => _selectedVisibility = 'CSE Department');
                  Navigator.pop(ctx);
                },
              ),
              _VisibilityOption(
                icon: Icons.language,
                title: 'ICT Department',
                selected: _selectedVisibility == 'ICT Department',
                onTap: () {
                  setState(() => _selectedVisibility = 'ICT Department');
                  Navigator.pop(ctx);
                },
              ),
              _VisibilityOption(
                icon: Icons.business,
                title: 'BBA Department',
                selected: _selectedVisibility == 'BBA Department',
                onTap: () {
                  setState(() => _selectedVisibility = 'BBA Department');
                  Navigator.pop(ctx);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submitPost() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    await context.read<FirestoreService>().createPost(
          text,
          _selectedType,
          _selectedVisibility,
        );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Post published to CSTU Connect feed! 🎉'),
          duration: Duration(seconds: 2),
          backgroundColor: AppTheme.cstuGold,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context);
    }
  }

  IconData get _typeIcon {
    switch (_selectedType) {
      case PostType.event:
        return Icons.event;
      case PostType.announcement:
        return Icons.campaign;
      case PostType.lostFound:
        return Icons.find_in_page;
      case PostType.general:
        return Icons.article_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<FirestoreService>().currentUser;
    final charCount = _textController.text.length;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          'Create Post',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton(
              onPressed: _canPost ? _submitPost : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _canPost ? AppTheme.cstuGold : Colors.grey.shade300,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: _canPost ? 2 : 0,
              ),
              child: const Text(
                'Publish',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Header
            Row(
              children: [
                UserAvatar(user: user, radius: 22),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppTheme.cstuDark,
                      ),
                    ),
                    Text(
                      '${user.department} • CSTU',
                      style: const TextStyle(color: AppTheme.cstuSlate, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Post type chips
            const Text(
              'Select Post Category',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: AppTheme.cstuSlate,
              ),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _TypeChip(
                    label: 'General Post',
                    icon: Icons.article_outlined,
                    selected: _selectedType == PostType.general,
                    onTap: () => setState(() => _selectedType = PostType.general),
                  ),
                  const SizedBox(width: 8),
                  _TypeChip(
                    label: 'Campus Event',
                    icon: Icons.event,
                    selected: _selectedType == PostType.event,
                    onTap: () => setState(() => _selectedType = PostType.event),
                  ),
                  const SizedBox(width: 8),
                  _TypeChip(
                    label: 'Notice / Announcement',
                    icon: Icons.campaign,
                    selected: _selectedType == PostType.announcement,
                    onTap: () => setState(() => _selectedType = PostType.announcement),
                  ),
                  const SizedBox(width: 8),
                  _TypeChip(
                    label: 'Lost & Found',
                    icon: Icons.find_in_page,
                    selected: _selectedType == PostType.lostFound,
                    onTap: () => setState(() => _selectedType = PostType.lostFound),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Text input box
            TextField(
              controller: _textController,
              maxLines: 8,
              maxLength: _maxChars,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: "What's happening on CSTU campus today?",
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppTheme.borderLight),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppTheme.borderLight),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppTheme.cstuGold, width: 2),
                ),
                counterStyle: TextStyle(
                  color: charCount > _maxChars * 0.9 ? Colors.red : AppTheme.cstuSlate,
                ),
              ),
            ),

            const SizedBox(height: 18),

            // Add attachments / Options
            const Text(
              'Add to your post',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.cstuDark,
              ),
            ),

            const SizedBox(height: 10),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderLight),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.cstuGoldLight,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.image_outlined, color: AppTheme.cstuGold),
                      ),
                      title: const Text('Add Media / Photo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: const Text('Attach photo or event banner', style: TextStyle(fontSize: 12, color: AppTheme.cstuSlate)),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.cstuSlate),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Image attachment supported with Cloud Storage!'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1, color: AppTheme.borderSubtle),
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.cstuGoldLight,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(_typeIcon, color: AppTheme.cstuGold),
                      ),
                      title: const Text('Post Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: Text(_selectedType.name.toUpperCase()),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.cstuSlate),
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Audience Visibility Selector
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderLight),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                clipBehavior: Clip.antiAlias,
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.cstuGoldLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.public, color: AppTheme.cstuGold),
                  ),
                  title: const Text(
                    'Post Target Audience',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  subtitle: Text(_selectedVisibility, style: const TextStyle(color: AppTheme.cstuSlate, fontSize: 12)),
                  trailing: const Icon(Icons.arrow_drop_down, color: AppTheme.cstuDark),
                  onTap: _showVisibilityOptions,
                ),
              ),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _TypeChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppTheme.cstuGold : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppTheme.cstuGold : AppTheme.borderLight,
            width: selected ? 1.5 : 1,
          ),
          boxShadow: selected ? AppTheme.goldGlow : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: selected ? Colors.white : AppTheme.cstuSlate,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                color: selected ? Colors.white : AppTheme.cstuDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VisibilityOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _VisibilityOption({
    required this.icon,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: selected ? AppTheme.cstuGold : AppTheme.cstuSlate,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          color: selected ? AppTheme.cstuGold : AppTheme.cstuDark,
        ),
      ),
      trailing: selected
          ? const Icon(Icons.check_circle, color: AppTheme.cstuGold)
          : null,
      onTap: onTap,
    );
  }
}
