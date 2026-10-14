# EXPERIMENT 8 – DATA PERSISTENCE USING SQLITE AND FIREBASE

## Aim
To implement data persistence in Flutter using:
1. **Local Storage:** SQLite Database (`sqflite`)
2. **Cloud Storage:** Firebase Firestore Database (`cloud_firestore`)

---

## Architecture

```
Flutter Application
 |
 +---- SQLite → Local Storage (students.db)
 |
 +---- Firebase → Cloud Storage (Firestore: collection "students")
```

---

## Project Structure

```
sqlite_app/
├── lib/
│   ├── database_helper.dart   # SQLite Database Helper implementing CRUD operations
│   ├── student_model.dart     # Student data model (id, name, course)
│   ├── firebase_helper.dart    # Cloud Firestore operations (insert, stream retrieve, update, delete)
│   ├── firebase_options.dart   # Firebase configuration options for all platforms
│   └── main.dart              # Interactive UI with Part A (SQLite) & Part B (Firebase) tabs
├── test/
│   ├── database_test.dart     # Automated tests for CREATE, READ, UPDATE, DELETE & Persistence
│   └── widget_test.dart       # UI & Widget tests for TabBar, Form Fields, and Buttons
└── pubspec.yaml               # Dependencies (sqflite, path, sqflite_common_ffi, firebase_core, cloud_firestore)
```

---

## Part A: SQLite (Local Database)

### Step 1: Project Creation
```bash
flutter create sqlite_app
cd sqlite_app
```

### Step 2: Add Packages (`pubspec.yaml`)
```yaml
dependencies:
  flutter:
    sdk: flutter
  sqflite: ^2.4.4+2
  path: ^1.9.1
  sqflite_common_ffi: ^2.4.4
  firebase_core: ^4.15.0
  cloud_firestore: ^6.10.0
```

### Step 3: Database Helper (`lib/database_helper.dart`)
Singleton `DatabaseHelper` manages database connection, initialization, and table lifecycle.

### Step 4: Database Schema (`students`)
```sql
CREATE TABLE students (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  course TEXT NOT NULL
);
```

### Step 5: CRUD Operations Implemented
- **CREATE**: `insertStudent(Map<String, dynamic> row)`
- **READ**: `getAllStudents()`, `getStudentById(int id)`
- **UPDATE**: `updateStudent(Map<String, dynamic> row)`
- **DELETE**: `deleteStudent(int id)`

### Step 6: Insert Student
Takes user input from `TextField` (Name and Course) and calls `_dbHelper.insertStudent()`.

### Step 7: Display Students
Fetches all rows from SQLite and displays them dynamically using `ListView.builder()` with edit and delete controls.

### Step 8: Persistence Verification
Automated test in `test/database_test.dart` verifies that when the database is closed and reopened, previously stored records remain completely intact.

---

## Part B: Firebase (Cloud Firestore)

### Step 9 & 10: Firebase Project Setup & Connection
1. Go to [Firebase Console](https://console.firebase.google.com/) and create a project.
2. Enable **Cloud Firestore** in test mode.
3. Configure platform credentials in `lib/firebase_options.dart` (or run `flutterfire configure`).

### Step 11: Firebase Packages
Installed `firebase_core` and `cloud_firestore`.

### Step 12: Initialize Firebase
Initialized inside `main()` prior to `runApp()`:
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseHelper.instance.initialize();
  runApp(const DataPersistenceApp());
}
```

### Step 13: Cloud Collection (`students`)
Document structure:
- `name` (String)
- `course` (String)
- `createdAt` (Timestamp)

### Step 14: Insert Data to Cloud
User input is submitted to `FirebaseHelper.instance.addStudent(name, course)`.

### Step 15: Retrieve and Display Data
Real-time synchronization using `StreamBuilder<List<Student>>` and `ListView.builder()`.

---

## How to Run

### Run Application:
```bash
cd sqlite_app
flutter run
```

### Run Automated Tests:
```bash
flutter test
```
All 7 unit and widget tests will run and pass:
- `CREATE: insertStudent inserts record and returns valid ID`
- `READ: getAllStudents returns list containing inserted records`
- `UPDATE: updateStudent modifies existing record correctly`
- `DELETE: deleteStudent removes record by ID`
- `Student Model: toMap and fromMap conversion`
- `PERSISTENCE (Step 8): Data persists after closing and reopening database`
- `Renders Experiment 8 UI elements and tabs`
