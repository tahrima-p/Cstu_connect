import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../theme/app_theme.dart';

/// Displays a colored circle avatar with the user's initials or avatar image.
class UserAvatar extends StatelessWidget {
  final User user;
  final double radius;

  const UserAvatar({super.key, required this.user, this.radius = 22});

  Color get _bg {
    final colors = [
      const Color(0xFFFFF3DF),
      const Color(0xFFE8F4FE),
      const Color(0xFFEAF8ED),
      const Color(0xFFFDEBF4),
      const Color(0xFFF1ECFE),
    ];
    return colors[user.id.hashCode.abs() % colors.length];
  }

  Color get _fg {
    final colors = [
      AppTheme.cstuGold,
      const Color(0xFF0277BD),
      const Color(0xFF2E7D32),
      const Color(0xFFC2185B),
      const Color(0xFF6A1B9A),
    ];
    return colors[user.id.hashCode.abs() % colors.length];
  }

  String get _initials {
    final parts = user.name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppTheme.cstuGold.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: _bg,
        backgroundImage: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
            ? NetworkImage(user.avatarUrl!)
            : null,
        child: user.avatarUrl == null || user.avatarUrl!.isEmpty
            ? Text(
                _initials,
                style: TextStyle(
                  color: _fg,
                  fontWeight: FontWeight.bold,
                  fontSize: radius * 0.72,
                ),
              )
            : null,
      ),
    );
  }
}
