import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/localization/generated/app_localizations.dart';
import '../core/theme/app_colors.dart';
import '../services/ai/gemini_service.dart';
import '../services/ai/quick_add_dispatcher.dart';
import '../services/auth_service.dart';
import '../services/bdapps/bdapps_config.dart';
import '../services/notification/notification_service.dart';
import '../services/security/security_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/app_top_header.dart';
import '../widgets/quick_add/quick_add_sheet.dart';

/// More / Super-App Command Center elevated to luxury fintech grade.
class MoreScreen extends StatelessWidget {
  const MoreScreen({
    super.key,
    required this.geminiService,
    this.dispatcher,
    this.authService,
  });

  final GeminiService geminiService;
  final QuickAddDispatcher? dispatcher;
  final AuthService? authService;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final userPhone = authService?.userPhone ?? '০১৭XXXXXXXX';

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      body: SafeArea(
        child: Column(
          children: [
            const AppTopHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                children: [
                  // VIP Profile & bdapps Subscription Hub Card
                  _VipProfileCard(
                    userPhone: userPhone,
                    onManageSubscription: () =>
                        _showSubscriptionDialog(context),
                  ),
                  const SizedBox(height: 16),

                  // AI Assistant Superpower Card
                  _AiSuperCard(
                    onTap: () => QuickAddSheet.show(
                      context: context,
                      geminiService: geminiService,
                      dispatcher: dispatcher,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Category 1: Fintech & Finance
                  _SectionHeader(
                    title: 'আর্থিক ব্যবস্থাপনা',
                    icon: Icons.account_balance_rounded,
                    color: const Color(0xFF0F766E),
                  ),
                  const SizedBox(height: 10),
                  _ModuleTile(
                    icon: Icons.account_balance_wallet_rounded,
                    title: l10n.moreMoneyTitle,
                    subtitle: l10n.moreMoneySubtitle,
                    gradient: const [Color(0xFF0F766E), Color(0xFF115E59)],
                    onTap: () => context.push('/money'),
                  ),
                  _ModuleTile(
                    icon: Icons.receipt_long_rounded,
                    title: l10n.moreBillsTitle,
                    subtitle: l10n.moreBillsSubtitle,
                    gradient: const [Color(0xFF0284C7), Color(0xFF0369A1)],
                    onTap: () => context.push('/bills'),
                  ),
                  _ModuleTile(
                    icon: Icons.insights_rounded,
                    title: l10n.moreAnalyticsTitle,
                    subtitle: l10n.moreAnalyticsSubtitle,
                    gradient: const [Color(0xFF7C3AED), Color(0xFF6D28D9)],
                    onTap: () => context.push('/analytics'),
                  ),
                  const SizedBox(height: 20),

                  // Category 2: Life, Health & Family
                  _SectionHeader(
                    title: 'স্বাস্থ্য, পরিবার ও সিম',
                    icon: Icons.favorite_rounded,
                    color: const Color(0xFFE11D48),
                  ),
                  const SizedBox(height: 10),
                  _ModuleTile(
                    icon: Icons.medication_rounded,
                    title: l10n.moreMedicineTitle,
                    subtitle: l10n.moreMedicineSubtitle,
                    gradient: const [Color(0xFFEF4444), Color(0xFFDC2626)],
                    onTap: () => context.push('/medicines'),
                  ),
                  _ModuleTile(
                    icon: Icons.family_restroom_rounded,
                    title: l10n.moreFamilyTitle,
                    subtitle: l10n.moreFamilySubtitle,
                    gradient: const [Color(0xFF0D9488), Color(0xFF0F766E)],
                    onTap: () => context.push('/family'),
                  ),
                  _ModuleTile(
                    icon: Icons.sim_card_rounded,
                    title: l10n.moreRechargeTitle,
                    subtitle: l10n.moreRechargeSubtitle,
                    gradient: const [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                    onTap: () => context.push('/sims'),
                  ),
                  const SizedBox(height: 20),

                  // Category 3: Vault & Organization
                  _SectionHeader(
                    title: 'নথি, ওয়ারেন্টি ও শিডিউল',
                    icon: Icons.folder_special_rounded,
                    color: const Color(0xFFD97706),
                  ),
                  const SizedBox(height: 10),
                  _ModuleTile(
                    icon: Icons.folder_shared_rounded,
                    title: l10n.moreDocsTitle,
                    subtitle: l10n.moreDocsSubtitle,
                    gradient: const [Color(0xFF059669), Color(0xFF047857)],
                    onTap: () => context.push('/documents'),
                  ),
                  _ModuleTile(
                    icon: Icons.verified_user_rounded,
                    title: l10n.moreWarrantyTitle,
                    subtitle: l10n.moreWarrantySubtitle,
                    gradient: const [Color(0xFF0284C7), Color(0xFF0369A1)],
                    onTap: () => context.push('/warranties'),
                  ),
                  _ModuleTile(
                    icon: Icons.calendar_month_rounded,
                    title: l10n.moreCalendarTitle,
                    subtitle: l10n.moreCalendarSubtitle,
                    gradient: const [Color(0xFF4F46E5), Color(0xFF4338CA)],
                    onTap: () => context.push('/calendar'),
                  ),
                  _ModuleTile(
                    icon: Icons.task_alt_rounded,
                    title: l10n.moreTasksTitle,
                    subtitle: l10n.moreTasksSubtitle,
                    gradient: const [Color(0xFF0D9488), Color(0xFF0F766E)],
                    onTap: () => context.push('/tasks'),
                  ),
                  const SizedBox(height: 24),

                  // Category 4: System & Security Group
                  _SectionHeader(
                    title: 'অ্যাকাউন্ট ও নিরাপত্তা',
                    icon: Icons.tune_rounded,
                    color: const Color(0xFF475569),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE8EEF2)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _AccountListTile(
                          icon: Icons.notifications_active_rounded,
                          iconColor: const Color(0xFFF59E0B),
                          title: 'স্মার্ট নোটিফিকেশন ও অ্যালার্ট',
                          subtitle: '১ ঘণ্টা, ৩০ মিনিট পূর্বে তাগাদা ও টেস্ট অ্যালার্ট',
                          trailingBadge: 'সক্রিয়',
                          onTap: () => _showNotificationSettingsDialog(context),
                        ),
                        const Divider(height: 1, indent: 64),
                        _AccountListTile(
                          icon: Icons.security_rounded,
                          iconColor: const Color(0xFF0F766E),
                          title: 'অ্যাপ লক ও গোপন পিন',
                          subtitle: 'ব্যক্তিগত তথ্য ও হিসাব সুরক্ষিত রাখুন',
                          trailingBadge: 'পিন কোড',
                          onTap: () => SecurityService.showPinDialog(context),
                        ),
                        const Divider(height: 1, indent: 64),
                        _AccountListTile(
                          icon: Icons.verified_rounded,
                          iconColor: const Color(0xFF059669),
                          title: 'bdapps সাবস্ক্রিপশন ও বিলিং',
                          subtitle: 'সক্রিয় মেম্বারশিপ ও কিওয়ার্ড বিবরণী',
                          trailingBadge: 'সক্রিয়',
                          onTap: () => _showSubscriptionDialog(context),
                        ),
                        const Divider(height: 1, indent: 64),
                        _AccountListTile(
                          icon: Icons.settings_suggest_rounded,
                          iconColor: const Color(0xFF0284C7),
                          title: l10n.moreSettings,
                          subtitle: 'Gemini AI ইঞ্জিন ও ভাষা সেটিংস',
                          onTap: () => _showSettingsDialog(context),
                        ),
                        const Divider(height: 1, indent: 64),
                        _AccountListTile(
                          icon: Icons.help_outline_rounded,
                          iconColor: const Color(0xFF8B5CF6),
                          title: l10n.moreHelp,
                          subtitle: 'ভয়েস ও ক্যামেরা ব্যবহারের নির্দেশিকা',
                          onTap: () => _showHelpDialog(context),
                        ),
                        const Divider(height: 1, indent: 64),
                        _AccountListTile(
                          icon: Icons.info_outline_rounded,
                          iconColor: const Color(0xFF64748B),
                          title: l10n.moreAbout,
                          subtitle: 'ভার্সন ১.০.০ (Release)',
                          onTap: () => _showAboutDialog(context),
                        ),
                        const Divider(height: 1, indent: 64),
                        _AccountListTile(
                          icon: Icons.logout_rounded,
                          iconColor: const Color(0xFFEF4444),
                          title: 'লগআউট',
                          subtitle: 'অ্যাকাউন্ট থেকে নিরাপদে বের হোন',
                          onTap: () => _showLogoutDialog(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotificationSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => const _NotificationSettingsDialog(),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF0284C7).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.settings_rounded,
                  color: Color(0xFF0284C7), size: 20),
            ),
            const SizedBox(width: 10),
            const Text('সিস্টেম ও AI সেটিংস',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.language_rounded, color: Color(0xFF0F766E)),
              title: Text('ভাষা (Language)',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              subtitle: Text('বাংলা (ডিফল্ট)'),
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading:
                  const Icon(Icons.auto_awesome, color: Color(0xFF7C3AED)),
              title: const Text('Gemini AI ইঞ্জিন',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              subtitle: Text(
                geminiService.hasApiKey
                    ? 'Gemini 1.5 Flash '
                    : 'ফলব্যাক অফলাইন পার্সার',
              ),
            ),
            const Divider(),
            const ListTile(
              contentPadding: EdgeInsets.zero,
              leading:
                  Icon(Icons.cloud_done_rounded, color: Color(0xFF059669)),
              title: Text('ক্লাউড সিঙ্ক ',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('ঠিক আছে',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.menu_book_rounded,
                  color: Color(0xFF8B5CF6), size: 20),
            ),
            const SizedBox(width: 10),
            const Text('ব্যবহার নির্দেশিকা',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '১. AI Quick Add ও ভয়েস কমান্ড:',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
              SizedBox(height: 2),
              Text(
                'নিচের মাঝখানের AI বাটনে চাপ দিয়ে লিখুন বা বাংলায় বলুন (যেমন: "করিমের কাছ থেকে ৫০০ টাকা পাব" বা "বিদ্যুৎ বিল দিতে হবে")। সাথে সাথে স্বয়ংক্রিয়ভাবে ক্যাটাগরি তৈরি হয়ে যাবে।\n',
                style: TextStyle(fontSize: 13, height: 1.4),
              ),
              Text(
                '২. বিল বা প্রেসক্রিপশনের ছবি দিয়ে এন্ট্রি:',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
              SizedBox(height: 2),
              Text(
                'Quick Add-এর ভেতরে ক্যামেরা চেপে ছবি তুললে Gemini OCR স্বয়ংক্রিয়ভাবে বিলের টাকার পরিমাণ ও তারিখ শনাক্ত করবে।\n',
                style: TextStyle(fontSize: 13, height: 1.4),
              ),
              Text(
                '৩. গোপনীয়তা ও ডাটা নিরাপত্তা:',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
              SizedBox(height: 2),
              Text(
                'আপনার ব্যক্তিগত সকল দেনা-পাওনা ও জাতীয় পরিচয়পত্র এনক্রিপ্টেড ডাটাবেজে সম্পূর্ণ সুরক্ষিত থাকে।',
                style: TextStyle(fontSize: 13, height: 1.4),
              ),
            ],
          ),
        ),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF0F766E),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('বুঝেছি'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/app_icon.png',
                width: 36,
                height: 36,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F766E),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.handshake_rounded,
                      color: Colors.white, size: 20),
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'সেবা বন্ধু',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                  ),
                  Text(
                    'Sheba Bondhu',
                    style: TextStyle(color: AppColors.inkMuted, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ভার্সন: 1.0.0',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            SizedBox(height: 8),
            Text(
              'বাংলাদেশ-কেন্দ্রিক AI-চালিত ডিজিটাল পারিবারিক ও পার্সোনাল সহকারী। আপনার দৈনন্দিন বিল, দেনা-পাওনা, ওষুধ, সিম রিচার্জ এবং জরুরি নথি ব্যবস্থাপনায় বিশ্বস্ত সহচর।',
              style: TextStyle(fontSize: 13, height: 1.4),
            ),
            SizedBox(height: 12),
            Text(
              '',
              style: TextStyle(
                color: Color(0xFF0F766E),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('বন্ধ করুন'),
          ),
        ],
      ),
    );
  }

  void _showSubscriptionDialog(BuildContext context) {
    final phone = authService?.userPhone ?? '০১৮XXXXXXXX';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.verified_user_rounded,
                  color: Color(0xFF059669), size: 20),
            ),
            const SizedBox(width: 10),
            const Text('bdapps সাবস্ক্রিপশন',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.phone_android_rounded,
                  color: Color(0xFF0F766E)),
              title: const Text('সংযুক্ত নম্বর',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              subtitle: Text(phone),
            ),
            const Divider(),
            const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.check_circle_rounded, color: Color(0xFF10B981)),
              title: Text('মেম্বারশিপ স্ট্যাটাস',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              subtitle: Text('সক্রিয় ভিআইপি গ্রাহক (Active)'),
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.info_outline_rounded,
                  color: AppColors.inkMuted),
              title: const Text('সাবস্ক্রিপশন সার্ভিস',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              subtitle: Text(
                'SMS: ${BdappsConfig.smsInstruction}\nUSSD: ${BdappsConfig.ussdInstruction}',
                style: const TextStyle(fontSize: 12),
              ),
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.payments_outlined,
                  color: Color(0xFF0284C7)),
              title: const Text('দৈনিক চার্জ',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              subtitle: Text(BdappsConfig.chargingNoticeBangla,
                  style: const TextStyle(fontSize: 12)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('ঠিক আছে',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.critical,
              side: const BorderSide(color: AppColors.critical),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              _confirmUnsubscribe(context);
            },
            child: const Text('আনসাবস্ক্রাইব'),
          ),
        ],
      ),
    );
  }

  void _confirmUnsubscribe(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('আনসাবস্ক্রাইব নিশ্চিতকরণ'),
        content: const Text(
          'আপনি কি নিশ্চিত সেবা বন্ধু আনসাবস্ক্রাইব করতে চান? এতে আপনার সাবস্ক্রিপশন বাতিল হবে এবং লগইন স্ক্রিনে ফেরত যাবেন।',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('না'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.critical,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('আনসাবস্ক্রাইব করা হচ্ছে...')),
              );
              await authService?.unsubscribe();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('সফলভাবে আনসাবস্ক্রাইব করা হয়েছে'),
                    backgroundColor: Colors.orange,
                  ),
                );
                context.go('/login');
              }
            },
            child: const Text('হ্যাঁ, আনসাবস্ক্রাইব করুন'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('লগআউট'),
        content: const Text('আপনি কি সেবা বন্ধু থেকে লগআউট করতে চান?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('না'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.critical,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await authService?.signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
            child: const Text('লগআউট'),
          ),
        ],
      ),
    );
  }
}

