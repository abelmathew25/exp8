import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqlite_app/main.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('Renders Experiment 8 UI elements and tabs', (WidgetTester tester) async {
    await tester.pumpWidget(const DataPersistenceApp());
    await tester.pump(); // Pump first frame
    await tester.pump(const Duration(milliseconds: 200));

    // Verify Title
    expect(find.text('Experiment 8'), findsOneWidget);
    expect(find.text('SQLite & Firebase Data Persistence'), findsOneWidget);

    // Verify Tabs
    expect(find.text('Part A: SQLite (Local)'), findsOneWidget);
    expect(find.text('Part B: Firebase (Cloud)'), findsOneWidget);

    // Verify SQLite Form fields
    expect(find.text('Student Name'), findsOneWidget);
    expect(find.text('Course'), findsOneWidget);
    expect(find.text('Insert Student'), findsOneWidget);

    // Switch to Firebase Tab
    await tester.tap(find.text('Part B: Firebase (Cloud)'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Verify Firebase tab elements
    expect(find.text('Send to Firebase'), findsOneWidget);
  });
}
