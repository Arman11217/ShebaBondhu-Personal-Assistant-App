import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../core/localization/generated/app_localizations.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../models/home_item.dart';
import '../models/severity.dart';
import '../services/bdapps/bdapps_config.dart';
import '../services/home_service.dart';
import '../widgets/empty_state.dart';
import '../widgets/section_header.dart';
import '../widgets/severity_chip.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.homeService});

  final HomeService homeService;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const String _baseUrl = BdappsConfig.baseUrl;
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

  Future<void> _unsubscribe() async {
    final prefs = await SharedPreferences.getInstance();
    final phone = prefs.getString('userPhone') ?? '';

    if (phone.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Phone not found!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (!mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Unsubscribing'),
        content: const Text('Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!mounted) return;

    // Hold a reference to the loader dialog so we can reliably close it.
    bool loaderOpen = true;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => const PopScope(
        canPop: false,
        child: Center(child: CircularProgressIndicator()),
      ),
    );

    Future<void> closeLoader() async {
      if (!loaderOpen) return;
      loaderOpen = false;
      if (!mounted) return;
      // Guard against pop when no dialog actually exists on the navigator.
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    }

    try {
      final unSubUrl = _baseUrl.endsWith('/')
          ? '${_baseUrl}unsubscribe.php'
          : '$_baseUrl/unsubscribe.php';

      final res = await http
          .post(
            Uri.parse(unSubUrl),
            body: {'user_mobile': phone},
          )
          .timeout(const Duration(seconds: 15));

      if (!mounted) return;
      await closeLoader();

      if (res.statusCode != 200) {
        throw Exception('HTTP ${res.statusCode}');
      }

      final dynamic decoded = jsonDecode(res.body);
      if (decoded is! Map<String, dynamic>) {
        throw Exception('Unexpected response shape');
      }
      final data = decoded;
      final statusCode = data['statusCode']?.toString() ?? '';
      final statusDetail = data['statusDetail']?.toString() ?? '';
      final successFlag = data['success'] == true;
      final subscriptionStatus =
          (data['subscriptionStatus']?.toString() ?? '').toUpperCase();

      final success =
          successFlag ||
          statusCode == 'S1000' ||
          subscriptionStatus == 'UNREGISTERED';

      if (success) {
        // Clear auth state before navigating so the cold-start guard in
        // main.dart doesn't read a stale `isLoggedIn` flag.
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', false);
        await prefs.remove('userPhone');

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unsubscribing success!'),
            backgroundColor: Colors.green,
          ),
        );

        // Use the named route or go_router to return to login
        try {
          context.go('/login');
        } catch (_) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/login',
            (route) => false,
          );
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(statusDetail.isNotEmpty
                ? statusDetail
                : 'Unsubscribing failed'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } on TimeoutException {
      if (!mounted) return;
      await closeLoader();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Timeout error!'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      await closeLoader();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Network error: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF063321), Color(0xFF0E7A53)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(13),
                          child: Image.asset(
                            'assets/app_icon.png',
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius: BorderRadius.circular(13),
                              ),
                              child: const Icon(
                                Icons.handshake_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x33F59E0B),
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.stars_rounded, color: Colors.white, size: 13),
                            SizedBox(width: 4),
                            Text(
                              'VIP প্রো',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'ShebaBondhu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const Text(
                    'আপনার বিশ্বস্ত ডিজিটাল সেবা বন্ধু',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.verified_rounded,
                          color: Color(0xFF34D399),
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _userPhone != null && _userPhone!.isNotEmpty
                              ? 'গ্রাহক: $_userPhone'
                              : 'bdapps সাবস্ক্রিপশন সক্রিয়',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                children: [
                  _drawerTile(
                    context: context,
                    icon: Icons.home_rounded,
                    color: AppColors.brandGreen,
                    title: 'হোম পেজ',
                    subtitle: 'দৈনন্দিন সারসংক্ষেপ ও কাজ',
                    onTap: () => Navigator.pop(context),
                  ),
                  _drawerTile(
                    context: context,
                    icon: Icons.account_balance_wallet_rounded,
                    color: AppColors.brandGreen,
                    title: 'দেনা-পাওনা হিসাব',
                    subtitle: 'বাকি, খাতা ও লেনদেন',
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/money');
                    },
                  ),
                  _drawerTile(
                    context: context,
                    icon: Icons.receipt_long_rounded,
                    color: AppColors.important,
                    title: 'ইউটিলিটি বিল',
                    subtitle: 'বিদ্যুৎ, গ্যাস, পানি ও ইন্টারনেট',
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/bills');
                    },
                  ),
                  _drawerTile(
                    context: context,
                    icon: Icons.check_circle_outline_rounded,
                    color: const Color(0xFF6366F1),
                    title: 'টাস্ক ও দৈনন্দিন কাজ',
                    subtitle: 'স্মার্ট চেকলিস্ট ও রিমাইন্ডার',
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/tasks');
                    },
                  ),
                  _drawerTile(
                    context: context,
                    icon: Icons.folder_shared_rounded,
                    color: const Color(0xFF8B5CF6),
                    title: 'জরুরি ডিজিটাল নথি',
                    subtitle: 'NID, পাসপোর্ট ও অফিসিয়াল ফাইল',
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/documents');
                    },
                  ),
                  _drawerTile(
                    context: context,
                    icon: Icons.calendar_month_rounded,
                    color: const Color(0xFF0284C7),
                    title: 'ক্যালেন্ডার ও সময়সূচি',
                    subtitle: 'সকল নোটিফিকেশন ও সিডিউল',
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/calendar');
                    },
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.all(14),
              child: Material(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    _unsubscribe();
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.power_settings_new_rounded,
                            color: Color(0xFFDC2626),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'আনসাবস্ক্রাইব (Unsubscribe)',
                                style: TextStyle(
                                  color: Color(0xFFDC2626),
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'bdapps সেবা বন্ধ করতে চাপুন',
                                style: TextStyle(
                                  color: Color(0xFFB91C1C),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 13,
                          color: Color(0xFFDC2626),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _drawerTile({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.inkMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: Color(0xFFCBD5E1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hour = DateTime.now().hour;
    final greeting = _greetingFor(hour, l10n);
    final today = widget.homeService.criticalToday();
    final upcoming = widget.homeService.upcoming();
    final insights = widget.homeService.activeInsights();
    final importantCount = today.length + upcoming.length;

    return Scaffold(
      backgroundColor: AppColors.surface,
      drawer: _buildDrawer(context),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.brandGreen,
          onRefresh: () async {
            setState(() {});
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(
                child: _HeroHeader(
                  greeting: greeting,
                  todayCount: today.length,
                  upcomingCount: upcoming.length,
                  userName: _userPhone != null && _userPhone!.isNotEmpty
                      ? _userPhone
                      : 'ব্যবহারকারী',
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xxl,
                  AppSpacing.md,
                  AppSpacing.xxl,
                  AppSpacing.xxxl,
                ),
                sliver: SliverList.list(
                  children: [
                    _SummaryCard(
                      count: importantCount,
                      todayCount: today.length,
                      upcomingCount: upcoming.length,
                      l10n: l10n,
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    SectionHeader(
                      title: l10n.homeQuickActionsTitle,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _QuickActionGrid(l10n: l10n),
                    const SizedBox(height: AppSpacing.xxl),
                    if (insights.isNotEmpty) ...[
                      SectionHeader(title: l10n.homeInsightTitle),
                      const SizedBox(height: AppSpacing.md),
                      _InsightCard(
                        day: insights.first.dayKey,
                        body: insights.first.body,
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                    ],
                    SectionHeader(title: l10n.homeSectionToday),
                    const SizedBox(height: AppSpacing.md),
                    if (today.isEmpty)
                      EmptyState(
                        icon: Icons.check_circle_outline_rounded,
                        title: l10n.homeEmptyTodayTitle,
                        message: l10n.homeEmptyTodayBody,
                      )
                    else
                      ...today.map((item) => _ItemTile(
                            item: item,
                            onReturn: () => setState(() {}),
                          )),
                    const SizedBox(height: AppSpacing.xxl),
                    SectionHeader(title: l10n.homeSectionUpcoming),
                    const SizedBox(height: AppSpacing.md),
                    if (upcoming.isEmpty)
                      EmptyState(
                        icon: Icons.event_available_outlined,
                        title: l10n.homeEmptyUpcomingTitle,
                        message: l10n.homeEmptyUpcomingBody,
                      )
                    else
                      ...upcoming.map((item) => _ItemTile(
                            item: item,
                            onReturn: () => setState(() {}),
                          )),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({
    required this.greeting,
    required this.todayCount,
    required this.upcomingCount,
    this.userName,
  });

  final String greeting;
  final int todayCount;
  final int upcomingCount;
  final String? userName;

  IconData _greetingIconFor(int hour) {
    if (hour >= 6 && hour < 17) return Icons.wb_sunny_rounded;
    if (hour >= 17 && hour < 21) return Icons.wb_twilight_rounded;
    return Icons.nightlight_round;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateStr = _formattedBanglaDate(now);
    final greetIcon = _greetingIconFor(now.hour);
    final displayName = userName != null && userName!.trim().isNotEmpty
        ? userName!
        : 'সম্মানিত সদস্য';

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE8EEF2),
            width: 1,
          ),
        ),
        boxShadow: [
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
              Builder(
                builder: (ctx) => InkWell(
                  onTap: () => Scaffold.of(ctx).openDrawer(),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
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
              InkWell(
                onTap: () => context.push('/calendar'),
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

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.count,
    required this.todayCount,
    required this.upcomingCount,
    required this.l10n,
  });

  final int count;
  final int todayCount;
  final int upcomingCount;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
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
                  child: const Icon(
                    Icons.notifications_active_rounded,
                    color: AppColors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'জরুরি সারসংক্ষেপ',
                        style: TextStyle(
                          color: AppColors.inkMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        count > 0
                            ? '$countটি কাজ ও পেমেন্ট বাকি আছে'
                            : 'কোনো বকেয়া কাজ বা বিল নেই',
                        style: const TextStyle(
                          color: AppColors.ink,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () => context.push('/calendar'),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8FDF0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'সময়সূচি',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF15803D),
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward_ios_rounded,
                            size: 10, color: Color(0xFF15803D)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(22)),
              border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEF4444),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'আজকের কাজ: $todayCountটি',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(height: 16, width: 1, color: const Color(0xFFCBD5E1)),
                const SizedBox(width: 14),
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF59E0B),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'আসন্ন কাজ: $upcomingCountটি',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                    ],
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

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.day, required this.body});
  final String day;
  final String body;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFDE68A),
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10D97706),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      l10n.homeInsightTitle,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF92400E),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: const Color(0xFFF59E0B),
                          width: 0.8,
                        ),
                      ),
                      child: const Text(
                        'AI অন্তর্দৃষ্টি',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFB45309),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  l10n.homeInsightBody(day),
                  style: const TextStyle(
                    color: Color(0xFF78350F),
                    fontSize: 13,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
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

class _ItemTile extends StatelessWidget {
  const _ItemTile({
    required this.item,
    this.onReturn,
  });

  final HomeItem item;
  final VoidCallback? onReturn;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final due = item.daysUntil == 0
        ? l10n.dueToday
        : item.daysUntil == 1
            ? l10n.dueTomorrow
            : l10n.daysRemaining(item.daysUntil);

    final color = _categoryColor(item.category);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8EEF2)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: () async {
            String? route;
            switch (item.category) {
              case ReminderCategory.money:
                route = '/money';
                break;
              case ReminderCategory.bill:
                route = '/bills';
                break;
              case ReminderCategory.document:
                route = '/documents';
                break;
              case ReminderCategory.medicine:
                route = '/medicines';
                break;
              case ReminderCategory.recharge:
                route = '/sims';
                break;
              case ReminderCategory.task:
                route = '/tasks';
                break;
              case ReminderCategory.warranty:
                route = '/warranties';
                break;
              default:
                break;
            }
            if (route != null) {
              await context.push(route);
              onReturn?.call();
            }
          },
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(item.icon, color: color, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 14.5,
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
                            color: AppColors.inkMuted,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            size: 13,
                            color: item.daysUntil <= 1
                                ? AppColors.critical
                                : AppColors.brandGreen,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            due,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: item.daysUntil <= 1
                                  ? AppColors.critical
                                  : AppColors.brandGreen,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                SeverityChip(severity: item.severity),
                const SizedBox(width: 4),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: AppColors.inkMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Color _categoryColor(ReminderCategory cat) {
    switch (cat) {
      case ReminderCategory.money:
        return AppColors.brandGreen;
      case ReminderCategory.bill:
        return AppColors.important;
      case ReminderCategory.medicine:
        return AppColors.critical;
      case ReminderCategory.recharge:
      case ReminderCategory.appointment:
        return AppColors.brandGreenVibrant;
      case ReminderCategory.task:
        return AppColors.accent;
      case ReminderCategory.warranty:
      case ReminderCategory.document:
        return const Color(0xFF6366F1); // Indigo
    }
  }
}

class _QuickActionGrid extends StatelessWidget {
  const _QuickActionGrid({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final actions = <_QuickActionItem>[
      _QuickActionItem(
        icon: Icons.account_balance_wallet_rounded,
        title: l10n.homeQuickMoneyTitle,
        subtitle: 'দেনা-পাওনা হিসাব',
        color: AppColors.brandGreen,
        bgColor: const Color(0xFFECFDF5),
        gradient: const [Color(0xFF0D5C3A), Color(0xFF10B981)],
        onTap: () => context.push('/money'),
      ),
      _QuickActionItem(
        icon: Icons.receipt_long_rounded,
        title: l10n.moreBillsTitle,
        subtitle: 'বিদ্যুৎ, গ্যাস, পানি',
        color: AppColors.important,
        bgColor: const Color(0xFFFFF7ED),
        gradient: const [Color(0xFFEA580C), Color(0xFFF97316)],
        onTap: () => context.push('/bills'),
      ),
      _QuickActionItem(
        icon: Icons.medication_rounded,
        title: l10n.moreMedicineTitle,
        subtitle: 'ওষুধের সময়সূচি',
        color: AppColors.critical,
        bgColor: const Color(0xFFFEF2F2),
        gradient: const [Color(0xFFDC2626), Color(0xFFEF4444)],
        onTap: () => context.push('/medicines'),
      ),
      _QuickActionItem(
        icon: Icons.sim_card_rounded,
        title: l10n.moreRechargeTitle,
        subtitle: 'মেয়াদ ও রিচার্জ',
        color: const Color(0xFF0D9488),
        bgColor: const Color(0xFFF0FDFA),
        gradient: const [Color(0xFF0F766E), Color(0xFF14B8A6)],
        onTap: () => context.push('/sims'),
      ),
      _QuickActionItem(
        icon: Icons.check_circle_rounded,
        title: 'দৈনন্দিন কাজ',
        subtitle: 'টু-ডু ও টাস্ক লিস্ট',
        color: const Color(0xFF6366F1),
        bgColor: const Color(0xFFEEF2FF),
        gradient: const [Color(0xFF4F46E5), Color(0xFF818CF8)],
        onTap: () => context.push('/tasks'),
      ),
      _QuickActionItem(
        icon: Icons.folder_shared_rounded,
        title: l10n.moreDocsTitle,
        subtitle: 'NID, ফাইল ও নথি',
        color: const Color(0xFF8B5CF6),
        bgColor: const Color(0xFFF5F3FF),
        gradient: const [Color(0xFF7C3AED), Color(0xFFA78BFA)],
        onTap: () => context.push('/documents'),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final spacing = 12.0;
        final itemWidth = (constraints.maxWidth - spacing) / 2;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: actions
              .map((a) => SizedBox(
                    width: itemWidth,
                    child: _QuickActionCard(item: a),
                  ))
              .toList(),
        );
      },
    );
  }
}

class _QuickActionItem {
  const _QuickActionItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.bgColor,
    required this.gradient,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Color bgColor;
  final List<Color> gradient;
  final VoidCallback onTap;
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({required this.item});
  final _QuickActionItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8EEF2)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: item.onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: item.gradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(13),
                    boxShadow: [
                      BoxShadow(
                        color: item.color.withValues(alpha: 0.25),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(item.icon, color: Colors.white, size: 21),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.subtitle,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                              color: AppColors.inkMuted,
                              fontSize: 11,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _greetingFor(int hour, AppLocalizations l10n) {
  if (hour < 12) return l10n.homeGreetingMorning;
  if (hour < 17) return l10n.homeGreetingAfternoon;
  if (hour < 21) return l10n.homeGreetingEvening;
  return l10n.homeGreetingNight;
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