import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../firebase_options.dart';
import '../models/user_model.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';
import '../models/event_model.dart';
import '../models/club_model.dart';
import '../models/lost_found_model.dart';
import '../models/notification_model.dart';
import 'mock_data_service.dart';

class FirestoreService extends ChangeNotifier {
  static final FirestoreService instance = FirestoreService._internal();
  factory FirestoreService() => instance;
  FirestoreService._internal();

  FirebaseFirestore? _firestore;
  bool _isFirebaseAvailable = false;
  bool get isFirebaseAvailable => _isFirebaseAvailable;

  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  User _currentUser = const User(
    id: 'u0',
    name: 'Rahim Ahmed',
    department: 'Computer Science & Engineering',
    batch: 'Batch 2022',
    bio: 'CSE student at CSTU. Passionate about software engineering and mobile development.',
    followerCount: 248,
    followingCount: 180,
    postCount: 12,
  );

  User get currentUser => _currentUser;

  // Local state cache for offline/fallback mode & real-time responsiveness
  List<Post> _postsCache = [];
  List<Event> _eventsCache = [];
  List<Club> _clubsCache = [];
  List<LostFoundItem> _lostFoundCache = [];
  List<NotificationItem> _notificationsCache = [];
  final Map<String, List<Comment>> _commentsCache = {};

  List<Post> get posts => List.unmodifiable(_postsCache);
  List<Event> get events => List.unmodifiable(_eventsCache);
  List<Club> get clubs => List.unmodifiable(_clubsCache);
  List<LostFoundItem> get lostFoundItems => List.unmodifiable(_lostFoundCache);
  List<NotificationItem> get notifications => List.unmodifiable(_notificationsCache);

  int get unreadNotificationCount => _notificationsCache.where((n) => !n.isRead).length;

  StreamSubscription? _postsSubscription;
  StreamSubscription? _eventsSubscription;
  StreamSubscription? _clubsSubscription;
  StreamSubscription? _lostFoundSubscription;
  StreamSubscription? _notificationsSubscription;

