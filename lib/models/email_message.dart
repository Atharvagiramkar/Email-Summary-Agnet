class EmailMessage {
  const EmailMessage({
    required this.id,
    required this.subject,
    required this.body,
    required this.arrivedAt,
    required this.isRead,
    required this.isStarred,
  });

  final String id;
  final String subject;
  final String body;
  final DateTime arrivedAt;
  final bool isRead;
  final bool isStarred;
}
