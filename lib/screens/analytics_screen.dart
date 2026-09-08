import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../models/bill.dart';
import '../models/money_entry.dart';
import '../services/bill_service.dart';
import '../services/money_service.dart';
import '../services/report/financial_statement_service.dart';
import '../widgets/app_top_header.dart';
import 'money/money_edit_screen.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({
    super.key,
    required this.moneyService,
    required this.billService,
  });

  final MoneyService moneyService;
  final BillService billService;

  void _openMoneyEditor(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MoneyEditScreen(moneyService: moneyService),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openMoneyEditor(context),
        backgroundColor: AppColors.brandGreen,
        foregroundColor: AppColors.white,
        elevation: 4,
        icon: const Icon(Icons.add_rounded, size: 22),
        label: const Text(
          'নতুন লেনদেন',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            letterSpacing: 0.2,
          ),
        ),
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: Listenable.merge([
            moneyService.repository as Listenable,
            billService.repository as Listenable,
          ]),
          builder: (context, _) {
            final moneyEntries = moneyService.getAll();
            final bills = billService.getAll();

            double totalReceivable = 0;
            double totalPayable = 0;
            for (final m in moneyEntries) {
              if (m.direction == MoneyDirection.receive) {
                totalReceivable += m.amount;
              } else {
                totalPayable += m.amount;
              }
            }
            final netBalance = totalReceivable - totalPayable;

            double totalBillsAmount = 0;
            int paidBillsCount = 0;
            int unpaidBillsCount = 0;
            for (final b in bills) {
              totalBillsAmount += b.amount;
              if (b.autoPay) {
                paidBillsCount++;
              } else {
                unpaidBillsCount++;
              }
            }

            return Column(
              children: [
                const AppTopHeader(),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xxl,
                      AppSpacing.xxl,
                      AppSpacing.xxl,
                      88,
                    ),
                    children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'হিসাব ও অ্যানালিটিক্স',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink,
                              ),
                        ),
                        FilledButton.tonalIcon(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.brandGreenLight,
                            foregroundColor: AppColors.brandGreenDark,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          ),
                          onPressed: () => FinancialStatementService.shareStatement(
                            context: context,
                            moneyService: moneyService,
                            billService: billService,
                          ),
                          icon: const Icon(Icons.share_outlined, size: 16),
                          label: const Text(
                            'স্টেটমেন্ট',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Net financial balance summary card
                  _buildNetCard(netBalance, totalReceivable, totalPayable),
            const SizedBox(height: AppSpacing.xl),

            // Receivables & Payables breakdown
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    title: 'মোট পাওনা',
                    amount: totalReceivable,
                    icon: Icons.call_received,
                    color: AppColors.brandGreen,
                    onTap: () => context.push('/money'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _buildMetricCard(
                    title: 'মোট দেনা',
                    amount: totalPayable,
                    icon: Icons.call_made,
                    color: AppColors.critical,
                    onTap: () => context.push('/money'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Bills Analysis Section
            Text(
              'ইউটিলিটি বিলের অবস্থা',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppSpacing.md),
            _buildBillsCard(
              context,
              totalAmount: totalBillsAmount,
              paidCount: paidBillsCount,
              unpaidCount: unpaidBillsCount,
              bills: bills,
            ),
          ],
        ),
      ),
    ],
  );
        },
      ),
    ),
  );
}

  Widget _buildNetCard(double net, double rec, double pay) {
    final isPositive = net >= 0;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: isPositive
              ? const [
                  Color(0xFF063321),
                  Color(0xFF0B4D33),
                  Color(0xFF07291B),
                ]
              : const [
                  Color(0xFF7F1D1D),
                  Color(0xFF991B1B),
                  Color(0xFF450A0A),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: (isPositive ? const Color(0xFF063321) : const Color(0xFF7F1D1D))
                .withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
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
                            decoration: BoxDecoration(
                              color: isPositive
                                  ? const Color(0xFF4ADE80)
                                  : const Color(0xFFF87171),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'নেট আর্থিক ব্যালেন্স',
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
                          isPositive ? 'পজিটিভ (উদ্বৃত্ত)' : 'নেগেটিভ (ঘাটতি)',
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
                    '৳${net.abs().toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 18),
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
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('পাওনা',
                                        style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 11)),
                                    const SizedBox(height: 2),
                                    Text(
                                      '৳${rec.toStringAsFixed(0)}',
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
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('দেনা',
                                        style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 11)),
                                    const SizedBox(height: 2),
                                    Text(
                                      '৳${pay.toStringAsFixed(0)}',
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

  Widget _buildMetricCard({
    required String title,
    required double amount,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: color, size: 18),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      color: AppColors.inkMuted, size: 18),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.inkMuted,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '৳${amount.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: color,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBillsCard(
    BuildContext context, {
    required double totalAmount,
    required int paidCount,
    required int unpaidCount,
    required List<Bill> bills,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.6)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('চলতি মাসের মোট বিল',
                        style: TextStyle(color: AppColors.inkMuted, fontSize: 13)),
                    const SizedBox(height: 2),
                    Text('৳${totalAmount.toStringAsFixed(0)}',
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.ink)),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              OutlinedButton(
                onPressed: () => context.push('/bills'),
                child: const Text('সব বিল দেখুন'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm + 2,
                    vertical: AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.brandGreenLight,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle,
                          color: AppColors.brandGreen, size: 18),
                      const SizedBox(width: 6),
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'পরিশোধিত: $paidCount টি',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.brandGreenDark,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm + 2,
                    vertical: AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.critical.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.pending_actions,
                          color: AppColors.critical, size: 18),
                      const SizedBox(width: 6),
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'বাকি: $unpaidCount টি',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.critical,
                            ),
                          ),
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
    );
  }
}
