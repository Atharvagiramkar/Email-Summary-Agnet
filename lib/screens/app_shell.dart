import 'package:emailsummaryagent/models/user_preferences.dart';
import 'package:emailsummaryagent/models/user_profile.dart';
import 'package:emailsummaryagent/models/enums.dart';
import 'package:emailsummaryagent/screens/history_page.dart';
import 'package:emailsummaryagent/screens/home_page.dart';
import 'package:emailsummaryagent/screens/preferences_screen.dart';
import 'package:emailsummaryagent/screens/profile_page.dart';
import 'package:emailsummaryagent/screens/summary_page.dart';
import 'package:emailsummaryagent/services/app_backend.dart';
import 'package:flutter/material.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.backend,
    required this.initialProfile,
  });

  final AppBackend backend;
  final UserProfile initialProfile;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late UserProfile _profile;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _profile = widget.initialProfile;
    _refreshProfile();
  }

  Future<void> _refreshProfile() async {
    final currentUser = await widget.backend.authState().first;
    if (currentUser == null) {
      return;
    }
    final profile = await widget.backend.getOrCreateProfile(currentUser);
    if (mounted) {
      setState(() => _profile = profile);
    }
  }

  Future<void> _generateSummary() async {
    // Collect all summarized email IDs to exclude them
    final existingSummaries = await widget.backend.summaries(_profile.uid).first;
    final summarizedIds = <String>{};
    for (final summary in existingSummaries) {
      summarizedIds.addAll(summary.emailIds);
    }

    // Check if there are any emails before generating summary
    final inboxEmails = await widget.backend.fetchInboxEmails(_profile.preferences);
    final emails = inboxEmails
        .where((email) => !summarizedIds.contains(email.id))
        .toList();

    if (emails.isEmpty) {
      if (!mounted) return;

      // Show different message based on summary type
      final isDaily = _profile.preferences.summaryType == SummaryType.daily;
      final message = isDaily
          ? 'No new email has arrived yet. You may wait or try again later.'
          : 'There is no new email arrived in this week. Kindly check your email address or wait till a new email to arrive in your inbox, and retry again.';

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('No New Emails'),
          content: Text(message),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    // Proceed with summary generation if emails exist
    await widget.backend.generateSummaries(
      profile: _profile,
      preferences: _profile.preferences,
    );
    await _refreshProfile();
    if (!mounted) {
      return;
    }
    setState(() => _index = 1);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Summaries generated successfully.')),
    );
  }

  Future<void> _openPreferences() async {
    final result = await Navigator.of(context).push<UserPreferences>(
      MaterialPageRoute(
        builder: (_) => PreferencesScreen(
          backend: widget.backend,
          profile: _profile,
          isInitialSetup: false,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _profile = _profile.copyWith(preferences: result, preferencesSet: true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomePage(
        backend: widget.backend,
        profile: _profile,
        onGenerateSummary: _generateSummary,
        onViewSummary: () => setState(() => _index = 1),
      ),
      SummaryPage(backend: widget.backend, profile: _profile),
      HistoryPage(backend: widget.backend, profile: _profile),
      ProfilePage(
        backend: widget.backend,
        profile: _profile,
        onEditPreferences: _openPreferences,
        onProfileUpdated: _refreshProfile,
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        backgroundColor: Colors.white,
        elevation: 12,
        surfaceTintColor: Colors.white,
        shadowColor: const Color(0xFF1E6BFF).withOpacity(0.1),
        destinations: [
          NavigationDestination(
            icon: Icon(
              Icons.home_outlined,
              color: _index == 0
                  ? const Color(0xFF1E6BFF)
                  : const Color(0xFF6B7A99),
            ),
            selectedIcon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF1E6BFF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.home_rounded, color: Color(0xFF1E6BFF)),
            ),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.summarize_outlined,
              color: _index == 1
                  ? const Color(0xFF00D4AA)
                  : const Color(0xFF6B7A99),
            ),
            selectedIcon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF00D4AA).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.summarize_rounded,
                color: Color(0xFF00D4AA),
              ),
            ),
            label: 'Summary',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.history_outlined,
              color: _index == 2
                  ? const Color(0xFFFFB457)
                  : const Color(0xFF6B7A99),
            ),
            selectedIcon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFB457).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.history_rounded,
                color: Color(0xFFFFB457),
              ),
            ),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.person_outline,
              color: _index == 3
                  ? const Color(0xFF9B5DE5)
                  : const Color(0xFF6B7A99),
            ),
            selectedIcon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF9B5DE5).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.person_rounded, color: Color(0xFF9B5DE5)),
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
