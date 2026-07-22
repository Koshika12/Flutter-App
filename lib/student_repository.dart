import 'package:flutter/foundation.dart';

class Student {
  final String id;
  final String name;
  final int semester;
  final String email;
  final String password;
  final DateTime joinedDate;

  Student({
    required this.id,
    required this.name,
    required this.semester,
    required this.email,
    required this.password,
    required this.joinedDate,
  });

  Student copyWith({
    String? id,
    String? name,
    int? semester,
    String? email,
    String? password,
    DateTime? joinedDate,
  }) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      semester: semester ?? this.semester,
      email: email ?? this.email,
      password: password ?? this.password,
      joinedDate: joinedDate ?? this.joinedDate,
    );
  }
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

  /// All students in a given semester, sorted by the year (and date)
  /// they joined — earliest/oldest batch first.
  List<Student> studentsBySemester(int semester) {
    final list = students.where((s) => s.semester == semester).toList();
    list.sort((a, b) => a.joinedDate.compareTo(b.joinedDate));
    return list;
  }

  /// Count of newly-added students per semester. Merge this with
  /// whatever baseline counts your backend already reports.
  Map<int, int> countsBySemester() {
    final counts = <int, int>{};
    for (final s in students) {
      counts[s.semester] = (counts[s.semester] ?? 0) + 1;
    }
    return counts;
  }

  /// Moves a student to a new semester and notifies listeners so every
  /// screen watching studentsNotifier (Home dashboard, accounts list,
  /// semester list, etc.) updates automatically.
  void updateStudentSemester(String studentId, int newSemester) {
    final list = [...studentsNotifier.value];
    final index = list.indexWhere((s) => s.id == studentId);
    if (index == -1) return;

    list[index] = list[index].copyWith(semester: newSemester);
    studentsNotifier.value = list;

    // TODO: persist this change to your real backend/local storage here,
    // e.g. Firestore update, SQLite update, REST API call, etc.
  }
}