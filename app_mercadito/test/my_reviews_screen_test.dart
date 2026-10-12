import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_mercadito/screens/my_reviews_screen.dart';
import 'package:app_mercadito/theme/app_theme.dart';
import 'package:app_mercadito/services/user_session.dart';

void main() {
  setUp(() {
    UserSession.selectedRole = 'comprador';
  });

  tearDown(() {
    UserSession.selectedRole = 'comprador';
  });

  testWidgets('MyReviewsScreen displays redesigned negotiated products with review options and tabs for buyer', (WidgetTester tester) async {
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
    expect(find.text('#NEG-00001'), findsOneWidget);
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
    expect(find.text('#NEG-00001'), findsWidgets); // Modal badge also shows #NEG-00001
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

  testWidgets('3-day rule blocks premature review and explains waiting period', (WidgetTester tester) async {
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

    // #NEG-00002 (Miel Silvestre) has daysSinceCompleted: 1 (< 3 days)
    expect(find.text('Miel Silvestre'), findsOneWidget);
    expect(find.textContaining('Disponible en 2 días'), findsWidgets);

    // Tap on the locked button
    await tester.tap(find.textContaining('Disponible en 2 días').first);
    await tester.pumpAndSettle();

    // Verify warning dialog is displayed
    expect(find.text('Reseña en Espera'), findsOneWidget);
    expect(find.textContaining('Para evitar abusos y garantizar que hayas podido comprobar la calidad del producto'), findsOneWidget);

    // Dismiss dialog
    await tester.tap(find.text('Entendido'));
    await tester.pumpAndSettle();
    expect(find.text('Reseña en Espera'), findsNothing);
  });

  testWidgets('Provider role displays Por Responder tab and allows replying to client review', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    UserSession.selectedRole = 'proveedor';

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const MyReviewsScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Provider Hero and Tabs
    expect(find.text('Reseñas de Clientes'), findsOneWidget);
    expect(find.text('Por Responder'), findsOneWidget);
    expect(find.text('Respondidas'), findsOneWidget);

    // Verify Provider Pending Card
    expect(find.text('Respuesta Pendiente'), findsOneWidget);
    expect(find.text('Mariana Ortiz'), findsOneWidget);
    expect(find.text('Responder'), findsOneWidget);

    // Tap Responder button
    await tester.tap(find.text('Responder'));
    await tester.pumpAndSettle();

    // Verify reply bottom sheet
    expect(find.text('Responder a Mariana Ortiz'), findsOneWidget);
    expect(find.text('Tu Respuesta Pública'), findsOneWidget);

    // Enter reply text
    await tester.enterText(find.byType(TextField).last, 'Muchas gracias por su preferencia, con gusto seguiremos atendiéndole.');
    await tester.pumpAndSettle();

    // Tap Publicar Respuesta
    await tester.tap(find.text('Publicar Respuesta'));
    await tester.pumpAndSettle();

    // Verify SnackBar confirmation
    expect(find.textContaining('¡Tu respuesta ha sido publicada'), findsOneWidget);
  });
}
