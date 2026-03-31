import 'dart:async';
import 'package:emailsummaryagent/models/summary_item.dart';
import 'package:emailsummaryagent/models/user_preferences.dart';
import 'package:emailsummaryagent/models/user_profile.dart';
import 'package:emailsummaryagent/models/enums.dart';
import 'package:emailsummaryagent/services/app_backend.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.backend,
    required this.profile,
    required this.onGenerateSummary,
    required this.onViewSummary,
  });

  final AppBackend backend;
  final UserProfile profile;
  final VoidCallback onGenerateSummary;
  final VoidCallback onViewSummary;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Stream<int> _emailCountStream({
    required UserPreferences preferences,
  }) {
    return Stream<int>.multi((controller) {
      var active = true;
      Timer? midnightTimer;

      Future<void> updateEmailCount() async {
        if (!active) return;
        try {
          final emails = await widget.backend.fetchInboxEmails(preferences);
          final now = DateTime.now();
          
          // Get start of today (00:00:00)
          final today = DateTime(now.year, now.month, now.day);
          
          // Get start of tomorrow (00:00:00)
          final tomorrow = today.add(const Duration(days: 1));

          // Filter emails that arrived today (between today's 00:00 and tomorrow's 00:00)
          final todayEmails = emails.where((email) {
            final emailDate = email.arrivedAt.toLocal();
            return !emailDate.isBefore(today) && emailDate.isBefore(tomorrow);
          }).toList();

          final count = todayEmails.length;
          controller.add(count);
        } catch (_) {
          controller.add(0);
        }
      }

      Future<void> scheduleMidnightReset() async {
        midnightTimer?.cancel();
        
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final midnight = today.add(const Duration(days: 1));
        final durationTilMidnight = midnight.difference(now);

        midnightTimer = Timer(durationTilMidnight, () {
          if (active) {
            updateEmailCount();
            scheduleMidnightReset();
          }
        });
      }

      Future<void> poll() async {
        while (active) {
          await updateEmailCount();
          await Future<void>.delayed(const Duration(seconds: 30));
        }
      }

      poll();
      scheduleMidnightReset();

      controller.onCancel = () {
        active = false;
        midnightTimer?.cancel();
      };
    });
  }

  bool _isInSelectedWindow(
    DateTime date,
    SummaryType summaryType,
    DateTime now,
  ) {
    final day = DateTime(date.year, date.month, date.day);
    final today = DateTime(now.year, now.month, now.day);

    if (summaryType == SummaryType.daily) {
      return day == today;
    }

    final startOfWeekWindow = today.subtract(const Duration(days: 6));
    return !day.isBefore(startOfWeekWindow) && !day.isAfter(today);
  }

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('dd MMM yyyy, hh:mm a');

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: Row(
          children: [
             Center(
                child: Image(image: AssetImage('assets/images/logo.png'), width:40, height: 40),
              ),
            
            const SizedBox(width: 12),
            Text(
              'Email Summary Agent',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0B1F3A),
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.more_vert, color: Color(0xFF6B7A99)),
            onSelected: (value) {
              if (value == 'about') {
                _showAboutUs(context);
              } else if (value == 'terms') {
                _showTermsAndConditions(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'about',
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 20),
                    SizedBox(width: 12),
                    Text('About Us'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'terms',
                child: Row(
                  children: [
                    Icon(Icons.description_outlined, size: 20),
                    SizedBox(width: 12),
                    Text('Terms & Conditions'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            const SizedBox(height: 8),
            // Header greeting
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello! 👋',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFF6B7A99),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Welcome back',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // User profile card with gradient
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
                borderRadius: BorderRadius.circular(24),
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
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 32,
                        backgroundColor: Colors.white30,
                        backgroundImage: widget.profile.photoUrl.isEmpty
                            ? null
                            : NetworkImage(widget.profile.photoUrl),
                        child: widget.profile.photoUrl.isEmpty
                            ? Text(
                                widget.profile.name.isNotEmpty
                                    ? widget.profile.name[0]
                                    : 'U',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.profile.name.isNotEmpty
                                ? widget.profile.name
                                : 'User',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.profile.email,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              widget.profile.lastSummarizedAt == null
                                  ? 'Never summarized'
                                  : formatter.format(
                                      widget.profile.lastSummarizedAt!
                                          .toLocal(),
                                    ),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),
            // Quick action cards
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            // Generate Summary Button
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF00D4AA),
                    const Color(0xFF00D4AA).withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00D4AA).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onGenerateSummary,
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.auto_awesome,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Generate Summary',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Use AI to summarize emails',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // View Summaries Button
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFFFFB457),
                    const Color(0xFFFFB457).withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFB457).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onViewSummary,
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.summarize_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'View Summaries',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Check your email summaries',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Stats section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE3EBFF), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1E6BFF).withOpacity(0.08),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.profile.preferences.summaryType == SummaryType.daily
                        ? "Your today's Status"
                        : "Your Weekly Status",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  StreamBuilder<List<SummaryItem>>(
                    stream: widget.backend.summaries(widget.profile.uid),
                    builder: (context, snapshot) {
                      final allSummaries = snapshot.data ?? [];
                      final today = DateTime.now();

                      final isDaily =
                          widget.profile.preferences.summaryType ==
                          SummaryType.daily;
                      final emailLabel = isDaily ? 'Today\'s Emails' : 'Weekly Emails';

                      final totalSummarizedCount = allSummaries
                          .where(
                            (summary) => _isInSelectedWindow(
                              summary.createdAt.toLocal(),
                              widget.profile.preferences.summaryType,
                              today,
                            ),
                          )
                          .length;

                      return StreamBuilder<int>(
                        stream: _emailCountStream(
                          preferences: widget.profile.preferences,
                        ),
                        initialData: 0,
                        builder: (context, emailSnapshot) {
                          final emailCount = emailSnapshot.data ?? 0;

                          return Row(
                            children: [
                              Expanded(
                                child: _StatCard(
                                  label: emailLabel,
                                  value: emailCount.toString(),
                                  icon: Icons.email_outlined,
                                  color: const Color(0xFF1E6BFF),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _StatCard(
                                  label: 'Summarized',
                                  value: totalSummarizedCount.toString(),
                                  icon: Icons.summarize_outlined,
                                  color: const Color(0xFF00D4AA),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Today's Summary Section
            Text(
              widget.profile.preferences.summaryType == SummaryType.daily
                  ? "Today's Summary"
                  : "This Week's Summary",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            StreamBuilder<List<SummaryItem>>(
              stream: widget.backend.summaries(widget.profile.uid),
              builder: (context, snapshot) {
                final allSummaries = snapshot.data ?? [];
                final today = DateTime.now();

                final filteredSummaries = allSummaries.where((summary) {
                  return _isInSelectedWindow(
                    summary.createdAt.toLocal(),
                    widget.profile.preferences.summaryType,
                    today,
                  );
                }).toList();

                if (filteredSummaries.isEmpty) {
                  final emptyMessage = widget.profile.preferences.summaryType == SummaryType.daily
                      ? 'No summaries for today'
                      : 'No summaries for this week';
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.summarize_outlined,
                              size: 40,
                              color: const Color(0xFF6B7A99).withOpacity(0.5),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              emptyMessage,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: const Color(0xFF6B7A99)),
                            ),
                            const SizedBox(height: 12),
                            FilledButton.icon(
                              onPressed: widget.onGenerateSummary,
                              icon: const Icon(Icons.add),
                              label: const Text('Generate Now'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredSummaries.length,
                  itemBuilder: (context, index) {
                    final summary = filteredSummaries[index];
                    final timeFormatter = DateFormat('hh:mm a');

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Batch ${summary.batchIndex}',
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: summary.read
                                        ? const Color(
                                            0xFF00D4AA,
                                          ).withOpacity(0.2)
                                        : const Color(
                                            0xFFFFB457,
                                          ).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    summary.read ? 'Read' : 'Unread',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: summary.read
                                          ? const Color(0xFF00D4AA)
                                          : const Color(0xFFFFB457),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              timeFormatter.format(summary.createdAt.toLocal()),
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(color: const Color(0xFF6B7A99)),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              summary.content,
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: widget.onViewSummary,
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('View Full'),
                                    SizedBox(width: 4),
                                    Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 14,
                                    ),
                                  ],
                                ),
                              ),
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
          ],
        ),
      ),
    );
  }

  void _showAboutUs(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Us'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Email Summary Agent',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
              SizedBox(height: 12),
              Text(
                'An intelligent email summarization application that uses AI to help you stay on top of your inbox.',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 16),
              Text('Features:', style: TextStyle(fontWeight: FontWeight.w600)),
              SizedBox(height: 8),
              Text('• AI-powered email summarization'),
              Text('• Customizable summary preferences'),
              Text('• Bookmark and manage summaries'),
              Text('• Google and email authentication'),
              SizedBox(height: 16),
              Text(
                'Version: 1.0.0',
                style: TextStyle(fontSize: 12, color: Color(0xFF6B7A99)),
              ),
            ],
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTermsAndConditions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms & Conditions'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '1. User Agreement',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              Text(
                'By using this application, you agree to these terms and conditions.',
                style: TextStyle(fontSize: 13),
              ),
              SizedBox(height: 16),
              Text(
                '2. Data Privacy',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              Text(
                'We respect your privacy and protect your email data according to industry standards.',
                style: TextStyle(fontSize: 13),
              ),
              SizedBox(height: 16),
              Text(
                '3. Limited Liability',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              Text(
                'The service is provided "as is" without warranties of any kind.',
                style: TextStyle(fontSize: 13),
              ),
              SizedBox(height: 16),
              Text(
                '4. Changes to Terms',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              Text(
                'We may update these terms at any time. Your continued use means acceptance.',
                style: TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Accept'),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: const Color(0xFF6B7A99)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
