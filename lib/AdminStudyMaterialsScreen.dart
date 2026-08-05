import 'package:flutter/material.dart';

import 'AdminSemesterMaterialsScreen.dart';

class AdminStudyMaterialsScreen extends StatelessWidget {
  const AdminStudyMaterialsScreen({super.key});

  // TODO: Replace with the real list of active semesters from your backend.
  static const List<int> _semesters = [1, 2, 3, 4, 5, 6, 7, 8];

  // A small palette so each card gets a distinct accent color.
  static const List<List<Color>> _gradients = [
    [Color(0xFF4E54C8), Color(0xFF8F94FB)],
    [Color(0xFF11998E), Color(0xFF38EF7D)],
    [Color(0xFFF7971E), Color(0xFFFFD200)],
    [Color(0xFFEB3349), Color(0xFFF45C43)],
    [Color(0xFF2193B0), Color(0xFF6DD5ED)],
    [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
    [Color(0xFFFF512F), Color(0xFFDD2476)],
    [Color(0xFF00B09B), Color(0xFF96C93D)],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text("Study Materials"),
        backgroundColor: const Color(0xFF1B1F3B),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Select a Semester",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              "Choose a semester to upload or manage its materials",
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                itemCount: _semesters.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.05,
                ),
                itemBuilder: (context, index) {
                  final semester = _semesters[index];
                  final gradient = _gradients[index % _gradients.length];

                  return _SemesterMaterialCard(
                    semester: semester,
                    gradientColors: gradient,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AdminSemesterMaterialsScreen(
                            semester: semester,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SemesterMaterialCard extends StatelessWidget {
  final int semester;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const _SemesterMaterialCard({
    required this.semester,
    required this.gradientColors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: gradientColors.last.withOpacity(0.35),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(18),
        child: Stack(
          children: [
            Positioned(
              right: -10,
              top: -10,
              child: Icon(
                Icons.menu_book_rounded,
                size: 80,
                color: Colors.white.withOpacity(0.15),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.folder_copy_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Semester $semester",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white70,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "View & Upload",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}