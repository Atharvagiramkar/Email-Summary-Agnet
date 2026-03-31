import 'package:emailsummaryagent/models/user_preferences.dart';

class UserProfile {
  const UserProfile({
    required this.uid,
    required this.email,
    required this.name,
    required this.photoUrl,
    required this.preferences,
    required this.preferencesSet,
    required this.lastSummarizedAt,
  });

  final String uid;
  final String email;
  final String name;
  final String photoUrl;
  final UserPreferences preferences;
  final bool preferencesSet;
  final DateTime? lastSummarizedAt;

  UserProfile copyWith({
    String? name,
    String? photoUrl,
    UserPreferences? preferences,
    bool? preferencesSet,
    DateTime? lastSummarizedAt,
  }) {
    return UserProfile(
      uid: uid,
      email: email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      preferences: preferences ?? this.preferences,
      preferencesSet: preferencesSet ?? this.preferencesSet,
      lastSummarizedAt: lastSummarizedAt ?? this.lastSummarizedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'preferences': preferences.toMap(),
      'preferencesSet': preferencesSet,
      'lastSummarizedAt': lastSummarizedAt?.toIso8601String(),
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      name: map['name']?.toString() ?? 'User',
      photoUrl: map['photoUrl']?.toString() ?? '',
      preferences: UserPreferences.fromMap(
        (map['preferences'] as Map<String, dynamic>?) ?? <String, dynamic>{},
      ),
      preferencesSet: map['preferencesSet'] as bool? ?? false,
      lastSummarizedAt: map['lastSummarizedAt'] == null
          ? null
          : DateTime.tryParse(map['lastSummarizedAt'].toString()),
    );
  }
}
