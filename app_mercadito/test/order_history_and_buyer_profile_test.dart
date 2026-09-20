import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_mercadito/data/global_state.dart';
import 'package:app_mercadito/screens/order_history_screen.dart';
import 'package:app_mercadito/screens/profile_screen.dart';
import 'package:app_mercadito/screens/buyer_profile_screen.dart';
import 'package:app_mercadito/theme/app_theme.dart';
import 'package:app_mercadito/services/user_session.dart';

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

final List<int> _transparentImage = <int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
  0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
  0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
];

void main() {
  setUpAll(() {
    HttpOverrides.global = _TestHttpOverrides();
  });

  setUp(() {
    UserSession.selectedRole = 'comprador';
  });

  Widget buildTestable(Widget child) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: MediaQuery(
        data: const MediaQueryData(size: Size(800, 1400)),
        child: child,
      ),
    );
  }

  group('OrderHistoryScreen Tests', () {
    testWidgets('Renders header, metrics, and filter chips without Pendientes', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestable(const OrderHistoryScreen()));
      await tester.pumpAndSettle();

      // Check Title
      expect(find.text('Histórico de Negociaciones'), findsOneWidget);

      // Check Metrics (Completados, Cancelados, Invertido)
      expect(find.text('COMPLETADOS'), findsNWidgets(2)); // 1 in metric, 1 in filter chip
      expect(find.text('CANCELADOS'), findsNWidgets(2)); // 1 in metric, 1 in filter chip
      expect(find.text('INVERTIDO'), findsOneWidget);
      // Ensure 'PENDIENTES' metric is NOT present
      expect(find.text('PENDIENTES'), findsNothing);

      // Check Filter Chips (TODOS, COMPLETADOS, CANCELADOS)
      expect(find.text('TODOS'), findsOneWidget);
      expect(find.text('COMPLETADOS'), findsWidgets);
      expect(find.text('CANCELADOS'), findsWidgets);

      // Verify no "Ver Detalle" button exists
      expect(find.text('Ver Detalle'), findsNothing);

      // Verify Cantidad negociada is rendered in the card body
      expect(find.text('Cantidad negociada: '), findsWidgets);
    });

    testWidgets('Calculates total invested correctly based on completed negotiations only', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestable(const OrderHistoryScreen()));
      await tester.pumpAndSettle();

      // In globalOrders:
      // Completed:
      // ORD-88291 (Aguacate) = 40.0
      // ORD-62104 (Maíz) = 28.0
      // ORD-59821 (Queso) = 16.5
      // ORD-39102 (Miel) = 13.5
      // Sum = 40 + 28 + 16.5 + 13.5 = 98.0
      // Completed count = 4
      expect(find.text('4'), findsWidgets); // 4 completados
      expect(find.text('\$98.0'), findsOneWidget); // $98.0 invertido
    });

    testWidgets('Tapping unavailable product shows notification SnackBar', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestable(const OrderHistoryScreen()));
      await tester.pumpAndSettle();

      // Filter by CANCELADOS or find Canasta de Verduras Mixtas (which has is_available: false)
      final canastaTitle = find.text('Canasta de Verduras Mixtas');
      expect(canastaTitle, findsOneWidget);

      await tester.tap(canastaTitle);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.textContaining('no está disponible actualmente'), findsOneWidget);
    });
  });

  group('ProfileScreen Negotiation History Tests', () {
    testWidgets('Renders last 3 negotiations with all required fields', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestable(const ProfileScreen()));
      await tester.pumpAndSettle();

      // Section title and Ver todo
      expect(find.text('Historial de negociaciones'), findsOneWidget);
      expect(find.text('Ver todo'), findsWidgets);

      // The last 3 completed/cancelled items are:
      // 1. Miel de Abeja Orgánica (1L)
      // 2. Canasta de Verduras Mixtas
      // 3. Queso Fresco de Rancho (3kg)
      expect(find.text('Miel de Abeja Orgánica (1L)'), findsOneWidget);
      expect(find.text('Canasta de Verduras Mixtas'), findsOneWidget);
      expect(find.text('Queso Fresco de Rancho (3kg)'), findsOneWidget);

      // Provider names with icons
      expect(find.text('Rancho La Esmeralda'), findsOneWidget);
      expect(find.text('Huerto Urbano Beto'), findsOneWidget);
      expect(find.text('Quesería del Valle'), findsOneWidget);

      // Status badges
      expect(find.text('COMPLETADO'), findsWidgets);
      expect(find.text('CANCELADO'), findsWidgets);
    });
  });

  group('BuyerProfileScreen Negotiation History Tests', () {
    testWidgets('Renders negotiation history section and interactive Negociaciones tile', (tester) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final buyerData = {
        'id': 'BUY-88291',
        'name': 'Carlos Mendoza',
        'location': 'Sector San Pedro',
        'rating': 4.9,
        'negotiationsCount': 15,
        'frequentProducts': ['Aguacate Hass', 'Miel Orgánica'],
      };

      await tester.pumpWidget(buildTestable(BuyerProfileScreen(buyer: buyerData)));
      await tester.pumpAndSettle();

      // Metric stat boxes: RESEÑAS, CALIFICACIÓN, NEGOCIACIONES
      expect(find.text('NEGOCIACIONES'), findsOneWidget);
      expect(find.text('RESEÑAS'), findsOneWidget);
      expect(find.text('CALIFICACIÓN'), findsOneWidget);
      expect(find.text('15'), findsOneWidget);

      // Section Historial de negociaciones
      expect(find.text('Historial de negociaciones'), findsOneWidget);
      expect(find.text('Miel de Abeja Orgánica (1L)'), findsOneWidget);
    });
  });

  group('ProfileScreen Mis Favoritos Tests', () {
    setUp(() {
      UserSession.selectedRole = 'comprador';
    });

    testWidgets('Mis Favoritos shows max 5 latest added products with FavoritesScreen card design and Ver todos', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 5000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      // Populate 7 items in globalFavorites
      globalFavorites.value = List.generate(7, (i) => {
        'id': 'PROD-$i',
        'name': 'Producto Favorito $i',
        'price': '\$${(i + 1) * 2}.50',
        'unit': 'kg',
        'supplier': 'Proveedor $i',
        'location': 'Colima, México',
        'distance': '4.2',
        'quality': 'Primera Calidad',
        'salesMode': 'both',
        'sku': 'SKU-00$i',
        'image': 'https://example.com/item$i.jpg',
      });

      await tester.pumpWidget(buildTestable(const ProfileScreen()));
      await tester.pumpAndSettle();

      // Verify Header and "Ver todos"
      expect(find.text('Mis Favoritos'), findsOneWidget);
      expect(find.text('Ver todos'), findsOneWidget);

      // Verify only 5 latest items are displayed (indices 6, 5, 4, 3, 2)
      expect(find.text('Producto Favorito 6'), findsOneWidget);
      expect(find.text('Producto Favorito 5'), findsOneWidget);
      expect(find.text('Producto Favorito 4'), findsOneWidget);
      expect(find.text('Producto Favorito 3'), findsOneWidget);
      expect(find.text('Producto Favorito 2'), findsOneWidget);
      // Older items (0 and 1) should NOT be displayed
      expect(find.text('Producto Favorito 0'), findsNothing);
      expect(find.text('Producto Favorito 1'), findsNothing);

      // Verify card elements matching FavoritesScreen
      expect(find.text('SKU: SKU-006'), findsOneWidget);
      expect(find.text('Detalle'), findsWidgets);
      expect(find.text('Por Mayor'), findsWidgets);
      expect(find.text('CALIDAD'), findsWidgets);
      expect(find.text('PROVEEDOR'), findsWidgets);
      expect(find.text('UBICACIÓN'), findsWidgets);
      expect(find.text('AGREGAR AL CARRITO'), findsWidgets);
    });
  });
}
