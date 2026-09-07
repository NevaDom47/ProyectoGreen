import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_mercadito/screens/home_feed_screen.dart';
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
    globalCart.value = [];
  });

  tearDown(() {
    stopGlobalFlashTimer();
  });

  testWidgets('HomeFeedScreen displays Proveedor destacado section with products, tags, mode switcher, and cart functionality',
      (WidgetTester tester) async {
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

    // Wait for skeleton timer
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pump();

    // Scroll until Proveedor destacado is visible
    final sectionFinder = find.text('Proveedor destacado');
    await tester.scrollUntilVisible(
      sectionFinder,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump();

    // Verify section header elements
    expect(find.text('Olé'), findsWidgets);
    expect(find.text('Proveedor destacado'), findsOneWidget);
    expect(find.text('De Hipermercados Olé Villa Mella 🛒'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_forward_rounded), findsWidgets);

    // Verify products and prices
    expect(find.text('DOÑA GALLINA Caldo 6ud (131) (AP)'), findsOneWidget);
    expect(find.text('RD\$48.00'), findsOneWidget);
    expect(find.text('POR CAJA'), findsOneWidget);

    // Verify tags and mode switchers
    expect(find.text('Condimentos'), findsWidgets);
    expect(find.text('Oferta'), findsWidgets);
    expect(find.text('Detalle'), findsWidgets);
    expect(find.text('Por Mayor'), findsWidgets);

    // Verify compact card structure: CALIDAD is present, PROVEEDOR and UBICACIÓN removed
    expect(find.text('CALIDAD'), findsWidgets);
    expect(find.text('PRIMERA CALIDAD'), findsWidgets);
    expect(find.text('Villa Mella, Santo Domingo'), findsNothing);

    // Check circular cart button exists on cards
    final cartButtons = find.byIcon(Icons.shopping_cart_outlined);
    expect(cartButtons, findsWidgets);

    // Initial cart is empty
    expect(globalCart.value.isEmpty, isTrue);

    // Tap first cart button to add Doña Gallina to cart
    await tester.tap(cartButtons.first);
    await tester.pump();

    // Verify SnackBar feedback
    expect(find.textContaining('Añadido al carrito'), findsOneWidget);

    // Verify item in globalCart
    expect(globalCart.value.isNotEmpty, isTrue);
    final vendor = globalCart.value.first;
    expect(vendor['name'], 'Hipermercados Olé');
    final items = vendor['items'] as List;
    expect(items.any((item) => item['name'] == 'DOÑA GALLINA Caldo 6ud (131) (AP)'), isTrue);
  });
}
