import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/bill.dart';
import '../../models/money_entry.dart';
import '../../services/bill_service.dart';
import '../../services/money_service.dart';

/// Service to generate clear, structured financial statements in Bengali.
class FinancialStatementService {
  static String generateStatementText({
    required List<MoneyEntry> moneyEntries,
    required List<Bill> bills,
  }) {
    final now = DateTime.now();
    final dateStr = '${now.day}/${now.month}/${now.year}';

    final receiveEntries =
        moneyEntries.where((m) => m.direction == MoneyDirection.receive).toList();
    final payEntries =
        moneyEntries.where((m) => m.direction == MoneyDirection.pay).toList();

    double totalReceive = 0;
    for (final r in receiveEntries) {
      totalReceive += r.amount;
    }

    double totalPay = 0;
    for (final p in payEntries) {
      totalPay += p.amount;
    }

    double totalBills = 0;
    int unpaidBillsCount = 0;
    for (final b in bills) {
      totalBills += b.amount;
      if (!b.autoPay) unpaidBillsCount++;
    }

    final netBalance = totalReceive - totalPay;

    final buf = StringBuffer();
    buf.writeln('📋 সেবা বন্ধু — আর্থিক হিসাব বিবরণী');
    buf.writeln('তারিখ: $dateStr');
    buf.writeln('-----------------------------------');
    buf.writeln('💵 নিট ব্যালেন্স: ৳${netBalance.toStringAsFixed(0)}');
    buf.writeln('💰 মোট পাওনা টাকা: ৳${totalReceive.toStringAsFixed(0)}');
    buf.writeln('💸 মোট দেনা টাকা: ৳${totalPay.toStringAsFixed(0)}');
    buf.writeln('⚡ ইউটিলিটি বিল: ৳${totalBills.toStringAsFixed(0)} (বাকি: $unpaidBillsCount টি)');
    buf.writeln('-----------------------------------');

    if (receiveEntries.isNotEmpty) {
      buf.writeln('\n[পাওনা তালিকা]');
      for (final r in receiveEntries) {
        buf.writeln('• ${r.person}: ৳${r.amount.toStringAsFixed(0)}');
      }
    }

    if (payEntries.isNotEmpty) {
      buf.writeln('\n[দেনা তালিকা]');
      for (final p in payEntries) {
        buf.writeln('• ${p.person}: ৳${p.amount.toStringAsFixed(0)}');
      }
    }

    if (bills.isNotEmpty) {
      buf.writeln('\n[বিল ও ইউটিলিটি]');
      for (final b in bills) {
        final status = b.autoPay ? 'পরিশোধিত' : 'বকেয়া';
        buf.writeln('• ${b.label} (${b.provider}): ৳${b.amount.toStringAsFixed(0)} [$status]');
      }
    }

    buf.writeln('\nসতর্কতা: এই বিবরণীটি ‘সেবা বন্ধু’ ডিজিটাল অ্যাসিস্ট্যান্ট অ্যাপ থেকে তৈরি।');
    return buf.toString();
  }

  /// Exports and shares the statement.
  static void shareStatement({
    required BuildContext context,
    required MoneyService moneyService,
    required BillService billService,
  }) {
    final moneyList = moneyService.getAll();
    final billList = billService.getAll();

    final text = generateStatementText(
      moneyEntries: moneyList,
      bills: billList,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.outline,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.brandGreenLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.description_rounded,
                      color: AppColors.brandGreen,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  const Expanded(
                    child: Text(
                      'আর্থিক স্টেটমেন্ট শেয়ার করুন',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                constraints: const BoxConstraints(maxHeight: 260),
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.outline),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    text,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      height: 1.45,
                      color: AppColors.ink,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.brandGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    // ignore: deprecated_member_use
                    Share.share(text, subject: 'সেবা বন্ধু — আর্থিক হিসাব বিবরণী');
                  },
                  icon: const Icon(Icons.share_rounded, size: 20),
                  label: const Text(
                    'বিবরণী শেয়ার করুন',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
