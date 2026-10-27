import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';
import '../widgets/notification_tile.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  String _selectedFilter = 'All';

  final List<String> _filters = ['All', 'Unread', 'Announcements', 'Activity'];

  @override
  Widget build(BuildContext context) {
    final firestoreService = context.watch<FirestoreService>();
    final allNotifications = firestoreService.notifications;

    final filtered = allNotifications.where((n) {
      if (_selectedFilter == 'All') return true;
      if (_selectedFilter == 'Unread') return !n.isRead;
      if (_selectedFilter == 'Announcements') {
        return n.message.toLowerCase().contains('notice') ||
            n.message.toLowerCase().contains('announcement');
      }
      return true;
    }).toList();

    final today = filtered
        .where((n) => DateTime.now().difference(n.time).inHours < 24)
        .toList();
    final earlier = filtered
        .where((n) => DateTime.now().difference(n.time).inHours >= 24)
        .toList();

    final hasUnread = allNotifications.any((n) => !n.isRead);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: const Row(
          children: [
            Icon(Icons.notifications_rounded, color: AppTheme.cstuGold, size: 24),
            SizedBox(width: 8),
            Text(
              'Alerts & Notices',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 20,
                color: AppTheme.cstuDark,
                letterSpacing: -0.4,
              ),
            ),
          ],
        ),
        actions: [
          if (hasUnread)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  firestoreService.markAllNotificationsRead();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('All alerts marked as read'),
                      backgroundColor: AppTheme.cstuDark,
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.done_all_rounded, size: 16, color: AppTheme.cstuGold),
                label: const Text(
                  'Mark all read',
                  style: TextStyle(
                    color: AppTheme.cstuGold,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SizedBox(
              height: 34,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _filters.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final filter = _filters[index];
                  final isSelected = _selectedFilter == filter;
                  return ChoiceChip(
                    label: Text(filter),
                    selected: isSelected,
                    showCheckmark: false,
                    selectedColor: AppTheme.cstuGold,
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected ? Colors.white : AppTheme.cstuDark,
                    ),
                    side: BorderSide(
                      color: isSelected ? AppTheme.cstuGold : AppTheme.borderLight,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    onSelected: (val) {
                      if (val) {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedFilter = filter);
                      }
                    },
                  );
                },
              ),
            ),
          ),

          // Notification List
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppTheme.cstuGoldLight,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppTheme.cstuGoldBorder),
                          ),
                          child: const Icon(
                            Icons.notifications_none_rounded,
                            size: 40,
                            color: AppTheme.cstuGold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "You're all caught up! 🎉",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.cstuDark,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'No new campus alerts or notifications.',
                          style: TextStyle(fontSize: 13, color: AppTheme.cstuSlate),
                        ),
                      ],
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 90),
                    children: [
                      if (today.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.only(left: 4, bottom: 8),
                          child: Text(
                            'TODAY',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.cstuSlate,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        ...today.map((n) => NotificationTile(
                              notification: n,
                              onTap: () {
                                HapticFeedback.selectionClick();
                                firestoreService.markNotificationRead(n.id);
                              },
                            )),
                      ],
                      if (earlier.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        const Padding(
                          padding: EdgeInsets.only(left: 4, bottom: 8),
                          child: Text(
                            'EARLIER',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.cstuSlate,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        ...earlier.map((n) => NotificationTile(
                              notification: n,
                              onTap: () {
                                HapticFeedback.selectionClick();
                                firestoreService.markNotificationRead(n.id);
                              },
                            )),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
