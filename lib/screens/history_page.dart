import 'package:emailsummaryagent/models/summary_item.dart';
import 'package:emailsummaryagent/models/user_profile.dart';
import 'package:emailsummaryagent/screens/summary_detail_page.dart';
import 'package:emailsummaryagent/services/app_backend.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key, required this.backend, required this.profile});

  final AppBackend backend;
  final UserProfile profile;

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final TextEditingController _queryController = TextEditingController();

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('dd MMM yyyy');

    return SafeArea(
      child: StreamBuilder<List<SummaryItem>>(
        stream: widget.backend.summaries(widget.profile.uid),
        initialData: const <SummaryItem>[],
        builder: (context, snapshot) {
          final all = snapshot.data ?? <SummaryItem>[];
          final query = _queryController.text.trim();
          final filtered = query.isEmpty
              ? all
              : all.where((item) {
                  final dateText = formatter.format(item.createdAt);
                  return dateText.contains(query);
                }).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('History', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 12),
              TextField(
                controller: _queryController,
                decoration: const InputDecoration(
                  labelText: 'Search by date (e.g., 27 Feb 2026)',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              ...filtered.map(
                (item) => Card(
                  child: ListTile(
                    title: Text('Batch ${item.batchIndex}'),
                    subtitle: Text(formatter.format(item.createdAt)),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => SummaryDetailPage(
                            backend: widget.backend,
                            profile: widget.profile,
                            summary: item,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
