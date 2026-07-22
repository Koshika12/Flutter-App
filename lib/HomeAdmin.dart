import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'AdminRoutineScreen.dart';
import 'AdminAttendanceScreen.dart';
import 'RoleSelectionScreen.dart';

import 'AdminStudyMaterialsScreen.dart';
import 'AdminNoticeScreen.dart';
import 'AdminAddStudentScreen.dart';
import 'AdminStudentAccountsScreen.dart';
import 'AdminSemesterStudentsScreen.dart';
import 'student_repository.dart';

class HomeAdmin extends StatefulWidget {
  const HomeAdmin({super.key});

  @override
  State<HomeAdmin> createState() => _HomeAdminState();
}

class _HomeAdminState extends State<HomeAdmin> {
  int _selectedNavIndex = 0; // Home tab active by default

  // TODO: Replace this with a real call to your backend
  // (e.g. Firestore query counting students where semester == X,
  // or a REST endpoint like GET /admin/semesters/summary). This
  // represents students that already existed before this app's
  // "Add Student" flow — newly added students are merged in live
  // from StudentRepository at render time (see _mergedSemesterCounts).
  Map<int, int> _baseSemesterCounts() {
    return {
      1: 42,
      2: 38,
      3: 45,
      4: 40,
      5: 37,
      6: 33,
      7: 29,
      8: 25,
    };
  }

  Map<int, int> _mergedSemesterCounts() {
    final merged = {..._baseSemesterCounts()};
    StudentRepository.instance.countsBySemester().forEach((sem, count) {
      merged[sem] = (merged[sem] ?? 0) + count;
    });
    return merged;
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isLoggedIn", false);
    await prefs.remove("userRole");

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
      (route) => false,
    );
  }

  void _onNavTap(int index) async {
    if (index == _selectedNavIndex) return;

    switch (index) {
      case 0: // Home (this screen) — no navigation needed
        setState(() => _selectedNavIndex = index);
        break;
      case 1: // Routine
        setState(() => _selectedNavIndex = index);
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AdminRoutineScreen()),
        );
        // Returned via back button — reset nav bar back to Home.
        if (mounted) setState(() => _selectedNavIndex = 0);
        break;
      case 2: // Study Materials
        setState(() => _selectedNavIndex = index);
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AdminStudyMaterialsScreen()),
        );
        if (mounted) setState(() => _selectedNavIndex = 0);
        break;
      case 3: // Attendance
        setState(() => _selectedNavIndex = index);
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AdminAttendanceScreen()),
        );
        if (mounted) setState(() => _selectedNavIndex = 0);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        backgroundColor: const Color(0xFF1B1F3B),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => setState(() {}),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Center(
                child: Icon(
                  Icons.admin_panel_settings_rounded,
                  size: 70,
                  color: Color(0xFF1B1F3B),
                ),
              ),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  "Welcome, Admin!",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Center(
                child: Text(
                  "Manage notices, routines and student records here.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Colors.black54),
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.person_add_alt_1_rounded,
                      label: "Add\nStudent",
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdminAddStudentScreen(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.campaign_rounded,
                      label: "Notices",
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdminNoticeScreen(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.badge_outlined,
                      label: "Student\nAccounts",
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdminStudentAccountsScreen(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              const Text(
                "Students by Semester",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 14),
              ValueListenableBuilder<List<Student>>(
                valueListenable: StudentRepository.instance.studentsNotifier,
                builder: (context, _, __) {
                  final counts = _mergedSemesterCounts();
                  final semesters = counts.keys.toList()..sort();
                  final totalStudents =
                      counts.values.fold<int>(0, (sum, c) => sum + c);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: semesters.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          childAspectRatio: 1.5,
                        ),
                        itemBuilder: (context, index) {
                          final sem = semesters[index];
                          final count = counts[sem]!;
                          return _SemesterCard(
                            semester: sem,
                            studentCount: count,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    AdminSemesterStudentsScreen(semester: sem),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B1F3B),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Total Students",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              "$totalStudents",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedNavIndex,
        onTap: _onNavTap,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1B1F3B),
        unselectedItemColor: Colors.grey.shade600,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_rounded),
            label: "Routine",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_rounded),
            label: "Materials",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fact_check_rounded),
            label: "Attendance",
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF1B1F3B), size: 28),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SemesterCard extends StatelessWidget {
  final int semester;
  final int studentCount;
  final VoidCallback onTap;

  const _SemesterCard({
    required this.semester,
    required this.studentCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B1F3B).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.school_rounded,
                    color: Color(0xFF1B1F3B),
                    size: 18,
                  ),
                ),
                const Spacer(),
                Text(
                  "Sem $semester",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "$studentCount",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 6),
                const Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Text(
                    "students",
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}