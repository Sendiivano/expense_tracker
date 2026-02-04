// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:expense_tracker/main.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('Home screen loads and shows main UI', (WidgetTester tester) async {
    // Build the app and wait for async initialization.
    await tester.pumpWidget(const ExpenseTrackerApp());
    await tester.pump();

    // Verify app bar title and FAB label exist.
    expect(find.text('MoneyTrack'), findsOneWidget);
    expect(find.text('Add Expense'), findsOneWidget);
  });
}
