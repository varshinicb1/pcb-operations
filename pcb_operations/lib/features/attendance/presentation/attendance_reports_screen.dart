import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:excel/excel.dart' as excel;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../auth/data/employee_profile_repository.dart';
import '../data/attendance_repository.dart';

class AttendanceReportsScreen extends ConsumerStatefulWidget {
  const AttendanceReportsScreen({super.key});
  @override
  ConsumerState<AttendanceReportsScreen> createState() => _AttendanceReportsScreenState();
}

class _AttendanceReportsScreenState extends ConsumerState<AttendanceReportsScreen> {
  DateTime _selectedDate = DateTime.now();
  bool _isExporting = false;

  @override
  Widget build(BuildContext context) {
    final branchId = ref.watch(currentEmployeeBranchProvider);
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final params = DateAndBranch(branchId, dateStr);
    final recordsAsync = ref.watch(branchAttendanceProvider(params));

    return AppScaffold(
      title: 'Attendance Reports',
      showBack: true,
      actions: [
        IconButton(
          icon: _isExporting
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.file_download_outlined),
          tooltip: 'Export Excel',
          onPressed: _isExporting ? null : () => _exportStyledExcel(recordsAsync.valueOrNull ?? []),
        ),
      ],
      body: Column(children: [
        Padding(padding: const EdgeInsets.all(16), child: Row(children: [
          Expanded(child: OutlinedButton.icon(
            onPressed: () => _pickDate(),
            icon: const Icon(Icons.calendar_month, size: 18),
            label: Text(DateFormat('dd MMM yyyy').format(_selectedDate)))),
          const Gap(12),
          SizedBox(height: 44, child: ElevatedButton.icon(
            onPressed: _isExporting ? null : () => _exportStyledExcel(recordsAsync.valueOrNull ?? []),
            icon: const Icon(Icons.download_rounded, size: 16),
            label: const Text('Excel'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success, foregroundColor: Colors.white, textStyle: const TextStyle(fontSize: 13)))),
        ])),
        const Divider(height: 1),
        Expanded(child: recordsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: AppColors.error))),
          data: (records) {
            if (records.isEmpty) {
              return const Center(child: EmptyState(
                icon: Icons.description_outlined, title: 'No records', subtitle: 'No attendance data for this date'));
            }
            final present = records.where((r) => r.isPresent).length;
            return Column(children: [
              Padding(padding: const EdgeInsets.all(16), child: Row(children: [
                _Stat(label: 'Total', value: '${records.length}', color: AppColors.primary),
                const Gap(8),
                _Stat(label: 'Present', value: '$present', color: AppColors.success),
                const Gap(8),
                _Stat(label: 'Absent', value: '${records.length - present}', color: AppColors.error),
                const Gap(8),
                _Stat(label: 'Late', value: '${records.where((r) => r.isLate).length}', color: AppColors.warning),
              ])),
              const Divider(height: 1),
              Expanded(child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                itemCount: records.length,
                itemBuilder: (_, i) {
                  final r = records[i];
                  return Card(margin: const EdgeInsets.only(bottom: 6),
                    child: ListTile(
                      dense: true,
                      leading: CircleAvatar(radius: 18,
                        backgroundColor: (r.isPresent ? AppColors.success : AppColors.error).withValues(alpha: 0.1),
                        child: Icon(r.isPresent ? Icons.check_rounded : Icons.close_rounded,
                          color: r.isPresent ? AppColors.success : AppColors.error, size: 18)),
                      title: Text(r.employeeName, style: Theme.of(context).textTheme.titleMedium),
                      subtitle: r.isPresent
                          ? Text('In: ${r.checkInTime ?? '-'}  ${r.checkOutTime != null ? '| Out: ${r.checkOutTime}' : ''}')
                          : const Text('Not checked in'),
                      trailing: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _statusColor(r.status).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6)),
                        child: Text(_statusLabel(r.status),
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _statusColor(r.status)))),
                    ));
                })),
            ]);
          },
        )),
      ]),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context, initialDate: _selectedDate,
      firstDate: DateTime(2024), lastDate: DateTime.now());
    if (picked != null) { setState(() => _selectedDate = picked); }
  }

  Future<void> _exportStyledExcel(List<dynamic> records) async {
    setState(() => _isExporting = true);
    try {
      final ex = excel.Excel.createExcel();
      final sheet = ex['Attendance Report'];

      sheet.appendRow([excel.TextCellValue('ATTENDANCE REPORT')]);
      sheet.appendRow([excel.TextCellValue('Date: ${DateFormat('dd MMMM yyyy').format(_selectedDate)}')]);
      sheet.appendRow([excel.TextCellValue('Total: ${records.length}  |  Present: ${records.where((r) => r.isPresent).length}  |  Absent: ${records.where((r) => !r.isPresent).length}')]);
      sheet.appendRow([excel.TextCellValue('')]);
      sheet.appendRow([
        excel.TextCellValue('Employee ID'), excel.TextCellValue('Name'),
        excel.TextCellValue('Date'), excel.TextCellValue('Check In'),
        excel.TextCellValue('Check Out'), excel.TextCellValue('Status'),
      ]);

      for (final r in records) {
        sheet.appendRow([
          excel.TextCellValue(r.employeeId),
          excel.TextCellValue(r.employeeName),
          excel.TextCellValue(r.date),
          excel.TextCellValue(r.checkInTime ?? ''),
          excel.TextCellValue(r.checkOutTime ?? ''),
          excel.TextCellValue(_statusLabel(r.status)),
        ]);
      }

      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/attendance_report_${_selectedDate.toIso8601String().split('T').first}.xlsx');
      await file.writeAsBytes(ex.encode()!);
      await Share.shareXFiles([XFile(file.path)],
          text: 'Attendance Report - ${DateFormat('dd MMM yyyy').format(_selectedDate)}');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e'), backgroundColor: AppColors.error));
      }
    } finally {
      if (mounted) { setState(() => _isExporting = false); }
    }
  }

  Color _statusColor(String? status) {
    switch (status) { case 'present': return AppColors.success; case 'late': return AppColors.warning; case 'absent': return AppColors.error; default: return AppColors.textSecondary; }
  }
  String _statusLabel(String? status) {
    switch (status) { case 'present': return 'Present'; case 'late': return 'Late'; case 'absent': return 'Absent'; default: return 'Unknown'; }
  }
}

class _Stat extends StatelessWidget {
  final String label, value; final Color color;
  const _Stat({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) {
    return Expanded(child: Card(
      child: Padding(padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: color, fontWeight: FontWeight.w700)),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ])),
    ));
  }
}
