import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'services/bill_service.dart';
import 'services/document_service.dart';
import 'services/family_service.dart';
import 'services/home_service.dart';
import 'services/medicine_service.dart';
import 'services/money_service.dart';
import 'services/sim_service.dart';
import 'services/task_service.dart';
import 'services/warranty_service.dart';
import 'services/ai/gemini_service.dart';
import 'services/notification/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env BEFORE constructing services that read from it (GeminiService).
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // Missing .env is non-fatal — the heuristic fallback still works.
  }

  // Safe Firebase initialization with project options
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase initialized successfully!');
  } catch (e) {
    debugPrint('Firebase init with options error: $e. Retrying default init...');
    try {
      await Firebase.initializeApp();
    } catch (e2) {
      debugPrint('Firebase default init error: $e2');
    }
  }

  // Services with reactive repositories
  final money = MoneyService();
  final bills = BillService();
  final docs = DocumentService();
  final meds = MedicineService();
  final sims = SimService();
  final warranties = WarrantyService();
  final family = FamilyService();
  final tasks = TaskService();
  final gemini = GeminiService();
  final home = HomeService(
    money: money,
    bills: bills,
    documents: docs,
    medicines: meds,
    sims: sims,
    tasks: tasks,
  );

  // Initialize smart background notification service
  try {
    await NotificationService.instance.init();
    await NotificationService.instance.requestPermission();
    await NotificationService.instance.syncAllReminders(home);
  } catch (e) {
    debugPrint('⚠️ [NotificationService Init Error]: $e');
  }

  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  final authService = AuthService();
  await authService.init();

  runApp(ShebaBondhuApp(
    isLoggedIn: isLoggedIn,
    authService: authService,
    homeService: home,
    moneyService: money,
    billService: bills,
    documentService: docs,
    medicineService: meds,
    simService: sims,
    warrantyService: warranties,
    familyService: family,
    taskService: tasks,
    geminiService: gemini,
  ));
}