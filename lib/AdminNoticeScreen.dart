import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class _Notice {
  final String title;
  final String message;
  final String? attachmentName;
  final DateTime postedAt;

  _Notice({
    required this.title,
    required this.message,
    this.attachmentName,
    required this.postedAt,
  });
}

class AdminNoticeScreen extends StatefulWidget {
  const AdminNoticeScreen({super.key});

  @override
  State<AdminNoticeScreen> createState() => _AdminNoticeScreenState();
}

class _AdminNoticeScreenState extends State<AdminNoticeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();

  PlatformFile? _attachedFile;
  bool _isPosting = false;
  bool _isLoading = true;

  // TODO: Replace with notices fetched from your backend.
  List<_Notice> _notices = [];

  @override
  void initState() {
    super.initState();
    _loadNotices();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadNotices() async {
    setState(() => _isLoading = true);

    // TODO: Fetch real notices from your backend here.
    await Future.delayed(const Duration(milliseconds: 400));

    _notices = [];

    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  Future<void> _pickAttachment() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
      withData: false,
    );

    if (result == null || result.files.isEmpty) return;

    setState(() => _attachedFile = result.files.single);
  }

  void _removeAttachment() {
    setState(() => _attachedFile = null);
  }

  Future<void> _postNotice() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isPosting = true);

    // TODO: Upload `_attachedFile` (if any) and save the notice to your
    // backend here, e.g.:
    // await noticeRepository.postNotice(
    //   title: _titleCtrl.text.trim(),
    //   message: _messageCtrl.text.trim(),
    //   attachmentPath: _attachedFile?.path,
    // );
    await Future.delayed(const Duration(seconds: 1));

    final newNotice = _Notice(
      title: _titleCtrl.text.trim(),
      message: _messageCtrl.text.trim(),
      attachmentName: _attachedFile?.name,
      postedAt: DateTime.now(),
    );

    if (!mounted) return;
    setState(() {
      _notices.insert(0, newNotice);
      _isPosting = false;
      _titleCtrl.clear();
      _messageCtrl.clear();
      _attachedFile = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Notice posted")),
    );
  }

  void _deleteNotice(_Notice notice) {
    // TODO: Also delete from backend here.
    setState(() => _notices.remove(notice));
  }

  String _formatDate(DateTime date) {
    const months = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec",
    ];
    return "${date.day} ${months[date.month - 1]} ${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text("Notices"),
        backgroundColor: const Color(0xFF1B1F3B),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // ---- Upload / post section ----
                Container(
                  padding: const EdgeInsets.all(16),
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
                  child: Form(
                    key: _formKey,
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
                              child: const Icon(
                                Icons.campaign_rounded,
                                color: Color(0xFF1B1F3B),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              "Post a New Notice",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _titleCtrl,
                          decoration: _inputDecoration(hint: "Notice title"),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? "Please enter a title"
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _messageCtrl,
                          maxLines: 4,
                          decoration: _inputDecoration(hint: "Notice details..."),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? "Please enter a message"
                              : null,
                        ),
                        const SizedBox(height: 12),
                        if (_attachedFile == null)
                          OutlinedButton.icon(
                            onPressed: _pickAttachment,
                            icon: const Icon(Icons.attach_file_rounded, size: 18),
                            label: const Text("Attach a file (optional)"),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF1B1F3B),
                              side: BorderSide(color: Colors.grey.shade300),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12,
                              ),
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F7FB),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.insert_drive_file_rounded,
                                    size: 18, color: Colors.black54),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _attachedFile!.name,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close_rounded,
                                      size: 18, color: Colors.redAccent),
                                  onPressed: _removeAttachment,
                                  splashRadius: 16,
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1B1F3B),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _isPosting ? null : _postNotice,
                            icon: _isPosting
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.upload_rounded,
                                    color: Colors.white, size: 18),
                            label: Text(
                              _isPosting ? "Posting..." : "Post Notice",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                const Text(
                  "Posted Notices",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                // ---- Existing notices list ----
                if (_notices.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        "No notices posted yet",
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    ),
                  )
                else
                  ..._notices.map(
                    (notice) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  notice.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  notice.message,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                if (notice.attachmentName != null) ...[
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(Icons.attach_file_rounded,
                                          size: 14, color: Colors.black45),
                                      const SizedBox(width: 4),
                                      Text(
                                        notice.attachmentName!,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                const SizedBox(height: 6),
                                Text(
                                  _formatDate(notice.postedAt),
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: Colors.redAccent, size: 20),
                            onPressed: () => _deleteNotice(notice),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  InputDecoration _inputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF5F7FB),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF1B1F3B), width: 2),
      ),
    );
  }
}