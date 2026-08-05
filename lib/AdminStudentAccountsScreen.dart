import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'student_repository.dart';

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
  String _query = "";
  final Set<String> _revealedPasswordIds = {};

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
    return "${date.day} ${months[date.month - 1]} ${date.year}";
  }

  void _copy(String label, String value) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("$label copied")),
    );
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
        builder: (context, allStudents, _) {
          var students = _semesterFilter == null
              ? allStudents
              : allStudents.where((s) => s.semester == _semesterFilter).toList();

          if (_query.trim().isNotEmpty) {
            final q = _query.trim().toLowerCase();
            students = students
                .where((s) =>
                    s.name.toLowerCase().contains(q) ||
                    s.email.toLowerCase().contains(q))
                .toList();
          }

          students.sort((a, b) => b.joinedDate.compareTo(a.joinedDate));

          return Column(
            children: [
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                child: Column(
                  children: [
                    TextField(
                      onChanged: (v) => setState(() => _query = v),
                      decoration: InputDecoration(
                        hintText: "Search by name or email",
                        prefixIcon: const Icon(Icons.search_rounded, size: 20),
                        filled: true,
                        fillColor: const Color(0xFFF5F7FB),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Color(0xFF1B1F3B), width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 36,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _SemesterChip(
                            label: "All",
                            selected: _semesterFilter == null,
                            onTap: () => setState(() => _semesterFilter = null),
                          ),
                          for (var s = 1; s <= 8; s++) ...[
                            const SizedBox(width: 8),
                            _SemesterChip(
                              label: "Sem $s",
                              selected: _semesterFilter == s,
                              onTap: () => setState(() => _semesterFilter = s),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: students.isEmpty
                    ? Center(
                        child: Text(
                          allStudents.isEmpty
                              ? "No student accounts yet.\nAdd one from the home page."
                              : "No students match your search.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: students.length,
                        itemBuilder: (context, index) {
                          final student = students[index];
                          final revealed =
                              _revealedPasswordIds.contains(student.id);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 18,
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
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            student.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14.5,
                                            ),
                                          ),
                                          Text(
                                            "Semester ${student.semester} • Joined ${_formatDate(student.joinedDate)}",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                _CredentialLine(
                                  icon: Icons.email_outlined,
                                  value: student.email,
                                  onCopy: () => _copy("Email", student.email),
                                ),
                                const SizedBox(height: 6),
                                _CredentialLine(
                                  icon: Icons.lock_outline_rounded,
                                  value: revealed
                                      ? student.password
                                      : "•" * student.password.length,
                                  onCopy: () =>
                                      _copy("Password", student.password),
                                  trailing: IconButton(
                                    icon: Icon(
                                      revealed
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      size: 18,
                                    ),
                                    splashRadius: 16,
                                    onPressed: () {
                                      setState(() {
                                        if (revealed) {
                                          _revealedPasswordIds.remove(student.id);
                                        } else {
                                          _revealedPasswordIds.add(student.id);
                                        }
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton.icon(
                                    onPressed: () => _copy(
                                      "Credentials",
                                      "Email: ${student.email}\nPassword: ${student.password}",
                                    ),
                                    icon: const Icon(Icons.ios_share_rounded,
                                        size: 16),
                                    label: const Text("Copy to Share"),
                                    style: TextButton.styleFrom(
                                      foregroundColor: const Color(0xFF1B1F3B),
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

class _SemesterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SemesterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF1B1F3B) : const Color(0xFFF5F7FB),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? const Color(0xFF1B1F3B) : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}

class _CredentialLine extends StatelessWidget {
  final IconData icon;
  final String value;
  final VoidCallback onCopy;
  final Widget? trailing;

  const _CredentialLine({
    required this.icon,
    required this.value,
    required this.onCopy,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FB),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ),
          if (trailing != null) trailing!,
          IconButton(
            icon: const Icon(Icons.copy_rounded, size: 16),
            splashRadius: 16,
            onPressed: onCopy,
          ),
        ],
      ),
    );
  }
}