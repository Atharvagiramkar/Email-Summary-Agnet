import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emailsummaryagent/models/user_feedback.dart';
import 'package:flutter/foundation.dart';

class FeedbackService {
  FeedbackService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<void> submitFeedback(UserFeedback feedback) async {
    try {
      debugPrint('Submitting feedback: id=${feedback.id}, uid=${feedback.uid}');
      await _firestore
          .collection('feedback')
          .doc(feedback.id)
          .set(feedback.toJson());
      debugPrint('Feedback saved: id=${feedback.id}');
    } catch (e) {
      debugPrint('Feedback submit failed: $e');
      throw Exception('Failed to submit feedback: $e');
    }
  }

  Stream<List<UserFeedback>> userFeedbacks(String uid) {
    return _firestore
        .collection('feedback')
        .where('uid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => UserFeedback.fromJson(doc.data()))
              .toList();
        });
  }
}
