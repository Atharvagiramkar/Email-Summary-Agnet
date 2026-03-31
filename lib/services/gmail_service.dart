import 'dart:convert';

import 'package:emailsummaryagent/models/email_message.dart';
import 'package:emailsummaryagent/models/enums.dart';
import 'package:emailsummaryagent/models/user_preferences.dart';
import 'package:http/http.dart' as http;

class GmailService {
  GmailService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<EmailMessage>> listMessages({
    required String accessToken,
    required UserPreferences preferences,
    required int maxResults,
  }) async {
    final q = _buildQuery(preferences);
    final uri = Uri.https(
      'gmail.googleapis.com',
      '/gmail/v1/users/me/messages',
      {'maxResults': maxResults.toString(), 'q': q},
    );

    final listResponse = await _client.get(uri, headers: _headers(accessToken));
    if (listResponse.statusCode >= 400) {
      throw Exception('Failed to list Gmail messages: ${listResponse.body}');
    }

    final listJson = jsonDecode(listResponse.body) as Map<String, dynamic>;
    final rawMessages = (listJson['messages'] as List<dynamic>? ?? <dynamic>[])
        .cast<Map<String, dynamic>>();

    final messages = <EmailMessage>[];
    for (final entry in rawMessages) {
      final id = entry['id']?.toString();
      if (id == null || id.isEmpty) {
        continue;
      }

      final detailUri = Uri.https(
        'gmail.googleapis.com',
        '/gmail/v1/users/me/messages/$id',
        {'format': 'metadata', 'metadataHeaders': 'Subject'},
      );

      final detailResponse = await _client.get(
        detailUri,
        headers: _headers(accessToken),
      );
      if (detailResponse.statusCode >= 400) {
        continue;
      }

      final detailJson =
          jsonDecode(detailResponse.body) as Map<String, dynamic>;
      final payload =
          (detailJson['payload'] as Map<String, dynamic>?) ??
          <String, dynamic>{};
      final headers = (payload['headers'] as List<dynamic>? ?? <dynamic>[])
          .cast<Map<String, dynamic>>();
      final labelIds = (detailJson['labelIds'] as List<dynamic>? ?? <dynamic>[])
          .map((label) => label.toString())
          .toSet();

      final subjectHeader = headers.firstWhere(
        (header) => header['name']?.toString().toLowerCase() == 'subject',
        orElse: () => <String, dynamic>{'value': '(No Subject)'},
      );
      final subject = subjectHeader['value']?.toString() ?? '(No Subject)';
      final body = detailJson['snippet']?.toString() ?? '';

      final internalDateMs =
          int.tryParse(detailJson['internalDate']?.toString() ?? '') ??
          DateTime.now().millisecondsSinceEpoch;
      final arrivedAt = DateTime.fromMillisecondsSinceEpoch(internalDateMs);

      messages.add(
        EmailMessage(
          id: id,
          subject: subject,
          body: body,
          arrivedAt: arrivedAt,
          isRead: !labelIds.contains('UNREAD'),
          isStarred: labelIds.contains('STARRED'),
        ),
      );
    }

    return messages;
  }

  Future<void> sendMessage({
    required String accessToken,
    required String to,
    required String subject,
    required String body,
  }) async {
    final rawMessage = _buildRawMessage(to: to, subject: subject, body: body);
    final encodedRaw = base64UrlEncode(
      utf8.encode(rawMessage),
    ).replaceAll('=', '');

    final uri = Uri.https(
      'gmail.googleapis.com',
      '/gmail/v1/users/me/messages/send',
    );
    final response = await _client.post(
      uri,
      headers: _headers(accessToken),
      body: jsonEncode({'raw': encodedRaw}),
    );

    if (response.statusCode >= 400) {
      throw Exception('Failed to send Gmail message: ${response.body}');
    }
  }

  String _buildQuery(UserPreferences preferences) {
    final datePart = preferences.summaryType == SummaryType.daily
        ? 'newer_than:1d'
        : 'newer_than:7d';

    switch (preferences.emailFilter) {
      case EmailFilter.all:
        return datePart;
      case EmailFilter.unread:
        return '$datePart is:unread';
      case EmailFilter.starred:
        return '$datePart is:starred';
    }
  }

  Map<String, String> _headers(String accessToken) {
    return <String, String>{
      'Authorization': 'Bearer $accessToken',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
  }

  String _buildRawMessage({
    required String to,
    required String subject,
    required String body,
  }) {
    return 'To: $to\r\n'
        'Subject: $subject\r\n'
        'Content-Type: text/plain; charset=utf-8\r\n'
        '\r\n'
        '$body';
  }
}
