import 'package:emailsummaryagent/models/enums.dart';
import 'package:emailsummaryagent/models/summary_item.dart';
import 'package:emailsummaryagent/models/user_profile.dart';
import 'package:emailsummaryagent/screens/auth_gate.dart';
import 'package:emailsummaryagent/screens/splash_screen.dart';
import 'package:emailsummaryagent/services/app_backend.dart';
import 'package:emailsummaryagent/services/summary_engine.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    super.key,
    required this.backend,
    required this.profile,
    required this.onEditPreferences,
    required this.onProfileUpdated,
  });

  final AppBackend backend;
  final UserProfile profile;
  final Future<void> Function() onEditPreferences;
  final Future<void> Function() onProfileUpdated;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final TextEditingController _nameController;
  bool _updating = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveName() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      return;
    }

    setState(() => _updating = true);
    await widget.backend.updateName(widget.profile.uid, name);
    await widget.onProfileUpdated();
    if (mounted) {
      setState(() => _updating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final prefs = widget.profile.preferences;
    final formatter = DateFormat('dd MMM yyyy');

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Profile',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          // Profile Info Card
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF1E6BFF),
                  const Color(0xFF1E6BFF).withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1E6BFF).withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Account',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Name',
                      labelStyle: const TextStyle(color: Colors.white70),
                      prefixIcon: const Icon(
                        Icons.person_outline,
                        color: Colors.white,
                      ),
                      filled: true,
                      fillColor: Colors.white12,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.white30),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.white30),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _updating ? null : _saveName,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF1E6BFF),
                    ),
                    child: const Text('Update Name'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Preferences Card
          Text(
            'Preferences',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PreferenceRow('Email', widget.profile.email),
                  const SizedBox(height: 12),
                  _PreferenceRow('Summary Type', prefs.summaryType.label),
                  const SizedBox(height: 12),
                  _PreferenceRow('Email Filter', prefs.emailFilter.label),
                  const SizedBox(height: 12),
                  _PreferenceRow('Emails per batch', '${prefs.numberOfEmails}'),
                  const SizedBox(height: 12),
                  _PreferenceRow('Summary Style', prefs.summaryStyle.label),
                  const SizedBox(height: 12),
                  _PreferenceRow('Delivery Method', prefs.deliveryMethod.label),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () async {
              await widget.onEditPreferences();
              await widget.onProfileUpdated();
            },
            child: const Text('Edit Preferences'),
          ),
          const SizedBox(height: 24),
          // Your Current Status Section
          Text(
            'Your Current Status',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          StreamBuilder<List<SummaryItem>>(
            stream: widget.backend.summaries(widget.profile.uid),
            builder: (context, snapshot) {
              final allSummaries = snapshot.data ?? [];

              // Count all emails since registration
              final allEmails = collectEmailsSinceRegistration();
              int totalEmailCount = allEmails.length;
              int totalSummaryCount = allSummaries.length;

              return Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E6BFF).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF1E6BFF).withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.email_outlined,
                            color: const Color(0xFF1E6BFF),
                            size: 24,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            totalEmailCount.toString(),
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: const Color(0xFF1E6BFF),
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Total Emails',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(color: const Color(0xFF6B7A99)),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00D4AA).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF00D4AA).withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.summarize_outlined,
                            color: const Color(0xFF00D4AA),
                            size: 24,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            totalSummaryCount.toString(),
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: const Color(0xFF00D4AA),
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Total Summaries',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(color: const Color(0xFF6B7A99)),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          // Bookmarked Summaries Section
          Text(
            'Bookmarked Summaries',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          StreamBuilder<List<SummaryItem>>(
            stream: widget.backend.summaries(widget.profile.uid),
            builder: (context, snapshot) {
              final allSummaries = snapshot.data ?? [];
              final bookmarked = allSummaries
                  .where((s) => s.isBookmarked)
                  .toList();

              if (bookmarked.isEmpty) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: Text(
                        'No bookmarked summaries yet',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF6B7A99),
                        ),
                      ),
                    ),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: bookmarked.length,
                itemBuilder: (context, index) {
                  final item = bookmarked[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Batch ${item.batchIndex}',
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              Icon(
                                Icons.bookmark_rounded,
                                color: const Color(0xFFFFB457),
                                size: 18,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formatter.format(item.createdAt.toLocal()),
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(color: const Color(0xFF6B7A99)),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.content.split('\n').first,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 24),
          // Recent Summaries Section
          Text(
            'All Summaries',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          StreamBuilder<List<SummaryItem>>(
            stream: widget.backend.summaries(widget.profile.uid),
            builder: (context, snapshot) {
              final summaries = snapshot.data ?? [];

              if (summaries.isEmpty) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: Text(
                        'No summaries generated yet',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF6B7A99),
                        ),
                      ),
                    ),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: summaries.length > 5 ? 5 : summaries.length,
                itemBuilder: (context, index) {
                  final item = summaries[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Batch ${item.batchIndex}',
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              Text(
                                item.read ? 'Read' : 'Unread',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: item.read
                                      ? const Color(0xFF00D4AA)
                                      : const Color(0xFFFFB457),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formatter.format(item.createdAt.toLocal()),
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(color: const Color(0xFF6B7A99)),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.content.split('\n').first,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 24),
          FilledButton.tonal(
            onPressed: () async {
              await widget.backend.signOut();
              if (!mounted) {
                return;
              }
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (_) =>
                      SplashScreen(child: AuthGate(backend: widget.backend)),
                ),
                (route) => false,
              );
            },
            child: const Text('Logout'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _PreferenceRow extends StatelessWidget {
  const _PreferenceRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(color: const Color(0xFF6B7A99)),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0B1F3A),
            ),
          ),
        ),
      ],
    );
  }
}
