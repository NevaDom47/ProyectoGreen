import 'package:flutter/material.dart';
import '../models/notification_item.dart';

/// Plantilla inmutable de ejemplo para emular notificaciones dentro y fuera de la app
/// por cada categoría concreta del dominio de El Mercadito.
class NotificationCategoryPreset {
  final NotificationCategory category;
  final String categoryLabel;
  final String subtitle;
  final String title;
  final String description;
  final String whyItMatters;
  final NotificationPriority priority;
  final String? priceTag;
  final IconData icon;
  final Color accentColor;
  final String route;
  final String primaryActionLabel;
  final List<NotificationAction> actions;

  const NotificationCategoryPreset({
    required this.category,
    required this.categoryLabel,
    required this.subtitle,
    required this.title,
    required this.description,
    required this.whyItMatters,
    required this.priority,
    this.priceTag,
    required this.icon,
    required this.accentColor,
    required this.route,
    required this.primaryActionLabel,
    required this.actions,
  });

  /// Convierte el preset en una instancia fresca de [NotificationItem].
  NotificationItem toNotificationItem({int? uniqueSeed}) {
    final seed = uniqueSeed ?? DateTime.now().microsecondsSinceEpoch;
    return NotificationItem(
      id: 'sim-${category.name}-$seed',
      title: title,
      description: description,
      whyItMatters: whyItMatters,
      category: category,
      priority: priority,
      timeAgo: 'Ahora',
      timestamp: DateTime.now(),
      dateGroup: 'HOY',
      icon: icon,
      iconColor: Colors.white,
      iconBgColor: accentColor,
      priceTag: priceTag,
      actions: actions,
      isRead: false,
    );
  }
}

/// Catálogo oficial con las 8 categorías concretas de notificación de El Mercadito.
class NotificationEmulatorCatalog {
  NotificationEmulatorCatalog._();

