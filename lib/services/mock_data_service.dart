import '../models/user_model.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';
import '../models/notification_model.dart';
import '../models/event_model.dart';
import '../models/club_model.dart';
import '../models/lost_found_model.dart';

class MockDataService {
  MockDataService._();
  static final MockDataService instance = MockDataService._();

  // ─── Current logged-in user ───────────────────────────────────────────────
  User currentUser = const User(
    id: 'u0',
    name: 'Rahim Ahmed',
    department: 'Computer Science & Engineering',
    batch: 'Batch 2022',
    bio: 'CSE student at CSTU. Love coding & tech.',
    followerCount: 248,
    followingCount: 180,
    postCount: 12,
  );

  // ─── Sample users ─────────────────────────────────────────────────────────
  final List<User> _users = const [
    User(
      id: 'u1',
      name: 'Karim Hossain',
      department: 'CSE',
      batch: 'Batch 2021',
      followerCount: 512,
      followingCount: 230,
      postCount: 34,
    ),
    User(
      id: 'u2',
      name: 'Nusrat Jahan',
      department: 'ICT',
      batch: 'Batch 2022',
      followerCount: 310,
      followingCount: 150,
      postCount: 18,
    ),
    User(
      id: 'u3',
      name: 'CSTU Admin',
      department: 'Administration',
      batch: '',
      followerCount: 2100,
      followingCount: 0,
      postCount: 98,
    ),
    User(
      id: 'u4',
      name: 'Sumaiya Akter',
      department: 'BBA',
      batch: 'Batch 2023',
      followerCount: 190,
      followingCount: 200,
      postCount: 9,
    ),
    User(
      id: 'u5',
      name: 'Tanvir Islam',
      department: 'CSE',
      batch: 'Batch 2020',
      followerCount: 870,
      followingCount: 340,
      postCount: 56,
    ),
  ];

