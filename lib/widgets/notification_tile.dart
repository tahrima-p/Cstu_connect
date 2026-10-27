import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../theme/app_theme.dart';

class NotificationTile extends StatelessWidget {
  final NotificationItem notification;
  final VoidCallback? onTap;

  const NotificationTile({
    super.key,
    required this.notification,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: notification.isRead ? Colors.white : AppTheme.cstuGoldLight.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: notification.isRead
              ? AppTheme.borderLight
              : AppTheme.cstuGoldBorder,
          width: notification.isRead ? 1.0 : 1.4,
        ),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: notification.backgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              notification.icon,
              size: 20,
              color: notification.iconColor,
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  notification.message,
                  style: TextStyle(
                    fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w800,
                    fontSize: 14,
                    color: AppTheme.cstuDark,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              if (!notification.isRead)
                Container(
                  width: 9,
                  height: 9,
                  decoration: const BoxDecoration(
                    color: AppTheme.cstuGold,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              notification.timeAgo,
              style: const TextStyle(fontSize: 12, color: AppTheme.cstuSlate),
            ),
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
