import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../auth/data/employee_profile_repository.dart';
import '../data/attendance_repository.dart';
import 'check_in_screen.dart';
import 'attendance_history_screen.dart';
import 'admin_attendance_screen.dart';
import 'attendance_reports_screen.dart';

class AttendanceScreen extends ConsumerWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendanceAsync = ref.watch(todayAttendanceProvider);
    final employeeAsync = ref.watch(currentEmployeeProvider);
    final role = ref.watch(currentEmployeeRoleProvider);
    final now = DateTime.now();

    return AppScaffold(
      title: 'Attendance',
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(todayAttendanceProvider),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            employeeAsync.maybeWhen(
              data: (emp) => emp != null
                  ? Row(children: [
                      CircleAvatar(radius: 22, backgroundColor: AppColors.accent.withValues(alpha: 0.15),
                        child: Text(emp.name[0].toUpperCase(),
                          style: const TextStyle(color: AppColors.accentDark, fontWeight: FontWeight.w700, fontSize: 18))),
                      const Gap(12),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Hello, ${emp.name.split(' ').first}',
                          style: Theme.of(context).textTheme.titleLarge),
                        Text('${emp.designation} • ${emp.branchName}',
                          style: Theme.of(context).textTheme.bodyMedium)]),
                    ])
                  : const SizedBox.shrink(),
              orElse: () => const SizedBox.shrink()),
            const Gap(20),
            attendanceAsync.when(
              loading: () => _StatusCard.loading(),
              error: (e, _) => _StatusCard.error(),
              data: (a) => _StatusCard(isCheckedIn: a?.isCheckedIn ?? false,
                time: a?.isCheckedIn == true ? 'Checked in at ${a?.checkInTime ?? '--'}' : null),
            ).animate().fadeIn(delay: 100.ms),
            const Gap(20),
            _CheckActions(attendance: attendanceAsync.valueOrNull),
            const Gap(24),
            _LiveClock(now: now).animate().fadeIn(delay: 200.ms),
            if (role == 'admin' || role == 'supervisor') ...[
              const Gap(24),
              const SectionHeader(title: 'Team Oversight'),
              _AdminTools(),
            ],
            const Gap(24),
            SectionHeader(title: 'My History', actionLabel: 'View All',
              onAction: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AttendanceHistoryScreen()))),
            _HistoryPreview(),
          ]))));
  }
}

class _StatusCard extends StatelessWidget {
  final bool isCheckedIn;
  final String? time;
  const _StatusCard({required this.isCheckedIn, this.time});
  _StatusCard.loading() : isCheckedIn = false, time = 'Loading...';
  _StatusCard.error() : isCheckedIn = false, time = null;

  @override
  Widget build(BuildContext context) {
    final color = isCheckedIn ? AppColors.success : AppColors.textMuted;
    final icon = isCheckedIn ? Icons.check_circle_rounded : Icons.access_time_rounded;
    final title = isCheckedIn ? 'Checked In' : 'Not Checked In';
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: isCheckedIn
              ? [AppColors.success, AppColors.success.withValues(alpha: 0.7)]
              : [AppColors.textMuted.withValues(alpha: 0.6), AppColors.textMuted.withValues(alpha: 0.3)],
        ),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(children: [
        Icon(icon, color: Colors.white, size: 52),
        const Gap(12),
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.3)),
        if (time != null) ...[
          const Gap(6),
          Text(time!, style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 15, fontWeight: FontWeight.w500)),
        ],
      ]),
    );
  }
}

class _CheckActions extends ConsumerWidget {
  final dynamic attendance;
  const _CheckActions({required this.attendance});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final in_ = attendance?.isCheckedIn ?? false;
    final out = attendance?.isCheckedOut ?? false;
    final emp = ref.watch(currentEmployeeProvider).valueOrNull;

