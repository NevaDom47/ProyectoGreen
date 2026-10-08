import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../models/notification_item.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';
import '../widgets/skeleton_loading.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _service = NotificationService();
  int _selectedTab = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  final List<String> _tabs = [
    'Todo',
    'Pedidos',
    'Negociaciones',
    'Ofertas',
    'Cupones',
    'Mercado',
    'Vendedores',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppTheme.darkPrimary : AppTheme.lightPrimary;
    final bgColor = isDark ? AppTheme.darkBackground : AppTheme.lightBackground;
    final cardColor = isDark ? AppTheme.darkCard : Colors.white;
    final textColor = isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;
    final subtextColor = isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary;
    final borderColor = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(
              context: context,
              isDark: isDark,
              primaryColor: primaryColor,
              textColor: textColor,
              subtextColor: subtextColor,
              borderColor: borderColor,
            ),
            Expanded(
              child: SkeletonScreenLoader(
                isLoading: _isLoading,
                skeleton: const SkeletonNotificationsView(),
                child: ValueListenableBuilder<NotificationPreferences>(
                  valueListenable: _service.preferences,
                builder: (context, prefs, _) {
                  if (!prefs.notificationsEnabled) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: subtextColor.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.notifications_off_outlined,
                                size: 52,
                                color: subtextColor,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Notificaciones Desactivadas',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Has pausado las notificaciones desde la configuración. No se mostrarán alertas ni avisos.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: subtextColor,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () {
                                _service.toggleNotificationsEnabled(true);
                              },
                              icon: const Icon(Icons.notifications_active, size: 18),
                              label: const Text('Activar Notificaciones'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ValueListenableBuilder<List<NotificationItem>>(
                    valueListenable: _service.notifications,
                    builder: (context, notifs, _) {
                      return ListView(
                        padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 40),
                        children: [
                          // Lista de Notificaciones agrupada por fecha
                          ..._buildGroupedNotifications(
                            notifications: notifs,
                            isDark: isDark,
                            primaryColor: primaryColor,
                            cardColor: cardColor,
                            textColor: textColor,
                            subtextColor: subtextColor,
                            borderColor: borderColor,
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader({
    required BuildContext context,
    required bool isDark,
    required Color primaryColor,
    required Color textColor,
    required Color subtextColor,
    required Color borderColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkBackground.withValues(alpha: 0.95) : AppTheme.lightBackground.withValues(alpha: 0.95),
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: primaryColor),
                  onPressed: () => context.pop(),
                  tooltip: 'Volver',
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        'Notificaciones',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                          fontFamily: 'Plus Jakarta Sans',
                        ),
                      ),
                      const SizedBox(width: 8),
                      ValueListenableBuilder<int>(
                        valueListenable: _service.unreadCount,
                        builder: (context, count, _) {
                          if (count == 0) return const SizedBox.shrink();
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$count',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                // Botón Marcar todas como leídas
                IconButton(
                  icon: Icon(Icons.done_all_rounded, color: primaryColor, size: 22),
                  tooltip: 'Marcar todas como leídas',
                  onPressed: () {
                    _service.markAllAsRead();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Todas las notificaciones marcadas como leídas'),
                        duration: Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                // Botón Preferencias / Ajustes de Notificaciones
                IconButton(
                  icon: Icon(Icons.tune_rounded, color: primaryColor, size: 22),
                  tooltip: 'Preferencias de notificaciones',
                  onPressed: () => _showPreferencesBottomSheet(context, isDark, primaryColor, textColor, subtextColor),
                ),
              ],
            ),
          ),
          // Tab bar horizontal con burbujas de notificaciones pendientes
          ValueListenableBuilder<List<NotificationItem>>(
            valueListenable: _service.notifications,
            builder: (context, notifs, _) {
              return SizedBox(
                height: 48,
                child: ListView.separated(
                  clipBehavior: Clip.none,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: _tabs.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 22),
                  itemBuilder: (context, index) {
                    final isSelected = _selectedTab == index;
                    final unreadCount = _getTabUnreadCount(index, notifs);
                    return GestureDetector(
                      onTap: () => setState(() => _selectedTab = index),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: isSelected ? primaryColor : Colors.transparent,
                              width: 2.5,
                            ),
                          ),
                        ),
                        padding: const EdgeInsets.only(bottom: 8, top: 4),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                right: unreadCount > 0 ? 14 : 0,
                                top: 2,
                              ),
                              child: Text(
                                _tabs[index],
                                style: TextStyle(
                                  color: isSelected ? primaryColor : subtextColor,
                                  fontSize: 14,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  fontFamily: 'Plus Jakarta Sans',
                                ),
                              ),
                            ),
                            if (unreadCount > 0)
                              Positioned(
                                top: -4,
                                right: -2,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFCD382F),
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFCD382F).withValues(alpha: 0.35),
                                        blurRadius: 3,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    unreadCount > 99 ? '99+' : '$unreadCount',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Plus Jakarta Sans',
                                      height: 1,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  int _getTabUnreadCount(int index, List<NotificationItem> notifs) {
    return notifs.where((n) {
      if (n.isRead) return false;
      if (index == 0) return true; // Todo
      if (index == 1) return n.category == NotificationCategory.pedidos;
      if (index == 2) return n.category == NotificationCategory.negociaciones;
      if (index == 3) {
        return n.category == NotificationCategory.ofertas ||
            n.category == NotificationCategory.recomendaciones;
      }
      if (index == 4) return n.category == NotificationCategory.cupones;
      if (index == 5) return n.category == NotificationCategory.mercado;
      if (index == 6) return n.category == NotificationCategory.vendedores;
      return false;
    }).length;
  }

  List<Widget> _buildGroupedNotifications({
    required List<NotificationItem> notifications,
    required bool isDark,
    required Color primaryColor,
    required Color cardColor,
    required Color textColor,
    required Color subtextColor,
    required Color borderColor,
  }) {
    // Filtrado por Tab
    final filtered = notifications.where((n) {
      if (_selectedTab == 0) return true;
      if (_selectedTab == 1) return n.category == NotificationCategory.pedidos;
      if (_selectedTab == 2) return n.category == NotificationCategory.negociaciones;
      if (_selectedTab == 3) {
        return n.category == NotificationCategory.ofertas ||
            n.category == NotificationCategory.recomendaciones;
      }
      if (_selectedTab == 4) return n.category == NotificationCategory.cupones;
      if (_selectedTab == 5) return n.category == NotificationCategory.mercado;
      if (_selectedTab == 6) return n.category == NotificationCategory.vendedores;
      return true;
    }).toList();

    if (filtered.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.only(top: 60),
          child: Column(
            children: [
              Icon(Icons.notifications_off_outlined, size: 64, color: subtextColor.withValues(alpha: 0.5)),
              const SizedBox(height: 16),
              Text(
                'No hay notificaciones aquí',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
              ),
              const SizedBox(height: 4),
              Text(
                'Te avisaremos cuando haya actividad o novedades en esta categoría.',
                style: TextStyle(fontSize: 12, color: subtextColor),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ];
    }

    final groups = ['HOY', 'AYER', 'ANTERIORES'];
    List<Widget> result = [];

    for (final group in groups) {
      final itemsInGroup = filtered.where((n) => n.dateGroup == group).toList();
      if (itemsInGroup.isNotEmpty) {
        result.add(_buildDateLabel(group, subtextColor));
        for (int i = 0; i < itemsInGroup.length; i++) {
          final item = itemsInGroup[i];
          result.add(
            Dismissible(
              key: Key(item.id),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                decoration: BoxDecoration(
                  color: AppTheme.functionalError,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.delete_outline, color: Colors.white),
              ),
              onDismissed: (_) {
                _service.dismiss(item.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Notificación descartada'),
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: _buildNotificationCard(
                item: item,
                isDark: isDark,
                primaryColor: primaryColor,
                cardColor: cardColor,
                textColor: textColor,
                subtextColor: subtextColor,
                borderColor: borderColor,
              ),
            ),
          );
          if (i < itemsInGroup.length - 1) {
            result.add(const SizedBox(height: 12));
          }
        }
        result.add(const SizedBox(height: 20));
      }
    }

    return result;
  }

  Widget _buildDateLabel(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 4),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
          fontFamily: 'Plus Jakarta Sans',
        ),
      ),
    );
  }

  Widget _buildNotificationCard({
    required NotificationItem item,
    required bool isDark,
    required Color primaryColor,
    required Color cardColor,
    required Color textColor,
    required Color subtextColor,
    required Color borderColor,
  }) {
    final isUnread = !item.isRead;

    final bool isGreenItem = item.iconColor == const Color(0xFF016042) ||
        item.iconColor == const Color(0xFF67C83B) ||
        item.iconColor == const Color(0xFF285E44) ||
        item.iconBgColor == const Color(0xFF016042) ||
        item.iconBgColor == const Color(0xFF285E44) ||
        (item.iconColor == null && item.iconBgColor == null);

    final Color effectiveIconColor = isGreenItem
        ? const Color(0xFFFFFFFF)
        : (item.iconColor ?? primaryColor);
    final Color effectiveIconBgColor = isGreenItem
        ? const Color(0xFF285E44)
        : (item.iconBgColor ?? primaryColor.withValues(alpha: 0.1));

    return InkWell(
      onTap: () {
        if (!item.isRead) _service.markAsRead(item.id);
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isUnread
              ? (isDark ? const Color(0xFF1F2F29) : const Color(0xFFF4F8F6))
              : cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isUnread ? primaryColor.withValues(alpha: 0.3) : borderColor,
            width: isUnread ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icono de Notificación
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: effectiveIconBgColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    item.icon,
                    color: effectiveIconColor,
                    size: 22,
                  ),
                ),
                // Punto indicador no leído
                if (isUnread)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: cardColor, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),

            // Contenido Central
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título, Priority Badge y Tiempo
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                item.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: textColor,
                                  fontFamily: 'Plus Jakarta Sans',
                                  height: 1.2,
                                ),
                              ),
                            ),
                            if (item.priority == NotificationPriority.urgent) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: AppTheme.functionalError.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'URGENTE',
                                  style: TextStyle(
                                    color: AppTheme.functionalError,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        item.timeAgo,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: subtextColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),

                  // Descripción principal (¿Qué pasó?)
                  Text(
                    item.description,
                    style: TextStyle(
                      color: isDark ? AppTheme.darkTextSecondary : const Color(0xFF475569),
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),

                  // Motivo / ¿Por qué importa?
                  if (item.whyItMatters != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.info_outline_rounded, size: 13, color: primaryColor),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item.whyItMatters!,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],

                  // Etiqueta de Precio / Porcentaje
                  if (item.priceTag != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: (isDark ? AppTheme.darkPrimaryLight : AppTheme.lightPrimaryLight),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.priceTag!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ],

                  // Media Video Thumbnail (Cosecha en Huerta Los Arcos)
                  if (item.mediaUrl != null) ...[
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.network(
                            item.mediaUrl!,
                            height: 110,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            headers: const {'User-Agent': 'Mozilla/5.0'},
                            errorBuilder: (c, e, s) => Container(
                              height: 110,
                              color: isDark ? AppTheme.darkSecondaryBackground : Colors.grey[200],
                              child: const Icon(Icons.image_not_supported_outlined),
                            ),
                          ),
                          Container(
                            height: 110,
                            width: double.infinity,
                            color: Colors.black.withValues(alpha: 0.25),
                          ),
                          if (item.isVideoMedia)
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.4),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28),
                            ),
                        ],
                      ),
                    ),
                  ],

                  // Feedback de Acción Completada
                  if (item.isActionCompleted && item.actionCompletedMessage != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.functionalSuccess.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.functionalSuccess.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, size: 16, color: AppTheme.functionalSuccess),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              item.actionCompletedMessage!,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.functionalSuccess,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Botones de Acción In-Card (Accionables directamente)
                  if (!item.isActionCompleted && item.actions.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: item.actions.map((act) {
                        return _buildActionButton(
                          item: item,
                          action: act,
                          isDark: isDark,
                          primaryColor: primaryColor,
                          cardColor: cardColor,
                          textColor: textColor,
                          borderColor: borderColor,
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required NotificationItem item,
    required NotificationAction action,
    required bool isDark,
    required Color primaryColor,
    required Color cardColor,
    required Color textColor,
    required Color borderColor,
  }) {
    if (action.isPrimary) {
      return ElevatedButton(
        onPressed: () => _handleActionClick(item, action),
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          minimumSize: const Size(0, 34),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        child: Text(action.label),
      );
    } else {
      return OutlinedButton(
        onPressed: () => _handleActionClick(item, action),
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          backgroundColor: Colors.transparent,
          side: BorderSide(color: primaryColor.withValues(alpha: 0.4)),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          minimumSize: const Size(0, 34),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        child: Text(action.label),
      );
    }
  }

  void _handleActionClick(NotificationItem item, NotificationAction action) {
    _service.markAsRead(item.id);

    switch (action.type) {
      case NotificationActionType.acceptOffer:
        _service.completeAction(item.id, '¡Oferta aceptada! El pedido ha sido confirmado con el proveedor.');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Has aceptado la oferta de ${item.title}'),
            backgroundColor: AppTheme.functionalSuccess,
            behavior: SnackBarBehavior.floating,
          ),
        );
        break;

      case NotificationActionType.counterOffer:
        _showCounterOfferDialog(item);
        break;

      case NotificationActionType.viewNegotiation:
        context.push('/negotiations');
        break;

      case NotificationActionType.viewOrder:
      case NotificationActionType.trackOrder:
        context.push('/order-history');
        break;

      case NotificationActionType.viewCoupon:
        context.push('/coupons');
        break;

      case NotificationActionType.copyCoupon:
        Clipboard.setData(ClipboardData(text: action.payload?.toString() ?? 'ORGANIC20'));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Código "${action.payload}" copiado al portapapeles'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        break;

      case NotificationActionType.viewMarket:
        context.push('/market');
        break;

      case NotificationActionType.viewProduct:
      case NotificationActionType.viewVendor:
        context.push('/providers');
        break;

      case NotificationActionType.viewCart:
        context.push('/cart');
        break;

      case NotificationActionType.openUrl:
      case NotificationActionType.dismiss:
        _service.dismiss(item.id);
        break;
    }
  }

  void _showCounterOfferDialog(NotificationItem item) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppTheme.darkPrimary : AppTheme.lightPrimary;
    final textController = TextEditingController(text: '8200');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Contraofertar Propuesta',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Propón un nuevo monto al proveedor para esta negociación.',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: textController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Nuevo Monto (RD\$)',
                  prefixText: 'RD\$ ',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () {
                    final amount = textController.text.trim();
                    Navigator.pop(ctx);
                    _service.completeAction(
                      item.id,
                      'Contraoferta enviada por RD\$ $amount al productor.',
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Contraoferta enviada por RD\$ $amount'),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: primaryColor,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Enviar Contraoferta', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPreferencesBottomSheet(
    BuildContext context,
    bool isDark,
    Color primaryColor,
    Color textColor,
    Color subtextColor,
  ) {
    final prefs = _service.preferences.value;
    final prefColor = isDark ? primaryColor : const Color(0xFF365D46);
    final trackColor = isDark ? null : const Color(0xFF365D46).withValues(alpha: 0.38);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              child: ListView(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.tune_rounded, color: prefColor),
                          const SizedBox(width: 8),
                          Text(
                            'Preferencias de Alertas',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Controla qué eventos recibir y configura tu horario de descanso.',
                    style: TextStyle(fontSize: 12, color: subtextColor),
                  ),
                  const SizedBox(height: 16),

                  // Estado General
                  _buildPrefSectionHeader('ESTADO DE NOTIFICACIONES', prefColor),
                  SwitchListTile(
                    title: Text('Permitir Notificaciones', style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
                    subtitle: Text(
                      prefs.notificationsEnabled
                          ? 'Alertas y avisos activos en toda la aplicación'
                          : 'Notificaciones inactivas (icono oculto en el inicio)',
                      style: TextStyle(color: subtextColor, fontSize: 11),
                    ),
                    value: prefs.notificationsEnabled,
                    activeThumbColor: prefColor,
                    activeTrackColor: trackColor,
                    onChanged: (val) {
                      setSheetState(() {
                        prefs.notificationsEnabled = val;
                        if (!val) {
                          prefs.deactivateAllChannels();
                        } else {
                          prefs.activateAllChannels();
                        }
                      });
                      _service.updatePreferences(prefs);
                    },
                  ),

                  Opacity(
                    opacity: prefs.notificationsEnabled ? 1.0 : 0.5,
                    child: AbsorbPointer(
                      absorbing: !prefs.notificationsEnabled,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 14),
                          // Canales
                          _buildPrefSectionHeader('CANALES DE ENTREGA', prefColor),
                  SwitchListTile(
                    title: Text('Notificaciones Push', style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
                    subtitle: Text('Alertas directas en la barra de tu dispositivo', style: TextStyle(color: subtextColor, fontSize: 11)),
                    value: prefs.pushEnabled,
                    activeThumbColor: prefColor,
                    activeTrackColor: trackColor,
                    onChanged: (val) {
                      setSheetState(() => prefs.pushEnabled = val);
                      _service.updatePreferences(prefs);
                    },
                  ),
                  SwitchListTile(
                    title: Text('Notificaciones In-App', style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
                    subtitle: Text('Bandeja de avisos dentro de El Mercadito', style: TextStyle(color: subtextColor, fontSize: 11)),
                    value: prefs.inAppEnabled,
                    activeThumbColor: prefColor,
                    activeTrackColor: trackColor,
                    onChanged: (val) {
                      setSheetState(() => prefs.inAppEnabled = val);
                      _service.updatePreferences(prefs);
                    },
                  ),

                  const SizedBox(height: 14),
                  // Horario Silencioso
                  _buildPrefSectionHeader('DESCANSO Y HORARIO SILENCIOSO', prefColor),
                  SwitchListTile(
                    title: Text('Horario silencioso (10:00 PM – 7:00 AM)', style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
                    subtitle: Text('Silencia avisos nocturnos para proteger tu descanso', style: TextStyle(color: subtextColor, fontSize: 11)),
                    value: prefs.quietHoursEnabled,
                    activeThumbColor: prefColor,
                    activeTrackColor: trackColor,
                    onChanged: (val) {
                      setSheetState(() => prefs.quietHoursEnabled = val);
                      _service.updatePreferences(prefs);
                    },
                  ),
                  CheckboxListTile(
                    title: Text('Permitir eventos urgentes durante descanso', style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.w500)),
                    subtitle: Text('Pagos rechazados, pedidos cancelados o contingencias', style: TextStyle(color: subtextColor, fontSize: 11)),
                    value: prefs.allowUrgentDuringQuietHours,
                    activeColor: prefColor,
                    checkColor: Colors.white,
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: (val) {
                      setSheetState(() => prefs.allowUrgentDuringQuietHours = val ?? true);
                      _service.updatePreferences(prefs);
                    },
                  ),

                  const SizedBox(height: 14),
                  // Pedidos y Negociaciones
                  _buildPrefSectionHeader('PEDIDOS Y NEGOCIACIONES', prefColor),
                  SwitchListTile(
                    title: Text('Actualizaciones de pedido', style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 13.5)),
                    subtitle: Text('Estatus del camión, despachos y entrega', style: TextStyle(color: subtextColor, fontSize: 11)),
                    value: prefs.orderUpdates,
                    activeThumbColor: prefColor,
                    activeTrackColor: trackColor,
                    onChanged: (val) {
                      setSheetState(() {
                        prefs.orderUpdates = val;
                        prefs.categoryChannels[NotificationCategory.pedidos] = val;
                      });
                      _service.updatePreferences(prefs);
                    },
                  ),
                  SwitchListTile(
                    title: Text('Nuevos mensajes de chat', style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 13.5)),
                    subtitle: Text('Avisos directos en negociaciones activas', style: TextStyle(color: subtextColor, fontSize: 11)),
                    value: prefs.chatMessages,
                    activeThumbColor: prefColor,
                    activeTrackColor: trackColor,
                    onChanged: (val) {
                      setSheetState(() => prefs.chatMessages = val);
                      _service.updatePreferences(prefs);
                    },
                  ),
                  SwitchListTile(
                    title: Text('Nuevas contraofertas', style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 13.5)),
                    subtitle: Text('Propuestas directas de precio de proveedores', style: TextStyle(color: subtextColor, fontSize: 11)),
                    value: prefs.counterOffers,
                    activeThumbColor: prefColor,
                    activeTrackColor: trackColor,
                    onChanged: (val) {
                      setSheetState(() {
                        prefs.counterOffers = val;
                        prefs.categoryChannels[NotificationCategory.negociaciones] = val;
                      });
                      _service.updatePreferences(prefs);
                    },
                  ),

                  const SizedBox(height: 14),
                  // Ofertas y Cupones
                  _buildPrefSectionHeader('OFERTAS Y CUPONES', prefColor),
                  SwitchListTile(
                    title: Text('Ofertas relámpago', style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 13.5)),
                    subtitle: Text('Descuentos por tiempo limitado y productos en liquidación', style: TextStyle(color: subtextColor, fontSize: 11)),
                    value: prefs.flashSales,
                    activeThumbColor: prefColor,
                    activeTrackColor: trackColor,
                    onChanged: (val) {
                      setSheetState(() {
                        prefs.flashSales = val;
                        prefs.categoryChannels[NotificationCategory.ofertas] = val;
                      });
                      _service.updatePreferences(prefs);
                    },
                  ),
                  SwitchListTile(
                    title: Text('Nuevos cupones disponibles', style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 13.5)),
                    subtitle: Text('Cupones exclusivos y avisos de expiración', style: TextStyle(color: subtextColor, fontSize: 11)),
                    value: prefs.newCoupons,
                    activeThumbColor: prefColor,
                    activeTrackColor: trackColor,
                    onChanged: (val) {
                      setSheetState(() {
                        prefs.newCoupons = val;
                        prefs.categoryChannels[NotificationCategory.cupones] = val;
                      });
                      _service.updatePreferences(prefs);
                    },
                  ),

                  const SizedBox(height: 14),
                  // Alertas de Mercado y Productores
                  _buildPrefSectionHeader('ALERTAS DE MERCADO', prefColor),
                  SwitchListTile(
                    title: Text('Bajas de precio en favoritos', style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 13.5)),
                    subtitle: Text('Avisos cuando tus productos guardados bajan de precio', style: TextStyle(color: subtextColor, fontSize: 11)),
                    value: prefs.priceDrops,
                    activeThumbColor: prefColor,
                    activeTrackColor: trackColor,
                    onChanged: (val) {
                      setSheetState(() => prefs.priceDrops = val);
                      _service.updatePreferences(prefs);
                    },
                  ),
                  SwitchListTile(
                    title: Text('Nuevos productos de vendedores seguidos', style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 13.5)),
                    subtitle: Text('Publicaciones y cosechas de tus vendedores seguidos', style: TextStyle(color: subtextColor, fontSize: 11)),
                    value: prefs.followedSellers,
                    activeThumbColor: prefColor,
                    activeTrackColor: trackColor,
                    onChanged: (val) {
                      setSheetState(() {
                        prefs.followedSellers = val;
                        prefs.categoryChannels[NotificationCategory.vendedores] = val;
                      });
                      _service.updatePreferences(prefs);
                    },
                  ),
                  SwitchListTile(
                    title: Text('Tendencias y radar de mercado', style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 13.5)),
                    subtitle: Text('Radar predictivo de precios y agro-noticias', style: TextStyle(color: subtextColor, fontSize: 11)),
                    value: prefs.marketTrends,
                    activeThumbColor: prefColor,
                    activeTrackColor: trackColor,
                    onChanged: (val) {
                      setSheetState(() {
                        prefs.marketTrends = val;
                        prefs.categoryChannels[NotificationCategory.mercado] = val;
                      });
                      _service.updatePreferences(prefs);
                    },
                  ),
                  SwitchListTile(
                    title: Text('Recomendaciones inteligentes', style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 13.5)),
                    subtitle: Text('Sugerencias personalizadas según tu consumo', style: TextStyle(color: subtextColor, fontSize: 11)),
                    value: prefs.smartRecommendations,
                    activeThumbColor: prefColor,
                    activeTrackColor: trackColor,
                    onChanged: (val) {
                      setSheetState(() {
                        prefs.smartRecommendations = val;
                        prefs.categoryChannels[NotificationCategory.recomendaciones] = val;
                      });
                      _service.updatePreferences(prefs);
                    },
                  ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPrefSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 8, bottom: 6),
      child: Text(
        title,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildCategorySwitchTile({
    required String title,
    required String subtitle,
    required NotificationCategory category,
    required NotificationPreferences prefs,
    required Color primaryColor,
    required Color textColor,
    required Color subtextColor,
    required ValueChanged<bool> onChanged,
  }) {
    final isEnabled = prefs.categoryChannels[category] ?? true;
    return SwitchListTile(
      title: Text(title, style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 13.5)),
      subtitle: Text(subtitle, style: TextStyle(color: subtextColor, fontSize: 11)),
      value: isEnabled,
      activeThumbColor: primaryColor,
      activeTrackColor: primaryColor.withValues(alpha: 0.38),
      onChanged: onChanged,
    );
  }
}
