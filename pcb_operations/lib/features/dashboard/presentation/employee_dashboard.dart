import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../auth/data/employee_profile_repository.dart';
import '../../attendance/data/attendance_repository.dart';

class EmployeeDashboard extends ConsumerWidget {
  const EmployeeDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emp = ref.watch(currentEmployeeProvider).valueOrNull;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Hello, ${emp?.name.split(' ').first ?? 'Worker'}',
          style: Theme.of(context).textTheme.headlineLarge).animate().fadeIn(),
        const Gap(4),
        Text('${emp?.branchName ?? 'Main Branch'} • ${DateFormat('EEEE, dd MMM').format(DateTime.now())}',
          style: Theme.of(context).textTheme.bodyMedium),
        const Gap(20),
        _buildCheckStatus(context, ref),
        const Gap(24),
        SectionHeader(title: 'Quick Actions'),
        const Gap(8),
        _QuickActions(),
      ]),
    );
  }

  Widget _buildCheckStatus(BuildContext context, WidgetRef ref) {
    final todayAttendance = ref.watch(todayAttendanceProvider);
    return todayAttendance.when(
      loading: () => Container(
        padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
        child: const Center(child: CircularProgressIndicator())),
      data: (att) {
        final in_ = att?.isCheckedIn ?? false;
        return Container(
          padding: const EdgeInsets.all(24), width: double.infinity,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: in_ ? [AppColors.success, AppColors.success.withValues(alpha: 0.7)]
                  : [AppColors.primary, AppColors.primaryDark])),
          child: Column(children: [
            Icon(in_ ? Icons.check_circle_rounded : Icons.access_time_rounded, color: Colors.white, size: 44),
            const Gap(12),
            Text(in_ ? 'Checked In' : 'Start Your Day',
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
            if (att?.checkInTime != null) ...[const Gap(4),
              Text('Today at ${att?.checkInTime}', style: TextStyle(color: Colors.white.withValues(alpha: 0.8)))],
          ]),
        );
      },
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.count(crossAxisCount: 3, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10, crossAxisSpacing: 10,
      children: [
        _Tile(icon: Icons.login_rounded, label: 'Check In', color: AppColors.success),
        _Tile(icon: Icons.history_rounded, label: 'History', color: AppColors.info),
        _Tile(icon: Icons.event_busy_rounded, label: 'Request\nLeave', color: Colors.purple),
        _Tile(icon: Icons.person_rounded, label: 'My Profile', color: AppColors.primary),
      ]);
  }
}

class _Tile extends StatelessWidget {
  final IconData icon; final String label; final Color color;
  const _Tile({required this.icon, required this.label, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.card,
        borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: color, size: 22)),
        const Gap(8), Text(label, textAlign: TextAlign.center,
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textPrimary, height: 1.3)),
      ]));
  }
}
