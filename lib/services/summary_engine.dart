import 'package:emailsummaryagent/models/email_message.dart';
import 'package:emailsummaryagent/models/enums.dart';
import 'package:emailsummaryagent/models/user_preferences.dart';
import 'package:emailsummaryagent/services/app_runtime.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

List<EmailMessage> collectEmails(UserPreferences preferences, {Set<String> summarizedEmailIds = const {}}) {
  final now = DateTime.now();
  final all = List<EmailMessage>.generate(18, (index) {
    return EmailMessage(
      id: 'email_${index + 1}',
      subject: 'Email #${index + 1}',
      body: 'Key update from conversation ${index + 1}.',
      arrivedAt: now.subtract(Duration(hours: index * 8)),
      isRead: index % 3 == 0,
      isStarred: index % 4 == 0,
    );
  });

  final windowStart = preferences.summaryType == SummaryType.daily
      ? DateTime(now.year, now.month, now.day)
      : now.subtract(const Duration(days: 7));

  final byDate = all
      .where((email) => email.arrivedAt.isAfter(windowStart))
      .where((email) => !summarizedEmailIds.contains(email.id))
      .toList();

  switch (preferences.emailFilter) {
    case EmailFilter.all:
      return byDate;
    case EmailFilter.unread:
      return byDate.where((email) => !email.isRead).toList();
    case EmailFilter.starred:
      return byDate.where((email) => email.isStarred).toList();
  }
}

/// Get emails arrived today (daily count for current status)
List<EmailMessage> collectEmailsForToday() {
  final now = DateTime.now();
  final all = List<EmailMessage>.generate(18, (index) {
    return EmailMessage(
      id: 'email_${index + 1}',
      subject: 'Email #${index + 1}',
      body: 'Key update from conversation ${index + 1}.',
      arrivedAt: now.subtract(Duration(hours: index * 8)),
      isRead: index % 3 == 0,
      isStarred: index % 4 == 0,
    );
  });

  final todayStart = DateTime(now.year, now.month, now.day);
  
  return all
      .where((email) => email.arrivedAt.isAfter(todayStart))
      .toList();
}

/// Get all emails since registration (all emails arrived since account creation)
List<EmailMessage> collectEmailsSinceRegistration() {
  final now = DateTime.now();
  // Generate more emails spanning from account creation date (simulated as 30+ days ago)
  final all = List<EmailMessage>.generate(50, (index) {
    return EmailMessage(
      id: 'email_${index + 1}',
      subject: 'Email #${index + 1}',
      body: 'Key update from conversation ${index + 1}.',
      arrivedAt: now.subtract(Duration(hours: index * 8)),
      isRead: index % 3 == 0,
      isStarred: index % 4 == 0,
    );
  });

  return all;
}

List<List<EmailMessage>> chunkEmails(List<EmailMessage> emails, int batchSize) {
  if (emails.isEmpty) {
    return <List<EmailMessage>>[];
  }

  final size = batchSize <= 0 ? 1 : batchSize;
  final batches = <List<EmailMessage>>[];

  for (var i = 0; i < emails.length; i += size) {
    batches.add(emails.sublist(i, (i + size).clamp(0, emails.length)));
  }
  return batches;
}

String summarizeBatch({
  required List<EmailMessage> emails,
  required SummaryStyle style,
  required DeliveryMethod deliveryMethod,
}) {
  final tone = switch (style) {
    SummaryStyle.formal => 'formal',
    SummaryStyle.casual => 'casual',
    SummaryStyle.bullet => 'bullet-point',
  };

  final lines = emails
      .map((email) => '${email.subject}: ${email.body}')
      .join(style == SummaryStyle.bullet ? '\n• ' : ' ');

  final prefix = style == SummaryStyle.bullet ? '• ' : '';
  final delivery = deliveryMethod == DeliveryMethod.inbox
      ? 'This summary is also queued for inbox delivery.'
      : 'This summary is available in app.';

  return '$prefix[$tone summary] $lines\n\n$delivery';
}

Future<String> summarizeBatchWithAi({
  required List<EmailMessage> emails,
  required SummaryStyle style,
  required DeliveryMethod deliveryMethod,
}) async {
  if (emails.isEmpty) {
    return 'No eligible emails were found for this batch.';
  }

  final fallback = summarizeBatch(
    emails: emails,
    style: style,
    deliveryMethod: deliveryMethod,
  );

  if (!AppRuntime.aiEnabled) {
    return fallback;
  }

  final styleInstruction = switch (style) {
    SummaryStyle.formal => 'Use a formal and professional tone.',
    SummaryStyle.casual => 'Use a concise and friendly casual tone.',
    SummaryStyle.bullet => 'Use clear bullet points.',
  };

  final deliveryInstruction = deliveryMethod == DeliveryMethod.inbox
      ? 'Add one short closing line that this summary should also be sent to inbox.'
      : 'Keep the summary optimized for in-app reading.';

  final emailLines = emails
      .map(
        (email) =>
            '- Subject: ${email.subject}\n  Body: ${email.body}\n  Arrived: ${email.arrivedAt.toIso8601String()}',
      )
      .join('\n');

  final prompt =
      '''
You are an email summarization assistant. Create a useful summary from the following emails.

$styleInstruction
$deliveryInstruction
Keep it accurate and concise.

Emails:
$emailLines
''';

  try {
    final model = GenerativeModel(
      model: 'gemini-2.5-pro',
      apiKey: AppRuntime.geminiApiKey,
    );
    final response = await model.generateContent([Content.text(prompt)]);
    final text = response.text?.trim();
    if (text == null || text.isEmpty) {
      return fallback;
    }
    return text;
  } catch (_) {
    return fallback;
  }
}
