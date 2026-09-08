import 'package:flutter/material.dart';

import '../../core/localization/generated/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../models/money_entry.dart';
import '../../models/recurring.dart';
import '../../services/money_service.dart';
import '../../services/reminder/reminder_message_service.dart';
import '../../widgets/due_label.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/severity_chip.dart';
import 'money_edit_screen.dart';

enum _MoneyFilter { all, receive, pay }

/// Full production-grade Money Manager screen with executive balance hero,
/// interactive filter tabs, smart WhatsApp reminders, and spacious modern cards.
class MoneyListScreen extends StatefulWidget {
  const MoneyListScreen({super.key, required this.moneyService});

  final MoneyService moneyService;

  @override
  State<MoneyListScreen> createState() => _MoneyListScreenState();
}

class _MoneyListScreenState extends State<MoneyListScreen> {
  _MoneyFilter _filter = _MoneyFilter.all;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'লেনদেন হিসাব খাতা',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(context, null),
        backgroundColor: AppColors.brandGreen,
        foregroundColor: AppColors.white,
        elevation: 4,
        icon: const Icon(Icons.add_rounded, size: 22),
        label: const Text(
          'নতুন এন্ট্রি',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
      ),
      body: AnimatedBuilder(
        animation: widget.moneyService.repository as Listenable,
        builder: (context, _) {
          final all = widget.moneyService.getAll();
          if (all.isEmpty) {
            return EmptyState(
              icon: Icons.account_balance_wallet_outlined,
              title: l10n.moneyListEmptyTitle,
              message: l10n.moneyListEmptyBody,
            );
          }

          final receive = all
              .where((e) => e.direction == MoneyDirection.receive)
              .toList();
          final pay =
              all.where((e) => e.direction == MoneyDirection.pay).toList();
          final receiveTotal =
              receive.fold<double>(0, (sum, e) => sum + e.amount);
          final payTotal = pay.fold<double>(0, (sum, e) => sum + e.amount);
          final netBalance = receiveTotal - payTotal;

          List<MoneyEntry> displayed;
          if (_filter == _MoneyFilter.receive) {
            displayed = receive;
          } else if (_filter == _MoneyFilter.pay) {
            displayed = pay;
          } else {
            displayed = all;
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 96),
            children: [
              // Executive Hero Balance Card
              _buildExecutiveHeroCard(
                netBalance: netBalance,
                receiveTotal: receiveTotal,
                payTotal: payTotal,
              ),
              const SizedBox(height: 18),

              // Filter Tabs
              _buildFilterTabs(
                allCount: all.length,
                receiveCount: receive.length,
                payCount: pay.length,
              ),
              const SizedBox(height: 16),

              if (displayed.isEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.receipt_long_outlined,
                            size: 48, color: AppColors.inkMuted.withValues(alpha: 0.5)),
                        const SizedBox(height: 12),
                        const Text(
                          'এই ক্যাটাগরিতে কোনো লেনদেন নেই',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.inkMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                for (final item in displayed)
                  _MoneyCard(
                    entry: item,
                    onTap: () => _openEditor(context, item),
                    onDelete: () => _confirmDelete(context, item),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildExecutiveHeroCard({
    required double netBalance,
    required double receiveTotal,
    required double payTotal,
  }) {
    final isPositive = netBalance >= 0;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF063321),
            Color(0xFF0B4D33),
            Color(0xFF07291B),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF063321).withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Decorative background glow
            Positioned(
              right: -30,
              top: -30,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
            Positioned(
              left: -40,
              bottom: -40,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.brandGreenVibrant.withValues(alpha: 0.07),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF4ADE80),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'মোট আর্থিক ব্যালেন্স',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isPositive
                              ? const Color(0xFF166534).withValues(alpha: 0.6)
                              : const Color(0xFF991B1B).withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isPositive
                                ? const Color(0xFF4ADE80).withValues(alpha: 0.3)
                                : const Color(0xFFF87171).withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          isPositive ? 'উদ্বৃত্ত (Net +' : 'ঘাটতি (Net -',
                          style: TextStyle(
                            color: isPositive
                                ? const Color(0xFF86EFAC)
                                : const Color(0xFFFCA5A5),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '৳${_fmt(netBalance.abs())}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 18),
                  // Frosted glass breakdown pills
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.12)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF22C55E)
                                      .withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.arrow_downward_rounded,
                                    size: 16, color: Color(0xFF4ADE80)),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'পাওনা (Receive)',
                                      style: TextStyle(
                                          color: Colors.white70, fontSize: 11),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '৳${_fmt(receiveTotal)}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.12)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEF4444)
                                      .withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.arrow_upward_rounded,
                                    size: 16, color: Color(0xFFF87171)),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'দেনা (Pay)',
                                      style: TextStyle(
                                          color: Colors.white70, fontSize: 11),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '৳${_fmt(payTotal)}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
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
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTabs({
    required int allCount,
    required int receiveCount,
    required int payCount,
  }) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildTabItem(
            filter: _MoneyFilter.all,
            title: 'সব লেনদেন',
            count: allCount,
            activeColor: AppColors.brandGreen,
          ),
          const SizedBox(width: 8),
          _buildTabItem(
            filter: _MoneyFilter.receive,
            title: 'পাওনা (Receive)',
            count: receiveCount,
            activeColor: AppColors.brandGreen,
          ),
          const SizedBox(width: 8),
          _buildTabItem(
            filter: _MoneyFilter.pay,
            title: 'দেনা (Pay)',
            count: payCount,
            activeColor: AppColors.critical,
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem({
    required _MoneyFilter filter,
    required String title,
    required int count,
    required Color activeColor,
  }) {
    final isSelected = _filter == filter;
    return InkWell(
      onTap: () => setState(() => _filter = filter),
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? activeColor : const Color(0xFFE2E8F0),
            width: isSelected ? 1.4 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? AppColors.white : AppColors.ink,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.25)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? AppColors.white : AppColors.inkMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(double v) {
    final whole = v.truncate();
    final s = whole.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  void _openEditor(BuildContext context, MoneyEntry? entry) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MoneyEditScreen(
          moneyService: widget.moneyService,
          existing: entry,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, MoneyEntry entry) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.deleteConfirmTitle),
        content: Text('${entry.person} · ৳${entry.amount.toStringAsFixed(0)}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton.tonal(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.criticalSoft,
              foregroundColor: AppColors.critical,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
    );
    if (ok == true) {
      await widget.moneyService.delete(entry.id);
    }
  }
}

class _MoneyCard extends StatelessWidget {
  const _MoneyCard({
    required this.entry,
    required this.onTap,
    required this.onDelete,
  });

  final MoneyEntry entry;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isReceive = entry.direction == MoneyDirection.receive;
    final accent = isReceive ? AppColors.brandGreen : AppColors.critical;
    final initial =
        entry.person.trim().isNotEmpty ? entry.person.trim()[0].toUpperCase() : 'M';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE8EEF2)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x06000000),
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Avatar + Name & Phone + Amount
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Avatar with initial and gradient
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isReceive
                              ? [const Color(0xFF10B981), const Color(0xFF047857)]
                              : [const Color(0xFFF87171), const Color(0xFFB91C1C)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          initial,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.person,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: isReceive
                                      ? AppColors.brandGreenLight
                                      : AppColors.criticalSoft,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  isReceive ? '↓ পাওনা' : '↑ দেনা',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: accent,
                                  ),
                                ),
                              ),
                              if (entry.phoneNumber != null &&
                                  entry.phoneNumber!.isNotEmpty) ...[
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.phone_outlined,
                                          size: 11, color: AppColors.inkMuted),
                                      const SizedBox(width: 3),
                                      Flexible(
                                        child: Text(
                                          entry.phoneNumber!,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: AppColors.inkMuted,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Amount
                    Text(
                      '${isReceive ? '+' : '-'}৳${_formatAmount(entry.amount)}',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: accent,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 10),

                // Bottom Row: Due date & severity on left, actions on right
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.calendar_today_outlined,
                                      size: 11.5, color: AppColors.inkMuted),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: DueLabel(when: entry.dueDate),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (entry.recurring != Recurring.none) ...[
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(6),
                                border:
                                    Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: const Icon(Icons.autorenew_rounded,
                                  size: 12, color: AppColors.accent),
                            ),
                          ],
                          const SizedBox(width: 6),
                          SeverityChip(severity: entry.severity),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),

                    // Action buttons
                    if (isReceive) ...[
                      InkWell(
                        onTap: () =>
                            ReminderMessageService.showReminderBottomSheet(
                          context: context,
                          entry: entry,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8FDF0),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFB9F6CA)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.send_rounded,
                                  size: 12, color: Color(0xFF25D366)),
                              SizedBox(width: 4),
                              Text(
                                'তাগাদা',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF15803D),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    InkWell(
                      onTap: onDelete,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: const Icon(Icons.delete_outline_rounded,
                            size: 17, color: AppColors.inkMuted),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatAmount(double v) {
    final s = v.toStringAsFixed(0);
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}