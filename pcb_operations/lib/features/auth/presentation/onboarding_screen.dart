import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/app_colors.dart';
import '../data/auth_service.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});
  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _empIdCtrl = TextEditingController();
  String? _selectedDept;
  String? _selectedRole = 'employee';
  bool _isLoading = false;
  String? _error;

  static const _departments = [
    'Fabrication', 'Welding', 'Sheet Metal', 'Painting',
    'Electrical', 'Interior', 'Testing', 'Quality', 'Administration'
  ];

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose(); _passwordCtrl.dispose();
    _phoneCtrl.dispose(); _empIdCtrl.dispose(); super.dispose();
  }

  Future<void> _onboardWorker() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _error = null; });
    try {
      final auth = ref.read(authServiceProvider);
      final cred = await auth.createAccount(_emailCtrl.text.trim(), _passwordCtrl.text.trim());
      if (cred?.user == null) return;

      await FirebaseFirestore.instance.collection('employees').doc(cred!.user!.uid).set({
        'id': cred.user!.uid,
        'employeeId': _empIdCtrl.text.trim(),
        'name': _nameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'designation': 'Worker',
        'department': _selectedDept ?? 'Fabrication',
        'branchId': 'default',
        'branchName': 'Main Branch',
        'role': _selectedRole ?? 'employee',
        'isActive': true,
        'isCheckedIn': false,
        'joinDate': DateTime.now().toIso8601String(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Worker onboarded!'), backgroundColor: AppColors.success));
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _error = ref.read(authServiceProvider).getErrorMessage(e));
    } catch (e) {
      setState(() => _error = 'Failed to onboard. Try again.');
    } finally {
      if (mounted) { setState(() => _isLoading = false); }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Onboard Worker'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(key: _formKey, child: Column(children: [
          const Gap(8),
          Text('Register a new worker', style: Theme.of(context).textTheme.bodyLarge
              ?.copyWith(color: AppColors.textSecondary)),
          const Gap(20),
          TextFormField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person)),
            validator: (v) => v!.isEmpty ? 'Required' : null),
          const Gap(14),
          TextFormField(
            controller: _empIdCtrl,
            decoration: const InputDecoration(labelText: 'Employee ID', prefixIcon: Icon(Icons.badge_outlined)),
            validator: (v) => v!.isEmpty ? 'Required' : null),
          const Gap(14),
          TextFormField(
            controller: _phoneCtrl, keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'Phone', prefixIcon: Icon(Icons.phone_outlined)),
            validator: (v) => v!.isEmpty ? 'Required' : null),
          const Gap(14),
          TextFormField(
            controller: _emailCtrl, keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
            validator: (v) {
              if (v!.isEmpty) return 'Required';
              if (!v.contains('@')) return 'Invalid email';
              return null;
            }),
          const Gap(14),
          TextFormField(
            controller: _passwordCtrl, obscureText: true,
            decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock_outlined)),
            validator: (v) => v!.length < 6 ? 'Min 6 characters' : null),
          const Gap(14),
          DropdownButtonFormField<String>(
            initialValue: _selectedDept,
            items: _departments.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) => setState(() => _selectedDept = v),
            decoration: const InputDecoration(labelText: 'Department', prefixIcon: Icon(Icons.business_rounded))),
          const Gap(14),
          DropdownButtonFormField<String>(
            initialValue: 'employee',
            items: ['employee', 'supervisor', 'admin']
                .map((e) => DropdownMenuItem(value: e, child: Text(e.capitalize))).toList(),
            onChanged: (v) => _selectedRole = v,
            decoration: const InputDecoration(labelText: 'Role', prefixIcon: Icon(Icons.shield_outlined))),
          if (_error != null) ...[
            const Gap(14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10)),
              child: Text(_error!, style: const TextStyle(color: AppColors.error, fontSize: 13))),
          ],
          const Gap(24),
          SizedBox(height: 52, width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _onboardWorker,
              child: _isLoading
                  ? const SizedBox(width: 22, height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                  : const Text('Register Worker'))),
        ]))));
  }
}

extension _StringExt on String {
  String get capitalize => '${this[0].toUpperCase()}${substring(1)}';
}
