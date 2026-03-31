import 'package:emailsummaryagent/models/summary_item.dart';
import 'package:emailsummaryagent/models/user_profile.dart';
import 'package:emailsummaryagent/services/app_backend.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SummaryDetailPage extends StatefulWidget {
  const SummaryDetailPage({
    super.key,
    required this.backend,
    required this.profile,
    required this.summary,
  });

  final AppBackend backend;
  final UserProfile profile;
  final SummaryItem summary;

  @override
  State<SummaryDetailPage> createState() => _SummaryDetailPageState();
}

class _SummaryDetailPageState extends State<SummaryDetailPage> {
  late bool _read;
  late bool _isBookmarked;

  @override
  void initState() {
    super.initState();
    _read = widget.summary.read;
    _isBookmarked = widget.summary.isBookmarked;
  }

  Future<void> _markRead() async {
    await widget.backend.markSummaryRead(widget.profile.uid, widget.summary.id);
    if (mounted) {
      setState(() => _read = true);
    }
  }

  Future<void> _toggleBookmark() async {
    await widget.backend.toggleBookmarkSummary(
      widget.profile.uid,
      widget.summary.id,
      !_isBookmarked,
    );
    if (mounted) {
      setState(() => _isBookmarked = !_isBookmarked);
    }
  }

  Future<void> _deleteSummary() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Summary'),
        content: const Text(
          'Are you sure you want to delete this summary? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await widget.backend.deleteSummary(widget.profile.uid, widget.summary.id);
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('dd MMM yyyy, hh:mm a');

    return Scaffold(
      appBar: AppBar(
        title: Text('Summary Batch ${widget.summary.batchIndex}'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0B1F3A),
        actions: [
          IconButton(
            onPressed: _toggleBookmark,
            icon: Icon(
              _isBookmarked
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_outline_rounded,
              color: _isBookmarked
                  ? const Color(0xFFFFB457)
                  : const Color(0xFF6B7A99),
            ),
          ),
          IconButton(
            onPressed: _deleteSummary,
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: Color(0xFFFF6B6B),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E6BFF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF1E6BFF).withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formatter.format(widget.summary.createdAt.toLocal()),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: const Color(0xFF6B7A99),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _read
                              ? const Color(0xFF00D4AA).withOpacity(0.2)
                              : const Color(0xFFFFB457).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _read ? 'Read' : 'Unread',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _read
                                ? const Color(0xFF00D4AA)
                                : const Color(0xFFFFB457),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (_isBookmarked)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFB457).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.bookmark_rounded,
                                size: 12,
                                color: Color(0xFFFFB457),
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Bookmarked',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFFFB457),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  widget.summary.content,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF0B1F3A),
                    height: 1.6,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _read ? null : _markRead,
              child: Text(_read ? 'Already Marked Read' : 'Mark as Read'),
            ),
          ],
        ),
      ),
    );
  }
}
