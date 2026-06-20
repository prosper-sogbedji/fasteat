import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fasteat_dashboard/screens/auth/login_screen.dart';

void main() {
  testWidgets('L\'écran de connexion affiche le formulaire', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
    await tester.pump();

    expect(find.text('Connexion'), findsOneWidget);
    expect(find.text('SE CONNECTER'), findsOneWidget);
  });
}
