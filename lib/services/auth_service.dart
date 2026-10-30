import 'package:firebase_auth/firebase_auth.dart';

/// An error with a message that is safe to show to the user.
class AuthException implements Exception {
  const AuthException(this.message);
  final String message;
}

/// All sign in / sign up / sign out work lives here, away from the UI.
class AuthService {
  const AuthService();

  FirebaseAuth get _auth => FirebaseAuth.instance;

  /// Emits the signed-in user, or null when signed out.
  Stream<User?> get authChanges => _auth.authStateChanges();

  Future<void> signIn(String email, String password) {
    return _guard(
      () => _auth.signInWithEmailAndPassword(email: email, password: password),
    );
  }

  Future<void> register(String email, String password) {
    return _guard(
      () => _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      ),
    );
  }

  /// CHANGE (NEW): Asks Firebase to email a "reset password" link.
  /// Firebase sends the email and hosts the page where the user picks
  /// a new password, so we do not need to build that page ourselves.
  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      // Security: if the email has no account we pretend it worked.
      // Otherwise someone could use this screen to discover which
      // emails are registered in our app.
      if (e.code == 'user-not-found') return;
      throw AuthException(_messageFor(e.code));
    }
  }

  Future<void> signOut() => _auth.signOut();

  /// Runs [action] and converts Firebase errors into friendly messages.
  Future<void> _guard(Future<void> Function() action) async {
    try {
      await action();
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageFor(e.code));
    }
  }

  String _messageFor(String code) {
    return switch (code) {
      'invalid-email' => 'That email address is not valid.',
      'user-not-found' ||
      'wrong-password' ||
      'invalid-credential' =>
        'Incorrect email or password.',
      'email-already-in-use' => 'An account already exists for that email.',
      'weak-password' => 'Password is too weak. Please choose a stronger one.',
      // CHANGE (NEW): Firebase's server-side password policy rejected the
      // password (this also covers the reset-password page).
      'password-does-not-meet-requirements' =>
        'Password must be 8+ characters with uppercase, lowercase, '
            'a number and a special character.',
      'network-request-failed' => 'No internet connection.',
      // CHANGE (NEW): shown when too many reset/sign-in attempts are made.
      'too-many-requests' => 'Too many attempts. Please try again later.',
      _ => 'Something went wrong. Please try again.',
    };
  }
}