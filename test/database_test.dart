import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqlite_app/database_helper.dart';
import 'package:sqlite_app/student_model.dart';

void main() {
  // Setup sqflite ffi for test environment
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  tearDown(() async {
    await DatabaseHelper.instance.clearAllStudents();
  });

  group('DatabaseHelper CRUD Tests (Experiment 8 - Part A)', () {
    test('CREATE: insertStudent inserts record and returns valid ID', () async {
      final helper = DatabaseHelper.instance;

      final id = await helper.insertStudent({
        DatabaseHelper.columnName: 'Alice Johnson',
        DatabaseHelper.columnCourse: 'B.Tech Computer Science',
      });

      expect(id, isPositive);
    });

    test('READ: getAllStudents returns list containing inserted records', () async {
      final helper = DatabaseHelper.instance;

      await helper.insertStudent({
        DatabaseHelper.columnName: 'Bob Smith',
        DatabaseHelper.columnCourse: 'Information Technology',
      });

      await helper.insertStudent({
        DatabaseHelper.columnName: 'Charlie Brown',
        DatabaseHelper.columnCourse: 'Electronics & Communication',
      });

      final students = await helper.getAllStudents();
      expect(students.length, 2);
      expect(students[0]['name'], 'Charlie Brown'); // Ordered by id DESC
      expect(students[1]['name'], 'Bob Smith');
    });

    test('UPDATE: updateStudent modifies existing record correctly', () async {
      final helper = DatabaseHelper.instance;

      final id = await helper.insertStudent({
        DatabaseHelper.columnName: 'David Miller',
        DatabaseHelper.columnCourse: 'Mechanical',
      });

      // Update course to Robotics
      final rowsAffected = await helper.updateStudent({
        DatabaseHelper.columnId: id,
        DatabaseHelper.columnName: 'David Miller',
        DatabaseHelper.columnCourse: 'Robotics Engineering',
      });

      expect(rowsAffected, 1);

      final updated = await helper.getStudentById(id);
      expect(updated, isNotNull);
      expect(updated!['course'], 'Robotics Engineering');
    });

    test('DELETE: deleteStudent removes record by ID', () async {
      final helper = DatabaseHelper.instance;

      final id = await helper.insertStudent({
        DatabaseHelper.columnName: 'Eva Green',
        DatabaseHelper.columnCourse: 'Data Science',
      });

      final rowsDeleted = await helper.deleteStudent(id);
      expect(rowsDeleted, 1);

      final deleted = await helper.getStudentById(id);
      expect(deleted, isNull);
    });

    test('Student Model: toMap and fromMap conversion', () {
      final student = Student(
        id: 10,
        name: 'Frank Ocean',
        course: 'Software Engineering',
      );

      final map = student.toMap();
      expect(map['id'], 10);
      expect(map['name'], 'Frank Ocean');
      expect(map['course'], 'Software Engineering');

      final reconstructed = Student.fromMap(map);
      expect(reconstructed.id, 10);
      expect(reconstructed.name, 'Frank Ocean');
      expect(reconstructed.course, 'Software Engineering');
    });

    test('PERSISTENCE (Step 8): Data persists after closing and reopening database', () async {
      final helper = DatabaseHelper.instance;

      // 1. Insert initial student
      final id = await helper.insertStudent({
        DatabaseHelper.columnName: 'Grace Hopper',
        DatabaseHelper.columnCourse: 'Computer Architecture',
      });

      // 2. Close the database (simulating closing the application)
      await helper.close();

      // 3. Re-access the database (simulating re-launching the application)
      final recordsAfterReopen = await helper.getAllStudents();

      // 4. Verify previously stored data is still available
      expect(recordsAfterReopen.isNotEmpty, true);
      final persisted = recordsAfterReopen.firstWhere((s) => s['id'] == id);
      expect(persisted['name'], 'Grace Hopper');
      expect(persisted['course'], 'Computer Architecture');
    });
  });
}
