import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_mercadito/models/notification_item.dart';
import 'package:app_mercadito/services/notification_service.dart';
import 'package:app_mercadito/screens/notifications_screen.dart';
import 'package:app_mercadito/theme/app_theme.dart';

void main() {
  late NotificationService service;

  setUp(() {
    service = NotificationService();
    // Reset to fresh state
    service.notifications.value = [
      NotificationItem(
        id: 'test-1',
        title: 'Tu pedido #MERC-9928 está en camino!',
        description: 'El transportista ya recolectó tus productos.',
        category: NotificationCategory.pedidos,
        priority: NotificationPriority.important,
        timeAgo: '2 min',
        timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
        dateGroup: 'HOY',
        icon: Icons.local_shipping,
        actions: [
          const NotificationAction(
            label: 'Ver pedido',
            type: NotificationActionType.viewOrder,
            isPrimary: true,
          ),
        ],
        isRead: false,
      ),
      NotificationItem(
        id: 'test-2',
        title: 'Nueva oferta de Juan Pérez',
        description: 'El proveedor Juan Pérez envió una contraoferta por tus Aguacates Hass.',
        category: NotificationCategory.negociaciones,
        priority: NotificationPriority.important,
        timeAgo: '1 h',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        dateGroup: 'HOY',
        icon: Icons.chat_bubble_rounded,
        priceTag: 'RD\$ 8,500',
        actions: [
          const NotificationAction(
            label: 'Aceptar',
            type: NotificationActionType.acceptOffer,
            isPrimary: true,
          ),
          const NotificationAction(
            label: 'Contraofertar',
            type: NotificationActionType.counterOffer,
            isPrimary: false,
          ),
        ],
        isRead: false,
      ),
      NotificationItem(
        id: 'test-3',
        title: '¡Cupón de 20% OFF disponible!',
        description: 'Aprovecha este descuento exclusivo.',
        category: NotificationCategory.cupones,
        priority: NotificationPriority.important,
        timeAgo: '3 h',
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        dateGroup: 'HOY',
        icon: Icons.confirmation_number_rounded,
        actions: [
          const NotificationAction(
            label: 'Usar cupón',
            type: NotificationActionType.viewCoupon,
            isPrimary: true,
          ),
        ],
        isRead: false,
      ),
      NotificationItem(
        id: 'test-4',
        title: 'Nueva cosecha en Huerta Los Arcos',
        description: 'Mira el nuevo video de la cosecha de tomates.',
        category: NotificationCategory.vendedores,
        priority: NotificationPriority.info,
        timeAgo: '1 d',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        dateGroup: 'AYER',
        icon: Icons.videocam_rounded,
        isVideoMedia: true,
        actions: [
          const NotificationAction(
            label: 'Ver productos',
            type: NotificationActionType.viewVendor,
            isPrimary: true,
          ),
        ],
        isRead: true,
      ),
    ];
    service.markAsRead('test-4'); // Ensure test-4 is read, 1, 2, 3 unread
  });

  group('NotificationService unit tests', () {
    test('Calculates unread count accurately', () {
      expect(service.unreadCount.value, 3);
    });

    test('markAsRead updates item state and decrements unread count', () {
      service.markAsRead('test-1');
      final item = service.notifications.value.firstWhere((n) => n.id == 'test-1');
      expect(item.isRead, isTrue);
      expect(service.unreadCount.value, 2);
    });

    test('markAllAsRead marks all items read and zeroes unread count', () {
      service.markAllAsRead();
      expect(service.unreadCount.value, 0);
      expect(service.notifications.value.every((n) => n.isRead), isTrue);
    });

    test('completeAction updates completion status and message', () {
      service.completeAction('test-2', 'Oferta aceptada por RD\$ 8,500');
      final item = service.notifications.value.firstWhere((n) => n.id == 'test-2');
      expect(item.isActionCompleted, isTrue);
      expect(item.actionCompletedMessage, 'Oferta aceptada por RD\$ 8,500');
    });

    test('dismiss removes notification from list', () {
      service.dismiss('test-3');
      expect(service.notifications.value.any((n) => n.id == 'test-3'), isFalse);
    });

    test('getDailyMarketSummary calculates metrics properly', () {
      final summary = service.getDailyMarketSummary();
      expect(summary.activeNegotiations, greaterThanOrEqualTo(1));
      expect(summary.ordersInProgress, greaterThanOrEqualTo(1));
    });

    test('toggleNotificationsEnabled(false) deactivates all notification channels and options', () {
      service.toggleNotificationsEnabled(true);
      expect(service.preferences.value.notificationsEnabled, isTrue);
      expect(service.preferences.value.pushEnabled, isTrue);
      expect(service.preferences.value.inAppEnabled, isTrue);

      service.toggleNotificationsEnabled(false);
      final prefs = service.preferences.value;
      expect(prefs.notificationsEnabled, isFalse);
      expect(prefs.pushEnabled, isFalse);
      expect(prefs.inAppEnabled, isFalse);
      expect(prefs.quietHoursEnabled, isFalse);
      expect(prefs.allowUrgentDuringQuietHours, isFalse);
      expect(prefs.orderUpdates, isFalse);
      expect(prefs.chatMessages, isFalse);
      expect(prefs.counterOffers, isFalse);
      expect(prefs.flashSales, isFalse);
      expect(prefs.newCoupons, isFalse);
      expect(prefs.priceDrops, isFalse);
      expect(prefs.followedSellers, isFalse);
      expect(prefs.marketTrends, isFalse);
      expect(prefs.smartRecommendations, isFalse);
      expect(prefs.categoryChannels.values.every((v) => v == false), isTrue);
      expect(service.unreadCount.value, 0);

      // Re-enabling restores options
      service.toggleNotificationsEnabled(true);
      expect(service.preferences.value.notificationsEnabled, isTrue);
      expect(service.preferences.value.pushEnabled, isTrue);
    });
  });

  group('NotificationsScreen widget tests', () {
    testWidgets('renders header, tabs, and notifications list', (tester) async {
      tester.view.physicalSize = const Size(1000, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          home: const NotificationsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Header checks
      expect(find.text('Notificaciones'), findsOneWidget);
      expect(find.byIcon(Icons.done_all_rounded), findsOneWidget);
      expect(find.byIcon(Icons.tune_rounded), findsOneWidget);

      // Tab bar checks
      expect(find.text('Todo'), findsOneWidget);
      expect(find.text('Pedidos'), findsOneWidget);
      expect(find.text('Negociaciones'), findsWidgets);
      expect(find.text('Cupones'), findsOneWidget);
      expect(find.text('Vendedores'), findsOneWidget);

      // Bento Summary eliminado
      expect(find.text('Resumen de tu Mercado'), findsNothing);

      // Notification cards
      expect(find.text('Tu pedido #MERC-9928 está en camino!'), findsOneWidget);
      expect(find.text('Nueva oferta de Juan Pérez'), findsOneWidget);
      expect(find.text('¡Cupón de 20% OFF disponible!'), findsOneWidget);
    });

    testWidgets('filters by category tab when tapped', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          home: const NotificationsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on "Pedidos"
      await tester.tap(find.text('Pedidos'));
      await tester.pumpAndSettle();

      expect(find.text('Tu pedido #MERC-9928 está en camino!'), findsOneWidget);
      expect(find.text('Nueva oferta de Juan Pérez'), findsNothing);

      // Tap on "Negociaciones"
      await tester.tap(find.text('Negociaciones'));
      await tester.pumpAndSettle();

      expect(find.text('Nueva oferta de Juan Pérez'), findsOneWidget);
      expect(find.text('Tu pedido #MERC-9928 está en camino!'), findsNothing);
    });

    testWidgets('tapping Aceptar on offer completes action in-card', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          home: const NotificationsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      final aceptarButton = find.widgetWithText(ElevatedButton, 'Aceptar');
      expect(aceptarButton, findsOneWidget);

      await tester.ensureVisible(aceptarButton);
      await tester.pumpAndSettle();
      await tester.tap(aceptarButton);
      await tester.pumpAndSettle();

      // Should show completion message
      expect(find.text('¡Oferta aceptada! El pedido ha sido confirmado con el proveedor.'), findsOneWidget);
    });

    testWidgets('gear icon opens preferences bottom sheet with quiet hours', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          home: const NotificationsScreen(),
        ),
      );
      final settingsIcon = find.byIcon(Icons.tune_rounded);
      await tester.tap(settingsIcon);
      await tester.pumpAndSettle();

      expect(find.text('Preferencias de Alertas'), findsOneWidget);
      expect(find.text('Horario silencioso (10:00 PM – 7:00 AM)'), findsOneWidget);
      expect(find.text('Permitir eventos urgentes durante descanso'), findsOneWidget);
    });

    testWidgets('shows red #CD382F bubbles with unread count on filter tabs and removes URGENTE label', (tester) async {
      tester.view.physicalSize = const Size(1000, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          home: const NotificationsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Check description contains "El proveedor" and not "El productor"
      expect(find.textContaining('El proveedor Juan Pérez'), findsOneWidget);
      expect(find.textContaining('El productor Juan Pérez'), findsNothing);

      // Verify "URGENTE" badge is NOT displayed
      expect(find.text('URGENTE'), findsNothing);

      // Verify unread bubble container exists with color #CD382F
      final unreadBubbleFinder = find.byWidgetPredicate((widget) {
        if (widget is Container && widget.decoration is BoxDecoration) {
          final boxDec = widget.decoration as BoxDecoration;
          return boxDec.color == const Color(0xFFCD382F);
        }
        return false;
      });
      expect(unreadBubbleFinder, findsWidgets);
    });

    testWidgets('shows disabled notifications view when notifications are inactivated', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      service.toggleNotificationsEnabled(false);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          home: const NotificationsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Notificaciones Desactivadas'), findsOneWidget);
      expect(find.text('Activar Notificaciones'), findsOneWidget);

      // Tap to reactivate
      await tester.tap(find.text('Activar Notificaciones'));
      await tester.pumpAndSettle();

      expect(service.preferences.value.notificationsEnabled, isTrue);
      expect(find.text('Tu pedido #MERC-9928 está en camino!'), findsOneWidget);
    });
  });
}
