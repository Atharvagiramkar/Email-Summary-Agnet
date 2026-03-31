import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emailsummaryagent/models/app_user.dart';
import 'package:emailsummaryagent/models/email_message.dart';
import 'package:emailsummaryagent/models/enums.dart';
import 'package:emailsummaryagent/models/summary_item.dart';
import 'package:emailsummaryagent/models/user_preferences.dart';
import 'package:emailsummaryagent/models/user_profile.dart';
import 'package:emailsummaryagent/services/app_backend.dart';
import 'package:emailsummaryagent/services/app_runtime.dart';
import 'package:emailsummaryagent/services/gmail_service.dart';
import 'package:emailsummaryagent/services/summary_engine.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAppBackend implements AppBackend {
  FirebaseAppBackend({GmailService? gmailService})
    : _gmailService = gmailService ?? GmailService();

  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _db => FirebaseFirestore.instance;
  GoogleSignIn get _googleSignIn => GoogleSignIn.instance;
  final GmailService _gmailService;

  static const List<String> _gmailScopes = <String>[
    'https://www.googleapis.com/auth/gmail.readonly',
    'https://www.googleapis.com/auth/gmail.send',
  ];

  GoogleSignInAccount? _googleAccount;
  String? _gmailAccessToken;

  @override
  Stream<AppUser?> authState() {
    return _auth.authStateChanges().map((user) {
      if (user == null) {
        return null;
      }
      return AppUser(
        uid: user.uid,
        email: user.email ?? '',
        displayName: user.displayName ?? 'User',
        photoUrl: user.photoURL ?? '',
      );
    });
  }

  @override
  Future<AppUser> signInWithEmail(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user;
    if (user == null) {
      throw Exception('Unable to sign in.');
    }
    return AppUser(
      uid: user.uid,
      email: user.email ?? email,
      displayName: user.displayName ?? 'User',
      photoUrl: user.photoURL ?? '',
    );
  }

  @override
  Future<AppUser> registerWithEmail(String email, String password) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user;
    if (user == null) {
      throw Exception('Unable to register user.');
    }
    return AppUser(
      uid: user.uid,
      email: user.email ?? email,
      displayName: user.displayName ?? 'User',
      photoUrl: user.photoURL ?? '',
    );
  }

  @override
  Future<AppUser> signInWithGoogle() async {
    await _googleSignIn.initialize(
      clientId: AppRuntime.googleOauthWebClientId.isEmpty
          ? null
          : AppRuntime.googleOauthWebClientId,
      serverClientId: AppRuntime.googleOauthWebClientId.isEmpty
          ? null
          : AppRuntime.googleOauthWebClientId,
    );

    final account = await _googleSignIn.authenticate();
    _googleAccount = account;

    await _ensureGmailAuthorization(interactive: true);

    final auth = account.authentication;
    final credential = GoogleAuthProvider.credential(idToken: auth.idToken);

    final userCredential = await _auth.signInWithCredential(credential);
    final user = userCredential.user;
    if (user == null) {
      throw Exception('Google sign in failed.');
    }

    return AppUser(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? 'User',
      photoUrl: user.photoURL ?? '',
    );
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    _googleAccount = null;
    _gmailAccessToken = null;
  }

  @override
  Future<UserProfile> getOrCreateProfile(AppUser user) async {
    final ref = _db.collection('users').doc(user.uid);
    final snapshot = await ref.get();

    if (!snapshot.exists) {
      final profile = UserProfile(
        uid: user.uid,
        email: user.email,
        name: user.displayName,
        photoUrl: user.photoUrl,
        preferences: UserPreferences.initial(),
        preferencesSet: false,
        lastSummarizedAt: null,
      );
      await ref.set(profile.toMap());
      return profile;
    }

    return UserProfile.fromMap(snapshot.data() ?? <String, dynamic>{});
  }

  @override
  Future<void> savePreferences(String uid, UserPreferences preferences) {
    return _db.collection('users').doc(uid).update({
      'preferences': preferences.toMap(),
      'preferencesSet': true,
    });
  }

  @override
  Stream<List<SummaryItem>> summaries(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('summaries')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map(
                (doc) => SummaryItem.fromMap(
                  Map<String, dynamic>.from(doc.data())
                    ..putIfAbsent('id', () => doc.id),
                ),
              )
              .toList();
        });
  }

  @override
  Future<void> markSummaryRead(String uid, String summaryId) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('summaries')
        .doc(summaryId)
        .update({'read': true});
  }

  @override
  Future<void> toggleBookmarkSummary(
    String uid,
    String summaryId,
    bool isBookmarked,
  ) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('summaries')
        .doc(summaryId)
        .update({'isBookmarked': isBookmarked});
  }

  @override
  Future<void> deleteSummary(String uid, String summaryId) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('summaries')
        .doc(summaryId)
        .delete();
  }

  @override
  Future<void> updateName(String uid, String name) {
    return _db.collection('users').doc(uid).update({'name': name});
  }

  @override
  Future<void> generateSummaries({
    required UserProfile profile,
    required UserPreferences preferences,
  }) async {
    final summarizedIds = await _loadSummarizedEmailIds(profile.uid);
    final inboxEmails = await fetchInboxEmails(preferences);
    final emails = inboxEmails
        .where((email) => !summarizedIds.contains(email.id))
        .toList();
    final batches = chunkEmails(emails, preferences.numberOfEmails);
    final collection = _db
        .collection('users')
        .doc(profile.uid)
        .collection('summaries');

    for (var i = 0; i < batches.length; i++) {
      final batchEmails = batches[i];
      final summary = await summarizeBatchWithAi(
        emails: batchEmails,
        style: preferences.summaryStyle,
        deliveryMethod: preferences.deliveryMethod,
      );
      await collection.add({
        'batchIndex': i + 1,
        'content': summary,
        'createdAt': DateTime.now().toIso8601String(),
        'read': false,
        'emailIds': batchEmails.map((e) => e.id).toList(),
      });

      if (preferences.deliveryMethod == DeliveryMethod.inbox &&
          _gmailAccessToken != null &&
          profile.email.isNotEmpty) {
        await _gmailService.sendMessage(
          accessToken: _gmailAccessToken!,
          to: profile.email,
          subject: 'Email Summary Batch ${i + 1}',
          body: summary,
        );
      }
    }

    await _db.collection('users').doc(profile.uid).update({
      'lastSummarizedAt': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<List<EmailMessage>> fetchInboxEmails(UserPreferences preferences) {
    return _collectEmailsFromGmail(preferences);
  }

  Future<void> _ensureGmailAuthorization({required bool interactive}) async {
    final account = _googleAccount;
    if (account == null) {
      return;
    }

    GoogleSignInClientAuthorization? authorization = await account
        .authorizationClient
        .authorizationForScopes(_gmailScopes);

    if (authorization == null && interactive) {
      authorization = await account.authorizationClient.authorizeScopes(
        _gmailScopes,
      );
    }

    _gmailAccessToken = authorization?.accessToken;
  }

  Future<List<EmailMessage>> _collectEmailsFromGmail(
    UserPreferences preferences,
  ) async {
    await _ensureGmailAuthorization(interactive: false);
    final token = _gmailAccessToken;
    if (token == null || token.isEmpty) {
      return <EmailMessage>[];
    }

    try {
      final result = await _gmailService.listMessages(
        accessToken: token,
        preferences: preferences,
        maxResults: 100,
      );
      if (result.isEmpty) {
        return <EmailMessage>[];
      }
      return result;
    } catch (_) {
      return <EmailMessage>[];
    }
  }

  Future<Set<String>> _loadSummarizedEmailIds(String uid) async {
    final snapshot = await _db
        .collection('users')
        .doc(uid)
        .collection('summaries')
        .get();

    final ids = <String>{};
    for (final doc in snapshot.docs) {
      final raw = doc.data()['emailIds'] as List<dynamic>? ?? <dynamic>[];
      ids.addAll(raw.map((id) => id.toString()));
    }
    return ids;
  }
}
