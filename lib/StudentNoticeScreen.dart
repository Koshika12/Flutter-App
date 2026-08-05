import 'package:flutter/material.dart';
import 'notice_repository.dart';

class StudentNoticeScreen extends StatefulWidget {
  final String? initialQuery;

  const StudentNoticeScreen({super.key, this.initialQuery});

  @override
  State<StudentNoticeScreen> createState() => _StudentNoticeScreenState();
}

class _StudentNoticeScreenState extends State<StudentNoticeScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery ?? "");
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    return "${date.day} ${months[date.month - 1]} ${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text("Notices"),
        backgroundColor: Color(0xFF1B1F3B),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: "Search notices...",
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () =>
                            setState(() => _searchController.clear()),
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFFF5F7FB),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 4),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFF1B1F3B), width: 2),
                ),
              ),
            ),
          ),
          Expanded(
            child: ValueListenableBuilder<List<Notice>>(
              valueListenable: NoticeRepository.instance.noticesNotifier,
              builder: (context, allNotices, _) {
                final query = _searchController.text.trim().toLowerCase();
                final notices = query.isEmpty
                    ? allNotices
                    : allNotices
                        .where((n) =>
                            n.title.toLowerCase().contains(query) ||
                            n.message.toLowerCase().contains(query))
                        .toList();

                if (allNotices.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.campaign_outlined,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "No notices posted yet",
                            style: TextStyle(
                                color: Colors.grey.shade600, fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (notices.isEmpty) {
                  return Center(
                    child: Text(
                      "No notices match \"${_searchController.text}\"",
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: notices.length,
                  itemBuilder: (context, index) {
                    final notice = notices[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Color(0xFF1B1F3B).withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.campaign_rounded,
                                  color: Color(0xFF1B1F3B),
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  notice.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            notice.message,
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey.shade700),
                          ),
                          if (notice.attachmentName != null) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.attach_file_rounded,
                                    size: 14, color: Colors.black45),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    notice.attachmentName!,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 8),
                          Text(
                            _formatDate(notice.postedAt),
                            style: TextStyle(
                                fontSize: 11.5, color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
