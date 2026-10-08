import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_mercadito/screens/splash_screen.dart';
import 'package:app_mercadito/screens/login_screen.dart';
import 'package:app_mercadito/router/app_router.dart';
import 'package:app_mercadito/main.dart';

void main() {
  group('SplashScreen Widget Tests', () {
    testWidgets('SplashScreen renders logo, title, tagline, and skip button', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(),
        ),
      );

      // Verify the essential brand elements exist on screen
      expect(find.text('El Mercadito'), findsOneWidget);
      expect(find.text('Accede a la frescura del campo en un clic'), findsOneWidget);
      expect(find.text('Conexión directa productor - comprador'), findsOneWidget);
      expect(find.text('Saltar'), findsOneWidget);
      expect(find.text('© 2026 El Mercadito S.A.'), findsOneWidget);

      // Verify official logo image is loaded
      final logoFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName.contains('el_mercadito_logo'),
      );
      expect(logoFinder, findsOneWidget);
    });

    testWidgets('SplashScreen renders correctly in dark theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const SplashScreen(),
        ),
      );

      expect(find.text('El Mercadito'), findsOneWidget);
      expect(find.text('Saltar'), findsOneWidget);
    });

    testWidgets('App starts at SplashScreen and transitions to LoginScreen on skip', (tester) async {
      appRouter.go('/splash');
      await tester.pumpWidget(const AppMercadito());
      await tester.pump();

      // Initially at SplashScreen
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.text('El Mercadito'), findsOneWidget);

      // Tapping "Saltar" navigates immediately to LoginScreen
      final skipButton = find.text('Saltar');
      expect(skipButton, findsOneWidget);
      await tester.tap(skipButton);
      await tester.pumpAndSettle();

      // Now at LoginScreen
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.text('Bienvenido de nuevo'), findsOneWidget);
      expect(find.text('Iniciar Sesión'), findsOneWidget);
    });

    testWidgets('SplashScreen automatically transitions to LoginScreen after animation completes', (tester) async {
      appRouter.go('/splash');
      await tester.pumpWidget(const AppMercadito());
      await tester.pump();

      expect(find.byType(SplashScreen), findsOneWidget);

      // Advance time for the 2600ms animation
      await tester.pump(const Duration(milliseconds: 3000));
      await tester.pumpAndSettle();

      // Successfully transitioned to LoginScreen
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.text('Bienvenido de nuevo'), findsOneWidget);
    });

    testWidgets('LoginScreen displays the official El Mercadito logo', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginScreen(),
        ),
      );

      expect(find.text('Bienvenido de nuevo'), findsOneWidget);
      final logoFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName.contains('el_mercadito_logo'),
      );
      expect(logoFinder, findsOneWidget);
    });
  });
}
