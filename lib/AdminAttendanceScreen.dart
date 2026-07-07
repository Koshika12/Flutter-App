import 'package:flutter/material.dart';

enum AttendanceStatus { present, absent, unmarked }

class _StudentAttendance {
  final String name;
  final String rollNo;
  AttendanceStatus status;

  _StudentAttendance({
    required this.name,
    required this.rollNo,
    this.status = AttendanceStatus.unmarked,
  });
}

class AdminAttendanceScreen extends StatefulWidget {
  const AdminAttendanceScreen({super.key});

  @override
  State<AdminAttendanceScreen> createState() => _AdminAttendanceScreenState();
}

class _AdminAttendanceScreenState extends State<AdminAttendanceScreen> {
  int selectedSemester = 5;
  DateTime selectedDate = DateTime.now();

  final List<String> semesters = List.generate(8, (i) => "${i + 1}");

  // Mock student list — replace with real data per semester later
  final Map<int, List<_StudentAttendance>> _studentsBySemester = {
    5: [
      _StudentAttendance(name: "Unish Rajak", rollNo: "BCA-5-01"),
      _StudentAttendance(name: "Sita Karki", rollNo: "BCA-5-02"),
      _StudentAttendance(name: "Ankit Shrestha", rollNo: "BCA-5-03"),
      _StudentAttendance(name: "Priya Gurung", rollNo: "BCA-5-04"),
      _StudentAttendance(name: "Rohan Thapa", rollNo: "BCA-5-05"),
    ],
    1: [
      _StudentAttendance(name: "Kiran Poudel", rollNo: "BCA-1-01"),
      _StudentAttendance(name: "Nisha Lama", rollNo: "BCA-1-02"),
    ],
  };

  List<_StudentAttendance> get _currentStudents =>
      _studentsBySemester[selectedSemester] ?? [];

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  void _markAll(AttendanceStatus status) {
    setState(() {
      for (final s in _currentStudents) {
        s.status = status;
      }
    });
  }

  void _saveAttendance() {
    final unmarked = _currentStudents
        .where((s) => s.status == AttendanceStatus.unmarked)
        .length;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          unmarked > 0
              ? "Saved. $unmarked student(s) still unmarked."
              : "Attendance saved for ${_currentStudents.length} students.",
        ),
      ),
    );
    // TODO: persist to backend once wired up
  }

  String get _formattedDate {
    const months = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    return "${selectedDate.day.toString().padLeft(2, '0')} "
        "${months[selectedDate.month - 1]} ${selectedDate.year}";
  }

  @override
  Widget build(BuildContext context) {
    final students = _currentStudents;
    final presentCount =
        students.where((s) => s.status == AttendanceStatus.present).length;
    final absentCount =
        students.where((s) => s.status == AttendanceStatus.absent).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text("Mark Attendance"),
        backgroundColor: const Color(0xFF2142B2),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _DropdownField(
                        label: "Semester",
                        value: selectedSemester.toString(),
                        items: semesters,
                        onChanged: (v) {
                          setState(() => selectedSemester = int.parse(v!));
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Date",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: _pickDate,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F7FB),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(_formattedDate,
                                      style: const TextStyle(fontSize: 14)),
                                  const Icon(Icons.calendar_today_rounded,
                                      size: 16, color: Color(0xFF2142B2)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _SummaryChip(
                        label: "Present",
                        count: presentCount,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _SummaryChip(
                        label: "Absent",
                        count: absentCount,
                        color: Colors.redAccent,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _SummaryChip(
                        label: "Total",
                        count: students.length,
                        color: const Color(0xFF2142B2),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _markAll(AttendanceStatus.present),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.green),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text("Mark all present",
                            style: TextStyle(color: Colors.green)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _markAll(AttendanceStatus.absent),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.redAccent),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text("Mark all absent",
                            style: TextStyle(color: Colors.redAccent)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: students.isEmpty
                ? Center(
                    child: Text(
                      "No students found for Semester $selectedSemester",
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 90),
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      final s = students[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: const Color(0xFF2142B2)
                                  .withOpacity(0.1),
                              child: Text(
                                s.name.isNotEmpty ? s.name[0] : "?",
                                style: const TextStyle(
                                  color: Color(0xFF2142B2),
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
                                    s.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    s.rollNo,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _StatusToggle(
                              status: s.status,
                              onChanged: (status) {
                                setState(() => s.status = status);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: students.isEmpty ? null : _saveAttendance,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2142B2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                "Save Attendance",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _SummaryChip({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            "$count",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: color),
          ),
        ],
      ),
    );
  }
}

class _StatusToggle extends StatelessWidget {
  final AttendanceStatus status;
  final ValueChanged<AttendanceStatus> onChanged;

  const _StatusToggle({required this.status, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ToggleIcon(
          icon: Icons.check_circle_rounded,
          isActive: status == AttendanceStatus.present,
          activeColor: Colors.green,
          onTap: () => onChanged(AttendanceStatus.present),
        ),
        const SizedBox(width: 6),
        _ToggleIcon(
          icon: Icons.cancel_rounded,
          isActive: status == AttendanceStatus.absent,
          activeColor: Colors.redAccent,
          onTap: () => onChanged(AttendanceStatus.absent),
        ),
      ],
    );
  }
}

class _ToggleIcon extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final Color activeColor;
  final VoidCallback onTap;

  const _ToggleIcon({
    required this.icon,
    required this.isActive,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Icon(
        icon,
        size: 30,
        color: isActive ? activeColor : Colors.grey.shade300,
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F7FB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              items: items
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}