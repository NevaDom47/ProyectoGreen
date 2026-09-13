import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_mercadito/screens/negotiation_detail_screen.dart';

void main() {
  testWidgets('NegotiationDetailScreen renders hero, metrics banner, and connected progress traceability without overflow', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final mockNegotiation = {
      'invoice_id': '#FAC-88290',
      'product': 'Tomates Cherry Orgánicos',
      'buyer': 'Juan Pérez',
      'role': 'Comprador',
      'date': '12 Oct 2023',
      'time': '10:45 AM',
      'total': '\$6,750.00',
      'price': '\$45.00 / kg',
      'quantity': '150 kg',
      'image': '',
      'avatar': '',
    };

    await tester.pumpWidget(
      MaterialApp(
        home: NegotiationDetailScreen(negotiation: mockNegotiation),
      ),
    );
    await tester.pumpAndSettle();

    // Verify title and hero section
    expect(find.text('Detalle del acuerdo'), findsOneWidget);
    expect(find.text('¡TRATO HECHO CON ÉXITO!'), findsOneWidget);
    expect(find.text('\$6,750.00'), findsOneWidget);
    expect(find.text('#FAC-88290'), findsOneWidget);

    // Verify product & deal conditions
    expect(find.text('Tomates Cherry Orgánicos'), findsOneWidget);
    expect(find.text('Cosecha directa • Calidad garantizada en entrega'), findsOneWidget);
    expect(find.text('Trazabilidad del Acuerdo Bilateral'), findsOneWidget);
    expect(find.text('Volumen pactado'), findsOneWidget);

    // Verify progress section and mini visual bar
    final progressFinder = find.text('Tu progreso con Juan');
    await tester.scrollUntilVisible(progressFinder, 200);
    await tester.pumpAndSettle();
    expect(progressFinder, findsOneWidget);
    expect(find.textContaining('Trato Concluido'), findsOneWidget);
    expect(find.text('4 de 4 hitos logrados'), findsOneWidget);

    // Verify timeline steps
    expect(find.text('Solicitud inicial recibida'), findsOneWidget);
    expect(find.text('Contraoferta enviada'), findsOneWidget);

    final finalStepFinder = find.text('¡Trato cerrado con éxito!');
    await tester.scrollUntilVisible(finalStepFinder, 200);
    await tester.pumpAndSettle();
    expect(find.text('Negociación por volumen'), findsOneWidget);
    expect(finalStepFinder, findsOneWidget);

    // Verify bottom action buttons
    expect(find.text('COMPROBANTE'), findsOneWidget);
    expect(find.byIcon(Icons.receipt_long_rounded), findsNWidgets(2));

    // Verify no RenderFlex overflow
    expect(tester.takeException(), isNull);
  });
}
