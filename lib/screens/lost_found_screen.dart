import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/lost_found_model.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';

class LostFoundScreen extends StatefulWidget {
  const LostFoundScreen({super.key});

  @override
  State<LostFoundScreen> createState() => _LostFoundScreenState();
}

class _LostFoundScreenState extends State<LostFoundScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openReportDialog(BuildContext context) {
    HapticFeedback.lightImpact();
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final locationCtrl = TextEditingController();
    bool isLost = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setModal) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 16,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Report Lost or Found Item',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.cstuDark,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Help the campus community return items safely',
                  style: TextStyle(fontSize: 12, color: AppTheme.cstuSlate),
                ),
                const SizedBox(height: 18),

                // Lost or Found Selector
                Row(
                  children: [
                    Expanded(
                      child: _TypeButton(
                        label: 'Lost Item',
                        icon: Icons.search_rounded,
                        selected: isLost,
                        color: AppTheme.cstuCrimson,
                        onTap: () => setModal(() => isLost = true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _TypeButton(
                        label: 'Found Item',
                        icon: Icons.check_circle_rounded,
                        selected: !isLost,
                        color: AppTheme.cstuEmerald,
                        onTap: () => setModal(() => isLost = false),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Item Name / Short Title',
                    hintText: 'e.g., Student ID Card, Blue Umbrella, Casio Calc',
                    prefixIcon: Icon(Icons.label_outline_rounded, color: AppTheme.cstuGold),
                  ),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: locationCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Location on Campus',
                    hintText: 'e.g., Academic Building 2, Room 304, Canteen',
                    prefixIcon: Icon(Icons.location_on_outlined, color: AppTheme.cstuGold),
                  ),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: descCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description & Distinguishing Details',
                    hintText: 'Color, brand, identifying marks, where it was kept...',
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      final title = titleCtrl.text.trim();
                      final desc = descCtrl.text.trim();
                      final loc = locationCtrl.text.trim();

                      if (title.isNotEmpty && loc.isNotEmpty) {
                        context.read<FirestoreService>().reportLostFound(
                          title: title,
                          description: desc.isEmpty ? 'No extra details provided.' : desc,
                          location: loc,
                          isLost: isLost,
                        );
                        Navigator.pop(ctx);
                        HapticFeedback.mediumImpact();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isLost
                                  ? 'Lost report published to campus feed'
                                  : 'Found report published! Thank you!',
                            ),
                            backgroundColor: isLost ? AppTheme.cstuCrimson : AppTheme.cstuEmerald,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isLost ? AppTheme.cstuCrimson : AppTheme.cstuEmerald,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(
                      isLost ? 'Submit Lost Report' : 'Submit Found Report',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = context.watch<FirestoreService>();
    final items = firestoreService.lostFoundItems;

    final lostItems = items.where((i) => i.isLost).toList();
    final foundItems = items.where((i) => !i.isLost).toList();

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: const Row(
          children: [
            Icon(Icons.find_in_page_rounded, color: AppTheme.cstuGold, size: 24),
            SizedBox(width: 8),
            Text(
              'Lost & Found Desk',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 20,
                color: AppTheme.cstuDark,
                letterSpacing: -0.4,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.all(3),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerHeight: 0,
              labelColor: AppTheme.cstuDark,
              unselectedLabelColor: AppTheme.cstuSlate,
              labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              tabs: [
                Tab(text: 'Lost Items (${lostItems.length})'),
                Tab(text: 'Found Items (${foundItems.length})'),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 74),
        child: FloatingActionButton.extended(
          onPressed: () => _openReportDialog(context),
          backgroundColor: AppTheme.cstuGold,
          elevation: 4,
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: const Text(
            'Report Item',
            style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _ItemList(
            items: lostItems,
            emptyMessage: 'No lost items currently reported.',
            emptyIcon: Icons.search_off_rounded,
          ),
          _ItemList(
            items: foundItems,
            emptyMessage: 'No found items currently reported.',
            emptyIcon: Icons.task_alt_rounded,
          ),
        ],
      ),
    );
  }
}

class _ItemList extends StatelessWidget {
  final List<LostFoundItem> items;
  final String emptyMessage;
  final IconData emptyIcon;

  const _ItemList({
    required this.items,
    required this.emptyMessage,
    required this.emptyIcon,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(emptyIcon, size: 54, color: const Color(0xFFCBD5E1)),
            const SizedBox(height: 12),
            Text(
              emptyMessage,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppTheme.cstuDark,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Items reported by students will appear here live.',
              style: TextStyle(fontSize: 12, color: AppTheme.cstuSlate),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 130),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _ItemCard(item: items[index]),
    );
  }
}

class _ItemCard extends StatelessWidget {
  final LostFoundItem item;

  const _ItemCard({required this.item});

  void _showContactModal(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Contact Reporter (${item.reporterName})',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.cstuDark,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Regarding: ${item.title}',
                style: const TextStyle(fontSize: 13, color: AppTheme.cstuSlate),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.borderLight),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on_rounded, color: AppTheme.cstuGold, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Claim location: ${item.location}',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Claim request sent to ${item.reporterName}!'),
                        backgroundColor: AppTheme.cstuEmerald,
                      ),
                    );
                  },
                  icon: const Icon(Icons.send_rounded, size: 18),
                  label: const Text('Send In-App Claim Message'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.cstuGold,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = item.isLost ? AppTheme.cstuCrimson : AppTheme.cstuEmerald;
    final statusBg = item.isLost ? const Color(0xFFFFF1F2) : const Color(0xFFECFDF5);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(color: AppTheme.borderLight),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(radius: 3, backgroundColor: statusColor),
                      const SizedBox(width: 5),
                      Text(
                        item.isLost ? 'LOST' : 'FOUND',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: statusColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.cstuDark,
                      letterSpacing: -0.3,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              item.description,
              style: const TextStyle(
                fontSize: 13,
                height: 1.45,
                color: Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: AppTheme.borderSubtle),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 14, color: AppTheme.cstuGold),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    item.location,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.cstuDark,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.schedule_rounded, size: 14, color: Color(0xFF94A3B8)),
                const SizedBox(width: 4),
                Text(
                  item.timeAgo,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Reported by ${item.reporterName}',
                  style: const TextStyle(fontSize: 11, color: AppTheme.cstuSlate),
                ),
                InkWell(
                  onTap: () => _showContactModal(context),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.chat_outlined, size: 13, color: AppTheme.cstuDark),
                        SizedBox(width: 4),
                        Text(
                          'Contact',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.cstuDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _TypeButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.12) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? color : AppTheme.borderLight,
            width: selected ? 2.0 : 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: selected ? color : AppTheme.cstuSlate),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                color: selected ? color : AppTheme.cstuSlate,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
