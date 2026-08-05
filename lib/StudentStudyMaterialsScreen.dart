import 'package:flutter/material.dart';

class StudentStudyMaterialsScreen extends StatelessWidget {
  const StudentStudyMaterialsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final materials = [
      _MaterialItem(
          title: 'Programming Notes',
          subtitle: 'Basics of Dart and Flutter',
          icon: Icons.description_rounded),
      _MaterialItem(
          title: 'Database PDF',
          subtitle: 'SQL and ER Diagram Concepts',
          icon: Icons.picture_as_pdf_rounded),
      _MaterialItem(
          title: 'Web Design Slides',
          subtitle: 'UI/UX essentials',
          icon: Icons.slideshow_rounded),
    ];

    return Scaffold(
      backgroundColor: Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text('Study Materials'),
        backgroundColor: Color(0xFF1B1F3B),
        foregroundColor: Colors.white,
      ),
      body: ListView(
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
              children: const [
                Text(
                  'Study Materials',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B1F3B),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Download and review your learning resources',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...materials.map((item) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Color(0xFF1B1F3B).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(item.icon, color: Color(0xFF1B1F3B)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.subtitle,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _MaterialItem {
  final String title;
  final String subtitle;
  final IconData icon;

  const _MaterialItem({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}
