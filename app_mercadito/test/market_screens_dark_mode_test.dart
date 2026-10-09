import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_mercadito/screens/market_analysis_screen.dart';
import 'package:app_mercadito/screens/market_price_detail_screen.dart';

void main() {
  group('MarketAnalysisScreen Dark Mode Tests', () {
    Widget buildTestableAnalysisScreen() {
      return MaterialApp(
        theme: ThemeData.dark(),
        home: const MarketAnalysisScreen(),
      );
    }

    testWidgets('renders header icons (arrow_back, tune) with #80C652 in dark mode', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestableAnalysisScreen());
      // Advance past the 600ms loading delay in initState
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();

      final backIconFinder = find.byIcon(Icons.arrow_back);
      expect(backIconFinder, findsOneWidget);
      final backIcon = tester.widget<Icon>(backIconFinder);
      expect(backIcon.color, const Color(0xFF80C652));

      final tuneIconFinder = find.byIcon(Icons.tune);
      expect(tuneIconFinder, findsOneWidget);
      final tuneIcon = tester.widget<Icon>(tuneIconFinder);
      expect(tuneIcon.color, const Color(0xFF80C652));
    });

    testWidgets('renders storefront buttons with #2D402A background and #80C652 color in dark mode', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestableAnalysisScreen());
      // Advance past the 600ms loading delay in initState
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();

      final storefrontFinder = find.byIcon(Icons.storefront);
      expect(storefrontFinder, findsWidgets);

      // Verify IconButton style
      final iconButtons = tester.widgetList<IconButton>(
        find.ancestor(
          of: storefrontFinder,
          matching: find.byType(IconButton),
        ),
      );
      expect(iconButtons.isNotEmpty, isTrue);
      final firstButton = iconButtons.first;
      expect(firstButton.style?.backgroundColor?.resolve({}), const Color(0xFF2D402A));
      expect(firstButton.style?.foregroundColor?.resolve({}), const Color(0xFF80C652));
    });
  });

  group('MarketPriceDetailScreen Dark Mode Tests', () {
    final mockItem = {
      'name': 'Arroz Campo',
      'sku': 'SKU-A01',
      'price': '23.07',
      'unit': 'kg',
      'trend': 2.1,
    };
    final mockProduct = {
      'id': 'arroz',
      'name': 'Arroz',
      'avgPrice': '23.07',
      'unit': 'kg',
      'category': 'Granos',
      'imageUrl': '',
      'icon': Icons.grain,
    };

    Widget buildTestableDetailScreen({bool isDark = true}) {
      return MaterialApp(
        theme: isDark ? ThemeData.dark() : ThemeData.light(),
        home: MarketPriceDetailScreen(
          item: mockItem,
          product: mockProduct,
          isWholesale: true,
        ),
      );
    }

    testWidgets('applies dark background and surface colors in dark mode', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestableDetailScreen(isDark: true));
      await tester.pumpAndSettle();

      // Check Scaffold background is dark
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, const Color(0xFF0F1C18));

      // Check back button color is #80C652
      final backIcon = tester.widget<Icon>(find.byIcon(Icons.arrow_back_rounded));
      expect(backIcon.color, const Color(0xFF80C652));

      // Check title 'Arroz Campo'
      expect(find.text('Arroz Campo'), findsOneWidget);

      // Check section 'Tendencia de Precios'
      expect(find.text('Tendencia de Precios'), findsOneWidget);

      // Check 'Reporte Oficial del Día'
      expect(find.text('Reporte Oficial del Día'), findsOneWidget);

      // Check stats labels
      expect(find.text('MÍNIMO'), findsOneWidget);
      expect(find.text('PROMEDIO'), findsOneWidget);
      expect(find.text('MÁXIMO'), findsOneWidget);

      // Check Disclaimer Banner
      expect(find.textContaining('El precio de mercado se reporta oficialmente'), findsOneWidget);
    });

    testWidgets('renders light theme colors correctly in light mode', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestableDetailScreen(isDark: false));
      await tester.pumpAndSettle();

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, const Color(0xFFF8F9FF));

      final backIcon = tester.widget<Icon>(find.byIcon(Icons.arrow_back_rounded));
      expect(backIcon.color, const Color(0xFF004532));
    });
  });
}
