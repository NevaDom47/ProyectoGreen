import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/notification_item.dart';
import '../router/app_router.dart';
import '../services/native_notification_bridge.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';
import 'bouncing_button.dart';

/// Host global montado sobre [MaterialApp.router] que muestra banners flotantes
/// animados cada vez que llega una notificación dentro de la aplicación,
/// inyectándolos preferiblemente en el [Overlay] raíz del [Navigator] y
/// atendiendo los deep-links al tocar notificaciones push nativas de Android.
class InAppNotificationHost extends StatefulWidget {
  final Widget child;
  final GlobalKey<NavigatorState>? navigatorKey;
  final Duration displayDuration;

  const InAppNotificationHost({
    super.key,
    required this.child,
    this.navigatorKey,
    this.displayDuration = const Duration(milliseconds: 4500),
  });

  @override
  State<InAppNotificationHost> createState() => _InAppNotificationHostState();
}

class _InAppNotificationHostState extends State<InAppNotificationHost> {
  final NotificationService _service = NotificationService();
  OverlayEntry? _bannerOverlayEntry;
  NotificationItem? _fallbackBannerItem;
  Timer? _autoDismissTimer;

  void _removeOverlayEntry() {
    final entry = _bannerOverlayEntry;
    _bannerOverlayEntry = null;
    if (entry != null) {
      try {
        entry.remove();
      } catch (_) {}
      try {
        entry.dispose();
      } catch (_) {}
    }
  }

