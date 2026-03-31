import 'package:flutter_test/flutter_test.dart';

import 'package:emailsummaryagent/main.dart';

void main() {
  testWidgets('App starts and shows auth screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Email Summary Agent'), findsOneWidget);
  });
}
