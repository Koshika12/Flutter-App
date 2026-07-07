import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'AdminRoutineScreen.dart';
import 'AdminAttendanceScreen.dart';
import 'RoleSelectionScreen.dart';

class HomeAdmin extends StatefulWidget {
  const HomeAdmin({super.key});

  @override
  State<HomeAdmin> createState() => _HomeAdminState();
}

class _HomeAdminState extends State<HomeAdmin> {
  int _selectedNavIndex = 0; // Home tab active by default

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

  void _onNavTap(int index) {
    if (index == _selectedNavIndex) return;

    setState(() => _selectedNavIndex = index);

    switch (index) {
      case 0: // Home (this screen) — no navigation needed
        break;
      case 1: // Routine
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminRoutineScreen()),
        );
        break;
      case 2: // Attendance
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminAttendanceScreen()),
        );
        break;
      case 3: // Profile
        // TODO: navigate to admin profile screen once it exists
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
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 10),
            const Icon(
              Icons.admin_panel_settings_rounded,
              size: 70,
              color: Color(0xFF1B1F3B),
            ),
            const SizedBox(height: 20),
            const Text(
              "Welcome, Admin!",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Manage notices, routines and student records here.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.black54),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.calendar_month_rounded,
                    label: "Manage\nRoutine",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AdminRoutineScreen(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.fact_check_rounded,
                    label: "Mark\nAttendance",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AdminAttendanceScreen(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
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