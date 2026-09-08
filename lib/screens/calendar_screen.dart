import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../core/theme/app_colors.dart';
import '../models/home_item.dart';
import '../models/severity.dart';
import '../services/home_service.dart';
import '../services/voice/bangla_voice_service.dart';
import '../widgets/app_top_header.dart';
import '../widgets/category_icon.dart';
import '../widgets/empty_state.dart';
import '../widgets/severity_chip.dart';

/// Calendar & Schedule screen elevated to luxury fintech grade.
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key, required this.homeService});

  final HomeService homeService;

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDate = DateTime.now();
  ReminderCategory? _selectedCategory;

  void _speakDateItems(List<HomeItem> items) {
    final dateFormatted =
        '${_selectedDate.day} ${_monthBangla(_selectedDate.month)}';
    final isToday = _isSameDay(_selectedDate, DateTime.now());
    final dayPrefix = isToday ? 'আজকে' : '$dateFormatted তারিখে';

    if (items.isEmpty) {
      BanglaVoiceService()
          .speak('$dayPrefix কোনো নির্ধারিত কাজ, বিল বা দেনা-পাওনা নেই।');
      return;
    }

    final buf = StringBuffer();
    buf.write('$dayPrefix আপনার মোট ${items.length}টি কাজ ও রিমাইন্ডার রয়েছে। ');

    for (int i = 0; i < items.length; i++) {
      final it = items[i];
      if (it.category == ReminderCategory.money) {
        if (it.amount != null) {
          final amt = it.amount!.toStringAsFixed(0);
          buf.write('${it.title} $amt টাকা। ');
        } else {
          buf.write('${it.title}। ');
        }
      } else if (it.category == ReminderCategory.bill) {
        final amt =
            it.amount != null ? ' ${it.amount!.toStringAsFixed(0)} টাকা' : '';
        buf.write('${it.title}$amt পরিশোধ করতে হবে। ');
      } else if (it.category == ReminderCategory.medicine) {
        buf.write('${it.title} ওষুধ খেতে হবে। ');
      } else {
        buf.write('${it.title}। ');
      }
    }

    BanglaVoiceService().speak(buf.toString());
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _monthBangla(int m) {
    const months = [
      'জানুয়ারি',
      'ফেব্রুয়ারি',
      'মার্চ',
      'এপ্রিল',
      'মে',
      'জুন',
      'জুলাই',
      'আগস্ট',
      'সেপ্টেম্বর',
      'অক্টোবর',
      'নভেম্বর',
      'ডিসেম্বর'
    ];
    return months[(m - 1) % 12];
  }

  @override
  Widget build(BuildContext context) {
    final allItems = widget.homeService.getAll();
    final itemsForDate = allItems.where((item) {
      final matchesCategory =
          _selectedCategory == null || item.category == _selectedCategory;
      final matchesDate = item.when.year == _selectedDate.year &&
          item.when.month == _selectedDate.month &&
          item.when.day == _selectedDate.day;
      return matchesCategory && matchesDate;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      body: SafeArea(
        child: Column(
          children: [
            AppTopHeader(
              onSpeakerTap: () => _speakDateItems(itemsForDate),
            ),
            // Header Action Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'ক্যালেন্ডার ও সময়সূচি',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: AppColors.ink,
                    ),
                  ),
                  Row(
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _speakDateItems(itemsForDate),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F766E).withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color:
                                    const Color(0xFF0F766E).withValues(alpha: 0.25),
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.volume_up_rounded,
                                    size: 15, color: Color(0xFF0F766E)),
                                SizedBox(width: 5),
                                Text(
                                  'শুনুন',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0F766E),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            setState(() => _selectedDate = DateTime.now());
                            final todayItems = allItems.where((item) {
                              final now = DateTime.now();
                              return item.when.year == now.year &&
                                  item.when.month == now.month &&
                                  item.when.day == now.day;
                            }).toList();
                            _speakDateItems(todayItems);
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFFE5E9EB),
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.today_rounded,
                                    size: 15, color: AppColors.ink),
                                SizedBox(width: 5),
                                Text(
                                  'আজকে',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.ink,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Calendar month header & 30-day horizontal strip
            _buildDateStrip(),
            const SizedBox(height: 10),
            // Category filter chips
            _buildCategoryFilter(),
            const SizedBox(height: 8),
            // Schedule item list for selected date
            Expanded(
              child: itemsForDate.isEmpty
                  ? Center(
                      child: EmptyState(
                        icon: Icons.event_available_rounded,
                        title: 'কোনো শিডিউল নেই',
                        message:
                            '${DateFormat('d MMMM, yyyy').format(_selectedDate)} তারিখে কোনো বিল বা রিমাইন্ডার নেই।',
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
                      itemCount: itemsForDate.length,
                      itemBuilder: (ctx, i) =>
                          _CalendarItemTile(item: itemsForDate[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateStrip() {
    final today = DateTime.now();
    final days = List.generate(30, (i) => today.add(Duration(days: i - 3)));

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: const Color(0xFFE8EEF2)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('MMMM yyyy').format(_selectedDate),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: AppColors.ink,
                  ),
                ),
                Text(
                  _isSameDay(_selectedDate, today)
                      ? 'আজ'
                      : '${_selectedDate.difference(today).inDays.abs()} দিন ${_selectedDate.isAfter(today) ? "পরে" : "আগে"}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.inkMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 74,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: days.length,
              itemBuilder: (ctx, i) {
                final d = days[i];
                final isSelected = d.year == _selectedDate.year &&
                    d.month == _selectedDate.month &&
                    d.day == _selectedDate.day;
                final isToday = d.year == today.year &&
                    d.month == today.month &&
                    d.day == today.day;

                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedDate = d);
                    final items = widget.homeService.getAll().where((item) {
                      return item.when.year == d.year &&
                          item.when.month == d.month &&
                          item.when.day == d.day;
                    }).toList();
                    _speakDateItems(items);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 52,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0xFF0F766E), Color(0xFF115E59)],
                            )
                          : null,
                      color: isSelected
                          ? null
                          : (isToday
                              ? const Color(0xFF0F766E).withValues(alpha: 0.08)
                              : const Color(0xFFF8FAFC)),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : (isToday
                                ? const Color(0xFF0F766E).withValues(alpha: 0.35)
                                : const Color(0xFFE2E8F0)),
                        width: isToday || isSelected ? 1.5 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: const Color(0xFF0F766E)
                                    .withValues(alpha: 0.35),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('E').format(d),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                            color: isSelected
                                ? Colors.white.withValues(alpha: 0.85)
                                : AppColors.inkMuted,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${d.day}',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: isSelected
                                ? Colors.white
                                : (isToday ? const Color(0xFF0F766E) : AppColors.ink),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final categories = <ReminderCategory?>[
      null,
      ReminderCategory.money,
      ReminderCategory.bill,
      ReminderCategory.medicine,
      ReminderCategory.task,
      ReminderCategory.document,
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: categories.map((cat) {
          final isSelected = _selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => setState(() => _selectedCategory = cat),
                borderRadius: BorderRadius.circular(10),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF0F766E)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF0F766E)
                          : const Color(0xFFE5E9EB),
                    ),
                  ),
                  child: Text(
                    _categoryLabel(cat),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w600,
                      color: isSelected ? Colors.white : AppColors.ink,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _categoryLabel(ReminderCategory? cat) {
    if (cat == null) return 'সকল সূচি';
    switch (cat) {
      case ReminderCategory.money:
        return 'টাকা-পয়সা';
      case ReminderCategory.bill:
        return 'বিল';
      case ReminderCategory.medicine:
        return 'ওষুধ';
      case ReminderCategory.task:
        return 'টাস্ক';
      case ReminderCategory.document:
        return 'ডকুমেন্টস';
      default:
        return 'অন্যান্য';
    }
  }
}

class _CalendarItemTile extends StatelessWidget {
  const _CalendarItemTile({required this.item});

  final HomeItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8EEF2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            switch (item.category) {
              case ReminderCategory.money:
                context.push('/money');
                break;
              case ReminderCategory.bill:
                context.push('/bills');
                break;
              case ReminderCategory.medicine:
                context.push('/medicines');
                break;
              case ReminderCategory.document:
                context.push('/documents');
                break;
              case ReminderCategory.task:
                context.push('/tasks');
                break;
              default:
                break;
            }
          },
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                CategoryIcon(icon: item.icon, severity: item.severity),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (item.subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          item.subtitle!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.inkMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                SeverityChip(severity: item.severity),
                const SizedBox(width: 6),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 13,
                  color: Color(0xFFB0BEC5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
