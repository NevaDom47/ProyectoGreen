// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_mercadito/main.dart';

import 'package:app_mercadito/widgets/custom_bottom_nav_bar.dart';

void main() {
  testWidgets('AppMercadito smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AppMercadito());
    expect(find.byType(MaterialApp), findsWidgets);
  });

  testWidgets('CustomBottomNavBar displays Inicio, Carrito, Mercado, Proveedores, and Chats', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          bottomNavigationBar: CustomBottomNavBar(currentIndex: 3),
        ),
      ),
    );

    expect(find.text('Inicio'), findsOneWidget);
    expect(find.text('Carrito'), findsOneWidget);
    expect(find.text('Mercado'), findsOneWidget);
    expect(find.text('Proveedores'), findsOneWidget);
    expect(find.text('Chats'), findsOneWidget);
  });
}
