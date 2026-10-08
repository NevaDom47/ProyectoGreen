import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_mercadito/models/provider_map_item.dart';
import 'package:app_mercadito/repositories/provider_map_repository.dart';
import 'package:app_mercadito/screens/providers_map_screen.dart';
import 'package:app_mercadito/screens/home_feed_screen.dart';
import 'package:app_mercadito/widgets/provider_map_card.dart';
import 'package:app_mercadito/widgets/provider_map_pin.dart';
import 'package:app_mercadito/widgets/verified_badge.dart';
import 'package:app_mercadito/data/global_state.dart';

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
  StreamSubscription<List<int>> listen(void Function(List<int> event)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    return Stream<List<int>>.value(_transparentImage)
        .listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);
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

  tearDown(() {
    stopGlobalFlashTimer();
  });

  final testProviders = [
    const ProviderMapItem(
      id: 'prov_test_1',
      name: 'Granja Santo Domingo',
      rating: '4.8',
      sector: 'Sector San Pedro • Santo Domingo',
      distance: 'A 5 km',
      level: 'Nivel 3',
      verified: true,
      open: true,
      closeTime: '18:00',
      specialty: 'Frutas y verduras',
      salesType: 'Al Detalle',
      reviews: '120 reseñas',
      traded: '1,240 productos',
      img: 'https://example.com/p1.jpg',
      latitude: 18.4861,
      longitude: -69.9312,
    ),
    const ProviderMapItem(
      id: 'prov_test_2',
      name: 'Lácteos del Valle Santiago',
      rating: '4.9',
      sector: 'Sector El Valle • Santiago',
      distance: 'A 15 km',
      level: 'Nivel 5',
      verified: false,
      open: false,
      closeTime: '17:00',
      specialty: 'Lacteos',
      salesType: 'Mayorista',
      reviews: '85 reseñas',
      traded: '430 productos',
      img: 'https://example.com/p2.jpg',
      latitude: 19.4517,
      longitude: -70.6970,
    ),
  ];

  group('ProvidersMapScreen UI Widget Tests', () {
    testWidgets('Renders search bar, filter chips, and map controls', (tester) async {
      final repo = ProviderMapRepository(seedProviders: testProviders);

      await tester.pumpWidget(
        MaterialApp(
          home: ProvidersMapScreen(repository: repo),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Search bar and back button
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(find.byIcon(Icons.list_alt_rounded), findsOneWidget);

      // 2. Filter chips
      expect(find.text('2 en RD'), findsOneWidget);
      expect(find.text('Verificados'), findsOneWidget);
      expect(find.text('Abierto ahora'), findsOneWidget);
      expect(find.text('Especialidad'), findsOneWidget);
      expect(find.text('Tipo de venta'), findsOneWidget);

      // 3. Floating map buttons
      expect(find.byIcon(Icons.my_location_rounded), findsOneWidget);
      expect(find.byIcon(Icons.add_rounded), findsOneWidget);
      expect(find.byIcon(Icons.remove_rounded), findsOneWidget);

      // 4. Provider pins rendered with official provider icon (Icons.local_florist)
      expect(find.byType(ProviderMapPin), findsNWidgets(2));
      expect(find.byIcon(Icons.local_florist), findsWidgets);
    });

    testWidgets('Tapping a provider pin displays quick details card with Ver Perfil button', (tester) async {
      final repo = ProviderMapRepository(seedProviders: testProviders);

      await tester.pumpWidget(
        MaterialApp(
          home: ProvidersMapScreen(repository: repo),
        ),
      );
      await tester.pumpAndSettle();

      // Map pin displays provider name and reputation rating directly on the map
      expect(find.text('Granja Santo Domingo'), findsOneWidget);
      expect(find.text('4.8'), findsOneWidget);
      expect(find.byType(VerifiedBadge), findsWidgets);

      // Card is not visible initially
      expect(find.byType(ProviderMapCard), findsNothing);

      // Tap the first provider pin
      await tester.tap(find.byType(ProviderMapPin).first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      // Quick Details Card is now shown with 12h AM/PM formatted hours
      expect(find.byType(ProviderMapCard), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(ProviderMapCard),
          matching: find.text('Granja Santo Domingo'),
        ),
        findsOneWidget,
      );
      expect(find.text('Frutas y verduras'), findsWidgets);
      expect(find.text('Venta: Al Detalle'), findsOneWidget);
      expect(find.text('Abierto hasta 6:00 PM'), findsOneWidget);
      expect(find.text('Ver Perfil'), findsOneWidget);

      // Close the card
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.byType(ProviderMapCard), findsNothing);
    });

    test('ProviderMapPin getZoomTier returns appropriate tier according to zoom level', () {
      expect(ProviderMapPin.getZoomTier(6.5), 0);
      expect(ProviderMapPin.getZoomTier(7.5), 0);
      expect(ProviderMapPin.getZoomTier(8.2), 1);
      expect(ProviderMapPin.getZoomTier(9.5), 1);
      expect(ProviderMapPin.getZoomTier(10.5), 2);
      expect(ProviderMapPin.getZoomTier(14.0), 2);
    });

    test('ProviderMapItem formatTo12h converts 24h hours to 12h AM/PM correctly', () {
      expect(ProviderMapItem.formatTo12h('19:00'), '7:00 PM');
      expect(ProviderMapItem.formatTo12h('18:00'), '6:00 PM');
      expect(ProviderMapItem.formatTo12h('17:30'), '5:30 PM');
      expect(ProviderMapItem.formatTo12h('12:00'), '12:00 PM');
      expect(ProviderMapItem.formatTo12h('08:00'), '8:00 AM');
      expect(ProviderMapItem.formatTo12h('00:30'), '12:30 AM');
      expect(ProviderMapItem.formatTo12h('6:00 PM'), '6:00 PM');
    });

    testWidgets('Search query filters providers on the map', (tester) async {
      final repo = ProviderMapRepository(seedProviders: testProviders);

      await tester.pumpWidget(
        MaterialApp(
          home: ProvidersMapScreen(repository: repo),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('2 en RD'), findsOneWidget);

      // Search for 'Santiago'
      await tester.enterText(find.byType(TextField), 'Santiago');
      await tester.pumpAndSettle();

      // Now only 1 provider matches
      expect(find.text('1 en RD'), findsOneWidget);
      expect(find.byType(ProviderMapPin), findsOneWidget);

      // Clear search
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pumpAndSettle();

      expect(find.text('2 en RD'), findsOneWidget);
      expect(find.byType(ProviderMapPin), findsNWidgets(2));
    });

    testWidgets('Toggle Verified filter chip filters only verified providers', (tester) async {
      final repo = ProviderMapRepository(seedProviders: testProviders);

      await tester.pumpWidget(
        MaterialApp(
          home: ProvidersMapScreen(repository: repo),
        ),
      );
      await tester.pumpAndSettle();

      // Tap 'Verificados' chip
      await tester.tap(find.text('Verificados'));
      await tester.pumpAndSettle();

      // Only 1 is verified
      expect(find.text('1 en RD'), findsOneWidget);
      expect(find.byType(ProviderMapPin), findsOneWidget);

      // Untoggle 'Verificados'
      await tester.tap(find.text('Verificados'));
      await tester.pumpAndSettle();

      expect(find.text('2 en RD'), findsOneWidget);
      expect(find.byType(ProviderMapPin), findsNWidgets(2));
    });

    testWidgets('Lateral drawer menu displays Mapa de Proveedores with MAPA badge', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: HomeFeedScreen(),
        ),
      );
      // Wait for 1500ms skeleton timer
      await tester.pump(const Duration(milliseconds: 1600));
      await tester.pump();

      final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold).first);
      scaffoldState.openDrawer();
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.text('Mapa de Proveedores'), findsOneWidget);
      expect(find.text('MAPA'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      stopGlobalFlashTimer();
    });
  });
}
