import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_mercadito/screens/providers_screen.dart';

void main() {
  testWidgets('ProvidersScreen renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ProvidersScreen(),
      ),
    );
    await tester.pumpAndSettle();
  });
}
