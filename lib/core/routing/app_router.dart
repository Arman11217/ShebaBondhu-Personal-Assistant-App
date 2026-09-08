import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/app_colors.dart';
import '../../models/bill.dart';
import '../../models/identity_document.dart';
import '../../models/medicine.dart';
import '../../models/money_entry.dart';
import '../../models/sim_card.dart';
import '../../models/task.dart';
import '../../screens/analytics_screen.dart';
import '../../screens/bills/bill_edit_screen.dart';
import '../../screens/bills/bill_list_screen.dart';
import '../../screens/calendar_screen.dart';
import '../../screens/documents/document_edit_screen.dart';
import '../../screens/documents/document_list_screen.dart';
import '../../screens/family/family_list_screen.dart';
import '../../screens/home_screen.dart';
import '../../screens/login_screen.dart';
import '../../screens/medicines/medicine_edit_screen.dart';
import '../../screens/medicines/medicine_list_screen.dart';
import '../../screens/money/money_edit_screen.dart';
import '../../screens/money/money_list_screen.dart';
import '../../screens/more_screen.dart';
import '../../screens/onboarding_screen.dart';
import '../../screens/sims/sim_edit_screen.dart';
import '../../screens/sims/sim_list_screen.dart';
import '../../screens/splash_screen.dart';
import '../../screens/tasks/task_edit_screen.dart';
import '../../screens/tasks/task_list_screen.dart';
import '../../screens/warranties/warranty_edit_screen.dart';
import '../../screens/warranties/warranty_list_screen.dart';
import '../../services/ai/gemini_service.dart';
import '../../services/ai/quick_add_dispatcher.dart';
import '../../services/auth_service.dart';
import '../../services/bill_service.dart';
import '../../services/document_service.dart';
import '../../services/family_service.dart';
import '../../services/home_service.dart';
import '../../services/medicine_service.dart';
import '../../services/money_service.dart';
import '../../services/sim_service.dart';
import '../../services/task_service.dart';
import '../../services/warranty_service.dart';
import '../../widgets/quick_add/quick_add_sheet.dart';

