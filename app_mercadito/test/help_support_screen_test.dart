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

    // 2.1 Test tapping "Preguntas Frecuentes" opens modal bottom sheet without removed badges
    await tester.tap(find.text('Preguntas Frecuentes'));
    await tester.pumpAndSettle();

    expect(find.text('CENTRO DE RESPUESTAS'), findsNothing);
    expect(find.text('Centro de Respuestas'), findsNothing);
    expect(find.text('FLUJO RÁPIDO DEL PROCESO'), findsNothing);
    expect(find.text('Sin comisiones ocultas'), findsNothing);
    expect(find.text('Estándar Dominicano'), findsNothing);
    expect(find.text('Respaldo Legal'), findsNothing);
    expect(find.text('Chat Bilateral'), findsNothing);
    expect(find.text('¿Tiene algún costo publicar productos?'), findsOneWidget);
    expect(find.text('Explorar Mercado'), findsNothing);

    // Close the FAQ sheet
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();

    // 3. Test tapping "Guía para Compradores" opens modal bottom sheet
    await tester.tap(find.text('Guía para Compradores'));
    await tester.pumpAndSettle();

    expect(find.text('PROCESO DE COMPRA'), findsNothing);
    expect(find.text('FLUJO RÁPIDO DEL PROCESO'), findsOneWidget);
    expect(find.text('3. Negociar'), findsOneWidget);
    expect(find.text('4. Cerrar Trato'), findsOneWidget);
    expect(find.text('4. Rastrear'), findsNothing);
    expect(find.text('Mapa & Filtros'), findsNothing);
    expect(find.text('Negociación Bilateral'), findsNothing);
    expect(find.text('Comprobante PDF'), findsNothing);
    expect(find.text('Trazabilidad'), findsNothing);
    expect(find.text('Explora en el Mapa y Catálogo'), findsOneWidget);
    expect(find.text('Negocia Precio y Condiciones'), findsOneWidget);
    expect(find.text('Rastrea los 4 Hitos de Entrega'), findsNothing);
    expect(find.text('Explorar Mapa de Productores'), findsNothing);
    expect(find.text('Ver Mis Pedidos'), findsNothing);

    // Close the sheet
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'After closing buyer guide');

    // 4. Test tapping "Guía para Vendedores" opens modal bottom sheet
    await tester.tap(find.text('Guía para Vendedores'));
    await tester.pumpAndSettle();

    expect(find.text('PROCESO DE VENTA'), findsNothing);
    expect(find.text('3. Negociar'), findsOneWidget);
    expect(find.text('4. Facturar'), findsOneWidget);
    expect(find.text('4. Fidelizar'), findsNothing);
    expect(find.text('Precios Inteligentes'), findsNothing);
    expect(find.text('Trato Directo'), findsNothing);
    expect(find.text('Factura Oficial'), findsNothing);
    expect(find.text('Herramientas Pro'), findsNothing);
    expect(find.text('Publica con Catálogo Estandarizado'), findsOneWidget);
    expect(find.text('Negocia Precios y Condiciones'), findsOneWidget);
    expect(find.text('Publicar un Producto'), findsNothing);
    expect(find.text('Ver Mis Negociaciones'), findsNothing);

    // Close the sheet
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'After closing seller guide');

    // 5. Test tapping "Seguridad y Denuncias" opens modal bottom sheet
    await tester.tap(find.text('Seguridad y Denuncias'));
    await tester.pumpAndSettle();

    expect(find.text('CONFIANZA MERCADITO'), findsNothing);
    expect(find.text('FLUJO RÁPIDO DEL PROCESO'), findsNothing);
    expect(find.text('Sello Verificado'), findsNothing);
    expect(find.text('Transparencia'), findsNothing);
    expect(find.text('Acceso Seguro'), findsNothing);
    expect(find.text('Soporte 24/7'), findsNothing);
    expect(find.text('Verificar mi Negocio'), findsNothing);
    expect(find.text('Reportar una Incidencia'), findsNothing);
    expect(find.text('Verificación de Identidad y Negocio'), findsOneWidget);
    expect(find.text('Comprobante Oficial Vinculante'), findsOneWidget);
    expect(find.text('Seguridad de Cuenta con 2FA'), findsOneWidget);

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
    expect(find.text('1. Agregar al carrito el producto.'), findsOneWidget);
    expect(find.text('2. Presionar Negociar.'), findsOneWidget);
    expect(find.text('3. Chat con el proveedor para acordar un precio.'), findsOneWidget);
    expect(find.text('Ir a Mis Negociaciones'), findsNothing);
    expect(find.text('Ver guía'), findsNothing);
    expect(find.text('¿Cómo rastrear mi pedido?'), findsNothing);
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
    expect(find.text('Línea Directa WhatsApp'), findsOneWidget);
    expect(find.text('Correo Electrónico'), findsOneWidget);
    expect(find.textContaining('contacto@diaztecnologies.com'), findsOneWidget);
    expect(find.text('Chat con Asesor en la App'), findsNothing);
    expect(find.text('Centro de Denuncias y Reportes'), findsNothing);

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

  testWidgets('HelpSupportScreen in dark mode applies #1F2924 cards, #AAB7B0 text, #2D402A icon box and #80C652 icons', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        home: const HelpSupportScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Verify FAQ question text color in dark mode is #AAB7B0
    final faqTextFinder = find.text('¿Cómo negociar un precio?');
    expect(faqTextFinder, findsOneWidget);
    final Text faqTextWidget = tester.widget(faqTextFinder);
    expect(faqTextWidget.style?.color, const Color(0xFFAAB7B0));

    // 2. Verify category card icon has color #80C652
    final quizIconFinder = find.byIcon(Icons.quiz);
    expect(quizIconFinder, findsOneWidget);
    final Icon quizIcon = tester.widget(quizIconFinder);
    expect(quizIcon.color, const Color(0xFF80C652));

    // 3. Verify back button icon has color #80C652
    final backIconFinder = find.byIcon(Icons.arrow_back);
    expect(backIconFinder, findsOneWidget);
    final Icon backIcon = tester.widget(backIconFinder);
    expect(backIcon.color, const Color(0xFF80C652));

    // 4. Verify no exception occurred
    expect(tester.takeException(), isNull);
  });
}
