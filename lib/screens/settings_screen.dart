import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _postNotifications = true;
  bool _eventNotifications = true;
  bool _commentNotifications = true;
  bool _followNotifications = true;

  @override
  Widget build(BuildContext context) {
    final firestoreService = context.watch<FirestoreService>();
    final user = firestoreService.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
        children: [
          // Account Section Card
          _SettingsSection(
            title: 'ACCOUNT & IDENTITY',
            children: [
              _SettingsTile(
                icon: Icons.person_outline_rounded,
                title: 'Full Name',
                subtitle: user.name,
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.cstuSlate),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Edit your name and bio from the Profile tab'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              _SettingsDivider(),
              _SettingsTile(
                icon: Icons.alternate_email_rounded,
                title: 'CSTU Email',
                subtitle: user.email.isNotEmpty ? user.email : 'student@student.cstu.ac.bd',
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.cstuEmerald.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Verified',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.cstuEmerald,
                    ),
                  ),
                ),
                onTap: () {},
              ),
              _SettingsDivider(),
              _SettingsTile(
                icon: Icons.school_outlined,
                title: 'Department',
                subtitle: user.department,
                onTap: () {},
              ),
              _SettingsDivider(),
              _SettingsTile(
                icon: Icons.badge_outlined,
                title: 'Student ID',
                subtitle: user.studentId.isNotEmpty ? user.studentId : '2022-CSE-001',
                onTap: () {},
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Notifications Section Card
          _SettingsSection(
            title: 'NOTIFICATION PREFERENCES',
            children: [
              _SwitchTile(
                icon: Icons.article_outlined,
                title: 'Post Activity',
                subtitle: 'Likes, mentions and notices',
                value: _postNotifications,
                onChanged: (v) => setState(() => _postNotifications = v),
              ),
              _SettingsDivider(),
              _SwitchTile(
                icon: Icons.event_outlined,
                title: 'Campus Events',
                subtitle: 'RSVP updates, event reminders',
                value: _eventNotifications,
                onChanged: (v) => setState(() => _eventNotifications = v),
              ),
              _SettingsDivider(),
              _SwitchTile(
                icon: Icons.comment_outlined,
                title: 'Comments & Replies',
                subtitle: 'When classmates comment on your posts',
                value: _commentNotifications,
                onChanged: (v) => setState(() => _commentNotifications = v),
              ),
              _SettingsDivider(),
              _SwitchTile(
                icon: Icons.groups_outlined,
                title: 'Club & Society Alerts',
                subtitle: 'Recruitment notices, meetups',
                value: _followNotifications,
                onChanged: (v) => setState(() => _followNotifications = v),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Privacy & Security Card
          _SettingsSection(
            title: 'PRIVACY & SECURITY',
            children: [
              _SettingsTile(
                icon: Icons.lock_outline_rounded,
                title: 'Profile Visibility',
                subtitle: 'CSTU Verified Campus Community',
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.cstuSlate),
                onTap: () {},
              ),
              _SettingsDivider(),
              _SettingsTile(
                icon: Icons.block_outlined,
                title: 'Blocked Users',
                subtitle: 'No blocked students',
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.cstuSlate),
                onTap: () {},
              ),
            ],
          ),

          const SizedBox(height: 20),

          // About Section Card
          _SettingsSection(
            title: 'ABOUT CSTU CONNECT',
            children: [
              _SettingsTile(
                icon: Icons.info_outline_rounded,
                title: 'About CSTU Connect',
                subtitle: 'Version 1.0.0 (Official Campus Release)',
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.cstuSlate),
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'CSTU Connect',
                    applicationVersion: '1.0.0',
                    applicationLegalese:
                        '© 2026 Chandpur Science and Technology University\n'
                        'The official collegiate platform connecting students, faculties, and clubs.',
                    applicationIcon: Image.asset(
                      'assets/images.png',
                      width: 52,
                      height: 52,
                    ),
                  );
                },
              ),
              _SettingsDivider(),
              _SettingsTile(
                icon: Icons.help_outline_rounded,
                title: 'Help Desk & Support',
                subtitle: 'IT Cell & student coordination',
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.cstuSlate),
                onTap: () {},
              ),
              _SettingsDivider(),
              _SettingsTile(
                icon: Icons.policy_outlined,
                title: 'Campus Code of Conduct',
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.cstuSlate),
                onTap: () {},
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Logout Action Card
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusCard),
              border: Border.all(color: AppTheme.cstuCrimson.withValues(alpha: 0.2)),
              boxShadow: AppTheme.cardShadow,
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.cstuCrimson.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.logout_rounded, color: AppTheme.cstuCrimson, size: 20),
              ),
              title: const Text(
                'Log Out',
                style: TextStyle(
                  color: AppTheme.cstuCrimson,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              subtitle: const Text(
                'Sign out of this device',
                style: TextStyle(fontSize: 12, color: AppTheme.cstuSlate),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.cstuCrimson),
              onTap: () => _confirmSignOut(context),
            ),
          ),

          const SizedBox(height: 24),
          Center(
            child: Text(
              'CSTU Connect • Chandpur Science & Technology University',
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.cstuSlate.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.cstuCrimson.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.logout_rounded, color: AppTheme.cstuCrimson, size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              'Log Out',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to sign out of CSTU Connect? You will need your @student.cstu.ac.bd credentials to sign back in.',
          style: TextStyle(color: AppTheme.cstuDark, fontSize: 14, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.cstuSlate, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<FirestoreService>().signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.cstuCrimson,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Log Out', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppTheme.cstuGold,
              letterSpacing: 0.8,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.radiusCard),
            border: Border.all(color: AppTheme.borderLight),
            boxShadow: AppTheme.cardShadow,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusCard),
            child: Column(children: children),
          ),
        ),
      ],
    );
  }
}

class _SettingsDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(height: 1, indent: 56, color: AppTheme.borderSubtle);
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.cstuGoldLight,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppTheme.cstuGold, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: AppTheme.cstuDark,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.cstuSlate,
              ),
            )
          : null,
      trailing: trailing,
      onTap: onTap,
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.cstuGoldLight,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppTheme.cstuGold, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: AppTheme.cstuDark,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: AppTheme.cstuSlate),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: Colors.white,
        activeTrackColor: AppTheme.cstuGold,
      ),
    );
  }
}
