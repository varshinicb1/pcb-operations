import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/employee.dart';
import '../data/attendance_repository.dart';
import '../data/face_verification_service.dart';

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
  String? _verifyStatus;
  FaceVerificationService? _faceService;

  String get _employeeName => widget.employee?.name ?? 'Worker';
  String get _branchId => widget.employee?.branchId ?? 'default';
  String get _employeeId => widget.employee?.id ?? '';

  @override
  void initState() {
    super.initState();
    _faceService = FaceVerificationService();
  }

  @override
  void dispose() {
    _faceService?.dispose();
    super.dispose();
  }

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
        setState(() { _selfieFile = File(image.path); _step = 3; _verifyStatus = null; });
      }
    } catch (_) {
      setState(() => _error = 'Camera not available. Try again.');
    }
  }

  Future<void> _verifyFace() async {
    if (_selfieFile == null) return;
    setState(() { _isLoading = true; _error = null; _verifyStatus = null; });
    try {
      final currentFace = await _faceService!.extractFaceData(_selfieFile!);

      final faceDoc = await FirebaseFirestore.instance
          .collection('employees').doc(_employeeId).collection('faceData').doc('reference').get();
      if (!faceDoc.exists) {
        setState(() {
          _verifyStatus = 'no_reference';
          _error = 'No reference face registered. Using photo for admin review.';
          _isLoading = false;
        });
        return;
      }

      final refFace = FaceData.fromJson(faceDoc.data()! as Map<String, dynamic>);
      final verified = _faceService!.isVerifiedFace(refFace, currentFace);

      if (verified) {
        setState(() {
          _verifyStatus = 'verified';
          _isLoading = false;
        });
      } else {
        setState(() {
          _verifyStatus = 'failed';
          _error = 'Face not matched. Photo saved for admin review.';
          _isLoading = false;
        });
      }
    } on FaceVerificationException catch (e) {
      setState(() {
        _verifyStatus = 'no_face';
        _error = e.message;
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _verifyStatus = 'error';
        _error = 'Verification failed. Try again.';
        _isLoading = false;
      });
    }
  }

  Future<void> _submit() async {
    if (_position == null) return;
    setState(() { _isLoading = true; _error = null; });
    try {
      final repo = ref.read(attendanceRepositoryProvider);

      String? selfieBase64;
      if (_verifyStatus != 'verified' && _selfieFile != null) {
        final bytes = await _selfieFile!.readAsBytes();
        selfieBase64 = 'data:image/jpeg;base64,${base64Encode(bytes)}';
      }

      await repo.checkIn(
        employeeName: _employeeName, branchId: _branchId,
        latitude: _position!.latitude, longitude: _position!.longitude,
        selfieBase64: selfieBase64, verificationStatus: _verifyStatus,
      );

      if (mounted) {
        ref.invalidate(todayAttendanceProvider);
        final msg = _verifyStatus == 'verified'
            ? 'Verified! Attendance recorded.'
            : 'Check-in recorded. Pending admin review.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: _verifyStatus == 'verified' ? AppColors.success : AppColors.accent));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() { _error = 'Check-in failed. Try again.'; _isLoading = false; });
      }
    }
  }

  void _goToStep(int step) => setState(() { _step = step; _error = null; });

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
              decoration: BoxDecoration(color: AppColors.errorBg, borderRadius: BorderRadius.circular(10)),
              child: Row(children: [
                const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 20), const Gap(8),
                Expanded(child: Text(_error!, style: const TextStyle(color: AppColors.error, fontSize: 13)))])),
          ],
        ]),
      ),
      bottomNavigationBar: _step == 3 && _verifyStatus != null && !_isLoading
          ? Padding(padding: const EdgeInsets.all(16),
              child: SizedBox(height: 52, child: ElevatedButton.icon(
                onPressed: _submit, icon: const Icon(Icons.check_rounded),
                label: Text(_verifyStatus == 'verified' ? 'Submit Verified Attendance' : 'Submit for Review'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _verifyStatus == 'verified' ? AppColors.success : AppColors.accent,
                  foregroundColor: Colors.white))))
          : null,
    );
  }

  Widget _buildStep1() => _buildStep(
    icon: Icons.gps_fixed, title: 'Step 1: Location',
    subtitle: 'Capturing your GPS to verify you are on-site',
    actionLabel: 'Capture My Location', onAction: _captureLocation, color: AppColors.primary);

  Widget _buildStep2() => Column(children: [
    Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(
      color: AppColors.accent.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppColors.accent.withValues(alpha: 0.2))),
      child: Row(children: [
        const Icon(Icons.check_circle, color: AppColors.accent, size: 22), const Gap(10),
        Text('Location captured', style: TextStyle(color: AppColors.accentDark, fontWeight: FontWeight.w600)),
        const Spacer(), TextButton(onPressed: () => _goToStep(1), child: const Text('Retake'))])),
    const Gap(24),
    _buildStep(
      icon: Icons.camera_alt_rounded, title: 'Step 2: Selfie',
      subtitle: 'Take a photo for face verification',
      actionLabel: 'Take Selfie', onAction: _captureSelfie, color: AppColors.primary)]);

  Widget _buildStep3() => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    Row(children: [
      Expanded(child: _MiniDoneCard(icon: Icons.gps_fixed, label: 'Location', onTap: () => _goToStep(1))),
      const Gap(10),
      Expanded(child: _MiniDoneCard(icon: Icons.camera_alt, label: 'Selfie', onTap: () => _goToStep(2)))]),
    const Gap(16),
    if (_selfieFile != null) ...[
      ClipRRect(borderRadius: BorderRadius.circular(12),
        child: Image.file(_selfieFile!, height: 200, width: double.infinity, fit: BoxFit.cover)),
      const Gap(16),
      if (_verifyStatus == null)
        SizedBox(width: double.infinity, height: 48,
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _verifyFace,
            icon: _isLoading ? const SizedBox(width: 20, height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.face_retouching_natural),
            label: const Text('Verify Face'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white))),
      if (_verifyStatus == 'verified')
        Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(
          color: AppColors.successBg, borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.success.withValues(alpha: 0.3))),
          child: const Row(children: [
            Icon(Icons.verified, color: AppColors.success, size: 24), Gap(10),
            Expanded(child: Text('Face verified! Photo will be deleted after check-in.',
              style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w600)))])),
      if (_verifyStatus == 'failed')
        Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(
          color: AppColors.warningBg, borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.accent.withValues(alpha: 0.3))),
          child: const Row(children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.accentDark, size: 24), Gap(10),
            Expanded(child: Text('Verification failed. Photo saved for admin review.',
              style: TextStyle(color: AppColors.accentDark, fontWeight: FontWeight.w600)))])),
      if (_verifyStatus == 'no_reference' || _verifyStatus == 'no_face' || _verifyStatus == 'error')
        Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(
          color: AppColors.warningBg, borderRadius: BorderRadius.circular(12)),
          child: Row(children: [
            const Icon(Icons.info_outline, color: AppColors.accentDark, size: 24), const Gap(10),
            Expanded(child: Text(_error ?? 'Verification unavailable',
              style: const TextStyle(color: AppColors.accentDark, fontWeight: FontWeight.w500)))]))],
    if (_position != null) ...[const Gap(12),
      Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(
        color: AppColors.card, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
        child: Row(children: [
          const Icon(Icons.location_on, color: AppColors.accent), const Gap(8),
          Expanded(child: Text('${_position!.latitude.toStringAsFixed(5)}, ${_position!.longitude.toStringAsFixed(5)}',
            style: const TextStyle(fontSize: 12, fontFamily: 'monospace', color: AppColors.textSecondary)))])),
    ],
  ]);

  Widget _buildStep({required IconData icon, required String title, required String subtitle, required String actionLabel, required VoidCallback onAction, required Color color}) {
    return Column(children: [
      Icon(icon, size: 64, color: color.withValues(alpha: 0.3)), const Gap(16),
      Text(title, style: Theme.of(context).textTheme.headlineMedium), const Gap(8),
      Text(subtitle, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium), const Gap(24),
      SizedBox(width: double.infinity, height: 52,
        child: ElevatedButton.icon(onPressed: onAction, icon: Icon(icon, size: 20), label: Text(actionLabel),
          style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white)))]);}
}

