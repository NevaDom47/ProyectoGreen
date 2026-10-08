import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_mercadito/models/standard_catalog_product.dart';
import 'package:app_mercadito/services/standard_product_catalog_service.dart';
import 'package:app_mercadito/screens/add_product_screen.dart';

void main() {
  group('StandardProductCatalogService & Models Unit Tests', () {
    final catalogService = StandardProductCatalogService.instance;

    test('Catalog contains required standardized agricultural products', () {
      expect(catalogService.allProducts.isNotEmpty, isTrue);
      expect(catalogService.isValidProductName('Tomate Saladette'), isTrue);
      expect(catalogService.isValidProductName('Aguacate Hass'), isTrue);
      expect(catalogService.isValidProductName('Limón Colima'), isTrue);
      expect(catalogService.isValidProductName('Papa Blanca Alpha'), isTrue);
    });

    test('Rejects arbitrary non-catalog product names', () {
      expect(catalogService.isValidProductName('Producto Inventado 123'), isFalse);
      expect(catalogService.isValidProductName('Caramelo Super'), isFalse);
      expect(catalogService.isValidProductName(''), isFalse);
      expect(catalogService.isValidProductName(null), isFalse);
    });

    test('Search filters by query and aliases', () {
      final tomateResults = catalogService.searchProducts('tomate');
      expect(tomateResults.any((p) => p.name == 'Tomate Saladette'), isTrue);

      final hassResults = catalogService.searchProducts('hass');
      expect(hassResults.any((p) => p.name == 'Aguacate Hass'), isTrue);

      final limonSemilla = catalogService.searchProducts('sin semilla');
      expect(limonSemilla.any((p) => p.name == 'Limón Persa'), isTrue);
    });

    test('Price evaluation correctly identifies Caro, Justo and Barato', () {
      final tomate = catalogService.findProductByName('Tomate Saladette')!;
      expect(tomate.referenceRetailPrice, 28.50);
      expect(tomate.referenceWholesalePrice, 22.00);

      // Precio Caro (> +15%)
      // 28.50 * 1.25 = 35.625
      final expensiveEval = tomate.evaluatePrice(36.00, isWholesale: false);
      expect(expensiveEval.status, PriceMarketStatus.expensive);
      expect(expensiveEval.isExpensive, isTrue);
      expect(expensiveEval.title, contains('Caro'));

      // Precio Justo / Competitivo (en rango [-15%, +15%])
      final fairEval = tomate.evaluatePrice(29.00, isWholesale: false);
      expect(fairEval.status, PriceMarketStatus.fair);
      expect(fairEval.isFair, isTrue);
      expect(fairEval.title, contains('competitivo'));

      // Precio Barato / Oferta (< -15%)
      // 28.50 * 0.80 = 22.80
      final cheapEval = tomate.evaluatePrice(20.00, isWholesale: false);
      expect(cheapEval.status, PriceMarketStatus.cheap);
      expect(cheapEval.isCheap, isTrue);
      expect(cheapEval.title, contains('Económico'));
    });

    test('Price evaluation works for wholesale reference', () {
      final papa = catalogService.findProductByName('Papa Blanca Alpha')!;
      // Wholesale ref = 18.00
      final wholesaleExpensive = papa.evaluatePrice(25.00, isWholesale: true);
      expect(wholesaleExpensive.status, PriceMarketStatus.expensive);

      final wholesaleCheap = papa.evaluatePrice(12.00, isWholesale: true);
      expect(wholesaleCheap.status, PriceMarketStatus.cheap);
    });
  });

  group('AddProductScreen Standardized Catalog & Price Intelligence Widget Tests', () {
    testWidgets('AddProductScreen renders standardized catalog picker and suggestion box', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: AddProductScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Screen Title and Field Label
      expect(find.text('Agregar Producto'), findsOneWidget);
      expect(find.text('NOMBRE DEL PRODUCTO *'), findsOneWidget);
      expect(find.text('Ver Catálogo Oficial'), findsOneWidget);

      // Verify typing in product name filters suggestions
      final nameField = find.byType(TextFormField).first;
      await tester.enterText(nameField, 'Aguacate');
      await tester.pumpAndSettle();

      // Suggestion box should appear with Aguacate Hass
      expect(find.textContaining('Aguacate Hass'), findsWidgets);

      // Verify trailing check circle outline is removed per user request
      expect(find.byIcon(Icons.check_circle_outline), findsNothing);

      // Tap suggestion to select
      await tester.tap(find.text('Aguacate Hass').first);
      await tester.pumpAndSettle();

      // Now it should show the official verified badge
      expect(find.text('Oficial'), findsOneWidget);
      expect(find.text('Cambiar'), findsOneWidget);
      expect(find.text('Frutas'), findsWidgets);
    });

    testWidgets('AddProductScreen typing tom filters suggestions without check icon and tapping selects Tomate Saladette', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: AddProductScreen(),
        ),
      );
      await tester.pumpAndSettle();

      final nameField = find.byType(TextFormField).first;
      await tester.enterText(nameField, 'tom');
      await tester.pumpAndSettle();

      // Should show suggestions for Tomate Saladette and Tomate Bola
      expect(find.text('Tomate Saladette'), findsOneWidget);
      expect(find.text('Tomate Bola'), findsOneWidget);

      // Trailing check icon must NOT be present
      expect(find.byIcon(Icons.check_circle_outline), findsNothing);

      // Tap Tomate Saladette suggestion
      await tester.tap(find.text('Tomate Saladette'));
      await tester.pumpAndSettle();

      // Verified banner with Oficial and Cambiar must be visible
      expect(find.text('Oficial'), findsOneWidget);
      expect(find.text('Cambiar'), findsOneWidget);

      // Category should be updated to Hortalizas
      expect(find.text('Hortalizas'), findsWidgets);
    });

    testWidgets('AddProductScreen in Edit Mode pre-populates standardized product and market intelligence', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final initialProduct = {
        'id': 'PROD-TOM-01',
        'name': 'Tomate Saladette',
        'category': 'Hortalizas',
        'badge': 'Primera Calidad',
        'priceNum': 42.00, // Caro frente a ref de 28.50 (+47%)
        'unit': 'LB',
        'unitConfigs': [
          {
            'unit': 'LB',
            'saleType': 'detalle',
            'priceRetail': 42.00,
            'isDefault': true,
          }
        ],
      };

      await tester.pumpWidget(
        MaterialApp(
          home: AddProductScreen(initialProduct: initialProduct),
        ),
      );
      await tester.pumpAndSettle();

      // Verify title is Editar Producto
      expect(find.text('Editar Producto'), findsOneWidget);

      // Verify official badge is active
      expect(find.text('Oficial'), findsOneWidget);

      // Verify Market Price Advisor identifies it as Caro
      expect(find.textContaining('Caro'), findsWidgets);
      expect(find.text('PROMEDIO MERCADO'), findsOneWidget);
      expect(find.textContaining('28.50'), findsWidgets);

      // Test "Alinear con Precio Sugerido de Mercado" button
      final alignButton = find.textContaining('Alinear con Precio Sugerido de Mercado');
      expect(alignButton, findsOneWidget);

      await tester.tap(alignButton);
      await tester.pumpAndSettle();

      // After aligning, status should change to Competitivo / Justo
      expect(find.textContaining('Competitivo'), findsWidgets);
    });

    testWidgets('Catalog modal bottom sheet opens and allows picking a product', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: AddProductScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Open catalog modal
      await tester.tap(find.text('Ver Catálogo Oficial'));
      await tester.pumpAndSettle();

      // Verify modal opened
      expect(find.text('Catálogo Oficial Estandarizado'), findsOneWidget);
      expect(find.text('Todas'), findsOneWidget);
      expect(find.text('Hortalizas'), findsWidgets);

      // Select 'Limón Colima' or 'Tomate Saladette'
      expect(find.text('Tomate Saladette'), findsWidgets);
      await tester.tap(find.text('Tomate Saladette').first);
      await tester.pumpAndSettle();

      // Modal closed and product selected
      expect(find.text('Catálogo Oficial Estandarizado'), findsNothing);
      expect(find.text('Tomate Saladette'), findsWidgets);
      expect(find.text('Oficial'), findsOneWidget);
    });

    testWidgets('AddProductScreen blocks saving when an arbitrary non-standard name is entered', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: AddProductScreen(),
        ),
      );
      await tester.pumpAndSettle();

      final nameField = find.byType(TextFormField).first;
      await tester.enterText(nameField, 'Producto Arbitrario No Oficial');
      await tester.pumpAndSettle();

      // Tap guardar producto
      final saveBtn = find.text('GUARDAR PRODUCTO');
      await tester.ensureVisible(saveBtn);
      await tester.tap(saveBtn);
      await tester.pumpAndSettle();

      // Form validation error must appear
      expect(find.text('Debes seleccionar obligatoriamente un producto del catálogo oficial'), findsOneWidget);
    });
  });
}
