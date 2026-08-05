import 'package:flutter/material.dart';

class StudentRoutineScreen extends StatelessWidget {
  const StudentRoutineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final routineItems = [
      _RoutineItem(day: 'Monday', time: '9:00 AM', subject: 'Programming'),
      _RoutineItem(day: 'Tuesday', time: '10:30 AM', subject: 'Database'),
      _RoutineItem(day: 'Wednesday', time: '11:00 AM', subject: 'Web Design'),
      _RoutineItem(day: 'Thursday', time: '1:00 PM', subject: 'Math'),
      _RoutineItem(day: 'Friday', time: '2:30 PM', subject: 'Project Lab'),
    ];

    return Scaffold(
      backgroundColor: Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text('Routine'),
        backgroundColor: Color(0xFF1B1F3B),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Class Routine',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B1F3B),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Your weekly class timetable',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...routineItems.map((item) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Color(0xFF1B1F3B).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.schedule_rounded,
                        color: Color(0xFF1B1F3B),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.day,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${item.time} • ${item.subject}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _RoutineItem {
  final String day;
  final String time;
  final String subject;

  const _RoutineItem({
    required this.day,
    required this.time,
    required this.subject,
  });
}
