import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/bus.dart';
import '../../auth/data/employee_profile_repository.dart';
import '../data/production_repository.dart';

class ProductionScreen extends ConsumerWidget {
  const ProductionScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emp = ref.watch(currentEmployeeProvider).valueOrNull;
    final buses = ref.watch(allBusesProvider(emp?.branchId ?? 'default'));

    return Column(children: [
      Padding(padding: const EdgeInsets.all(16), child: Row(children: [
        Text('Active Projects', style: Theme.of(context).textTheme.headlineLarge),
        const Spacer(),
        IconButton(icon: const Icon(Icons.add_rounded, color: AppColors.accent), onPressed: () => _showAddBus(context)),
      ])),
      Expanded(child: buses.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (list) {
          if (list.isEmpty) return const Center(child: EmptyState(
            icon: Icons.directions_bus_rounded, title: 'No buses tracked', subtitle: 'Tap + to add a new bus'));
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            itemCount: list.length,
            itemBuilder: (_, i) => _BusCard(bus: list[i]));
        },
      )),
    ]);
  }

  void _showAddBus(BuildContext context) {
    showModalBottomSheet(context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => const _AddBusSheet());
  }
}

class _BusCard extends ConsumerWidget {
  final Bus bus;
  const _BusCard({required this.bus});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stageColor = AppColors.productionStages[bus.currentStageIndex % AppColors.productionStages.length];
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16), decoration: BoxDecoration(
        color: AppColors.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(
            color: stageColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.directions_bus_rounded, color: AppColors.primary, size: 22)),
          const Gap(10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(bus.busNumber, style: Theme.of(context).textTheme.titleMedium),
            Text(bus.customerName, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12)),
          ])),
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: stageColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
            child: Text(bus.currentStage, style: TextStyle(color: stageColor, fontSize: 11, fontWeight: FontWeight.w600))),
        ]),
        const Gap(12),
        ClipRRect(borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(value: bus.completionPercent / 100, minHeight: 6,
            backgroundColor: AppColors.border, color: stageColor)),
        const Gap(8),
        Row(children: [
          Text('${bus.completionPercent.toStringAsFixed(0)}% complete',
            style: TextStyle(fontSize: 11, color: stageColor, fontWeight: FontWeight.w600)),
          const Spacer(),
          if (bus.isDelayed)
            Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
              child: const Text('DELAYED', style: TextStyle(color: AppColors.error, fontSize: 10, fontWeight: FontWeight.w700))),
        ]),
        const Gap(10),
        SizedBox(width: double.infinity, height: 36,
          child: OutlinedButton(onPressed: () => _showUpdateDialog(context, ref, bus),
            child: const Text('Update Stage', style: TextStyle(fontSize: 12)))),
      ]));
  }

  void _showUpdateDialog(BuildContext context, WidgetRef ref, Bus bus) {
    showDialog(context: context, builder: (_) => _UpdateBusDialog(bus: bus));
  }
}

class _UpdateBusDialog extends ConsumerStatefulWidget {
  final Bus bus;
  const _UpdateBusDialog({required this.bus});
  @override
  ConsumerState<_UpdateBusDialog> createState() => _UpdateBusDialogState();
}

class _UpdateBusDialogState extends ConsumerState<_UpdateBusDialog> {
  int _selectedIdx = 0;
  final _remarksCtrl = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _selectedIdx = widget.bus.currentStageIndex + 1;
    if (_selectedIdx >= AppConstants.productionStages.length) _selectedIdx = AppConstants.productionStages.length - 1;
  }

  @override
  void dispose() { _remarksCtrl.dispose(); super.dispose(); }

  Future<void> _update() async {
    setState(() => _loading = true);
    final emp = ref.read(currentEmployeeProvider).valueOrNull;
    await ref.read(productionRepositoryProvider).updateBusStage(
      widget.bus.id, _selectedIdx, AppConstants.productionStages[_selectedIdx],
      emp?.id ?? '', emp?.name ?? 'Supervisor',
      remarks: _remarksCtrl.text.trim().isEmpty ? null : _remarksCtrl.text.trim(),
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Update: ${widget.bus.busNumber}'),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Current: ${widget.bus.currentStage}', style: const TextStyle(color: AppColors.textSecondary)),
          const Gap(12),
          ...List.generate(AppConstants.productionStages.length, (i) => RadioListTile<int>(
            value: i, groupValue: _selectedIdx, dense: true, title: Text(AppConstants.productionStages[i],
              style: TextStyle(fontWeight: i == _selectedIdx ? FontWeight.w600 : FontWeight.w400)),
            onChanged: (v) => setState(() => _selectedIdx = v!),
            activeColor: AppColors.productionStages[i % AppColors.productionStages.length])),
          const Gap(8),
          TextField(controller: _remarksCtrl, decoration: const InputDecoration(labelText: 'Remarks', hintText: 'Optional notes...')),
        ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(onPressed: _loading ? null : _update, child: const Text('Save')),
      ],
    );
  }
}

class _AddBusSheet extends ConsumerStatefulWidget {
  const _AddBusSheet();
  @override
  ConsumerState<_AddBusSheet> createState() => _AddBusSheetState();
}

class _AddBusSheetState extends ConsumerState<_AddBusSheet> {
  final _busCtrl = TextEditingController(), _chassisCtrl = TextEditingController(), _modelCtrl = TextEditingController(), _customerCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() { _busCtrl.dispose(); _chassisCtrl.dispose(); _modelCtrl.dispose(); _customerCtrl.dispose(); super.dispose(); }

  Future<void> _add() async {
    if (_busCtrl.text.trim().isEmpty || _chassisCtrl.text.trim().isEmpty) return;
    setState(() => _loading = true);
    final emp = ref.read(currentEmployeeProvider).valueOrNull;
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    await FirebaseFirestore.instance.collection('buses').doc(id).set({
      'id': id, 'busNumber': _busCtrl.text.trim(), 'chassisNumber': _chassisCtrl.text.trim(),
      'model': _modelCtrl.text.trim(), 'customerName': _customerCtrl.text.trim(),
      'branchId': emp?.branchId ?? 'default', 'currentStage': 'Chassis Received',
      'currentStageIndex': 0, 'status': 'active', 'startDate': DateTime.now().toIso8601String(),
      'createdAt': FieldValue.serverTimestamp(), 'updatedAt': FieldValue.serverTimestamp(),
    });
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
      Text('Add New Bus', style: Theme.of(context).textTheme.headlineMedium),
      const Gap(20),
      TextField(controller: _busCtrl, decoration: const InputDecoration(labelText: 'Bus Number')),
      const Gap(12), TextField(controller: _chassisCtrl, decoration: const InputDecoration(labelText: 'Chassis Number')),
      const Gap(12), TextField(controller: _modelCtrl, decoration: const InputDecoration(labelText: 'Model')),
      const Gap(12), TextField(controller: _customerCtrl, decoration: const InputDecoration(labelText: 'Customer')),
      const Gap(20),
      SizedBox(width: double.infinity, height: 48,
        child: ElevatedButton(onPressed: _loading ? null : _add,
          child: _loading ? const CircularProgressIndicator(strokeWidth: 2, color: Colors.white) : const Text('Add Bus'))),
      const Gap(12),
    ]));
  }
}
