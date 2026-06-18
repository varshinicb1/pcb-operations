import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../data/models/bus.dart';
import '../../auth/data/employee_profile_repository.dart';
import '../../attendance/data/attendance_repository.dart';
import '../../production/data/production_repository.dart';
import '../../reporting/data/reporting_repository.dart';

class CompanyDashboard extends ConsumerWidget {
  const CompanyDashboard({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emp = ref.watch(currentEmployeeProvider).valueOrNull;
    final branch = emp?.branchId ?? 'default';
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final buses = ref.watch(allBusesProvider(branch));
    final reports = ref.watch(todayReportsProvider(branch));
    final attendance = ref.watch(branchAttendanceProvider(DateAndBranch(branch, today)));

    return SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Dashboard', style: Theme.of(context).textTheme.headlineLarge),
      const Gap(4), Text('${emp?.branchName ?? 'Main Branch'} • ${DateFormat('dd MMM yyyy').format(DateTime.now())}',
        style: Theme.of(context).textTheme.bodyMedium),
      const Gap(20),
      attendance.when(loading: () => const SizedBox.shrink(), error: (_, __) => const SizedBox.shrink(),
        data: (a) {
          final p = a.where((r) => r.isPresent).length;
          return Row(children: [_StatCard(label: 'Present Today', value: '$p', color: AppColors.success, icon: Icons.people_rounded),
            const Gap(8), _StatCard(label: 'Absent', value: '${a.length - p}', color: AppColors.error, icon: Icons.person_off_rounded),
            const Gap(8), _StatCard(label: 'Late', value: '${a.where((r) => r.isLate).length}', color: AppColors.accent, icon: Icons.access_time_rounded)]);
        }),
      const Gap(20),
      buses.when(loading: () => const SizedBox.shrink(), error: (_, __) => const SizedBox.shrink(),
        data: (b) {
          final active = b.where((x) => x.status == 'active').length;
          final delayed = b.where((x) => x.isDelayed).length;
          return Row(children: [_StatCard(label: 'Active Buses', value: '$active', color: AppColors.info, icon: Icons.directions_bus_rounded),
            const Gap(8), _StatCard(label: 'Delayed', value: '$delayed', color: AppColors.error, icon: Icons.warning_rounded)]);
        }),
      const Gap(24),
      Text('Department Workload', style: Theme.of(context).textTheme.titleLarge),
      const Gap(12),
      _buildBusChart(buses),
      const Gap(24),
      SectionHeader(title: 'Today\'s Reports'),
      reports.when(loading: () => const Center(child: CircularProgressIndicator()), error: (_, __) => const SizedBox.shrink(),
        data: (r) {
          if (r.isEmpty) return const EmptyState(icon: Icons.assignment, title: 'No reports today', subtitle: '');
          return Column(children: r.take(5).map((rep) => Container(
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
            child: Row(children: [
              Container(width: 36, height: 36, decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.assignment_turned_in, color: AppColors.accent, size: 18)),
              const Gap(10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(rep.department, style: Theme.of(context).textTheme.titleMedium),
                Text('by ${rep.submittedByName}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12))]))]))).toList());
        }),
      const Gap(32),
    ]));
  }

  Widget _buildBusChart(AsyncValue<List<Bus>> buses) {
    return SizedBox(height: 200,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
        child: buses.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const SizedBox.shrink(),
          data: (b) {
            final stages = ['Fab', 'Weld', 'SM', 'Paint', 'Elec', 'Interior', 'Test', 'Ready'];
            final counts = stages.map((s) => b.where((x) => x.currentStage.toLowerCase().contains(s.toLowerCase())).length).toList();
            if (counts.every((c) => c == 0)) return const Center(child: Text('No bus data', style: TextStyle(color: AppColors.textMuted)));
            final maxY = (counts.reduce((a, b2) => a > b2 ? a : b2) + 1).toDouble();
            final barGroups = List.generate(stages.length, (i) {
              return BarChartGroupData(x: i, barRods: [
                BarChartRodData(toY: counts[i].toDouble(), color: AppColors.productionStages[i % AppColors.productionStages.length], width: 16, borderRadius: BorderRadius.circular(3))
              ]);
            });
            return BarChart(BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxY,
              barTouchData: BarTouchData(enabled: false),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) {
                  final i = v.toInt();
                  return Padding(padding: const EdgeInsets.only(top: 8), child: Text(stages[i], style: const TextStyle(fontSize: 9, color: AppColors.textSecondary)));
                })),
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28, getTitlesWidget: (v, _) {
                  return Text('${v.toInt()}', style: const TextStyle(fontSize: 10, color: AppColors.textMuted));
                })),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 1),
              borderData: FlBorderData(show: false),
              barGroups: barGroups,
            ));
          },
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value; final Color color; final IconData icon;
  const _StatCard({required this.label, required this.value, required this.color, required this.icon});
  @override
  Widget build(BuildContext context) => Expanded(child: Container(
    padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
    child: Column(children: [
      Icon(icon, color: color, size: 22), const Gap(6),
      Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: color, fontWeight: FontWeight.w800)),
      Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11))])));
}
