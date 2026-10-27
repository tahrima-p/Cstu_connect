import 'package:flutter_test/flutter_test.dart';
import 'package:cstu_connect/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const CSTUConnectApp());
    expect(find.text('CSTU Connect'), findsWidgets);
  });
}
