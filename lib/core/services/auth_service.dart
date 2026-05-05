import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Wraps Firebase Authentication and Google Sign-In.
/// All screens interact with this service — never directly with Firebase.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  /// The currently signed-in user, or null if not authenticated.
  User? get currentUser => _auth.currentUser;

  /// Stream of auth state changes (signed in / signed out).
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ── Sign Up ───────────────────────────────────────────────────────────────

  /// Creates a new account with email and password.
  /// Returns the [UserCredential] on success.
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Save display name immediately after sign-up.
    await credential.user?.updateDisplayName('$firstName $lastName');

    // Send the verification email.
    await credential.user?.sendEmailVerification();

    return credential;
  }

  // ── Login ─────────────────────────────────────────────────────────────────

  /// Signs in with email and password.
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Signs in using Google OAuth.
  /// Returns null if the user cancels. Throws on actual errors.
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Force the account chooser to appear every time.
      await _googleSignIn.signOut();
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // User cancelled.

      final googleAuth = await googleUser.authentication;

      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        throw PlatformException(
          code: 'MISSING_GOOGLE_AUTH_TOKEN',
          message: 'Google authentication tokens are missing.',
        );
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return _auth.signInWithCredential(credential);
    } on PlatformException {
      rethrow;
    } catch (e) {
      throw FirebaseAuthException(
        code: 'google-sign-in-failed',
        message: e.toString(),
      );
    }
  }

  // ── Email Verification ────────────────────────────────────────────────────

  /// Re-sends the email verification link.
  Future<void> resendVerificationEmail() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  /// Reloads the current user to refresh the emailVerified flag.
  Future<bool> checkEmailVerified() async {
    await _auth.currentUser?.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  // ── Password Reset ────────────────────────────────────────────────────────

  /// Sends a password-reset email to the provided address.
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // ── Sign Out ──────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }
}
