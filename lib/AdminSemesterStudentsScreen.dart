import 'package:flutter/material.dart';
import 'student_repository.dart';

class AdminSemesterStudentsScreen extends StatelessWidget {
  final int semester;

  const AdminSemesterStudentsScreen({super.key, required this.semester});

  String _formatDate(DateTime date) {
    const months = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec",
    ];
    return "${months[date.month - 1]} ${date.year}";
  }

  Future<void> _showUpdateSemesterDialog(
    BuildContext context,
    Student student,
  ) async {
    int selectedSemester = student.semester;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text("Move ${student.name}"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Select the new semester for this student:"),
                  const SizedBox(height: 16),
                  DropdownButton<int>(
                    value: selectedSemester,
                    isExpanded: true,
                    items: List.generate(8, (i) => i + 1)
                        .map(
                          (sem) => DropdownMenuItem(
                            value: sem,
                            child: Text("Semester $sem"),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() => selectedSemester = value);
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B1F3B),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text("Update"),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed == true && context.mounted) {
      final movedFromSemester = student.semester;
      StudentRepository.instance.updateStudentSemester(
        student.id,
        selectedSemester,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            selectedSemester == movedFromSemester
                ? "${student.name} is already in Semester $selectedSemester"
                : "${student.name} moved to Semester $selectedSemester",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: Text("Semester $semester Students"),
        backgroundColor: const Color(0xFF1B1F3B),
        foregroundColor: Colors.white,
      ),
      body: ValueListenableBuilder<List<Student>>(
        valueListenable: StudentRepository.instance.studentsNotifier,
        builder: (context, _, __) {
          final students =
              StudentRepository.instance.studentsBySemester(semester);

          if (students.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  "No students found in this semester.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54, fontSize: 15),
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: students.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final student = students[index];
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor:
                          const Color(0xFF1B1F3B).withOpacity(0.1),
                      child: Text(
                        student.name.isNotEmpty
                            ? student.name[0].toUpperCase()
                            : "?",
                        style: const TextStyle(
                          color: Color(0xFF1B1F3B),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            student.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            student.email,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Joined: ${_formatDate(student.joinedDate)}",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () =>
                          _showUpdateSemesterDialog(context, student),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B1F3B),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text("Update"),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}