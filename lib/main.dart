import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'database_helper.dart';
import 'firebase_helper.dart';
import 'student_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SQLite for Desktop platforms (Windows, Linux, macOS)
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Step 12: Initialize Firebase before running application
  await FirebaseHelper.instance.initialize();

  runApp(const DataPersistenceApp());
}

class DataPersistenceApp extends StatelessWidget {
  const DataPersistenceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Exp 8: Data Persistence',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E88E5),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 2),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showArchitectureDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.hub_outlined, color: Color(0xFF1E88E5)),
            SizedBox(width: 8),
            Text('Architecture Overview'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'EXPERIMENT 8 – DATA PERSISTENCE USING SQLITE AND FIREBASE',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Flutter Application\n'
                  ' |\n'
                  ' +---- SQLite → Local Storage (students.db)\n'
                  ' |\n'
                  ' +---- Firebase → Cloud Storage (Firestore: students)',
                  style: TextStyle(
                    color: Colors.greenAccent,
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Demonstrated Features:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text('✓ PART A: SQLite CRUD (Create, Read, Update, Delete)'),
              const Text('✓ PART A: ListView.builder() local record display'),
              const Text('✓ PART A: Offline persistent storage in SQLite'),
              const Text('✓ PART B: Firebase initialization & Firestore connection'),
              const Text('✓ PART B: Cloud collection "students" (name, course)'),
              const Text('✓ PART B: Cloud insert & real-time retrieve'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Experiment 8',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              'SQLite & Firebase Data Persistence',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Architecture Diagram',
            icon: const Icon(Icons.info_outline),
            onPressed: _showArchitectureDialog,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF1E88E5),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF1E88E5),
          indicatorWeight: 3,
          tabs: const [
            Tab(
              icon: Icon(Icons.storage),
              text: 'Part A: SQLite (Local)',
            ),
            Tab(
              icon: Icon(Icons.cloud_sync),
              text: 'Part B: Firebase (Cloud)',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          SqliteTab(),
          FirebaseTab(),
        ],
      ),
    );
  }
}

// ============================================================================
// PART A: SQLITE TAB (Steps 1 to 8)
// ============================================================================
class SqliteTab extends StatefulWidget {
  const SqliteTab({super.key});

  @override
  State<SqliteTab> createState() => _SqliteTabState();
}

