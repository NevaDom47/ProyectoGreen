import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_mercadito/screens/quality_products_screen.dart';

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
    'name': 'Huerta Los Arcos',
    'sector': 'Sector San Pedro',
    'distance': 'A 5 km',
  };

  testWidgets('QualityProductsScreen renders banner, search box, filters and products', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: QualityProductsScreen(
          quality: 'Primera Calidad',
          provider: mockProvider,
        ),
      ),
    );

    await tester.pumpAndSettle();

    // 1. Verify AppBar and Provider Name
    expect(find.text('Primera Calidad'), findsWidgets);
    expect(find.text('Huerta Los Arcos'), findsOneWidget);

    // 2. Verify Educational Banner with standards
    expect(find.text('Selección Premium de Exportación'), findsOneWidget);
    expect(find.text('Calibre A+'), findsOneWidget);
    expect(find.text('Cosecha Hoy'), findsOneWidget);
    expect(find.text('100% Frescura'), findsOneWidget);

    // 3. Verify Search Bar
    expect(find.byType(TextField), findsOneWidget);
    expect(find.textContaining('Buscar por nombre o código SKU'), findsOneWidget);

    // 4. Verify Filters are present
    expect(find.text('Todos'), findsOneWidget);
    expect(find.text('Al Detalle'), findsWidgets);
    expect(find.text('Por Mayor'), findsWidgets);
    expect(find.text('Frutas'), findsOneWidget);
    expect(find.text('Hortalizas'), findsOneWidget);

    // 5. Verify Products are displayed with SKU and Action Buttons
    expect(find.textContaining('SKU: FRU-FRE-01'), findsOneWidget);
    expect(find.text('Fresas Extra'), findsOneWidget);
    expect(find.text('AGREGAR AL CARRITO'), findsWidgets);

    final exception = tester.takeException();
    expect(exception, isNull);
  });

  testWidgets('QualityProductsScreen filters correctly by SKU code', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: QualityProductsScreen(
          quality: 'Primera Calidad',
          provider: mockProvider,
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Enter SKU in search box
    await tester.enterText(find.byType(TextField), 'RAI-ZAN-02');
    await tester.pumpAndSettle();

    // Should only match Zanahoria Orgánica
    expect(find.text('Zanahoria Orgánica'), findsOneWidget);
    expect(find.text('Fresas Extra'), findsNothing);
    expect(find.text('Tomates Premium'), findsNothing);

    // Clear search
    await tester.tap(find.byIcon(Icons.clear_rounded));
    await tester.pumpAndSettle();

    // Products reappear
    expect(find.text('Fresas Extra'), findsOneWidget);
  });

  testWidgets('QualityProductsScreen switches between Detalle and Por Mayor modes', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: QualityProductsScreen(
          quality: 'Primera Calidad',
          provider: mockProvider,
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Tap Por Mayor on the first card (at(0) is the filter chip, at(1) is the first card's switcher)
    final porMayorButtons = find.text('Por Mayor');
    expect(porMayorButtons, findsWidgets);
    await tester.tap(porMayorButtons.at(1));
    await tester.pumpAndSettle();

    // Wholesale price should be shown
    expect(find.textContaining('por mayor'), findsWidgets);

    // Tap AGREGAR AL CARRITO
    await tester.tap(find.text('AGREGAR AL CARRITO').first);
    await tester.pump();
    expect(find.textContaining('agregado al carrito'), findsOneWidget);

    final exception = tester.takeException();
    expect(exception, isNull);
  });

  testWidgets('QualityProductsScreen renders Segunda Calidad with updated theme colors', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: QualityProductsScreen(
          quality: 'Segunda Calidad',
          provider: mockProvider,
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Segunda Calidad header and standards
    expect(find.text('Segunda Calidad'), findsWidgets);
    expect(find.text('Mismo sabor y frescura a precio accesible'), findsOneWidget);
    expect(find.text('SEGUNDA'), findsOneWidget);
    expect(find.text('Sabor Auténtico'), findsOneWidget);
    expect(find.text('Ahorro Garantizado'), findsOneWidget);
    expect(find.text('Directo de Finca'), findsOneWidget);
    expect(find.text('Desperdicio Cero'), findsOneWidget);

    final exception = tester.takeException();
    expect(exception, isNull);
  });
}
