// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:staff_performance_mapping/main.dart';
import 'package:staff_performance_mapping/providers/auth_provider.dart';

void main() {
  testWidgets('MyApp widget test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
        ],
        child: MyApp(),
      ),
    );

    // Verify that the app starts with the AuthWrapper
    expect(find.byType(AuthWrapper), findsOneWidget);

    // You can add more specific tests here based on your AuthWrapper's behavior
    // For example, you might want to test if it shows a login screen when there's no user
    // or if it shows the appropriate screen based on the user's role.
  });
}
