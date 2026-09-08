import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/theme/app_colors.dart';
import '../services/voice/bangla_voice_service.dart';

/// Reusable Executive Top Header bar showing Greeting, User phone/profile,
/// AI status pill, sound briefing, and Bangla formatted date.
class AppTopHeader extends StatefulWidget {
  const AppTopHeader({
    super.key,
    this.onMenuTap,
    this.showDrawerButton = false,
    this.onSpeakerTap,
  });

  final VoidCallback? onMenuTap;
  final bool showDrawerButton;
  final VoidCallback? onSpeakerTap;

  @override
  State<AppTopHeader> createState() => _AppTopHeaderState();
}

class _AppTopHeaderState extends State<AppTopHeader> {
  String? _userPhone;

  @override
  void initState() {
    super.initState();
    _loadUserPhone();
  }

  Future<void> _loadUserPhone() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _userPhone = prefs.getString('userPhone');
      });
    }
  }

  String _greetingFor(int hour) {
    if (hour < 12) return 'শুভ সকাল';
    if (hour < 17) return 'শুভ দুপুর';
    if (hour < 21) return 'শুভ সন্ধ্যা';
    return 'শুভ রাত্রি';
  }

  IconData _greetingIconFor(int hour) {
    if (hour >= 6 && hour < 17) return Icons.wb_sunny_rounded;
    if (hour >= 17 && hour < 21) return Icons.wb_twilight_rounded;
    return Icons.nightlight_round;
  }

  String _formattedBanglaDate(DateTime d) {
    const days = [
      'সোমবার',
      'মঙ্গলবার',
      'বুধবার',
      'বৃহস্পতিবার',
      'শুক্রবার',
      'শনিবার',
      'রবিবার'
    ];
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

    final dayName = days[(d.weekday - 1) % 7];
    final monthName = months[(d.month - 1) % 12];
    final dayNumber = _toBanglaDigits(d.day.toString());
    final yearNumber = _toBanglaDigits(d.year.toString());

    return '$dayName, $dayNumber $monthName, $yearNumber';
  }

  String _toBanglaDigits(String input) {
    return input
        .replaceAll('0', '০')
        .replaceAll('1', '১')
        .replaceAll('2', '২')
        .replaceAll('3', '৩')
        .replaceAll('4', '৪')
        .replaceAll('5', '৫')
        .replaceAll('6', '৬')
        .replaceAll('7', '৭')
        .replaceAll('8', '৮')
        .replaceAll('9', '৯');
  }

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = _greetingFor(hour);
    final greetIcon = _greetingIconFor(hour);
    final dateStr = _formattedBanglaDate(DateTime.now());
    final displayName = _userPhone != null && _userPhone!.trim().isNotEmpty
        ? _userPhone!
        : 'সম্মানিত সদস্য';

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFE8EEF2),
            width: 1,
          ),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x04000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (widget.showDrawerButton) ...[
                Builder(
                  builder: (ctx) => InkWell(
                    onTap: widget.onMenuTap ??
                        () => Scaffold.of(ctx).openDrawer(),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.brandGreen.withValues(alpha: 0.28),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.menu_rounded,
                          color: AppColors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ] else ...[
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0D5C3A), Color(0xFF10B981)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.brandGreen.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.person_rounded,
                      color: AppColors.white,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(greetIcon, size: 14, color: const Color(0xFFF59E0B)),
                        const SizedBox(width: 4),
                        Text(
                          greeting,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.inkMuted,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8FDF0),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: const Color(0xFFB9F6CA), width: 0.8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: 3,
                                backgroundColor: Color(0xFF10B981),
                              ),
                              SizedBox(width: 4),
                              Text(
                                'AI সক্রিয়',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF15803D),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
              // Speaker button
              InkWell(
                onTap: () async {
                  if (widget.onSpeakerTap != null) {
                    widget.onSpeakerTap!();
                    return;
                  }
                  final now = DateTime.now();
                  final greet = _greetingFor(now.hour);
                  final voice = BanglaVoiceService();
                  final msg =
                      '$greet! সেবা বন্ধুতে স্বাগতম। আপনার দিনটি শুভ ও নির্বিঘ্ন হোক। যেকোনো কাজ বা হিসাব মুখে বলতে নিচের প্লাস বাটনে চাপুন।';
                  await voice.speak(msg);
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFBBF7D0)),
                  ),
                  child: const Icon(
                    Icons.volume_up_rounded,
                    color: Color(0xFF16A34A),
                    size: 19,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Calendar button
              InkWell(
                onTap: () {
                  final loc = GoRouterState.of(context).uri.toString();
                  if (!loc.startsWith('/calendar')) {
                    context.push('/calendar');
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Icon(
                    Icons.calendar_month_rounded,
                    color: AppColors.ink,
                    size: 19,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Bangla Date Tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.event_note_rounded,
                  size: 13,
                  color: AppColors.inkMuted,
                ),
                const SizedBox(width: 6),
                Text(
                  dateStr,
                  style: const TextStyle(
                    color: Color(0xFF475569),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
