import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/localization/generated/app_localizations.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'services/ai/gemini_service.dart';
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

class ShebaBondhuApp extends StatefulWidget {
  const ShebaBondhuApp({
    super.key,
    this.isLoggedIn = false,
    required this.authService,
    required this.homeService,
    required this.moneyService,
    required this.billService,
    required this.documentService,
    required this.medicineService,
    required this.simService,
    required this.warrantyService,
    required this.familyService,
    required this.taskService,
    required this.geminiService,
  });

  final bool isLoggedIn;
  final AuthService authService;
  final HomeService homeService;
  final MoneyService moneyService;
  final BillService billService;
  final DocumentService documentService;
  final MedicineService medicineService;
  final SimService simService;
  final WarrantyService warrantyService;
  final FamilyService familyService;
  final TaskService taskService;
  final GeminiService geminiService;

  @override
  State<ShebaBondhuApp> createState() => _ShebaBondhuAppState();
}

class _ShebaBondhuAppState extends State<ShebaBondhuApp> {
  late final AppRouter _router = AppRouter(
    isLoggedIn: widget.isLoggedIn,
    authService: widget.authService,
    homeService: widget.homeService,
    moneyService: widget.moneyService,
    billService: widget.billService,
    documentService: widget.documentService,
    medicineService: widget.medicineService,
    simService: widget.simService,
    warrantyService: widget.warrantyService,
    familyService: widget.familyService,
    taskService: widget.taskService,
    geminiService: widget.geminiService,
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      onGenerateTitle: (ctx) => AppLocalizations.of(ctx).appName,
      theme: AppTheme.light(),
      debugShowCheckedModeBanner: false,
      locale: const Locale('bn'),
      supportedLocales: const [Locale('bn'), Locale('en')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: _router.config,
    );
  }
}