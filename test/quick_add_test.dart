import 'package:flutter_test/flutter_test.dart';
import 'package:sheba_bondhu/models/ai/parsed_intent.dart';
import 'package:sheba_bondhu/models/money_entry.dart';
import 'package:sheba_bondhu/services/ai/gemini_service.dart';
import 'package:sheba_bondhu/services/ai/quick_add_dispatcher.dart';
import 'package:sheba_bondhu/services/bill_service.dart';
import 'package:sheba_bondhu/services/document_service.dart';
import 'package:sheba_bondhu/services/medicine_service.dart';
import 'package:sheba_bondhu/services/money_service.dart';
import 'package:sheba_bondhu/services/sim_service.dart';
import 'package:sheba_bondhu/services/task_service.dart';

void main() {
  group('GeminiService Natural Language Parsing', () {
    late GeminiService service;

    setUp(() {
      service = GeminiService();
    });

    test('Parses money receive intent correctly (e.g. Hadi theke)', () async {
      final res = await service.parse(
          'hedi theke agami maser 10 tarikhe 500 taka pabo');
      expect(res.isOk, isTrue);
      final intent = res.intent!;
      expect(intent.module, equals(QuickAddModule.money));
      expect(intent.getDouble('amount'), equals(500));
      expect(intent.getString('direction'), equals('receive'));
      expect(intent.getString('person')?.toLowerCase(), contains('hedi'));
      expect(intent.getDate('dueDate'), isNotNull);
    });

    test('Parses user Bengali voice input with Bengali digits and date', () async {
      final res = await service.parse(
          'নিবিড় থেকে ১০০০ টাকা পাবো সামনের মাসের ১০ তারিখে');
      expect(res.isOk, isTrue);
      final intent = res.intent!;
      expect(intent.module, equals(QuickAddModule.money));
      expect(intent.getDouble('amount'), equals(1000));
      expect(intent.getString('person'), equals('নিবিড়'));
      expect(intent.getString('direction'), equals('receive'));
      final due = intent.getDate('dueDate');
      expect(due, isNotNull);
      expect(due!.day, equals(10));
    });

    test('Parses money intent with recipient phone number and formats correctly', () async {
      final res = await service.parse(
          'শাকিল থেকে ২০০০ টাকা পাবো ফোন নম্বর ০১৭১২৩৪৫৬৭৮');
      expect(res.isOk, isTrue);
      final intent = res.intent!;
      expect(intent.module, equals(QuickAddModule.money));
      expect(intent.getDouble('amount'), equals(2000));
      expect(intent.getString('person'), equals('শাকিল'));
      expect(intent.getString('direction'), equals('receive'));
      expect(intent.getString('phoneNumber'), equals('01712345678'));
    });

    test('Parses electricity bill intent correctly', () async {
      final res = await service.parse(
          'agami maser electicitu bill dite hone 5 tarikhe');
      expect(res.isOk, isTrue);
      final intent = res.intent!;
      expect(intent.module, equals(QuickAddModule.bill));
      expect(intent.getString('type'), equals('electricity'));
      expect(intent.getInt('dueDay'), equals(5));
    });

    test('Parses Banglish with typos, teka, and give direction', () async {
      final res = await service.parse(
          'biddut bil ditehobe 850 teka 12 tarikhe');
      expect(res.isOk, isTrue);
      final intent = res.intent!;
      expect(intent.module, equals(QuickAddModule.bill));
      expect(intent.getString('type'), equals('electricity'));
      expect(intent.getDouble('amount'), equals(850));
      expect(intent.getInt('dueDay'), equals(12));
    });
  });

  group('QuickAddDispatcher Auto-Save', () {
    late MoneyService moneyService;
    late BillService billService;
    late MedicineService medicineService;
    late SimService simService;
    late DocumentService documentService;
    late TaskService taskService;
    late QuickAddDispatcher dispatcher;

    setUp(() {
      moneyService = MoneyService();
      billService = BillService();
      medicineService = MedicineService();
      simService = SimService();
      documentService = DocumentService();
      taskService = TaskService();
      dispatcher = QuickAddDispatcher(
        moneyService: moneyService,
        billService: billService,
        medicineService: medicineService,
        simService: simService,
        documentService: documentService,
        taskService: taskService,
      );
    });

    test('Auto-saves money entry and updates repository', () async {
      final intent = ParsedIntent(
        module: QuickAddModule.money,
        confidence: 0.9,
        params: {
          'amount': 500.0,
          'direction': 'receive',
          'person': 'হাদি',
          'dueDate': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
        },
        originalText: 'হাদি থেকে আগামী মাসের ১০ তারিখে ৫০০ টাকা পাব',
      );

      final result = await dispatcher.autoSave(intent);
      expect(result.isSuccess, isTrue);
      expect(result.route, equals('/money'));

      final all = moneyService.getAll();
      final added = all.lastWhere((e) => e.person == 'হাদি');
      expect(added.amount, equals(500));
      expect(added.direction, equals(MoneyDirection.receive));
    });

    test('Auto-saves bill entry and updates repository', () async {
      final intent = ParsedIntent(
        module: QuickAddModule.bill,
        confidence: 0.85,
        params: {
          'type': 'electricity',
          'amount': 1200.0,
          'dueDay': 5,
        },
        originalText: 'বিদ্যুৎ বিল ১২০০ টাকা',
      );

      final result = await dispatcher.autoSave(intent);
      expect(result.isSuccess, isTrue);
      expect(result.route, equals('/bills'));

      final all = billService.getAll();
      expect(all.any((b) => b.amount == 1200), isTrue);
    });
  });
}
