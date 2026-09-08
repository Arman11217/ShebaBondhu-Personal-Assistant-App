import 'package:flutter/foundation.dart';

import '../../models/ai/parsed_intent.dart';
import '../../models/bill.dart';
import '../../models/identity_document.dart';
import '../../models/medicine.dart';
import '../../models/money_entry.dart';
import '../../models/severity.dart';
import '../../models/sim_card.dart';
import '../../models/task.dart';
import '../bill_service.dart';
import '../document_service.dart';
import '../firebase/firestore_sync_service.dart';
import '../medicine_service.dart';
import '../money_service.dart';
import '../sim_service.dart';
import '../task_service.dart';

/// Result of auto-saving a [ParsedIntent].
class QuickAddSaveResult {
  const QuickAddSaveResult({
    required this.isSuccess,
    required this.message,
    required this.route,
    this.savedId,
  });

  final bool isSuccess;
  final String message;
  final String route;
  final String? savedId;
}

/// Dispatches parsed intents directly into domain services and repositories.
class QuickAddDispatcher {
  const QuickAddDispatcher({
    required this.moneyService,
    required this.billService,
    required this.medicineService,
    required this.simService,
    required this.documentService,
    required this.taskService,
  });

  final MoneyService moneyService;
  final BillService billService;
  final MedicineService medicineService;
  final SimService simService;
  final DocumentService documentService;
  final TaskService taskService;

  /// Automatically parses the intent into the domain model and saves it.
  Future<QuickAddSaveResult> autoSave(ParsedIntent intent) async {
    final now = DateTime.now();

    try {
      switch (intent.module) {
        case QuickAddModule.money:
          final amount = intent.getDouble('amount') ?? 0;
          final person = intent.getString('person') ?? 'নাম উল্লেখ নেই';
          final dirStr = intent.getString('direction') ?? 'receive';
          final direction = dirStr.toLowerCase() == 'give' ||
                  dirStr.toLowerCase() == 'pay'
              ? MoneyDirection.pay
              : MoneyDirection.receive;
          final dueDate = intent.getDate('dueDate') ?? now;
          final phone = intent.getString('phoneNumber') ?? intent.getString('phone');
          final entry = MoneyEntry(
            id: 'm_${DateTime.now().millisecondsSinceEpoch}',
            person: person,
            phoneNumber: phone,
            amount: amount,
            dueDate: dueDate,
            direction: direction,
            severity: Severity.important,
            note: intent.originalText,
          );
          await moneyService.add(entry);
          await FirestoreSyncService.instance.saveMoney(entry);
          final label = direction == MoneyDirection.receive ? 'পাওনা' : 'দেনা';
          return QuickAddSaveResult(
            isSuccess: true,
            message: '$label টাকা যুক্ত হয়েছে: $person (৳${amount.toStringAsFixed(0)})',
            route: '/money',
            savedId: entry.id,
          );

        case QuickAddModule.bill:
          final typeStr = intent.getString('type')?.toLowerCase() ?? 'other';
          final billType = _toBillType(typeStr);
          final amount = intent.getDouble('amount') ?? 0;
          final dueDay = intent.getInt('dueDay');
          DateTime dueDate;
          if (intent.getDate('dueDate') != null) {
            dueDate = intent.getDate('dueDate')!;
          } else if (dueDay != null && dueDay >= 1 && dueDay <= 28) {
            dueDate = DateTime(now.year, now.month, dueDay);
            if (dueDate.isBefore(now)) {
              dueDate = DateTime(now.year, now.month + 1, dueDay);
            }
          } else {
            dueDate = now.add(const Duration(days: 7));
          }

          final billLabel = '${_billTypeName(billType)} বিল';
          final bill = Bill(
            id: 'b_${DateTime.now().millisecondsSinceEpoch}',
            type: billType,
            label: billLabel,
            provider: 'সাধারণ',
            amount: amount,
            nextDueDate: dueDate,
            severity: Severity.important,
            note: intent.originalText,
          );
          await billService.add(bill);
          await FirestoreSyncService.instance.saveBill(bill);
          return QuickAddSaveResult(
            isSuccess: true,
            message: '$billLabel যুক্ত হয়েছে (৳${amount.toStringAsFixed(0)})',
            route: '/bills',
            savedId: bill.id,
          );

        case QuickAddModule.medicine:
          final name = intent.getString('name') ?? 'নতুন ওষুধ';
          final dose = intent.getString('dose') ?? '১ টি';
          final med = Medicine(
            id: 'med_${DateTime.now().millisecondsSinceEpoch}',
            name: name,
            forMember: 'আমি',
            dose: dose,
            frequency: MedicineFrequency.twiceDaily,
            slots: [MedicineSlot.morning, MedicineSlot.night],
            remainingUnits: 30,
            estimatedDaysRemaining: 15,
            note: intent.originalText,
          );
          await medicineService.add(med);
          await FirestoreSyncService.instance.saveMedicine(med);
          return QuickAddSaveResult(
            isSuccess: true,
            message: 'ওষুধ যুক্ত হয়েছে: $name',
            route: '/medicines',
            savedId: med.id,
          );

        case QuickAddModule.sim:
          final carrierStr = intent.getString('carrier')?.toLowerCase() ?? 'other';
          final carrier = _toSimCarrier(carrierStr);
          final amount = intent.getDouble('amount') ?? 100;
          final dataGb = intent.getDouble('dataGb');
          final sim = SimCard(
            id: 'sim_${DateTime.now().millisecondsSinceEpoch}',
            memberName: 'আমি',
            carrier: carrier,
            number: '০১৭xxxxxxxx',
            rechargeAmount: amount,
            dataBalanceGb: dataGb,
            lastRechargeDate: now,
            validityDays: intent.getInt('validityDays') ?? 30,
            note: intent.originalText,
          );
          await simService.add(sim);
          await FirestoreSyncService.instance.saveSim(sim);
          return QuickAddSaveResult(
            isSuccess: true,
            message: 'সিম রিচার্জ সেভ হয়েছে: ${_carrierName(carrier)}',
            route: '/sims',
            savedId: sim.id,
          );

        case QuickAddModule.task:
          final title = intent.getString('title') ??
              (intent.originalText.isNotEmpty ? intent.originalText : 'নতুন কাজ');
          final dueDate = intent.getDate('dueDate') ?? now.add(const Duration(days: 1));
          final task = Task(
            id: 't_${DateTime.now().millisecondsSinceEpoch}',
            title: title,
            dueDate: dueDate,
            priority: TaskPriority.normal,
            status: TaskStatus.pending,
            createdAt: now,
            note: intent.originalText,
          );
          await taskService.add(task);
          await FirestoreSyncService.instance.saveTask(task);
          return QuickAddSaveResult(
            isSuccess: true,
            message: 'টাস্ক যুক্ত হয়েছে: $title',
            route: '/tasks',
            savedId: task.id,
          );

        case QuickAddModule.document:
          final name = intent.getString('name') ?? 'জরুরি নথি';
          final expiry = intent.getDate('expiresAt') ?? now.add(const Duration(days: 365));
          final doc = IdentityDocument(
            id: 'doc_${DateTime.now().millisecondsSinceEpoch}',
            type: DocumentType.nid,
            label: name,
            expiryDate: expiry,
            note: intent.originalText,
          );
          await documentService.add(doc);
          await FirestoreSyncService.instance.saveDocument(doc);
          return QuickAddSaveResult(
            isSuccess: true,
            message: 'ডকুমেন্ট যুক্ত হয়েছে: $name',
            route: '/documents',
            savedId: doc.id,
          );

        case QuickAddModule.unknown:
          return const QuickAddSaveResult(
            isSuccess: false,
            message: 'তথ্যটি নির্দিষ্ট কোনো সেকশনে যুক্ত করা যায়নি।',
            route: '/home',
          );
      }
    } catch (e, st) {
      debugPrint('QuickAdd autoSave failed: $e\n$st');
      return QuickAddSaveResult(
        isSuccess: false,
        message: 'সেভ করতে সমস্যা হয়েছে: $e',
        route: '/home',
      );
    }
  }

