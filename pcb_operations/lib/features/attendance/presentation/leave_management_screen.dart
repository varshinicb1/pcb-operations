import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/leave.dart';
import '../../auth/data/employee_profile_repository.dart';
import '../data/leave_repository.dart';

class LeaveManagementScreen extends ConsumerStatefulWidget {
  const LeaveManagementScreen({super.key});
  @override
  ConsumerState<LeaveManagementScreen> createState() => _LeaveManagementScreenState();
}

class _LeaveManagementScreenState extends ConsumerState<LeaveManagementScreen> {
  @override
  Widget build(BuildContext context) {
    final emp = ref.watch(currentEmployeeProvider).valueOrNull;
    final branchId = emp?.branchId ?? 'default';
    final pendingLeaves = ref.watch(leaveRepositoryProvider).watchPendingLeaves(branchId);

    return Scaffold(
      appBar: AppBar(title: const Text('Leave Requests')),
      body: StreamBuilder<List<LeaveRequest>>(
        stream: pendingLeaves,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final list = snapshot.data ?? [];
          if (list.isEmpty) {
            return const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.celebration_outlined, size: 64, color: AppColors.textMuted),
              Gap(12), Text('No pending requests', style: TextStyle(color: AppColors.textMuted, fontSize: 16))]));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (_, i) => _buildLeaveCard(context, list[i]),
          );
        },
      ),
    );
  }

  Widget _buildLeaveCard(BuildContext context, LeaveRequest leave) {
    final days = DateTime.parse(leave.endDate).difference(DateTime.parse(leave.startDate)).inDays + 1;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(radius: 18, backgroundColor: AppColors.accent.withValues(alpha: 0.15),
            child: Text(leave.employeeName[0].toUpperCase(),
              style: const TextStyle(color: AppColors.accentDark, fontWeight: FontWeight.w700))),
          const Gap(10),
          Expanded(child: Text(leave.employeeName, style: Theme.of(context).textTheme.titleMedium)),
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: AppColors.warningBg, borderRadius: BorderRadius.circular(20)),
            child: const Text('Pending', style: TextStyle(color: AppColors.accentDark, fontSize: 11, fontWeight: FontWeight.w600))),
        ]),
        const Gap(12),
        Row(children: [
          _InfoChip(icon: Icons.calendar_today, text: '${DateFormat('dd MMM').format(DateTime.parse(leave.startDate))} → ${DateFormat('dd MMM').format(DateTime.parse(leave.endDate))}'),
          const Gap(8),
          _InfoChip(icon: Icons.timer_outlined, text: '$days day${days > 1 ? 's' : ''}'),
        ]),
        const Gap(10),
        Text(leave.reason, style: Theme.of(context).textTheme.bodyMedium),
        const Gap(14),
        Row(children: [
          Expanded(child: SizedBox(height: 40,
            child: ElevatedButton.icon(
              onPressed: () => _approve(leave),
              icon: const Icon(Icons.check, size: 18),
              label: const Text('Approve'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white)))),
          const Gap(10),
          Expanded(child: SizedBox(height: 40,
            child: OutlinedButton.icon(
              onPressed: () => _reject(leave),
              icon: const Icon(Icons.close, size: 18),
              label: const Text('Reject'),
              style: OutlinedButton.styleFrom(foregroundColor: AppColors.error, side: const BorderSide(color: AppColors.error))))),
        ]),
      ]),
    );
  }

  Future<void> _approve(LeaveRequest leave) async {
    final emp = ref.read(currentEmployeeProvider).valueOrNull;
    await ref.read(leaveRepositoryProvider).approveLeave(leave.id, emp?.id ?? '', 'Approved');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Leave approved'), backgroundColor: AppColors.success));
    }
  }

  Future<void> _reject(LeaveRequest leave) async {
    final emp = ref.read(currentEmployeeProvider).valueOrNull;
    await ref.read(leaveRepositoryProvider).rejectLeave(leave.id, emp?.id ?? '', 'Rejected');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Leave rejected'), backgroundColor: AppColors.error));
    }
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon; final String text;
  const _InfoChip({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 13, color: AppColors.textMuted), const Gap(4),
      Text(text, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
    ]);
  }
}
