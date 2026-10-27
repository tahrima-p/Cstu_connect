import 'user_model.dart';

enum PostType { general, event, announcement, lostFound }

class Post {
  final String id;
  final User author;
  final String content;
  final PostType postType;
  final String? imageUrl;
  int likeCount;
  int commentCount;
  bool isLiked;
  final List<String> likedBy;
  final DateTime createdAt;

  Post({
    required this.id,
    required this.author,
    required this.content,
    this.postType = PostType.general,
    this.imageUrl,
    this.likeCount = 0,
    this.commentCount = 0,
    this.isLiked = false,
    List<String>? likedBy,
    required this.createdAt,
  }) : likedBy = likedBy ?? [];

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  String get postTypeLabel {
    switch (postType) {
      case PostType.event:
        return 'Event';
      case PostType.announcement:
        return 'Announcement';
      case PostType.lostFound:
        return 'Lost & Found';
      case PostType.general:
        return '';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'authorId': author.id,
      'authorName': author.name,
      'authorDepartment': author.department,
      'authorBatch': author.batch,
      'authorAvatarUrl': author.avatarUrl,
      'content': content,
      'postType': postType.name,
      'imageUrl': imageUrl,
      'likeCount': likeCount,
      'commentCount': commentCount,
      'likedBy': likedBy,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Post.fromMap(Map<String, dynamic> map, [String? docId, String? currentUserId]) {
    final likedList = List<String>.from(map['likedBy'] ?? []);
    final currentLiked = currentUserId != null ? likedList.contains(currentUserId) : (map['isLiked'] ?? false);

    return Post(
      id: docId ?? map['id'] ?? '',
      author: User(
        id: map['authorId'] ?? 'u0',
        name: map['authorName'] ?? 'Anonymous',
        department: map['authorDepartment'] ?? 'CSTU',
        batch: map['authorBatch'] ?? '',
        avatarUrl: map['authorAvatarUrl'],
      ),
      content: map['content'] ?? '',
      postType: PostType.values.firstWhere(
        (e) => e.name == map['postType'],
        orElse: () => PostType.general,
      ),
      imageUrl: map['imageUrl'] as String?,
      likeCount: (map['likeCount'] ?? likedList.length) as int,
      commentCount: (map['commentCount'] ?? 0) as int,
      isLiked: currentLiked,
      likedBy: likedList,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Post copyWith({
    String? id,
    User? author,
    String? content,
    PostType? postType,
    String? imageUrl,
    int? likeCount,
    int? commentCount,
    bool? isLiked,
    List<String>? likedBy,
    DateTime? createdAt,
  }) {
    return Post(
      id: id ?? this.id,
      author: author ?? this.author,
      content: content ?? this.content,
      postType: postType ?? this.postType,
      imageUrl: imageUrl ?? this.imageUrl,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      isLiked: isLiked ?? this.isLiked,
      likedBy: likedBy ?? this.likedBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
