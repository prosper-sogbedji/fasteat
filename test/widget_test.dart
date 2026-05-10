import 'package:flutter_test/flutter_test.dart';

import 'package:fast_eat/app.dart';

void main() {
  testWidgets('FastEat app launches', (WidgetTester tester) async {
    await tester.pumpWidget(const FastEatApp());
    expect(find.byType(FastEatApp), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 2100));
  });
}
