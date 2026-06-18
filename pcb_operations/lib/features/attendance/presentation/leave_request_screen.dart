import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/leave.dart';
import '../../auth/data/employee_profile_repository.dart';
import '../data/leave_repository.dart';

class LeaveRequestScreen extends ConsumerStatefulWidget {
  const LeaveRequestScreen({super.key});
  @override
  ConsumerState<LeaveRequestScreen> createState() => _LeaveRequestScreenState();
}

class _LeaveRequestScreenState extends ConsumerState<LeaveRequestScreen> {
  final _reasonCtrl = TextEditingController();
  DateTime _fromDate = DateTime.now().add(const Duration(days: 1));
  DateTime _toDate = DateTime.now().add(const Duration(days: 2));
  bool _loading = false;
  String? _error;

  @override
  void dispose() { _reasonCtrl.dispose(); super.dispose(); }

  Future<void> _submit() async {
    final reason = _reasonCtrl.text.trim();
    if (reason.isEmpty) {
      setState(() => _error = 'Please enter a reason');
      return;
    }
    final emp = ref.read(currentEmployeeProvider).valueOrNull;
    if (emp == null) return;

    setState(() { _loading = true; _error = null; });
    try {
      final id = '${emp.id}_${_fromDate.toIso8601String()}';
      await ref.read(leaveRepositoryProvider).submitLeaveRequest(LeaveRequest(
        id: id, employeeId: emp.id, employeeName: emp.name,
        branchId: emp.branchId,
        startDate: DateFormat('yyyy-MM-dd').format(_fromDate),
        endDate: DateFormat('yyyy-MM-dd').format(_toDate),
        reason: reason, status: 'pending', createdAt: DateTime.now(),
      ));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Leave request submitted!'), backgroundColor: AppColors.success));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) setState(() { _error = 'Failed to submit'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Request Leave')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Gap(8),
          Row(children: [
            Expanded(child: _DateTile(label: 'From', date: _fromDate, onTap: () async {
              final d = await showDatePicker(context: context, initialDate: _fromDate,
                firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 90)));
              if (d != null) setState(() { _fromDate = d; if (_toDate.isBefore(d)) _toDate = d.add(const Duration(days: 1)); });
            })),
            const Gap(12),
            Expanded(child: _DateTile(label: 'To', date: _toDate, onTap: () async {
              final d = await showDatePicker(context: context, initialDate: _toDate,
                firstDate: _fromDate, lastDate: DateTime.now().add(const Duration(days: 90)));
              if (d != null) setState(() => _toDate = d);
            })),
          ]),
          const Gap(8),
          Text('${_toDate.difference(_fromDate).inDays + 1} day(s)',
            style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600)),
          const Gap(20),
          TextField(
            controller: _reasonCtrl, maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Reason for leave',
              hintText: 'Describe why you need leave...',
              alignLabelWithHint: true),
          ),
          if (_error != null) ...[
            const Gap(12),
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(
              color: AppColors.errorBg, borderRadius: BorderRadius.circular(10)),
              child: Text(_error!, style: const TextStyle(color: AppColors.error))),
          ],
          const Gap(24),
          SizedBox(width: double.infinity, height: 50,
            child: ElevatedButton(onPressed: _loading ? null : _submit,
              child: _loading ? const SizedBox(width: 20, height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Submit Request'))),
        ])));
  }
}

class _DateTile extends StatelessWidget {
  final String label; final DateTime date; final VoidCallback onTap;
  const _DateTile({required this.label, required this.date, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16), decoration: BoxDecoration(
          color: AppColors.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
        child: Row(children: [
          const Icon(Icons.calendar_today, color: AppColors.accent, size: 20), const Gap(10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
            Text(DateFormat('dd MMM yyyy').format(date), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          ])])));
  }
}
