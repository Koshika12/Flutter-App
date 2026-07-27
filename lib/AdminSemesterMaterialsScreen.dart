import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminSemesterMaterialsScreen extends StatefulWidget {
  final int semester;

  const AdminSemesterMaterialsScreen({super.key, required this.semester});

  @override
  State<AdminSemesterMaterialsScreen> createState() =>
      _AdminSemesterMaterialsScreenState();
}

class _AdminSemesterMaterialsScreenState
    extends State<AdminSemesterMaterialsScreen> {
  final List<Map<String, dynamic>> _categories = [
    {"title": "Syllabus", "icon": Icons.description_rounded},
    {"title": "Lecture Notes", "icon": Icons.edit_note_rounded},
    {"title": "Slides / PPT", "icon": Icons.slideshow_rounded},
    {"title": "Assignments", "icon": Icons.assignment_rounded},
    {"title": "Previous Question Papers", "icon": Icons.quiz_rounded},
  ];

  final CollectionReference materialsRef =
      FirebaseFirestore.instance.collection('materials');

  void _showAddMaterialSheet(String category) {
    final titleCtrl = TextEditingController();
    final linkCtrl = TextEditingController();

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
                "Add to $category",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 18),
              const Text("Title", style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextField(
                controller: titleCtrl,
                decoration: InputDecoration(
                  hintText: "e.g. Unit 1 Notes",
                  filled: true,
                  fillColor: const Color(0xFFF5F7FB),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 14),
              const Text("Google Drive Link", style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextField(
                controller: linkCtrl,
                decoration: InputDecoration(
                  hintText: "https://drive.google.com/...",
                  filled: true,
                  fillColor: const Color(0xFFF5F7FB),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B1F3B),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () async {
                    final title = titleCtrl.text.trim();
                    final link = linkCtrl.text.trim();

                    if (title.isEmpty || link.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please fill both fields")),
                      );
                      return;
                    }
                    if (!link.startsWith("http")) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please paste a valid link")),
                      );
                      return;
                    }

                    try {
                      await materialsRef.add({
                        'title': title,
                        'category': category,
                        'semester': widget.semester,
                        'driveLink': link,
                        'uploadedAt': FieldValue.serverTimestamp(),
                      });
                      if (ctx.mounted) Navigator.pop(ctx);
                    } catch (e) {
                      if (ctx.mounted) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          const SnackBar(content: Text("Failed to save. Try again.")),
                        );
                      }
                    }
                  },
                  child: const Text(
                    "Add Material",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _deleteMaterial(String docId) async {
    try {
      await materialsRef.doc(docId).delete();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to delete. Try again.")),
        );
      }
    }
  }

  Future<void> _openLink(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not open link")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: Text("Semester ${widget.semester} Materials"),
        backgroundColor: const Color(0xFF1B1F3B),
        foregroundColor: Colors.white,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final category = _categories[index];

          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B1F3B).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(category["icon"], color: const Color(0xFF1B1F3B), size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        category["title"],
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _showAddMaterialSheet(category["title"]),
                      icon: const Icon(Icons.add_link_rounded, size: 18),
                      label: const Text("Add"),
                      style: TextButton.styleFrom(foregroundColor: const Color(0xFF1B1F3B)),
                    ),
                  ],
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: materialsRef
                      .where('semester', isEqualTo: widget.semester)
                      .where('category', isEqualTo: category["title"])
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: LinearProgressIndicator(minHeight: 2),
                      );
                    }

                    final docs = snapshot.data!.docs;

                    if (docs.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8, left: 4),
                        child: Text(
                          "No materials added yet",
                          style: TextStyle(fontSize: 12.5, color: Colors.grey.shade500),
                        ),
                      );
                    }

                    return Column(
                      children: [
                        const SizedBox(height: 10),
                        const Divider(height: 1),
                        ...docs.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                const Icon(Icons.link_rounded, size: 18, color: Colors.black45),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => _openLink(data['driveLink'] ?? ''),
                                    child: Text(
                                      data['title'] ?? '',
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF1B1F3B),
                                        fontWeight: FontWeight.w600,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close_rounded, size: 18, color: Colors.redAccent),
                                  onPressed: () => _deleteMaterial(doc.id),
                                  splashRadius: 18,
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
