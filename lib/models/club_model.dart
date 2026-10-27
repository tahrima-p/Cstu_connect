class Club {
  final String id;
  final String name;
  final String description;
  final String category;
  int memberCount;
  bool isJoined;
  final List<String> joinedUserIds;

  Club({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    this.memberCount = 0,
    this.isJoined = false,
    List<String>? joinedUserIds,
  }) : joinedUserIds = joinedUserIds ?? [];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'memberCount': memberCount,
      'joinedUserIds': joinedUserIds,
    };
  }

  factory Club.fromMap(Map<String, dynamic> map, [String? docId, String? currentUserId]) {
    final joinedList = List<String>.from(map['joinedUserIds'] ?? []);
    final joined = currentUserId != null ? joinedList.contains(currentUserId) : (map['isJoined'] ?? false);

    return Club(
      id: docId ?? map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? 'General',
      memberCount: (map['memberCount'] ?? joinedList.length) as int,
      isJoined: joined,
      joinedUserIds: joinedList,
    );
  }
}
