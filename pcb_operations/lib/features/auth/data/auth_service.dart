import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthService {
  final FirebaseAuth _auth;

  AuthService(this._auth);

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  bool get isLoggedIn => _auth.currentUser != null;

  String? get uid => _auth.currentUser?.uid;

  String? get email => _auth.currentUser?.email;

  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException {
      rethrow;
    }
  }

  Future<UserCredential?> createAccount(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException {
      rethrow;
    }
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  String getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'An account already exists with this email';
      case 'invalid-email':
        return 'Please enter a valid email address';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'weak-password':
        return 'Password should be at least 6 characters';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      case 'network-request-failed':
        return 'Network error. Check your connection';
      default:
        return e.message ?? 'Something went wrong';
    }
  }
}

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(FirebaseAuth.instance);
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges();
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authServiceProvider).currentUser;
});
