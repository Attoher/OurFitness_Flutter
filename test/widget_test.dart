import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ourfitness/screens/login_screen.dart';

void main() {
  testWidgets('login screen renders primary actions', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    expect(find.text('Welcome\nBack'), findsOneWidget);
    expect(find.text('Sign In'), findsWidgets);
    expect(find.text('Forgot Password?'), findsOneWidget);
  });
}
