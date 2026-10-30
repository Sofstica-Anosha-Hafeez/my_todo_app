// Widget tests for lib/widgets/edit_todo_dialog.dart
//
// A dialog is not a normal widget: it opens ON TOP of a screen when a
// function is called. So our fake screen has one "Open" button that calls
// showEditTodoDialog and remembers what the dialog returned.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:todo_app/widgets/edit_todo_dialog.dart';

void main() {
  String? result; // what the dialog returned (the new text, or null)
  var dialogClosed = false; // did the dialog finish?

  setUp(() {
    result = null;
    dialogClosed = false;
  });

  // Helper: builds the fake screen and opens the dialog.
  Future<void> openDialog(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          // Builder gives us a `context` that is INSIDE the MaterialApp.
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await showEditTodoDialog(context, 'Old title');
                dialogClosed = true;
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    // pumpAndSettle = keep redrawing until the open animation is finished.
    await tester.pumpAndSettle();
  }

  testWidgets('opens with the title and the current text filled in',
      (tester) async {
    await openDialog(tester);

    expect(find.text('Edit task'), findsOneWidget);
    expect(find.text('Old title'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
  });

  testWidgets('Save returns the new text without extra spaces',
      (tester) async {
    await openDialog(tester);

    await tester.enterText(find.byType(TextField), '  New title  ');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(dialogClosed, isTrue);
    expect(result, 'New title');
    expect(find.text('Edit task'), findsNothing); // dialog is gone
  });

  testWidgets('Cancel closes the dialog and returns null', (tester) async {
    await openDialog(tester);

    await tester.enterText(find.byType(TextField), 'Something else');
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(dialogClosed, isTrue); // it closed...
    expect(result, isNull); // ...and nothing was returned
  });
}
