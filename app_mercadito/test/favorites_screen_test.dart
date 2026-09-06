import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_mercadito/screens/favorites_screen.dart';

void main() {
  testWidgets('FavoritesScreen displays rich product cards with sales mode switcher and no overflow', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: FavoritesScreen(),
      ),
    );

    // Initial loading shimmer
    await tester.pump(const Duration(milliseconds: 1600));

    // Check title
    expect(find.text('Mis Favoritos'), findsOneWidget);

    // Check metadata rows from Image 1 design
    expect(find.text('CALIDAD'), findsWidgets);
    expect(find.text('PROVEEDOR'), findsWidgets);
    expect(find.text('UBICACIÓN'), findsWidgets);

    // Check action button
    expect(find.text('AGREGAR AL CARRITO'), findsWidgets);

    // Check switcher items
    expect(find.text('Detalle'), findsWidgets);
    expect(find.text('Por Mayor'), findsWidgets);

    // Tap 'Por Mayor' on the first product card
    await tester.tap(find.text('Por Mayor').first);
    await tester.pumpAndSettle();

    // Verify inline unit format like / por mayor
    expect(find.textContaining('/ por mayor'), findsWidgets);

    // Check GridView has 2 columns
    final gridFinder = find.byType(GridView);
    expect(gridFinder, findsOneWidget);
    final GridView gridView = tester.widget(gridFinder);
    final delegate = gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
    expect(delegate.crossAxisCount, 2);
  });

  testWidgets('FavoritesScreen displays 2 columns on mobile screen size without overflow', (WidgetTester tester) async {
    // 375x812 iPhone standard size
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: FavoritesScreen(),
      ),
    );

    // Complete loading state
    await tester.pump(const Duration(milliseconds: 1600));

    expect(find.byType(GridView), findsOneWidget);
    expect(find.text('CALIDAD'), findsWidgets);
    expect(find.text('AGREGAR AL CARRITO'), findsWidgets);

    // Verify retail_only and wholesale_only products appear
    expect(find.text('Solo al Detalle'), findsWidgets);
    expect(find.text('Zanahoria Orgánica'), findsWidgets);

    await tester.drag(find.byType(GridView), const Offset(0, -300));
    await tester.pumpAndSettle();

    expect(find.text('Solo por Mayor'), findsWidgets);
    expect(find.text('Saco de Papas Blancas'), findsWidgets);

    expect(tester.takeException(), isNull);
  });
}
