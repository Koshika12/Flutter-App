import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  List<QueryDocumentSnapshot> _filteredStudents(List<QueryDocumentSnapshot> all) {
    var list = all;

    if (_semesterFilter != null) {
      list = list.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return (data['semester'] as num?)?.toInt() == _semesterFilter;
      }).toList();
    }

    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      list = list.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final name = (data['name'] ?? '').toString().toLowerCase();
        final email = (data['email'] ?? '').toString().toLowerCase();
        return name.contains(q) || email.contains(q);
      }).toList();
    }

    list = [...list]
      ..sort((a, b) {
        final dataA = a.data() as Map<String, dynamic>;
        final dataB = b.data() as Map<String, dynamic>;
        final semA = (dataA['semester'] as num?)?.toInt() ?? 0;
        final semB = (dataB['semester'] as num?)?.toInt() ?? 0;
        final semCompare = semA.compareTo(semB);
        if (semCompare != 0) return semCompare;
        final joinedA = (dataA['joinedDate'] as Timestamp?)?.toDate() ?? DateTime.now();
        final joinedB = (dataB['joinedDate'] as Timestamp?)?.toDate() ?? DateTime.now();
        return joinedA.compareTo(joinedB);
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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('students').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final allDocs = snapshot.data!.docs;
          final students = _filteredStudents(allDocs);

          final semesters = allDocs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return (data['semester'] as num?)?.toInt() ?? 0;
          }).toSet().toList()
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
                            onTap: () => setState(() => _semesterFilter = sem),
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
                            style: TextStyle(color: Colors.black54, fontSize: 15),
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        itemCount: students.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final doc = students[index];
                          final data = doc.data() as Map<String, dynamic>;

                          final name = data['name'] ?? '';
                          final email = data['email'] ?? '';
                          final semester = (data['semester'] as num?)?.toInt() ?? 0;
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
                                  backgroundColor:
                                      const Color(0xFF1B1F3B).withOpacity(0.1),
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
                                        "Email: $email",
                                        style: const TextStyle(fontSize: 12, color: Colors.black54),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Semester $semester • Joined: ${_formatDate(joinedDate)}",
                                        style: const TextStyle(fontSize: 12, color: Colors.black54),
                                      ),
                                    ],
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    final accountDetails = '''
Name: $name
Email: $email
Semester: $semester
''';
                                    await Clipboard.setData(ClipboardData(text: accountDetails));
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text("$name's details copied!")),
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
            color: selected ? const Color(0xFF1B1F3B) : Colors.grey.shade300,
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