  static BillType _toBillType(String type) {
    if (type.contains('elec') || type.contains('বিদ্যুৎ')) {
      return BillType.electricity;
    }
    if (type.contains('gas') || type.contains('গ্যাস')) return BillType.gas;
    if (type.contains('water') || type.contains('পানি')) return BillType.water;
    if (type.contains('inter') || type.contains('wifi') || type.contains('ইন্টারনেট')) {
      return BillType.internet;
    }
    if (type.contains('tv')) return BillType.tv;
    return BillType.other;
  }

  static String _billTypeName(BillType t) {
    switch (t) {
      case BillType.electricity:
        return 'বিদ্যুৎ';
      case BillType.gas:
        return 'গ্যাস';
      case BillType.water:
        return 'পানি';
      case BillType.internet:
        return 'ইন্টারনেট';
      case BillType.tv:
        return 'টিভি';
      case BillType.mobile:
        return 'মোবাইল';
      case BillType.other:
        return 'অন্যান্য';
    }
  }

  static SimCarrier _toSimCarrier(String c) {
    if (c.contains('gp') || c.contains('grameen')) return SimCarrier.grameenphone;
    if (c.contains('robi')) return SimCarrier.robi;
    if (c.contains('cirkle') || c.contains('circle') || c.contains('airtel')) {
      return SimCarrier.airtel;
    }
    if (c.contains('bangla')) return SimCarrier.banglalink;
    if (c.contains('tele')) return SimCarrier.teletalk;
    return SimCarrier.other;
  }

  static String _carrierName(SimCarrier c) {
    switch (c) {
      case SimCarrier.grameenphone:
        return 'গ্রামীণফোন';
      case SimCarrier.robi:
        return 'রবি';
      case SimCarrier.airtel:
        return 'Cirkle';
      case SimCarrier.banglalink:
        return 'বাংলালিংক';
      case SimCarrier.teletalk:
        return 'টেলিটক';
      case SimCarrier.other:
        return 'সিম';
    }
  }
}
