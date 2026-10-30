// Widget tests for lib/widgets/todo_tile.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:todo_app/models/todo.dart';
import 'package:todo_app/widgets/todo_tile.dart';

void main() {
  // Variables that remember what the widget "told" us.
  // (They are reset in setUp, which runs before EVERY test.)
  late List<bool> toggled; // every value sent to onToggle
  late int editCount; // how many times onEdit was called
  late int deleteCount; // how many times onDelete was called

  setUp(() {
    toggled = [];
    editCount = 0;
    deleteCount = 0;
  });

  // Helper: shows one TodoTile on a fake screen.
  Future<void> showTile(WidgetTester tester, {required bool isDone}) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TodoTile(
            todo: Todo(id: '1', title: 'Buy milk', isDone: isDone),
            onToggle: toggled.add,
            onEdit: () => editCount++,
            onDelete: () => deleteCount++,
          ),
        ),
      ),
    );
  }

  testWidgets('shows the title, a checkbox, an edit and a delete button',
      (tester) async {
    await showTile(tester, isDone: false);

    expect(find.text('Buy milk'), findsOneWidget);
    expect(find.byType(Checkbox), findsOneWidget);
    expect(find.byIcon(Icons.edit), findsOneWidget);
    expect(find.byIcon(Icons.delete), findsOneWidget);
  });

  testWidgets('a task that is NOT done: unchecked and no line through',
      (tester) async {
    await showTile(tester, isDone: false);

    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isFalse);

    final title = tester.widget<Text>(find.text('Buy milk'));
    expect(title.style!.decoration, isNull);
  });

  testWidgets('a task that IS done: checked, struck through and grey',
      (tester) async {
    await showTile(tester, isDone: true);

    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);

    final title = tester.widget<Text>(find.text('Buy milk'));
    expect(title.style!.decoration, TextDecoration.lineThrough);
    expect(title.style!.color, Colors.grey);
  });

  testWidgets('tapping the checkbox calls onToggle with the new value',
      (tester) async {
    await showTile(tester, isDone: false);

    await tester.tap(find.byType(Checkbox));
    await tester.pump();

    expect(toggled, [true]); // it was false, so the new value is true
  });

  testWidgets('tapping the row (title) also toggles the task',
      (tester) async {
    await showTile(tester, isDone: true);

    await tester.tap(find.text('Buy milk'));
    await tester.pump();

    expect(toggled, [false]); // it was true, so the new value is false
  });

  testWidgets('tapping the edit icon calls onEdit', (tester) async {
    await showTile(tester, isDone: false);

    await tester.tap(find.byIcon(Icons.edit));
    await tester.pump();

    expect(editCount, 1);
    expect(deleteCount, 0);
    expect(toggled, isEmpty); // the row itself must NOT toggle
  });

  testWidgets('tapping the delete icon calls onDelete', (tester) async {
    await showTile(tester, isDone: false);

    await tester.tap(find.byIcon(Icons.delete));
    await tester.pump();

    expect(deleteCount, 1);
    expect(editCount, 0);
  });
}
