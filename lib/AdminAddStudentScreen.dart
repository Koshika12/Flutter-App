import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'student_repository.dart';

class AdminAddStudentScreen extends StatefulWidget {
  const AdminAddStudentScreen({super.key});

  @override
  State<AdminAddStudentScreen> createState() => _AdminAddStudentScreenState();
}

class _AdminAddStudentScreenState extends State<AdminAddStudentScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  int _selectedSemester = 1;
  DateTime? _joinedDate;
  bool _isSaving = false;
  bool _obscurePassword = true;

  // Tracks whether the admin has hand-edited the email, so we stop
  // overwriting it every time the name changes.
  bool _emailManuallyEdited = false;

  // TODO: Replace with your institution's real email domain.
  static const String _emailDomain = "college.edu";

  final List<int> _semesters = List.generate(8, (i) => i + 1);
  final Random _rand = Random.secure();

  @override
  void initState() {
    super.initState();
    _passwordCtrl.text = _generatePassword();
    _nameCtrl.addListener(_onNameChanged);
    _emailCtrl.addListener(_onEmailFieldEdited);
  }

  @override
  void dispose() {
    _nameCtrl.removeListener(_onNameChanged);
    _emailCtrl.removeListener(_onEmailFieldEdited);
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _onNameChanged() {
    if (_emailManuallyEdited) return;
    final generated = _generateEmail(_nameCtrl.text);
    // Update without re-triggering the manual-edit listener.
    _emailCtrl.removeListener(_onEmailFieldEdited);
    _emailCtrl.text = generated;
    _emailCtrl.addListener(_onEmailFieldEdited);
    setState(() {});
  }

  void _onEmailFieldEdited() {
    // Any direct edit to the email field means we stop auto-updating it.
    _emailManuallyEdited = true;
  }

  String _generateEmail(String name) {
    final slug = name
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z\s]'), '')
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .join('.');

    if (slug.isEmpty) return "";

    final suffix = 100 + _rand.nextInt(900); // 3-digit disambiguator
    return "$slug$suffix@$_emailDomain";
  }

  void _regenerateEmail() {
    setState(() {
      _emailManuallyEdited = false;
      final generated = _generateEmail(_nameCtrl.text);
      _emailCtrl.removeListener(_onEmailFieldEdited);
      _emailCtrl.text = generated;
      _emailCtrl.addListener(_onEmailFieldEdited);
    });
  }

  String _generatePassword({int length = 10}) {
    const upper = 'ABCDEFGHJKLMNPQRSTUVWXYZ';
    const lower = 'abcdefghijkmnpqrstuvwxyz';
    const digits = '23456789';
    const symbols = '!@#\$%&*';
    const all = upper + lower + digits + symbols;

    final chars = <String>[
      upper[_rand.nextInt(upper.length)],
      lower[_rand.nextInt(lower.length)],
      digits[_rand.nextInt(digits.length)],
      symbols[_rand.nextInt(symbols.length)],
    ];

    for (var i = chars.length; i < length; i++) {
      chars.add(all[_rand.nextInt(all.length)]);
    }

    chars.shuffle(_rand);
    return chars.join();
  }

  void _regeneratePassword() {
    setState(() {
      _passwordCtrl.text = _generatePassword();
      _obscurePassword = false;
    });
  }

  Future<void> _pickJoinedDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _joinedDate ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1B1F3B),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _joinedDate = picked);
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec",
    ];
    return "${date.day} ${months[date.month - 1]} ${date.year}";
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_joinedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select the date they joined")),
      );
      return;
    }

    setState(() => _isSaving = true);

    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;
    final semester = _selectedSemester;
    final joinedDate = _joinedDate!;

    // TODO: Replace with real calls to your backend:
    // 1. Create the login account (e.g. Firebase Auth
    //    createUserWithEmailAndPassword, or your own auth API) using
    //    `email` and `password`, tagged with role "student".
    //    NOTE: if the generated email happens to collide with an
    //    existing account, catch that error here and regenerate.
    // 2. Create the student record (name, semester, email, joinedDate)
    //    linked to that account, e.g.:
    //    await studentRepository.addStudent(
    //      name: name,
    //      semester: semester,
    //      email: email,
    //      joinedDate: joinedDate,
    //      uid: createdAuthUser.uid,
    //    );
    await Future.delayed(const Duration(seconds: 1));

    // Save locally so it shows up immediately in semester counts and the
    // Student Accounts screen. Swap/extend this once real backend calls
    // (auth account creation + student record) are wired in above.
    StudentRepository.instance.addStudent(
      Student(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: name,
        semester: semester,
        email: email,
        password: password,
        joinedDate: joinedDate,
      ),
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    await _showCredentialsDialog(name: name, email: email, password: password);

    if (!mounted) return;
    Navigator.pop(context);
  }

  Future<void> _showCredentialsDialog({
    required String name,
    required String email,
    required String password,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Row(
            children: const [
              Icon(Icons.check_circle_rounded, color: Colors.green),
              SizedBox(width: 10),
              Text("Student Account Created"),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "$name can now log in with these credentials. Share them securely — this password won't be shown again.",
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 16),
              _CredentialRow(label: "Email", value: email),
              const SizedBox(height: 10),
              _CredentialRow(label: "Password", value: password),
            ],
          ),
          actions: [
            TextButton.icon(
              onPressed: () {
                Clipboard.setData(
                  ClipboardData(text: "Email: $email\nPassword: $password"),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Credentials copied")),
                );
              },
              icon: const Icon(Icons.copy_rounded, size: 18),
              label: const Text("Copy Both"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B1F3B),
              ),
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Done", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text("Add Student"),
        backgroundColor: const Color(0xFF1B1F3B),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _FieldLabel("Full Name"),
            const SizedBox(height: 6),
            TextFormField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: _inputDecoration(hint: "e.g. Aarav Sharma"),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Please enter the student's name";
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            _FieldLabel("Semester"),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _selectedSemester,
                  isExpanded: true,
                  items: _semesters
                      .map((s) => DropdownMenuItem(
                            value: s,
                            child: Text("Semester $s"),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedSemester = value);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF1B1F3B).withOpacity(0.04),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF1B1F3B).withOpacity(0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.lock_outline_rounded,
                          size: 18, color: Color(0xFF1B1F3B)),
                      const SizedBox(width: 8),
                      const Text(
                        "Student Login Account",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B1F3B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Email and password are generated automatically from the name above. You can edit or regenerate either one.",
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 14),

                  _FieldLabel("Login Email"),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _inputDecoration(
                      hint: "Fill in the name to auto-generate",
                    ).copyWith(
                      suffixIcon: IconButton(
                        tooltip: "Regenerate",
                        icon: const Icon(Icons.refresh_rounded, size: 20),
                        onPressed: _nameCtrl.text.trim().isEmpty
                            ? null
                            : _regenerateEmail,
                      ),
                    ),
                    validator: (value) {
                      final v = value?.trim() ?? "";
                      if (v.isEmpty) return "Enter the student's name to generate an email";
                      final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                      if (!emailRegex.hasMatch(v)) return "Enter a valid email address";
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),

                  _FieldLabel("Password"),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _passwordCtrl,
                    obscureText: _obscurePassword,
                    decoration: _inputDecoration(hint: "Password").copyWith(
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: "Regenerate",
                            icon: const Icon(Icons.refresh_rounded, size: 20),
                            onPressed: _regeneratePassword,
                          ),
                          IconButton(
                            tooltip: _obscurePassword ? "Show" : "Hide",
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              size: 20,
                            ),
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                          const SizedBox(width: 4),
                        ],
                      ),
                    ),
                    validator: (value) {
                      final v = value ?? "";
                      if (v.isEmpty) return "Please set a password";
                      if (v.length < 8) return "Use at least 8 characters";
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            _FieldLabel("Date Joined This Semester"),
            const SizedBox(height: 6),
            InkWell(
              onTap: _pickJoinedDate,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_rounded,
                        size: 18, color: Colors.grey.shade600),
                    const SizedBox(width: 10),
                    Text(
                      _joinedDate == null
                          ? "Select a date"
                          : _formatDate(_joinedDate!),
                      style: TextStyle(
                        fontSize: 14,
                        color: _joinedDate == null
                            ? Colors.grey.shade500
                            : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B1F3B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _isSaving ? null : _submit,
                child: _isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        "Create Student Account",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF1B1F3B), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }
}

class _CredentialRow extends StatelessWidget {
  final String label;
  final String value;

  const _CredentialRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy_rounded, size: 16),
            splashRadius: 16,
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("$label copied")),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.grey.shade700,
      ),
    );
  }
}