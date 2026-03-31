import 'package:employee_engagement_app/providers/auth_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:employee_engagement_app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      EmployeeEngagementApp(authProvider: AuthProvider()),
    );
    expect(find.text('EngageHub'), findsAny);
  });
}
