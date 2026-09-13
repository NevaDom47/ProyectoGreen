import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_mercadito/screens/my_reviews_screen.dart';
import 'package:app_mercadito/theme/app_theme.dart';

void main() {
  testWidgets('MyReviewsScreen displays redesigned negotiated products with review options and tabs', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const MyReviewsScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify AppBar title
    expect(find.text('Mis Reseñas'), findsOneWidget);

    // Verify Hero section content
    expect(find.text('Productos Negociados'), findsOneWidget);
    expect(find.text('Acuerdos Concretados'), findsNothing);
    expect(find.text('Acuerdo Entregado'), findsNothing);

    // Verify Tab headers
    expect(find.text('Pendientes'), findsOneWidget);
    expect(find.text('Completadas'), findsOneWidget);

    // Verify pending items are present
    expect(find.text('Tomates Heirloom'), findsOneWidget);
    expect(find.text('Finca La Esperanza'), findsOneWidget);
    expect(find.text('CANTIDAD'), findsWidgets);
    expect(find.text('PRECIO PACTADO'), findsWidgets);
    expect(find.text('TOTAL ACORDADO'), findsWidgets);
    expect(find.text('Escribir Reseña'), findsWidgets);
    expect(find.text('Acuerdo'), findsWidgets);

    // Open Agreement Details modal
    await tester.tap(find.text('Acuerdo').first);
    await tester.pumpAndSettle();
    expect(find.text('Detalles del Acuerdo'), findsOneWidget);
    expect(find.text('Volumen Negociado'), findsOneWidget);

    // Scroll to action button and tap
    await tester.ensureVisible(find.text('Escribir Reseña para este Acuerdo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Escribir Reseña para este Acuerdo'));
    await tester.pumpAndSettle();

    // Verify Write Review modal opened
    expect(find.text('Calificar Producto'), findsOneWidget);
    expect(find.text('¿CÓMO CALIFICAS ESTE LOTE?'), findsOneWidget);
    expect(find.text('PUNTOS DESTACADOS'), findsOneWidget);
    expect(find.text('Publicar Reseña'), findsOneWidget);

    // Cancel modal
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    // Switch to Completadas tab
    await tester.tap(find.text('Completadas'));
    await tester.pumpAndSettle();

    // Verify completed reviews content
    expect(find.text('Cesta de Verduras Mixtas'), findsOneWidget);
    expect(find.text('Huerta San Miguel'), findsOneWidget);
    expect(find.text('RESPUESTA DEL PRODUCTOR'), findsOneWidget);
  });
}
