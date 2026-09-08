import 'package:flutter/material.dart';

import '../../core/localization/generated/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../models/warranty_product.dart';
import '../../services/warranty_service.dart';
import '../../widgets/empty_state.dart';
import 'warranty_edit_screen.dart';

enum _WarrantyFilter { all, attention, active }

/// Full Warranty Bondhu module: family warranty tracking
/// with executive warranty hero summary, interactive filter pills,
/// category badges, and expiry countdown.
class WarrantyListScreen extends StatefulWidget {
  const WarrantyListScreen({super.key, required this.warrantyService});

  final WarrantyService warrantyService;

  @override
  State<WarrantyListScreen> createState() => _WarrantyListScreenState();
}

class _WarrantyListScreenState extends State<WarrantyListScreen> {
  _WarrantyFilter _filter = _WarrantyFilter.all;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(
          l10n.warrantyListTitle,
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
              color: const Color(0xFF0284C7).withValues(alpha: 0.35),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () => _openEditor(context, null),
          backgroundColor: const Color(0xFF0284C7),
          foregroundColor: AppColors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          icon: const Icon(Icons.add_moderator_rounded, size: 22),
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
        animation: widget.warrantyService.repository as Listenable,
        builder: (context, _) {
          final all = widget.warrantyService.getAll();
          if (all.isEmpty) {
            return EmptyState(
              icon: Icons.verified_outlined,
              title: l10n.warrantyListEmptyTitle,
              message: l10n.warrantyListEmptyBody,
            );
          }
          final expired = all
              .where((w) => w.status == WarrantyStatus.expired)
              .toList();
          final expiring = all
              .where((w) => w.status == WarrantyStatus.expiringSoon)
              .toList();
          final active = all
              .where((w) => w.status == WarrantyStatus.active)
              .toList();
          final attention = [...expired, ...expiring];

          List<WarrantyProduct> displayed;
          switch (_filter) {
            case _WarrantyFilter.all:
              displayed = all;
              break;
            case _WarrantyFilter.attention:
              displayed = attention;
              break;
            case _WarrantyFilter.active:
              displayed = active;
              break;
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
            children: [
              _SummaryCard(
                totalCount: all.length,
                attentionCount: attention.length,
                activeCount: active.length,
              ),
              const SizedBox(height: 16),
              _buildFilterBar(
                allCount: all.length,
                attentionCount: attention.length,
                activeCount: active.length,
              ),
              const SizedBox(height: 16),
              if (_filter == _WarrantyFilter.all) ...[
                if (expired.isNotEmpty) ...[
                  _SectionLabel(
                    label: l10n.warrantySectionExpired,
                    accent: const Color(0xFFDC2626),
                    count: expired.length,
                  ),
                  const SizedBox(height: 10),
                  ...expired.map((w) => _WarrantyCard(
                        product: w,
                        onTap: () => _openEditor(context, w),
                        onDelete: () => _confirmDelete(context, w),
                      )),
                  const SizedBox(height: 16),
                ],
                if (expiring.isNotEmpty) ...[
                  _SectionLabel(
                    label: l10n.warrantySectionExpiring,
                    accent: const Color(0xFFD97706),
                    count: expiring.length,
                  ),
                  const SizedBox(height: 10),
                  ...expiring.map((w) => _WarrantyCard(
                        product: w,
                        onTap: () => _openEditor(context, w),
                        onDelete: () => _confirmDelete(context, w),
                      )),
                  const SizedBox(height: 16),
                ],
                if (active.isNotEmpty) ...[
                  _SectionLabel(
                    label: l10n.warrantySectionActive,
                    accent: AppColors.brandGreen,
                    count: active.length,
                  ),
                  const SizedBox(height: 10),
                  ...active.map((w) => _WarrantyCard(
                        product: w,
                        onTap: () => _openEditor(context, w),
                        onDelete: () => _confirmDelete(context, w),
                      )),
                ],
              ] else ...[
                if (displayed.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(32),
                    alignment: Alignment.center,
                    child: Text(
                      'এই ফিল্টারে কোনো পণ্য নেই',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                else
                  ...displayed.map((w) => _WarrantyCard(
                        product: w,
                        onTap: () => _openEditor(context, w),
                        onDelete: () => _confirmDelete(context, w),
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
    required int attentionCount,
    required int activeCount,
  }) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _filterPill(_WarrantyFilter.all, 'সকল ($allCount)'),
          _filterPill(_WarrantyFilter.attention, 'জরুরি ($attentionCount)'),
          _filterPill(_WarrantyFilter.active, 'বৈধ ($activeCount)'),
        ],
      ),
    );
  }

  Widget _filterPill(_WarrantyFilter filter, String label) {
    final active = _filter == filter;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _filter = filter),
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

  void _openEditor(BuildContext context, WarrantyProduct? product) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => WarrantyEditScreen(
          warrantyService: widget.warrantyService,
          existing: product,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, WarrantyProduct product) async {
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
      await widget.warrantyService.delete(product.id);
    }
  }
}

/// Header summary card with the total warranty count and an attention badge.
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.totalCount,
    required this.attentionCount,
    required this.activeCount,
  });

  final int totalCount;
  final int attentionCount;
  final int activeCount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasAttention = attentionCount > 0;
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0C4A6E), Color(0xFF0369A1)],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x200369A1),
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
                      l10n.warrantyListTotalLabel,
                      style: const TextStyle(
                        color: Color(0xFFBAE6FD),
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
                        color: Colors.white.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified_user_rounded,
                            size: 13,
                            color: Colors.white,
                          ),
                          SizedBox(width: 5),
                          Text(
                            'গ্যারান্টি ট্র্যাকার',
                            style: TextStyle(
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
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$totalCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 6),
                      child: Text(
                        'টি পণ্যের ওয়ারেন্টি ট্র্যাক করা হচ্ছে',
                        style: TextStyle(
                          color: Color(0xFFE0F2FE),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(22)),
              border: Border(
                top: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        size: 16,
                        color: Color(0xFF34D399),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'সক্রিয় ওয়ারেন্টি: $activeCountটি',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (hasAttention)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF43F5E).withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFFFDA4AF).withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      l10n.warrantyAttentionCount(attentionCount),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
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

class _WarrantyCard extends StatelessWidget {
  const _WarrantyCard({
    required this.product,
    required this.onTap,
    required this.onDelete,
  });

  final WarrantyProduct product;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  IconData _iconFor(WarrantyCategory cat) {
    switch (cat) {
      case WarrantyCategory.electronics:
        return Icons.devices_rounded;
      case WarrantyCategory.appliance:
        return Icons.kitchen_rounded;
      case WarrantyCategory.furniture:
        return Icons.chair_rounded;
      case WarrantyCategory.vehicle:
        return Icons.directions_car_rounded;
      case WarrantyCategory.jewellery:
        return Icons.diamond_rounded;
      case WarrantyCategory.clothing:
        return Icons.checkroom_rounded;
      case WarrantyCategory.other:
        return Icons.inventory_2_rounded;
    }
  }

  Color _colorFor(WarrantyStatus s) {
    switch (s) {
      case WarrantyStatus.active:
        return const Color(0xFF059669);
      case WarrantyStatus.expiringSoon:
        return const Color(0xFFD97706);
      case WarrantyStatus.expired:
        return const Color(0xFFDC2626);
    }
  }

  List<Color> _gradientFor(WarrantyCategory cat) {
    switch (cat) {
      case WarrantyCategory.electronics:
        return const [Color(0xFF0284C7), Color(0xFF0369A1)];
      case WarrantyCategory.appliance:
        return const [Color(0xFFD97706), Color(0xFFB45309)];
      case WarrantyCategory.furniture:
        return const [Color(0xFF7C3AED), Color(0xFF6D28D9)];
      case WarrantyCategory.vehicle:
        return const [Color(0xFF0D9488), Color(0xFF0F766E)];
      case WarrantyCategory.jewellery:
        return const [Color(0xFFE11D48), Color(0xFFBE123C)];
      case WarrantyCategory.clothing:
        return const [Color(0xFF4F46E5), Color(0xFF4338CA)];
      case WarrantyCategory.other:
        return const [Color(0xFF64748B), Color(0xFF475569)];
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final statusColor = _colorFor(product.status);
    final icon = _iconFor(product.category);
    final gradient = _gradientFor(product.category);
    final isExpired = product.status == WarrantyStatus.expired;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isExpired
              ? const Color(0xFFFECACA)
              : const Color(0xFFE8EEF2),
          width: isExpired ? 1.4 : 1,
        ),
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
                        color: gradient.first.withValues(alpha: 0.28),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 22),
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
                              product.productName,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              product.brand,
                              style: const TextStyle(
                                color: Color(0xFF334155),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          if (product.vendor != null &&
                              product.vendor!.isNotEmpty) ...[
                            Flexible(
                              child: Text(
                                product.vendor!,
                                style: const TextStyle(
                                  color: AppColors.inkMuted,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 5),
                              child: Text('•', style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 10)),
                            ),
                          ],
                          Text(
                            'ক্রয়: ${_formatDate(product.purchaseDate)}',
                            style: const TextStyle(
                              color: AppColors.inkMuted,
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2.5,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isExpired
                                  ? Icons.error_outline_rounded
                                  : Icons.verified_rounded,
                              size: 11,
                              color: statusColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _expiryText(l10n, product),
                              style: TextStyle(
                                color: statusColor,
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

  String _expiryText(AppLocalizations l10n, WarrantyProduct p) {
    final days = p.daysUntilExpiry;
    if (days < 0) {
      return l10n.warrantyExpiredDaysAgo(days.abs());
    }
    if (days == 0) return 'আজ মেয়াদ শেষ';
    if (days == 1) return 'আগামীকাল মেয়াদ শেষ';
    return l10n.warrantyDaysLeft(days);
  }

  String _formatDate(DateTime d) {
    return '${d.day}/${d.month}/${d.year}';
  }
}