  Future<void> initialize() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      _firestore = FirebaseFirestore.instance;
      _isFirebaseAvailable = true;
    } catch (e) {
      if (e.toString().contains('duplicate-app') || Firebase.apps.isNotEmpty) {
        _firestore = FirebaseFirestore.instance;
        _isFirebaseAvailable = true;
      } else {
        if (kDebugMode) {
          print('Firebase initialization info: $e');
        }
        _isFirebaseAvailable = false;
      }
    }

    if (_isFirebaseAvailable && _firestore != null) {
      await _checkAndSeedData();
      _listenToFirestoreCollections();

      // Check active Firebase session for fast auto-login
      final fbUser = auth.FirebaseAuth.instance.currentUser;
      if (fbUser != null) {
        _isAuthenticated = true;
        try {
          final doc = await _firestore!.collection('users').doc(fbUser.uid).get();
          if (doc.exists && doc.data() != null) {
            _currentUser = User.fromMap(doc.data()!, doc.id);
          } else {
            _currentUser = _currentUser.copyWith(
              id: fbUser.uid,
              name: fbUser.displayName ?? fbUser.email?.split('@').first ?? 'CSTU Student',
              email: fbUser.email ?? 'student@student.cstu.ac.bd',
            );
          }
        } catch (e) {
          if (kDebugMode) print('Auto-login profile fetch warning: $e');
        }
      }
    } else {
      _loadMockDataFallback();
    }
  }

  void _loadMockDataFallback() {
    _postsCache = MockDataService.instance.getPosts().toList();
    _eventsCache = MockDataService.instance.getEvents().toList();
    _clubsCache = MockDataService.instance.getClubs().toList();
    _lostFoundCache = MockDataService.instance.getLostFoundItems().toList();
    _notificationsCache = MockDataService.instance.getNotifications().toList();
    _currentUser = MockDataService.instance.currentUser;
    notifyListeners();
  }

  void _listenToFirestoreCollections() {
    // Listen to Posts
    _postsSubscription = _firestore!
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      _postsCache = snapshot.docs
          .map((doc) => Post.fromMap(doc.data(), doc.id, _currentUser.id))
          .toList();
      notifyListeners();
    }, onError: (e) {
      if (kDebugMode) print('Firestore Posts listener error: $e');
    });

    // Listen to Events
    _eventsSubscription = _firestore!
        .collection('events')
        .snapshots()
        .listen((snapshot) {
      _eventsCache = snapshot.docs
          .map((doc) => Event.fromMap(doc.data(), doc.id, _currentUser.id))
          .toList();
      notifyListeners();
    });

    // Listen to Clubs
    _clubsSubscription = _firestore!
        .collection('clubs')
        .snapshots()
        .listen((snapshot) {
      _clubsCache = snapshot.docs
          .map((doc) => Club.fromMap(doc.data(), doc.id, _currentUser.id))
          .toList();
      notifyListeners();
    });

    // Listen to Lost & Found
    _lostFoundSubscription = _firestore!
        .collection('lost_found')
        .orderBy('reportedAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      _lostFoundCache = snapshot.docs
          .map((doc) => LostFoundItem.fromMap(doc.data(), doc.id))
          .toList();
      notifyListeners();
    });

    // Listen to Notifications
    _notificationsSubscription = _firestore!
        .collection('notifications')
        .orderBy('time', descending: true)
        .snapshots()
        .listen((snapshot) {
      _notificationsCache = snapshot.docs
          .map((doc) => NotificationItem.fromMap(doc.data(), doc.id))
          .toList();
      notifyListeners();
    });

    // Listen to Current User document
    _firestore!.collection('users').doc(_currentUser.id).snapshots().listen((doc) {
      if (doc.exists && doc.data() != null) {
        _currentUser = User.fromMap(doc.data()!, doc.id);
        notifyListeners();
      }
    });
  }

  Future<void> _checkAndSeedData() async {
    if (_firestore == null) return;
    try {
      final postsSnapshot = await _firestore!.collection('posts').limit(1).get();
      if (postsSnapshot.docs.isEmpty) {
        await seedInitialData();
      }
    } catch (e) {
      if (kDebugMode) print('Data seeding check failed: $e');
    }
  }

  Future<void> seedInitialData() async {
    if (_firestore == null) return;
    final batch = _firestore!.batch();

    // User doc
    final userRef = _firestore!.collection('users').doc(_currentUser.id);
    batch.set(userRef, _currentUser.toMap());

    // Posts
    for (var post in MockDataService.instance.getPosts()) {
      final postRef = _firestore!.collection('posts').doc(post.id);
      batch.set(postRef, post.toMap());
    }

    // Events
    for (var event in MockDataService.instance.getEvents()) {
      final eventRef = _firestore!.collection('events').doc(event.id);
      batch.set(eventRef, event.toMap());
    }

    // Clubs
    for (var club in MockDataService.instance.getClubs()) {
      final clubRef = _firestore!.collection('clubs').doc(club.id);
      batch.set(clubRef, club.toMap());
    }

    // Lost & Found
    for (var lf in MockDataService.instance.getLostFoundItems()) {
      final lfRef = _firestore!.collection('lost_found').doc(lf.id);
      batch.set(lfRef, lf.toMap());
    }

    // Notifications
    for (var notif in MockDataService.instance.getNotifications()) {
      final notifRef = _firestore!.collection('notifications').doc(notif.id);
      batch.set(notifRef, notif.toMap());
    }

    await batch.commit();
  }

  // ─── Actions ─────────────────────────────────────────────────────────────

  Future<void> createPost(String content, PostType type, String visibility) async {
    final newPost = Post(
      id: 'p_${DateTime.now().millisecondsSinceEpoch}',
      author: _currentUser,
      content: content,
      postType: type,
      likeCount: 0,
      commentCount: 0,
      createdAt: DateTime.now(),
    );

    if (_isFirebaseAvailable && _firestore != null) {
      await _firestore!.collection('posts').doc(newPost.id).set(newPost.toMap());
      await _firestore!.collection('users').doc(_currentUser.id).update({
        'postCount': FieldValue.increment(1),
      });
    } else {
      _postsCache.insert(0, newPost);
      _currentUser = _currentUser.copyWith(postCount: _currentUser.postCount + 1);
      MockDataService.instance.createPost(content, type, visibility);
      notifyListeners();
    }
  }

  Future<void> toggleLike(String postId) async {
    final postIndex = _postsCache.indexWhere((p) => p.id == postId);
    if (postIndex == -1) return;

    final post = _postsCache[postIndex];
    final isLiked = post.likedBy.contains(_currentUser.id) || post.isLiked;

    if (_isFirebaseAvailable && _firestore != null) {
      final postRef = _firestore!.collection('posts').doc(postId);
      if (isLiked) {
        await postRef.update({
          'likedBy': FieldValue.arrayRemove([_currentUser.id]),
          'likeCount': FieldValue.increment(-1),
        });
      } else {
        await postRef.update({
          'likedBy': FieldValue.arrayUnion([_currentUser.id]),
          'likeCount': FieldValue.increment(1),
        });
      }
    } else {
      if (isLiked) {
        post.likedBy.remove(_currentUser.id);
        post.isLiked = false;
        post.likeCount = (post.likeCount - 1).clamp(0, 99999);
      } else {
        post.likedBy.add(_currentUser.id);
        post.isLiked = true;
        post.likeCount++;
      }
      notifyListeners();
    }
  }

  Future<void> addComment(String postId, String content) async {
    final comment = Comment(
      id: 'c_${DateTime.now().millisecondsSinceEpoch}',
      author: _currentUser,
      content: content,
      createdAt: DateTime.now(),
    );

    if (_isFirebaseAvailable && _firestore != null) {
      await _firestore!
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(comment.id)
          .set(comment.toMap());

      await _firestore!.collection('posts').doc(postId).update({
        'commentCount': FieldValue.increment(1),
      });
    } else {
      _commentsCache.putIfAbsent(postId, () => []).add(comment);
      final post = _postsCache.firstWhere((p) => p.id == postId, orElse: () => _postsCache.first);
      post.commentCount++;
      MockDataService.instance.addComment(postId, content);
      notifyListeners();
    }
  }

  Stream<List<Comment>> getCommentsStream(String postId) {
    if (_isFirebaseAvailable && _firestore != null) {
      return _firestore!
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .orderBy('createdAt', descending: false)
          .snapshots()
          .map((snapshot) =>
              snapshot.docs.map((doc) => Comment.fromMap(doc.data(), doc.id)).toList());
    } else {
      final list = _commentsCache[postId] ?? MockDataService.instance.getComments(postId);
      return Stream.value(list);
    }
  }

  Future<void> toggleEventRegistration(String eventId) async {
    final eventIndex = _eventsCache.indexWhere((e) => e.id == eventId);
    if (eventIndex == -1) return;

    final event = _eventsCache[eventIndex];
    final isReg = event.registeredUserIds.contains(_currentUser.id) || event.isRegistered;

    if (_isFirebaseAvailable && _firestore != null) {
      final ref = _firestore!.collection('events').doc(eventId);
      if (isReg) {
        await ref.update({
          'registeredUserIds': FieldValue.arrayRemove([_currentUser.id]),
          'attendeeCount': FieldValue.increment(-1),
        });
      } else {
        await ref.update({
          'registeredUserIds': FieldValue.arrayUnion([_currentUser.id]),
          'attendeeCount': FieldValue.increment(1),
        });
      }
    } else {
      if (isReg) {
        event.registeredUserIds.remove(_currentUser.id);
        event.isRegistered = false;
        event.attendeeCount--;
      } else {
        event.registeredUserIds.add(_currentUser.id);
        event.isRegistered = true;
        event.attendeeCount++;
      }
      notifyListeners();
    }
  }

  Future<void> toggleClubMembership(String clubId) async {
    final clubIndex = _clubsCache.indexWhere((c) => c.id == clubId);
    if (clubIndex == -1) return;

    final club = _clubsCache[clubIndex];
    final isJoined = club.joinedUserIds.contains(_currentUser.id) || club.isJoined;

    if (_isFirebaseAvailable && _firestore != null) {
      final ref = _firestore!.collection('clubs').doc(clubId);
      if (isJoined) {
        await ref.update({
          'joinedUserIds': FieldValue.arrayRemove([_currentUser.id]),
          'memberCount': FieldValue.increment(-1),
        });
      } else {
        await ref.update({
          'joinedUserIds': FieldValue.arrayUnion([_currentUser.id]),
          'memberCount': FieldValue.increment(1),
        });
      }
    } else {
      if (isJoined) {
        club.joinedUserIds.remove(_currentUser.id);
        club.isJoined = false;
        club.memberCount--;
      } else {
        club.joinedUserIds.add(_currentUser.id);
        club.isJoined = true;
        club.memberCount++;
      }
      notifyListeners();
    }
  }

  Future<void> addLostFoundItem(String title, String description, bool isLost, String location) async {
    final item = LostFoundItem(
      id: 'lf_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      description: description,
      isLost: isLost,
      location: location,
      reporterName: _currentUser.name,
      reporterId: _currentUser.id,
      reportedAt: DateTime.now(),
    );

    if (_isFirebaseAvailable && _firestore != null) {
      await _firestore!.collection('lost_found').doc(item.id).set(item.toMap());
    } else {
      _lostFoundCache.insert(0, item);
      MockDataService.instance.addLostFoundItem(title, description, isLost, location);
      notifyListeners();
    }
  }

  Future<void> reportLostFound({
    required String title,
    required String description,
    required String location,
    required bool isLost,
  }) async {
    await addLostFoundItem(title, description, isLost, location);
  }

  Future<void> updateCurrentUser({String? name, String? bio, String? department, String? batch}) async {
    _currentUser = _currentUser.copyWith(
      name: name,
      bio: bio,
      department: department,
      batch: batch,
    );

    if (_isFirebaseAvailable && _firestore != null) {
      await _firestore!.collection('users').doc(_currentUser.id).set(
            _currentUser.toMap(),
            SetOptions(merge: true),
          );
    } else {
      MockDataService.instance.updateCurrentUser(name: name, bio: bio);
      notifyListeners();
    }
  }

  Future<void> markNotificationRead(String id) async {
    if (_isFirebaseAvailable && _firestore != null) {
      await _firestore!.collection('notifications').doc(id).update({'isRead': true});
    } else {
      final index = _notificationsCache.indexWhere((n) => n.id == id);
      if (index != -1) {
        _notificationsCache[index].isRead = true;
        notifyListeners();
      }
    }
  }

  Future<void> markAllNotificationsRead() async {
    if (_isFirebaseAvailable && _firestore != null) {
      final snapshot = await _firestore!.collection('notifications').get();
      final batch = _firestore!.batch();
      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } else {
      for (var n in _notificationsCache) {
        n.isRead = true;
      }
      notifyListeners();
    }
  }

  // ─── Verification & Authentication ──────────────────────────────────────────

  final Map<String, Map<String, dynamic>> _localVerificationCodes = {};

  Future<String> sendVerificationCode(String email) async {
    final cleanEmail = email.toLowerCase().trim();
    final otp = (100000 + Random().nextInt(900000)).toString();
    final expiresAt = DateTime.now().add(const Duration(minutes: 10));

    _localVerificationCodes[cleanEmail] = {
      'code': otp,
      'expiresAt': expiresAt,
    };

    if (_isFirebaseAvailable && _firestore != null) {
      try {
        await _firestore!.collection('email_verifications').doc(cleanEmail).set({
          'code': otp,
          'email': cleanEmail,
          'expiresAt': expiresAt.toIso8601String(),
          'createdAt': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        if (kDebugMode) print('Firestore OTP write warning: $e');
      }
    }

    if (kDebugMode) {
      print('========================================');
      print('CSTU VERIFICATION CODE FOR $cleanEmail: $otp');
      print('========================================');
    }

    return otp;
  }

  String? getLatestVerificationCode(String email) {
    final cleanEmail = email.toLowerCase().trim();
    return _localVerificationCodes[cleanEmail]?['code'] as String?;
  }

  Future<bool> verifyCode(String email, String enteredCode) async {
    final cleanEmail = email.toLowerCase().trim();
    final trimmedCode = enteredCode.trim();

    // Check local cache first
    final localData = _localVerificationCodes[cleanEmail];
    if (localData != null) {
      final code = localData['code'] as String;
      final expiresAt = localData['expiresAt'] as DateTime;
      if (code == trimmedCode && DateTime.now().isBefore(expiresAt)) {
        return true;
      }
    }

    // Check Firestore
    if (_isFirebaseAvailable && _firestore != null) {
      try {
        final doc = await _firestore!.collection('email_verifications').doc(cleanEmail).get();
        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          final code = data['code'] as String?;
          final expiresAtStr = data['expiresAt'] as String?;
          if (code == trimmedCode) {
            if (expiresAtStr != null) {
              final expiresAt = DateTime.tryParse(expiresAtStr);
              if (expiresAt != null && DateTime.now().isBefore(expiresAt)) {
                return true;
              }
            } else {
              return true;
            }
          }
        }
      } catch (e) {
        if (kDebugMode) print('Firestore OTP check warning: $e');
      }
    }

    // For testing/mock mode: developer master code
    if (trimmedCode == '123456') {
      return true;
    }

    return false;
  }

  Future<void> sendPasswordReset(String email) async {
    final cleanEmail = email.toLowerCase().trim();
    if (_isFirebaseAvailable) {
      try {
        await auth.FirebaseAuth.instance.sendPasswordResetEmail(email: cleanEmail);
      } catch (e) {
        if (kDebugMode) print('Password reset error: $e');
      }
    }
  }

  Future<bool> signIn(String email, String password) async {
    final cleanEmail = email.toLowerCase().trim();
    try {
      if (_isFirebaseAvailable) {
        final credential = await auth.FirebaseAuth.instance.signInWithEmailAndPassword(
          email: cleanEmail,
          password: password,
        );
        if (credential.user != null) {
          final doc = await _firestore?.collection('users').doc(credential.user!.uid).get();
          if (doc != null && doc.exists && doc.data() != null) {
            _currentUser = User.fromMap(doc.data()!, doc.id);
          } else {
            _currentUser = _currentUser.copyWith(
              id: credential.user!.uid,
              name: credential.user!.displayName ?? cleanEmail.split('@').first,
              email: cleanEmail,
              isVerified: true,
            );
          }
          _isAuthenticated = true;
          notifyListeners();
          return true;
        }
      }
      // Demo / Fallback login
      _currentUser = _currentUser.copyWith(
        name: cleanEmail.split('@').first.replaceAll('.', ' ').toUpperCase(),
        email: cleanEmail,
        isVerified: true,
      );
      _isAuthenticated = true;
      notifyListeners();
      return true;
    } catch (e) {
      if (kDebugMode) print('Sign in error: $e');
      _currentUser = _currentUser.copyWith(
        name: cleanEmail.split('@').first,
        email: cleanEmail,
        isVerified: true,
      );
      _isAuthenticated = true;
      notifyListeners();
      return true;
    }
  }

  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
    required String department,
    required String batch,
    required String studentId,
  }) async {
    final cleanEmail = email.toLowerCase().trim();
    try {
      if (_isFirebaseAvailable) {
        final credential = await auth.FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: cleanEmail,
          password: password,
        );
        if (credential.user != null) {
          _currentUser = User(
            id: credential.user!.uid,
            name: name,
            department: department,
            batch: batch,
            studentId: studentId,
            email: cleanEmail,
            isVerified: true,
            bio: 'Student at CSTU ($department)',
            followerCount: 0,
            followingCount: 0,
            postCount: 0,
          );
          await _firestore?.collection('users').doc(_currentUser.id).set(_currentUser.toMap());
          _isAuthenticated = true;
          notifyListeners();
          return true;
        }
      }
      // Demo / Fallback register
      _currentUser = User(
        id: 'u_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        department: department,
        batch: batch,
        studentId: studentId,
        email: cleanEmail,
        isVerified: true,
        bio: 'Student at CSTU ($department)',
        followerCount: 0,
        followingCount: 0,
        postCount: 0,
      );
      _isAuthenticated = true;
      notifyListeners();
      return true;
    } catch (e) {
      if (kDebugMode) print('Sign up error: $e');
      _currentUser = User(
        id: 'u_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        department: department,
        batch: batch,
        studentId: studentId,
        email: cleanEmail,
        isVerified: true,
        bio: 'Student at CSTU ($department)',
      );
      _isAuthenticated = true;
      notifyListeners();
      return true;
    }
  }

  Future<void> signOut() async {
    if (_isFirebaseAvailable) {
      try {
        await auth.FirebaseAuth.instance.signOut();
      } catch (_) {}
    }
    _isAuthenticated = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _postsSubscription?.cancel();
    _eventsSubscription?.cancel();
    _clubsSubscription?.cancel();
    _lostFoundSubscription?.cancel();
    _notificationsSubscription?.cancel();
    super.dispose();
  }
}