class _SqliteTabState extends State<SqliteTab> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _courseController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  List<Map<String, dynamic>> _students = [];
  bool _isLoading = true;
  int? _editingId; // null = insert mode, non-null = update mode

  @override
  void initState() {
    super.initState();
    _refreshStudentList();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _courseController.dispose();
    super.dispose();
  }

  /// Step 5 & 7: READ records from SQLite
  Future<void> _refreshStudentList() async {
    setState(() => _isLoading = true);
    final data = await _dbHelper.getAllStudents();
    setState(() {
      _students = data;
      _isLoading = false;
    });
  }

  /// Step 5 & 6: CREATE / UPDATE student record in SQLite
  Future<void> _saveStudent() async {
    final name = _nameController.text.trim();
    final course = _courseController.text.trim();

    if (name.isEmpty || course.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both Name and Course.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_editingId == null) {
      // Step 6: CREATE (Insert into SQLite)
      await _dbHelper.insertStudent({
        DatabaseHelper.columnName: name,
        DatabaseHelper.columnCourse: course,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Student "$name" saved to SQLite local database!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else {
      // Step 5: UPDATE in SQLite
      await _dbHelper.updateStudent({
        DatabaseHelper.columnId: _editingId,
        DatabaseHelper.columnName: name,
        DatabaseHelper.columnCourse: course,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Student #$_editingId updated successfully!'),
            backgroundColor: Colors.blue,
            duration: const Duration(seconds: 2),
          ),
        );
      }
      _editingId = null;
    }

    _nameController.clear();
    _courseController.clear();
    await _refreshStudentList();
  }

  /// Step 5: DELETE student from SQLite
  Future<void> _deleteStudent(int id, String name) async {
    await _dbHelper.deleteStudent(id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Student "$name" (ID: $id) deleted from SQLite.'),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 2),
        ),
      );
    }
    await _refreshStudentList();
  }

  void _startEditing(Map<String, dynamic> student) {
    setState(() {
      _editingId = student[DatabaseHelper.columnId] as int;
      _nameController.text = student[DatabaseHelper.columnName] as String;
      _courseController.text = student[DatabaseHelper.columnCourse] as String;
    });
  }

  void _cancelEditing() {
    setState(() {
      _editingId = null;
      _nameController.clear();
      _courseController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header Banner
        Container(
          width: double.infinity,
          color: Colors.blue.shade50,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              const Icon(Icons.inventory_2_outlined, color: Color(0xFF1E88E5), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _editingId == null
                      ? 'SQLite Local Database: Table "students"'
                      : 'Editing Student ID: #$_editingId',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0D47A1),
                  ),
                ),
              ),
              Chip(
                label: Text(
                  '${_students.length} Records',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
                backgroundColor: Colors.white,
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),

        // Step 6: TextFields to Collect Student Info
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Student Name',
                      hintText: 'e.g. John Doe',
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _courseController,
                    decoration: const InputDecoration(
                      labelText: 'Course',
                      hintText: 'e.g. Computer Science',
                      prefixIcon: Icon(Icons.school),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      if (_editingId != null) ...[
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _cancelEditing,
                            icon: const Icon(Icons.close),
                            label: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _editingId == null
                                ? const Color(0xFF1E88E5)
                                : Colors.green.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: _saveStudent,
                          icon: Icon(
                            _editingId == null ? Icons.add : Icons.check,
                          ),
                          label: Text(
                            _editingId == null
                                ? 'Insert Student'
                                : 'Update Student',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        const Divider(height: 1),

        // Step 7: Display Students using ListView.builder()
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _students.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.folder_open,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No records found in SQLite database.',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Enter details above and tap "Insert Student"',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _students.length,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      itemBuilder: (context, index) {
                        final student = _students[index];
                        final id = student[DatabaseHelper.columnId] as int;
                        final name =
                            student[DatabaseHelper.columnName] as String;
                        final course =
                            student[DatabaseHelper.columnCourse] as String;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFF1E88E5),
                              foregroundColor: Colors.white,
                              child: Text(
                                '#$id',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            title: Text(
                              name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Row(
                              children: [
                                const Icon(
                                  Icons.menu_book,
                                  size: 14,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(course),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.blue),
                                  tooltip: 'Edit (Update)',
                                  onPressed: () => _startEditing(student),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.redAccent),
                                  tooltip: 'Delete',
                                  onPressed: () => _deleteStudent(id, name),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}

// ============================================================================
// PART B: FIREBASE TAB (Steps 9 to 15)
// ============================================================================
class FirebaseTab extends StatefulWidget {
  const FirebaseTab({super.key});

  @override
  State<FirebaseTab> createState() => _FirebaseTabState();
}

class _FirebaseTabState extends State<FirebaseTab> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _courseController = TextEditingController();
  final FirebaseHelper _firebaseHelper = FirebaseHelper.instance;

  String? _editingCloudId;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _courseController.dispose();
    super.dispose();
  }

  /// Step 14: Insert / Update student data in Firebase
  Future<void> _sendStudentToFirebase() async {
    final name = _nameController.text.trim();
    final course = _courseController.text.trim();

    if (name.isEmpty || course.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both Name and Course.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      if (_editingCloudId == null) {
        // Step 14: Insert data to Firebase
        await _firebaseHelper.addStudent(name, course);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Uploaded "$name" to Firebase Cloud Firestore!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Update in Firebase
        await _firebaseHelper.updateStudent(_editingCloudId!, name, course);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Firebase record updated successfully!'),
              backgroundColor: Colors.blue,
            ),
          );
        }
        _editingCloudId = null;
      }

      _nameController.clear();
      _courseController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Firebase Note: $e'),
            backgroundColor: Colors.orange.shade800,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _deleteFirebaseStudent(String cloudId, String name) async {
    try {
      await _firebaseHelper.deleteStudent(cloudId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Deleted "$name" from Firebase.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting: $e')),
        );
      }
    }
  }

  void _startEditing(Student student) {
    setState(() {
      _editingCloudId = student.cloudId;
      _nameController.text = student.name;
      _courseController.text = student.course;
    });
  }

  void _cancelEditing() {
    setState(() {
      _editingCloudId = null;
      _nameController.clear();
      _courseController.clear();
    });
  }

  void _showFirebaseConfigDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.cloud_done, color: Colors.amber),
            SizedBox(width: 8),
            Text('Firebase Setup Guide'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Steps 9-11 from Lab Experiment:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('1. Go to console.firebase.google.com & create a project.'),
              Text('2. Create a Firestore Database in test mode.'),
              Text('3. Collection name: "students" with fields: "name", "course".'),
              Text('4. Put your project keys into "lib/firebase_options.dart".'),
              SizedBox(height: 12),
              Text(
                'The app will automatically sync in real-time once connected!',
                style: TextStyle(fontStyle: FontStyle.italic, color: Colors.black87),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isReady = _firebaseHelper.isInitialized;

    return Column(
      children: [
        // Header Banner with status
        Container(
          width: double.infinity,
          color: Colors.amber.shade50,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Icon(
                isReady ? Icons.cloud_done : Icons.cloud_queue,
                color: isReady ? Colors.green.shade700 : Colors.amber.shade800,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isReady
                      ? 'Cloud Collection: "students" (Ready)'
                      : 'Firebase Cloud (Setup in firebase_options.dart)',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.amber.shade900,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.help_outline, size: 20),
                tooltip: 'Firebase Guide',
                onPressed: _showFirebaseConfigDialog,
              ),
            ],
          ),
        ),

        // Step 14: Input Form
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Student Name',
                      hintText: 'e.g. Alice Smith',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _courseController,
                    decoration: const InputDecoration(
                      labelText: 'Course',
                      hintText: 'e.g. Information Technology',
                      prefixIcon: Icon(Icons.school_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      if (_editingCloudId != null) ...[
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _cancelEditing,
                            icon: const Icon(Icons.close),
                            label: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: _isSubmitting ? null : _sendStudentToFirebase,
                          icon: _isSubmitting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Icon(
                                  _editingCloudId == null
                                      ? Icons.cloud_upload
                                      : Icons.check,
                                ),
                          label: Text(
                            _editingCloudId == null
                                ? 'Send to Firebase'
                                : 'Update Cloud Record',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        const Divider(height: 1),

        // Step 15: Retrieve data from Firebase and display using ListView.builder()
        Expanded(
          child: StreamBuilder<List<Student>>(
            stream: _firebaseHelper.getStudentsStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final students = snapshot.data ?? [];

              if (students.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.cloud_off_outlined,
                          size: 64,
                          color: Colors.amber.shade300,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No cloud records found in "students" collection.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Enter student details above and tap "Send to Firebase".\n'
                          'Live records will automatically appear here.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: _showFirebaseConfigDialog,
                          icon: const Icon(Icons.settings),
                          label: const Text('View Firebase Configuration Guide'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.builder(
                itemCount: students.length,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                itemBuilder: (context, index) {
                  final student = students[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.amber.shade700,
                        foregroundColor: Colors.white,
                        child: const Icon(Icons.cloud, size: 20),
                      ),
                      title: Text(
                        student.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.menu_book,
                                size: 14,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(student.course),
                            ],
                          ),
                          if (student.cloudId != null)
                            Text(
                              'ID: ${student.cloudId}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade500,
                                fontFamily: 'monospace',
                              ),
                            ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            tooltip: 'Edit Cloud Record',
                            onPressed: () => _startEditing(student),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete,
                                color: Colors.redAccent),
                            tooltip: 'Delete Cloud Record',
                            onPressed: () => _deleteFirebaseStudent(
                              student.cloudId!,
                              student.name,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
