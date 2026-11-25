import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import '../models/notification_item.dart';

/// Metadatos visuales y de enrutamiento para cada categoría de notificación.
class NativeNotificationCategoryMeta {
  final String key;
  final String label;
  final int colorArgb;
  final String defaultRoute;

  const NativeNotificationCategoryMeta({
    required this.key,
    required this.label,
    required this.colorArgb,
    required this.defaultRoute,
  });
}

/// Payload enviado a Android para mostrar una notificación nativa en la barra/cajón del sistema.
class NativeExternalNotificationPayload {
  final NotificationCategory category;
  final String title;
  final String body;
  final String? expandedBody;
  final String? summaryText;
  final String? route;
  final String? notificationId;
  final String? actionLabel;

  const NativeExternalNotificationPayload({
    required this.category,
    required this.title,
    required this.body,
    this.expandedBody,
    this.summaryText,
    this.route,
    this.notificationId,
    this.actionLabel,
  });
}

/// Puente nativo hacia Android para emitir notificaciones reales del sistema operativo
/// (banners heads-up fuera de la app, cajón de notificaciones, sonido nativo y deep-link).
class NativeNotificationBridge {
  NativeNotificationBridge._internal();
  static final NativeNotificationBridge instance = NativeNotificationBridge._internal();

  static const MethodChannel _channel =
      MethodChannel('com.elmercaditoapp/notifications');

  bool _initialized = false;
  int _nextAndroidId = 1001;
  void Function(String route, String? notificationId)? _onTapCallback;

  bool get _isAndroidNativeRuntime {
    if (kIsWeb) return false;
    if (defaultTargetPlatform != TargetPlatform.android) return false;
    try {
      final bindingType = WidgetsBinding.instance.runtimeType.toString();
      if (bindingType.contains('TestWidgetsFlutterBinding') ||
          bindingType.contains('AutomatedTestWidgetsFlutterBinding')) {
        return false;
      }
    } catch (_) {
      return false;
    }
    return true;
  }

  /// Metadatos de canal, color y ruta por defecto para las 8 categorías reales.
  static NativeNotificationCategoryMeta categoryMetadata(NotificationCategory category) {
    switch (category) {
      case NotificationCategory.pedidos:
        return const NativeNotificationCategoryMeta(
          key: 'pedidos',
          label: 'Pedidos',
          colorArgb: 0xFF016042,
          defaultRoute: '/order-history',
        );
      case NotificationCategory.negociaciones:
        return const NativeNotificationCategoryMeta(
          key: 'negociaciones',
          label: 'Negociaciones',
          colorArgb: 0xFFDC2626,
          defaultRoute: '/negotiations',
        );
      case NotificationCategory.ofertas:
        return const NativeNotificationCategoryMeta(
          key: 'ofertas',
          label: 'Ofertas Relámpago',
          colorArgb: 0xFFF5A623,
          defaultRoute: '/flash-offers',
        );
      case NotificationCategory.cupones:
        return const NativeNotificationCategoryMeta(
          key: 'cupones',
          label: 'Cupones',
          colorArgb: 0xFF059669,
          defaultRoute: '/coupons',
        );
      case NotificationCategory.mercado:
        return const NativeNotificationCategoryMeta(
          key: 'mercado',
          label: 'Mercado y Precios',
          colorArgb: 0xFF2563EB,
          defaultRoute: '/market-analysis',
        );
      case NotificationCategory.vendedores:
        return const NativeNotificationCategoryMeta(
          key: 'vendedores',
          label: 'Vendedores',
          colorArgb: 0xFF285E44,
          defaultRoute: '/providers',
        );
      case NotificationCategory.recomendaciones:
        return const NativeNotificationCategoryMeta(
          key: 'recomendaciones',
          label: 'Recomendaciones',
          colorArgb: 0xFFD97706,
          defaultRoute: '/search',
        );
      case NotificationCategory.sistema:
      case NotificationCategory.todos:
        return const NativeNotificationCategoryMeta(
          key: 'sistema',
          label: 'Sistema y Cuenta',
          colorArgb: 0xFF1D9BF0,
          defaultRoute: '/notifications',
        );
    }
  }

