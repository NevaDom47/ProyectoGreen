import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_mercadito/data/global_state.dart';
import 'package:app_mercadito/screens/cart_screen.dart';
import 'package:app_mercadito/screens/flash_offers_screen.dart';
import 'package:app_mercadito/screens/help_support_screen.dart';
import 'package:app_mercadito/screens/negotiations_screen.dart';
import 'package:app_mercadito/screens/product_detail_screen.dart';
import 'package:app_mercadito/screens/search_screen.dart';
import 'package:app_mercadito/screens/tasks_screen.dart';
import 'package:app_mercadito/theme/app_theme.dart';
import 'package:app_mercadito/widgets/custom_bottom_nav_bar.dart';

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
  0x60, 0x82,
];

void main() {
  setUpAll(() {
    HttpOverrides.global = _TestHttpOverrides();
  });

  tearDownAll(() {
    HttpOverrides.global = null;
  });

  void configureMobileViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0; // 360 x 800 dp lógicos
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  testWidgets(
    'CartScreen displays all unit options cleanly without clipping at 1080x2400 (360x800 dp) and updates limits on tap',
    (WidgetTester tester) async {
      configureMobileViewport(tester);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            extendBody: true,
            body: CartScreen(),
            bottomNavigationBar: CustomBottomNavBar(currentIndex: 1),
          ),
        ),
      );

      // Advance past the 600ms skeleton loading delay
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();

      expect(find.text('Confirma tu Negociación'), findsOneWidget);
      expect(find.text('UNIDAD'), findsNWidgets(2));
      expect(find.text('LIBRA'), findsNWidgets(2));
      expect(find.text('SACO'), findsOneWidget);
      expect(find.text('CAJA'), findsOneWidget);

      // Verify unit labels render at full readable width (not clipped to "UNID" or "D")
      expect(tester.getSize(find.text('UNIDAD').first).width, greaterThan(35));
      expect(tester.getSize(find.text('LIBRA').first).width, greaterThan(28));
      expect(tester.getSize(find.text('SACO')).width, greaterThan(25));
      expect(tester.getSize(find.text('CAJA')).width, greaterThan(25));

      // Verify initial limits and interactive switch to LIBRA
      expect(find.text('Mín. 5 | Máx. 20'), findsNWidgets(2));
      await tester.tap(find.text('LIBRA').first);
      await tester.pumpAndSettle();

      expect(find.text('Mín. 2 | Máx. 50'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('FlashOffersScreen renders without overflow at 1080x2400 (360x800 dp)', (WidgetTester tester) async {
    configureMobileViewport(tester);
    addTearDown(stopGlobalFlashTimer);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const FlashOffersScreen(),
      ),
    );

    await tester.pump(const Duration(milliseconds: 700));

    expect(find.text('Ofertas Relámpago'), findsOneWidget);
    expect(tester.takeException(), isNull);
    stopGlobalFlashTimer();
  });

  testWidgets('NegotiationsScreen renders tabs and cards without overflow at 1080x2400 (360x800 dp)', (WidgetTester tester) async {
    configureMobileViewport(tester);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const NegotiationsScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Pendientes'), findsOneWidget);
    expect(find.text('Completadas'), findsOneWidget);
    expect(find.text('Canceladas'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ProductDetailScreen renders price, multiple unit chips, and quantity selector without overflow at 1080x2400 (360x800 dp)', (WidgetTester tester) async {
    configureMobileViewport(tester);

    final testProduct = {
      'id': 'PROD-RESP-1',
      'name': 'Aguacate Hass Premium',
      'category': 'Frutas',
      'saleType': 'ambos',
      'price': '\$280.00',
      'wholesalePrice': '\$240.00',
      'wholesaleMin': '5 Saco',
      'unit': 'Por Libra',
      'unitConfigs': [
        {'unit': 'Por Libra', 'saleType': 'detalle', 'priceRetail': 280.00, 'isDefault': true},
        {'unit': 'Unidad', 'saleType': 'detalle', 'priceRetail': 45.00, 'isDefault': false},
        {'unit': 'Docena', 'saleType': 'detalle', 'priceRetail': 450.00, 'isDefault': false},
        {'unit': 'Saco', 'saleType': 'mayor', 'priceWholesale': 240.00, 'wholesaleMin': '5 Saco', 'isDefault': true},
      ],
      'img': 'assets/images/PapaGemini.png',
      'photos': ['assets/images/PapaGemini.png'],
    };

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: ProductDetailScreen(product: testProduct),
      ),
    );

    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pumpAndSettle();

    expect(find.text('Aguacate Hass Premium'), findsOneWidget);
    expect(find.text('Por Libra'), findsOneWidget);
    expect(find.text('Unidad'), findsOneWidget);
    expect(find.text('Docena'), findsOneWidget);

    await tester.tap(find.text('Por Mayor'));
    await tester.pumpAndSettle();
    expect(find.text('Saco'), findsOneWidget);

    expect(tester.takeException(), isNull);
  });

  testWidgets('TasksScreen renders gamified task grid without overflow at 1080x2400 (360x800 dp)', (WidgetTester tester) async {
    configureMobileViewport(tester);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const TasksScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Tareas y Prestigio'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('HelpSupportScreen renders category grid without overflow at 1080x2400 (360x800 dp)', (WidgetTester tester) async {
    configureMobileViewport(tester);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const HelpSupportScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Preguntas Frecuentes'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('SearchScreen renders product cards without overflow at 1080x2400 (360x800 dp)', (WidgetTester tester) async {
    configureMobileViewport(tester);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const SearchScreen(),
      ),
    );

    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pumpAndSettle();

    expect(find.text('Papa Blanca Alpha'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
