import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/post_model.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';
import 'user_avatar.dart';

class PostCard extends StatefulWidget {
  final Post post;
  final VoidCallback? onCommentTap;

  const PostCard({
    super.key,
    required this.post,
    this.onCommentTap,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> with SingleTickerProviderStateMixin {
  late AnimationController _likeAnimController;
  late Animation<double> _likeScaleAnim;
  bool _isBookmarked = false;

  @override
  void initState() {
    super.initState();
    _likeAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _likeScaleAnim = Tween<double>(begin: 1.0, end: 1.35).animate(
      CurvedAnimation(parent: _likeAnimController, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _likeAnimController.dispose();
    super.dispose();
  }

  Widget _buildPostTypeBadge() {
    if (widget.post.postType == PostType.general) return const SizedBox.shrink();

    final (label, color, bgColor, icon) = switch (widget.post.postType) {
      PostType.event => (
          'Event',
          AppTheme.cstuEmerald,
          const Color(0xFFECFDF5),
          Icons.event_available_rounded
        ),
      PostType.announcement => (
          'Notice',
          AppTheme.cstuGold,
          AppTheme.cstuGoldLight,
          Icons.campaign_rounded
        ),
      PostType.lostFound => (
          'Lost & Found',
          AppTheme.cstuRiverCyan,
          const Color(0xFFF0F9FF),
          Icons.find_in_page_rounded
        ),
      PostType.general => ('', AppTheme.cstuSlate, Colors.transparent, Icons.article_rounded),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 1.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }

  void _handleLike(bool isLiked) {
    HapticFeedback.lightImpact();
    if (!isLiked) {
      _likeAnimController.forward().then((_) => _likeAnimController.reverse());
    }
    context.read<FirestoreService>().toggleLike(widget.post.id);
  }

  void _toggleBookmark() {
    HapticFeedback.selectionClick();
    setState(() => _isBookmarked = !_isBookmarked);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isBookmarked ? 'Post saved to bookmarks' : 'Removed from bookmarks'),
        duration: const Duration(seconds: 2),
        backgroundColor: AppTheme.cstuDark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = context.watch<FirestoreService>();
    final isLiked = widget.post.likedBy.contains(firestoreService.currentUser.id) || widget.post.isLiked;
    final isAnnouncement = widget.post.postType == PostType.announcement;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(
          color: isAnnouncement ? AppTheme.cstuGold : AppTheme.borderLight,
          width: isAnnouncement ? 1.5 : 1.0,
        ),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                UserAvatar(user: widget.post.author, radius: 21),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              widget.post.author.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                                color: AppTheme.cstuDark,
                                letterSpacing: -0.3,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          if (widget.post.author.batch.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                widget.post.author.batch.replaceFirst('Batch ', 'B\''),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.cstuSlate,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              widget.post.author.department,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.cstuSlate,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          const Text(' • ', style: TextStyle(color: Color(0xFFCBD5E1))),
                          Text(
                            widget.post.timeAgo,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _buildPostTypeBadge(),
              ],
            ),

                const SizedBox(height: 14),

                // Content Text
                Text(
                  widget.post.content,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.55,
                    color: Color(0xFF1E293B),
                    fontWeight: FontWeight.w400,
                  ),
                ),

                // Image if present
                if (widget.post.imageUrl != null && widget.post.imageUrl!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(
                      widget.post.imageUrl!,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                    ),
                  ),
                ],

                const SizedBox(height: 14),
                const Divider(height: 1, color: AppTheme.borderSubtle),
                const SizedBox(height: 8),

                // Interactive Reaction Bar
                Row(
                  children: [
                    // Like button with pulse animation
                    ScaleTransition(
                      scale: _likeScaleAnim,
                      child: InkWell(
                        onTap: () => _handleLike(isLiked),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          child: Row(
                            children: [
                              Icon(
                                isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                size: 20,
                                color: isLiked ? AppTheme.cstuCrimson : AppTheme.cstuSlate,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${widget.post.likeCount}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isLiked ? FontWeight.w800 : FontWeight.w600,
                                  color: isLiked ? AppTheme.cstuCrimson : AppTheme.cstuSlate,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Comment button
                    InkWell(
                      onTap: widget.onCommentTap,
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.chat_bubble_outline_rounded,
                              size: 19,
                              color: AppTheme.cstuSlate,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${widget.post.commentCount}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.cstuSlate,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Bookmark toggle
                    IconButton(
                      icon: Icon(
                        _isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                        size: 20,
                        color: _isBookmarked ? AppTheme.cstuGold : AppTheme.cstuSlate,
                      ),
                      onPressed: _toggleBookmark,
                      padding: const EdgeInsets.all(6),
                      constraints: const BoxConstraints(),
                    ),

                    const SizedBox(width: 12),

                    // Share button
                    IconButton(
                      icon: const Icon(
                        Icons.share_outlined,
                        size: 19,
                        color: AppTheme.cstuSlate,
                      ),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Clipboard.setData(ClipboardData(text: widget.post.content));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Post copied to clipboard!'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      padding: const EdgeInsets.all(6),
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }
}
