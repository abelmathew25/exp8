/// Student model representing a student entity with id, name, and course.
/// Compatible with both SQLite and Firebase Cloud Firestore.
class Student {
  final int? id; // SQLite primary key
  final String? cloudId; // Firestore document ID
  final String name;
  final String course;

  Student({
    this.id,
    this.cloudId,
    required this.name,
    required this.course,
  });

  /// Convert Student to Map for SQLite storage
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'name': name,
      'course': course,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  /// Create Student from SQLite Map
  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'] as int?,
      name: map['name'] as String,
      course: map['course'] as String,
    );
  }

  /// Convert Student to Map for Firebase Firestore storage
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'course': course,
    };
  }

  /// Create Student from Firebase Firestore document data
  factory Student.fromFirestore(Map<String, dynamic> data, String docId) {
    return Student(
      cloudId: docId,
      name: data['name'] as String? ?? '',
      course: data['course'] as String? ?? '',
    );
  }
}
