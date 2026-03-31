enum SummaryType { daily, weekly }

enum EmailFilter { all, unread, starred }

enum SummaryStyle { formal, casual, bullet }

enum DeliveryMethod { inApp, inbox }

extension SummaryTypeLabel on SummaryType {
  String get label => this == SummaryType.daily ? 'Daily' : 'Weekly';
}

extension EmailFilterLabel on EmailFilter {
  String get label {
    switch (this) {
      case EmailFilter.all:
        return 'All';
      case EmailFilter.unread:
        return 'Unread';
      case EmailFilter.starred:
        return 'Starred';
    }
  }
}

extension SummaryStyleLabel on SummaryStyle {
  String get label {
    switch (this) {
      case SummaryStyle.formal:
        return 'Formal';
      case SummaryStyle.casual:
        return 'Casual';
      case SummaryStyle.bullet:
        return 'Bullet Points';
    }
  }
}

extension DeliveryMethodLabel on DeliveryMethod {
  String get label => this == DeliveryMethod.inApp ? 'In App' : 'In Inbox';
}
