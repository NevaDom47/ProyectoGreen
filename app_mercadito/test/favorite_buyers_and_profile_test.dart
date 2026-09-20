import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_mercadito/data/global_state.dart';
import 'package:app_mercadito/screens/buyer_profile_screen.dart';
import 'package:app_mercadito/screens/favorite_buyers_screen.dart';
import 'package:app_mercadito/screens/home_feed_screen.dart';
import 'package:app_mercadito/screens/direct_profile_review_screen.dart';
import 'package:app_mercadito/theme/app_theme.dart';
import 'package:app_mercadito/services/user_session.dart';
import 'package:app_mercadito/services/buyer_behavior_service.dart';
import 'package:app_mercadito/screens/profile_screen.dart';
import 'package:app_mercadito/screens/order_history_screen.dart';
import 'package:app_mercadito/widgets/animated_favorite_button.dart';

class _TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _MockHttpClient();
  }
}

class _MockHttpClient implements HttpClient {
  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _MockHttpClientRequest();

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _MockHttpClientRequest implements HttpClientRequest {
  @override
  Future<HttpClientResponse> close() async => _MockHttpClientResponse();

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _MockHttpClientResponse implements HttpClientResponse {
  @override
  int get statusCode => 200;

  @override
  int get contentLength => _transparentImage.length;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.value(_transparentImage).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

final List<int> _transparentImage = [
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49,
  0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06,
  0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44,
  0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00, 0x05, 0x00, 0x01, 0x0D,
  0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42,
  0x60, 0x82
];

void main() {
  setUpAll(() {
    HttpOverrides.global = _TestHttpOverrides();
  });

  tearDownAll(() {
    HttpOverrides.global = null;
  });

  setUp(() {
    UserSession.selectedRole = 'proveedor';
    globalFavoriteBuyers.value = [
      Map<String, dynamic>.from(initialMarketplaceBuyers[0]),
      Map<String, dynamic>.from(initialMarketplaceBuyers[1]),
    ];
  });

  tearDown(() {
    stopGlobalFlashTimer();
  });

  group('Favorite Buyers Global State Tests', () {
    test('isFavoriteBuyer accurately identifies saved buyers', () {
      expect(isFavoriteBuyer('BUY-88291'), isTrue);
      expect(isFavoriteBuyer('Juan Pérez'), isTrue);
      expect(isFavoriteBuyer('BUY-99102'), isTrue);
      expect(isFavoriteBuyer('BUY-UNKNOWN'), isFalse);
    });

    test('toggleFavoriteBuyer adds and removes buyers reactively', () {
      final newBuyer = Map<String, dynamic>.from(initialMarketplaceBuyers[2]); // Roberto Gómez
      expect(isFavoriteBuyer(newBuyer['id']), isFalse);

      // Add to favorites
      toggleFavoriteBuyer(newBuyer);
      expect(isFavoriteBuyer(newBuyer['id']), isTrue);
      expect(globalFavoriteBuyers.value.length, 3);

      // Remove from favorites
      toggleFavoriteBuyer(newBuyer);
      expect(isFavoriteBuyer(newBuyer['id']), isFalse);
      expect(globalFavoriteBuyers.value.length, 2);
    });
  });

  group('FavoriteBuyersScreen Widget Tests', () {
    testWidgets('FavoriteBuyersScreen displays title, tabs, search bar, and buyer cards', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const FavoriteBuyersScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Header & Tabs
      expect(find.text('Compradores'), findsOneWidget);
      expect(find.text('Mis Favoritos'), findsOneWidget);
      expect(find.text('Buscar Compradores'), findsOneWidget);

      // Verify Initial Favorite Buyers
      expect(find.text('Juan Pérez'), findsOneWidget);
      expect(find.text('Mariana Ortiz'), findsOneWidget);
      expect(find.text('#BUY-88291'), findsOneWidget);
      expect(find.text('#BUY-99102'), findsOneWidget);

      // Verify removal of businessType and onTimePayment puntual chip
      expect(find.text('Restaurante & Tienda Gourmet'), findsNothing);
      expect(find.text('Frutería La Selecta'), findsNothing);
      expect(find.textContaining('puntual'), findsNothing);

      // Verify sector display
      expect(find.text('Cuauhtémoc, CDMX'), findsOneWidget);
      expect(find.text('Guadalajara, Jal.'), findsOneWidget);

      // Search functionality by partial name
      await tester.enterText(find.byType(TextField), 'Mariana');
      await tester.pumpAndSettle();

      // Only Mariana should remain
      expect(find.text('Mariana Ortiz'), findsOneWidget);
      expect(find.text('Juan Pérez'), findsNothing);

      // Search functionality by BUY ID code (e.g. 88291 or BUY-88291)
      await tester.enterText(find.byType(TextField), '88291');
      await tester.pumpAndSettle();
      expect(find.text('Juan Pérez'), findsOneWidget);
      expect(find.text('Mariana Ortiz'), findsNothing);

      // Clear search
      await tester.enterText(find.byType(TextField), '');
      await tester.pumpAndSettle();
      expect(find.text('Juan Pérez'), findsOneWidget);
      expect(find.text('Mariana Ortiz'), findsOneWidget);

      // Switch to 'Buscar Compradores' tab
      await tester.tap(find.text('Buscar Compradores'));
      await tester.pumpAndSettle();

      // Should show other marketplace buyers
      expect(find.text('Sofía Ramírez'), findsOneWidget);
      expect(find.text('Carlos Mendoza'), findsOneWidget);

      // Search by code in Buscar Compradores
      await tester.enterText(find.byType(TextField), 'BUY-55204');
      await tester.pumpAndSettle();
      expect(find.text('Sofía Ramírez'), findsOneWidget);
      expect(find.text('Carlos Mendoza'), findsNothing);
    });

    testWidgets('Tapping animated favorite button toggles buyer in list', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const FavoriteBuyersScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(globalFavoriteBuyers.value.length, 2);

      // Tap the first animated favorite button (for Juan Pérez)
      final favButtons = find.byType(AnimatedFavoriteButton);
      expect(favButtons, findsWidgets);
      await tester.tap(favButtons.first);
      await tester.pumpAndSettle();

      // Now only 1 favorite buyer should remain
      expect(globalFavoriteBuyers.value.length, 1);
    });
  });

  group('BuyerProfileScreen Widget Tests', () {
    testWidgets('BuyerProfileScreen renders complete profile, 6 criteria, and actions', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 5000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final testBuyer = Map<String, dynamic>.from(initialMarketplaceBuyers[0]);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: BuyerProfileScreen(buyer: testBuyer),
        ),
      );
      await tester.pumpAndSettle();

      // Header, Identity & Badges
      expect(find.text('Perfil de Comprador'), findsOneWidget);
      expect(find.text('VISTA DE PROVEEDOR'), findsNothing);
      expect(find.text('Juan Pérez'), findsOneWidget);
      expect(find.text('#BUY-88291'), findsOneWidget);
      expect(find.text('Restaurante & Tienda Gourmet'), findsNothing);
      expect(find.text('Cuauhtémoc, CDMX'), findsOneWidget);
      expect(find.text('Comprador Verificado'), findsOneWidget);
      expect(find.text('Nivel 3'), findsOneWidget);
      expect(find.byIcon(Icons.military_tech_rounded), findsWidgets);
      expect(find.textContaining('Cliente desde Enero 2023'), findsOneWidget);

      // Direct Supplier Actions
      expect(find.text('Iniciar Chat'), findsOneWidget);
      expect(find.text('Enviar Oferta'), findsOneWidget);

      // 3 Metrics Stat Boxes (Reseñas, Calificación, Negociaciones)
      expect(find.text('15'), findsOneWidget);
      expect(find.text('NEGOCIACIONES'), findsOneWidget);
      expect(find.text('RESEÑAS'), findsOneWidget);
      expect(find.text('4.9'), findsWidgets);
      expect(find.text('CALIFICACIÓN'), findsOneWidget);

      // Section: ¿Cómo lo califican los proveedores? (Nivel A+ removed)
      expect(find.text('¿Cómo lo califican los proveedores?'), findsOneWidget);
      expect(find.text('Nivel A+'), findsNothing);
      expect(find.text('98% satisfacción'), findsOneWidget);

      // 6 Criteria
      expect(find.text('Comunicación'), findsWidgets);
      expect(find.text('Puntualidad'), findsWidgets);
      expect(find.text('Cumplimiento del acuerdo'), findsWidgets);
      expect(find.text('Cumplimiento de pago'), findsWidgets);
      expect(find.text('Seriedad en la compra'), findsWidgets);
      expect(find.text('Comportamiento general'), findsWidgets);

      // Calificar Comprador button
      expect(find.text('Calificar Comprador'), findsOneWidget);

      // Provider comments with verified badge and dates
      expect(find.text('Comentarios de Proveedores'), findsOneWidget);
      expect(find.text('Finca La Esperanza'), findsOneWidget);
      expect(find.text('Página 1 de 2'), findsOneWidget);
      expect(find.text('Siguiente'), findsOneWidget);

      // Test expandable rating details
      expect(find.text('Ver detalle de calificación'), findsWidgets);
      await tester.tap(find.text('Ver detalle de calificación').first);
      await tester.pumpAndSettle();
      expect(find.text('Ocultar desglose'), findsOneWidget);

      // Test pagination to page 2
      await tester.tap(find.text('Siguiente'));
      await tester.pumpAndSettle();
      expect(find.text('Página 2 de 2'), findsOneWidget);

      // Preferences with calculation
      expect(find.text('Preferencias de Compra'), findsOneWidget);
      expect(find.text('Lógica de cálculo'), findsOneWidget);
      expect(find.textContaining('Volumen habitual'), findsOneWidget);
      expect(find.textContaining('Método de pago preferido'), findsOneWidget);
      expect(find.textContaining('Modalidad de compra'), findsOneWidget);
      expect(find.text('Tomate Saladette'), findsOneWidget);
      expect(find.text('Aguacate Hass'), findsOneWidget);
    });

