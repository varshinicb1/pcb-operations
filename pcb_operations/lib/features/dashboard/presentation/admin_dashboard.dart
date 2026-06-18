import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../attendance/data/attendance_repository.dart';
import '../../auth/data/employee_profile_repository.dart';
import '../../auth/presentation/onboarding_screen.dart';
import '../../attendance/presentation/admin_attendance_screen.dart';
import '../../attendance/presentation/attendance_reports_screen.dart';

class AdminDashboard extends ConsumerWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emp = ref.watch(currentEmployeeProvider).valueOrNull;
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final branchId = emp?.branchId ?? 'default';
    final params = DateAndBranch(branchId, today);
    final records = ref.watch(branchAttendanceProvider(params));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Hello, ${emp?.name.split(' ').first ?? 'Admin'}',
          style: Theme.of(context).textTheme.headlineLarge).animate().fadeIn(),
        const Gap(4),
        Text('${emp?.branchName ?? 'Main Branch'} • ${DateFormat('EEEE, dd MMM').format(DateTime.now())}',
          style: Theme.of(context).textTheme.bodyMedium),
        const Gap(20),
        records.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const SizedBox.shrink(),
          data: (list) {
            final present = list.where((r) => r.isPresent).length;
            final late = list.where((r) => r.isLate).length;
            final total = list.length;
            return _StatsGrid(present: present, late: late, absent: total - present);
          },
        ).animate().fadeIn(delay: 100.ms),
        const Gap(24),
        const SectionHeader(title: 'Quick Actions'),
        const Gap(8),
        _ActionGrid(),
      ]),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final int present, late, absent;
  const _StatsGrid({required this.present, required this.late, required this.absent});
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      _StatCard(label: 'Present', value: '$present', icon: Icons.people_rounded, color: AppColors.success),
      const Gap(8), _StatCard(label: 'Late', value: '$late', icon: Icons.access_time_rounded, color: AppColors.accent),
      const Gap(8), _StatCard(label: 'Absent', value: '$absent', icon: Icons.person_off_rounded, color: AppColors.error),
    ]);
  }
}

class _StatCard extends StatelessWidget {
  final String label, value; final IconData icon; final Color color;
  const _StatCard({required this.label, required this.value, required this.icon, required this.color});
  @override
  Widget build(BuildContext context) {
    return Expanded(child: Container(
      padding: const EdgeInsets.all(16), decoration: BoxDecoration(
        color: AppColors.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
      child: Column(children: [
        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: color, size: 20)),
        const Gap(10), Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: color, fontWeight: FontWeight.w800)),
        Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12)),
      ])));
  }
}

class _ActionGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.count(crossAxisCount: 3, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 0.95,
      children: [
        _ActionTile(icon: Icons.people_rounded, label: 'Team\nAttendance', color: AppColors.success, onTap: () =>
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminAttendanceScreen()))),
        _ActionTile(icon: Icons.access_time_rounded, label: 'Late\nArrivals', color: AppColors.accent, onTap: () =>
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminAttendanceScreen(initialTab: 2)))),
        _ActionTile(icon: Icons.person_off_rounded, label: 'Absent\nToday', color: AppColors.error, onTap: () =>
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminAttendanceScreen(initialTab: 1)))),
        _ActionTile(icon: Icons.assessment_rounded, label: 'Reports', color: AppColors.info, onTap: () =>
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AttendanceReportsScreen()))),
        _ActionTile(icon: Icons.event_busy_rounded, label: 'Leave\nRequests', color: Colors.purple, onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const _Placeholder2(title: 'Leave Management')));
        }),
        _ActionTile(icon: Icons.person_add_rounded, label: 'Onboard\nWorker', color: AppColors.primary, onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const OnboardingScreen()));
        }),
      ]);
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon; final String label; final Color color; final VoidCallback onTap;
  const _ActionTile({required this.icon, required this.label, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Material(color: AppColors.card, borderRadius: BorderRadius.circular(14),
      child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(14),
        child: Container(decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.all(12),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: color, size: 22)),
            const Gap(8), Text(label, textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textPrimary, height: 1.3)),
          ]))));
  }
}

class _Placeholder2 extends StatelessWidget {
  final String title;
  const _Placeholder2({required this.title});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text(title)), body: const Center(child: Text('Coming soon')));
}
