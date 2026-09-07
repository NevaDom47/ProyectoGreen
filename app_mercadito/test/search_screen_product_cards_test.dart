import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_mercadito/screens/search_screen.dart';

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

  testWidgets('SearchScreen product card displays horizontal layout with left image, details, and right cart icon', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: SearchScreen(),
      ),
    );

    // Allow skeleton loading timer to finish (1500ms)
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pumpAndSettle();

    // Verify card title, SKU, provider, location
    expect(find.text('Papa Blanca Alpha'), findsOneWidget);
    expect(find.text('SKU: TUB-PAP-01'), findsOneWidget);
    expect(find.text('Don Pedro H.'), findsOneWidget);
    expect(find.text('Tecomán, Colima'), findsOneWidget);

    // Verify sales mode switcher / indicators
    expect(find.text('Detalle'), findsWidgets);
    expect(find.text('Por Mayor'), findsWidgets);

    // Verify badges row: unit and quality
    expect(find.text('Venta por: KG'), findsWidgets);
    expect(find.text('CALIDAD'), findsWidgets);
    expect(find.text('PRIMERA CALIDAD'), findsWidgets);
    expect(find.text('PROVEEDOR'), findsWidgets);
    expect(find.text('UBICACIÓN'), findsWidgets);

    // Verify price and unit
    expect(find.text('\$22.50'), findsOneWidget);
    expect(find.text('/kg'), findsWidgets);

    // Verify representative circular icons and unit dropdown icon
    expect(find.byIcon(Icons.workspace_premium), findsWidgets);
    expect(find.byIcon(Icons.local_florist), findsWidgets);
    expect(find.byIcon(Icons.location_on), findsWidgets);
    expect(find.byIcon(Icons.keyboard_arrow_down_rounded), findsWidgets);

    // Verify shopping cart icon button on the right
    expect(find.byIcon(Icons.shopping_cart_outlined), findsWidgets);

    // Tap shopping cart button on the first card
    final cartButtons = find.byIcon(Icons.shopping_cart_outlined);
    await tester.tap(cartButtons.first);
    await tester.pumpAndSettle();

    // Verify SnackBar feedback
    expect(find.textContaining('Añadido al carrito'), findsOneWidget);
  });

  testWidgets('SearchScreen allows switching between Detalle and Por Mayor mode', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: SearchScreen(),
      ),
    );

    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pumpAndSettle();

    // Default retail price for Papa Blanca Alpha is $22.50
    expect(find.text('\$22.50'), findsOneWidget);

    // Tap 'Por Mayor' on the first card
    final porMayorButtons = find.text('Por Mayor');
    expect(porMayorButtons, findsWidgets);
    await tester.tap(porMayorButtons.first);
    await tester.pumpAndSettle();

    // Wholesale price for Papa Blanca Alpha is $18.00
    expect(find.text('\$18.00'), findsOneWidget);

    // Switch back to 'Detalle'
    final detalleButtons = find.text('Detalle');
    await tester.tap(detalleButtons.first);
    await tester.pumpAndSettle();

    // Reverts to $22.50
    expect(find.text('\$22.50'), findsOneWidget);
  });
}

