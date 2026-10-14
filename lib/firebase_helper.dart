import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'firebase_options.dart';
import 'student_model.dart';

/// FirebaseHelper manages Cloud Firestore operations for Part B of Experiment 8.
///
/// Implements:
/// - Step 12: Firebase Initialization
/// - Step 13: 'students' collection reference with fields: name, course
/// - Step 14: Insert data into Firebase
/// - Step 15: Retrieve data from Firebase
class FirebaseHelper {
  static final FirebaseHelper instance = FirebaseHelper._init();
  FirebaseHelper._init();

  bool _initialized = false;
  String? _initError;

  bool get isInitialized => _initialized;
  String? get initError => _initError;

  /// Step 12: Initializes Firebase using DefaultFirebaseOptions.
  Future<bool> initialize() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      _initialized = true;
      _initError = null;
      debugPrint('Firebase initialized successfully.');
      return true;
    } catch (e) {
      _initialized = false;
      _initError = e.toString();
      debugPrint('Firebase initialization note: $e');
      return false;
    }
  }

  /// Step 13: Reference to the 'students' cloud collection.
  CollectionReference<Map<String, dynamic>>? get _studentsCollection {
    if (!_initialized) return null;
    return FirebaseFirestore.instance.collection('students');
  }

  /// Step 14: Inserts student data into Firebase Firestore.
  /// Collection: 'students'
  /// Fields: name, course
  Future<String?> addStudent(String name, String course) async {
    if (!_initialized) {
      throw Exception('Firebase is not initialized. Please verify configuration.');
    }
    try {
      final docRef = await _studentsCollection!.add({
        'name': name,
        'course': course,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      debugPrint('Error inserting student to Firebase: $e');
      rethrow;
    }
  }

  /// Step 15: Retrieves real-time stream of student records from Firebase Firestore.
  Stream<List<Student>> getStudentsStream() {
    if (!_initialized || _studentsCollection == null) {
      return Stream.value([]);
    }
    return _studentsCollection!
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Student.fromFirestore(doc.data(), doc.id);
      }).toList();
    });
  }

  /// Step 15 (Alternate): Retrieves list of student records once from Firebase Firestore.
  Future<List<Student>> getStudentsOnce() async {
    if (!_initialized || _studentsCollection == null) {
      return [];
    }
    try {
      final snapshot = await _studentsCollection!.get();
      return snapshot.docs.map((doc) {
        return Student.fromFirestore(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      debugPrint('Error fetching students from Firebase: $e');
      return [];
    }
  }

  /// Updates an existing student record in Firebase Firestore.
  Future<void> updateStudent(String docId, String name, String course) async {
    if (!_initialized || _studentsCollection == null) {
      throw Exception('Firebase is not initialized.');
    }
    try {
      await _studentsCollection!.doc(docId).update({
        'name': name,
        'course': course,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error updating student in Firebase: $e');
      rethrow;
    }
  }

  /// Deletes a student record from Firebase Firestore.
  Future<void> deleteStudent(String docId) async {
    if (!_initialized || _studentsCollection == null) {
      throw Exception('Firebase is not initialized.');
    }
    try {
      await _studentsCollection!.doc(docId).delete();
    } catch (e) {
      debugPrint('Error deleting student from Firebase: $e');
      rethrow;
    }
  }
}
