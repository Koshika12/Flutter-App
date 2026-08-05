import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'HomeScreen.dart';

class CompleteProfileScreen extends StatefulWidget {
  final bool isEditMode;

  const CompleteProfileScreen({super.key, this.isEditMode = false});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _rollNoController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  String? _photoPath;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadExistingProfile();
  }

  @override
  void dispose() {
    _rollNoController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingProfile() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _rollNoController.text = prefs.getString('studentRollNo') ?? '';
      _photoPath = prefs.getString('studentProfilePhotoPath');
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 85);
    if (picked == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('studentProfilePhotoPath', picked.path);

    if (!mounted) return;
    setState(() {
      _photoPath = picked.path;
    });
  }

  Future<void> _removePhoto() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('studentProfilePhotoPath');
    if (!mounted) return;
    setState(() => _photoPath = null);
  }

  Future<void> _showPhotoPicker() async {
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Choose from gallery'),
                onTap: () async {
                  Navigator.pop(ctx);
                  await _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('Take a photo'),
                onTap: () async {
                  Navigator.pop(ctx);
                  await _pickImage(ImageSource.camera);
                },
              ),
              if (_photoPath != null)
                ListTile(
                  leading: const Icon(Icons.delete_outline),
                  title: const Text('Remove photo'),
                  onTap: () async {
                    Navigator.pop(ctx);
                    await _removePhoto();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final prefs = await SharedPreferences.getInstance();
    final rollNo = _rollNoController.text.trim();
    await prefs.setString('studentRollNo', rollNo);
    await prefs.setBool('studentProfileCompleted', true);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (widget.isEditMode) {
      Navigator.pop(context, true);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const StudentHomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isEditMode ? 'Edit Profile' : 'Complete Your Profile';
    final buttonText = widget.isEditMode ? 'Save Changes' : 'Save & Continue';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B1F3B),
        foregroundColor: Colors.white,
        title: Text(title),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.isEditMode
                      ? 'Update your roll number and photo below.'
                      : 'Please add your roll number and optional profile photo to continue.',
                  style: const TextStyle(fontSize: 15, color: Colors.black54),
                ),
                const SizedBox(height: 22),
                Center(
                  child: GestureDetector(
                    onTap: _showPhotoPicker,
                    child: CircleAvatar(
                      radius: 46,
                      backgroundColor:
                          const Color(0xFF1B1F3B).withOpacity(0.12),
                      backgroundImage: _photoPath != null
                          ? FileImage(File(_photoPath!))
                          : null,
                      child: _photoPath == null
                          ? const Icon(Icons.add_a_photo_outlined,
                              size: 30, color: Color(0xFF1B1F3B))
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: TextButton(
                    onPressed: _showPhotoPicker,
                    child: const Text('Add / Change Photo'),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Roll Number',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _rollNoController,
                  textCapitalization: TextCapitalization.characters,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your roll number';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'e.g. BCA-5-01',
                    prefixIcon: const Icon(Icons.badge_outlined),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B1F3B),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.5, color: Colors.white),
                          )
                        : Text(buttonText,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
