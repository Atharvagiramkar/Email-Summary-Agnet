import 'package:emailsummaryagent/models/user_feedback.dart';
import 'package:emailsummaryagent/services/feedback_service.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class FeedbackDialog extends StatefulWidget {
  const FeedbackDialog({
    super.key,
    required this.uid,
    required this.userEmail,
    required this.userName,
    required this.feedbackService,
    required this.onFeedbackSubmitted,
  });

  final String uid;
  final String userEmail;
  final String userName;
  final FeedbackService feedbackService;
  final VoidCallback onFeedbackSubmitted;

  @override
  State<FeedbackDialog> createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends State<FeedbackDialog> {
  late final TextEditingController _subjectController;
  late final TextEditingController _messageController;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _subjectController = TextEditingController();
    _messageController = TextEditingController();
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    // Basic validation before submitting feedback.
    final subject = _subjectController.text.trim();
    final message = _messageController.text.trim();

    if (subject.isEmpty) {
      setState(() => _errorMessage = 'Please enter a subject');
      return;
    }

    if (message.isEmpty) {
      setState(() => _errorMessage = 'Please enter your message');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final feedback = UserFeedback(
        id: const Uuid().v4(),
        uid: widget.uid,
        userEmail: widget.userEmail,
        name: widget.userName,
        subject: subject,
        message: message,
        createdAt: DateTime.now(),
        status: 'pending',
      );

      await widget.feedbackService.submitFeedback(feedback);

      if (!mounted) return;

      widget.onFeedbackSubmitted();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Your query is recored and will be solved very soon. Thank you for you precisious feedback !!',
          ),
          backgroundColor: Color(0xFF00D4AA),
          duration: Duration(seconds: 3),
        ),
      );

      Navigator.of(context).pop();
    } catch (e) {
      setState(() => _errorMessage = 'Failed to submit feedback. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Send Us Your Feedback',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Help us improve by sharing your thoughts and suggestions',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF6B7A99),
                  ),
                ),
                const SizedBox(height: 24),
                // Subject Field
                TextField(
                  controller: _subjectController,
                  enabled: !_isSubmitting,
                  decoration: InputDecoration(
                    labelText: 'Subject',
                    hintText: 'Brief subject of your feedback',
                    prefixIcon: const Icon(Icons.subject),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF1E6BFF),
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF1E6BFF),
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Message Field
                TextField(
                  controller: _messageController,
                  enabled: !_isSubmitting,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: 'Your Message',
                    hintText:
                        'Tell us what you think. Your feedback helps us improve the app.',
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Icon(Icons.message_outlined),
                    ),
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF1E6BFF),
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF1E6BFF),
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Error Message
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B6B).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFFFF6B6B),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Color(0xFFFF6B6B),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: Color(0xFFFF6B6B),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (_errorMessage != null) const SizedBox(height: 16),
                // Info Box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E6BFF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF1E6BFF).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Color(0xFF1E6BFF),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: const Text(
                          'Your feedback is saved securely for review.',
                          style: TextStyle(
                            color: Color(0xFF1E6BFF),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isSubmitting
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    FilledButton(
                      onPressed: _isSubmitting ? null : _submitFeedback,
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Send Feedback'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
