import 'package:emailsummaryagent/models/email_message.dart';
import 'package:emailsummaryagent/models/enums.dart';
import 'package:emailsummaryagent/models/user_preferences.dart';
import 'package:emailsummaryagent/services/app_runtime.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

List<EmailMessage> collectEmails(UserPreferences preferences, {Set<String> summarizedEmailIds = const {}}) {
  // Demo data used when Gmail access isn't available.
  final now = DateTime.now();
  final sampleSubjects = [
    'Q1 Sales Report',
    'Project Kickoff Meeting',
    'Budget Review Feedback',
    'Team Updates',
    'Client Presentation',
    'Feature Release Notes',
    'Performance Metrics',
    'HR Policy Changes',
    'Conference Registration',
    'Code Review Notes',
    'Database Migration Plan',
    'Security Audit Results',
    'Customer Feedback Summary',
    'Quarterly Planning',
    'Infrastructure Updates',
    'API Documentation',
    'Team Lunch RSVP',
    'Sprint Retrospective',
  ];

  final sampleBodies = [
    'Q1 shows strong growth with 25% increase in revenue. All departments exceeded targets.',
    'Starting new feature development. First milestone deadline is March 15.',
    'Department budgets approved. Please review allocation details and confirm.',
    'Team members traveled for conference. Full debrief scheduled tomorrow at 10am.',
    'Client presentation went well. They requested demo of new dashboard features.',
    'Version 2.3 released with bug fixes and performance improvements. See release notes.',
    'Last month metrics show improved deployment frequency and reduced error rates.',
    'New remote work policy effective immediately. Updated handbook sent to all staff.',
    'Tech summit early bird registration opens tomorrow. Link in travel portal.',
    'PR #487 ready for review. Updated authentication flow with better error handling.',
    'Database migration scheduled for after-hours. Estimated downtime 2-3 hours.',
    'Security audit completed with one minor finding. Remediation plan prepared.',
    'Customer survey results back. Satisfaction score up 12% from last quarter.',
    'OKRs for Q2 finalized and shared. Quarterly planning session next week.',
    'CDN migration reduced latency by 40%. All regions successfully updated.',
    'REST API documentation updated. Added examples for new endpoints.',
    'Team lunch next Friday. Please RSVP by Wednesday in the calendar invite.',
    'Sprint completed successfully. 18 of 20 story points delivered.',
  ];

  final all = List<EmailMessage>.generate(18, (index) {
    return EmailMessage(
      id: 'email_${index + 1}',
      subject: sampleSubjects[index],
      body: sampleBodies[index],
      arrivedAt: now.subtract(Duration(hours: index * 8)),
      isRead: index % 3 == 0,
      isStarred: index % 4 == 0,
    );
  });

  // Restrict results to the selected daily/weekly window.
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
  final sampleSubjects = [
    'Q1 Sales Report',
    'Project Kickoff Meeting',
    'Budget Review Feedback',
    'Team Updates',
    'Client Presentation',
    'Feature Release Notes',
    'Performance Metrics',
    'HR Policy Changes',
    'Conference Registration',
    'Code Review Notes',
    'Database Migration Plan',
    'Security Audit Results',
    'Customer Feedback Summary',
    'Quarterly Planning',
    'Infrastructure Updates',
    'API Documentation',
    'Team Lunch RSVP',
    'Sprint Retrospective',
  ];

  final sampleBodies = [
    'Q1 shows strong growth with 25% increase in revenue. All departments exceeded targets.',
    'Starting new feature development. First milestone deadline is March 15.',
    'Department budgets approved. Please review allocation details and confirm.',
    'Team members traveled for conference. Full debrief scheduled tomorrow at 10am.',
    'Client presentation went well. They requested demo of new dashboard features.',
    'Version 2.3 released with bug fixes and performance improvements. See release notes.',
    'Last month metrics show improved deployment frequency and reduced error rates.',
    'New remote work policy effective immediately. Updated handbook sent to all staff.',
    'Tech summit early bird registration opens tomorrow. Link in travel portal.',
    'PR #487 ready for review. Updated authentication flow with better error handling.',
    'Database migration scheduled for after-hours. Estimated downtime 2-3 hours.',
    'Security audit completed with one minor finding. Remediation plan prepared.',
    'Customer survey results back. Satisfaction score up 12% from last quarter.',
    'OKRs for Q2 finalized and shared. Quarterly planning session next week.',
    'CDN migration reduced latency by 40%. All regions successfully updated.',
    'REST API documentation updated. Added examples for new endpoints.',
    'Team lunch next Friday. Please RSVP by Wednesday in the calendar invite.',
    'Sprint completed successfully. 18 of 20 story points delivered.',
  ];

  final all = List<EmailMessage>.generate(18, (index) {
    return EmailMessage(
      id: 'email_${index + 1}',
      subject: sampleSubjects[index],
      body: sampleBodies[index],
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
  final sampleSubjects = [
    'Q1 Sales Report',
    'Project Kickoff Meeting',
    'Budget Review Feedback',
    'Team Updates',
    'Client Presentation',
    'Feature Release Notes',
    'Performance Metrics',
    'HR Policy Changes',
    'Conference Registration',
    'Code Review Notes',
    'Database Migration Plan',
    'Security Audit Results',
    'Customer Feedback Summary',
    'Quarterly Planning',
    'Infrastructure Updates',
    'API Documentation',
    'Team Lunch RSVP',
    'Sprint Retrospective',
    'Weekly Stand-up Notes',
    'Analytics Dashboard Update',
    'Design Review Feedback',
    'Testing Results',
    'Deployment Checklist',
    'Monthly Newsletter',
    'Social Event Announcement',
    'Training Session Reminder',
    'Compliance Update',
    'New Hire Onboarding',
    'Product Demo Invitation',
    'Feedback Request',
    'Roadmap Preview',
    'Partnership Announcement',
    'System Maintenance Notice',
    'Tool Migration Plan',
    'Career Development Plan',
    'Award Announcement',
    'Project Milestone',
    'Client Testimonial',
    'Industry News Digest',
    'Webinar Recording',
    'Documentation Update',
    'Bug Fix Release',
    'Feature Deprecation Notice',
    'Licensing Renewal',
    'Support Ticket Summary',
    'Performance Optimization',
    'Risk Assessment Report',
    'Vendor Evaluation',
    'Contract Review',
    'Travel Policy Update',
  ];

  final sampleBodies = [
    'Q1 shows strong growth with 25% increase in revenue. All departments exceeded targets.',
    'Starting new feature development. First milestone deadline is March 15.',
    'Department budgets approved. Please review allocation details and confirm.',
    'Team members traveled for conference. Full debrief scheduled tomorrow at 10am.',
    'Client presentation went well. They requested demo of new dashboard features.',
    'Version 2.3 released with bug fixes and performance improvements. See release notes.',
    'Last month metrics show improved deployment frequency and reduced error rates.',
    'New remote work policy effective immediately. Updated handbook sent to all staff.',
    'Tech summit early bird registration opens tomorrow. Link in travel portal.',
    'PR #487 ready for review. Updated authentication flow with better error handling.',
    'Database migration scheduled for after-hours. Estimated downtime 2-3 hours.',
    'Security audit completed with one minor finding. Remediation plan prepared.',
    'Customer survey results back. Satisfaction score up 12% from last quarter.',
    'OKRs for Q2 finalized and shared. Quarterly planning session next week.',
    'CDN migration reduced latency by 40%. All regions successfully updated.',
    'REST API documentation updated. Added examples for new endpoints.',
    'Team lunch next Friday. Please RSVP by Wednesday in the calendar invite.',
    'Sprint completed successfully. 18 of 20 story points delivered.',
    'Weekly sync completed. Key topics: project timeline and resource allocation.',
    'New dashboard launched with real-time analytics. Check it out at analytics.company.com.',
    'Design mockups approved for next release. Frontend implementation can begin.',
    'All tests passing. Code coverage improved to 85% from 78%.',
    'Production deployment completed successfully. Zero downtime rollout finished.',
    'Latest company newsletter with highlights of Q1 achievements.',
    'Company picnic scheduled for April 15. Sign up in the event system.',
    'New training sessions available on cloud architecture. Enrollment open now.',
    'Annual compliance review required. Complete by Friday. Link in email.',
    'Welcome to Sarah Chen, new Engineering Manager. Say hello at team lunch!',
    'Schedule a product demo with our team. Demo opportunities available next week.',
    'Help us improve by completing this 2-minute survey about tool usage.',
    'Product roadmap for next quarter released. Check wiki for full details.',
    'Announcing partnership with TechCorp Solutions. Integration coming Q2.',
    'Scheduled maintenance on Friday 2-4 AM. Systems will be unavailable during window.',
    'Jira migration completed. All projects moved. New links sent separately.',
    'Q2 career development plans due. Schedule 1-on-1 with your manager.',
    'Congratulations to team on winning Innovation Award. Celebration planned.',
    'Project Falcon reached major milestone. Shipped to beta testing today.',
    'Customer loves our solution. Great feedback from implementation review.',
    'Check out latest industry report on cloud trends. Article link below.',
    'Webinar recording: Advanced cloud architecture patterns now available.',
    'Updated developer documentation. New API reference section published.',
    'Bug fix release 2.3.1 now available. One critical fix included.',
    'Feature X deprecated in v3.0. Migration guide available on wiki.',
    'License renewal notice. Please contact sales to finalize contract.',
    'Support ticket summary: 47 tickets resolved this week, 3 critical.',
    'Performance optimization reduced memory usage by 30%. See benchmarks.',
    'Risk assessment completed. Three mitigation plans documented.',
    'Vendor demo scheduled. Meeting invite sent with evaluation criteria.',
    'Contract review completed. Legal approved with minor amendments.',
    'Travel policy updated. New per-diem rates effective immediately.',
  ];

  // Generate more emails spanning from account creation date
  final all = List<EmailMessage>.generate(50, (index) {
    return EmailMessage(
      id: 'email_${index + 1}',
      subject: sampleSubjects[index % sampleSubjects.length],
      body: sampleBodies[index % sampleBodies.length],
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
  if (emails.isEmpty) {
    return 'No emails to summarize.';
  }

  // Adjust the tone header and delivery footer based on preferences.
  final tone = switch (style) {
    SummaryStyle.formal => 'FORMAL SUMMARY',
    SummaryStyle.casual => 'QUICK SUMMARY',
    SummaryStyle.bullet => 'KEY POINTS',
  };

  final delivery = deliveryMethod == DeliveryMethod.inbox
      ? '\n\n📧 This summary will be sent to your inbox.'
      : '\n\n💾 This summary is saved in your app.';

  late String content;

  switch (style) {
    case SummaryStyle.formal:
      // Formal summary: organized by topic
      final grouped = <String, List<String>>{};
      for (final email in emails) {
        final topic = _extractTopic(email.subject);
        grouped.putIfAbsent(topic, () => []).add(email.body);
      }

      final sections = grouped.entries.map((entry) {
        final topic = entry.key;
        final items = entry.value.take(2).toList(); // Limit to 2 items per topic
        return '${topic.toUpperCase()}: ${items.join(" ")}';
      }).toList();

      content = sections.join('\n\n');
      return '$tone\n\n$content$delivery';

    case SummaryStyle.casual:
      // Casual: key info from each email in natural language
      final summaries = emails.take(5).map((email) {
        final preview = email.body.split('.').first;
        return '• ${email.subject}: $preview';
      }).toList();

      content = summaries.join('\n');
      return '$tone\n\n$content$delivery';

    case SummaryStyle.bullet:
      // Bullet points: extract actionable items
      final bullets = emails.take(8).map((email) {
        final keyPhrase = _extractKeyPhrase(email.body);
        return '• ${email.subject} - $keyPhrase';
      }).toList();

      content = bullets.join('\n');
      return '${style == SummaryStyle.bullet ? "📋 " : ""}$tone\n\n$content$delivery';
  }
}

String _extractTopic(String subject) {
  // Extract main topic from subject line
  final words = subject.split(' ');
  if (words.isEmpty) return 'General';
  
  // Return first meaningful word(s)
  if (subject.contains('Report')) return 'Reports';
  if (subject.contains('Meeting')) return 'Meetings';
  if (subject.contains('Update')) return 'Updates';
  if (subject.contains('Review')) return 'Reviews';
  if (subject.contains('Feedback')) return 'Feedback';
  if (subject.contains('Release')) return 'Releases';
  
  return words.take(2).join(' ');
}

String _extractKeyPhrase(String body) {
  // Extract first meaningful sentence or phrase
  final sentences = body.split('.');
  if (sentences.isEmpty || sentences[0].isEmpty) {
    return 'See details';
  }
  
  final firstSentence = sentences[0].trim();
  if (firstSentence.length > 100) {
    // Truncate long sentences
    return '${firstSentence.substring(0, 100).trim()}...';
  }
  
  return firstSentence;
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

  // Fall back to local summarization when AI is disabled.
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