class _MiniDoneCard extends StatelessWidget {
  final IconData icon; final String label; final VoidCallback onTap;
  const _MiniDoneCard({required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) => Card(child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(12),
    child: Padding(padding: const EdgeInsets.all(14), child: Row(children: [
      Icon(icon, color: AppColors.success, size: 20), const Gap(8),
      Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
      const Spacer(), const Icon(Icons.check_circle, color: AppColors.success, size: 18)]))));
}

class _ProgressIndicator extends StatelessWidget {
  final int current;
  const _ProgressIndicator({required this.current});
  static const _steps = ['GPS', 'Selfie', 'Verify'];
  @override
  Widget build(BuildContext context) => Row(children: List.generate(_steps.length * 2 - 1, (i) {
    if (i.isOdd) return const Expanded(child: Divider(height: 1, color: AppColors.border));
    final s = i ~/ 2; final done = s < current - 1; final active = s == current - 1;
    return Column(children: [
      Container(width: 28, height: 28, decoration: BoxDecoration(
        color: done ? AppColors.success : active ? AppColors.primary : AppColors.border, shape: BoxShape.circle),
        child: Center(child: done
          ? const Icon(Icons.check, color: Colors.white, size: 14)
          : Text('${s + 1}', style: TextStyle(color: active ? Colors.white : AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)))),
      const Gap(6), Text(_steps[s], style: TextStyle(fontSize: 11, color: active ? AppColors.textPrimary : AppColors.textSecondary))]);}));
}

