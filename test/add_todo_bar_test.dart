// Widget tests for lib/widgets/add_todo_bar.dart
//
// A "widget test" builds ONE widget in a fake screen (no real phone needed),
// does things to it (type, tap) and then checks the result.

// flutter_test gives us: testWidgets, find, expect, WidgetTester...
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// IMPORTANT: "todo_app" must match the `name:` at the top of pubspec.yaml.
import 'package:todo_app/widgets/add_todo_bar.dart';

void main() {
  // A small helper so we do not repeat the same setup in every test.
  // It puts AddTodoBar on a fake screen. AddTodoBar needs a MaterialApp
  // and a Scaffold around it (it uses Material widgets like TextField).
  Future<void> showBar(
    WidgetTester tester,
    ValueChanged<String> onAdd,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: AddTodoBar(onAdd: onAdd)),
      ),
    );
  }

  //  test 1:does it show the right things? 
  testWidgets('shows a text field, the hint text and the Add button',
      (tester) async {
    await showBar(tester, (_) {});

    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Enter a new task'), findsOneWidget); // the hint
    expect(find.text('Add'), findsOneWidget); // the button label
  });

  //test 2: the main "happy path" 
  testWidgets('calls onAdd with the trimmed text and clears the field',
      (tester) async {
    final added = <String>[]; // we collect every task that onAdd receives
    await showBar(tester, added.add);

    // Type text with extra spaces on purpose.
    await tester.enterText(find.byType(TextField), '  Buy milk  ');
    // Tap the Add button.
    await tester.tap(find.text('Add'));
    // Redraw the screen after the tap.
    await tester.pump();

    // The spaces must be removed and onAdd called exactly once.
    expect(added, ['Buy milk']);

    // The text box must be empty again.
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.controller!.text, isEmpty);
  });

  // test 3: a wrong input
  testWidgets('does NOT call onAdd when the text is empty or only spaces',
      (tester) async {
    final added = <String>[];
    await showBar(tester, added.add);

    await tester.enterText(find.byType(TextField), '   ');
    await tester.tap(find.text('Add'));
    await tester.pump();

    expect(added, isEmpty);
  });
}
