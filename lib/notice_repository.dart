import 'package:flutter/foundation.dart';

class Notice {
  final String title;
  final String message;
  final String? attachmentName;
  final DateTime postedAt;

  Notice({
    required this.title,
    required this.message,
    this.attachmentName,
    required this.postedAt,
  });
}

/// Simple in-memory store shared across admin + student screens, so a
/// notice posted by Admin immediately shows up on the Student side
/// while the app is running — same pattern as StudentRepository.
///
/// TODO: Replace this in-memory store with real reads/writes to your
/// backend (Firestore, REST API, etc). Keep the same shape — a
/// ValueNotifier<List<Notice>> — so the UI code that listens to it
/// doesn't need to change.
class NoticeRepository {
  NoticeRepository._();
  static final NoticeRepository instance = NoticeRepository._();

  final ValueNotifier<List<Notice>> noticesNotifier =
      ValueNotifier<List<Notice>>([]);

  List<Notice> get notices => noticesNotifier.value;

  void addNotice(Notice notice) {
    // Newest notice first.
    noticesNotifier.value = [notice, ...noticesNotifier.value];
  }

  void removeNotice(Notice notice) {
    noticesNotifier.value =
        noticesNotifier.value.where((n) => n != notice).toList();
  }
}