  /// Inicializa el listener de clics sobre notificaciones nativas de Android.
  Future<void> initialize({
    void Function(String route, String? notificationId)? onNotificationTap,
  }) async {
    _onTapCallback = onNotificationTap;
    if (!_isAndroidNativeRuntime || _initialized) return;
    _initialized = true;

    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onNotificationTap') {
        final args = call.arguments as Map?;
        final route = args?['route']?.toString();
        final notifId = args?['notificationId']?.toString();
        if (route != null && route.isNotEmpty) {
          _onTapCallback?.call(route, notifId);
        }
      }
    });

    try {
      final initial = await _channel.invokeMapMethod<String, dynamic>('getInitialPayload');
      final route = initial?['route']?.toString();
      final notifId = initial?['notificationId']?.toString();
      if (route != null && route.isNotEmpty) {
        _onTapCallback?.call(route, notifId);
      }
    } on MissingPluginException {
      // Canal no disponible en este entorno.
    } on PlatformException {
      // Ignorado de forma segura para no romper arranque de la app.
    }
  }

  Future<bool> hasPermission() async {
    if (!_isAndroidNativeRuntime) return false;
    try {
      return await _channel.invokeMethod<bool>('hasPermission') ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }

  Future<bool> requestPermission() async {
    if (!_isAndroidNativeRuntime) return false;
    try {
      return await _channel.invokeMethod<bool>('requestPermission') ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }

  Map<String, dynamic> _serializePayload(NativeExternalNotificationPayload payload) {
    final meta = categoryMetadata(payload.category);
    return <String, dynamic>{
      'id': _nextAndroidId++,
      'categoryKey': meta.key,
      'categoryLabel': meta.label,
      'title': payload.title,
      'body': payload.body,
      'expandedBody': payload.expandedBody ?? payload.body,
      'summaryText': payload.summaryText ?? meta.label,
      'colorHex': meta.colorArgb,
      'route': payload.route ?? meta.defaultRoute,
      'notificationId': payload.notificationId ?? '',
      'actionLabel': payload.actionLabel ?? 'Ver en El Mercadito',
    };
  }

  /// Emite una notificación nativa real en el sistema Android.
  /// Devuelve `true` si el canal nativo Android aceptó el despacho.
  Future<bool> showExternalNotification(
    NativeExternalNotificationPayload payload, {
    Duration delay = Duration.zero,
    bool minimizeApp = false,
  }) async {
    if (!_isAndroidNativeRuntime) return false;
    try {
      final map = _serializePayload(payload)
        ..['delayMs'] = delay.inMilliseconds
        ..['minimizeApp'] = minimizeApp;
      return await _channel.invokeMethod<bool>('showNotification', map) ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException catch (e) {
      debugPrint('NativeNotificationBridge.showExternalNotification error: $e');
      return false;
    }
  }

  /// Emite secuencialmente múltiples notificaciones nativas reales en el sistema Android.
  Future<bool> showExternalBatch(
    List<NativeExternalNotificationPayload> payloads, {
    bool minimizeApp = true,
    Duration initialDelay = const Duration(milliseconds: 1800),
    Duration interval = const Duration(milliseconds: 950),
  }) async {
    if (!_isAndroidNativeRuntime || payloads.isEmpty) return false;
    try {
      final serializedItems = payloads.map(_serializePayload).toList();
      return await _channel.invokeMethod<bool>('showBatchNotifications', <String, dynamic>{
            'items': serializedItems,
            'minimizeApp': minimizeApp,
            'initialDelayMs': initialDelay.inMilliseconds,
            'intervalMs': interval.inMilliseconds,
          }) ??
          false;
    } on MissingPluginException {
      return false;
    } on PlatformException catch (e) {
      debugPrint('NativeNotificationBridge.showExternalBatch error: $e');
      return false;
    }
  }

  Future<bool> cancelAllExternalNotifications() async {
    if (!_isAndroidNativeRuntime) return false;
    try {
      return await _channel.invokeMethod<bool>('cancelAllNotifications') ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }
}
