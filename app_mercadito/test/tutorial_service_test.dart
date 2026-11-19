import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_mercadito/services/tutorial_service.dart';
import 'package:app_mercadito/services/user_session.dart';
import 'package:app_mercadito/widgets/custom_bottom_nav_bar.dart';
import 'package:app_mercadito/screens/add_product_screen.dart';
import 'package:app_mercadito/screens/tasks_screen.dart';
import 'package:app_mercadito/screens/negotiations_screen.dart';
import 'package:app_mercadito/screens/coupons_manager_screen.dart';
import 'package:app_mercadito/screens/flash_offers_manager_screen.dart';
import 'package:app_mercadito/screens/market_analysis_screen.dart';
import 'package:app_mercadito/screens/settings_screen.dart';
import 'package:app_mercadito/data/global_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TutorialService & In-App Guide Tests', () {
    setUp(() {
      UserSession.hasSeenNavTutorial = false;
      UserSession.hasSeenAddProductTutorial = false;
      UserSession.hasSeenTasksTutorial = false;
      UserSession.hasSeenNegotiationsTutorial = false;
      UserSession.hasSeenCouponsManagerTutorial = false;
      UserSession.hasSeenFlashOffersManagerTutorial = false;
      UserSession.hasSeenMarketAnalysisTutorial = false;
    });

    test('TutorialService singleton initializes and checks seen state', () {
      final service = TutorialService();
      expect(service, isNotNull);
      expect(service.isTutorialActive, false);
      expect(UserSession.hasSeenNavTutorial, false);
      expect(UserSession.hasSeenAddProductTutorial, false);
      expect(UserSession.hasSeenTasksTutorial, false);
      expect(UserSession.hasSeenNegotiationsTutorial, false);
      expect(UserSession.hasSeenCouponsManagerTutorial, false);
      expect(UserSession.hasSeenFlashOffersManagerTutorial, false);
      expect(UserSession.hasSeenMarketAnalysisTutorial, false);
    });

    test('UserSession.clear resets all 5 tutorial flags', () {
      UserSession.hasSeenTasksTutorial = true;
      UserSession.hasSeenNegotiationsTutorial = true;
      UserSession.hasSeenCouponsManagerTutorial = true;
      UserSession.hasSeenFlashOffersManagerTutorial = true;
      UserSession.hasSeenMarketAnalysisTutorial = true;

      UserSession.clear();

      expect(UserSession.hasSeenTasksTutorial, false);
      expect(UserSession.hasSeenNegotiationsTutorial, false);
      expect(UserSession.hasSeenCouponsManagerTutorial, false);
      expect(UserSession.hasSeenFlashOffersManagerTutorial, false);
      expect(UserSession.hasSeenMarketAnalysisTutorial, false);
    });

    testWidgets('showNavTutorial executes safely in test environment and updates session', (tester) async {
      final homeKey = GlobalKey();
      final cartKey = GlobalKey();
      final marketKey = GlobalKey();
      final providersKey = GlobalKey();
      final chatsKey = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: Row(
              children: [
                IconButton(key: homeKey, icon: const Icon(Icons.home), onPressed: () {}),
                IconButton(key: cartKey, icon: const Icon(Icons.shopping_cart), onPressed: () {}),
                IconButton(key: marketKey, icon: const Icon(Icons.storefront), onPressed: () {}),
                IconButton(key: providersKey, icon: const Icon(Icons.person), onPressed: () {}),
                IconButton(key: chatsKey, icon: const Icon(Icons.chat), onPressed: () {}),
              ],
            ),
          ),
        ),
      );

      bool finished = false;
      TutorialService().showNavTutorial(
        tester.element(find.byType(Scaffold)),
        homeKey: homeKey,
        cartKey: cartKey,
        marketKey: marketKey,
        providersKey: providersKey,
        chatsKey: chatsKey,
        onFinish: () {
          finished = true;
        },
      );

      expect(UserSession.hasSeenNavTutorial, true);
      expect(finished, true);
    });

    testWidgets('CustomBottomNavBar assigns GlobalKeys for tutorial coach marks', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(child: Text('Contenido')),
            bottomNavigationBar: CustomBottomNavBar(currentIndex: 0),
          ),
        ),
      );

      // Verify CustomBottomNavBar renders with all 5 items
      expect(find.byType(CustomBottomNavBar), findsOneWidget);
      expect(find.text('Inicio'), findsOneWidget);
      expect(find.text('Carrito'), findsOneWidget);
      expect(find.text('Mercado'), findsOneWidget);
      expect(find.text('Proveedores'), findsOneWidget);
      expect(find.text('Chats'), findsOneWidget);

      // Verify startTutorial static method can be called without exception
      CustomBottomNavBar.startTutorial(tester.element(find.byType(CustomBottomNavBar)), force: true);
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('SettingsScreen does not display Tutorial y Guia Interactiva option', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Tutorial y Guía Interactiva'), findsNothing);
      expect(find.text('Repetir'), findsNothing);
    });

    testWidgets('showAddProductTutorial executes safely in test environment and updates session', (tester) async {
      final previewKey = GlobalKey();
      final mediaKey = GlobalKey();
      final basicInfoKey = GlobalKey();
      final pricingKey = GlobalKey();
      final saveButtonKey = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                SizedBox(key: previewKey, height: 20),
                SizedBox(key: mediaKey, height: 20),
                SizedBox(key: basicInfoKey, height: 20),
                SizedBox(key: pricingKey, height: 20),
                SizedBox(key: saveButtonKey, height: 20),
              ],
            ),
          ),
        ),
      );

      bool finished = false;
      TutorialService().showAddProductTutorial(
        tester.element(find.byType(Scaffold)),
        previewKey: previewKey,
        mediaKey: mediaKey,
        basicInfoKey: basicInfoKey,
        pricingKey: pricingKey,
        saveButtonKey: saveButtonKey,
        onFinish: () {
          finished = true;
        },
      );

      expect(UserSession.hasSeenAddProductTutorial, true);
      expect(finished, true);
    });

    testWidgets('AddProductScreen assigns GlobalKeys and startTutorial executes cleanly', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: AddProductScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Vista Previa en Tarjeta Principal'), findsOneWidget);
      expect(find.text('Fotografías del Producto'), findsOneWidget);
      expect(find.text('GUARDAR PRODUCTO'), findsOneWidget);

      expect(AddProductScreen.tutorialPreviewKey.currentContext, isNotNull);
      expect(AddProductScreen.tutorialMediaKey.currentContext, isNotNull);
      expect(AddProductScreen.tutorialBasicInfoKey.currentContext, isNotNull);
      expect(AddProductScreen.tutorialPricingKey.currentContext, isNotNull);
      expect(AddProductScreen.tutorialSaveButtonKey.currentContext, isNotNull);

      AddProductScreen.startTutorial(
        tester.element(find.byType(AddProductScreen)),
        force: true,
      );
      await tester.pump(const Duration(seconds: 1));
      expect(UserSession.hasSeenAddProductTutorial, true);
    });

    testWidgets('showTasksTutorial executes safely in test environment and updates session', (tester) async {
      final streakKey = GlobalKey();
      final summaryKey = GlobalKey();
      final listKey = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                SizedBox(key: streakKey, height: 20),
                SizedBox(key: summaryKey, height: 20),
                SizedBox(key: listKey, height: 20),
              ],
            ),
          ),
        ),
      );

      bool finished = false;
      TutorialService().showTasksTutorial(
        tester.element(find.byType(Scaffold)),
        streakBannerKey: streakKey,
        dailySummaryKey: summaryKey,
        taskListKey: listKey,
        onFinish: () {
          finished = true;
        },
      );

      expect(UserSession.hasSeenTasksTutorial, true);
      expect(finished, true);
    });

    testWidgets('TasksScreen assigns GlobalKeys and startTutorial executes cleanly', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: TasksScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TasksScreen), findsOneWidget);
      expect(TasksScreen.tutorialStreakBannerKey.currentContext, isNotNull);
      expect(TasksScreen.tutorialDailySummaryKey.currentContext, isNotNull);
      expect(TasksScreen.tutorialTaskListKey.currentContext, isNotNull);

      TasksScreen.startTutorial(
        tester.element(find.byType(TasksScreen)),
        force: true,
      );
      await tester.pump(const Duration(seconds: 1));
      expect(UserSession.hasSeenTasksTutorial, true);
    });

    testWidgets('showNegotiationsTutorial executes safely and updates session', (tester) async {
      final tabsKey = GlobalKey();
      final filterKey = GlobalKey();
      final cardKey = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                SizedBox(key: tabsKey, height: 20),
                SizedBox(key: filterKey, height: 20),
                SizedBox(key: cardKey, height: 20),
              ],
            ),
          ),
        ),
      );

      bool finished = false;
      TutorialService().showNegotiationsTutorial(
        tester.element(find.byType(Scaffold)),
        tabsKey: tabsKey,
        searchFilterKey: filterKey,
        negotiationCardKey: cardKey,
        onFinish: () => finished = true,
      );

      expect(UserSession.hasSeenNegotiationsTutorial, true);
      expect(finished, true);
    });

    testWidgets('NegotiationsScreen assigns GlobalKeys and startTutorial executes cleanly', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: NegotiationsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(NegotiationsScreen), findsOneWidget);
      expect(NegotiationsScreen.tutorialTabsKey.currentContext, isNotNull);
      expect(NegotiationsScreen.tutorialSearchFilterKey.currentContext, isNotNull);
      expect(NegotiationsScreen.tutorialCardKey.currentContext, isNotNull);

      NegotiationsScreen.startTutorial(
        tester.element(find.byType(NegotiationsScreen)),
        force: true,
      );
      await tester.pump(const Duration(seconds: 1));
      expect(UserSession.hasSeenNegotiationsTutorial, true);
    });

    testWidgets('showCouponsManagerTutorial executes safely and updates session', (tester) async {
      final metricsKey = GlobalKey();
      final filterKey = GlobalKey();
      final createKey = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                SizedBox(key: metricsKey, height: 20),
                SizedBox(key: filterKey, height: 20),
                SizedBox(key: createKey, height: 20),
              ],
            ),
          ),
        ),
      );

      bool finished = false;
      TutorialService().showCouponsManagerTutorial(
        tester.element(find.byType(Scaffold)),
        metricsKey: metricsKey,
        searchFilterKey: filterKey,
        createButtonKey: createKey,
        onFinish: () => finished = true,
      );

      expect(UserSession.hasSeenCouponsManagerTutorial, true);
      expect(finished, true);
    });

    testWidgets('CouponsManagerScreen assigns GlobalKeys and startTutorial executes cleanly', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: CouponsManagerScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CouponsManagerScreen), findsOneWidget);
      expect(CouponsManagerScreen.tutorialMetricsKey.currentContext, isNotNull);
      expect(CouponsManagerScreen.tutorialSearchFilterKey.currentContext, isNotNull);
      expect(CouponsManagerScreen.tutorialCreateButtonKey.currentContext, isNotNull);

      CouponsManagerScreen.startTutorial(
        tester.element(find.byType(CouponsManagerScreen)),
        force: true,
      );
      await tester.pump(const Duration(seconds: 1));
      expect(UserSession.hasSeenCouponsManagerTutorial, true);
    });

    testWidgets('showFlashOffersManagerTutorial executes safely and updates session', (tester) async {
      final tabsKey = GlobalKey();
      final bannerKey = GlobalKey();
      final actionKey = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                SizedBox(key: tabsKey, height: 20),
                SizedBox(key: bannerKey, height: 20),
                SizedBox(key: actionKey, height: 20),
              ],
            ),
          ),
        ),
      );

      bool finished = false;
      TutorialService().showFlashOffersManagerTutorial(
        tester.element(find.byType(Scaffold)),
        tabsKey: tabsKey,
        activeBannerKey: bannerKey,
        newOfferActionKey: actionKey,
        onFinish: () => finished = true,
      );

      expect(UserSession.hasSeenFlashOffersManagerTutorial, true);
      expect(finished, true);
    });

    testWidgets('FlashOffersManagerScreen assigns GlobalKeys and startTutorial executes cleanly', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        stopGlobalFlashTimer();
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: FlashOffersManagerScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(FlashOffersManagerScreen), findsOneWidget);
      expect(FlashOffersManagerScreen.tutorialTabsKey.currentContext, isNotNull);
      expect(FlashOffersManagerScreen.tutorialActiveBannerKey.currentContext, isNotNull);
      expect(FlashOffersManagerScreen.tutorialNewOfferActionKey.currentContext, isNotNull);

      FlashOffersManagerScreen.startTutorial(
        tester.element(find.byType(FlashOffersManagerScreen)),
        force: true,
      );
      await tester.pump(const Duration(seconds: 1));
      expect(UserSession.hasSeenFlashOffersManagerTutorial, true);
    });

    testWidgets('showMarketAnalysisTutorial executes safely and updates session', (tester) async {
      final tabsKey = GlobalKey();
      final switchKey = GlobalKey();
      final listKey = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                SizedBox(key: tabsKey, height: 20),
                SizedBox(key: switchKey, height: 20),
                SizedBox(key: listKey, height: 20),
              ],
            ),
          ),
        ),
      );

      bool finished = false;
      TutorialService().showMarketAnalysisTutorial(
        tester.element(find.byType(Scaffold)),
        tabsKey: tabsKey,
        modeSwitchKey: switchKey,
        pricesListKey: listKey,
        onFinish: () => finished = true,
      );

      expect(UserSession.hasSeenMarketAnalysisTutorial, true);
      expect(finished, true);
    });

    testWidgets('MarketAnalysisScreen assigns GlobalKeys and startTutorial executes cleanly', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: MarketAnalysisScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(MarketAnalysisScreen), findsOneWidget);
      expect(MarketAnalysisScreen.tutorialTabsKey.currentContext, isNotNull);
      expect(MarketAnalysisScreen.tutorialModeSwitchKey.currentContext, isNotNull);
      expect(MarketAnalysisScreen.tutorialPricesListKey.currentContext, isNotNull);

      MarketAnalysisScreen.startTutorial(
        tester.element(find.byType(MarketAnalysisScreen)),
        force: true,
      );
      await tester.pump(const Duration(seconds: 1));
      expect(UserSession.hasSeenMarketAnalysisTutorial, true);
    });
  });
}
