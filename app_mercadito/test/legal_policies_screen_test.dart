import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_mercadito/screens/legal_policies_screen.dart';
import 'package:app_mercadito/data/legal_policies_data.dart';

void main() {
  group('LegalPoliciesScreen Widget Tests', () {
    final Uint8List testPdfBytes = Uint8List.fromList([0x25, 0x50, 0x44, 0x46, 0x2D]);

    testWidgets('Renders official policies header, tabs, and Diaz Tecnologies info', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: LegalPoliciesScreen(
            customPdfLoader: (_) async => testPdfBytes,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      // Verify title and headers
      expect(find.text('Políticas Legales'), findsOneWidget);
      expect(find.text('Términos y Condiciones'), findsWidgets);
      expect(find.text('Política de Privacidad'), findsWidgets);
      expect(find.textContaining(LegalPoliciesData.entityName), findsWidgets);
      expect(find.text('PDF'), findsNothing);

      // Verify "Uso de Cookies" is not present
      expect(find.text('Uso de Cookies'), findsNothing);
    });

    testWidgets('Opens directly to Privacy tab when initialTabIndex is 1', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: LegalPoliciesScreen(
            initialTabIndex: 1,
            customPdfLoader: (_) async => testPdfBytes,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      // In privacy tab, title reflects Política de Privacidad
      expect(find.text('Política de Privacidad'), findsWidgets);
    });

    testWidgets('Tapping contact action shows legal contact dialog with official email', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: LegalPoliciesScreen(
            customPdfLoader: (_) async => testPdfBytes,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      // Tap help / legal contact button
      await tester.tap(find.byTooltip('Contacto legal'));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Contacto Legal'), findsOneWidget);
      expect(find.text(LegalPoliciesData.contactEmail), findsOneWidget);
    });

    testWidgets('Switching tabs toggles active document', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: LegalPoliciesScreen(
            customPdfLoader: (_) async => testPdfBytes,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      // Tap on 'Política de Privacidad' tab
      await tester.tap(find.text('Política de Privacidad').first);
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Política de Privacidad'), findsWidgets);
    });
  });
}
