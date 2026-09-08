import 'package:flutter/material.dart';

import '../../core/localization/generated/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../models/bill.dart';
import '../../models/recurring.dart';
import '../../services/bill_service.dart';
import '../../widgets/due_label.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/severity_chip.dart';
import 'bill_edit_screen.dart';

enum _BillFilter { all, upcoming, later }

/// Full Bill Bondhu module: executive utility hero summary, interactive filters,
/// modern utility cards with provider badge, due tags, auto-pay chips, and swipeable actions.
class BillListScreen extends StatefulWidget {
  const BillListScreen({super.key, required this.billService});

  final BillService billService;

  @override
  State<BillListScreen> createState() => _BillListScreenState();
}

class _BillListScreenState extends State<BillListScreen> {
  _BillFilter _currentFilter = _BillFilter.all;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(
          l10n.billListTitle,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
            letterSpacing: 0.2,
          ),
        ),
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFE8EEF2)),
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: AppColors.brandGreen.withValues(alpha: 0.35),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () => _openEditor(context, null),
          backgroundColor: AppColors.brandGreen,
          foregroundColor: AppColors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          icon: const Icon(Icons.add_rounded, size: 22),
          label: Text(
            l10n.commonAdd,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
      body: AnimatedBuilder(
        animation: widget.billService.repository as Listenable,
        builder: (context, _) {
          final all = widget.billService.getAll();
          if (all.isEmpty) {
            return EmptyState(
              icon: Icons.receipt_long_outlined,
              title: l10n.billListEmptyTitle,
              message: l10n.billListEmptyBody,
            );
          }
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          final upcoming = all
              .where((b) =>
                  b.nextDueDate.difference(today).inDays <= 7 && !b.autoPay)
              .toList();
          final later = all
              .where((b) =>
                  b.nextDueDate.difference(today).inDays > 7 || b.autoPay)
              .toList();
          final monthlyTotal =
              all.fold<double>(0, (sum, b) => sum + b.amount);
          final autoPayCount = all.where((b) => b.autoPay).length;

          List<Bill> displayedBills;
          switch (_currentFilter) {
            case _BillFilter.all:
              displayedBills = all;
              break;
            case _BillFilter.upcoming:
              displayedBills = upcoming;
              break;
            case _BillFilter.later:
              displayedBills = later;
              break;
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
            children: [
              _SummaryCard(
                total: monthlyTotal,
                autoPayCount: autoPayCount,
                totalCount: all.length,
                upcomingCount: upcoming.length,
              ),
              const SizedBox(height: 16),
              // Segmented Filter Bar
              _buildFilterBar(allCount: all.length, upcomingCount: upcoming.length, laterCount: later.length),
              const SizedBox(height: 16),
              if (_currentFilter == _BillFilter.all) ...[
                if (upcoming.isNotEmpty) ...[
                  _SectionLabel(
                    label: l10n.billSectionUpcoming,
                    accent: const Color(0xFFEF4444),
                    count: upcoming.length,
                  ),
                  const SizedBox(height: 10),
                  ...upcoming.map((b) => _BillCard(
                        bill: b,
                        onTap: () => _openEditor(context, b),
                        onDelete: () => _confirmDelete(context, b),
                      )),
                  const SizedBox(height: 16),
                ],
                if (later.isNotEmpty) ...[
                  _SectionLabel(
                    label: l10n.billSectionLater,
                    accent: AppColors.brandGreen,
                    count: later.length,
                  ),
                  const SizedBox(height: 10),
                  ...later.map((b) => _BillCard(
                        bill: b,
                        onTap: () => _openEditor(context, b),
                        onDelete: () => _confirmDelete(context, b),
                      )),
                ],
              ] else ...[
                if (displayedBills.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(32),
                    alignment: Alignment.center,
                    child: Text(
                      'এই ফিল্টারে কোনো বিল নেই',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                else
                  ...displayedBills.map((b) => _BillCard(
                        bill: b,
                        onTap: () => _openEditor(context, b),
                        onDelete: () => _confirmDelete(context, b),
                      )),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterBar({
    required int allCount,
    required int upcomingCount,
    required int laterCount,
  }) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _filterPill(_BillFilter.all, 'সকল বিল ($allCount)'),
          _filterPill(_BillFilter.upcoming, 'জরুরি ($upcomingCount)'),
          _filterPill(_BillFilter.later, 'অন্যান্য ($laterCount)'),
        ],
      ),
    );
  }

  Widget _filterPill(_BillFilter filter, String label) {
    final active = _currentFilter == filter;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentFilter = filter),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: active ? AppColors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: active
                ? const [
                    BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: active ? FontWeight.w800 : FontWeight.w600,
              color: active ? AppColors.ink : AppColors.inkMuted,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  void _openEditor(BuildContext context, Bill? bill) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BillEditScreen(
          billService: widget.billService,
          existing: bill,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Bill bill) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(l10n.deleteConfirmTitle),
        content: Text(l10n.deleteConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
    );
    if (ok == true) {
      await widget.billService.delete(bill.id);
    }
  }
}

/// Executive header summary card with monthly total, auto-pay metrics, and near-due badge.
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.total,
    required this.autoPayCount,
    required this.totalCount,
    required this.upcomingCount,
  });

  final double total;
  final int autoPayCount;
  final int totalCount;
  final int upcomingCount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F0F172A),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.billListTotalLabel,
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.receipt_rounded,
                            size: 13,
                            color: Color(0xFF38BDF8),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'মোট বিল: $totalCountটি',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '৳${_formatMoney(total)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(22)),
              border: Border(
                top: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.bolt_rounded,
                        size: 16,
                        color: Color(0xFFFBBF24),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        l10n.billListPaidCount(autoPayCount, totalCount),
                        style: const TextStyle(
                          color: Color(0xFFCBD5E1),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (upcomingCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircleAvatar(
                          radius: 3,
                          backgroundColor: Color(0xFFEF4444),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '$upcomingCountটি বিল জরুরি',
                          style: const TextStyle(
                            color: Color(0xFFFCA5A5),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
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

  static String _formatMoney(double v) {
    final whole = v.toStringAsFixed(0);
    final buf = StringBuffer();
    for (int i = 0; i < whole.length; i++) {
      if (i > 0 && (whole.length - i) % 3 == 0) buf.write(',');
      buf.write(whole[i]);
    }
    return buf.toString();
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({
    required this.label,
    required this.accent,
    this.count,
  });
  final String label;
  final Color accent;
  final int? count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: accent,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
        ),
        if (count != null)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                color: accent,
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
      ],
    );
  }
}

class _BillCard extends StatelessWidget {
  const _BillCard({
    required this.bill,
    required this.onTap,
    required this.onDelete,
  });

  final Bill bill;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final typeColor = _colorFor(bill.type);
    final typeIcon = _iconFor(bill.type);
    final gradient = _gradientFor(bill.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8EEF2)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: typeColor.withValues(alpha: 0.25),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(typeIcon, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              bill.label,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '৳${_formatMoney(bill.amount)}',
                            style: TextStyle(
                              color: typeColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              bill.provider,
                              style: const TextStyle(
                                color: AppColors.inkMuted,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          _Dot(),
                          Text(
                            _typeLabel(l10n, bill.type),
                            style: const TextStyle(
                              color: AppColors.inkMuted,
                              fontSize: 12,
                            ),
                          ),
                          if (bill.autoPay) ...[
                            _Dot(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.bolt_rounded, size: 11, color: Color(0xFFD97706)),
                                  SizedBox(width: 2),
                                  Text(
                                    'AutoPay',
                                    style: TextStyle(
                                      color: Color(0xFFB45309),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Flexible(
                            child: DueLabel(when: bill.nextDueDate),
                          ),
                          if (bill.recurring != Recurring.none) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFECFDF5),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(
                                Icons.autorenew_rounded,
                                size: 12,
                                color: Color(0xFF059669),
                              ),
                            ),
                          ],
                          const Spacer(),
                          SeverityChip(severity: bill.severity),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  tooltip: l10n.commonDelete,
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline_rounded),
                  color: AppColors.inkMuted,
                  iconSize: 20,
                  splashRadius: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static IconData _iconFor(BillType t) {
    switch (t) {
      case BillType.electricity:
        return Icons.bolt_rounded;
      case BillType.gas:
        return Icons.local_fire_department_rounded;
      case BillType.water:
        return Icons.water_drop_rounded;
      case BillType.internet:
        return Icons.wifi_rounded;
      case BillType.tv:
        return Icons.tv_rounded;
      case BillType.mobile:
        return Icons.phone_iphone_rounded;
      case BillType.other:
        return Icons.receipt_long_rounded;
    }
  }

  static Color _colorFor(BillType t) {
    switch (t) {
      case BillType.electricity:
        return const Color(0xFFD97706);
      case BillType.gas:
        return const Color(0xFFDC2626);
      case BillType.water:
        return const Color(0xFF0284C7);
      case BillType.internet:
        return const Color(0xFF059669);
      case BillType.tv:
        return const Color(0xFF7C3AED);
      case BillType.mobile:
        return const Color(0xFF0D9488);
      case BillType.other:
        return const Color(0xFF64748B);
    }
  }

  static List<Color> _gradientFor(BillType t) {
    switch (t) {
      case BillType.electricity:
        return const [Color(0xFFF59E0B), Color(0xFFD97706)];
      case BillType.gas:
        return const [Color(0xFFEF4444), Color(0xFFDC2626)];
      case BillType.water:
        return const [Color(0xFF38BDF8), Color(0xFF0284C7)];
      case BillType.internet:
        return const [Color(0xFF10B981), Color(0xFF059669)];
      case BillType.tv:
        return const [Color(0xFFA78BFA), Color(0xFF7C3AED)];
      case BillType.mobile:
        return const [Color(0xFF14B8A6), Color(0xFF0D9488)];
      case BillType.other:
        return const [Color(0xFF94A3B8), Color(0xFF64748B)];
    }
  }

  static String _typeLabel(AppLocalizations l10n, BillType t) {
    switch (t) {
      case BillType.electricity:
        return l10n.billTypeElectricity;
      case BillType.gas:
        return l10n.billTypeGas;
      case BillType.water:
        return l10n.billTypeWater;
      case BillType.internet:
        return l10n.billTypeInternet;
      case BillType.tv:
        return l10n.billTypeTv;
      case BillType.mobile:
        return l10n.billTypeMobile;
      case BillType.other:
        return l10n.billTypeOther;
    }
  }

  static String _formatMoney(double v) {
    final whole = v.toStringAsFixed(0);
    final buf = StringBuffer();
    for (int i = 0; i < whole.length; i++) {
      if (i > 0 && (whole.length - i) % 3 == 0) buf.write(',');
      buf.write(whole[i]);
    }
    return buf.toString();
  }
}

class _Dot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 5),
      child: Text('•', style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 10)),
    );
  }
}
