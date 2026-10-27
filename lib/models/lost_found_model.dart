class LostFoundItem {
  final String id;
  final String title;
  final String description;
  final bool isLost; // true = lost, false = found
  final String location;
  final String reporterName;
  final String reporterId;
  final DateTime reportedAt;

  const LostFoundItem({
    required this.id,
    required this.title,
    required this.description,
    required this.isLost,
    required this.location,
    required this.reporterName,
    this.reporterId = 'u0',
    required this.reportedAt,
  });

  String get timeAgo {
    final diff = DateTime.now().difference(reportedAt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays}d ago';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isLost': isLost,
      'location': location,
      'reporterName': reporterName,
      'reporterId': reporterId,
      'reportedAt': reportedAt.toIso8601String(),
    };
  }

  factory LostFoundItem.fromMap(Map<String, dynamic> map, [String? docId]) {
    return LostFoundItem(
      id: docId ?? map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      isLost: map['isLost'] ?? true,
      location: map['location'] ?? 'Campus',
      reporterName: map['reporterName'] ?? 'CSTU Student',
      reporterId: map['reporterId'] ?? 'u0',
      reportedAt: map['reportedAt'] != null
          ? DateTime.tryParse(map['reportedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
