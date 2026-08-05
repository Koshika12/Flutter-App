import 'package:flutter/material.dart';
import 'HomeAdmin.dart';

class AdminRoutineScreen extends StatefulWidget {
  const AdminRoutineScreen({super.key});

  @override
  State<AdminRoutineScreen> createState() => _AdminRoutineScreenState();
}

class _ClassEntry {
  String subject;
  String teacher;
  String startTime;
  String endTime;

  _ClassEntry({
    required this.subject,
    required this.teacher,
    required this.startTime,
    required this.endTime,
  });
}

class _AdminRoutineScreenState extends State<AdminRoutineScreen> {
  int selectedSemester = 1;
  String selectedDay = "Monday";

  final List<String> semesters = List.generate(8, (i) => "${i + 1}");
  final List<String> weekdays = const [
    "Monday", "Tuesday", "Wednesday", "Thursday",
    "Friday", "Saturday", "Sunday",
  ];

  // Local mock storage: semester -> weekday -> list of classes
  final Map<int, Map<String, List<_ClassEntry>>> _routineStore = {};

  List<_ClassEntry> get _currentClasses {
    _routineStore.putIfAbsent(selectedSemester, () => {});
    _routineStore[selectedSemester]!.putIfAbsent(selectedDay, () => []);
    return _routineStore[selectedSemester]![selectedDay]!;
  }

  void _addOrEditClass({_ClassEntry? existing, int? index}) {
    final subjectCtrl = TextEditingController(text: existing?.subject ?? "");
    final teacherCtrl = TextEditingController(text: existing?.teacher ?? "");
    final startCtrl = TextEditingController(text: existing?.startTime ?? "");
    final endCtrl = TextEditingController(text: existing?.endTime ?? "");

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 22,
            right: 22,
            top: 22,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 22,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                existing == null ? "Add Class" : "Edit Class",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 18),
              _RoutineTextField(label: "Subject", controller: subjectCtrl),
              const SizedBox(height: 14),
              _RoutineTextField(label: "Teacher", controller: teacherCtrl),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _RoutineTextField(
                      label: "Start time",
                      controller: startCtrl,
                      hint: "06:30",
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _RoutineTextField(
                      label: "End time",
                      controller: endCtrl,
                      hint: "07:20",
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2142B2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    if (subjectCtrl.text.trim().isEmpty ||
                        startCtrl.text.trim().isEmpty ||
                        endCtrl.text.trim().isEmpty) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(content: Text("Please fill all required fields")),
                      );
                      return;
                    }

                    setState(() {
                      if (existing != null && index != null) {
                        _currentClasses[index] = _ClassEntry(
                          subject: subjectCtrl.text.trim(),
                          teacher: teacherCtrl.text.trim(),
                          startTime: startCtrl.text.trim(),
                          endTime: endCtrl.text.trim(),
                        );
                      } else {
                        _currentClasses.add(_ClassEntry(
                          subject: subjectCtrl.text.trim(),
                          teacher: teacherCtrl.text.trim(),
                          startTime: startCtrl.text.trim(),
                          endTime: endCtrl.text.trim(),
                        ));
                      }
                    });

                    Navigator.pop(ctx);
                  },
                  child: Text(
                    existing == null ? "Add Class" : "Save Changes",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _deleteClass(int index) {
    setState(() {
      _currentClasses.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final classes = _currentClasses;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text("Manage Routine"),
        backgroundColor: const Color(0xFF2142B2),
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF2142B2),
        onPressed: () => _addOrEditClass(),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Add Class", style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                      child: _DropdownField(
                        label: "Weekday",
                        value: selectedDay,
                        items: weekdays,
                        onChanged: (v) {
                          setState(() => selectedDay = v!);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: classes.isEmpty
                ? Center(
                    child: Text(
                      "No classes added for\nSemester $selectedSemester, $selectedDay",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                    itemCount: classes.length,
                    itemBuilder: (context, index) {
                      final c = classes[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    c.subject,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    c.teacher,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${c.startTime} - ${c.endTime}",
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF2142B2),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, color: Colors.grey),
                              onPressed: () => _addOrEditClass(existing: c, index: index),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                              onPressed: () => _deleteClass(index),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
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

class _RoutineTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hint;

  const _RoutineTextField({
    required this.label,
    required this.controller,
    this.hint,
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
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFF5F7FB),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2142B2), width: 2),
            ),
          ),
        ),
      ],
    );
  }
}