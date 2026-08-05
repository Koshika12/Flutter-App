import 'package:flutter/foundation.dart';

enum AttendanceStatus { present, absent, unmarked }

/// Shared attendance store. Records are keyed by "semester_yyyy-mm-dd",
/// each mapping roll number -> AttendanceStatus for that day.
///
/// TODO: Replace this in-memory store with real reads/writes to your
/// backend (Firestore, REST API, etc). Keep the same shape so the UI
/// code that listens to it doesn't need to change.
class AttendanceRepository {
  AttendanceRepository._();
  static final AttendanceRepository instance = AttendanceRepository._();

  // key: "semester_yyyy-mm-dd" -> { rollNo: status }
  final ValueNotifier<Map<String, Map<String, AttendanceStatus>>>
      recordsNotifier = ValueNotifier({});

  String _dateKey(DateTime date) =>
      "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

  String _key(int semester, DateTime date) => "${semester}_${_dateKey(date)}";

  /// Save/overwrite the attendance for a given semester + date.
  void saveAttendance(
    int semester,
    DateTime date,
    Map<String, AttendanceStatus> statuses,
  ) {
    final updated = {...recordsNotifier.value};
    updated[_key(semester, date)] = statuses;
    recordsNotifier.value = updated;
  }

  /// Get previously-saved statuses for a semester + date, if any.
  Map<String, AttendanceStatus>? getAttendance(int semester, DateTime date) {
    return recordsNotifier.value[_key(semester, date)];
  }

  /// All dated records for a semester where this roll number has a
  /// marked status, sorted most recent first.
  List<MapEntry<DateTime, AttendanceStatus>> historyForStudent(
    int semester,
    String rollNo,
  ) {
    final result = <MapEntry<DateTime, AttendanceStatus>>[];

    recordsNotifier.value.forEach((key, statuses) {
      final parts = key.split('_');
      if (parts.length != 2) return;
      final sem = int.tryParse(parts[0]);
      if (sem != semester) return;

      final status = statuses[rollNo];
      if (status == null || status == AttendanceStatus.unmarked) return;

      final dateParts = parts[1].split('-');
      if (dateParts.length != 3) return;
      final date = DateTime(
        int.parse(dateParts[0]),
        int.parse(dateParts[1]),
        int.parse(dateParts[2]),
      );

      result.add(MapEntry(date, status));
    });

    result.sort((a, b) => b.key.compareTo(a.key));
    return result;
  }
}
