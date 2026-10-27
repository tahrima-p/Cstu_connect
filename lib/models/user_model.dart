class User {
  final String id;
  final String name;
  final String department;
  final String batch;
  final String bio;
  final int followerCount;
  final int followingCount;
  final int postCount;
  final String? avatarUrl;
  final String studentId;
  final String email;
  final bool isVerified;

  const User({
    required this.id,
    required this.name,
    required this.department,
    required this.batch,
    this.bio = '',
    this.followerCount = 0,
    this.followingCount = 0,
    this.postCount = 0,
    this.avatarUrl,
    this.studentId = '2022-CSE-001',
    this.email = 'student@student.cstu.ac.bd',
    this.isVerified = true,
  });

  User copyWith({
    String? id,
    String? name,
    String? department,
    String? batch,
    String? bio,
    int? followerCount,
    int? followingCount,
    int? postCount,
    String? avatarUrl,
    String? studentId,
    String? email,
    bool? isVerified,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      department: department ?? this.department,
      batch: batch ?? this.batch,
      bio: bio ?? this.bio,
      followerCount: followerCount ?? this.followerCount,
      followingCount: followingCount ?? this.followingCount,
      postCount: postCount ?? this.postCount,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      studentId: studentId ?? this.studentId,
      email: email ?? this.email,
      isVerified: isVerified ?? this.isVerified,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'department': department,
      'batch': batch,
      'bio': bio,
      'followerCount': followerCount,
      'followingCount': followingCount,
      'postCount': postCount,
      'avatarUrl': avatarUrl,
      'studentId': studentId,
      'email': email,
      'isVerified': isVerified,
    };
  }

  factory User.fromMap(Map<String, dynamic> map, [String? docId]) {
    return User(
      id: docId ?? map['id'] ?? '',
      name: map['name'] ?? 'CSTU Student',
      department: map['department'] ?? 'Computer Science & Engineering',
      batch: map['batch'] ?? 'Batch 2022',
      bio: map['bio'] ?? '',
      followerCount: (map['followerCount'] ?? 0) as int,
      followingCount: (map['followingCount'] ?? 0) as int,
      postCount: (map['postCount'] ?? 0) as int,
      avatarUrl: map['avatarUrl'] as String?,
      studentId: map['studentId'] ?? '2022-CSE-001',
      email: map['email'] ?? 'student@student.cstu.ac.bd',
      isVerified: (map['isVerified'] ?? false) as bool,
    );
  }
}
