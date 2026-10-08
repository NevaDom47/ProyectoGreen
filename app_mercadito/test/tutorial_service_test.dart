import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_mercadito/services/tutorial_service.dart';
import 'package:app_mercadito/services/user_session.dart';
import 'package:app_mercadito/widgets/custom_bottom_nav_bar.dart';
import 'package:app_mercadito/screens/settings_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TutorialService & In-App Guide Tests', () {
    setUp(() {
      UserSession.hasSeenNavTutorial = false;
    });

    test('TutorialService singleton initializes and checks seen state', () {
      final service = TutorialService();
      expect(service, isNotNull);
      expect(service.isTutorialActive, false);
      expect(UserSession.hasSeenNavTutorial, false);
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

    testWidgets('SettingsScreen displays Tutorial y Guia Interactiva option', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Tutorial y Guía Interactiva'), findsOneWidget);
      expect(find.text('Repetir'), findsOneWidget);
    });
  });
}
