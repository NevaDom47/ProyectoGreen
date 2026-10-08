import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_mercadito/screens/help_support_screen.dart';

void main() {
  testWidgets('HelpSupportScreen renders categories, FAQ tiles, and launches interactive guides without errors', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: HelpSupportScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Verify title and sections
    expect(find.text('Ayuda y Soporte'), findsOneWidget);
    expect(find.text('CATEGORÍAS DE AYUDA'), findsOneWidget);
    expect(find.text('CONSULTAS POPULARES'), findsOneWidget);

    // 2. Verify all 4 category cards
    expect(find.text('Preguntas Frecuentes'), findsOneWidget);
    expect(find.text('Guía para Compradores'), findsOneWidget);
    expect(find.text('Guía para Vendedores'), findsOneWidget);
    expect(find.text('Seguridad y Denuncias'), findsOneWidget);

    // 3. Test tapping "Guía para Compradores" opens modal bottom sheet
    await tester.tap(find.text('Guía para Compradores'));
    await tester.pumpAndSettle();

    expect(find.text('Proceso de Compra'.toUpperCase()), findsOneWidget);
    expect(find.text('FLUJO RÁPIDO DEL PROCESO'), findsOneWidget);
    expect(find.text('Explora en el Mapa y Catálogo'), findsOneWidget);

    // Close the sheet
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'After closing buyer guide');

    // 4. Test tapping "Guía para Vendedores" opens modal bottom sheet
    await tester.tap(find.text('Guía para Vendedores'));
    await tester.pumpAndSettle();

    expect(find.text('Proceso de Venta'.toUpperCase()), findsOneWidget);
    expect(find.text('Publica con Catálogo Estandarizado'), findsOneWidget);

    // Close the sheet
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'After closing seller guide');

    // 5. Test tapping "Seguridad y Denuncias" opens modal bottom sheet
    await tester.tap(find.text('Seguridad y Denuncias'));
    await tester.pumpAndSettle();

    expect(find.text('Confianza Mercadito'.toUpperCase()), findsOneWidget);
    expect(find.text('Verificación de Identidad y Negocio'), findsOneWidget);

    // Close the sheet
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'After closing security guide');

    // 5. Test expanding FAQ tile
    final faqFinder = find.text('¿Cómo negociar un precio?');
    await tester.scrollUntilVisible(
      faqFinder,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    await tester.tap(faqFinder);
    await tester.pumpAndSettle();

    expect(find.text('PASOS RÁPIDOS:'), findsOneWidget);
    expect(find.text('Ir a Mis Negociaciones'), findsOneWidget);
    expect(tester.takeException(), isNull, reason: 'After expanding FAQ');

    // 6. Test Live Chat support sheet
    final chatBtnFinder = find.text('Chat en vivo');
    await tester.scrollUntilVisible(
      chatBtnFinder,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    await tester.tap(chatBtnFinder);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'After opening chat support sheet');

    expect(find.text('Canales de Atención Directa'), findsOneWidget);
    expect(find.text('Chat con Asesor en la App'), findsOneWidget);
    expect(find.text('Línea Directa / WhatsApp'), findsOneWidget);

    // Close the support sheet
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();

    // Verify no exception occurred
    final ex = tester.takeException();
    if (ex != null) {
      debugPrint('TEST EXCEPTION DETECTED: $ex');
      if (ex is FlutterError) {
        debugPrint(ex.toStringDeep());
      }
    }
    expect(ex, isNull);
  });
}
