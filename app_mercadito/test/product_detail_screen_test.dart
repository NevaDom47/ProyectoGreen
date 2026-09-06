import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_mercadito/screens/product_detail_screen.dart';

void main() {
  testWidgets('ProductDetailScreen allows switching between Detalle and Por Mayor', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final testProduct = {
      'id': 'PROD-TEST-1',
      'name': 'Papa Blanca Alpha',
      'category': 'Tubérculos',
      'saleType': 'ambos',
      'price': '\$18.00',
      'wholesalePrice': '\$14.50',
      'wholesaleMin': '10 LB',
      'unit': 'Unidad',
      'unitConfigs': [
        {'unit': 'Por Libra', 'saleType': 'detalle', 'priceRetail': 18.00, 'isDefault': true},
        {'unit': 'Unidad', 'saleType': 'detalle', 'priceRetail': 18.00, 'isDefault': false},
        {'unit': 'Saco', 'saleType': 'mayor', 'priceWholesale': 280.00, 'wholesaleMin': '2 Saco', 'isDefault': true},
        {'unit': 'Caja', 'saleType': 'mayor', 'priceWholesale': 220.00, 'wholesaleMin': '3 Caja', 'isDefault': false},
      ],
      'img': 'assets/images/PapaGemini.png',
      'photos': ['assets/images/PapaGemini.png'],
    };

    await tester.pumpWidget(
      MaterialApp(
        home: ProductDetailScreen(product: testProduct),
      ),
    );

    // Initial pump & settle past skeleton loading delay (1500ms)
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pumpAndSettle();

    // Verify both switcher tabs exist
    expect(find.text('Detalle'), findsOneWidget);
    expect(find.text('Por Mayor'), findsWidgets);

    // In Detalle mode, retail units are visible
    expect(find.text('Por Libra'), findsOneWidget);
    expect(find.text('Unidad'), findsOneWidget);
    expect(find.text('Saco'), findsNothing);

    // Tap "Por Mayor"
    await tester.tap(find.text('Por Mayor').first);
    await tester.pumpAndSettle();

    // In Por Mayor mode, wholesale units are visible
    expect(find.text('Saco'), findsOneWidget);
    expect(find.text('Caja'), findsOneWidget);
    expect(find.text('Por Libra'), findsNothing);

    // Switch back to "Detalle"
    await tester.tap(find.text('Detalle'));
    await tester.pumpAndSettle();

    // Retail units return
    expect(find.text('Por Libra'), findsOneWidget);
    expect(find.text('Unidad'), findsOneWidget);
    expect(find.text('Saco'), findsNothing);
  });
}