  static const List<NotificationCategoryPreset> allPresets = [
    // 1. Pedidos
    NotificationCategoryPreset(
      category: NotificationCategory.pedidos,
      categoryLabel: 'Pedidos',
      subtitle: 'Despacho y rastreo de entrega en ruta',
      title: 'Tu pedido #MERC-9942 salió a entrega',
      description:
          'El camión refrigerado de Huerta Los Arcos salió hacia tu negocio con 3 cajas de tomates y aguacates.',
      whyItMatters: 'Llegada estimada hoy en 25 min a tu muelle de carga.',
      priority: NotificationPriority.important,
      priceTag: 'RD\$ 4,850',
      icon: Icons.local_shipping_rounded,
      accentColor: Color(0xFF016042),
      route: '/order-history',
      primaryActionLabel: 'Rastrear pedido',
      actions: [
        NotificationAction(
          label: 'Ver pedido',
          type: NotificationActionType.viewOrder,
          isPrimary: true,
          payload: 'MERC-9942',
        ),
        NotificationAction(
          label: 'Rastrear',
          type: NotificationActionType.trackOrder,
          isPrimary: false,
          payload: 'MERC-9942',
        ),
      ],
    ),

    // 2. Negociaciones
    NotificationCategoryPreset(
      category: NotificationCategory.negociaciones,
      categoryLabel: 'Negociaciones',
      subtitle: 'Contraofertas urgentes y acuerdos B2B',
      title: 'Contraoferta recibida de Juan Agro',
      description:
          'Juan Agro respondió a tu solicitud de 80 lb de Aguacate Hass y ofrece cerrar hoy con descuento por volumen.',
      whyItMatters: 'Ahorro neto de RD\$ 1,350 si confirmas antes de 2 horas.',
      priority: NotificationPriority.urgent,
      priceTag: 'RD\$ 7,900',
      icon: Icons.handshake_rounded,
      accentColor: Color(0xFFDC2626),
      route: '/negotiations',
      primaryActionLabel: 'Ver negociación',
      actions: [
        NotificationAction(
          label: 'Aceptar',
          type: NotificationActionType.acceptOffer,
          isPrimary: true,
          payload: 'NEG-9041',
        ),
        NotificationAction(
          label: 'Contraofertar',
          type: NotificationActionType.counterOffer,
          isPrimary: false,
          payload: 'NEG-9041',
        ),
      ],
    ),

    // 3. Ofertas Relámpago
    NotificationCategoryPreset(
      category: NotificationCategory.ofertas,
      categoryLabel: 'Ofertas Relámpago',
      subtitle: 'Descuentos flash y liquidación de cosecha',
      title: '¡Oferta Relámpago -25% en Plátano Barraganete!',
      description:
          'Lote fresco de 150 racimos en Primera Calidad disponible por solo 45 minutos en tu zona.',
      whyItMatters: 'Precio por debajo del promedio de mercado semanal.',
      priority: NotificationPriority.urgent,
      priceTag: '-25% FLASH',
      icon: Icons.flash_on_rounded,
      accentColor: Color(0xFFF5A623),
      route: '/flash-offers',
      primaryActionLabel: 'Ver oferta flash',
      actions: [
        NotificationAction(
          label: 'Ver oferta',
          type: NotificationActionType.viewProduct,
          isPrimary: true,
          payload: 'FLASH-PLATA-25',
        ),
      ],
    ),

    // 4. Cupones
    NotificationCategoryPreset(
      category: NotificationCategory.cupones,
      categoryLabel: 'Cupones',
      subtitle: 'Cupones promocionales y códigos activos',
      title: 'Cupón VERDE15 activado para tu cuenta',
      description:
          'Obtén 15% de descuento adicional en compras mayoristas superiores a RD\$ 3,000 hasta medianoche.',
      whyItMatters: 'Válido con cualquier productor verificado en RD.',
      priority: NotificationPriority.important,
      priceTag: '15% OFF',
      icon: Icons.confirmation_number_rounded,
      accentColor: Color(0xFF059669),
      route: '/coupons',
      primaryActionLabel: 'Usar cupón',
      actions: [
        NotificationAction(
          label: 'Usar cupón',
          type: NotificationActionType.viewCoupon,
          isPrimary: true,
          payload: 'VERDE15',
        ),
        NotificationAction(
          label: 'Copiar código',
          type: NotificationActionType.copyCoupon,
          isPrimary: false,
          payload: 'VERDE15',
        ),
      ],
    ),

    // 5. Mercado
    NotificationCategoryPreset(
      category: NotificationCategory.mercado,
      categoryLabel: 'Mercado y Precios',
      subtitle: 'Radar predictivo y variaciones de precio',
      title: 'Radar de Mercado: Cebolla Roja bajó 9.2%',
      description:
          'Mayor oferta desde Constanza redujo el precio promedio por saco de 50 lb en las últimas 24 horas.',
      whyItMatters: 'Ventana óptima para reabastecer inventario mayorista.',
      priority: NotificationPriority.info,
      priceTag: '-9.2%',
      icon: Icons.trending_down_rounded,
      accentColor: Color(0xFF2563EB),
      route: '/market-analysis',
      primaryActionLabel: 'Ver análisis',
      actions: [
        NotificationAction(
          label: 'Ver tendencia',
          type: NotificationActionType.viewMarket,
          isPrimary: true,
        ),
      ],
    ),

    // 6. Vendedores
    NotificationCategoryPreset(
      category: NotificationCategory.vendedores,
      categoryLabel: 'Vendedores',
      subtitle: 'Publicaciones de productores que sigues',
      title: 'Huerta Los Arcos subió cosecha recién cortada',
      description:
          '14 nuevos lotes de ají cubanela, lechuga hidropónica y fresa orgánica listos para despacho hoy.',
      whyItMatters: 'Productor verificado Nivel 4 • A ~7 km de tu ubicación.',
      priority: NotificationPriority.info,
      priceTag: '14 lotes',
      icon: Icons.storefront_rounded,
      accentColor: Color(0xFF285E44),
      route: '/providers',
      primaryActionLabel: 'Ver catálogo',
      actions: [
        NotificationAction(
          label: 'Ver catálogo',
          type: NotificationActionType.viewVendor,
          isPrimary: true,
        ),
      ],
    ),

    // 7. Recomendaciones
    NotificationCategoryPreset(
      category: NotificationCategory.recomendaciones,
      categoryLabel: 'Recomendaciones',
      subtitle: 'Sugerencias inteligentes según historial',
      title: 'Sugerencia semanal: Reponer Limón Persa y Ajo',
      description:
          'Basado en tu frecuencia de compra, encontramos 3 fincas cercanas con stock en Primera Calidad.',
      whyItMatters: 'Ahorra hasta RD\$ 45 por libra combinando entrega.',
      priority: NotificationPriority.info,
      priceTag: 'RD\$ 42/lb',
      icon: Icons.auto_awesome_rounded,
      accentColor: Color(0xFFD97706),
      route: '/search',
      primaryActionLabel: 'Explorar sugerencias',
      actions: [
        NotificationAction(
          label: 'Explorar',
          type: NotificationActionType.viewProduct,
          isPrimary: true,
        ),
      ],
    ),

    // 8. Sistema
    NotificationCategoryPreset(
      category: NotificationCategory.sistema,
      categoryLabel: 'Sistema y Cuenta',
      subtitle: 'Seguridad, verificación y avisos oficiales',
      title: 'Verificación de dispositivo y alertas activas',
      description:
          'Tu sesión móvil fue validada correctamente y tus canales de notificación Push e In-App están listos.',
      whyItMatters: 'Protección activa de cuenta y operaciones comerciales.',
      priority: NotificationPriority.info,
      priceTag: 'SEGURIDAD',
      icon: Icons.verified_user_rounded,
      accentColor: Color(0xFF1D9BF0),
      route: '/notifications',
      primaryActionLabel: 'Ver centro',
      actions: [
        NotificationAction(
          label: 'Revisar',
          type: NotificationActionType.viewCart,
          isPrimary: false,
        ),
      ],
    ),
  ];

  static NotificationCategoryPreset presetFor(NotificationCategory category) {
    return allPresets.firstWhere(
      (p) => p.category == category,
      orElse: () => allPresets.first,
    );
  }
}
