import 'package:flutter/material.dart';

enum NotificationType { like, comment, follow, announcement, event, club }

class NotificationItem {
  final String id;
  final NotificationType type;
  final String actorName;
  final String message;
  final DateTime time;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.type,
    required this.actorName,
    required this.message,
    required this.time,
    this.isRead = false,
  });

  IconData get icon {
    switch (type) {
      case NotificationType.like:
        return Icons.favorite;
      case NotificationType.comment:
        return Icons.comment;
      case NotificationType.follow:
        return Icons.person_add;
      case NotificationType.announcement:
        return Icons.campaign;
      case NotificationType.event:
        return Icons.event;
      case NotificationType.club:
        return Icons.group;
    }
  }

  Color get iconColor {
    switch (type) {
      case NotificationType.like:
        return Colors.red;
      case NotificationType.comment:
        return Colors.blue;
      case NotificationType.follow:
        return Colors.teal;
      case NotificationType.announcement:
        return const Color(0xFFE69A2E);
      case NotificationType.event:
        return Colors.green;
      case NotificationType.club:
        return Colors.purple;
    }
  }

  Color get backgroundColor {
    switch (type) {
      case NotificationType.like:
        return const Color(0xFFFFEEEE);
      case NotificationType.comment:
        return const Color(0xFFEEF5FF);
      case NotificationType.follow:
        return const Color(0xFFE0F7F4);
      case NotificationType.announcement:
        return const Color(0xFFFFF3DF);
      case NotificationType.event:
        return const Color(0xFFEEF9F0);
      case NotificationType.club:
        return const Color(0xFFF5EEFF);
    }
  }

  String get timeAgo {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays}d ago';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'actorName': actorName,
      'message': message,
      'time': time.toIso8601String(),
      'isRead': isRead,
    };
  }

  factory NotificationItem.fromMap(Map<String, dynamic> map, [String? docId]) {
    return NotificationItem(
      id: docId ?? map['id'] ?? '',
      type: NotificationType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => NotificationType.announcement,
      ),
      actorName: map['actorName'] ?? '',
      message: map['message'] ?? '',
      time: map['time'] != null
          ? DateTime.tryParse(map['time'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isRead: map['isRead'] ?? false,
    );
  }
}
