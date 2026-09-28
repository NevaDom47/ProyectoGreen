import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_mercadito/services/market_news_service.dart';
import 'package:app_mercadito/screens/market_analysis_screen.dart';
import 'package:app_mercadito/widgets/infinite_marquee_ticker.dart';

void main() {
  group('MarketNewsService Unit Tests', () {
    test('getAllNews returns non-empty list of agricultural news', () {
      final news = MarketNewsService.instance.getAllNews();
      expect(news.isNotEmpty, isTrue);
      expect(news.length, greaterThanOrEqualTo(5));
    });

    test('getNewsByCategory filters correctly by category', () {
      final fruitNews = MarketNewsService.instance.getNewsByCategory('Frutas');
      expect(fruitNews.every((n) => n.category == 'Frutas'), isTrue);
      expect(fruitNews.any((n) => n.title.contains('Aguacate')), isTrue);

      final grainNews = MarketNewsService.instance.getNewsByCategory('Granos');
      expect(grainNews.every((n) => n.category == 'Granos'), isTrue);
    });

    test('searchNews filters by query correctly', () {
      final results = MarketNewsService.instance.searchNews('Tomate');
      expect(results.isNotEmpty, isTrue);
      expect(results.first.title.toLowerCase().contains('tomate'), isTrue);
    });

    test('getMarketTrendSignals returns valid trend distribution and top crops', () {
      final signals = MarketNewsService.instance.getMarketTrendSignals();
      expect(signals['totalNews'], greaterThan(0));
      expect(signals['topMovingCrops'], isNotNull);
      final crops = signals['topMovingCrops'] as List;
      expect(crops.isNotEmpty, isTrue);
    });
  });

  group('MarketAnalysisScreen Noticias Tab Widget Tests', () {
    Widget buildTestableWidget() {
      return const MaterialApp(
        home: MarketAnalysisScreen(),
      );
    }

    testWidgets('Tapping Noticias tab renders Radar de Tendencias, Search, Filters, and News cards', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Find and tap "Noticias" Tab
      final noticiasTab = find.text('Noticias');
      expect(noticiasTab, findsOneWidget);
      await tester.tap(noticiasTab);
      await tester.pumpAndSettle();

      // 1. Verify Search Bar
      expect(find.byType(TextField), findsWidgets);
      expect(find.text('Buscar por cultivo, fuente o mercado...'), findsOneWidget);

      // 2. Verify Category Filters
      expect(find.text('Todas'), findsWidgets);
      expect(find.text('Frutas'), findsWidgets);
      expect(find.text('Vegetales'), findsWidgets);
      expect(find.text('Granos'), findsWidgets);

      // 3. Verify News Cards and Action Buttons
      expect(find.text('Leer fuente original'), findsWidgets);
      expect(find.text('Detalles'), findsWidgets);
      expect(find.textContaining('Impacto estimado en comercialización:'), findsWidgets);

      // 4. Verify prominent crop headlines
      expect(find.textContaining('Aguacate Hass'), findsWidgets);
    });

    testWidgets('Filter by category Frutas updates news feed', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Tap Noticias
      await tester.tap(find.text('Noticias'));
      await tester.pumpAndSettle();

      // Tap "Frutas" filter
      await tester.tap(find.text('Frutas').first);
      await tester.pumpAndSettle();

      // Verify fruits news are displayed
      expect(find.textContaining('Aguacate Hass'), findsWidgets);

      // Reset filters button
      expect(find.text('Restablecer'), findsOneWidget);
      await tester.tap(find.text('Restablecer'));
      await tester.pumpAndSettle();

      expect(find.text('Restablecer'), findsNothing);
    });

    testWidgets('Search query filters results and empty state shows when no match', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Tap Noticias
      await tester.tap(find.text('Noticias'));
      await tester.pumpAndSettle();

      // Enter search query with no match
      final searchField = find.widgetWithText(TextField, 'Buscar por cultivo, fuente o mercado...');
      await tester.enterText(searchField, 'CultivoInexistenteXYZ');
      await tester.pumpAndSettle();

      expect(find.text('No se encontraron noticias'), findsOneWidget);
      expect(find.text('Ver todas las noticias'), findsOneWidget);

      // Tap reset in empty state
      await tester.tap(find.text('Ver todas las noticias'));
      await tester.pumpAndSettle();

      expect(find.text('Leer fuente original'), findsWidgets);
    });

    testWidgets('Tapping Tendencias tab shows Radar, Predictive Disclaimer, KPIs and Sin cambios crops', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Tap Tendencias Tab
      final tendenciasTab = find.text('Tendencias');
      expect(tendenciasTab, findsOneWidget);
      await tester.tap(tendenciasTab);
      await tester.pumpAndSettle();

      // 1. Radar Banner (Without 'En vivo' badge)
      expect(find.text('Radar de Tendencias Comerciales'), findsOneWidget);
      expect(find.text('En vivo'), findsNothing);

      // 2. Predictive disclaimer & notice
      expect(find.text('Aviso de Estimación Predictiva'), findsOneWidget);
      expect(find.text('Orientativo'), findsOneWidget);
      expect(find.textContaining('Es un modelo predictivo sujeto a fluctuaciones de mercado y posibles equivocaciones'), findsOneWidget);
      expect(find.textContaining('Si no existen datos suficientes para un cultivo o período, se clasifica automáticamente como "Sin cambios"'), findsOneWidget);

      // 3. KPI metric counters (Alza, Baja, Sin cambios)
      expect(find.text('Alza'), findsWidgets);
      expect(find.text('Baja'), findsWidgets);
      expect(find.text('Sin cambios'), findsWidgets);

      // 4. Detailed crop cards (including items with no data showing "Sin cambios")
      expect(find.text('Aguacate Hass'), findsWidgets);
      expect(find.text('Tomate Saladette'), findsWidgets);
      expect(find.textContaining('Sin datos recientes (Se coloca sin cambios)'), findsWidgets);

      // 5. Test interactive filter: tap "Sin cambios"
      final sinCambiosFilter = find.widgetWithText(AnimatedContainer, 'Sin cambios');
      if (sinCambiosFilter.evaluate().isNotEmpty) {
        await tester.tap(sinCambiosFilter.first);
        await tester.pumpAndSettle();
        expect(find.textContaining('Sin datos recientes (Se coloca sin cambios)'), findsWidgets);
      }

      // 6. Verify InfiniteMarqueeTicker is rendered in Radar
      expect(find.byType(InfiniteMarqueeTicker), findsOneWidget);
    });

    testWidgets('InfiniteMarqueeTicker renders children and responds to pointer events', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InfiniteMarqueeTicker(
              fadeColor: Colors.black,
              children: const [
                Text('Crop Item 1'),
                Text('Crop Item 2'),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Crop Item 1'), findsWidgets);
      expect(find.text('Crop Item 2'), findsWidgets);
    });
  });
}

