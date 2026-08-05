import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'LoginScreen.dart';
import 'app_theme.dart';
import 'attendance_repository.dart';
import 'CompleteProfileScreen.dart';
import 'notice_repository.dart';
import 'student_repository.dart';
import 'StudentAttendanceScreen.dart';
import 'StudentNoticeScreen.dart';
import 'StudentStudyMaterialsScreen.dart';

class StudentProfileScreen extends StatefulWidget {
  const StudentProfileScreen({super.key});

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  bool _loading = true;
  String? _fullName;
  String? _email;
  String? _rollNo;
  int? _semester;
  String? _profilePhotoPath;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _fullName = prefs.getString("studentFullName");
      _email = prefs.getString("studentEmail");
      _rollNo = prefs.getString("studentRollNo");
      _semester = prefs.getInt("studentSemester");
      _profilePhotoPath = prefs.getString("studentProfilePhotoPath");
      _loading = false;
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isLoggedIn", false);

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _logout();
            },
            child: const Text(
              "Logout",
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _changePassword() async {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Change Password"),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: currentCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "Current Password",
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Enter your current password";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: newCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "New Password",
                    ),
                    validator: (value) {
                      if (value == null || value.trim().length < 6) {
                        return "Password must be at least 6 characters";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: confirmCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "Confirm New Password",
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Please confirm your new password";
                      }
                      if (value != newCtrl.text) {
                        return "Passwords do not match";
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            FilledButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;

                final prefs = await SharedPreferences.getInstance();
                final storedPassword = prefs.getString("studentPassword");
                if (storedPassword != null &&
                    currentCtrl.text != storedPassword) {
                  if (!ctx.mounted) return;
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(
                        content: Text("Current password is incorrect")),
                  );
                  return;
                }

                await prefs.setString("studentPassword", newCtrl.text);

                final studentId = prefs.getString("studentId");
                if (studentId != null) {
                  final updatedStudents = <Student>[];
                  for (final student in StudentRepository.instance.students) {
                    if (student.id == studentId) {
                      updatedStudents.add(
                        Student(
                          id: student.id,
                          name: student.name,
                          semester: student.semester,
                          email: student.email,
                          password: newCtrl.text,
                          joinedDate: student.joinedDate,
                          rollNo: student.rollNo,
                        ),
                      );
                    } else {
                      updatedStudents.add(student);
                    }
                  }
                  StudentRepository.instance.studentsNotifier.value =
                      updatedStudents;
                }

                if (!ctx.mounted) return;
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Password updated successfully")),
                );
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _manageNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool("studentNotificationsEnabled") ?? true;
    bool value = enabled;

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Notifications"),
              content: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: value,
                title: const Text("Enable notifications"),
                onChanged: (newValue) {
                  setDialogState(() => value = newValue);
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("Close"),
                ),
                FilledButton(
                  onPressed: () async {
                    await prefs.setBool("studentNotificationsEnabled", value);
                    if (!ctx.mounted) return;
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          value
                              ? "Notifications enabled"
                              : "Notifications disabled",
                        ),
                      ),
                    );
                  },
                  child: const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showHelpSupport() async {
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Help & Support"),
        content: const Text(
          "Contact the college support desk for help with your account, attendance, or study materials.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  Future<void> _setRollNumber() async {
    final ctrl = TextEditingController(text: _rollNo ?? "");
    await showModalBottomSheet(
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
              const Text(
                "Set Roll Number",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                "Used to match your attendance records.",
                style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: ctrl,
                decoration: InputDecoration(
                  hintText: "e.g. BCA-5-01",
                  filled: true,
                  fillColor: AppColors.scaffoldBackground,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    final value = ctrl.text.trim();
                    if (value.isEmpty) return;
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString("studentRollNo", value);
                    if (!ctx.mounted) return;
                    Navigator.pop(ctx);
                    _loadProfile();
                  },
                  child: const Text(
                    "Save",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final name = _fullName ?? "Student";
    final initial = name.isNotEmpty ? name[0].toUpperCase() : "S";

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // ---- Header ----
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
              decoration: const BoxDecoration(
                gradient: AppColors.headerGradient,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    "Profile",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            Transform.translate(
              offset: const Offset(0, -30),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // ---- Info card ----
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 32,
                                backgroundColor: AppColors.primaryTint,
                                backgroundImage: _profilePhotoPath != null
                                    ? FileImage(File(_profilePhotoPath!))
                                    : null,
                                child: _profilePhotoPath == null
                                    ? Text(
                                        initial,
                                        style: const TextStyle(
                                          color: AppColors.primary,
                                          fontSize: 26,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryTint,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Text(
                                        "BCA Student",
                                        style: TextStyle(
                                          color: AppColors.primaryDark,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          const Divider(height: 1),
                          const SizedBox(height: 12),
                          _InfoRow(
                            icon: Icons.badge_outlined,
                            label: "Roll No.",
                            value: _rollNo ?? "Not set",
                            valueColor: _rollNo == null ? Colors.orange : null,
                            onTap: _setRollNumber,
                          ),
                          _InfoRow(
                            icon: Icons.school_outlined,
                            label: "Semester",
                            value:
                                _semester != null ? "Semester $_semester" : "—",
                          ),
                          _InfoRow(
                            icon: Icons.email_outlined,
                            label: "Email",
                            value: _email ?? "—",
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // ---- Stats row (Attendance, Materials, Notices) ----
                    Row(
                      children: [
                        Expanded(
                          child: ValueListenableBuilder<
                              Map<String, Map<String, AttendanceStatus>>>(
                            valueListenable:
                                AttendanceRepository.instance.recordsNotifier,
                            builder: (context, _, __) {
                              String value = "--";
                              if (_semester != null && _rollNo != null) {
                                final history = AttendanceRepository.instance
                                    .historyForStudent(_semester!, _rollNo!);
                                if (history.isNotEmpty) {
                                  final present = history
                                      .where((e) =>
                                          e.value == AttendanceStatus.present)
                                      .length;
                                  value =
                                      "${((present / history.length) * 100).round()}%";
                                }
                              }
                              return _StatCard(
                                icon: Icons.fact_check_rounded,
                                label: "Attendance",
                                value: value,
                                color: AppColors.success,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const StudentAttendanceScreen(),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          // TODO: Replace with a real count once Study
                          // Materials is connected to a shared repository
                          // like Notices and Attendance are.
                          child: _StatCard(
                            icon: Icons.menu_book_rounded,
                            label: "Materials",
                            value: "3",
                            color: AppColors.primary,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const StudentStudyMaterialsScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ValueListenableBuilder<List<Notice>>(
                            valueListenable:
                                NoticeRepository.instance.noticesNotifier,
                            builder: (context, notices, _) => _StatCard(
                              icon: Icons.campaign_rounded,
                              label: "Notices",
                              value: "${notices.length}",
                              color: Colors.orange,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const StudentNoticeScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ---- Settings list ----
                    _SettingsTile(
                      icon: Icons.edit_note_rounded,
                      title: "Edit Profile",
                      subtitle: "Update your roll number and photo",
                      onTap: () async {
                        final updated = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const CompleteProfileScreen(isEditMode: true),
                          ),
                        );
                        if (updated == true && mounted) {
                          _loadProfile();
                        }
                      },
                    ),
                    _SettingsTile(
                      icon: Icons.lock_outline_rounded,
                      title: "Change Password",
                      subtitle: "Update your account password",
                      onTap: _changePassword,
                    ),
                    _SettingsTile(
                      icon: Icons.notifications_none_rounded,
                      title: "Notifications",
                      subtitle: "Manage your notification preferences",
                      onTap: _manageNotifications,
                    ),
                    _SettingsTile(
                      icon: Icons.help_outline_rounded,
                      title: "Help & Support",
                      subtitle: "Get help and support",
                      onTap: _showHelpSupport,
                    ),
                    _SettingsTile(
                      icon: Icons.info_outline_rounded,
                      title: "About App",
                      subtitle: "App information and details",
                      onTap: () {
                        showAboutDialog(
                          context: context,
                          applicationName: "PKMC BCA Student App",
                          applicationVersion: "1.0.0",
                          applicationLegalese: "© 2026 PKMC University",
                        );
                      },
                    ),
                    _SettingsTile(
                      icon: Icons.logout_rounded,
                      title: "Logout",
                      subtitle: "Sign out from your account",
                      iconColor: AppColors.danger,
                      titleColor: AppColors.danger,
                      onTap: _confirmLogout,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "PKMC BCA Student App\nVersion 1.0.0",
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 11, color: Colors.grey.shade500),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final VoidCallback? onTap;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Colors.grey.shade600),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(fontSize: 13.5, color: Colors.grey.shade700),
            ),
            const Spacer(),
            Text(
              value,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: valueColor ?? Colors.black87,
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right_rounded,
                  size: 18, color: Colors.black38),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback? onTap;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
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
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? titleColor;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        leading: Icon(icon, color: iconColor ?? AppColors.primary),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14.5,
            color: titleColor ?? Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        trailing:
            const Icon(Icons.chevron_right_rounded, color: Colors.black38),
      ),
    );
  }
}
