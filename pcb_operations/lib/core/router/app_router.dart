import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/attendance/presentation/attendance_screen.dart';
import '../../features/attendance/presentation/attendance_reports_screen.dart';
import '../../features/auth/data/auth_service.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/onboarding_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/dashboard/presentation/admin_dashboard.dart';
import '../../features/dashboard/presentation/company_dashboard.dart';
import '../../features/employees/presentation/employee_list_screen.dart';
import '../../features/production/presentation/production_screen.dart';
import '../../features/reporting/presentation/daily_report_screen.dart';
import '../theme/app_colors.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authStateProvider).valueOrNull;

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isLogin = state.matchedLocation == '/login';
      final isSplash = state.matchedLocation == '/splash';
      if (isSplash) return null;
      if (auth == null && !isLogin) return '/login';
      if (auth != null && isLogin) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      ShellRoute(builder: (_, __, child) => _MainShell(child: child), routes: [
        GoRoute(path: '/home', builder: (_, __) => const CompanyDashboard()),
        GoRoute(path: '/production', builder: (_, __) => const ProductionScreen()),
        GoRoute(path: '/attendance', builder: (_, __) => const AttendanceScreen()),
        GoRoute(path: '/employees', builder: (_, __) => const EmployeeListScreen()),
        GoRoute(path: '/reports', builder: (_, __) => const DailyReportScreen()),
      ]),
    ],
  );
});

class _MainShell extends ConsumerStatefulWidget {
  final Widget child;
  const _MainShell({required this.child});
  @override
  ConsumerState<_MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<_MainShell> {
  int _idx = 0;
  static const _tabs = [
    ('Home', Icons.dashboard_rounded, '/home'),
    ('Production', Icons.precision_manufacturing_rounded, '/production'),
    ('Attendance', Icons.how_to_reg_rounded, '/attendance'),
    ('Directory', Icons.people_rounded, '/employees'),
    ('Reports', Icons.assignment_rounded, '/reports'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Image.asset('assets/images/smk_logo.png', height: 26),
        actions: [
          IconButton(icon: const Icon(Icons.person_add_rounded, color: AppColors.accent),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OnboardingScreen()))),
          IconButton(icon: const Icon(Icons.logout_rounded, color: Colors.white70),
            onPressed: () => ref.read(authServiceProvider).signOut()),
        ]),
      body: widget.child,
      bottomNavigationBar: NavigationBar(selectedIndex: _idx, height: 64,
        onDestinationSelected: (i) { setState(() => _idx = i); context.go(_tabs[i].$3); },
        indicatorColor: AppColors.accent.withValues(alpha: 0.15),
        destinations: _tabs.map((t) => NavigationDestination(icon: Icon(t.$2, size: 22),
          selectedIcon: Icon(t.$2, color: AppColors.accent, size: 22), label: t.$1)).toList()),
    );
  }
}