    return Row(children: [
      Expanded(child: _Btn(
        label: 'Check In', icon: Icons.login_rounded, color: AppColors.success,
        enabled: !in_,
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CheckInScreen(employee: emp))))),
      const Gap(12),
      Expanded(child: _Btn(
        label: 'Check Out', icon: Icons.logout_rounded, color: AppColors.error,
        enabled: in_ && !out,
        onTap: () async {
          final a = ref.read(todayAttendanceProvider).valueOrNull;
          if (a == null) return;
          try {
            final perm = await Geolocator.checkPermission();
            if (perm == LocationPermission.denied) await Geolocator.requestPermission();
            final pos = await Geolocator.getCurrentPosition(
              locationSettings: const LocationSettings(accuracy: LocationAccuracy.high));
            await ref.read(attendanceRepositoryProvider).checkOut(
              docId: a.id, latitude: pos.latitude, longitude: pos.longitude);
            ref.invalidate(todayAttendanceProvider);
          } catch (_) {}
        })),
    ]).animate().fadeIn(delay: 150.ms);
  }
}

class _Btn extends StatelessWidget {
  final String label; final IconData icon; final Color color; final bool enabled; final VoidCallback onTap;
  const _Btn({required this.label, required this.icon, required this.color, required this.enabled, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return SizedBox(height: 54,
      child: ElevatedButton.icon(
        onPressed: enabled ? onTap : null,
        icon: Icon(icon, size: 20),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color, foregroundColor: Colors.white,
          disabledBackgroundColor: color.withValues(alpha: 0.25), disabledForegroundColor: Colors.white54,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}

class _LiveClock extends StatelessWidget {
  final DateTime now;
  const _LiveClock({required this.now});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
      child: Column(children: [
        Text(DateFormat('EEEE, dd MMMM yyyy').format(now), style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 13)),
        const Gap(4),
        StreamBuilder(
          stream: Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now()),
          builder: (_, snap) => Text(DateFormat('hh:mm:ss a').format(snap.data ?? now),
            style: Theme.of(context).textTheme.displayMedium?.copyWith(color: AppColors.primaryDark, fontWeight: FontWeight.w800))),
      ]),
    );
  }
}

class _AdminTools extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10, crossAxisSpacing: 10, padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        _Tile(icon: Icons.people_rounded, label: 'Present', color: AppColors.success, route: () => const AdminAttendanceScreen(initialTab: 0)),
        _Tile(icon: Icons.person_off_rounded, label: 'Absent', color: AppColors.error, route: () => const AdminAttendanceScreen(initialTab: 1)),
        _Tile(icon: Icons.access_time_rounded, label: 'Late Arrivals', color: AppColors.accent, route: () => const AdminAttendanceScreen(initialTab: 2)),
        _Tile(icon: Icons.assessment_rounded, label: 'Reports', color: AppColors.primary, route: () => const AttendanceReportsScreen()),
      ]);
  }
}

class _Tile extends StatelessWidget {
  final IconData icon; final String label; final Color color; final Widget Function() route;
  const _Tile({required this.icon, required this.label, required this.color, required this.route});
  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => route())),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.all(16),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 22)),
            const Gap(10),
            Text(label, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, fontSize: 13)),
          ]),
        ),
      ),
    );
  }
}

class _HistoryPreview extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(attendanceHistoryProvider);
    return history.when(
      loading: () => const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator())),
      error: (_, __) => const SizedBox.shrink(),
      data: (records) {
        if (records.isEmpty) return const EmptyState(icon: Icons.history, title: 'No records yet', subtitle: '');
        return Column(children: records.take(5).map((r) => Container(
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 6),
          decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            Container(width: 40, height: 40,
              decoration: BoxDecoration(color: (r.isPresent ? AppColors.success : AppColors.error).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(r.isPresent ? Icons.check_rounded : Icons.close_rounded, color: r.isPresent ? AppColors.success : AppColors.error, size: 20)),
            const Gap(12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(r.date, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              Text(r.isPresent ? 'In: ${r.checkInTime ?? '-'}  Out: ${r.checkOutTime ?? '-'}' : 'Absent',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12)),
            ])),
            if (r.isLate) Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: AppColors.warningBg, borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.warning.withValues(alpha: 0.3))),
              child: const Text('Late', style: TextStyle(color: AppColors.accentDark, fontSize: 11, fontWeight: FontWeight.w700))),
          ]),
        )).toList());
      });
  }
}
