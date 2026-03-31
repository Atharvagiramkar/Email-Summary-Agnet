import 'package:emailsummaryagent/models/enums.dart';

class UserPreferences {
  const UserPreferences({
    required this.summaryType,
    required this.emailFilter,
    required this.numberOfEmails,
    required this.summaryStyle,
    required this.deliveryMethod,
  });

  final SummaryType summaryType;
  final EmailFilter emailFilter;
  final int numberOfEmails;
  final SummaryStyle summaryStyle;
  final DeliveryMethod deliveryMethod;

  factory UserPreferences.initial() {
    return const UserPreferences(
      summaryType: SummaryType.daily,
      emailFilter: EmailFilter.all,
      numberOfEmails: 5,
      summaryStyle: SummaryStyle.bullet,
      deliveryMethod: DeliveryMethod.inApp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'summaryType': summaryType.name,
      'emailFilter': emailFilter.name,
      'numberOfEmails': numberOfEmails,
      'summaryStyle': summaryStyle.name,
      'deliveryMethod': deliveryMethod.name,
    };
  }

  factory UserPreferences.fromMap(Map<String, dynamic> map) {
    return UserPreferences(
      summaryType: SummaryType.values.firstWhere(
        (value) => value.name == map['summaryType'],
        orElse: () => SummaryType.daily,
      ),
      emailFilter: EmailFilter.values.firstWhere(
        (value) => value.name == map['emailFilter'],
        orElse: () => EmailFilter.all,
      ),
      numberOfEmails: (map['numberOfEmails'] as num?)?.toInt() ?? 5,
      summaryStyle: SummaryStyle.values.firstWhere(
        (value) => value.name == map['summaryStyle'],
        orElse: () => SummaryStyle.bullet,
      ),
      deliveryMethod: DeliveryMethod.values.firstWhere(
        (value) => value.name == map['deliveryMethod'],
        orElse: () => DeliveryMethod.inApp,
      ),
    );
  }
}
