import 'package:flutter_test/flutter_test.dart';
import 'package:troupeau_ovins/main.dart';

void main() {
  testWidgets('App starts correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const TroupeauApp());
    await tester.pump();
    expect(find.text('Troupeau Ovins'), findsWidgets);
  });
}
