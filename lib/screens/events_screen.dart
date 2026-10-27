import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/event_model.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Technology',
    'Seminars',
    'Cultural',
    'Sports',
  ];

  @override
  Widget build(BuildContext context) {
    final firestoreService = context.watch<FirestoreService>();
    final allEvents = firestoreService.events;

    final events = allEvents.where((e) {
      if (_selectedCategory == 'All') return true;
      return e.category.toLowerCase().contains(_selectedCategory.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: const Row(
          children: [
            Icon(Icons.event_available_rounded, color: AppTheme.cstuGold, size: 24),
            SizedBox(width: 8),
            Text(
              'Campus Events',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 20,
                color: AppTheme.cstuDark,
                letterSpacing: -0.4,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Filter Chips Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = _selectedCategory == cat;
                  return ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    showCheckmark: false,
                    selectedColor: AppTheme.cstuGold,
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected ? Colors.white : AppTheme.cstuDark,
                    ),
                    side: BorderSide(
                      color: isSelected ? AppTheme.cstuGold : AppTheme.borderLight,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    onSelected: (val) {
                      if (val) {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedCategory = cat);
                      }
                    },
                  );
                },
              ),
            ),
          ),

          // Events List
          Expanded(
            child: events.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.event_busy_rounded,
                          size: 54,
                          color: Color(0xFFCBD5E1),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No $_selectedCategory events scheduled',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.cstuDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Check back soon or organize an event on campus!',
                          style: TextStyle(fontSize: 13, color: AppTheme.cstuSlate),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                    itemCount: events.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final event = events[index];
                      return _TicketStubEventCard(
                        event: event,
                        onRegisterToggle: () {
                          HapticFeedback.mediumImpact();
                          firestoreService.toggleEventRegistration(event.id);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _TicketStubEventCard extends StatelessWidget {
  final Event event;
  final VoidCallback onRegisterToggle;

  const _TicketStubEventCard({
    required this.event,
    required this.onRegisterToggle,
  });

  String _formatMonth(DateTime dt) {
    const months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    return months[dt.month - 1];
  }

  String _formatWeekday(DateTime dt) {
    const days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    return days[dt.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = context.read<FirestoreService>().currentUser.id;
    final isRegistered = event.isRegistered || event.registeredUserIds.contains(currentUserId);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(color: AppTheme.borderLight),
        boxShadow: AppTheme.cardShadow,
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left Date Stub (Perforated aesthetic)
            Container(
              width: 82,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.horizontal(left: Radius.circular(19)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _formatMonth(event.date),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.cstuGold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    '${event.date.day}',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.cstuDark,
                      height: 1.1,
                    ),
                  ),
                  Text(
                    _formatWeekday(event.date),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.cstuSlate,
                    ),
                  ),
                ],
              ),
            ),

            // Dashed Divider Line
            CustomPaint(
              size: const Size(1, double.infinity),
              painter: _DashedLinePainter(),
            ),

            // Right Event Information
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category & Spots Badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.cstuGoldLight,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppTheme.cstuGoldBorder),
                          ),
                          child: Text(
                            event.category.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.cstuGold,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.people_outline_rounded, size: 14, color: AppTheme.cstuSlate),
                            const SizedBox(width: 4),
                            Text(
                              '${event.registeredCount} going',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.cstuSlate,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Title
                    Text(
                      event.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.cstuDark,
                        letterSpacing: -0.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 6),

                    // Location Tag
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 14, color: AppTheme.cstuSlate),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.location,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.cstuSlate,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // RSVP Button
                    Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        onTap: onRegisterToggle,
                        borderRadius: BorderRadius.circular(12),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: isRegistered ? const Color(0xFFECFDF5) : AppTheme.cstuGold,
                            borderRadius: BorderRadius.circular(12),
                            border: isRegistered
                                ? Border.all(color: AppTheme.cstuEmerald, width: 1.5)
                                : null,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isRegistered ? Icons.check_circle_rounded : Icons.bookmark_add_rounded,
                                size: 14,
                                color: isRegistered ? AppTheme.cstuEmerald : Colors.white,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isRegistered ? 'Attending ✓' : 'Register / RSVP',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: isRegistered ? AppTheme.cstuEmerald : Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    const dashHeight = 4.0;
    const dashSpace = 4.0;
    double startY = 0;

    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
