import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_mercadito/router/app_router.dart';
import 'package:app_mercadito/data/global_state.dart';

void main() {
  testWidgets('Navigating from /profile to /favorites via "Ver todos" does not throw assertion error', (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    // Populate mock favorites if empty
    if (globalFavorites.value.isEmpty) {
      globalFavorites.value = [
        {
          'name': 'Papa Blanca Alpha',
          'sku': 'TUB-PAP-01',
          'category': 'Tubérculos',
          'price': '\$18.00',
          'quality': 'Primera Calidad',
          'unit': 'por KG',
          'supplier': 'Don Pedro H.',
          'location': 'Tecomán, Colima',
          'img': 'assets/images/PapaGemini.png',
        },
      ];
    }

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: appRouter,
      ),
    );
    await tester.pumpAndSettle();

    // Navigate to profile
    appRouter.push('/profile');
    await tester.pumpAndSettle();

    // Verify we are on ProfileScreen
    expect(find.text('Mis Favoritos'), findsOneWidget);

    // Find "Ver todos" button
    final verTodosButton = find.text('Ver todos');
    expect(verTodosButton, findsOneWidget);

    // Tap "Ver todos" - this previously threw:
    // Assertion failed: !keyReservation.contains(key)
    await tester.tap(verTodosButton);
    await tester.pumpAndSettle();

    // Verify we navigated to FavoritesScreen without crashing
    expect(find.text('Todos'), findsWidgets);
    expect(tester.takeException(), isNull);

    // Tap back button
    final backButton = find.byIcon(Icons.arrow_back).first;
    await tester.tap(backButton);
    await tester.pumpAndSettle();

    // We should be back on ProfileScreen
    expect(find.text('Mis Favoritos'), findsOneWidget);
  });
}
