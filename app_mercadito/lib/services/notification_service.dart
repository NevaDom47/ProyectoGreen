import 'package:flutter/material.dart';
import '../models/notification_item.dart';

class NotificationPreferences {
  bool notificationsEnabled;
  bool pushEnabled;
  bool inAppEnabled;
  bool emailEnabled;
  bool quietHoursEnabled;
  TimeOfDay quietHoursStart;
  TimeOfDay quietHoursEnd;
  bool allowUrgentDuringQuietHours;

  // Pedidos y Negociaciones
  bool orderUpdates;
  bool chatMessages;
  bool counterOffers;

  // Ofertas y Cupones
  bool flashSales;
  bool newCoupons;

  // Mercado y Productores
  bool priceDrops;
  bool followedSellers;
  bool marketTrends;
  bool smartRecommendations;

  Map<NotificationCategory, bool> categoryChannels;

  NotificationPreferences({
    this.notificationsEnabled = true,
    this.pushEnabled = true,
    this.inAppEnabled = true,
    this.emailEnabled = false,
    this.quietHoursEnabled = true,
    this.quietHoursStart = const TimeOfDay(hour: 22, minute: 0), // 10:00 PM
    this.quietHoursEnd = const TimeOfDay(hour: 7, minute: 0),    // 7:00 AM
    this.allowUrgentDuringQuietHours = true,
    this.orderUpdates = true,
    this.chatMessages = true,
    this.counterOffers = true,
    this.flashSales = true,
    this.newCoupons = true,
    this.priceDrops = true,
    this.followedSellers = true,
    this.marketTrends = true,
    this.smartRecommendations = true,
    Map<NotificationCategory, bool>? categoryChannels,
  }) : categoryChannels = categoryChannels ?? {
          NotificationCategory.negociaciones: true,
          NotificationCategory.pedidos: true,
          NotificationCategory.ofertas: true,
          NotificationCategory.cupones: true,
          NotificationCategory.mercado: true,
          NotificationCategory.vendedores: true,
          NotificationCategory.recomendaciones: true,
          NotificationCategory.sistema: true,
        };

  NotificationPreferences copyWith({
    bool? notificationsEnabled,
    bool? pushEnabled,
    bool? inAppEnabled,
    bool? emailEnabled,
    bool? quietHoursEnabled,
    TimeOfDay? quietHoursStart,
    TimeOfDay? quietHoursEnd,
    bool? allowUrgentDuringQuietHours,
    bool? orderUpdates,
    bool? chatMessages,
    bool? counterOffers,
    bool? flashSales,
    bool? newCoupons,
    bool? priceDrops,
    bool? followedSellers,
    bool? marketTrends,
    bool? smartRecommendations,
    Map<NotificationCategory, bool>? categoryChannels,
  }) {
    return NotificationPreferences(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      pushEnabled: pushEnabled ?? this.pushEnabled,
      inAppEnabled: inAppEnabled ?? this.inAppEnabled,
      emailEnabled: emailEnabled ?? this.emailEnabled,
      quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
      allowUrgentDuringQuietHours: allowUrgentDuringQuietHours ?? this.allowUrgentDuringQuietHours,
      orderUpdates: orderUpdates ?? this.orderUpdates,
      chatMessages: chatMessages ?? this.chatMessages,
      counterOffers: counterOffers ?? this.counterOffers,
      flashSales: flashSales ?? this.flashSales,
      newCoupons: newCoupons ?? this.newCoupons,
      priceDrops: priceDrops ?? this.priceDrops,
      followedSellers: followedSellers ?? this.followedSellers,
      marketTrends: marketTrends ?? this.marketTrends,
      smartRecommendations: smartRecommendations ?? this.smartRecommendations,
      categoryChannels: categoryChannels ?? Map.from(this.categoryChannels),
    );
  }

  void deactivateAllChannels() {
    pushEnabled = false;
    inAppEnabled = false;
    emailEnabled = false;
    quietHoursEnabled = false;
    allowUrgentDuringQuietHours = false;
    orderUpdates = false;
    chatMessages = false;
    counterOffers = false;
    flashSales = false;
    newCoupons = false;
    priceDrops = false;
    followedSellers = false;
    marketTrends = false;
    smartRecommendations = false;
    for (final key in categoryChannels.keys.toList()) {
      categoryChannels[key] = false;
    }
  }

