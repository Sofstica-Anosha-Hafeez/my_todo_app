// Widget tests for lib/screens/sign_in_screen.dart
//
// PROBLEM: the real AuthService talks to Firebase (internet, real accounts).
// Tests must be fast, offline and safe.
// SOLUTION: a "fake" AuthService. It looks the same from outside, but it
// only records what was called and never touches Firebase.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:todo_app/screens/sign_in_screen.dart';
import 'package:todo_app/services/auth_service.dart';

/// A pretend AuthService used only in tests.
class FakeAuthService implements AuthService {
  int signInCalls = 0;
  int registerCalls = 0;
  String? lastResetEmail;

  /// Set to true to make signIn fail like a wrong password.
  bool failSignIn = false;

  @override
  Stream<User?> get authChanges => const Stream<User?>.empty();

  @override
  Future<void> signIn(String email, String password) async {
    signInCalls++;
    if (failSignIn) throw const AuthException('Incorrect email or password.');
  }

  @override
  Future<void> register(String email, String password) async {
    registerCalls++;
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    lastResetEmail = email;
  }

  @override
  Future<void> signOut() async {}
}

void main() {
  late FakeAuthService auth;

  setUp(() => auth = FakeAuthService());

  // Helper: shows the sign-in screen using the fake service.
  Future<void> showScreen(WidgetTester tester) async {
    // Make the fake phone screen tall so nothing is hidden off-screen.
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(home: SignInScreen(authService: auth)),
    );
  }

  // Shortcuts to find the two text boxes by their label.
  final emailField = find.widgetWithText(TextField, 'Email');
  final passwordField = find.widgetWithText(TextField, 'Password');

  //Test 1
  testWidgets('starts on the Sign in screen', (tester) async {
    await showScreen(tester);

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Sign in'), findsOneWidget);
    expect(find.text('Forgot password?'), findsOneWidget);
  });


//Test 2
  group('eye icon', () {
    testWidgets('password is hidden at first', (tester) async {
      await showScreen(tester);

      expect(tester.widget<TextField>(passwordField).obscureText, isTrue);
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    });
//Test 3
    testWidgets('tapping it shows the password, tapping again hides it',
        (tester) async {
      await showScreen(tester);

      // 1st tap: show
      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pump();
      expect(tester.widget<TextField>(passwordField).obscureText, isFalse);
      expect(find.byIcon(Icons.visibility), findsOneWidget);

      // 2nd tap: hide again
      await tester.tap(find.byIcon(Icons.visibility));
      await tester.pump();
      expect(tester.widget<TextField>(passwordField).obscureText, isTrue);
    });
  });


//Test 4
  group('sign in mode', () {
    testWidgets('empty form shows "required" errors and does not call Firebase',
        (tester) async {
      await showScreen(tester);

      await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
      await tester.pump();

      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
      expect(auth.signInCalls, 0);
    });

//Test 5
    testWidgets('a weak password is still allowed when signing in',
        (tester) async {
      await showScreen(tester);

      await tester.enterText(emailField, 'old@user.com');
      await tester.enterText(passwordField, 'abc'); // weak, but it is login
      await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
      await tester.pumpAndSettle();

      expect(auth.signInCalls, 1);
    });


//Test 6
    testWidgets('shows the error message when sign in fails', (tester) async {
      auth.failSignIn = true;
      await showScreen(tester);

      await tester.enterText(emailField, 'user@example.com');
      await tester.enterText(passwordField, 'Whatever1!');
      await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
      await tester.pumpAndSettle();

      expect(find.text('Incorrect email or password.'), findsOneWidget);
    });
  });

//Test 7
  group('create account mode', () {
    // Helper: tap the link that switches to "Create account".
    Future<void> switchToRegister(WidgetTester tester) async {
      await tester.tap(find.text('Create a new account'));
      await tester.pump();
    }
//Test 8
    testWidgets('switching hides "Forgot password?" and shows the rules hint',
        (tester) async {
      await showScreen(tester);
      await switchToRegister(tester);

      expect(find.text('Forgot password?'), findsNothing);
      expect(find.textContaining('8+ characters'), findsOneWidget);
      expect(find.text('I already have an account'), findsOneWidget);
    });

//Test 9
    testWidgets('a weak password is rejected', (tester) async {
      await showScreen(tester);
      await switchToRegister(tester);

      await tester.enterText(emailField, 'new@user.com');
      await tester.enterText(passwordField, 'abc');
      await tester.tap(find.widgetWithText(FilledButton, 'Create account'));
      await tester.pump();

      expect(find.text('Use at least 8 characters'), findsOneWidget);
      expect(auth.registerCalls, 0);
    });

//Test 10
    testWidgets('a strong password creates the account', (tester) async {
      await showScreen(tester);
      await switchToRegister(tester);

      await tester.enterText(emailField, 'new@user.com');
      await tester.enterText(passwordField, 'Hello@2026');
      await tester.tap(find.widgetWithText(FilledButton, 'Create account'));
      await tester.pumpAndSettle();

      expect(auth.registerCalls, 1);
    });
  });

//Test 11
  group('forgot password', () {
    testWidgets('sends the reset link and shows a confirmation message',
        (tester) async {
      await showScreen(tester);

      await tester.tap(find.text('Forgot password?'));
      await tester.pumpAndSettle(); // wait for the pop-up to open

      // The screen behind the pop-up also has text boxes, so we say:
      // "the text box INSIDE the AlertDialog".
      final dialogField = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextFormField),
      );
      await tester.enterText(dialogField, 'user@example.com');
      await tester.tap(find.text('Send link'));
      await tester.pumpAndSettle(); // pop-up closes, SnackBar appears

      expect(auth.lastResetEmail, 'user@example.com');
      expect(find.textContaining('reset link has been sent'), findsOneWidget);
    });

//Test 12
    testWidgets('Cancel does not send anything', (tester) async {
      await showScreen(tester);

      await tester.tap(find.text('Forgot password?'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(auth.lastResetEmail, isNull);
    });
  });
}
