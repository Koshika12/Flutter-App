import 'package:flutter/foundation.dart';

class Student {
  final String id;
  final String name;
  final int semester;
  final String email;
  final String password;
  final DateTime joinedDate;

  /// Optional roll number (e.g. "BCA-5-01"), used for attendance
  /// matching. Not currently set by AdminAddStudentScreen — if null,
  /// the student is prompted to set one themselves on first visit to
  /// the Attendance screen.
  final String? rollNo;

  Student({
    required this.id,
    required this.name,
    required this.semester,
    required this.email,
    required this.password,
    required this.joinedDate,
    this.rollNo,
  });
}

/// Simple in-memory store shared across admin screens, so a newly added
/// student immediately shows up in the home page's semester counts and
/// in the Student Accounts screen — without wiring up a real backend yet.
///
/// TODO: Replace this in-memory store with real reads/writes to your
/// backend (Firestore, REST API, etc). Keep the same shape — a
/// ValueNotifier<List<Student>> — so the UI code that listens to it
/// doesn't need to change; just populate/sync it from your backend
/// instead of holding everything in memory.
class StudentRepository {
  StudentRepository._();
  static final StudentRepository instance = StudentRepository._();

  final ValueNotifier<List<Student>> studentsNotifier =
      ValueNotifier<List<Student>>([]);

  List<Student> get students => studentsNotifier.value;

  void addStudent(Student student) {
    studentsNotifier.value = [...studentsNotifier.value, student];
  }

  void removeStudent(String id) {
    studentsNotifier.value =
        studentsNotifier.value.where((s) => s.id != id).toList();
  }

  List<Student> studentsForSemester(int semester) =>
      students.where((s) => s.semester == semester).toList();

  /// Count of newly-added students per semester. Merge this with
  /// whatever baseline counts your backend already reports.
  Map<int, int> countsBySemester() {
    final counts = <int, int>{};
    for (final s in students) {
      counts[s.semester] = (counts[s.semester] ?? 0) + 1;
    }
    return counts;
  }

  /// Finds a student whose email + password match what was entered at
  /// login. Case-insensitive on email, exact match on password. Returns
  /// null if no match — used by LoginScreen to authenticate for real
  /// instead of accepting any input.
  Student? findByCredentials(String email, String password) {
    final normalizedEmail = email.trim().toLowerCase();
    for (final s in students) {
      if (s.email.trim().toLowerCase() == normalizedEmail &&
          s.password == password) {
        return s;
      }
    }
    return null;
  }
}
