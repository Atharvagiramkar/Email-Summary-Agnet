import 'package:emailsummaryagent/models/app_user.dart';
import 'package:emailsummaryagent/models/email_message.dart';
import 'package:emailsummaryagent/models/summary_item.dart';
import 'package:emailsummaryagent/models/user_preferences.dart';
import 'package:emailsummaryagent/models/user_profile.dart';

abstract class AppBackend {
  Stream<AppUser?> authState();

  Future<AppUser> signInWithEmail(String email, String password);

  Future<AppUser> registerWithEmail(String email, String password);

  Future<AppUser> signInWithGoogle();

  Future<void> signOut();

  Future<UserProfile> getOrCreateProfile(AppUser user);

  Future<void> savePreferences(String uid, UserPreferences preferences);

  Stream<List<SummaryItem>> summaries(String uid);

  Future<void> markSummaryRead(String uid, String summaryId);

  Future<void> toggleBookmarkSummary(
    String uid,
    String summaryId,
    bool isBookmarked,
  );

  Future<void> deleteSummary(String uid, String summaryId);

  Future<void> generateSummaries({
    required UserProfile profile,
    required UserPreferences preferences,
  });

  Future<List<EmailMessage>> fetchInboxEmails(UserPreferences preferences);

  Future<void> updateName(String uid, String name);
}
