import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maat/main.dart';

void main() {
  testWidgets('App loads and displays the correct UI', (WidgetTester tester) async {
    await tester.pumpWidget(const TasksApp());
    expect(find.text('Maat'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.text('Add Task'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'New Task');
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();
    expect(find.text('New Task'), findsOneWidget);
  });
}