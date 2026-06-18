import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gap/gap.dart';
import '../../../core/theme/app_colors.dart';
import '../data/auth_service.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _showPass = false;
  bool _loading = false;
  bool _isRegistering = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose(); _passCtrl.dispose();
    _nameCtrl.dispose(); _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      await ref.read(authServiceProvider).signInWithEmail(_emailCtrl.text.trim(), _passCtrl.text.trim());
    } on FirebaseAuthException catch (e) {
      if (mounted) { setState(() { _error = ref.read(authServiceProvider).getErrorMessage(e); _loading = false; }); }
    } catch (_) {
      if (mounted) { setState(() { _error = 'Something went wrong'; _loading = false; }); }
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_isRegistering && _nameCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Name is required');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final cred = await ref.read(authServiceProvider).createAccount(_emailCtrl.text.trim(), _passCtrl.text.trim());
      if (cred?.user != null) {
        final uid = cred!.user!.uid;
        final name = _nameCtrl.text.trim().isEmpty ? 'Worker' : _nameCtrl.text.trim();
        await FirebaseFirestore.instance.collection('employees').doc(uid).set({
          'id': uid, 'employeeId': 'PCB${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
          'name': name, 'email': _emailCtrl.text.trim(),
          'phone': _phoneCtrl.text.trim(), 'designation': 'Worker',
          'department': 'General', 'branchId': 'default', 'branchName': 'Main Branch',
          'role': 'employee', 'isActive': true, 'isCheckedIn': false,
          'joinDate': DateTime.now().toIso8601String(),
          'createdAt': FieldValue.serverTimestamp(), 'updatedAt': FieldValue.serverTimestamp(),
        });
        await FirebaseFirestore.instance.collection('notifications').add({
          'type': 'new_registration', 'employeeId': uid, 'employeeName': name,
          'branchId': 'default', 'read': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account created! Sign in now.'), backgroundColor: AppColors.success));
          setState(() { _isRegistering = false; _loading = false; });
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) { setState(() { _error = ref.read(authServiceProvider).getErrorMessage(e); _loading = false; }); }
    } catch (_) {
      if (mounted) { setState(() { _error = 'Registration failed'; _loading = false; }); }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Form(
              key: _formKey,
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Gap(48),
                Image.asset('assets/images/smk_logo.png', height: 48)
                  .animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.9, 0.9)),
                const Gap(40),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 30)]),
                  child: Column(children: [
                    Text(_isRegistering ? 'Create Account' : 'Sign In',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: AppColors.primaryDark)),
                    const Gap(4),
                    Text(_isRegistering ? 'Self-onboard as a worker' : 'Enter your credentials',
                      style: Theme.of(context).textTheme.bodyMedium),
                    const Gap(24),
                    if (_isRegistering) ...[
                      TextFormField(controller: _nameCtrl, decoration: const InputDecoration(
                        labelText: 'Full Name', prefixIcon: Icon(Icons.person_outlined, size: 20)),
                        validator: (v) => _isRegistering && (v == null || v.trim().isEmpty) ? 'Required' : null),
                      const Gap(14),
                      TextFormField(controller: _phoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(
                        labelText: 'Phone', prefixIcon: Icon(Icons.phone_outlined, size: 20))),
                      const Gap(14),
                    ],
                    TextFormField(controller: _emailCtrl, keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined, size: 20)),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Email required' : !v.contains('@') ? 'Invalid' : null),
                    const Gap(14),
                    TextFormField(controller: _passCtrl, obscureText: !_showPass,
                      decoration: InputDecoration(labelText: 'Password', prefixIcon: const Icon(Icons.lock_outlined, size: 20),
                        suffixIcon: IconButton(icon: Icon(_showPass ? Icons.visibility_off : Icons.visibility, size: 20),
                          onPressed: () => setState(() => _showPass = !_showPass))),
                      validator: (v) => v == null || v.length < 6 ? 'Min 6 characters' : null),
                    if (_error != null) ...[
                      const Gap(12),
                      Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(
                        color: AppColors.errorBg, borderRadius: BorderRadius.circular(10)),
                        child: Row(children: [
                          const Icon(Icons.error_outline, color: AppColors.error, size: 18), const Gap(8),
                          Expanded(child: Text(_error!, style: const TextStyle(color: AppColors.error, fontSize: 13)))])),
                    ],
                    const Gap(20),
                    SizedBox(width: double.infinity, height: 48,
                      child: ElevatedButton(
                        onPressed: _loading ? null : (_isRegistering ? _register : _login),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent, foregroundColor: AppColors.primaryDark),
                        child: _loading ? const SizedBox(width: 22, height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.primaryDark))
                          : Text(_isRegistering ? 'Create Account' : 'Sign In'))),
                    const Gap(16),
                    TextButton(
                      onPressed: () => setState(() => _isRegistering = !_isRegistering),
                      child: Text(_isRegistering ? 'Already have an account? Sign In' : 'New worker? Register here')),
                  ]),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.05),
                const Gap(24),
                Text('Prakash Coach Builders • v1.0',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 11)),
              ]))))));
  }
}
