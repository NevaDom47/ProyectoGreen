import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_mercadito/screens/favorite_providers_screen.dart';
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
  HttpClientResponseCompressionState get compressionState => HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(void Function(List<int> event)? onData, {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    return Stream<List<int>>.value(_transparentImage).listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);
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

  setUp(() {
    // Reset global favorite providers before each test
    globalFavoriteProviders.value = [
      {
        'id': 'p1',
        'name': 'Huerta Los Arcos',
        'rating': '4.8',
        'sector': 'Agrícola',
        'distance': 'A 5 km',
        'level': 'Nivel 3',
        'verified': true,
        'open': true,
        'closeTime': '18:00',
        'tags': 'Frutas y verduras',
        'reviews': '120 reseñas de clientes',
        'traded': '1,240 productos negociados',
        'sales': '1,240 ventas',
        'salesType': 'Al Detalle',
        'banner': 'https://images.unsplash.com/photo-1542838132-92c53300491e',
      },
      {
        'id': 'p2',
        'name': 'La Granja de Toño',
        'rating': '4.7',
        'sector': 'Avícola',
        'distance': 'A 8 km',
        'level': 'Nivel 2',
        'verified': true,
        'open': true,
        'closeTime': '17:30',
        'tags': 'Huevos',
        'reviews': '128 reseñas',
        'traded': '850 productos negociados',
        'sales': '850 ventas',
        'salesType': 'Por Mayor',
        'banner': 'https://images.unsplash.com/photo-1500595046743-cd271d694d30',
      },
    ];
  });

  testWidgets('FavoriteProvidersScreen renders rich provider cards with all requested metadata', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: FavoriteProvidersScreen(),
      ),
    );

    // Initial loading shimmer
    await tester.pump(const Duration(milliseconds: 1600));

    // Verify Title and Search Bar
    expect(find.text('Proveedores Favoritos'), findsOneWidget);
    expect(find.text('Buscar en mis favoritos...'), findsOneWidget);

    // 1. Check Verified badge
    expect(find.text('VERIFICADO'), findsWidgets);

    // 2. Check Distance badge
    expect(find.text('A 5 km'), findsOneWidget);
    expect(find.text('A 8 km'), findsOneWidget);

    // 3. Check Provider name and Rating chip
    expect(find.text('Huerta Los Arcos'), findsOneWidget);
    expect(find.text('4.8'), findsOneWidget);
    expect(find.text('La Granja de Toño'), findsOneWidget);
    expect(find.text('4.7'), findsOneWidget);

    // 4. Check Operational status & 12h close time
    expect(find.text('ABIERTO AHORA'), findsWidgets);
    expect(find.text('• Cierra 6:00 PM'), findsOneWidget);
    expect(find.text('• Cierra 5:30 PM'), findsOneWidget);

    // 5. Check Category, Modality & Level pills
    expect(find.text('Frutas y verduras'), findsOneWidget);
    expect(find.text('Al Detalle'), findsOneWidget);
    expect(find.text('Nivel 3'), findsOneWidget);

    expect(find.text('Huevos'), findsOneWidget);
    expect(find.text('Por Mayor'), findsOneWidget);
    expect(find.text('Nivel 2'), findsOneWidget);

    // 6. Check Traded products
    expect(find.text('1,240 productos negociados'), findsOneWidget);
    expect(find.text('850 productos negociados'), findsOneWidget);

    // 7. Check Reviews & Ver perfil CTA
    expect(find.text('120 reseñas de clientes'), findsOneWidget);
    expect(find.text('Ver perfil'), findsWidgets);

    // 8. Test Search Filter
    await tester.enterText(find.byType(TextField), 'Huerta');
    await tester.pumpAndSettle();

    expect(find.text('Huerta Los Arcos'), findsOneWidget);
    expect(find.text('La Granja de Toño'), findsNothing);

    // Clear search
    await tester.enterText(find.byType(TextField), '');
    await tester.pumpAndSettle();

    expect(find.text('Huerta Los Arcos'), findsOneWidget);
    expect(find.text('La Granja de Toño'), findsOneWidget);

    expect(tester.takeException(), isNull);
  });
}
