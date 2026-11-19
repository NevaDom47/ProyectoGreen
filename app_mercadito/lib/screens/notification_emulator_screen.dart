import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/notification_item.dart';
import '../services/native_notification_bridge.dart';
import '../services/notification_emulator_catalog.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';
import '../widgets/bouncing_button.dart';
import 'notifications_screen.dart';

/// Estudio interactivo para emular en el dispositivo móvil las 8 categorías
/// reales de notificaciones de El Mercadito, tanto dentro de la app (banner
/// flotante in-app) como fuera de la app (notificaciones nativas en barra y
/// cajón del sistema Android).
class NotificationEmulatorScreen extends StatefulWidget {
  const NotificationEmulatorScreen({super.key});

  @override
  State<NotificationEmulatorScreen> createState() =>
      _NotificationEmulatorScreenState();
}

class _NotificationEmulatorScreenState extends State<NotificationEmulatorScreen> {
  final NotificationService _service = NotificationService();

  bool _externalMode = false;
  bool _minimizeOnExternalPush = true;
  bool _hasNativePermission = true;
  bool _checkingPermission = true;

  Timer? _batchTimer;
  bool _isBatchRunning = false;
  int _batchProgressIndex = 0;
  String _batchCurrentLabel = '';

  @override
  void initState() {
    super.initState();
    _refreshNativePermission();
  }

  @override
  void dispose() {
    _batchTimer?.cancel();
    super.dispose();
  }

  Future<void> _refreshNativePermission() async {
    final granted = await NativeNotificationBridge.instance.hasPermission();
    if (!mounted) return;
    setState(() {
      _hasNativePermission = granted;
      _checkingPermission = false;
    });
  }

  Future<bool> _ensureNativePermission() async {
    final already = await NativeNotificationBridge.instance.hasPermission();
    if (already) {
      if (mounted && !_hasNativePermission) {
        setState(() => _hasNativePermission = true);
      }
      return true;
    }
    final granted = await NativeNotificationBridge.instance.requestPermission();
    if (!mounted) return granted;
    setState(() => _hasNativePermission = granted);
    return granted;
  }

  void _navigateBack() {
    final router = GoRouter.maybeOf(context);
    if (router != null) {
      context.pop();
    } else {
      Navigator.of(context).maybePop();
    }
  }

