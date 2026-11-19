import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:app_mercadito/models/notification_item.dart';
import 'package:app_mercadito/services/native_notification_bridge.dart';
import 'package:app_mercadito/services/notification_emulator_catalog.dart';
import 'package:app_mercadito/services/notification_service.dart';
import 'package:app_mercadito/theme/app_theme.dart';
import 'package:app_mercadito/widgets/in_app_notification_host.dart';

void main() {
  late NotificationService service;

  setUp(() {
    service = NotificationService();
    service.toggleNotificationsEnabled(true);
    service.clearActiveInAppBanner();
    service.notifications.value = [];
    service.markAllAsRead();
  });

  group('NotificationEmulatorCatalog & Bridge metadata', () {
    test('covers all 8 concrete NotificationCategory values without duplicates', () {
      final expectedCategories = NotificationCategory.values
          .where((c) => c != NotificationCategory.todos)
          .toList();

      expect(NotificationEmulatorCatalog.allPresets.length, expectedCategories.length);
      expect(NotificationEmulatorCatalog.allPresets.length, 8);

      final presentCategories =
          NotificationEmulatorCatalog.allPresets.map((p) => p.category).toSet();
      expect(presentCategories, expectedCategories.toSet());

      for (final category in expectedCategories) {
        final meta = NativeNotificationBridge.categoryMetadata(category);
        expect(meta.key, isNotEmpty);
        expect(meta.label, isNotEmpty);
        expect(meta.defaultRoute.startsWith('/'), isTrue);
      }
    });

    test('emitCategoryDemo in-app adds item, updates unreadCount, and emits stream event', () async {
      final received = <NotificationItem>[];
      final sub = service.inAppBannerStream.listen(received.add);
      addTearDown(sub.cancel);

      final expectedCategories = NotificationCategory.values
          .where((c) => c != NotificationCategory.todos)
          .toList();

      for (final cat in expectedCategories) {
        service.emitCategoryDemo(cat, isExternal: false);
      }

      // Permitir entrega asíncrona de eventos del broadcast stream.
      await Future<void>.delayed(Duration.zero);

      expect(received.length, 8);
      expect(service.notifications.value.length, 8);
      expect(service.unreadCount.value, 8);
      expect(received.map((e) => e.category).toSet(), expectedCategories.toSet());
    });
  });

  group('InAppNotificationHost widget tests', () {
    testWidgets('InAppNotificationHost renders banner in Light & Dark mode and dismisses cleanly',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // Modo Día
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.light,
          builder: (context, child) => InAppNotificationHost(
            displayDuration: const Duration(milliseconds: 500),
            child: child ?? const SizedBox.shrink(),
          ),
          home: const Scaffold(body: Center(child: Text('Base Screen'))),
        ),
      );
      await tester.pumpAndSettle();

      service.emitCategoryDemo(NotificationCategory.pedidos, isExternal: false);
      await tester.pump(); // flushes microtask -> sets state & starts ticker
      await tester.pump(); // builds widget & anchors ticker startTime
      await tester.pump(const Duration(milliseconds: 290)); // completes slide-in (280ms)

      expect(find.text('Tu pedido #MERC-9942 salió a entrega'), findsOneWidget);
      expect(find.text('En la app • Ahora'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('close_in_app_banner_button')));
      await tester.pumpAndSettle();
      expect(find.text('Tu pedido #MERC-9942 salió a entrega'), findsNothing);

      // Modo Noche
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.dark,
          builder: (context, child) => InAppNotificationHost(
            displayDuration: const Duration(milliseconds: 500),
            child: child ?? const SizedBox.shrink(),
          ),
          home: const Scaffold(body: Center(child: Text('Dark Screen'))),
        ),
      );
      await tester.pumpAndSettle();

      service.emitCategoryDemo(NotificationCategory.negociaciones, isExternal: false);
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 290));

      expect(find.text('Contraoferta recibida de Juan Agro'), findsOneWidget);
      expect(find.text('URGENTE'), findsNothing);

      // Esperar auto-cierre limpio sin fugas de timer.
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pumpAndSettle();
      expect(find.text('Contraoferta recibida de Juan Agro'), findsNothing);
    });

    testWidgets('GoRouter MaterialApp.router integration renders InAppNotificationHost banner on top of route',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final navKey = GlobalKey<NavigatorState>();
      final router = GoRouter(
        navigatorKey: navKey,
        initialLocation: '/home',
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Home Route')),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          routerConfig: router,
          builder: (context, child) => InAppNotificationHost(
            navigatorKey: navKey,
            displayDuration: const Duration(seconds: 2),
            child: child ?? const SizedBox.shrink(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Home Route'), findsOneWidget);

      service.emitCategoryDemo(NotificationCategory.pedidos, isExternal: false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 260));

      expect(find.text('En la app • Ahora'), findsOneWidget);
      expect(find.text('Tu pedido #MERC-9942 salió a entrega'), findsWidgets);

      final rect = tester.getRect(find.byKey(const ValueKey('in_app_banner_card')));
      expect(rect.width, greaterThan(200));
      expect(rect.height, greaterThan(60));
      expect(rect.top, greaterThanOrEqualTo(0));
      expect(rect.bottom, lessThan(400));

      await tester.tap(find.byKey(const ValueKey('close_in_app_banner_button')));
      await tester.pumpAndSettle();
      expect(find.text('En la app • Ahora'), findsNothing);
    });
  });
}
