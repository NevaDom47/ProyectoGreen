import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:app_mercadito/models/notification_item.dart';
import 'package:app_mercadito/screens/notification_emulator_screen.dart';
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

  group('InAppNotificationHost & NotificationEmulatorScreen widget tests', () {
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

    testWidgets(
        'NotificationEmulatorScreen renders all 8 categories cleanly on 1080x2400 without overflow and triggers En App banner',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          builder: (context, child) => InAppNotificationHost(
            displayDuration: const Duration(seconds: 2),
            child: child ?? const SizedBox.shrink(),
          ),
          home: const NotificationEmulatorScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Emulador de Notificaciones'), findsOneWidget);
      expect(find.text('Dentro de la App'), findsOneWidget);
      expect(find.text('Fuera de la App'), findsOneWidget);
      expect(find.text('CATEGORÍAS INDIVIDUALES (8)'), findsOneWidget);

      // Verificar cada una de las 8 categorías haciendo scroll limpio
      for (final preset in NotificationEmulatorCatalog.allPresets) {
        final labelFinder = find.text(preset.categoryLabel);
        await tester.scrollUntilVisible(
          labelFinder,
          240,
          scrollable: find.byType(Scrollable).first,
        );
        expect(labelFinder, findsWidgets);
      }

      // Regresar arriba y pulsar "En App" en Pedidos
      await tester.scrollUntilVisible(
        find.text('Emulación por Modalidad'),
        -300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      final firstEnAppButton = find.widgetWithText(OutlinedButton, 'En App').first;
      await tester.ensureVisible(firstEnAppButton);
      await tester.pumpAndSettle();
      await tester.tap(firstEnAppButton);
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('En la app • Ahora'), findsOneWidget);
      expect(find.text('Tu pedido #MERC-9942 salió a entrega'), findsWidgets);

      // Cerrar banner y cambiar a modo Fuera de la App para comprobar switch de minimizar
      final closeBtn = find.byKey(const ValueKey('close_in_app_banner_button'));
      if (closeBtn.evaluate().isNotEmpty) {
        await tester.tap(closeBtn);
        await tester.pumpAndSettle();
      }

      await tester.scrollUntilVisible(
        find.text('Fuera de la App'),
        -300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Fuera de la App'));
      await tester.pumpAndSettle();

      expect(find.text('Minimizar app al enviar'), findsOneWidget);
      expect(
        find.text('Emular las 8 categorías (Fuera de la App)'),
        findsOneWidget,
      );

      final exception = tester.takeException();
      expect(exception, isNull);
    });

    testWidgets('GoRouter MaterialApp.router integration renders InAppNotificationHost banner on top of /notification-emulator',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final navKey = GlobalKey<NavigatorState>();
      final router = GoRouter(
        navigatorKey: navKey,
        initialLocation: '/notification-emulator',
        routes: [
          GoRoute(
            path: '/notification-emulator',
            builder: (context, state) => const NotificationEmulatorScreen(),
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

      expect(find.text('Emulador de Notificaciones'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Pedidos'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

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
