import 'package:emailsummaryagent/models/app_user.dart';
import 'package:emailsummaryagent/models/email_message.dart';
import 'package:emailsummaryagent/models/summary_item.dart';
import 'package:emailsummaryagent/models/user_preferences.dart';
import 'package:emailsummaryagent/models/user_profile.dart';
import 'package:emailsummaryagent/services/app_backend.dart';
import 'package:emailsummaryagent/services/notifier_stream_extension.dart';
import 'package:emailsummaryagent/services/summary_engine.dart';
import 'package:flutter/material.dart';

class LocalAppBackend implements AppBackend {
  const LocalAppBackend();

  static final ValueNotifier<AppUser?> _authState = ValueNotifier<AppUser?>(
    null,
  );
  static final Map<String, UserProfile> _profiles = <String, UserProfile>{};
  static final Map<String, List<SummaryItem>> _summaryStore =
      <String, List<SummaryItem>>{};

  @override
  Stream<AppUser?> authState() {
    return _authState.asStream();
  }

  @override
  Future<AppUser> signInWithEmail(String email, String password) async {
    final uid = email.toLowerCase();
    final user = AppUser(
      uid: uid,
      email: email,
      displayName: email.split('@').first,
      photoUrl: '',
    );
    _authState.value = user;
    return user;
  }

  @override
  Future<AppUser> registerWithEmail(String email, String password) {
    return signInWithEmail(email, password);
  }

  @override
  Future<AppUser> signInWithGoogle() async {
    final user = AppUser(
      uid: 'local_google_user',
      email: 'google.user@example.com',
      displayName: 'Google User',
      photoUrl: '',
    );
    _authState.value = user;
    return user;
  }

  @override
  Future<void> signOut() async {
    _authState.value = null;
  }

  @override
  Future<UserProfile> getOrCreateProfile(AppUser user) async {
    final existing = _profiles[user.uid];
    if (existing != null) {
      return existing;
    }

    final profile = UserProfile(
      uid: user.uid,
      email: user.email,
      name: user.displayName,
      photoUrl: user.photoUrl,
      preferences: UserPreferences.initial(),
      preferencesSet: false,
      lastSummarizedAt: null,
    );

    _profiles[user.uid] = profile;
    _summaryStore.putIfAbsent(user.uid, () => <SummaryItem>[]);
    return profile;
  }

  @override
  Future<void> savePreferences(String uid, UserPreferences preferences) async {
    final current = _profiles[uid];
    if (current == null) {
      return;
    }
    _profiles[uid] = current.copyWith(
      preferences: preferences,
      preferencesSet: true,
    );
  }

  @override
  Stream<List<SummaryItem>> summaries(String uid) async* {
    yield _summaryStore[uid] ?? <SummaryItem>[];
  }

  @override
  Future<void> markSummaryRead(String uid, String summaryId) async {
    final list = _summaryStore[uid];
    if (list == null) {
      return;
    }
    final index = list.indexWhere((item) => item.id == summaryId);
    if (index == -1) {
      return;
    }
    list[index] = list[index].copyWith(read: true);
  }

  @override
  Future<void> toggleBookmarkSummary(
    String uid,
    String summaryId,
    bool isBookmarked,
  ) async {
    final list = _summaryStore[uid];
    if (list == null) {
      return;
    }
    final index = list.indexWhere((item) => item.id == summaryId);
    if (index == -1) {
      return;
    }
    list[index] = list[index].copyWith(isBookmarked: isBookmarked);
  }

  @override
  Future<void> deleteSummary(String uid, String summaryId) async {
    final list = _summaryStore[uid];
    if (list == null) {
      return;
    }
    _summaryStore[uid] = list.where((item) => item.id != summaryId).toList();
  }

  @override
  Future<void> updateName(String uid, String name) async {
    final current = _profiles[uid];
    if (current == null) {
      return;
    }
    _profiles[uid] = current.copyWith(name: name);
  }

  @override
  Future<void> generateSummaries({
    required UserProfile profile,
    required UserPreferences preferences,
  }) async {
    // Collect all summarized email IDs
    final existingSummaries = _summaryStore[profile.uid] ?? <SummaryItem>[];
    final summarizedIds = <String>{};
    for (final summary in existingSummaries) {
      summarizedIds.addAll(summary.emailIds);
    }

    final inboxEmails = await fetchInboxEmails(preferences);
    final emails = inboxEmails
      .where((email) => !summarizedIds.contains(email.id))
      .toList();
    final batches = chunkEmails(emails, preferences.numberOfEmails);
    final now = DateTime.now();
    final generated = <SummaryItem>[];

    for (var i = 0; i < batches.length; i++) {
      final batchEmails = batches[i];
      final summary = await summarizeBatchWithAi(
        emails: batchEmails,
        style: preferences.summaryStyle,
        deliveryMethod: preferences.deliveryMethod,
      );
      generated.add(
        SummaryItem(
          id: 'local_${now.millisecondsSinceEpoch}_$i',
          batchIndex: i + 1,
          content: summary,
          createdAt: now,
          read: false,
          emailIds: batchEmails.map((e) => e.id).toList(),
        ),
      );
    }

    final existing = _summaryStore[profile.uid] ?? <SummaryItem>[];
    _summaryStore[profile.uid] = <SummaryItem>[...generated, ...existing];
    _profiles[profile.uid] = profile.copyWith(lastSummarizedAt: now);
  }

  @override
  Future<List<EmailMessage>> fetchInboxEmails(UserPreferences preferences) async {
    return collectEmails(preferences);
  }
}
