import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../data/models/daily_report.dart';
import '../../../core/constants/app_constants.dart';
import '../../auth/data/employee_profile_repository.dart';
import '../data/reporting_repository.dart';

class DailyReportScreen extends ConsumerStatefulWidget {
  const DailyReportScreen({super.key});
  @override
  ConsumerState<DailyReportScreen> createState() => _DailyReportScreenState();
}

class _DailyReportScreenState extends ConsumerState<DailyReportScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _busCtrl = TextEditingController(), _issuesCtrl = TextEditingController(),
        _materialCtrl = TextEditingController(), _workforceCtrl = TextEditingController(), _notesCtrl = TextEditingController();
  String? _selectedDept;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose(); _busCtrl.dispose(); _issuesCtrl.dispose();
    _materialCtrl.dispose(); _workforceCtrl.dispose(); _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final emp = ref.read(currentEmployeeProvider).valueOrNull;
    if (emp == null || _selectedDept == null) return;
    setState(() => _loading = true);
    try {
      final id = '${emp.branchId}_${_selectedDept}_${DateFormat('yyyy-MM-dd').format(DateTime.now())}';
      await ref.read(reportingRepositoryProvider).submitReport(DailyReport(
        id: id, branchId: emp.branchId, department: _selectedDept!,
        date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
        submittedBy: emp.id, submittedByName: emp.name,
        busUpdates: _busCtrl.text.trim().isEmpty ? null : _busCtrl.text.trim(),
        productionIssues: _issuesCtrl.text.trim().isEmpty ? null : _issuesCtrl.text.trim(),
        materialDelays: _materialCtrl.text.trim().isEmpty ? null : _materialCtrl.text.trim(),
        workforceIssues: _workforceCtrl.text.trim().isEmpty ? null : _workforceCtrl.text.trim(),
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        createdAt: DateTime.now(),
      ));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report submitted!'), backgroundColor: AppColors.success));
        _busCtrl.clear(); _issuesCtrl.clear(); _materialCtrl.clear(); _workforceCtrl.clear(); _notesCtrl.clear();
        setState(() => _loading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final emp = ref.watch(currentEmployeeProvider).valueOrNull;
    final reports = ref.watch(todayReportsProvider(emp?.branchId ?? 'default'));

    return AppScaffold(title: 'Daily Report', bottom: TabBar(controller: _tabCtrl, tabs: const [Tab(text: 'Submit'), Tab(text: 'Today')]),
      body: TabBarView(controller: _tabCtrl, children: [
        SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          DropdownButtonFormField<String>(value: _selectedDept,
            items: AppConstants.departments.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
            onChanged: (v) => setState(() => _selectedDept = v),
            decoration: const InputDecoration(labelText: 'Department')),
          const Gap(16), _buildField('Bus Progress Updates', _busCtrl),
          const Gap(12), _buildField('Production Issues', _issuesCtrl, maxLines: 2),
          const Gap(12), _buildField('Material Delays', _materialCtrl),
          const Gap(12), _buildField('Workforce Issues', _workforceCtrl),
          const Gap(12), _buildField('Additional Notes', _notesCtrl, maxLines: 2),
          const Gap(20),
          SizedBox(width: double.infinity, height: 50,
            child: ElevatedButton(onPressed: _loading ? null : _submit,
              child: _loading ? const CircularProgressIndicator(strokeWidth: 2, color: Colors.white) : const Text('Submit Report'))),
          const Gap(40)])),
        reports.when(loading: () => const Center(child: CircularProgressIndicator()), error: (_, __) => const EmptyState(icon: Icons.error, title: 'Error', subtitle: ''),
          data: (list) {
            if (list.isEmpty) return const Center(child: EmptyState(icon: Icons.assignment, title: 'No reports today', subtitle: ''));
            return ListView.builder(padding: const EdgeInsets.all(16), itemCount: list.length, itemBuilder: (_, i) {
              final r = list[i];
              return Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [Text(r.department, style: Theme.of(context).textTheme.titleMedium), const Spacer(),
                    Text(r.submittedByName, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11))]),
                  if (r.busUpdates != null) ...[const Gap(4), Text('📋 ${r.busUpdates}', style: const TextStyle(fontSize: 13))],
                  if (r.productionIssues != null) ...[const Gap(4), Text('⚠️ ${r.productionIssues}', style: const TextStyle(fontSize: 13, color: AppColors.error))],
                  if (r.materialDelays != null) ...[const Gap(4), Text('📦 ${r.materialDelays}', style: const TextStyle(fontSize: 13, color: AppColors.accentDark))],
                  if (r.notes != null) ...[const Gap(4), Text(r.notes!, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))],
                ]));
            });
          }),
      ]));
  }

  Widget _buildField(String label, TextEditingController ctrl, {int maxLines = 1}) => TextField(controller: ctrl, maxLines: maxLines,
    decoration: InputDecoration(labelText: label, hintText: 'Enter $label...', alignLabelWithHint: maxLines > 1));
}
