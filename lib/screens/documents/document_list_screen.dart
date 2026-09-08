import 'package:flutter/material.dart';

import '../../core/localization/generated/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../models/identity_document.dart';
import '../../services/document_service.dart';
import '../../widgets/empty_state.dart';
import 'document_edit_screen.dart';

enum _DocFilter { all, expiringSoon, valid, expired }

/// Full Document Bondhu module: secure identity documents vault
/// with executive security hero card, interactive filter pills,
/// gradient document badges, and expiry urgency tracking.
class DocumentListScreen extends StatefulWidget {
  const DocumentListScreen({super.key, required this.documentService});

  final DocumentService documentService;

  @override
  State<DocumentListScreen> createState() => _DocumentListScreenState();
}

class _DocumentListScreenState extends State<DocumentListScreen> {
  _DocFilter _filter = _DocFilter.all;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(
          l10n.docsListTitle,
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
              color: const Color(0xFF7C3AED).withValues(alpha: 0.35),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () => _openEditor(context, null),
          backgroundColor: const Color(0xFF7C3AED),
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
      body: SafeArea(
        child: AnimatedBuilder(
          animation: widget.documentService.repository as Listenable,
          builder: (context, _) {
            final docs = widget.documentService.getAll();
            if (docs.isEmpty) {
              return EmptyState(
                icon: Icons.folder_outlined,
                title: l10n.docsListEmptyTitle,
                message: l10n.docsListEmptyBody,
              );
            }
            final expiringSoon = <IdentityDocument>[];
            final valid = <IdentityDocument>[];
            final expired = <IdentityDocument>[];
            for (final d in docs) {
              final days = d.daysUntilExpiry();
              if (days < 0) {
                expired.add(d);
              } else if (days <= 60) {
                expiringSoon.add(d);
              } else {
                valid.add(d);
              }
            }

            List<IdentityDocument> displayed;
            switch (_filter) {
              case _DocFilter.all:
                displayed = docs;
                break;
              case _DocFilter.expiringSoon:
                displayed = expiringSoon;
                break;
              case _DocFilter.valid:
                displayed = valid;
                break;
              case _DocFilter.expired:
                displayed = expired;
                break;
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
              children: [
                _SummaryCard(
                  totalCount: docs.length,
                  validCount: valid.length,
                  expiringCount: expiringSoon.length,
                  expiredCount: expired.length,
                ),
                const SizedBox(height: 16),
                _buildFilterBar(
                  allCount: docs.length,
                  expiringCount: expiringSoon.length,
                  validCount: valid.length,
                  expiredCount: expired.length,
                ),
                const SizedBox(height: 16),
                if (_filter == _DocFilter.all) ...[
                  if (expiringSoon.isNotEmpty) ...[
                    _SectionLabel(
                      title: l10n.docsListExpiringSoon,
                      count: expiringSoon.length,
                      color: const Color(0xFFD97706),
                    ),
                    const SizedBox(height: 10),
                    ...expiringSoon.map((d) => _DocumentCard(
                          doc: d,
                          onEdit: () => _openEditor(context, d.id),
                          onDelete: () => _confirmDelete(context, d),
                        )),
                    const SizedBox(height: 16),
                  ],
                  if (valid.isNotEmpty) ...[
                    _SectionLabel(
                      title: l10n.docsListValid,
                      count: valid.length,
                      color: AppColors.brandGreen,
                    ),
                    const SizedBox(height: 10),
                    ...valid.map((d) => _DocumentCard(
                          doc: d,
                          onEdit: () => _openEditor(context, d.id),
                          onDelete: () => _confirmDelete(context, d),
                        )),
                    const SizedBox(height: 16),
                  ],
                  if (expired.isNotEmpty) ...[
                    _SectionLabel(
                      title: l10n.docsListExpired,
                      count: expired.length,
                      color: const Color(0xFFDC2626),
                    ),
                    const SizedBox(height: 10),
                    ...expired.map((d) => _DocumentCard(
                          doc: d,
                          onEdit: () => _openEditor(context, d.id),
                          onDelete: () => _confirmDelete(context, d),
                        )),
                  ],
                ] else ...[
                  if (displayed.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(32),
                      alignment: Alignment.center,
                      child: Text(
                        'এই ফিল্টারে কোনো নথি পাওয়া যায়নি',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  else
                    ...displayed.map((d) => _DocumentCard(
                          doc: d,
                          onEdit: () => _openEditor(context, d.id),
                          onDelete: () => _confirmDelete(context, d),
                        )),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFilterBar({
    required int allCount,
    required int expiringCount,
    required int validCount,
    required int expiredCount,
  }) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _filterPill(_DocFilter.all, 'সকল ($allCount)'),
          _filterPill(_DocFilter.expiringSoon, 'আসন্ন ($expiringCount)'),
          _filterPill(_DocFilter.valid, 'বৈধ ($validCount)'),
          if (expiredCount > 0)
            _filterPill(_DocFilter.expired, 'উত্তীর্ণ ($expiredCount)'),
        ],
      ),
    );
  }

  Widget _filterPill(_DocFilter filter, String label) {
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
              fontSize: 11.5,
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

  void _openEditor(BuildContext context, String? id) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DocumentEditScreen(
          documentService: widget.documentService,
          documentId: id,
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, IdentityDocument doc) async {
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
      await widget.documentService.delete(doc.id);
    }
  }
}

/// Executive secure vault summary card.
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.totalCount,
    required this.validCount,
    required this.expiringCount,
    required this.expiredCount,
  });

  final int totalCount;
  final int validCount;
  final int expiringCount;
  final int expiredCount;

  @override
  Widget build(BuildContext context) {
    final hasWarning = expiringCount > 0 || expiredCount > 0;
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3B0764), Color(0xFF6B21A8)],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x206B21A8),
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
                    const Text(
                      'সুরক্ষিত ডিজিটাল নথি ভল্ট',
                      style: TextStyle(
                        color: Color(0xFFE9D5FF),
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
                            Icons.shield_rounded,
                            size: 13,
                            color: Colors.white,
                          ),
                          SizedBox(width: 5),
                          Text(
                            'এনক্রিপ্টেড',
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
                        'টি প্রয়োজনীয় সরকারি ও জরুরি নথি সংরক্ষিত',
                        style: TextStyle(
                          color: Color(0xFFF3E8FF),
                          fontSize: 12.5,
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
                        'বৈধ নথি: $validCountটি',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (hasWarning)
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
                      expiredCount > 0
                          ? '$expiredCountটির মেয়াদ শেষ!'
                          : '$expiringCountটির নবায়ন প্রয়োজন',
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
    required this.title,
    required this.count,
    required this.color,
  });
  final String title;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              color: color,
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _DocumentCard extends StatelessWidget {
  const _DocumentCard({
    required this.doc,
    required this.onEdit,
    required this.onDelete,
  });

  final IdentityDocument doc;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  IconData _iconFor(DocumentType t) {
    switch (t) {
      case DocumentType.nid:
        return Icons.badge_rounded;
      case DocumentType.passport:
        return Icons.menu_book_rounded;
      case DocumentType.drivingLicense:
        return Icons.directions_car_rounded;
      case DocumentType.vehicleFitness:
        return Icons.local_taxi_rounded;
      case DocumentType.tradeLicense:
        return Icons.storefront_rounded;
      case DocumentType.bankCard:
        return Icons.credit_card_rounded;
      case DocumentType.insurance:
        return Icons.health_and_safety_rounded;
      case DocumentType.certificate:
        return Icons.workspace_premium_rounded;
      case DocumentType.other:
        return Icons.description_rounded;
    }
  }

  Color _colorForStatus(int days) {
    if (days < 0) return const Color(0xFFDC2626);
    if (days <= 30) return const Color(0xFFD97706);
    if (days <= 60) return const Color(0xFF7C3AED);
    return const Color(0xFF059669);
  }

  List<Color> _gradientForType(DocumentType t) {
    switch (t) {
      case DocumentType.nid:
        return const [Color(0xFF0D9488), Color(0xFF0F766E)];
      case DocumentType.passport:
        return const [Color(0xFF1E3A8A), Color(0xFF1D4ED8)];
      case DocumentType.drivingLicense:
        return const [Color(0xFFEA580C), Color(0xFFC2410C)];
      case DocumentType.vehicleFitness:
        return const [Color(0xFFD97706), Color(0xFFB45309)];
      case DocumentType.tradeLicense:
        return const [Color(0xFF7C3AED), Color(0xFF6D28D9)];
      case DocumentType.bankCard:
        return const [Color(0xFF0284C7), Color(0xFF0369A1)];
      case DocumentType.insurance:
        return const [Color(0xFF059669), Color(0xFF047857)];
      case DocumentType.certificate:
        return const [Color(0xFFBE123C), Color(0xFF9F1239)];
      case DocumentType.other:
        return const [Color(0xFF64748B), Color(0xFF475569)];
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final days = doc.daysUntilExpiry();
    final statusColor = _colorForStatus(days);
    final icon = _iconFor(doc.type);
    final gradient = _gradientForType(doc.type);

    final expiryLabel = days < 0
        ? l10n.docsExpiredOn(_formatDate(doc.expiryDate, l10n))
        : l10n.docsExpiringIn(days);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: days <= 60
              ? statusColor.withValues(alpha: 0.3)
              : const Color(0xFFE8EEF2),
          width: days <= 60 ? 1.4 : 1,
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
          onTap: onEdit,
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
                      Text(
                        doc.label,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (doc.number != null && doc.number!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1.5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            doc.number!,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              color: Color(0xFF334155),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                      if (doc.issuer != null && doc.issuer!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          doc.issuer!,
                          style: const TextStyle(
                            color: AppColors.inkMuted,
                            fontSize: 11.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 6),
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
                              days < 0
                                  ? Icons.error_outline_rounded
                                  : Icons.event_available_rounded,
                              size: 11,
                              color: statusColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              expiryLabel,
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

  String _formatDate(DateTime d, AppLocalizations l10n) {
    return '${d.day}/${d.month}/${d.year}';
  }
}