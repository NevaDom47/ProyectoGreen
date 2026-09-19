import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_mercadito/services/reviews_service.dart';
import 'package:app_mercadito/services/user_session.dart';
import 'package:app_mercadito/screens/direct_profile_review_screen.dart';
import 'package:app_mercadito/screens/provider_profile_screen.dart';
import 'package:app_mercadito/screens/profile_screen.dart';
import 'package:app_mercadito/theme/app_theme.dart';

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
    UserSession.selectedRole = 'comprador';
    ReviewsService.instance.reset();
  });

  group('ReviewsService Business Logic & Rules', () {
    test('3-day rule correctly locks and unlocks review', () {
      final lockedReview = ProductNegotiationReview(
        orderId: 'ORD-1',
        negotiationId: 'NEG-1',
        productName: 'Miel',
        vendor: 'Apicultura',
        buyer: 'Juan',
        imageUrl: '',
        completedDate: DateTime.now().subtract(const Duration(days: 1)),
        formattedCompletedDate: 'Ayer',
        finalPrice: '\$10',
        quantity: '2',
        totalAmount: '\$20',
      );

      expect(lockedReview.isReviewUnlocked, isFalse);
      expect(lockedReview.daysRemaining, 2);

      final unlockedReview = ProductNegotiationReview(
        orderId: 'ORD-2',
        negotiationId: 'NEG-2',
        productName: 'Tomates',
        vendor: 'Finca',
        buyer: 'Juan',
        imageUrl: '',
        completedDate: DateTime.now().subtract(const Duration(days: 4)),
        formattedCompletedDate: 'Hace 4 días',
        finalPrice: '\$2',
        quantity: '100 kg',
        totalAmount: '\$200',
      );

      expect(unlockedReview.isReviewUnlocked, isTrue);
      expect(unlockedReview.daysRemaining, 0);
    });

    test('Direct profile review enforces 10-100 characters limit', () {
      final shortComment = ReviewsService.instance.submitDirectReview(
        authorId: 'BUY-1',
        authorName: 'Comprador 1',
        authorRole: 'comprador',
        targetId: 'PROV-1',
        targetName: 'Proveedor 1',
        targetRole: 'proveedor',
        comment: 'Muy corto', // 9 chars
        scores: {'Recomendación': 5.0},
      );
      expect(shortComment, isFalse);

      final validComment = ReviewsService.instance.submitDirectReview(
        authorId: 'BUY-1',
        authorName: 'Comprador 1',
        authorRole: 'comprador',
        targetId: 'PROV-1',
        targetName: 'Proveedor 1',
        targetRole: 'proveedor',
        comment: 'Excelente calidad y cumplimiento en los tiempos pactados.', // ~57 chars
        scores: {'Recomendación': 5.0, 'Calidad del servicio': 5.0},
      );
      expect(validComment, isTrue);

      // Duplicate prevention: cannot submit twice for the same target
      final duplicateComment = ReviewsService.instance.submitDirectReview(
        authorId: 'BUY-1',
        authorName: 'Comprador 1',
        authorRole: 'comprador',
        targetId: 'PROV-1',
        targetName: 'Proveedor 1',
        targetRole: 'proveedor',
        comment: 'Otro comentario que no debería ser permitido.',
        scores: {'Recomendación': 4.0},
      );
      expect(duplicateComment, isFalse);
    });

    test('Provider reputation aggregates 98% cumplimiento, 93% respuesta rápida, 96% recomendación', () {
      final rep = ReviewsService.getProviderReputation('PROV-1');
      expect(rep['overallRating'], 4.8);
      expect(rep['compliancePercent'], 98);
      expect(rep['fastResponsePercent'], 93);
      expect(rep['recommendationPercent'], 96);
    });

    test('Buyer reputation scores calculate 5 expected criteria for providers view', () {
      final scores = ReviewsService.getBuyerReputation('BUY-88291');
      expect(scores.containsKey('Comunicación'), isTrue);
      expect(scores.containsKey('Cumplimiento'), isTrue);
      expect(scores.containsKey('Puntualidad'), isTrue);
      expect(scores.containsKey('Trato'), isTrue);
      expect(scores.containsKey('Pago'), isTrue);
    });
  });

  group('DirectProfileReviewScreen Widget Tests', () {
    testWidgets('Buyer evaluating Provider renders 7 criteria and validates characters', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const DirectProfileReviewScreen(
            targetRole: 'proveedor',
            targetId: 'PROV-TEST-1',
            targetName: 'Granja El Sol',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Header & Title
      expect(find.text('Calificar Proveedor'), findsOneWidget);
      expect(find.text('Granja El Sol'), findsOneWidget);
      expect(find.textContaining('7 criterios'), findsOneWidget);

      // Criteria items
      expect(find.text('Recomendación'), findsOneWidget);
      expect(find.text('Calidad del servicio'), findsOneWidget);
      expect(find.text('Puntualidad'), findsOneWidget);
      expect(find.text('Comunicación'), findsOneWidget);
      expect(find.text('Cumplimiento'), findsOneWidget);
      expect(find.text('Confiabilidad'), findsOneWidget);
      expect(find.text('Correspondencia con lo ofrecido'), findsOneWidget);

      // Character validation: enter text < 10 chars
      await tester.enterText(find.byType(TextField), 'Corto');
      await tester.pumpAndSettle();
      expect(find.textContaining('Faltan'), findsOneWidget);

      // Enter valid text between 10 and 100 chars
      await tester.enterText(find.byType(TextField), 'Gran proveedor con excelente cumplimiento y productos de primera.');
      await tester.pumpAndSettle();
      expect(find.textContaining('✓ Longitud válida'), findsOneWidget);

      // Submit review
      final submitBtn = find.text('Publicar Reseña de Perfil');
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      // Check confirmation dialog
      expect(find.text('¡Reseña Publicada!'), findsOneWidget);
      expect(find.textContaining('Tu evaluación para Granja El Sol ha sido registrada'), findsOneWidget);
    });

    testWidgets('Provider evaluating Buyer renders 6 criteria', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const DirectProfileReviewScreen(
            targetRole: 'comprador',
            targetId: 'BUY-TEST-1',
            targetName: 'Mariana Ortiz',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Header & Title
      expect(find.text('Calificar Comprador'), findsOneWidget);
      expect(find.text('Mariana Ortiz'), findsOneWidget);
      expect(find.textContaining('6 criterios'), findsOneWidget);

      // Criteria items
      expect(find.text('Comunicación'), findsOneWidget);
      expect(find.text('Puntualidad'), findsOneWidget);
      expect(find.text('Cumplimiento del acuerdo'), findsOneWidget);
      expect(find.text('Cumplimiento de pago'), findsOneWidget);
      expect(find.text('Seriedad en la compra'), findsOneWidget);
      expect(find.text('Comportamiento general'), findsOneWidget);
    });
  });

  group('Provider and Buyer Profile Screens Integration', () {
    testWidgets('ProviderProfileScreen shows reputation breakdown in reviews tab', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const ProviderProfileScreen(
            provider: {
              'name': 'Granja El Sol',
              'id': 'PROV-1',
              'img': '',
              'banner': '',
              'isOwner': false,
            },
          ),
        ),
      );
      // Wait for skeleton timer
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pumpAndSettle();

      // Switch to Reseñas tab
      await tester.tap(find.text('Reseñas'));
      await tester.pumpAndSettle();

      // Verify Provider Reputation Card & Confidence Pillars
      expect(find.text('REPUTACIÓN DEL PROVEEDOR'), findsOneWidget);
      expect(find.text('Cumplimiento'), findsNWidgets(2)); // in pillar badge and criteria breakdown
      expect(find.text('Responde rápido'), findsOneWidget);
      expect(find.text('Lo recomiendan'), findsOneWidget);
      expect(find.text('98%'), findsOneWidget);
      expect(find.text('93%'), findsOneWidget);
      expect(find.text('96%'), findsOneWidget);

      // Verify no duplicate star emoji in reputation score badge
      expect(find.textContaining('4.8 ⭐'), findsNothing);
      expect(find.textContaining('4.8 · 129 reseñas'), findsOneWidget);

      // Verify all 7 exact criteria in breakdown
      expect(find.text('Recomendación'), findsOneWidget);
      expect(find.text('Calidad del servicio'), findsOneWidget);
      expect(find.text('Puntualidad'), findsOneWidget);
      expect(find.text('Comunicación'), findsOneWidget);
      expect(find.text('Confiabilidad'), findsOneWidget);
      expect(find.text('Correspondencia con lo ofrecido'), findsOneWidget);
    });

    testWidgets('ProfileScreen shows "¿Cómo lo califican los proveedores?" section', (WidgetTester tester) async {
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

      // Verify Buyer Profile Reputation Section
      expect(find.text('¿Cómo lo califican los proveedores?'), findsOneWidget);
      expect(find.text('Evaluación directa basada en acuerdos y negociaciones'), findsOneWidget);
      expect(find.text('Comunicación'), findsWidgets);
      expect(find.text('Cumplimiento del acuerdo'), findsWidgets);
      expect(find.text('Puntualidad en citas y recepción'), findsWidgets);
      expect(find.text('Trato y seriedad'), findsWidgets);
      expect(find.text('Cumplimiento de pago'), findsWidgets);
    });

    testWidgets('ProviderProfileScreen shows reputation reviews below product reviews with expandable details and reputation filter', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const ProviderProfileScreen(
            provider: {
              'name': 'Granja El Sol',
              'id': 'PROV-1',
              'img': '',
              'banner': '',
              'isOwner': false,
            },
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pumpAndSettle();

      // Switch to Reseñas tab
      await tester.tap(find.text('Reseñas'));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Scroll down to bring filters and reviews into viewport
      await tester.drag(find.byType(NestedScrollView), const Offset(0, -600));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Check filter options include REPUTACIÓN
      expect(find.text('REPUTACIÓN'), findsOneWidget);
      expect(find.text('MÁS RECIENTES'), findsOneWidget);

      // Scroll further down to see reputation reviews below product reviews
      await tester.drag(find.byType(NestedScrollView), const Offset(0, -800));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Verify reputation review badge is present below the product reviews
      expect(find.text('RESEÑA DE REPUTACIÓN'), findsWidgets);

      // Verify expandable button is present
      expect(find.text('Ver detalle de calificación'), findsWidgets);

      // Tap on the first "Ver detalle de calificación" button
      await tester.tap(find.text('Ver detalle de calificación').first);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      // Now "Detalle por Criterios Evaluados" and "Ocultar detalle de calificación" should appear
      expect(find.text('Detalle por Criterios Evaluados'), findsOneWidget);
      expect(find.text('Ocultar detalle de calificación'), findsOneWidget);

      // Scroll back up to tap the REPUTACIÓN filter chip
      await tester.drag(find.byType(NestedScrollView), const Offset(0, 800));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Tap REPUTACIÓN filter chip
      await tester.tap(find.text('REPUTACIÓN'));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // In REPUTACIÓN filter, product purchase tag "COMPRÓ: TOMATES SALADETTE" should NOT be visible
      expect(find.text('COMPRÓ: TOMATES SALADETTE'), findsNothing);
      // But reputation reviews should still be visible
      expect(find.text('RESEÑA DE REPUTACIÓN'), findsWidgets);
    });
  });
}
