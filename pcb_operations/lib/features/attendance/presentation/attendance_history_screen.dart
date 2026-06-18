import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/utils/helpers.dart';
import '../data/attendance_repository.dart';

class AttendanceHistoryScreen extends ConsumerWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(attendanceHistoryProvider);

    return AppScaffold(
      title: 'Attendance History',
      showBack: true,
      body: history.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (records) {
          if (records.isEmpty) {
            return const EmptyState(
              icon: Icons.history_rounded,
              title: 'No Records',
              subtitle: 'Attendance history will appear here',
            );
          }

          final present = records.where((r) => r.isPresent).length;
          final absent = records.length - present;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    _SummaryCard(
                      label: 'Present',
                      value: '$present',
                      color: AppColors.success,
                    ),
                    const SizedBox(width: 12),
                    _SummaryCard(
                      label: 'Absent',
                      value: '$absent',
                      color: AppColors.error,
                    ),
                    const SizedBox(width: 12),
                    _SummaryCard(
                      label: 'Rate',
                      value: records.isNotEmpty
                          ? '${((present / records.length) * 100).toStringAsFixed(0)}%'
                          : '0%',
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    final record = records[index];
                    final isPresent = record.isPresent;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: (isPresent ? AppColors.success : AppColors.error).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            isPresent ? Icons.check_rounded : Icons.close_rounded,
                            color: isPresent ? AppColors.success : AppColors.error,
                          ),
                        ),
                        title: Text(
                          Helpers.formatDate(DateTime.tryParse(record.date)),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        subtitle: Text(
                          isPresent
                              ? 'In: ${record.checkInTime ?? '--'}  |  Out: ${record.checkOutTime ?? '--'}'
                              : 'Absent',
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              Helpers.attendanceStatusLabel(record.status),
                              style: TextStyle(
                                color: Helpers.attendanceStatusColor(record.status),
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            if (record.isLate)
                              const Text(
                                'Late',
                                style: TextStyle(
                                  color: AppColors.attendanceLate,
                                  fontSize: 11,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          child: Column(
            children: [
              Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: color)),
              Text(label, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}