class _VipProfileCard extends StatelessWidget {
  const _VipProfileCard({
    required this.userPhone,
    required this.onManageSubscription,
  });

  final String userPhone;
  final VoidCallback onManageSubscription;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F172A),
            Color(0xFF1E293B),
            Color(0xFF0F2B26),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF059669)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981).withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.person_rounded,
                      color: Colors.white, size: 28),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            userPhone,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: 0.20),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: const Color(0xFF10B981).withValues(alpha: 0.40),
                            ),
                          ),
                          child: const Text(
                            'PRO',
                            style: TextStyle(
                              color: Color(0xFF34D399),
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF10B981),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'bdapps ভেরিফায়েড অ্যাকাউন্ট',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.75),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.workspace_premium_rounded,
                        size: 16, color: Color(0xFFFBBF24)),
                    SizedBox(width: 8),
                    Text(
                      'দৈনিক আনলিমিটেড AI ও ক্লাউড সিঙ্ক',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: onManageSubscription,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'ম্যানেজ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
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

class _AiSuperCard extends StatelessWidget {
  const _AiSuperCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F766E),
            Color(0xFF134E48),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F766E).withValues(alpha: 0.28),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Icon(Icons.auto_awesome,
                        color: Color(0xFF5EEAD4), size: 22),
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI সুপার অ্যাসিস্ট্যান্ট (Quick Add)',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'মুখে বলুন বা লিখুন — স্বয়ংক্রিয়ভাবে হিসাব বা বিল যোগ হবে',
                        style: TextStyle(
                          color: Color(0xFFCCFBF1),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded,
                    color: Colors.white, size: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.color,
  });

  final String title;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}

