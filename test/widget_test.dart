import 'package:flutter_test/flutter_test.dart';
import 'package:noor_islamic/main.dart';

void main() {
  testWidgets('App launches', (WidgetTester tester) async {
    await tester.pumpWidget(const NoorIslamicApp());
    expect(find.text('Noor Islamic'), findsAny);
  });
}
