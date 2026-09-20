import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_mercadito/models/coupon_model.dart';
import 'package:app_mercadito/services/coupons_service.dart';
import 'package:app_mercadito/screens/coupons_manager_screen.dart';
import 'package:app_mercadito/screens/home_feed_screen.dart';
import 'package:app_mercadito/theme/app_theme.dart';
import 'package:app_mercadito/services/user_session.dart';

class _TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => _MockHttpClient();
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

  group('Coupons Domain & Logic Unit Tests', () {
    test('Coupon model initializes and computes condition summary accurately', () {
      final now = DateTime.now();
      final coupon = Coupon(
        id: 'TEST-1',
        providerId: 'PROV-00000001',
        code: 'COSECHA10',
        title: 'Feria de Cosecha',
        benefit: const CouponBenefit(
          type: CouponBenefitType.percentage,
          value: 10,
        ),
        rule: CouponRule(
          scope: CouponScope.allProducts,
          minPurchase: 1500,
          startDate: now,
          endDate: now.add(const Duration(days: 15)),
        ),
        createdAt: now,
      );

      expect(coupon.benefit.displayTitle, '10% OFF');
      expect(coupon.rule.conditionSummary, contains('Compra mínima RD\$ 1500'));
      expect(coupon.rule.conditionSummary, contains('En todos los productos'));
      expect(coupon.isActive, isTrue);
    });

    test('CouponsService performs CRUD, duplication and pause/resume correctly', () {
      final service = CouponsService.instance;
      final initialCount = service.coupons.length;
      expect(initialCount, greaterThanOrEqualTo(5));

      // Create
      final newCoupon = Coupon(
        id: 'UNIT-TEST-CPN',
        providerId: 'PROV-00000001',
        code: 'TEST2026',
        title: 'Cupón de Prueba Unitaria',
        benefit: const CouponBenefit(
          type: CouponBenefitType.fixedAmount,
          value: 200,
        ),
        rule: CouponRule(
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 10)),
        ),
        createdAt: DateTime.now(),
      );
      service.createCoupon(newCoupon);
      expect(service.coupons.first.code, 'TEST2026');
      // Debe iniciar pausado y editable antes de activarse
      expect(service.coupons.first.status, CouponStatus.paused);
      expect(service.coupons.first.canBeEdited, isTrue);

      // Activar por primera vez -> Bloquea edición permanentemente
      service.togglePauseCoupon('UNIT-TEST-CPN');
      expect(service.coupons.first.status, CouponStatus.active);
      expect(service.coupons.first.hasBeenActivated, isTrue);
      expect(service.coupons.first.canBeEdited, isFalse);

      // Volver a pausar -> No se puede volver a editar
      service.togglePauseCoupon('UNIT-TEST-CPN');
      expect(service.coupons.first.status, CouponStatus.paused);
      expect(service.coupons.first.canBeEdited, isFalse);

      // Finalizar cupón -> Pasa a status expired (inactivo definitivo)
      service.finalizeCoupon('UNIT-TEST-CPN');
      expect(service.coupons.first.status, CouponStatus.expired);

      // Duplicate
      service.duplicateCoupon('UNIT-TEST-CPN');
      expect(service.coupons.first.title, contains('(Copia)'));

      // Delete test coupons
      service.deleteCoupon('UNIT-TEST-CPN');
      service.deleteCoupon(service.coupons.first.id);
    });

    test('CouponsService calculates global metrics properly', () {
      final metrics = CouponsService.instance.getGlobalMetrics();
      expect(metrics['activeCount'], greaterThan(0));
      expect(metrics['usedCount'], greaterThan(0));
      expect(metrics['totalSales'], greaterThan(0));
      expect(metrics['totalDiscount'], greaterThan(0));
    });
  });

  group('CouponsManagerScreen UI Widget Tests', () {
    testWidgets('CouponsManagerScreen renders title, KPIs, search and coupon ticket cards', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const CouponsManagerScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Check title and actions
      expect(find.text('Gestión de Cupones'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.text('Crear cupón'), findsOneWidget);

      // Check KPIs in header
      expect(find.text('CUPONES ACTIVOS'), findsOneWidget);
      expect(find.text('CUPONES UTILIZADOS'), findsOneWidget);
      expect(find.text('DESCUENTO OTORGADO'), findsOneWidget);
      expect(find.text('VENTAS GENERADAS'), findsOneWidget);

      // Check Filter chips
      expect(find.text('Todos'), findsOneWidget);
      expect(find.text('Activos'), findsOneWidget);
      expect(find.text('Pausados'), findsOneWidget);
      expect(find.text('Finalizados'), findsOneWidget);

      // Check coupon cards
      expect(find.text('COSECHA10'), findsWidgets);
      expect(find.text('ORGANICOS'), findsWidgets);
      expect(find.text('Estadísticas'), findsWidgets);
      expect(find.text('Ver'), findsWidgets);
    });

    testWidgets('Tapping Estadísticas button opens CouponStatsSheet with conversion funnel', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const CouponsManagerScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap first "Estadísticas" button
      final statsBtn = find.text('Estadísticas').first;
      await tester.ensureVisible(statsBtn);
      await tester.tap(statsBtn);
      await tester.pumpAndSettle();

      // Verify Stats Sheet content
      expect(find.text('RENDIMIENTO GENERAL'), findsOneWidget);
      expect(find.text('EMBUDO DE CONVERSIÓN'), findsOneWidget);
      expect(find.text('Cupón publicado'), findsOneWidget);
      expect(find.text('Personas que lo vieron'), findsOneWidget);
      expect(find.text('Personas que lo guardaron'), findsOneWidget);
      expect(find.text('Personas que lo utilizaron'), findsOneWidget);
    });

    testWidgets('Tapping Crear cupón opens CreateCouponWizard in 4 steps', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const CouponsManagerScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap FAB
      await tester.tap(find.text('Crear cupón'));
      await tester.pumpAndSettle();

      // Step 1
      expect(find.text('Crear Nuevo Cupón'), findsOneWidget);
      expect(find.text('Paso 1 — Información básica'), findsOneWidget);

      // Navigate to Step 2
      await tester.tap(find.text('Siguiente'));
      await tester.pumpAndSettle();
      expect(find.text('Paso 2 — ¿Qué beneficio obtiene el comprador?'), findsOneWidget);

      // Navigate to Step 3
      await tester.tap(find.text('Siguiente'));
      await tester.pumpAndSettle();
      expect(find.text('Paso 3 — Reglas del cupón'), findsOneWidget);
      expect(find.text('Lunes'), findsOneWidget);
      expect(find.text('Domingo'), findsOneWidget);

      // Navigate to Step 4
      await tester.tap(find.text('Siguiente'));
      await tester.pumpAndSettle();
      expect(find.text('Paso 4 — ¿Quién puede utilizar este cupón?'), findsOneWidget);
      expect(find.text('Guardar Cupón (Pausado)'), findsOneWidget);

      // Verify badges have been removed
      expect(find.text('Manual / Público'), findsNothing);
      expect(find.text('Automático'), findsNothing);
      expect(find.text('Selección manual'), findsNothing);

      // Select 'Compradores seleccionados'
      await tester.tap(find.text('Compradores seleccionados'));
      await tester.pumpAndSettle();

      // Verify buyer name in bold and buyer BUY ID underneath
      expect(find.text('Carmen Jiménez'), findsOneWidget);
      expect(find.text('BUY-002'), findsOneWidget);
      expect(find.text('Rafael Marte'), findsOneWidget);
      expect(find.text('BUY-001'), findsOneWidget);
    });

    testWidgets('CouponsManagerScreen filter chips work for Activos, Pausados and Finalizados without promotions tab', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const CouponsManagerScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Ensure 'Promociones' chip does not exist
      expect(find.text('Promociones'), findsNothing);
      expect(find.byTooltip('Promociones automatizadas'), findsNothing);

      // Verify default shows active coupons
      expect(find.text('COSECHA10'), findsOneWidget);
      expect(find.text('VERDE15'), findsOneWidget);

      // Tap Pausados filter
      await tester.tap(find.text('Pausados'));
      await tester.pumpAndSettle();

      expect(find.text('PAN2X1'), findsOneWidget);
      expect(find.text('COSECHA10'), findsNothing);

      // Tap Todos filter
      await tester.tap(find.text('Todos'));
      await tester.pumpAndSettle();

      expect(find.text('COSECHA10'), findsOneWidget);
      expect(find.text('PAN2X1'), findsOneWidget);
    });
  });

  group('Drawer Navigation Integration for Coupons Management', () {
    testWidgets('HomeFeedScreen drawer displays Gestión de Cupones option', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      UserSession.selectedRole = 'proveedor';

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const HomeFeedScreen(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 1600));
      await tester.pump();

      // Open drawer
      final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold).first);
      scaffoldState.openDrawer();
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.text('Gestión de Cupones'), findsOneWidget);
    });
  });
}