class _ModuleTile extends StatelessWidget {
  const _ModuleTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final VoidCallback? onTap;

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
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: gradient.first.withValues(alpha: 0.28),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.inkMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded,
                    color: Color(0xFFB0BEC5), size: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AccountListTile extends StatelessWidget {
  const _AccountListTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.trailingBadge,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String? trailingBadge;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
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
              if (trailingBadge != null) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    trailingBadge!,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: iconColor,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
              ],
              const Icon(Icons.arrow_forward_ios_rounded,
                  color: Color(0xFFCBD5E1), size: 13),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationSettingsDialog extends StatefulWidget {
  const _NotificationSettingsDialog();

  @override
  State<_NotificationSettingsDialog> createState() =>
      _NotificationSettingsDialogState();
}

class _NotificationSettingsDialogState
    extends State<_NotificationSettingsDialog> {
  bool _master = true;
  bool _alert1h = true;
  bool _alert30m = true;
  bool _alertDue = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _master =
          prefs.getBool(NotificationService.keyNotificationsEnabled) ?? true;
      _alert1h = prefs.getBool(NotificationService.keyAlert1hEnabled) ?? true;
      _alert30m = prefs.getBool(NotificationService.keyAlert30mEnabled) ?? true;
      _alertDue =
          prefs.getBool(NotificationService.keyAlertAtDueEnabled) ?? true;
      _isLoading = false;
    });
  }

  Future<void> _updatePref(String key, bool val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, val);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.notifications_active_rounded,
                color: Color(0xFFD97706), size: 22),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'স্মার্ট নোটিফিকেশন সেন্টার',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
            ),
          ),
        ],
      ),
      content: _isLoading
          ? const SizedBox(
              height: 120,
              child: Center(child: CircularProgressIndicator()),
            )
          : SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    activeThumbColor: const Color(0xFF0F766E),
                    title: const Text(
                      'সকল নোটিফিকেশন সক্রিয়',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    subtitle: const Text('সিস্টেম ট্রে অ্যালার্ট চালু রাখুন',
                        style: TextStyle(fontSize: 12)),
                    value: _master,
                    onChanged: (val) {
                      setState(() => _master = val);
                      _updatePref(
                          NotificationService.keyNotificationsEnabled, val);
                    },
                  ),
                  const Divider(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    activeThumbColor: const Color(0xFF0F766E),
                    title: const Text(
                      '⏳ ১ ঘণ্টা পূর্বে অ্যালার্ট',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    subtitle: const Text('কাজের সময় হওয়ার ১ ঘণ্টা পূর্বে তাগাদা',
                        style: TextStyle(fontSize: 11)),
                    value: _alert1h,
                    onChanged: _master
                        ? (val) {
                            setState(() => _alert1h = val);
                            _updatePref(
                                NotificationService.keyAlert1hEnabled, val);
                          }
                        : null,
                  ),
                  const Divider(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    activeThumbColor: const Color(0xFF0F766E),
                    title: const Text(
                      '⚠️ ৩০ মিনিট পূর্বে অ্যালার্ট',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    subtitle: const Text('কাজের সময় হওয়ার ৩০ মিনিট পূর্বে তাগাদা',
                        style: TextStyle(fontSize: 11)),
                    value: _alert30m,
                    onChanged: _master
                        ? (val) {
                            setState(() => _alert30m = val);
                            _updatePref(
                                NotificationService.keyAlert30mEnabled, val);
                          }
                        : null,
                  ),
                  const Divider(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    activeThumbColor: const Color(0xFF0F766E),
                    title: const Text(
                      '⏰ সঠিক সময়ে নোটিফিকেশন',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    subtitle: const Text('নির্ধারিত সময় উপস্থিত হলে চূড়ান্ত তাগাদা',
                        style: TextStyle(fontSize: 11)),
                    value: _alertDue,
                    onChanged: _master
                        ? (val) {
                            setState(() => _alertDue = val);
                            _updatePref(
                                NotificationService.keyAlertAtDueEnabled, val);
                          }
                        : null,
                  ),
                ],
              ),
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('ঠিক আছে',
              style: TextStyle(fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}