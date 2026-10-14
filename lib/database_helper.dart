import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// DatabaseHelper manages SQLite local database operations for Experiment 8.
///
/// Implements CRUD operations for the 'students' table:
/// - CREATE: insertStudent()
/// - READ:   getAllStudents(), getStudentById()
/// - UPDATE: updateStudent()
/// - DELETE: deleteStudent()
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  // Table and column names
  static const String tableStudents = 'students';
  static const String columnId = 'id';
  static const String columnName = 'name';
  static const String columnCourse = 'course';

  /// Returns the singleton database instance, initializing if necessary.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('students.db');
    return _database!;
  }

  /// Initializes the SQLite database. Supports Android, iOS, Windows, macOS, and Linux.
  Future<Database> _initDB(String filePath) async {
    // If running on desktop (Windows/Linux/macOS), initialize sqflite_common_ffi
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  /// Creates the 'students' table with id, name, and course fields.
  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableStudents (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnName TEXT NOT NULL,
        $columnCourse TEXT NOT NULL
      )
    ''');
  }

  // ==========================================
  // CRUD OPERATIONS
  // ==========================================

  /// CREATE: Inserts a new student record into the SQLite database.
  /// Returns the auto-generated student ID.
  Future<int> insertStudent(Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert(tableStudents, row);
  }

  /// READ: Retrieves all student records ordered by ID descending.
  Future<List<Map<String, dynamic>>> getAllStudents() async {
    final db = await database;
    return await db.query(tableStudents, orderBy: '$columnId DESC');
  }

  /// READ: Retrieves a single student record by ID.
  Future<Map<String, dynamic>?> getStudentById(int id) async {
    final db = await database;
    final results = await db.query(
      tableStudents,
      where: '$columnId = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  /// UPDATE: Modifies an existing student record based on the ID.
  /// Returns the number of affected rows.
  Future<int> updateStudent(Map<String, dynamic> row) async {
    final db = await database;
    final int id = row[columnId] as int;
    return await db.update(
      tableStudents,
      row,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  /// DELETE: Deletes a student record by ID.
  /// Returns the number of affected rows.
  Future<int> deleteStudent(int id) async {
    final db = await database;
    return await db.delete(
      tableStudents,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  /// Deletes all student records (useful for clearing the table).
  Future<int> clearAllStudents() async {
    final db = await database;
    return await db.delete(tableStudents);
  }

  /// Closes the database connection.
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