class AppRouter {
  AppRouter({
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

  late final QuickAddDispatcher dispatcher = QuickAddDispatcher(
    moneyService: moneyService,
    billService: billService,
    medicineService: medicineService,
    simService: simService,
    documentService: documentService,
    taskService: taskService,
  );

  final _navKey = GlobalKey<NavigatorState>();

  late final GoRouter config = GoRouter(
    navigatorKey: _navKey,
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (_, _) => SplashScreen(onReady: _afterSplash),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (_, _) => OnboardingScreen(onDone: _afterOnboarding),
      ),
      GoRoute(
        path: '/login',
        builder: (_, _) => LoginScreen(
          authService: authService,
          onSignedIn: _afterLogin,
        ),
      ),
      ShellRoute(
        builder: (_, _, child) => HomeShell(
          geminiService: geminiService,
          dispatcher: dispatcher,
          child: child,
        ),
        routes: [
          GoRoute(
            path: '/home',
            builder: (_, _) => HomeScreen(homeService: homeService),
          ),
          GoRoute(
            path: '/calendar',
            builder: (_, _) => CalendarScreen(homeService: homeService),
          ),
          GoRoute(
            path: '/analytics',
            builder: (_, _) => AnalyticsScreen(
              moneyService: moneyService,
              billService: billService,
            ),
          ),
          GoRoute(
            path: '/more',
            builder: (_, _) => MoreScreen(
              geminiService: geminiService,
              dispatcher: dispatcher,
              authService: authService,
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/money',
        builder: (_, _) => MoneyListScreen(moneyService: moneyService),
        routes: [
          GoRoute(
            path: 'edit',
            builder: (_, state) => MoneyEditScreen(
              moneyService: moneyService,
              entryId: state.uri.queryParameters['id'],
              existing: state.extra as MoneyEntry?,
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/bills',
        builder: (_, _) => BillListScreen(billService: billService),
        routes: [
          GoRoute(
            path: 'edit',
            builder: (_, state) => BillEditScreen(
              billService: billService,
              billId: state.uri.queryParameters['id'],
              existing: state.extra as Bill?,
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/documents',
        builder: (_, _) => DocumentListScreen(documentService: documentService),
        routes: [
          GoRoute(
            path: 'edit',
            builder: (_, state) => DocumentEditScreen(
              documentService: documentService,
              documentId: state.uri.queryParameters['id'],
              existing: state.extra as IdentityDocument?,
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/medicines',
        builder: (_, _) =>
            MedicineListScreen(medicineService: medicineService),
        routes: [
          GoRoute(
            path: 'edit',
            builder: (_, state) => MedicineEditScreen(
              medicineService: medicineService,
              medicineId: state.uri.queryParameters['id'],
              existing: state.extra as Medicine?,
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/sims',
        builder: (_, _) => SimListScreen(simService: simService),
        routes: [
          GoRoute(
            path: 'edit',
            builder: (_, state) {
              final id = state.uri.queryParameters['id'];
              return SimEditScreen(
                simService: simService,
                existing: state.extra as SimCard? ??
                    (id == null ? null : simService.getById(id)),
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: '/warranties',
        builder: (_, _) =>
            WarrantyListScreen(warrantyService: warrantyService),
        routes: [
          GoRoute(
            path: 'edit',
            builder: (_, state) {
              final id = state.uri.queryParameters['id'];
              return WarrantyEditScreen(
                warrantyService: warrantyService,
                existing: id == null
                    ? null
                    : warrantyService.getById(id),
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: '/family',
        builder: (_, _) => FamilyListScreen(familyService: familyService),
      ),
      GoRoute(
        path: '/tasks',
        builder: (_, _) => TaskListScreen(taskService: taskService),
        routes: [
          GoRoute(
            path: 'edit',
            builder: (_, state) => TaskEditScreen(
              taskService: taskService,
              existing: state.extra as Task?,
            ),
          ),
        ],
      ),
    ],
  );

  Future<void> _afterSplash() async {
    final prefs = await SharedPreferences.getInstance();
    final loggedIn = prefs.getBool('isLoggedIn') ?? isLoggedIn;
    if (loggedIn) {
      config.go('/home');
    } else {
      final seenOnboarding = prefs.getBool('seenOnboarding') ?? false;
      if (!seenOnboarding) {
        config.go('/onboarding');
      } else {
        config.go('/login');
      }
    }
  }

  Future<void> _afterOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnboarding', true);
    config.go('/login');
  }

  void _afterLogin() => config.go('/home');
}

class HomeShell extends StatelessWidget {
  const HomeShell({
    super.key,
    required this.child,
    required this.geminiService,
    this.dispatcher,
  });

  final Widget child;
  final GeminiService geminiService;
  final QuickAddDispatcher? dispatcher;

  int _indexFor(BuildContext context) {
    final loc = GoRouterState.of(context).uri.toString();
    if (loc.startsWith('/home')) return 0;
    if (loc.startsWith('/calendar')) return 1;
    if (loc.startsWith('/analytics')) return 2;
    if (loc.startsWith('/more')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final index = _indexFor(context);

    return Scaffold(
      body: child,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        height: 60,
        width: 60,
        margin: const EdgeInsets.only(top: 8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0B4D33), Color(0xFF10B981)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.white, width: 3),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF10B981).withValues(alpha: 0.42),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => QuickAddSheet.show(
              context: context,
              geminiService: geminiService,
              dispatcher: dispatcher,
            ),
            customBorder: const CircleBorder(),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(
                  Icons.auto_awesome,
                  color: AppColors.white,
                  size: 26,
                ),
                Positioned(
                  top: 12,
                  right: 14,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFBBF24),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          border: const Border(
            top: BorderSide(color: Color(0xFFE8EEF2), width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 66,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home_rounded,
                  label: 'হোম',
                  isSelected: index == 0,
                  onTap: () => context.go('/home'),
                ),
                _NavItem(
                  icon: Icons.calendar_today_outlined,
                  selectedIcon: Icons.calendar_month_rounded,
                  label: 'ক্যালেন্ডার',
                  isSelected: index == 1,
                  onTap: () => context.go('/calendar'),
                ),
                const SizedBox(width: 52), // Gap for floating AI button
                _NavItem(
                  icon: Icons.pie_chart_outline_rounded,
                  selectedIcon: Icons.pie_chart_rounded,
                  label: 'হিসাব',
                  isSelected: index == 2,
                  onTap: () => context.go('/analytics'),
                ),
                _NavItem(
                  icon: Icons.widgets_outlined,
                  selectedIcon: Icons.widgets_rounded,
                  label: 'মেনু',
                  isSelected: index == 3,
                  onTap: () => context.go('/more'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFE8FDF0)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isSelected ? selectedIcon : icon,
                color: isSelected ? const Color(0xFF0F766E) : AppColors.inkMuted,
                size: 21,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                color: isSelected ? const Color(0xFF0F766E) : AppColors.inkMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}