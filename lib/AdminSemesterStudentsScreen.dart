import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
    String studentId,
    String studentName,
    int currentSemester,
  ) async {
    int selectedSemester = currentSemester;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text("Move $studentName"),
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
      try {
        await FirebaseFirestore.instance
            .collection('students')
            .doc(studentId)
            .update({'semester': selectedSemester});

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                selectedSemester == currentSemester
                    ? "$studentName is already in Semester $selectedSemester"
                    : "$studentName moved to Semester $selectedSemester",
              ),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to update. Try again.")),
          );
        }
      }
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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('students')
            .where('semester', isEqualTo: semester)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text("Something went wrong loading students."),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
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
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              final name = data['name'] ?? '';
              final email = data['email'] ?? '';
              final sem = (data['semester'] as num?)?.toInt() ?? semester;
              final joinedTimestamp = data['joinedDate'] as Timestamp?;
              final joinedDate = joinedTimestamp?.toDate() ?? DateTime.now();

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
                      backgroundColor: const Color(0xFF1B1F3B).withOpacity(0.1),
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : "?",
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
                            name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            email,
                            style: const TextStyle(fontSize: 12, color: Colors.black54),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Joined: ${_formatDate(joinedDate)}",
                            style: const TextStyle(fontSize: 12, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => _showUpdateSemesterDialog(context, doc.id, name, sem),
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
