import 'package:flutter/material.dart';
import 'student_repository.dart';
import 'package:flutter/services.dart';

class AdminStudentAccountsScreen extends StatefulWidget {
  final int? initialSemesterFilter;

  const AdminStudentAccountsScreen({super.key, this.initialSemesterFilter});

  @override
  State<AdminStudentAccountsScreen> createState() =>
      _AdminStudentAccountsScreenState();
}

class _AdminStudentAccountsScreenState
    extends State<AdminStudentAccountsScreen> {
  int? _semesterFilter;
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _semesterFilter = widget.initialSemesterFilter;
  }

  String _formatDate(DateTime date) {
    const months = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec",
    ];
    return "${months[date.month - 1]} ${date.year}";
  }

  List<Student> _filteredStudents(List<Student> all) {
    var list = all;

    if (_semesterFilter != null) {
      list = list.where((s) => s.semester == _semesterFilter).toList();
    }

    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      list = list
          .where((s) =>
              s.name.toLowerCase().contains(q) ||
              s.email.toLowerCase().contains(q))
          .toList();
    }

    list = [...list]
      ..sort((a, b) {
        final semCompare = a.semester.compareTo(b.semester);
        if (semCompare != 0) return semCompare;
        return a.joinedDate.compareTo(b.joinedDate);
      });

    return list;
  }

 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text("Student Accounts"),
        backgroundColor: const Color(0xFF1B1F3B),
        foregroundColor: Colors.white,
      ),
      body: ValueListenableBuilder<List<Student>>(
        valueListenable: StudentRepository.instance.studentsNotifier,
        builder: (context, allStudents, __) {
          final students = _filteredStudents(allStudents);
          final semesters = allStudents.map((s) => s.semester).toSet().toList()
            ..sort();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Search by name or email",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
              ),
              if (semesters.isNotEmpty)
                SizedBox(
                  height: 44,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _FilterChip(
                        label: "All",
                        selected: _semesterFilter == null,
                        onTap: () => setState(() => _semesterFilter = null),
                      ),
                      const SizedBox(width: 8),
                      ...semesters.map(
                        (sem) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _FilterChip(
                            label: "Sem $sem",
                            selected: _semesterFilter == sem,
                            onTap: () =>
                                setState(() => _semesterFilter = sem),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 8),
              Expanded(
                child: students.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Text(
                            "No students found.",
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        itemCount: students.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 12),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
  "Email: ${student.email}",
  style: const TextStyle(
    fontSize: 12,
    color: Colors.black54,
  ),
),

const SizedBox(height: 4),

Text(
  "Password: ${student.password}",
  style: const TextStyle(
    fontSize: 12,
    color: Colors.black54,
    fontWeight: FontWeight.w500,
  ),
),

const SizedBox(height: 4),

Text(
  "Semester ${student.semester} • Joined: ${_formatDate(student.joinedDate)}",
  style: const TextStyle(
    fontSize: 12,
    color: Colors.black54,
  ),
),
                                    ],
                                  ),
                                ),
                                ElevatedButton.icon(
  onPressed: () async {
    final accountDetails = '''
Name: ${student.name}
Email: ${student.email}
Password: ${student.password}
Semester: ${student.semester}
''';

    await Clipboard.setData(
      ClipboardData(text: accountDetails),
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "${student.name}'s account copied!",
          ),
        ),
      );
    }
  },
  icon: const Icon(Icons.copy),
  label: const Text("Copy"),
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF1B1F3B),
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
  ),
),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF1B1F3B) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? const Color(0xFF1B1F3B)
                : Colors.grey.shade300,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}