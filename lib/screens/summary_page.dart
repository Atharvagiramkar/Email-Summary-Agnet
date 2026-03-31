import 'package:emailsummaryagent/models/summary_item.dart';
import 'package:emailsummaryagent/models/user_profile.dart';
import 'package:emailsummaryagent/screens/summary_detail_page.dart';
import 'package:emailsummaryagent/services/app_backend.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SummaryPage extends StatefulWidget {
  const SummaryPage({super.key, required this.backend, required this.profile});

  final AppBackend backend;
  final UserProfile profile;

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('dd MMM yyyy, hh:mm a');

    return SafeArea(
      child: StreamBuilder<List<SummaryItem>>(
        stream: widget.backend.summaries(widget.profile.uid),
        initialData: const <SummaryItem>[],
        builder: (context, snapshot) {
          final items = snapshot.data ?? <SummaryItem>[];

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                pinned: true,
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF0B1F3A),
                elevation: 0,
                title: Text(
                  'Summaries',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (items.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Text(
                            'No summaries yet.\nGenerate from Home page.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(color: const Color(0xFF6B7A99)),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              else
                SliverList.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFE3EBFF),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1E6BFF).withOpacity(0.08),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () async {
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => SummaryDetailPage(
                                    backend: widget.backend,
                                    profile: widget.profile,
                                    summary: item,
                                  ),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              'Batch ${item.batchIndex}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 11,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: item.read
                                                    ? const Color(
                                                        0xFF00D4AA,
                                                      ).withOpacity(0.15)
                                                    : const Color(
                                                        0xFFFFB457,
                                                      ).withOpacity(0.15),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                item.read ? 'Read' : 'Unread',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: item.read
                                                      ? const Color(0xFF00D4AA)
                                                      : const Color(0xFFFFB457),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          formatter.format(
                                            item.createdAt.toLocal(),
                                          ),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: const Color(0xFF6B7A99),
                                              ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          item.content.split('\n').first,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                color: const Color(0xFF0B1F3A),
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      GestureDetector(
                                        onTap: () async {
                                          await widget.backend
                                              .toggleBookmarkSummary(
                                                widget.profile.uid,
                                                item.id,
                                                !item.isBookmarked,
                                              );
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: item.isBookmarked
                                                ? const Color(
                                                    0xFFFFB457,
                                                  ).withOpacity(0.15)
                                                : const Color(0xFFE3EBFF),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Icon(
                                            item.isBookmarked
                                                ? Icons.bookmark_rounded
                                                : Icons
                                                      .bookmark_outline_rounded,
                                            color: item.isBookmarked
                                                ? const Color(0xFFFFB457)
                                                : const Color(0xFF6B7A99),
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      GestureDetector(
                                        onTap: () async {
                                          final confirm = await showDialog<bool>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text('Delete'),
                                              content: const Text(
                                                'Are you sure you want to delete this summary?',
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                        context,
                                                        false,
                                                      ),
                                                  child: const Text('Cancel'),
                                                ),
                                                FilledButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                        context,
                                                        true,
                                                      ),
                                                  child: const Text('Delete'),
                                                ),
                                              ],
                                            ),
                                          );

                                          if (confirm == true) {
                                            await widget.backend.deleteSummary(
                                              widget.profile.uid,
                                              item.id,
                                            );
                                          }
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: const Color(
                                              0xFFFF6B6B,
                                            ).withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.delete_outline_rounded,
                                            color: Color(0xFFFF6B6B),
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}
