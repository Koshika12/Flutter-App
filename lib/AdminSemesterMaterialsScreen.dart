import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

/// A single uploaded file entry, shown under its category.
class _UploadedFile {
  final String name;
  final String sizeLabel;
  final DateTime uploadedAt;

  _UploadedFile({
    required this.name,
    required this.sizeLabel,
    required this.uploadedAt,
  });
}

/// One required material category for a semester, e.g. "Notes", "Syllabus".
class _MaterialCategory {
  final String title;
  final IconData icon;
  final List<_UploadedFile> files;

  _MaterialCategory({
    required this.title,
    required this.icon,
    List<_UploadedFile>? files,
  }) : files = files ?? [];
}

class AdminSemesterMaterialsScreen extends StatefulWidget {
  final int semester;

  const AdminSemesterMaterialsScreen({super.key, required this.semester});

  @override
  State<AdminSemesterMaterialsScreen> createState() =>
      _AdminSemesterMaterialsScreenState();
}

class _AdminSemesterMaterialsScreenState
    extends State<AdminSemesterMaterialsScreen> {
  bool _isLoading = true;
  bool _isUploading = false;

  // TODO: Replace with the real category list + existing files fetched
  // from your backend (Firestore/Storage, REST API, etc.) for this semester.
  late List<_MaterialCategory> _categories;

  @override
  void initState() {
    super.initState();
    _loadMaterials();
  }

  Future<void> _loadMaterials() async {
    setState(() => _isLoading = true);

    // TODO: Fetch real data for widget.semester here.
    await Future.delayed(const Duration(milliseconds: 400));

    _categories = [
      _MaterialCategory(title: "Syllabus", icon: Icons.description_rounded),
      _MaterialCategory(title: "Lecture Notes", icon: Icons.edit_note_rounded),
      _MaterialCategory(title: "Slides / PPT", icon: Icons.slideshow_rounded),
      _MaterialCategory(
        title: "Assignments",
        icon: Icons.assignment_rounded,
      ),
      _MaterialCategory(
        title: "Previous Question Papers",
        icon: Icons.quiz_rounded,
      ),
    ];

    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  Future<void> _uploadToCategory(_MaterialCategory category) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'ppt', 'pptx', 'zip'],
        withData: false,
      );

      if (result == null || result.files.isEmpty) return;

      final picked = result.files.single;

      setState(() => _isUploading = true);

      // TODO: Upload `picked.path` (or `picked.bytes` on web) to your
      // backend/storage here, tagged with widget.semester and
      // category.title. Once that succeeds, refresh from the server
      // instead of just appending locally below.
      await Future.delayed(const Duration(seconds: 1));

      final sizeInKb = (picked.size / 1024).toStringAsFixed(0);

      setState(() {
        category.files.add(
          _UploadedFile(
            name: picked.name,
            sizeLabel: "$sizeInKb KB",
            uploadedAt: DateTime.now(),
          ),
        );
        _isUploading = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Uploaded "${picked.name}"')),
      );
    } catch (e) {
      setState(() => _isUploading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Upload failed. Please try again.")),
      );
    }
  }

  void _removeFile(_MaterialCategory category, _UploadedFile file) {
    // TODO: Also delete from backend/storage here.
    setState(() => category.files.remove(file));
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: _categories.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    return _CategoryCard(
                      category: _categories[index],
                      onUpload: () => _uploadToCategory(_categories[index]),
                      onDeleteFile: (file) =>
                          _removeFile(_categories[index], file),
                    );
                  },
                ),
                if (_isUploading)
                  Container(
                    color: Colors.black.withOpacity(0.15),
                    child: const Center(
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                ),
                              ),
                              SizedBox(width: 14),
                              Text("Uploading..."),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final _MaterialCategory category;
  final VoidCallback onUpload;
  final void Function(_UploadedFile file) onDeleteFile;

  const _CategoryCard({
    required this.category,
    required this.onUpload,
    required this.onDeleteFile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
                child: Icon(
                  category.icon,
                  color: const Color(0xFF1B1F3B),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  category.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: onUpload,
                icon: const Icon(Icons.upload_rounded, size: 18),
                label: const Text("Upload"),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF1B1F3B),
                ),
              ),
            ],
          ),
          if (category.files.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 4),
              child: Text(
                "No files uploaded yet",
                style: TextStyle(fontSize: 12.5, color: Colors.grey.shade500),
              ),
            )
          else ...[
            const SizedBox(height: 10),
            const Divider(height: 1),
            ...category.files.map(
              (file) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    const Icon(
                      Icons.insert_drive_file_rounded,
                      size: 18,
                      color: Colors.black45,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        file.name,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Text(
                      file.sizeLabel,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: Colors.redAccent,
                      ),
                      onPressed: () => onDeleteFile(file),
                      splashRadius: 18,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}