import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'LoginScreen.dart';
import 'StudentNoticeScreen.dart';
import 'StudentRoutineScreen.dart';
import 'StudentStudyMaterialsScreen.dart';
import 'StudentAttendanceScreen.dart';
import 'StudentProfileScreen.dart';
import 'CompleteProfileScreen.dart';
import 'notice_repository.dart';
import 'attendance_repository.dart';

class StudentHomePage extends StatefulWidget {
  const StudentHomePage({super.key});

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  int _selectedNavIndex = 0;

  String? _studentName;
  int? _studentSemester;
  String? _studentRollNo;
  String? _profilePhotoPath;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadStudentIdentity();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadStudentIdentity() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _studentName = prefs.getString("studentFullName");
      _studentSemester = prefs.getInt("studentSemester");
      _studentRollNo = prefs.getString("studentRollNo");
      _profilePhotoPath = prefs.getString("studentProfilePhotoPath");
    });
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning,";
    if (hour < 17) return "Good Afternoon,";
    return "Good Evening,";
  }

  void _onSearchSubmitted(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StudentNoticeScreen(initialQuery: trimmed),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isLoggedIn", false);

    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _showProfileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                if (_studentName != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      _studentName!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ListTile(
                  leading: const Icon(Icons.person_outline_rounded,
                      color: Color(0xFF1B1F3B)),
                  title: const Text(
                    "View Profile",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  onTap: () async {
                    Navigator.pop(ctx);
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const StudentProfileScreen()),
                    );
                    _loadStudentIdentity();
                  },
                ),
                ListTile(
                  leading:
                      const Icon(Icons.logout_rounded, color: Colors.redAccent),
                  title: const Text(
                    "Logout",
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _logout(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onNavTap(int index) async {
    if (index == _selectedNavIndex) return;

    switch (index) {
      case 0:
        setState(() => _selectedNavIndex = index);
        break;
      case 1:
        setState(() => _selectedNavIndex = index);
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const StudentRoutineScreen()),
        );
        if (mounted) setState(() => _selectedNavIndex = 0);
        break;
      case 2:
        setState(() => _selectedNavIndex = index);
        await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => const StudentStudyMaterialsScreen()),
        );
        if (mounted) setState(() => _selectedNavIndex = 0);
        break;
      case 3:
        setState(() => _selectedNavIndex = index);
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const StudentAttendanceScreen()),
        );
        if (mounted) {
          setState(() => _selectedNavIndex = 0);
          _loadStudentIdentity();
        }
        break;
      case 4:
        setState(() => _selectedNavIndex = index);
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const StudentProfileScreen()),
        );
        if (mounted) {
          setState(() => _selectedNavIndex = 0);
          _loadStudentIdentity();
        }
        break;
    }
  }

  String _relativeTime(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
    if (diff.inHours < 24) return "${diff.inHours}h ago";
    return "${diff.inDays}d ago";
  }

  @override
  Widget build(BuildContext context) {
    final displayName = _studentName ?? "Student";
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : "S";

    return Scaffold(
      backgroundColor: Color(0xFFF5F7FB),
      body: RefreshIndicator(
        onRefresh: _loadStudentIdentity,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---- Gradient header ----
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                decoration: const BoxDecoration(
                  color: Color(0xFF1B1F3B),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(28),
                    bottomRight: Radius.circular(28),
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _greeting,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.white70,
                                  ),
                                ),
                                Text(
                                  displayName,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                if (_studentSemester != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Text(
                                      "BCA - Semester $_studentSemester",
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _showProfileMenu(context),
                            child: CircleAvatar(
                              radius: 26,
                              backgroundColor: Colors.white,
                              backgroundImage: _profilePhotoPath != null
                                  ? FileImage(File(_profilePhotoPath!))
                                  : null,
                              child: _profilePhotoPath == null
                                  ? Text(
                                      initial,
                                      style: const TextStyle(
                                        color: Color(0xFF1B1F3B),
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      TextField(
                        controller: _searchController,
                        textInputAction: TextInputAction.search,
                        onSubmitted: _onSearchSubmitted,
                        decoration: InputDecoration(
                          hintText: "Search notices...",
                          prefixIcon: const Icon(Icons.search_rounded,
                              color: Colors.black45),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 0, horizontal: 4),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ---- Attendance ring card ----
                    _AttendanceRingCard(
                      semester: _studentSemester,
                      rollNo: _studentRollNo,
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const StudentAttendanceScreen()),
                        );
                        _loadStudentIdentity();
                      },
                    ),
                    const SizedBox(height: 20),

                    // ---- Quick action grid (no Exams) ----
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 1.3,
                      children: [
                        _QuickActionTile(
                          icon: Icons.campaign_rounded,
                          label: "Notices",
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const StudentNoticeScreen()),
                          ),
                        ),
                        _QuickActionTile(
                          icon: Icons.calendar_month_rounded,
                          label: "Routine",
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const StudentRoutineScreen()),
                          ),
                        ),
                        _QuickActionTile(
                          icon: Icons.menu_book_rounded,
                          label: "Study Materials",
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    const StudentStudyMaterialsScreen()),
                          ),
                        ),
                        _QuickActionTile(
                          icon: Icons.fact_check_rounded,
                          label: "Attendance",
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const StudentAttendanceScreen()),
                            );
                            _loadStudentIdentity();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // ---- Latest notices ----
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Latest Notices",
                          style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const StudentNoticeScreen()),
                          ),
                          child: const Text("View All"),
                        ),
                      ],
                    ),
                    ValueListenableBuilder<List<Notice>>(
                      valueListenable:
                          NoticeRepository.instance.noticesNotifier,
                      builder: (context, notices, _) {
                        if (notices.isEmpty) {
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Text(
                              "No notices posted yet",
                              style: TextStyle(color: Colors.grey.shade500),
                            ),
                          );
                        }

                        final latest = notices.take(3).toList();

                        return Column(
                          children: latest
                              .map(
                                (notice) => Container(
                                  margin: const EdgeInsets.only(top: 10),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border:
                                        Border.all(color: Colors.grey.shade200),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Color(0xFF1B1F3B)
                                              .withOpacity(0.08),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: const Icon(
                                          Icons.campaign_rounded,
                                          color: Color(0xFF1B1F3B),
                                          size: 18,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              notice.title,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              _relativeTime(notice.postedAt),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(Icons.chevron_right_rounded,
                                          color: Colors.black38),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedNavIndex,
        onTap: _onNavTap,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Color(0xFF1B1F3B),
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
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(0xFF1B1F3B).withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Color(0xFF1B1F3B), size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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

/// Attendance summary shown as a circular progress ring, matching the
/// reference design. Pulls real data once the student has set a roll
/// number (via login or the Attendance screen); otherwise prompts them
/// to set one up.
class _AttendanceRingCard extends StatelessWidget {
  final int? semester;
  final String? rollNo;
  final VoidCallback onTap;

  const _AttendanceRingCard({
    required this.semester,
    required this.rollNo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (semester == null || rollNo == null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              const Icon(Icons.fact_check_outlined, color: Color(0xFF1B1F3B)),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  "Set up your roll number to see your attendance here",
                  style: TextStyle(fontSize: 13),
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.black38),
            ],
          ),
        ),
      );
    }

    return ValueListenableBuilder<Map<String, Map<String, AttendanceStatus>>>(
      valueListenable: AttendanceRepository.instance.recordsNotifier,
      builder: (context, _, __) {
        final history =
            AttendanceRepository.instance.historyForStudent(semester!, rollNo!);
        final presentCount =
            history.where((e) => e.value == AttendanceStatus.present).length;
        final absentCount =
            history.where((e) => e.value == AttendanceStatus.absent).length;
        final total = history.length;
        final percentage = total == 0 ? 0.0 : (presentCount / total) * 100;

        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF1B1F3B),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 84,
                  height: 84,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 84,
                        height: 84,
                        child: CircularProgressIndicator(
                          value: total == 0 ? 0 : percentage / 100,
                          strokeWidth: 8,
                          backgroundColor: Colors.white24,
                          valueColor:
                              const AlwaysStoppedAnimation(Colors.green),
                        ),
                      ),
                      Text(
                        total == 0 ? "--" : "${percentage.toStringAsFixed(0)}%",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Your Attendance",
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        total == 0
                            ? "Not marked yet"
                            : "Present: $presentCount   Absent: $absentCount",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Colors.white70),
              ],
            ),
          ),
        );
      },
    );
  }
}