  void activateAllChannels() {
    pushEnabled = true;
    inAppEnabled = true;
    quietHoursEnabled = true;
    allowUrgentDuringQuietHours = true;
    orderUpdates = true;
    chatMessages = true;
    counterOffers = true;
    flashSales = true;
    newCoupons = true;
    priceDrops = true;
    followedSellers = true;
    marketTrends = true;
    smartRecommendations = true;
    for (final key in categoryChannels.keys.toList()) {
      categoryChannels[key] = true;
    }
  }
}

class MarketDailySummary {
  final int activeNegotiations;
  final int ordersInProgress;
  final int expiringCoupons;
  final int priceAlerts;
  final String dateGreeting;

  const MarketDailySummary({
    required this.activeNegotiations,
    required this.ordersInProgress,
    required this.expiringCoupons,
    required this.priceAlerts,
    required this.dateGreeting,
  });
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal() {
    _initSampleData();
  }

  final ValueNotifier<List<NotificationItem>> notifications =
      ValueNotifier<List<NotificationItem>>([]);

  final ValueNotifier<int> unreadCount = ValueNotifier<int>(0);

  final ValueNotifier<NotificationPreferences> preferences =
      ValueNotifier<NotificationPreferences>(NotificationPreferences());

  void _initSampleData() {
    notifications.value = [
      // 1. Pedido en camino
      NotificationItem(
        id: 'notif-1',
        title: 'Tu pedido #MERC-9928 está en camino!',
        description: 'El transportista ya recolectó tus productos y llegará en aprox. 45 min.',
        whyItMatters: 'Entrega estimada hoy antes del mediodía.',
        category: NotificationCategory.pedidos,
        priority: NotificationPriority.important,
        timeAgo: '2 min',
        timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
        dateGroup: 'HOY',
        icon: Icons.local_shipping,
        iconBgColor: const Color(0xFF285E44),
        iconColor: const Color(0xFFFFFFFF),
        priceTag: 'RD\$ 4,200',
        actions: [
          const NotificationAction(
            label: 'Ver pedido',
            type: NotificationActionType.viewOrder,
            isPrimary: true,
            payload: 'MERC-9928',
          ),
          const NotificationAction(
            label: 'Rastrear',
            type: NotificationActionType.trackOrder,
            isPrimary: false,
            payload: 'MERC-9928',
          ),
        ],
        isRead: false,
      ),

      // 2. Nueva oferta / Negociación accionable
      NotificationItem(
        id: 'notif-2',
        title: 'Nueva oferta de Juan Pérez',
        description: 'El proveedor Juan Pérez envió una contraoferta por tus 50 unidades de Aguacates Hass.',
        whyItMatters: 'Ahorro de RD\$ 1,200 frente al precio de lista.',
        category: NotificationCategory.negociaciones,
        priority: NotificationPriority.important,
        timeAgo: '1 h',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        dateGroup: 'HOY',
        icon: Icons.chat_bubble_rounded,
        iconBgColor: const Color(0xFF285E44),
        iconColor: const Color(0xFFFFFFFF),
        priceTag: 'RD\$ 8,500',
        actions: [
          const NotificationAction(
            label: 'Aceptar',
            type: NotificationActionType.acceptOffer,
            isPrimary: true,
            payload: 'NEG-8821',
          ),
          const NotificationAction(
            label: 'Contraofertar',
            type: NotificationActionType.counterOffer,
            isPrimary: false,
            payload: 'NEG-8821',
          ),
        ],
        isRead: false,
      ),

      // 3. Cupón de descuento
      NotificationItem(
        id: 'notif-3',
        title: '¡Cupón de 20% OFF disponible!',
        description: 'Aprovecha este descuento exclusivo en frutas orgánicas solo por hoy.',
        whyItMatters: 'Válido para compras mayores a RD\$ 2,000.',
        category: NotificationCategory.cupones,
        priority: NotificationPriority.important,
        timeAgo: '3 h',
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        dateGroup: 'HOY',
        icon: Icons.confirmation_number_rounded,
        iconBgColor: const Color(0xFF285E44),
        iconColor: const Color(0xFFFFFFFF),
        priceTag: '20% OFF',
        actions: [
          const NotificationAction(
            label: 'Usar cupón',
            type: NotificationActionType.viewCoupon,
            isPrimary: true,
            payload: 'ORGANIC20',
          ),
          const NotificationAction(
            label: 'Copiar código',
            type: NotificationActionType.copyCoupon,
            isPrimary: false,
            payload: 'ORGANIC20',
          ),
        ],
        isRead: false,
      ),

      // 4. Mercado / Tendencia predictiva
      NotificationItem(
        id: 'notif-4',
        title: 'Tendencia: Aguacate Hass al alza',
        description: 'El precio promedio aumentó 6.4% durante los últimos 7 días por demanda estacional.',
        whyItMatters: 'Buen momento para asegurar volumen anticipado.',
        category: NotificationCategory.mercado,
        priority: NotificationPriority.info,
        timeAgo: '4 h',
        timestamp: DateTime.now().subtract(const Duration(hours: 4)),
        dateGroup: 'HOY',
        icon: Icons.trending_up_rounded,
        iconBgColor: const Color(0xFF58A6FF).withValues(alpha: 0.15),
        iconColor: const Color(0xFF58A6FF),
        priceTag: '+6.4%',
        actions: [
          const NotificationAction(
            label: 'Ver tendencia',
            type: NotificationActionType.viewMarket,
            isPrimary: true,
          ),
        ],
        isRead: false,
      ),

      // 5. Recomendación basada en comportamiento
      NotificationItem(
        id: 'notif-5',
        title: 'Puede interesarte: Tomates y Zanahorias',
        description: 'Has comprado vegetales 4 veces este mes. Finca Bella Vista tiene oferta por volumen de 50 kg.',
        whyItMatters: 'Precio preferencial de mayorista verificado.',
        category: NotificationCategory.recomendaciones,
        priority: NotificationPriority.info,
        timeAgo: '5 h',
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        dateGroup: 'HOY',
        icon: Icons.auto_awesome_rounded,
        iconBgColor: const Color(0xFFF5A623).withValues(alpha: 0.15),
        iconColor: const Color(0xFFF5A623),
        priceTag: 'RD\$ 35/lb',
        actions: [
          const NotificationAction(
            label: 'Ver oferta',
            type: NotificationActionType.viewProduct,
            isPrimary: true,
          ),
        ],
        isRead: true,
      ),

      // 6. AYER - Cosecha con video
      NotificationItem(
        id: 'notif-6',
        title: 'Nueva cosecha en Huerta Los Arcos',
        description: 'Mira el nuevo video de la cosecha de tomates de esta mañana.',
        whyItMatters: 'Lote recién recolectado listo para despacho.',
        category: NotificationCategory.vendedores,
        priority: NotificationPriority.info,
        timeAgo: '1 d',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        dateGroup: 'AYER',
        icon: Icons.videocam_rounded,
        iconBgColor: const Color(0xFF285E44),
        iconColor: const Color(0xFFFFFFFF),
        mediaUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuDZb3XgoNfixW3tUuuVb9VRAF1luoaxnuwBt5ENpHn4M4CkzTMafAzyTiMQQkkExG2MWzJXkKolAvVD4dh42jypWyNXmY7AFcxn0-k7UYRSUiKHTbhigyc813TJHOY4k3AnNExhG_ainPC6dWQHL16DGUohjp2-NAYdauQEAWumLseaZzHld-eYTqm3D5HbmZ39Va6EWGOWHpiF2Wu0dHsDsRnCxDLfuD_FDqnOL6Z_Icl0AeefsjY-WZQjeTeYo_6ySivyfnZQjFw',
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

      // 7. AYER - Agrupación inteligente
      NotificationItem(
        id: 'notif-7',
        title: 'Nuevos productos de Juan Agro',
        description: 'Juan Agro publicó 23 productos nuevos de vegetales y frutas de temporada.',
        whyItMatters: 'Productos con certificación de calidad.',
        category: NotificationCategory.vendedores,
        priority: NotificationPriority.info,
        timeAgo: '1 d',
        timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
        dateGroup: 'AYER',
        icon: Icons.inventory_2_rounded,
        iconBgColor: const Color(0xFF285E44),
        iconColor: const Color(0xFFFFFFFF),
        groupCount: 23,
        actions: [
          const NotificationAction(
            label: 'Ver catálogo',
            type: NotificationActionType.viewVendor,
            isPrimary: true,
          ),
        ],
        isRead: true,
      ),

      // 8. AYER - Pedido entregado
      NotificationItem(
        id: 'notif-8',
        title: 'Pedido entregado exitosamente',
        description: 'Tu pedido #MERC-9880 de la semana pasada ha sido completado.',
        whyItMatters: 'Agradecemos tu confirmación de recepción.',
        category: NotificationCategory.pedidos,
        priority: NotificationPriority.info,
        timeAgo: '1 d',
        timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 5)),
        dateGroup: 'AYER',
        icon: Icons.check_circle_rounded,
        iconBgColor: const Color(0xFF285E44),
        iconColor: const Color(0xFFFFFFFF),
        actions: [
          const NotificationAction(
            label: 'Ver pedido',
            type: NotificationActionType.viewOrder,
            isPrimary: false,
          ),
        ],
        isRead: true,
      ),

      // 9. ANTERIORES - Recordatorio útil
      NotificationItem(
        id: 'notif-9',
        title: 'Tu negociación quedó pendiente',
        description: 'AgroMax respondió a tu propuesta. Tu contraoferta vence en menos de 6 horas.',
        whyItMatters: 'El lote podría asignarse a otro comprador si no respondes.',
        category: NotificationCategory.negociaciones,
        priority: NotificationPriority.urgent,
        timeAgo: '3 d',
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
        dateGroup: 'ANTERIORES',
        icon: Icons.access_time_filled_rounded,
        iconBgColor: const Color(0xFFFF6B6B).withValues(alpha: 0.15),
        iconColor: const Color(0xFFFF6B6B),
        priceTag: 'RD\$ 6,800',
        actions: [
          const NotificationAction(
            label: 'Continuar negociación',
            type: NotificationActionType.viewNegotiation,
            isPrimary: true,
          ),
        ],
        isRead: true,
      ),
    ];
    _updateUnreadCount();
  }

  void _updateUnreadCount() {
    if (!preferences.value.notificationsEnabled) {
      unreadCount.value = 0;
    } else {
      unreadCount.value = notifications.value.where((n) => !n.isRead).length;
    }
  }

  MarketDailySummary getDailyMarketSummary() {
    final activeNeg = notifications.value
        .where((n) => n.category == NotificationCategory.negociaciones && !n.isActionCompleted)
        .length;
    final activeOrders = notifications.value
        .where((n) => n.category == NotificationCategory.pedidos && !n.isRead)
        .length;
    final activeCoupons = notifications.value
        .where((n) => n.category == NotificationCategory.cupones)
        .length;
    final priceAlerts = notifications.value
        .where((n) => n.category == NotificationCategory.mercado || n.category == NotificationCategory.ofertas)
        .length;

    return MarketDailySummary(
      activeNegotiations: activeNeg > 0 ? activeNeg : 3,
      ordersInProgress: activeOrders > 0 ? activeOrders : 2,
      expiringCoupons: activeCoupons > 0 ? activeCoupons : 1,
      priceAlerts: priceAlerts > 0 ? priceAlerts : 2,
      dateGreeting: 'Resumen de tu Mercado',
    );
  }

  void markAsRead(String id) {
    notifications.value = notifications.value.map((item) {
      if (item.id == id) {
        return item.copyWith(isRead: true);
      }
      return item;
    }).toList();
    _updateUnreadCount();
  }

  void markAllAsRead() {
    notifications.value = notifications.value.map((item) {
      return item.copyWith(isRead: true);
    }).toList();
    _updateUnreadCount();
  }

  void dismiss(String id) {
    notifications.value = notifications.value.where((item) => item.id != id).toList();
    _updateUnreadCount();
  }

  void completeAction(String id, String completionMessage) {
    notifications.value = notifications.value.map((item) {
      if (item.id == id) {
        return item.copyWith(
          isRead: true,
          isActionCompleted: true,
          actionCompletedMessage: completionMessage,
        );
      }
      return item;
    }).toList();
    _updateUnreadCount();
  }

  void updatePreferences(NotificationPreferences newPrefs) {
    if (!newPrefs.notificationsEnabled) {
      newPrefs.deactivateAllChannels();
    }
    preferences.value = newPrefs;
    _updateUnreadCount();
  }

  void toggleNotificationsEnabled(bool enabled) {
    final current = preferences.value;
    final updated = current.copyWith(notificationsEnabled: enabled);
    if (!enabled) {
      updated.deactivateAllChannels();
    } else {
      updated.activateAllChannels();
    }
    preferences.value = updated;
    _updateUnreadCount();
  }
}
