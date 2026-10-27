import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cstu_connect/main.dart';
import 'package:cstu_connect/models/user_model.dart';
import 'package:cstu_connect/models/post_model.dart';
import 'package:cstu_connect/models/event_model.dart';
import 'package:cstu_connect/models/lost_found_model.dart';
import 'package:cstu_connect/theme/app_theme.dart';
import 'package:cstu_connect/services/firestore_service.dart';
import 'package:provider/provider.dart';

void main() {
  group('CSTU Connect Core Model Tests', () {
    test('User model serializes and retains studentId, email, and verification', () {
      final user = User(
        id: 'user_1',
        name: 'Mahir Faysal',
        department: 'Computer Science & Engineering',
        batch: 'Batch 2022',
        studentId: '2022-CSE-042',
        email: 'mahir.cse@student.cstu.ac.bd',
        isVerified: true,
      );

      final map = user.toMap();
      expect(map['studentId'], '2022-CSE-042');
      expect(map['email'], 'mahir.cse@student.cstu.ac.bd');
      expect(map['isVerified'], true);

      final revived = User.fromMap(map, 'user_1');
      expect(revived.id, 'user_1');
      expect(revived.name, 'Mahir Faysal');
      expect(revived.studentId, '2022-CSE-042');
      expect(revived.email, 'mahir.cse@student.cstu.ac.bd');
      expect(revived.isVerified, true);
    });

    test('Post model retains post types and image URLs', () {
      final author = User(
        id: 'u1',
        name: 'Ayesha Rahman',
        department: 'ICT',
        batch: 'Batch 2021',
        studentId: '2021-ICT-008',
      );

      final post = Post(
        id: 'p1',
        author: author,
        content: 'Campus Robotics Fest 2026 is announced!',
        createdAt: DateTime.now(),
        postType: PostType.announcement,
        likeCount: 15,
        commentCount: 3,
        imageUrl: 'https://images.unsplash.com/photo-cstu-fest',
      );

      expect(post.postType, PostType.announcement);
      expect(post.imageUrl, isNotNull);
      expect(post.isLiked, false);
      expect(post.likeCount, 15);
      expect(post.commentCount, 3);
    });

    test('Event model holds registration and category attributes', () {
      final event = Event(
        id: 'e1',
        title: 'CSTU Annual Hackathon 2026',
        description: 'Code the future by the Meghna River',
        date: DateTime.now().add(const Duration(days: 7)),
        location: 'Auditorium Hall 1',
        organizer: 'CSTU Computer Club',
        category: 'Hackathon',
        attendeeCount: 85,
      );

      expect(event.category, 'Hackathon');
      expect(event.registeredCount, 85);
      expect(event.isRegistered, false);
    });

    test('Lost and Found item status helpers work accurately', () {
      final item = LostFoundItem(
        id: 'lf1',
        title: 'Scientific Calculator fx-991EX',
        description: 'Left in Room 304 after math lecture',
        location: 'Academic Building 2, Room 304',
        isLost: true,
        reporterName: 'Tanvir Hossain',
        reportedAt: DateTime.now(),
      );

      expect(item.isLost, true);
      expect(item.title, 'Scientific Calculator fx-991EX');
    });
  });

  group('CSTU Connect App & Theme Integration Tests', () {
    test('AppTheme official colors are defined', () {
      expect(AppTheme.cstuGold, const Color(0xFFEAA22E));
      expect(AppTheme.cstuSlate, const Color(0xFF6E7175));
      expect(AppTheme.cstuDark, const Color(0xFF18181B));
      expect(AppTheme.cstuRiverCyan, const Color(0xFF0284C7));
    });

    testWidgets('App renders main navigation and quad feed gracefully', (tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: FirestoreService.instance,
          child: const CSTUConnectApp(),
        ),
      );

      await tester.pump();
      expect(find.text('CSTU Connect'), findsWidgets);
    });
  });
}
