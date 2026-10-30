// Widget tests for lib/widgets/forgot_password_dialog.dart
// Same idea as edit_todo_dialog_test.dart: a fake screen with an
// "Open" button that opens the dialog and remembers what it returned.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:todo_app/widgets/forgot_password_dialog.dart';

void main() {
  String? result;
  var dialogClosed = false;

  setUp(() {
    result = null;
    dialogClosed = false;
  });

  Future<void> openDialog(WidgetTester tester, {String email = ''}) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await showForgotPasswordDialog(context, email);
                dialogClosed = true;
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
  }

  testWidgets('shows the title, the email box and both buttons',
      (tester) async {
    await openDialog(tester);

    expect(find.text('Reset password'), findsOneWidget);
    expect(find.byType(TextFormField), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Send link'), findsOneWidget);
  });

  testWidgets('is pre-filled with the email typed on the sign-in screen',
      (tester) async {
    await openDialog(tester, email: 'user@example.com');

    expect(find.text('user@example.com'), findsOneWidget);
  });

  testWidgets('shows an error and stays open when the email is invalid',
      (tester) async {
    await openDialog(tester);

    await tester.enterText(find.byType(TextFormField), 'not-an-email');
    await tester.tap(find.text('Send link'));
    await tester.pump();

    expect(find.text('Enter a valid email'), findsOneWidget);
    expect(find.text('Reset password'), findsOneWidget); // still open
    expect(dialogClosed, isFalse);
  });

  testWidgets('returns the trimmed email when it is valid', (tester) async {
    await openDialog(tester);

    await tester.enterText(find.byType(TextFormField), ' user@example.com ');
    await tester.tap(find.text('Send link'));
    await tester.pumpAndSettle();

    expect(dialogClosed, isTrue);
    expect(result, 'user@example.com');
  });

  testWidgets('Cancel returns null', (tester) async {
    await openDialog(tester);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(dialogClosed, isTrue);
    expect(result, isNull);
  });
}