  void _openInbox() {
    final router = GoRouter.maybeOf(context);
    if (router != null) {
      context.push('/notifications');
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const NotificationsScreen()),
      );
    }
  }

  void _ensureNotificationsActive() {
    if (!_service.preferences.value.notificationsEnabled) {
      _service.toggleNotificationsEnabled(true);
    }
  }

  void _triggerSingleInApp(NotificationCategoryPreset preset) {
    _ensureNotificationsActive();
    _service.emitCategoryDemo(preset.category, isExternal: false);
  }

  Future<void> _triggerSingleExternal(NotificationCategoryPreset preset) async {
    _ensureNotificationsActive();
    await _ensureNativePermission();
    if (!mounted) return;

    final delay = _minimizeOnExternalPush
        ? const Duration(milliseconds: 1600)
        : Duration.zero;

    _service.emitCategoryDemo(
      preset.category,
      isExternal: true,
      externalDelay: delay,
      minimizeApp: _minimizeOnExternalPush,
    );

    if (!_minimizeOnExternalPush && mounted) {
      _showFeedbackSnackBar(
        'Push "${preset.categoryLabel}" enviado a la barra del teléfono.',
      );
    }
  }

  void _startInAppBatch() {
    _ensureNotificationsActive();
    _batchTimer?.cancel();

    final presets = NotificationEmulatorCatalog.allPresets;
    if (presets.isEmpty) return;

    setState(() {
      _isBatchRunning = true;
      _batchProgressIndex = 1;
      _batchCurrentLabel = presets.first.categoryLabel;
    });

    _service.emitCategoryDemo(presets.first.category, isExternal: false);

    var nextIdx = 1;
    _batchTimer = Timer.periodic(const Duration(milliseconds: 2800), (timer) {
      if (!mounted || nextIdx >= presets.length) {
        timer.cancel();
        if (mounted) {
          setState(() {
            _isBatchRunning = false;
            _batchProgressIndex = 0;
            _batchCurrentLabel = '';
          });
          _showFeedbackSnackBar(
            'Secuencia completada: ${presets.length} categorías emuladas en app.',
          );
        }
        return;
      }

      final preset = presets[nextIdx];
      nextIdx++;
      setState(() {
        _batchProgressIndex = nextIdx;
        _batchCurrentLabel = preset.categoryLabel;
      });
      _service.emitCategoryDemo(preset.category, isExternal: false);
    });
  }

  void _stopInAppBatch() {
    _batchTimer?.cancel();
    _batchTimer = null;
    if (!mounted) return;
    setState(() {
      _isBatchRunning = false;
      _batchProgressIndex = 0;
      _batchCurrentLabel = '';
    });
  }

  Future<void> _triggerExternalBatch() async {
    _ensureNotificationsActive();
    await _ensureNativePermission();
    if (!mounted) return;

    final delay = _minimizeOnExternalPush
        ? const Duration(milliseconds: 1800)
        : const Duration(milliseconds: 250);

    await _service.emitAllCategoriesExternal(
      minimizeApp: _minimizeOnExternalPush,
      initialDelay: delay,
      interval: const Duration(milliseconds: 900),
    );

    if (!_minimizeOnExternalPush && mounted) {
      _showFeedbackSnackBar(
        'Enviadas las 8 categorías a la barra de notificaciones Android.',
      );
    }
  }

  Future<void> _clearAndroidNotifications() async {
    await _service.cancelAllExternalNotifications();
    if (!mounted) return;
    _showFeedbackSnackBar('Barra de notificaciones Android limpiada.');
  }

  void _showFeedbackSnackBar(String message) {
    final primaryColor = AppTheme.getPrimaryColor(context);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          backgroundColor: primaryColor,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final bgColor = AppTheme.getBackgroundColor(context);
    final cardColor = AppTheme.getCardColor(context);
    final elevatedColor = AppTheme.getElevatedCardColor(context);
    final primaryColor = AppTheme.getPrimaryColor(context);
    final ctaColor = AppTheme.getPrimaryCtaColor(context);
    final textColor = AppTheme.getTextColor(context);
    final secondaryColor = AppTheme.getSecondaryTextColor(context);
    final borderColor = AppTheme.getBorderColor(context);
    final presets = NotificationEmulatorCatalog.allPresets;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: primaryColor),
          tooltip: 'Volver',
          onPressed: _navigateBack,
        ),
        title: Text(
          'Emulador de Notificaciones',
          style: GoogleFonts.plusJakartaSans(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ValueListenableBuilder<int>(
              valueListenable: _service.unreadCount,
              builder: (context, count, _) {
                return Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.notifications_outlined,
                        color: primaryColor,
                      ),
                      tooltip: 'Ver bandeja de notificaciones',
                      onPressed: _openInbox,
                    ),
                    if (count > 0)
                      Positioned(
                        top: 8,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1.5,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFCD382F),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            count > 99 ? '99+' : '$count',
                            style: GoogleFonts.manrope(
                              color: Colors.white,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            _buildStatusBanner(
              context: context,
              isDark: isDark,
              cardColor: cardColor,
              borderColor: borderColor,
              primaryColor: primaryColor,
              textColor: textColor,
              secondaryColor: secondaryColor,
            ),
            const SizedBox(height: 14),
            _buildBatchControlCard(
              context: context,
              isDark: isDark,
              cardColor: cardColor,
              elevatedColor: elevatedColor,
              borderColor: borderColor,
              primaryColor: primaryColor,
              ctaColor: ctaColor,
              textColor: textColor,
              secondaryColor: secondaryColor,
              totalCount: presets.length,
            ),
            const SizedBox(height: 22),
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'CATEGORÍAS INDIVIDUALES (${presets.length})',
                      style: GoogleFonts.manrope(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                        color: secondaryColor,
                      ),
                    ),
                  ),
                  Text(
                    'Dentro y fuera de la app',
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            ...presets.map(
              (preset) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildCategoryCard(
                  context: context,
                  preset: preset,
                  isDark: isDark,
                  cardColor: cardColor,
                  borderColor: borderColor,
                  primaryColor: primaryColor,
                  ctaColor: ctaColor,
                  textColor: textColor,
                  secondaryColor: secondaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBanner({
    required BuildContext context,
    required bool isDark,
    required Color cardColor,
    required Color borderColor,
    required Color primaryColor,
    required Color textColor,
    required Color secondaryColor,
  }) {
    return ValueListenableBuilder<NotificationPreferences>(
      valueListenable: _service.preferences,
      builder: (context, prefs, _) {
        final bool globalOff = !prefs.notificationsEnabled;
        final bool needsPerm = !_checkingPermission && !_hasNativePermission;

        final Color bannerBg;
        final Color bannerBorder;
        final Color iconColor;
        final IconData iconData;
        final String titleText;
        final String subtitleText;

        if (globalOff) {
          bannerBg = isDark
              ? AppTheme.functionalError.withValues(alpha: 0.14)
              : const Color(0xFFFFF4F2);
          bannerBorder = AppTheme.functionalError.withValues(alpha: 0.35);
          iconColor = AppTheme.functionalError;
          iconData = Icons.notifications_off_outlined;
          titleText = 'Notificaciones pausadas en ajustes';
          subtitleText =
              'Actívalas para ver el contador en inicio y recibir alertas completas.';
        } else if (needsPerm) {
          bannerBg = isDark
              ? AppTheme.functionalOffer.withValues(alpha: 0.14)
              : const Color(0xFFFFF8EC);
          bannerBorder = AppTheme.functionalOffer.withValues(alpha: 0.4);
          iconColor = AppTheme.functionalOffer;
          iconData = Icons.phonelink_lock_rounded;
          titleText = 'Permiso Push Android pendiente';
          subtitleText =
              'Concede permiso para mostrar avisos fuera de la app en la barra del sistema.';
        } else {
          bannerBg = isDark
              ? AppTheme.darkPrimaryLight
              : AppTheme.lightSecondaryBackground;
          bannerBorder = isDark
              ? primaryColor.withValues(alpha: 0.3)
              : const Color(0xFFCCDFD9);
          iconColor = primaryColor;
          iconData = Icons.notifications_active_rounded;
          titleText = 'Simulador móvil listo';
          subtitleText =
              'Prueba alertas internas (banner in-app) y externas (barra nativa Android).';
        }

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: bannerBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: bannerBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: isDark ? 0.2 : 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(iconData, color: iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titleText,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitleText,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: secondaryColor,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              if (globalOff || needsPerm) ...[
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    if (globalOff) {
                      _service.toggleNotificationsEnabled(true);
                    }
                    if (needsPerm) {
                      _ensureNativePermission();
                    }
                  },
                  child: Text(
                    'Activar',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                      color: primaryColor,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildBatchControlCard({
    required BuildContext context,
    required bool isDark,
    required Color cardColor,
    required Color elevatedColor,
    required Color borderColor,
    required Color primaryColor,
    required Color ctaColor,
    required Color textColor,
    required Color secondaryColor,
    required int totalCount,
  }) {
    final ctaTextColor = isDark ? AppTheme.darkOnPrimary : Colors.white;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.science_outlined, color: primaryColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Emulación por Modalidad',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Elige dónde visualizar las $totalCount categorías: flotando dentro de la app o en la barra del sistema Android.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              color: secondaryColor,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),

          // Choice chips de modalidad
          Row(
            children: [
              Expanded(
                child: _buildModeChip(
                  label: 'Dentro de la App',
                  icon: Icons.phonelink_ring_rounded,
                  isSelected: !_externalMode,
                  isDark: isDark,
                  primaryColor: primaryColor,
                  textColor: textColor,
                  onTap: () => setState(() => _externalMode = false),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildModeChip(
                  label: 'Fuera de la App',
                  icon: Icons.notifications_active_outlined,
                  isSelected: _externalMode,
                  isDark: isDark,
                  primaryColor: primaryColor,
                  textColor: textColor,
                  onTap: () {
                    _stopInAppBatch();
                    setState(() => _externalMode = true);
                  },
                ),
              ),
            ],
          ),

          if (_externalMode) ...[
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: isDark
                    ? AppTheme.darkBackground
                    : AppTheme.lightSecondaryBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              child: SwitchListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 2,
                ),
                title: Text(
                  'Minimizar app al enviar',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                subtitle: Text(
                  'Cierra la vista al escritorio móvil para ver el banner fuera de la app',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: secondaryColor,
                  ),
                ),
                value: _minimizeOnExternalPush,
                activeThumbColor: primaryColor,
                activeTrackColor: primaryColor.withValues(alpha: 0.35),
                onChanged: (v) => setState(() => _minimizeOnExternalPush = v),
              ),
            ),
          ],

          if (_isBatchRunning) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isDark
                    ? AppTheme.darkPrimaryLight
                    : AppTheme.lightPrimaryLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: primaryColor.withValues(alpha: 0.35),
                ),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Emulando $_batchProgressIndex/$totalCount • $_batchCurrentLabel',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: primaryColor,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _stopInAppBatch,
                    style: TextButton.styleFrom(
                      minimumSize: const Size(0, 32),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    child: Text(
                      'Detener',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.functionalError,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 14),

          // Botón CTA Principal (altura mínima 48px)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _externalMode
                  ? _triggerExternalBatch
                  : (_isBatchRunning ? _stopInAppBatch : _startInAppBatch),
              icon: Icon(
                _externalMode
                    ? Icons.send_to_mobile_rounded
                    : (_isBatchRunning
                        ? Icons.stop_circle_outlined
                        : Icons.play_circle_fill_rounded),
                color: ctaTextColor,
              ),
              label: Text(
                _externalMode
                    ? 'Emular las $totalCount categorías (Fuera de la App)'
                    : (_isBatchRunning
                        ? 'Detener secuencia en app'
                        : 'Emular las $totalCount categorías (En App)'),
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5,
                  color: ctaTextColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _isBatchRunning ? AppTheme.functionalError : ctaColor,
                foregroundColor: ctaTextColor,
                minimumSize: const Size(0, 48),
                elevation: isDark ? 0 : 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Botón Secundario (altura mínima 48px)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed:
                  _externalMode ? _clearAndroidNotifications : _openInbox,
              icon: Icon(
                _externalMode
                    ? Icons.clear_all_rounded
                    : Icons.inbox_rounded,
                size: 18,
              ),
              label: Text(
                _externalMode
                    ? 'Limpiar barra Android'
                    : 'Abrir bandeja de notificaciones',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 48),
                backgroundColor:
                    isDark ? AppTheme.darkCardElevated : Colors.white,
                foregroundColor: isDark ? const Color(0xFFD1D5DB) : textColor,
                side: BorderSide(
                  color:
                      isDark ? AppTheme.darkBorderSubtle : AppTheme.lightBorder,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required bool isDark,
    required Color primaryColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    final Color bg;
    final Color border;
    final Color contentColor;

    if (isSelected) {
      if (isDark) {
        bg = AppTheme.darkPrimaryLight;
        border = AppTheme.darkPrimary.withValues(alpha: 0.3);
        contentColor = const Color(0xFF34D399);
      } else {
        bg = AppTheme.lightPrimary;
        border = AppTheme.lightPrimary;
        contentColor = Colors.white;
      }
    } else {
      if (isDark) {
        bg = AppTheme.darkCardElevated;
        border = AppTheme.darkBorderSubtle;
        contentColor = const Color(0xFFD1D5DB);
      } else {
        bg = const Color(0xFFF1F4F0);
        border = const Color(0xFFCCDFD9);
        contentColor = textColor;
      }
    }

    return BouncingButton(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: contentColor),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: contentColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard({
    required BuildContext context,
    required NotificationCategoryPreset preset,
    required bool isDark,
    required Color cardColor,
    required Color borderColor,
    required Color primaryColor,
    required Color ctaColor,
    required Color textColor,
    required Color secondaryColor,
  }) {
    final String priorityLabel;
    final Color priorityColor;

    switch (preset.priority) {
      case NotificationPriority.urgent:
        priorityLabel = 'URGENTE';
        priorityColor = AppTheme.functionalError;
        break;
      case NotificationPriority.important:
        priorityLabel = 'IMPORTANTE';
        priorityColor = AppTheme.functionalOffer;
        break;
      case NotificationPriority.info:
        priorityLabel = 'INFO';
        priorityColor = AppTheme.functionalInfo;
        break;
    }

    final ctaTextColor = isDark ? AppTheme.darkOnPrimary : Colors.white;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: preset.accentColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(preset.icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          preset.categoryLabel,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: priorityColor.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            priorityLabel,
                            style: GoogleFonts.manrope(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: priorityColor,
                            ),
                          ),
                        ),
                        if (preset.priceTag != null)
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
                              preset.priceTag!,
                              style: GoogleFonts.manrope(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: primaryColor,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      preset.subtitle,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: secondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark
                  ? AppTheme.darkBackground
                  : AppTheme.lightSecondaryBackground,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  preset.title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  preset.description,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: secondaryColor,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _triggerSingleInApp(preset),
                  icon: Icon(
                    Icons.phonelink_ring_rounded,
                    size: 16,
                    color: primaryColor,
                  ),
                  label: Text(
                    'En App',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 48),
                    backgroundColor:
                        isDark ? AppTheme.darkCardElevated : Colors.white,
                    foregroundColor: primaryColor,
                    side: BorderSide(
                      color: isDark
                          ? AppTheme.darkBorderSubtle
                          : const Color(0xFFCCDFD9),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _triggerSingleExternal(preset),
                  icon: Icon(
                    Icons.notifications_active_rounded,
                    size: 16,
                    color: ctaTextColor,
                  ),
                  label: Text(
                    'Fuera (Push)',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: ctaTextColor,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 48),
                    backgroundColor: ctaColor,
                    foregroundColor: ctaTextColor,
                    elevation: isDark ? 0 : 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
