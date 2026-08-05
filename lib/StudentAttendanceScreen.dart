import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'attendance_repository.dart';

class StudentAttendanceScreen extends StatefulWidget {
  const StudentAttendanceScreen({super.key});

  @override
  State<StudentAttendanceScreen> createState() =>
      _StudentAttendanceScreenState();
}

class _StudentAttendanceScreenState extends State<StudentAttendanceScreen> {
  bool _loading = true;
  int? _semester;
  String? _rollNo;
  String? _fullName;

  @override
  void initState() {
    super.initState();
    _loadSavedIdentity();
  }

  Future<void> _loadSavedIdentity() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _semester = prefs.getInt("studentSemester");
      _rollNo = prefs.getString("studentRollNo");
      _fullName = prefs.getString("studentFullName");
      _loading = false;
    });
  }

  Future<void> _saveRollNo(String rollNo) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("studentRollNo", rollNo);
    setState(() => _rollNo = rollNo);
  }

  Future<void> _saveFullIdentity(
      int semester, String rollNo, String fullName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("studentSemester", semester);
    await prefs.setString("studentRollNo", rollNo);
    await prefs.setString("studentFullName", fullName);
    setState(() {
      _semester = semester;
      _rollNo = rollNo;
      _fullName = fullName;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Name + semester already known from a real login — just need the
    // roll number to match attendance records.
    if (_fullName != null && _semester != null && _rollNo == null) {
      return _RollNumberOnlySetupView(onSaved: _saveRollNo);
    }

    // No real login context at all (e.g. testing directly) — fall back
    // to asking for everything.
    if (_semester == null || _rollNo == null || _fullName == null) {
      return _FullIdentitySetupView(onSaved: _saveFullIdentity);
    }

    return _AttendanceView(
      semester: _semester!,
      rollNo: _rollNo!,
      fullName: _fullName!,
    );
  }
}

InputDecoration _fieldDecoration(String hint) {
  return InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF1B1F3B), width: 2),
    ),
  );
}

/// Shown when the student is already logged in (name + semester known)
/// but hasn't set a roll number yet.
class _RollNumberOnlySetupView extends StatefulWidget {
  final void Function(String rollNo) onSaved;

  const _RollNumberOnlySetupView({required this.onSaved});

  @override
  State<_RollNumberOnlySetupView> createState() =>
      _RollNumberOnlySetupViewState();
}

class _RollNumberOnlySetupViewState extends State<_RollNumberOnlySetupView> {
  final _rollNoCtrl = TextEditingController();

  @override
  void dispose() {
    _rollNoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text("Attendance"),
        backgroundColor: Color(0xFF1B1F3B),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "One last step",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              "Enter your roll number so we can match your attendance "
              "records.",
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 18),
            const Text("Roll Number",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 6),
            TextField(
              controller: _rollNoCtrl,
              decoration: _fieldDecoration("e.g. BCA-5-01"),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF1B1F3B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  final rollNo = _rollNoCtrl.text.trim();
                  if (rollNo.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Please enter your roll number")),
                    );
                    return;
                  }
                  widget.onSaved(rollNo);
                },
                child: const Text(
                  "Continue",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Fallback full setup (name + semester + roll number) for when there's
/// no real login context at all.
class _FullIdentitySetupView extends StatefulWidget {
  final void Function(int semester, String rollNo, String fullName) onSaved;

  const _FullIdentitySetupView({required this.onSaved});

  @override
  State<_FullIdentitySetupView> createState() => _FullIdentitySetupViewState();
}

class _FullIdentitySetupViewState extends State<_FullIdentitySetupView> {
  int _semester = 1;
  final _fullNameCtrl = TextEditingController();
  final _rollNoCtrl = TextEditingController();

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _rollNoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text("Attendance"),
        backgroundColor: Color(0xFF1B1F3B),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Set up your attendance",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              "Enter your details so we can show your real attendance "
              "record.",
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),
            const Text("Full Name",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 6),
            TextField(
              controller: _fullNameCtrl,
              decoration: _fieldDecoration("e.g. Unish Rajak"),
            ),
            const SizedBox(height: 18),
            const Text("Semester",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _semester,
                  isExpanded: true,
                  items: List.generate(8, (i) => i + 1)
                      .map((s) => DropdownMenuItem(
                            value: s,
                            child: Text("Semester $s"),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _semester = v!),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text("Roll Number",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 6),
            TextField(
              controller: _rollNoCtrl,
              decoration: _fieldDecoration("e.g. BCA-5-01"),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF1B1F3B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  final fullName = _fullNameCtrl.text.trim();
                  final rollNo = _rollNoCtrl.text.trim();

                  if (fullName.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Please enter your full name")),
                    );
                    return;
                  }
                  if (rollNo.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Please enter your roll number")),
                    );
                    return;
                  }
                  widget.onSaved(_semester, rollNo, fullName);
                },
                child: const Text(
                  "Continue",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttendanceView extends StatelessWidget {
  final int semester;
  final String rollNo;
  final String fullName;

  const _AttendanceView({
    required this.semester,
    required this.rollNo,
    required this.fullName,
  });

  String _formatDate(DateTime date) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    return "${date.day} ${months[date.month - 1]} ${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text("Attendance"),
        backgroundColor: Color(0xFF1B1F3B),
        foregroundColor: Colors.white,
      ),
      body: ValueListenableBuilder<Map<String, Map<String, AttendanceStatus>>>(
        valueListenable: AttendanceRepository.instance.recordsNotifier,
        builder: (context, _, __) {
          final history =
              AttendanceRepository.instance.historyForStudent(semester, rollNo);

          final presentCount =
              history.where((e) => e.value == AttendanceStatus.present).length;
          final totalCount = history.length;
          final percentage =
              totalCount == 0 ? 0 : ((presentCount / totalCount) * 100).round();

          return ListView(
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
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: Color(0xFF1B1F3B).withOpacity(0.08),
                          child: Text(
                            fullName.isNotEmpty
                                ? fullName[0].toUpperCase()
                                : "?",
                            style: const TextStyle(
                              color: Color(0xFF1B1F3B),
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                fullName,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1B1F3B),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "$rollNo  •  Semester $semester",
                                style: TextStyle(
                                    fontSize: 13, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _StatBlock(
                            label: "Present",
                            value: "$presentCount",
                            color: Colors.green,
                          ),
                        ),
                        Expanded(
                          child: _StatBlock(
                            label: "Total Marked",
                            value: "$totalCount",
                            color: Color(0xFF1B1F3B),
                          ),
                        ),
                        Expanded(
                          child: _StatBlock(
                            label: "Percentage",
                            value: "$percentage%",
                            color: percentage >= 75
                                ? Colors.green
                                : Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Attendance History",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              if (history.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      "No attendance marked for you yet.\n"
                      "Once your admin marks attendance for Semester "
                      "$semester with roll no $rollNo, it'll show up here.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  ),
                )
              else
                ...history.map(
                  (entry) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          entry.value == AttendanceStatus.present
                              ? Icons.check_circle_rounded
                              : Icons.cancel_rounded,
                          color: entry.value == AttendanceStatus.present
                              ? Colors.green
                              : Colors.redAccent,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _formatDate(entry.key),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Text(
                          entry.value == AttendanceStatus.present
                              ? "Present"
                              : "Absent",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: entry.value == AttendanceStatus.present
                                ? Colors.green
                                : Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _StatBlock extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatBlock({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
