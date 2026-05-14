import 'package:cloud_firestore/cloud_firestore.dart';
class UserFeedback {
  UserFeedback({
    required this.id,
    required this.uid,
    required this.userEmail,
    required this.name,
    required this.subject,
    required this.message,
    required this.createdAt,
    this.status = 'pending',
  });

  // Stored feedback payload sent to Firestore.
  final String id;
  final String uid;
  final String userEmail;
  final String name;
  final String subject;
  final String message;
  final DateTime createdAt;
  final String status; // pending, read

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uid': uid,
      'userEmail': userEmail,
      'name': name,
      'subject': subject,
      'message': message,
      'createdAt': createdAt,
      'status': status,
    };
  }

  factory UserFeedback.fromJson(Map<String, dynamic> json) {
    return UserFeedback(
      id: json['id'] ?? '',
      uid: json['uid'] ?? '',
      userEmail: json['userEmail'] ?? '',
      name: json['name'] ?? '',
      subject: json['subject'] ?? '',
      message: json['message'] ?? '',
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: json['status'] ?? 'pending',
    );
  }
}
