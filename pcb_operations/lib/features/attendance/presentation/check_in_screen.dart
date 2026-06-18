import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/image_helper.dart';
import '../../../data/models/employee.dart';
import '../data/attendance_repository.dart';

class CheckInScreen extends ConsumerStatefulWidget {
  final Employee? employee;
  const CheckInScreen({super.key, this.employee});
  @override
  ConsumerState<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends ConsumerState<CheckInScreen> {
  int _step = 1;
  File? _selfieFile;
  Position? _position;
  bool _isLoading = false;
  String? _error;

  String get _employeeName => widget.employee?.name ?? 'Worker';
  String get _branchId => widget.employee?.branchId ?? 'default';

  Future<void> _captureLocation() async {
    setState(() => _error = null);
    try {
      final perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        final result = await Geolocator.requestPermission();
        if (result == LocationPermission.denied) {
          setState(() => _error = 'Location permission is required');
          return;
        }
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.bestForNavigation));
      setState(() { _position = pos; _step = 2; });
    } catch (_) {
      setState(() => _error = 'Could not get location. Enable GPS.');
    }
  }

  Future<void> _captureSelfie() async {
    setState(() => _error = null);
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.camera, imageQuality: 70, maxWidth: 800);
      if (image != null) {
        setState(() { _selfieFile = File(image.path); _step = 3; });
      }
    } catch (_) {
      setState(() => _error = 'Camera not available. Try again.');
    }
  }

  Future<void> _submit() async {
    if (_selfieFile == null || _position == null) return;
    setState(() { _isLoading = true; _error = null; });
    try {
      final repo = ref.read(attendanceRepositoryProvider);
      final selfieBase64 = await ImageHelper.fileToBase64(_selfieFile!);

      await repo.checkIn(
        employeeName: _employeeName, branchId: _branchId,
        latitude: _position!.latitude, longitude: _position!.longitude,
        selfieBase64: selfieBase64,
      );

      if (mounted) {
        ref.invalidate(todayAttendanceProvider);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Checked in successfully!'), backgroundColor: AppColors.success));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() { _error = 'Check-in failed. Please try again.'; _isLoading = false; });
      }
    }
  }

  void _goToStep(int step) {
    setState(() { _step = step; _error = null; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Check In'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          _ProgressIndicator(current: _step),
          const Gap(24),
          if (_step == 1) _buildStep1(),
          if (_step == 2) _buildStep2(),
          if (_step == 3) _buildStep3(),
          if (_error != null) ...[
            const Gap(16),
            Container(padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10)),
              child: Row(children: [
                const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 20),
                const Gap(8),
                Expanded(child: Text(_error!, style: const TextStyle(color: AppColors.error, fontSize: 13))),
              ])),
          ],
        ]),
      ),
      bottomNavigationBar: _step == 3 && !_isLoading
          ? Padding(padding: const EdgeInsets.all(16),
              child: SizedBox(height: 52, child: ElevatedButton.icon(
                onPressed: _submit, icon: const Icon(Icons.check_rounded),
                label: const Text('Confirm Check In'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white))))
          : null,
    );
  }

  Widget _buildStep1() {
    return Column(children: [
      Icon(Icons.gps_fixed, size: 64, color: AppColors.primary.withValues(alpha: 0.3)),
      const Gap(16),
      Text('Step 1: Location', style: Theme.of(context).textTheme.headlineMedium),
      const Gap(8),
      Text('Your GPS location is captured to verify\nyou are on-site',
        textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
      const Gap(24),
      SizedBox(width: double.infinity, height: 52,
        child: ElevatedButton.icon(
          onPressed: _captureLocation, icon: const Icon(Icons.my_location),
          label: const Text('Capture My Location'),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white))),
    ]);
  }

  Widget _buildStep2() {
    return Column(children: [
      Container(padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.accent.withValues(alpha: 0.2))),
        child: Row(children: [
          const Icon(Icons.check_circle, color: AppColors.accent, size: 22),
          const Gap(10),
          Text('Location captured', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600)),
          const Spacer(),
          TextButton(onPressed: () => _goToStep(1), child: const Text('Retake')),
        ])),
      const Gap(24),
      Icon(Icons.camera_alt_rounded, size: 64, color: AppColors.primary.withValues(alpha: 0.3)),
      const Gap(16),
      Text('Step 2: Selfie', style: Theme.of(context).textTheme.headlineMedium),
      const Gap(8),
      Text('Take a photo for attendance verification',
        textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
      const Gap(24),
      SizedBox(width: double.infinity, height: 52,
        child: ElevatedButton.icon(
          onPressed: _captureSelfie, icon: const Icon(Icons.camera_alt_rounded),
          label: const Text('Take Selfie'),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white))),
    ]);
  }

  Widget _buildStep3() {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [
        Expanded(child: _MiniDoneCard(icon: Icons.gps_fixed, label: 'Location', onTap: () => _goToStep(1))),
        const Gap(10),
        Expanded(child: _MiniDoneCard(icon: Icons.camera_alt, label: 'Selfie', onTap: () => _goToStep(2))),
      ]),
      const Gap(16),
      if (_selfieFile != null)
        ClipRRect(borderRadius: BorderRadius.circular(12),
          child: Image.file(_selfieFile!, height: 240, width: double.infinity, fit: BoxFit.cover)),
      if (_position != null) ...[
        const Gap(12),
        Card(child: Padding(padding: const EdgeInsets.all(12), child: Row(children: [
          const Icon(Icons.location_on, color: AppColors.accent),
          const Gap(8),
          Expanded(child: Text('${_position!.latitude.toStringAsFixed(5)}, ${_position!.longitude.toStringAsFixed(5)}',
            style: const TextStyle(fontSize: 12, fontFamily: 'monospace', color: AppColors.textSecondary)))]))),
      ],
    ]);
  }
}

class _MiniDoneCard extends StatelessWidget {
  final IconData icon; final String label; final VoidCallback onTap;
  const _MiniDoneCard({required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Card(child: InkWell(onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(padding: const EdgeInsets.all(14), child: Row(children: [
        Icon(icon, color: AppColors.success, size: 20),
        const Gap(8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const Spacer(),
        const Icon(Icons.check_circle, color: AppColors.success, size: 18),
      ]))));
  }
}

class _ProgressIndicator extends StatelessWidget {
  final int current;
  const _ProgressIndicator({required this.current});
  static const _steps = ['Location', 'Selfie', 'Confirm'];
  @override
  Widget build(BuildContext context) {
    return Row(children: List.generate(_steps.length * 2 - 1, (i) {
      if (i.isOdd) return const Expanded(child: Divider(height: 1, color: AppColors.border));
      final step = i ~/ 2;
      final done = step < current - 1;
      final active = step == current - 1;
      return Column(children: [
        Container(width: 28, height: 28,
          decoration: BoxDecoration(
            color: done ? AppColors.success : active ? AppColors.primary : AppColors.border,
            shape: BoxShape.circle),
          child: Center(child: done
              ? const Icon(Icons.check, color: Colors.white, size: 14)
              : Text('${step + 1}', style: TextStyle(color: active ? Colors.white : AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)))),
        const Gap(6),
        Text(_steps[step], style: TextStyle(fontSize: 11, color: active ? AppColors.textPrimary : AppColors.textSecondary)),
      ]);
    }));
  }
}
