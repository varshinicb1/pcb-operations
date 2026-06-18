import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:gap/gap.dart';
import 'dart:io';
import 'package:excel/excel.dart' as excel;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/selfie_image.dart';
import '../../auth/data/employee_profile_repository.dart';
import '../data/attendance_repository.dart';

class AdminAttendanceScreen extends ConsumerStatefulWidget {
  final int initialTab;
  const AdminAttendanceScreen({super.key, this.initialTab = 0});
  @override
  ConsumerState<AdminAttendanceScreen> createState() => _AdminAttendanceScreenState();
}

class _AdminAttendanceScreenState extends ConsumerState<AdminAttendanceScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: widget.initialTab);
  }

  @override
  void dispose() { _tabController.dispose(); super.dispose(); }

  String get _today => DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  Widget build(BuildContext context) {
    final branchId = ref.watch(currentEmployeeBranchProvider);
    final params = DateAndBranch(branchId, _today);
    final recordsAsync = ref.watch(branchAttendanceProvider(params));

    return AppScaffold(
      title: 'Team Attendance',
      showBack: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.file_download_outlined),
          tooltip: 'Export Excel',
          onPressed: () => _exportExcel(recordsAsync.valueOrNull ?? []),
        ),
      ],
      bottom: TabBar(
        controller: _tabController,
        indicatorColor: AppColors.primary,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        tabs: const [Tab(text: 'Present'), Tab(text: 'Absent'), Tab(text: 'Late')],
      ),
      body: recordsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (allRecords) {
          final present = allRecords.where((r) => r.isPresent).toList();
          final absent = allRecords.where((r) => !r.isPresent).toList();
          final late = allRecords.where((r) => r.isLate).toList();

          return Column(children: [
            Padding(padding: const EdgeInsets.all(16),
              child: Row(children: [
                _CountChip(label: 'Total', count: allRecords.length, color: AppColors.primary),
                const Gap(8),
                _CountChip(label: 'Present', count: present.length, color: AppColors.success),
                const Gap(8),
                _CountChip(label: 'Absent', count: absent.length, color: AppColors.error),
                const Gap(8),
                _CountChip(label: 'Late', count: late.length, color: AppColors.warning),
              ])),
            const Divider(height: 1),
            if (allRecords.isEmpty)
              const Expanded(child: Center(child: EmptyState(
                icon: Icons.people_outline, title: 'No records', subtitle: 'No attendance data for today'))),
            if (allRecords.isNotEmpty)
              Expanded(child: TabBarView(controller: _tabController, children: [
                _TabList(records: present, emptyMsg: 'No one checked in yet'),
                _TabList(records: absent, emptyMsg: 'Everyone is present!'),
                _TabList(records: late, emptyMsg: 'No late arrivals today!', showLate: true),
              ])),
          ]);
        },
      ),
    );
  }

  Future<void> _exportExcel(List<dynamic> records) async {
    try {
      final sheet = excel.Excel.createExcel();
      final s = sheet['Attendance'];
      s.appendRow([
        excel.TextCellValue('Employee ID'), excel.TextCellValue('Name'),
        excel.TextCellValue('Check In'), excel.TextCellValue('Check Out'),
        excel.TextCellValue('Status'), excel.TextCellValue('Location'),
      ]);

      for (final r in records) {
        s.appendRow([
          excel.TextCellValue(r.employeeId),
          excel.TextCellValue(r.employeeName),
          excel.TextCellValue(r.checkInTime ?? ''),
          excel.TextCellValue(r.checkOutTime ?? ''),
          excel.TextCellValue(r.status ?? ''),
          excel.TextCellValue(r.checkInLatitude != null
              ? '${r.checkInLatitude}, ${r.checkInLongitude}' : ''),
        ]);
      }

      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/attendance_$_today.xlsx');
      await file.writeAsBytes(sheet.encode()!);
      await Share.shareXFiles([XFile(file.path)],
          text: 'Attendance Report - ${DateFormat('dd MMM yyyy').format(DateTime.now())}');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e'), backgroundColor: AppColors.error));
      }
    }
  }
}

class _CountChip extends StatelessWidget {
  final String label; final int count; final Color color;
  const _CountChip({required this.label, required this.count, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text('$label ', style: TextStyle(fontSize: 12, color: color.withValues(alpha: 0.8))),
        Text('$count', style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w700)),
      ]));
  }
}

class _TabList extends StatelessWidget {
  final List<dynamic> records; final String emptyMsg; final bool showLate;
  const _TabList({required this.records, required this.emptyMsg, this.showLate = false});
  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return Center(child: EmptyState(icon: Icons.celebration_outlined, title: emptyMsg, subtitle: ''));
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: records.length,
      itemBuilder: (_, i) {
        final r = records[i];
        final isPresent = r.isPresent == true;
        return Card(margin: const EdgeInsets.only(bottom: 6),
          child: ListTile(
            leading: CircleAvatar(radius: 20,
              backgroundColor: (isPresent ? AppColors.success : AppColors.error).withValues(alpha: 0.1),
              child: Text((r.employeeName as String)[0].toUpperCase(),
                style: TextStyle(color: isPresent ? AppColors.success : AppColors.error, fontWeight: FontWeight.w700))),
            title: Text(r.employeeName ?? '-', style: Theme.of(context).textTheme.titleMedium),
            subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('ID: ${r.employeeId ?? '-'}', style: const TextStyle(fontSize: 12)),
              if (isPresent)
                Text('In: ${r.checkInTime ?? '-'}${r.checkOutTime != null ? '  |  Out: ${r.checkOutTime}' : ''}',
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ]),
            trailing: showLate
                ? Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.warning.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6)),
                    child: const Text('Late', style: TextStyle(color: AppColors.warning, fontSize: 12, fontWeight: FontWeight.w600)))
                : (r.selfieUrl is String && (r.selfieUrl as String).isNotEmpty
                    ? SelfieImage(base64: r.selfieUrl, width: 40, height: 40)
                    : null),
          ),
        );
      });
  }
}
