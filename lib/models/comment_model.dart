import 'user_model.dart';

class Comment {
  final String id;
  final User author;
  final String content;
  final DateTime createdAt;

  const Comment({
    required this.id,
    required this.author,
    required this.content,
    required this.createdAt,
  });

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
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
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Comment.fromMap(Map<String, dynamic> map, [String? docId]) {
    return Comment(
      id: docId ?? map['id'] ?? '',
      author: User(
        id: map['authorId'] ?? 'u0',
        name: map['authorName'] ?? 'Anonymous',
        department: map['authorDepartment'] ?? 'CSTU',
        batch: map['authorBatch'] ?? '',
        avatarUrl: map['authorAvatarUrl'],
      ),
      content: map['content'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
