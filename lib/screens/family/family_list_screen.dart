import 'package:flutter/material.dart';

import '../../core/localization/generated/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../models/family_member.dart';
import '../../services/family_service.dart';
import '../../widgets/empty_state.dart';
import 'family_edit_screen.dart';

/// Family Bondhu: list of family members with luxury avatar, blood-group badge,
/// age, and quick tags for phone + NID.
class FamilyListScreen extends StatelessWidget {
  const FamilyListScreen({super.key, required this.familyService});

  final FamilyService familyService;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        title: Text(
          l10n.familyListTitle,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: AppColors.ink,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE5E9EB)),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                size: 16, color: AppColors.ink),
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(context, null),
        backgroundColor: const Color(0xFF0F766E),
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.person_add_rounded, size: 20),
        label: Text(
          l10n.commonAdd,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
      ),
      body: AnimatedBuilder(
        animation: familyService.repository as Listenable,
        builder: (context, _) {
          final all = familyService.getAll();
          if (all.isEmpty) {
            return EmptyState(
              icon: Icons.family_restroom_outlined,
              title: l10n.familyListEmptyTitle,
              message: l10n.familyListEmptyBody,
            );
          }
          final donorCount = all.where((m) => m.bloodGroup != BloodGroup.unknown).length;
          final phoneCount = all.where((m) => m.phone != null && m.phone!.isNotEmpty).length;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
            children: [
              _FamilySummaryCard(
                totalCount: all.length,
                donorCount: donorCount,
                phoneCount: phoneCount,
              ),
              const SizedBox(height: 16),
              ...all.map((m) => _MemberCard(
                    member: m,
                    onTap: () => _openEditor(context, m),
                    onDelete: () => _confirmDelete(context, m),
                  )),
            ],
          );
        },
      ),
    );
  }

  void _openEditor(BuildContext context, FamilyMember? member) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => FamilyEditScreen(
          familyService: familyService,
          existing: member,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, FamilyMember member) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.deleteConfirmTitle),
        content: Text(l10n.deleteConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.critical.withValues(alpha: 0.12),
              foregroundColor: AppColors.critical,
            ),
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
    );
    if (ok == true) {
      await familyService.delete(member.id);
    }
  }
}

/// Executive dark teal & emerald hero summary card
class _FamilySummaryCard extends StatelessWidget {
  const _FamilySummaryCard({
    required this.totalCount,
    required this.donorCount,
    required this.phoneCount,
  });

  final int totalCount;
  final int donorCount;
  final int phoneCount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F3D39),
            Color(0xFF134E48),
            Color(0xFF115E59),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF115E59).withValues(alpha: 0.28),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.diversity_1_rounded,
                      color: Color(0xFF5EEAD4),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    l10n.familyListTotalLabel,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF5EEAD4).withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF5EEAD4).withValues(alpha: 0.35),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shield_rounded, size: 12, color: Color(0xFF5EEAD4)),
                    SizedBox(width: 4),
                    Text(
                      'সুরক্ষিত প্রোফাইল',
                      style: TextStyle(
                        color: Color(0xFF5EEAD4),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$totalCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'জন সদস্য',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.water_drop_rounded,
                          size: 15, color: Color(0xFFFCA5A5)),
                      const SizedBox(width: 6),
                      Text(
                        'রক্তের গ্রুপ: $donorCount জন',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 16,
                  color: Colors.white.withValues(alpha: 0.20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.contact_phone_rounded,
                          size: 15, color: Color(0xFF5EEAD4)),
                      const SizedBox(width: 6),
                      Text(
                        'ফোন সংরক্ষিত: $phoneCount জন',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
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
        ],
      ),
    );
  }
}

class _MemberCard extends StatelessWidget {
  const _MemberCard({
    required this.member,
    required this.onTap,
    required this.onDelete,
  });

  final FamilyMember member;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final accent = relationColor(member.relation);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8EEF2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            accent.withValues(alpha: 0.22),
                            accent.withValues(alpha: 0.08),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: accent.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          avatarInitial(member.name),
                          style: TextStyle(
                            color: accent,
                            fontWeight: FontWeight.w800,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            member.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _relationLabel(l10n, member.relation),
                              style: TextStyle(
                                color: accent,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (member.bloodGroup != BloodGroup.unknown)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFFEF4444).withValues(alpha: 0.28),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.water_drop_rounded,
                              size: 13,
                              color: Color(0xFFDC2626),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              member.bloodGroup.label,
                              style: const TextStyle(
                                color: Color(0xFFDC2626),
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _chips(context, l10n),
                ),
                if (member.note != null && member.note!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    member.note!,
                    style: const TextStyle(
                      color: AppColors.inkMuted,
                      fontSize: 12,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: onTap,
                      icon: const Icon(Icons.edit_outlined, size: 14),
                      label: const Text('সম্পাদনা', style: TextStyle(fontSize: 12)),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF0F766E),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                    IconButton(
                      tooltip: l10n.commonDelete,
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline_rounded, size: 18),
                      color: AppColors.inkMuted,
                      visualDensity: VisualDensity.compact,
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

  List<Widget> _chips(BuildContext context, AppLocalizations l10n) {
    final out = <Widget>[];

    final age = member.age;
    if (age != null) {
      out.add(_MemberInfoChip(
        icon: Icons.cake_outlined,
        label: l10n.familyAgeYears(age),
        color: const Color(0xFFD97706),
      ));
    }

    if (member.phone != null && member.phone!.isNotEmpty) {
      out.add(_MemberInfoChip(
        icon: Icons.phone_android_rounded,
        label: member.phone!,
        color: const Color(0xFF059669),
      ));
    }

    if (member.nid != null && member.nid!.isNotEmpty) {
      out.add(_MemberInfoChip(
        icon: Icons.badge_outlined,
        label: member.nid!,
        color: const Color(0xFF475569),
      ));
    }

    return out;
  }

  static String _relationLabel(AppLocalizations l10n, FamilyRelation r) {
    switch (r) {
      case FamilyRelation.self:
        return l10n.familyRelationSelf;
      case FamilyRelation.spouse:
        return l10n.familyRelationSpouse;
      case FamilyRelation.father:
        return l10n.familyRelationFather;
      case FamilyRelation.mother:
        return l10n.familyRelationMother;
      case FamilyRelation.son:
        return l10n.familyRelationSon;
      case FamilyRelation.daughter:
        return l10n.familyRelationDaughter;
      case FamilyRelation.brother:
        return l10n.familyRelationBrother;
      case FamilyRelation.sister:
        return l10n.familyRelationSister;
      case FamilyRelation.grandfather:
        return l10n.familyRelationGrandfather;
      case FamilyRelation.grandmother:
        return l10n.familyRelationGrandmother;
      case FamilyRelation.other:
        return l10n.familyRelationOther;
    }
  }
}

class _MemberInfoChip extends StatelessWidget {
  const _MemberInfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