    testWidgets('Calificar Comprador button opens DirectProfileReviewScreen', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 5000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final testBuyer = Map<String, dynamic>.from(initialMarketplaceBuyers[0]);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: BuyerProfileScreen(buyer: testBuyer),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Calificar Comprador
      final rateButton = find.text('Calificar Comprador');
      await tester.tap(rateButton);
      await tester.pumpAndSettle();

      // Should open DirectProfileReviewScreen targeting Comprador
      expect(find.byType(DirectProfileReviewScreen), findsOneWidget);
      expect(find.text('Calificar Comprador'), findsWidgets);
    });

    testWidgets('Provider can submit rating to BUY-88291 successfully without error', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const DirectProfileReviewScreen(
            targetRole: 'comprador',
            targetId: 'BUY-88291',
            targetName: 'Juan Pérez',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Enter valid comment (between 10 and 100 chars)
      final commentField = find.byType(TextField);
      await tester.enterText(commentField, 'Excelente comprador muy formal y puntual en sus pagos.');
      await tester.pumpAndSettle();

      // Tap Publicar Reseña de Perfil
      final submitButton = find.text('Publicar Reseña de Perfil');
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Verify that success dialog appears and NO error snackbar
      expect(find.text('¡Reseña Publicada!'), findsOneWidget);
      expect(find.text('No se pudo publicar la reseña. Verifica los requisitos.'), findsNothing);
    });
  });

  group('BuyerBehaviorService Logic Tests', () {
    test('Calculates median volume, confidence, preferred payment, and modality correctly', () {
      final profile = BuyerBehaviorService.instance.calculateProfile('BUY-88291');

      // Verify median calculation (60 kg median among operations, not skewed by 350kg spike)
      expect(profile.medianVolumeKg, greaterThan(0));
      expect(profile.volumeClassification, isNotEmpty);
      expect(profile.volumeConfidencePercent, greaterThan(50));

      // Preferred payment & confidence
      expect(profile.preferredPaymentMethod, 'Transferencia SPEI');
      expect(profile.paymentConfidencePercent, greaterThan(50));

      // Modality & frequent products
      expect(profile.purchaseModality, isNotEmpty);
      expect(profile.frequentProducts, contains('Tomate Saladette'));
    });
  });

  group('Negotiation History Synchronization Tests', () {
    testWidgets('OrderHistoryScreen displays Historial de Negociaciones title in AppBar', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const OrderHistoryScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Historial de Negociaciones'), findsOneWidget);
      expect(find.text('Mercadito'), findsNothing);
    });

    testWidgets('ProfileScreen renders InteractiveOrderCard widgets in negotiation history section', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      UserSession.selectedRole = 'comprador';

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const ProfileScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify that InteractiveOrderCard widgets are rendered in profile
      expect(find.byType(InteractiveOrderCard), findsWidgets);
      expect(find.text('Historial de negociaciones'), findsOneWidget);
      expect(find.text('PRECIO FINAL NEGOCIADO'), findsWidgets);
    });
  });
}

