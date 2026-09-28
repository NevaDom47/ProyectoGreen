import 'package:flutter/material.dart';

enum NotificationCategory {
  todos,
  pedidos,
  negociaciones,
  ofertas,
  cupones,
  mercado,
  vendedores,
  recomendaciones,
  sistema,
}

enum NotificationPriority {
  urgent,    // 🔴 Urgente (requiere atención rápida: cancelado, oferta por expirar)
  important, // 🟡 Importante (nueva oferta, nuevo pedido, cupón por vencer)
  info,      // 🟢 Informativa (tendencias, cosechas, novedades)
}

enum NotificationActionType {
  viewNegotiation,
  acceptOffer,
  counterOffer,
  viewOrder,
  trackOrder,
  viewCoupon,
  copyCoupon,
  viewMarket,
  viewProduct,
  viewVendor,
  viewCart,
  openUrl,
  dismiss,
}

class NotificationAction {
  final String label;
  final NotificationActionType type;
  final bool isPrimary;
  final dynamic payload;

  const NotificationAction({
    required this.label,
    required this.type,
    this.isPrimary = true,
    this.payload,
  });
}

class NotificationItem {
  final String id;
  final String title;
  final String description;
  final String? whyItMatters;
  final NotificationCategory category;
  final NotificationPriority priority;
  final String timeAgo;
  final DateTime timestamp;
  final String dateGroup; // 'HOY', 'AYER', 'ANTERIORES'
  final IconData icon;
  final Color? iconColor;
  final Color? iconBgColor;
  final List<NotificationAction> actions;
  final String? priceTag;
  final String? mediaUrl;
  final bool isVideoMedia;
  final String? groupKey;
  final int? groupCount;
  bool isRead;
  bool isActionCompleted;
  String? actionCompletedMessage;

  NotificationItem({
    required this.id,
    required this.title,
    required this.description,
    this.whyItMatters,
    required this.category,
    this.priority = NotificationPriority.info,
    required this.timeAgo,
    required this.timestamp,
    required this.dateGroup,
    required this.icon,
    this.iconColor,
    this.iconBgColor,
    this.actions = const [],
    this.priceTag,
    this.mediaUrl,
    this.isVideoMedia = false,
    this.groupKey,
    this.groupCount,
    this.isRead = false,
    this.isActionCompleted = false,
    this.actionCompletedMessage,
  });

  NotificationItem copyWith({
    String? id,
    String? title,
    String? description,
    String? whyItMatters,
    NotificationCategory? category,
    NotificationPriority? priority,
    String? timeAgo,
    DateTime? timestamp,
    String? dateGroup,
    IconData? icon,
    Color? iconColor,
    Color? iconBgColor,
    List<NotificationAction>? actions,
    String? priceTag,
    String? mediaUrl,
    bool? isVideoMedia,
    String? groupKey,
    int? groupCount,
    bool? isRead,
    bool? isActionCompleted,
    String? actionCompletedMessage,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      whyItMatters: whyItMatters ?? this.whyItMatters,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      timeAgo: timeAgo ?? this.timeAgo,
      timestamp: timestamp ?? this.timestamp,
      dateGroup: dateGroup ?? this.dateGroup,
      icon: icon ?? this.icon,
      iconColor: iconColor ?? this.iconColor,
      iconBgColor: iconBgColor ?? this.iconBgColor,
      actions: actions ?? this.actions,
      priceTag: priceTag ?? this.priceTag,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      isVideoMedia: isVideoMedia ?? this.isVideoMedia,
      groupKey: groupKey ?? this.groupKey,
      groupCount: groupCount ?? this.groupCount,
      isRead: isRead ?? this.isRead,
      isActionCompleted: isActionCompleted ?? this.isActionCompleted,
      actionCompletedMessage: actionCompletedMessage ?? this.actionCompletedMessage,
    );
  }
}