  @override
  void initState() {
    super.initState();
    _service.activeInAppBanner.addListener(_onBannerChanged);
    if (_service.activeInAppBanner.value != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _onBannerChanged();
        }
      });
    }

    NativeNotificationBridge.instance.initialize(
      onNotificationTap: _handleNativeNotificationTap,
    );
  }

  void _onBannerChanged() {
    _autoDismissTimer?.cancel();
    _autoDismissTimer = null;
    _removeOverlayEntry();

    final item = _service.activeInAppBanner.value;
    if (item == null) {
      if (_fallbackBannerItem != null && mounted) {
        setState(() => _fallbackBannerItem = null);
      }
      return;
    }

    _scheduleAutoDismiss(item);

    final overlay = widget.navigatorKey?.currentState?.overlay;
    if (overlay != null && overlay.mounted) {
      if (_fallbackBannerItem != null && mounted) {
        setState(() => _fallbackBannerItem = null);
      }
      late final OverlayEntry entry;
      entry = OverlayEntry(
        builder: (overlayContext) =>
            _buildPositionedBanner(overlayContext, item),
      );
      _bannerOverlayEntry = entry;

      if (SchedulerBinding.instance.schedulerPhase ==
          SchedulerPhase.persistentCallbacks) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _bannerOverlayEntry == entry && overlay.mounted) {
            overlay.insert(entry);
          }
        });
      } else {
        overlay.insert(entry);
      }

      if (kDebugMode) {
        debugPrint(
          '[InAppBanner] showing ${item.id} (${item.category.name}) via=overlay',
        );
      }
    } else {
      if (mounted) {
        setState(() => _fallbackBannerItem = item);
      }
      if (kDebugMode) {
        debugPrint(
          '[InAppBanner] showing ${item.id} (${item.category.name}) via=stack',
        );
      }
    }
  }

  void _scheduleAutoDismiss(NotificationItem item) {
    _autoDismissTimer?.cancel();
    _autoDismissTimer = Timer(widget.displayDuration, () {
      if (!mounted) return;
      _service.clearActiveInAppBanner(item.id);
    });
  }

  void _handleNativeNotificationTap(String route, String? notificationId) {
    if (notificationId != null && notificationId.isNotEmpty) {
      _service.markAsRead(notificationId);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      try {
        appRouter.push(route);
      } catch (_) {
        // Ignorado si no hay GoRouter montado.
      }
    });
  }

  void _dismissBanner(NotificationItem item) {
    _autoDismissTimer?.cancel();
    _autoDismissTimer = null;
    _removeOverlayEntry();
    _service.clearActiveInAppBanner(item.id);
  }

  void _onBannerTap(NotificationItem item) {
    _service.markAsRead(item.id);
    final route = _service.resolveRouteForNotification(item);
    _dismissBanner(item);
    try {
      appRouter.push(route);
    } catch (_) {
      // Ignorado si el host se renderiza en pruebas sin GoRouter montado.
    }
  }

  @override
  void dispose() {
    _autoDismissTimer?.cancel();
    _removeOverlayEntry();
    _service.activeInAppBanner.removeListener(_onBannerChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        if (_fallbackBannerItem != null)
          _buildPositionedBanner(context, _fallbackBannerItem!),
      ],
    );
  }

  Widget _buildPositionedBanner(BuildContext context, NotificationItem item) {
    final topPadding = MediaQuery.paddingOf(context).top;
    if (kDebugMode) {
      debugPrint(
        '[InAppBanner] build card ${item.id} topPadding=$topPadding',
      );
    }

    return Positioned(
      top: topPadding + 8,
      left: 12,
      right: 12,
      child: TweenAnimationBuilder<double>(
        key: ValueKey('banner_anim_${item.id}'),
        tween: Tween<double>(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, (1.0 - value) * -18.0),
            child: Opacity(
              opacity: (0.88 + 0.12 * value).clamp(0.0, 1.0),
              child: child,
            ),
          );
        },
        child: Dismissible(
          key: Key('in_app_banner_${item.id}'),
          direction: DismissDirection.horizontal,
          onDismissed: (_) => _dismissBanner(item),
          child: _buildBannerCard(context, item),
        ),
      ),
    );
  }

  Widget _buildBannerCard(BuildContext context, NotificationItem item) {
    final isDark = AppTheme.isDark(context);
    final meta = NativeNotificationBridge.categoryMetadata(item.category);
    final accentColor = item.iconBgColor ?? Color(meta.colorArgb);
    final surfaceColor = AppTheme.getElevatedCardColor(context);
    final borderColor = AppTheme.getBorderColor(context);
    final textColor = AppTheme.getTextColor(context);
    final secondaryColor = AppTheme.getSecondaryTextColor(context);

    final primaryActionLabel = item.actions.isNotEmpty
        ? item.actions.first.label
        : 'Ver';

    return Material(
      color: Colors.transparent,
      child: BouncingButton(
        lowerBound: 0.98,
        enableSound: false,
        onTap: () => _onBannerTap(item),
        child: Container(
          key: const ValueKey('in_app_banner_card'),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? borderColor : accentColor.withValues(alpha: 0.25),
              width: 1.1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.14),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Franja superior de categoría
              Container(
                height: 3.5,
                width: double.infinity,
                color: accentColor,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icono de categoría
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: accentColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        item.icon,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Contenido central
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Wrap(
                            spacing: 5,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: accentColor.withValues(
                                    alpha: isDark ? 0.2 : 0.12,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  meta.label.toUpperCase(),
                                  style: GoogleFonts.manrope(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.3,
                                    color: isDark
                                        ? AppTheme.darkTextPrimary
                                        : accentColor,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (item.priceTag != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? AppTheme.darkPrimaryLight
                                        : AppTheme.lightPrimaryLight,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    item.priceTag!,
                                    style: GoogleFonts.manrope(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.getPrimaryColor(context),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            item.title,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: textColor,
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.description,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: secondaryColor,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.notifications_active_outlined,
                                      size: 12,
                                      color: AppTheme.getPrimaryColor(context),
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        'En la app • Ahora',
                                        style: GoogleFonts.manrope(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w600,
                                          color: secondaryColor,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        primaryActionLabel,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w700,
                                          color: AppTheme.getPrimaryColor(context),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    Icon(
                                      Icons.chevron_right_rounded,
                                      size: 15,
                                      color: AppTheme.getPrimaryColor(context),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Botón cerrar (sin Tooltip/Overlay porque el host vive sobre el Navigator)
                    Semantics(
                      label: 'Cerrar notificación',
                      button: true,
                      child: InkWell(
                        key: const ValueKey('close_in_app_banner_button'),
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => _dismissBanner(item),
                        child: SizedBox(
                          width: 28,
                          height: 28,
                          child: Center(
                            child: Icon(
                              Icons.close_rounded,
                              size: 18,
                              color: secondaryColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Barra de progreso de auto-cierre
              TweenAnimationBuilder<double>(
                key: ValueKey('banner_progress_${item.id}'),
                tween: Tween<double>(begin: 1.0, end: 0.0),
                duration: widget.displayDuration,
                builder: (context, progress, _) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: progress.clamp(0.0, 1.0),
                      child: Container(
                        height: 2.5,
                        color: accentColor.withValues(alpha: 0.75),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