  // ─── Posts ────────────────────────────────────────────────────────────────
  late final List<Post> _posts = [
    Post(
      id: 'p1',
      author: _users[2], // CSTU Admin
      content:
          '📢 Important Notice: Mid-term exams will begin on October 15th. All students are requested to collect their admit cards from the exam controller office by October 10th. Best of luck to everyone! 🎓',
      postType: PostType.announcement,
      likeCount: 142,
      commentCount: 28,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    Post(
      id: 'p2',
      author: _users[0], // Karim
      content:
          'Just finished the database lab assignment. If anyone needs help with SQL joins, feel free to DM me! We can study together before the exam. 💪\n\n#CSE #CSTU #Database',
      postType: PostType.general,
      likeCount: 47,
      commentCount: 12,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    Post(
      id: 'p3',
      author: _users[4], // Tanvir
      content:
          '🎉 CSTU Tech Fest 2026 is coming! The annual tech festival will be held on November 5–7. This year we have hackathon, robotics competition, project showcase and so much more!\n\nRegister now at the CSE department office.',
      postType: PostType.event,
      likeCount: 234,
      commentCount: 61,
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
    ),
    Post(
      id: 'p4',
      author: _users[1], // Nusrat
      content:
          'Looking for my blue notebook — lost it somewhere near the cafeteria or the ICT building. It has my name "Nusrat" written on the cover. Please return it if found! 🙏',
      postType: PostType.lostFound,
      likeCount: 15,
      commentCount: 7,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Post(
      id: 'p5',
      author: _users[3], // Sumaiya
      content:
          'First week of university life is done! So nervous but also so excited. CSTU feels like a second home already. Thanks to everyone who helped me settle in 🌸',
      postType: PostType.general,
      likeCount: 89,
      commentCount: 22,
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
    ),
    Post(
      id: 'p6',
      author: _users[2], // CSTU Admin
      content:
          '📚 Library hours have been extended during exam season:\n• Weekdays: 8 AM – 10 PM\n• Weekends: 9 AM – 8 PM\n\nMake the most of it! Study hard, score well. 📖',
      postType: PostType.announcement,
      likeCount: 98,
      commentCount: 14,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  // ─── Comments (keyed by post id) ─────────────────────────────────────────
  final Map<String, List<Comment>> _comments = {
    'p1': [
      Comment(
        id: 'c1',
        author: const User(id: 'u1', name: 'Karim Hossain', department: 'CSE', batch: 'Batch 2021'),
        content: 'Thanks for the heads up! Already planned my study schedule.',
        createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
      ),
      Comment(
        id: 'c2',
        author: const User(id: 'u4', name: 'Sumaiya Akter', department: 'BBA', batch: 'Batch 2023'),
        content: 'Can we collect admit cards online?',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ],
    'p2': [
      Comment(
        id: 'c3',
        author: const User(id: 'u5', name: 'Tanvir Islam', department: 'CSE', batch: 'Batch 2020'),
        content: 'Great initiative! Left outer joins are always tricky 😅',
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      ),
    ],
    'p3': [
      Comment(
        id: 'c4',
        author: const User(id: 'u1', name: 'Karim Hossain', department: 'CSE', batch: 'Batch 2021'),
        content: 'Can\'t wait! Last year\'s hackathon was amazing.',
        createdAt: DateTime.now().subtract(const Duration(hours: 7)),
      ),
      Comment(
        id: 'c5',
        author: const User(id: 'u2', name: 'Nusrat Jahan', department: 'ICT', batch: 'Batch 2022'),
        content: 'Will the robotics competition be open to all departments?',
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      ),
    ],
    'p4': [],
    'p5': [],
    'p6': [],
  };

  // ─── Notifications ────────────────────────────────────────────────────────
  late final List<NotificationItem> _notifications = [
    NotificationItem(
      id: 'n1',
      type: NotificationType.like,
      actorName: 'Karim Hossain',
      message: 'Karim Hossain liked your post',
      time: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
    NotificationItem(
      id: 'n2',
      type: NotificationType.comment,
      actorName: 'Nusrat Jahan',
      message: 'Nusrat Jahan commented on your post: "Great work!"',
      time: DateTime.now().subtract(const Duration(minutes: 25)),
    ),
    NotificationItem(
      id: 'n3',
      type: NotificationType.follow,
      actorName: 'Sumaiya Akter',
      message: 'Sumaiya Akter started following you',
      time: DateTime.now().subtract(const Duration(hours: 3)),
      isRead: true,
    ),
    NotificationItem(
      id: 'n4',
      type: NotificationType.announcement,
      actorName: 'CSTU Admin',
      message: 'New university announcement: Mid-term exam schedule released',
      time: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
    ),
    NotificationItem(
      id: 'n5',
      type: NotificationType.event,
      actorName: 'CSTU Tech Fest',
      message: 'CSTU Tech Fest 2026 registration is now open!',
      time: DateTime.now().subtract(const Duration(days: 2)),
      isRead: true,
    ),
    NotificationItem(
      id: 'n6',
      type: NotificationType.club,
      actorName: 'CSE Club',
      message: 'You have been invited to join the CSE Programming Club',
      time: DateTime.now().subtract(const Duration(days: 3)),
      isRead: true,
    ),
  ];

  // ─── Events ───────────────────────────────────────────────────────────────
  late final List<Event> _events = [
    Event(
      id: 'e1',
      title: 'CSTU Tech Fest 2026',
      description:
          'Annual technology festival featuring hackathon, robotics competition, project showcase, and seminars by industry experts.',
      date: DateTime.now().add(const Duration(days: 45)),
      location: 'CSTU Main Campus',
      organizer: 'CSE Department',
      attendeeCount: 312,
    ),
    Event(
      id: 'e2',
      title: 'Freshers\' Welcome Ceremony',
      description:
          'A warm welcome for the new batch of students. Meet seniors, faculty and explore what CSTU has to offer.',
      date: DateTime.now().add(const Duration(days: 7)),
      location: 'CSTU Auditorium',
      organizer: 'Student Affairs',
      attendeeCount: 480,
    ),
    Event(
      id: 'e3',
      title: 'Programming Contest — CodeStorm',
      description:
          'Inter-department competitive programming contest. Teams of up to 3 members. Problem set covers algorithms, data structures and math.',
      date: DateTime.now().add(const Duration(days: 14)),
      location: 'CSE Lab, Building C',
      organizer: 'CSTU Programming Club',
      attendeeCount: 96,
    ),
    Event(
      id: 'e4',
      title: 'Career Fair 2026',
      description:
          'Connect with top companies and startups. Submit your resume and attend on-spot interviews. Over 20 companies participating.',
      date: DateTime.now().add(const Duration(days: 60)),
      location: 'CSTU Convention Center',
      organizer: 'Career Services Office',
      attendeeCount: 620,
    ),
    Event(
      id: 'e5',
      title: 'Photography Workshop',
      description:
          'Learn the basics of photography — composition, lighting, editing. Bring your phone or DSLR. Certificate will be provided.',
      date: DateTime.now().add(const Duration(days: 10)),
      location: 'Media Room, Building B',
      organizer: 'CSTU Photography Club',
      attendeeCount: 45,
    ),
  ];

  // ─── Clubs ────────────────────────────────────────────────────────────────
  late final List<Club> _clubs = [
    Club(
      id: 'cl1',
      name: 'CSE Programming Club',
      description: 'A club for coding enthusiasts. We host contests, workshops and hackathons throughout the year.',
      category: 'Technology',
      memberCount: 180,
    ),
    Club(
      id: 'cl2',
      name: 'CSTU Robotics Club',
      description: 'Build and program robots. Participate in national and international robotics competitions.',
      category: 'Technology',
      memberCount: 72,
    ),
    Club(
      id: 'cl3',
      name: 'Photography Club',
      description: 'Capture moments and memories. Regular photo walks, workshops and exhibitions.',
      category: 'Arts & Culture',
      memberCount: 95,
    ),
    Club(
      id: 'cl4',
      name: 'Business & Innovation Club',
      description: 'For aspiring entrepreneurs. Networking events, business plan competitions and mentorship programs.',
      category: 'Business',
      memberCount: 130,
    ),
    Club(
      id: 'cl5',
      name: 'Debating Society',
      description: 'Sharpen your critical thinking and public speaking skills through regular debates and competitions.',
      category: 'Academic',
      memberCount: 60,
    ),
    Club(
      id: 'cl6',
      name: 'Sports Club',
      description: 'Football, cricket, badminton and more. Join inter-department tournaments and stay fit.',
      category: 'Sports',
      memberCount: 220,
    ),
  ];

  // ─── Lost & Found Items ───────────────────────────────────────────────────
  late final List<LostFoundItem> _lostFoundItems = [
    LostFoundItem(
      id: 'lf1',
      title: 'Blue Notebook',
      description: 'Blue spiral notebook with "Nusrat" written on the cover. Lost near the cafeteria or ICT building.',
      isLost: true,
      location: 'Cafeteria / ICT Building',
      reporterName: 'Nusrat Jahan',
      reportedAt: DateTime.now().subtract(const Duration(hours: 18)),
    ),
    LostFoundItem(
      id: 'lf2',
      title: 'Black Umbrella',
      description: 'Found a black umbrella near the library entrance. Please contact to claim.',
      isLost: false,
      location: 'Library Entrance',
      reporterName: 'Karim Hossain',
      reportedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    LostFoundItem(
      id: 'lf3',
      title: 'Student ID Card',
      description: 'Lost my student ID card. Name: Arif Rahman, ID: 2022-CSE-045. Please return to me or admin office.',
      isLost: true,
      location: 'Unknown',
      reporterName: 'Arif Rahman',
      reportedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    LostFoundItem(
      id: 'lf4',
      title: 'Earphones',
      description: 'Found white earphones in the CSE classroom 301. Left them at the department office.',
      isLost: false,
      location: 'CSE Classroom 301',
      reporterName: 'Sumaiya Akter',
      reportedAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  // ─── Public API ───────────────────────────────────────────────────────────

  List<Post> getPosts() => List.unmodifiable(_posts);

  List<NotificationItem> getNotifications() => List.unmodifiable(_notifications);

  List<Event> getEvents() => List.unmodifiable(_events);

  List<Club> getClubs() => List.unmodifiable(_clubs);

  List<LostFoundItem> getLostFoundItems() => List.unmodifiable(_lostFoundItems);

  List<Comment> getComments(String postId) => _comments[postId] ?? [];

  void toggleLike(String postId) {
    final post = _posts.firstWhere((p) => p.id == postId);
    if (post.isLiked) {
      post.isLiked = false;
      post.likeCount--;
    } else {
      post.isLiked = true;
      post.likeCount++;
    }
  }

  void toggleClubMembership(String clubId) {
    final club = _clubs.firstWhere((c) => c.id == clubId);
    if (club.isJoined) {
      club.isJoined = false;
      club.memberCount--;
    } else {
      club.isJoined = true;
      club.memberCount++;
    }
  }

  void toggleEventRegistration(String eventId) {
    final event = _events.firstWhere((e) => e.id == eventId);
    if (event.isRegistered) {
      event.isRegistered = false;
      event.attendeeCount--;
    } else {
      event.isRegistered = true;
      event.attendeeCount++;
    }
  }

  void markNotificationRead(String notificationId) {
    final n = _notifications.firstWhere((n) => n.id == notificationId);
    n.isRead = true;
  }

  void markAllNotificationsRead() {
    for (final n in _notifications) {
      n.isRead = true;
    }
  }

  void addComment(String postId, String content) {
    final comment = Comment(
      id: 'c_${DateTime.now().millisecondsSinceEpoch}',
      author: currentUser,
      content: content,
      createdAt: DateTime.now(),
    );
    _comments.putIfAbsent(postId, () => []).add(comment);
    final post = _posts.firstWhere((p) => p.id == postId);
    post.commentCount++;
  }

  void createPost(String content, PostType type, String visibility) {
    final post = Post(
      id: 'p_${DateTime.now().millisecondsSinceEpoch}',
      author: currentUser,
      content: content,
      postType: type,
      likeCount: 0,
      commentCount: 0,
      createdAt: DateTime.now(),
    );
    _posts.insert(0, post);
    currentUser = currentUser.copyWith(postCount: currentUser.postCount + 1);
  }

  void addLostFoundItem(String title, String description, bool isLost, String location) {
    final item = LostFoundItem(
      id: 'lf_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      description: description,
      isLost: isLost,
      location: location,
      reporterName: currentUser.name,
      reportedAt: DateTime.now(),
    );
    _lostFoundItems.insert(0, item);
  }

  void updateCurrentUser({String? name, String? bio}) {
    currentUser = currentUser.copyWith(
      name: name,
      bio: bio,
    );
  }

  int get unreadNotificationCount =>
      _notifications.where((n) => !n.isRead).length;
}
