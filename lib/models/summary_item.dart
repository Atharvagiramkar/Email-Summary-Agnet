class SummaryItem {
  const SummaryItem({
    required this.id,
    required this.batchIndex,
    required this.content,
    required this.createdAt,
    required this.read,
    this.isBookmarked = false,
    this.emailIds = const [],
  });

  final String id;
  final int batchIndex;
  final String content;
  final DateTime createdAt;
  final bool read;
  final bool isBookmarked;
  final List<String> emailIds;

  SummaryItem copyWith({bool? read, bool? isBookmarked}) {
    return SummaryItem(
      id: id,
      batchIndex: batchIndex,
      content: content,
      createdAt: createdAt,
      read: read ?? this.read,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      emailIds: emailIds,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'batchIndex': batchIndex,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'read': read,
      'isBookmarked': isBookmarked,
      'emailIds': emailIds,
    };
  }

  factory SummaryItem.fromMap(Map<String, dynamic> map) {
    return SummaryItem(
      id: map['id']?.toString() ?? '',
      batchIndex: (map['batchIndex'] as num?)?.toInt() ?? 1,
      content: map['content']?.toString() ?? '',
      createdAt:
          DateTime.tryParse(map['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      read: map['read'] as bool? ?? false,
      isBookmarked: map['isBookmarked'] as bool? ?? false,
      emailIds: (map['emailIds'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
    );
  }
}
