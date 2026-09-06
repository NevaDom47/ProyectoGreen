import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_mercadito/screens/provider_profile_screen.dart';

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

  tearDownAll(() {
    HttpOverrides.global = null;
  });

  final mockProvider = {
    'name': 'AgroFresas',
    'location': 'Tecomán, Colima',
    'banner': 'https://via.placeholder.com/600x240',
    'img': 'https://via.placeholder.com/100',
    'rating': 4.8,
    'traded': '1,240',
    'productsCount': 8,
  };

  testWidgets('ProviderProfileScreen displays favorites-style product cards without supplier or location rows', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: ProviderProfileScreen(provider: mockProvider),
      ),
    );

    // Complete loading state (1200ms in screen)
    await tester.pump(const Duration(milliseconds: 1400));
    await tester.pumpAndSettle();

    // Check that products tab is rendered
    expect(find.text('Calidad: Primera'), findsOneWidget);
    expect(find.text('Fresas Extra'), findsOneWidget);

    // Check SKU
    expect(find.textContaining('SKU:'), findsWidgets);

    // Check CALIDAD row is present
    expect(find.text('CALIDAD'), findsWidgets);
    expect(find.text('PRIMERA CALIDAD'), findsWidgets);

    // CRITICAL REQUIREMENT: Verify PROVEEDOR and UBICACIÓN are NOT present in product cards
    expect(find.text('PROVEEDOR'), findsNothing);
    expect(find.text('UBICACIÓN'), findsNothing);

    // Check sales mode switcher [ Detalle | Por Mayor ]
    expect(find.text('Detalle'), findsWidgets);
    expect(find.text('Por Mayor'), findsWidgets);

    // Check action button
    expect(find.text('AGREGAR AL CARRITO'), findsWidgets);

    // Tap 'Por Mayor' on the first product card
    await tester.tap(find.text('Por Mayor').first);
    await tester.pumpAndSettle();

    // Verify wholesale price & unit update
    expect(find.textContaining('por mayor'), findsWidgets);

    // Check GridView has 2 columns
    final gridFinders = find.byType(GridView);
    expect(gridFinders, findsWidgets);
    final GridView gridView = tester.widget(gridFinders.first);
    final delegate = gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
    expect(delegate.crossAxisCount, 2);
  });

  testWidgets('ProviderProfileScreen product cards fit on mobile screen without overflow', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: ProviderProfileScreen(provider: mockProvider),
      ),
    );

    // Complete loading state
    await tester.pump(const Duration(milliseconds: 1400));
    await tester.pumpAndSettle();

    expect(find.text('Calidad: Primera'), findsOneWidget);
    expect(find.text('AGREGAR AL CARRITO'), findsWidgets);
    expect(find.text('CALIDAD'), findsWidgets);
    expect(find.text('PROVEEDOR'), findsNothing);
    expect(find.text('UBICACIÓN'), findsNothing);

    final exception = tester.takeException();
    expect(exception, isNull);
  });
}
