import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _user != null;
  bool get isEmailVerified => _user?.emailVerified ?? false;

  AuthProvider() {
    // Immediately grab the current user (fixes intermittent sign-in bug).
    _user = _authService.currentUser;
    // Then keep listening for future changes.
    _authService.authStateChanges.listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  void _setLoading(bool value) { _isLoading = value; notifyListeners(); }
  void _setError(String? msg)  { _errorMessage = msg; notifyListeners(); }
  void clearError()             { _errorMessage = null; notifyListeners(); }

  // ── Sign Up ───────────────────────────────────────────────────────────────

  Future<bool> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      final cred = await _authService.signUpWithEmail(
        email: email, password: password,
        firstName: firstName, lastName: lastName,
      );
      _user = cred.user;

      // Save profile to Firestore immediately after account creation.
      if (_user != null) {
        await _userService.createUser(UserModel(
          uid: _user!.uid,
          firstName: firstName,
          lastName: lastName,
          email: email,
          bio: '',
        ));
      }
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_friendlyError(e.code));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ── Sign In ───────────────────────────────────────────────────────────────

  Future<bool> signIn({required String email, required String password}) async {
    _setLoading(true);
    _setError(null);
    try {
      final cred = await _authService.signInWithEmail(
          email: email, password: password);
      // Update immediately — do not wait for the auth stream.
      _user = cred.user;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_friendlyError(e.code));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _setError(null);
    try {
      final cred = await _authService.signInWithGoogle();
      if (cred == null) return false;
      _user = cred.user;

      // Create Firestore profile if this is a first-time Google login.
      if (_user != null) {
        final exists = await _userService.userExists(_user!.uid);
        if (!exists) {
          final nameParts = (_user!.displayName ?? '').split(' ');
          await _userService.createUser(UserModel(
            uid: _user!.uid,
            firstName: nameParts.isNotEmpty ? nameParts.first : '',
            lastName: nameParts.length > 1 ? nameParts.skip(1).join(' ') : '',
            email: _user!.email ?? '',
            bio: '',
          ));
        }
      }
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_friendlyError(e.code));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ── Email Verification ────────────────────────────────────────────────────

  Future<void> resendVerificationEmail() async =>
      _authService.resendVerificationEmail();

  Future<bool> checkEmailVerified() async {
    final verified = await _authService.checkEmailVerified();
    if (verified) { _user = _authService.currentUser; notifyListeners(); }
    return verified;
  }

  // ── Password Reset ────────────────────────────────────────────────────────

  Future<bool> sendPasswordReset(String email) async {
    _setLoading(true);
    _setError(null);
    try {
      await _authService.sendPasswordResetEmail(email);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_friendlyError(e.code));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ── Sign Out ──────────────────────────────────────────────────────────────

  Future<void> signOut() async => _authService.signOut();

  // ── Error Messages ────────────────────────────────────────────────────────

  String _friendlyError(String code) {
    switch (code) {
      case 'email-already-in-use': return 'An account with this email already exists.';
      case 'invalid-email':        return 'Please enter a valid email address.';
      case 'weak-password':        return 'Password must be at least 6 characters.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':  return 'Incorrect email or password.';
      case 'user-disabled':        return 'This account has been disabled.';
      case 'too-many-requests':    return 'Too many attempts. Please try again later.';
      default:                     return 'Something went wrong. Please try again.';
    }
  }
}
