import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_mercadito/screens/coupons_screen.dart';
import 'package:app_mercadito/services/coupons_service.dart';
import 'package:app_mercadito/theme/app_theme.dart';

void main() {
  setUp(() {
    // Reset service state before each test
    CouponsService.instance.activeBuyerCouponsNotifier.value = [
      CouponsService.instance.coupons.firstWhere((c) => c.code == 'VERDE15'),
      CouponsService.instance.coupons.firstWhere((c) => c.code == 'ORGANICOS'),
    ];
  });

  group('CouponsScreen (Mis Cupones) Integration Tests', () {
    testWidgets('Renders screen with redeem bar, tabs and active coupons',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const CouponsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Mis Cupones'), findsOneWidget);
      expect(find.text('Ingresar código de cupón'), findsOneWidget);
      expect(find.text('Canjear'), findsOneWidget);

      // Check Tabs
      expect(find.textContaining('Activos'), findsOneWidget);
      expect(find.textContaining('Historial'), findsOneWidget);

      // Check active coupons
      expect(find.text('VERDE15'), findsWidgets);
      expect(find.text('ORGANICOS'), findsWidgets);
      expect(find.text('Copiar'), findsWidgets);
    });

    testWidgets('Entering valid coupon code and tapping Canjear adds coupon',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const CouponsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Enter COSECHA10 into text field
      final textField = find.byType(TextField);
      await tester.enterText(textField, 'COSECHA10');
      await tester.pump();

      // Tap Canjear
      await tester.tap(find.text('Canjear'));
      await tester.pumpAndSettle();

      // Verify success SnackBar and new coupon is listed
      expect(find.textContaining('canjeado con éxito'), findsOneWidget);
      expect(find.text('COSECHA10'), findsWidgets);
    });

    testWidgets('Entering invalid coupon code displays error message',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const CouponsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Enter invalid code
      final textField = find.byType(TextField);
      await tester.enterText(textField, 'CODIGO_INVENTADO');
      await tester.pump();

      // Tap Canjear
      await tester.tap(find.text('Canjear'));
      await tester.pumpAndSettle();

      // Verify error SnackBar
      expect(find.textContaining('no es válido o ha expirado'), findsOneWidget);
    });

    testWidgets('Tapping Historial tab displays used coupons with products and dates',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const CouponsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Historial Tab
      await tester.tap(find.textContaining('Historial'));
      await tester.pumpAndSettle();

      // Verify Historial content is shown
      expect(find.text('UTILIZADO'), findsWidgets);
      expect(find.text('PRODUCTOS EN ESTA COMPRA:'), findsWidgets);

      // Verify specific products and stores
      expect(find.textContaining('Manzanas Gala'), findsOneWidget);
      expect(find.textContaining('Tomates de Ensalada'), findsOneWidget);
      expect(find.text('Finca Orgánica Monteverde'), findsOneWidget);
      expect(find.text('#FAC-2026-0089'), findsOneWidget);
      expect(find.textContaining('Ahorro: RD\$ 250'), findsOneWidget);

      // Switch back to Activos
      await tester.tap(find.textContaining('Activos'));
      await tester.pumpAndSettle();
      expect(find.text('Copiar'), findsWidgets);
    });
  });
}
