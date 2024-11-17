import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maat/main.dart';

void main() {
  testWidgets('App displays UI correctly', (WidgetTester tester) async {
    // Launch the app.
    await tester.pumpWidget(const TasksApp());

    // Verify the app bar title.
    expect(find.text('Google Tasks Clone'), findsOneWidget);

    // Verify the add button exists.
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets('Add a task without deadline', (WidgetTester tester) async {
    await tester.pumpWidget(const TasksApp());

    // Tap the "+" button to add a task.
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Enter a task name.
    await tester.enterText(find.byType(TextField), 'New Task');
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    // Verify the new task is displayed.
    expect(find.text('New Task'), findsOneWidget);
  });

  testWidgets('Mark task as completed', (WidgetTester tester) async {
    await tester.pumpWidget(const TasksApp());

    // Add a task.
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Complete Me');
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    // Verify the task is in the pending list.
    expect(find.text('Complete Me'), findsOneWidget);

    // Tap the radio button to complete the task.
    await tester.tap(find.byType(Radio<int>));
    await tester.pumpAndSettle();

    // Verify the task is removed from the pending list.
    expect(find.text('Complete Me'), findsNothing);
  });
}
