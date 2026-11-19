import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import '../services/sound_service.dart';
import '../services/user_session.dart';
import '../theme/app_theme.dart';

class TutorialService {
  static final TutorialService _instance = TutorialService._internal();
  factory TutorialService() => _instance;
  TutorialService._internal();

  TutorialCoachMark? _currentTutorial;

  /// Retorna si el tutorial está activo en este momento
  bool get isTutorialActive => _currentTutorial != null;

  /// Muestra el tutorial interactivo de la barra de navegación inferior
  /// con foco (spotlight) en cada uno de los 5 menús clave.
  void showNavTutorial(
    BuildContext context, {
    required GlobalKey homeKey,
    required GlobalKey cartKey,
    required GlobalKey marketKey,
    required GlobalKey providersKey,
    required GlobalKey chatsKey,
    bool force = false,
    VoidCallback? onFinish,
  }) {
    // Si ya lo vio y no es forzado, no volver a mostrar
    if (!force && UserSession.hasSeenNavTutorial) {
      return;
    }

    // Evitar ejecutar durante tests automatizados de widgets sin contexto de render
    final bindingStr = WidgetsBinding.instance.runtimeType.toString();
    if (bindingStr.contains('TestWidgetsFlutterBinding') ||
        bindingStr.contains('AutomatedTestWidgetsFlutterBinding')) {
      UserSession.hasSeenNavTutorial = true;
      onFinish?.call();
      return;
    }

    // Marcar como visto para futuros inicios de sesión
    UserSession.hasSeenNavTutorial = true;

    final targets = _createNavTargets(
      context: context,
      homeKey: homeKey,
      cartKey: cartKey,
      marketKey: marketKey,
      providersKey: providersKey,
      chatsKey: chatsKey,
    );

    final isDark = Theme.of(context).brightness == Brightness.dark;

    _currentTutorial = TutorialCoachMark(
      targets: targets,
      colorShadow: isDark ? const Color(0xFF020C07) : const Color(0xFF0F172A),
      paddingFocus: 12,
      opacityShadow: 0.82,
      imageFilter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
      hideSkip: true, // Manejamos el botón Omitir personalizado dentro de cada tarjeta
      onFinish: () {
        _currentTutorial = null;
        onFinish?.call();
      },
      onSkip: () {
        SoundService.playButtonClick();
        _currentTutorial = null;
        onFinish?.call();
        return true;
      },
      onClickTarget: (target) {
        SoundService.playButtonClick();
      },
    );

    // Ejecutar presentación tras renderizado seguro
    Future.delayed(const Duration(milliseconds: 300), () {
      if (context.mounted) {
        _currentTutorial?.show(context: context);
      }
    });
  }

  /// Muestra el tutorial interactivo cuando el usuario ingresa por primera vez
  /// a la pantalla de Agregar Producto (AddProductScreen).
  void showAddProductTutorial(
    BuildContext context, {
    required GlobalKey previewKey,
    required GlobalKey mediaKey,
    required GlobalKey basicInfoKey,
    required GlobalKey pricingKey,
    required GlobalKey saveButtonKey,
    bool force = false,
    VoidCallback? onFinish,
  }) {
    if (!force && UserSession.hasSeenAddProductTutorial) {
      return;
    }

    final bindingStr = WidgetsBinding.instance.runtimeType.toString();
    if (bindingStr.contains('TestWidgetsFlutterBinding') ||
        bindingStr.contains('AutomatedTestWidgetsFlutterBinding')) {
      UserSession.hasSeenAddProductTutorial = true;
      onFinish?.call();
      return;
    }

    UserSession.hasSeenAddProductTutorial = true;

    final targets = _createAddProductTargets(
      context: context,
      previewKey: previewKey,
      mediaKey: mediaKey,
      basicInfoKey: basicInfoKey,
      pricingKey: pricingKey,
      saveButtonKey: saveButtonKey,
    );

    final isDark = Theme.of(context).brightness == Brightness.dark;

    void restoreScrollTop() {
      final topCtx = previewKey.currentContext;
      if (topCtx != null && topCtx.mounted) {
        Scrollable.ensureVisible(
          topCtx,
          alignment: 0.0,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
        );
      }
    }

    _currentTutorial = TutorialCoachMark(
      targets: targets,
      colorShadow: isDark ? const Color(0xFF020C07) : const Color(0xFF0F172A),
      paddingFocus: 10,
      opacityShadow: 0.82,
      imageFilter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
      hideSkip: true,
      beforeFocus: (target) async {
        if (target.identify == 'add_product_save') {
          final topCtx = previewKey.currentContext;
          if (topCtx != null && topCtx.mounted) {
            await Scrollable.ensureVisible(
              topCtx,
              alignment: 0.0,
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
            );
          }
          return;
        }
        final targetCtx = target.keyTarget?.currentContext;
        if (targetCtx != null && targetCtx.mounted) {
          await Scrollable.ensureVisible(
            targetCtx,
            alignment: 0.08,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
          );
        }
      },
      onFinish: () {
        _currentTutorial = null;
        restoreScrollTop();
        onFinish?.call();
      },
      onSkip: () {
        SoundService.playButtonClick();
        _currentTutorial = null;
        restoreScrollTop();
        onFinish?.call();
        return true;
      },
      onClickTarget: (target) {
        SoundService.playButtonClick();
      },
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      if (context.mounted) {
        _currentTutorial?.show(context: context);
      }
    });
  }

  List<TargetFocus> _createAddProductTargets({
    required BuildContext context,
    required GlobalKey previewKey,
    required GlobalKey mediaKey,
    required GlobalKey basicInfoKey,
    required GlobalKey pricingKey,
    required GlobalKey saveButtonKey,
  }) {
    return [
      TargetFocus(
        identify: 'add_product_preview',
        keyTarget: previewKey,
        shape: ShapeLightFocus.RRect,
        radius: 16,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return _buildTutorialCard(
                context: context,
                controller: controller,
                stepNumber: 1,
                totalSteps: 5,
                title: 'Vista Previa en Tiempo Real',
                description:
                    'Observa al instante cómo verán los compradores tu producto en el catálogo, pudiendo alternar entre la vista Al Detalle y Al Por Mayor.',
                icon: Icons.visibility_rounded,
                isLastStep: false,
              );
            },
          ),
        ],
      ),
      TargetFocus(
        identify: 'add_product_media',
        keyTarget: mediaKey,
        shape: ShapeLightFocus.RRect,
        radius: 16,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return _buildTutorialCard(
                context: context,
                controller: controller,
                stepNumber: 2,
                totalSteps: 5,
                title: 'Fotografías y Video del Producto',
                description:
                    'Sube hasta 8 fotos reales y 1 video demostrativo. La foto #1 será tu portada principal y puedes reordenarlas fácilmente.',
                icon: Icons.perm_media_rounded,
                isLastStep: false,
              );
            },
          ),
        ],
      ),
      TargetFocus(
        identify: 'add_product_basic_info',
        keyTarget: basicInfoKey,
        shape: ShapeLightFocus.RRect,
        radius: 16,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return _buildTutorialCard(
                context: context,
                controller: controller,
                stepNumber: 3,
                totalSteps: 5,
                title: 'Catálogo Oficial y Datos Básicos',
                description:
                    'Elige del catálogo oficial estandarizado para autocompletar nombre, categoría y etiquetas, o escribe tus propios datos agrícolas.',
                icon: Icons.category_rounded,
                isLastStep: false,
              );
            },
          ),
        ],
      ),
      TargetFocus(
        identify: 'add_product_pricing',
        keyTarget: pricingKey,
        shape: ShapeLightFocus.RRect,
        radius: 16,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return _buildTutorialCard(
                context: context,
                controller: controller,
                stepNumber: 4,
                totalSteps: 5,
                title: 'Precios, Unidades y Calidad',
                description:
                    'Establece precios al detalle o al por mayor con rangos mínimos y máximos, selecciona unidades de venta y define el grado de calidad.',
                icon: Icons.price_change_rounded,
                isLastStep: false,
              );
            },
          ),
        ],
      ),
      TargetFocus(
        identify: 'add_product_save',
        keyTarget: saveButtonKey,
        shape: ShapeLightFocus.RRect,
        radius: 16,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return _buildTutorialCard(
                context: context,
                controller: controller,
                stepNumber: 5,
                totalSteps: 5,
                title: 'Guardar y Publicar',
                description:
                    'Cuando completes la información de tu cosecha o producto, pulsa aquí para publicarlo inmediatamente en El Mercadito.',
                icon: Icons.save_rounded,
                isLastStep: true,
              );
            },
          ),
        ],
      ),
    ];
  }

  /// Muestra el tutorial interactivo cuando el usuario ingresa por primera vez
  /// a la pantalla de Tareas (TasksScreen).
  void showTasksTutorial(
    BuildContext context, {
    required GlobalKey streakBannerKey,
    required GlobalKey dailySummaryKey,
    required GlobalKey taskListKey,
    bool force = false,
    VoidCallback? onFinish,
  }) {
    if (!force && UserSession.hasSeenTasksTutorial) {
      return;
    }

    final bindingStr = WidgetsBinding.instance.runtimeType.toString();
    if (bindingStr.contains('TestWidgetsFlutterBinding') ||
        bindingStr.contains('AutomatedTestWidgetsFlutterBinding')) {
      UserSession.hasSeenTasksTutorial = true;
      onFinish?.call();
      return;
    }

    UserSession.hasSeenTasksTutorial = true;

    final targets = _createTasksTargets(
      context: context,
      streakBannerKey: streakBannerKey,
      dailySummaryKey: dailySummaryKey,
      taskListKey: taskListKey,
    );

    final isDark = Theme.of(context).brightness == Brightness.dark;

    _currentTutorial = TutorialCoachMark(
      targets: targets,
      colorShadow: isDark ? const Color(0xFF020C07) : const Color(0xFF0F172A),
      paddingFocus: 10,
      opacityShadow: 0.82,
      imageFilter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
      hideSkip: true,
      beforeFocus: (target) async {
        final targetCtx = target.keyTarget?.currentContext;
        if (targetCtx != null && targetCtx.mounted) {
          await Scrollable.ensureVisible(
            targetCtx,
            alignment: 0.1,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
          );
        }
      },
      onFinish: () {
        _currentTutorial = null;
        onFinish?.call();
      },
      onSkip: () {
        SoundService.playButtonClick();
        _currentTutorial = null;
        onFinish?.call();
        return true;
      },
      onClickTarget: (target) {
        SoundService.playButtonClick();
      },
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      if (context.mounted) {
        _currentTutorial?.show(context: context);
      }
    });
  }

  List<TargetFocus> _createTasksTargets({
    required BuildContext context,
    required GlobalKey streakBannerKey,
    required GlobalKey dailySummaryKey,
    required GlobalKey taskListKey,
  }) {
    return [
      TargetFocus(
        identify: 'tasks_streak_banner',
        keyTarget: streakBannerKey,
        shape: ShapeLightFocus.RRect,
        radius: 16,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return _buildTutorialCard(
                context: context,
                controller: controller,
                stepNumber: 1,
                totalSteps: 3,
                title: 'Racha y Puntos de Productor',
                description:
                    'Monitorea tu racha consecutiva de días activos y los puntos que acumulas al completar tus metas diarias.',
                icon: Icons.local_fire_department_rounded,
                isLastStep: false,
              );
            },
          ),
        ],
      ),
      TargetFocus(
        identify: 'tasks_daily_summary',
        keyTarget: dailySummaryKey,
        shape: ShapeLightFocus.RRect,
        radius: 16,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return _buildTutorialCard(
                context: context,
                controller: controller,
                stepNumber: 2,
                totalSteps: 3,
                title: 'Progreso y Metas del Día',
                description:
                    'Revisa cuántas tareas has finalizado hoy para desbloquear el cofre de recompensas y bonificaciones especiales.',
                icon: Icons.fact_check_rounded,
                isLastStep: false,
              );
            },
          ),
        ],
      ),
      TargetFocus(
        identify: 'tasks_list_section',
        keyTarget: taskListKey,
        shape: ShapeLightFocus.RRect,
        radius: 16,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return _buildTutorialCard(
                context: context,
                controller: controller,
                stepNumber: 3,
                totalSteps: 3,
                title: 'Misiones y Reclamo de Puntos',
                description:
                    'Cumple misiones como actualizar precios o responder clientes, y pulsa "Reclamar" para sumar tus puntos al instante.',
                icon: Icons.military_tech_rounded,
                isLastStep: true,
              );
            },
          ),
        ],
      ),
    ];
  }

  /// Muestra el tutorial interactivo cuando el usuario ingresa por primera vez
  /// a la pantalla de Negociaciones (NegotiationsScreen).
  void showNegotiationsTutorial(
    BuildContext context, {
    required GlobalKey tabsKey,
    required GlobalKey searchFilterKey,
    required GlobalKey negotiationCardKey,
    bool force = false,
    VoidCallback? onFinish,
  }) {
    if (!force && UserSession.hasSeenNegotiationsTutorial) {
      return;
    }

    final bindingStr = WidgetsBinding.instance.runtimeType.toString();
    if (bindingStr.contains('TestWidgetsFlutterBinding') ||
        bindingStr.contains('AutomatedTestWidgetsFlutterBinding')) {
      UserSession.hasSeenNegotiationsTutorial = true;
      onFinish?.call();
      return;
    }

    UserSession.hasSeenNegotiationsTutorial = true;

    final targets = _createNegotiationsTargets(
      context: context,
      tabsKey: tabsKey,
      searchFilterKey: searchFilterKey,
      negotiationCardKey: negotiationCardKey,
    );

    final isDark = Theme.of(context).brightness == Brightness.dark;

    _currentTutorial = TutorialCoachMark(
      targets: targets,
      colorShadow: isDark ? const Color(0xFF020C07) : const Color(0xFF0F172A),
      paddingFocus: 10,
      opacityShadow: 0.82,
      imageFilter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
      hideSkip: true,
      beforeFocus: (target) async {
        final targetCtx = target.keyTarget?.currentContext;
        if (targetCtx != null && targetCtx.mounted) {
          await Scrollable.ensureVisible(
            targetCtx,
            alignment: 0.1,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
          );
        }
      },
      onFinish: () {
        _currentTutorial = null;
        onFinish?.call();
      },
      onSkip: () {
        SoundService.playButtonClick();
        _currentTutorial = null;
        onFinish?.call();
        return true;
      },
      onClickTarget: (target) {
        SoundService.playButtonClick();
      },
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      if (context.mounted) {
        _currentTutorial?.show(context: context);
      }
    });
  }

  List<TargetFocus> _createNegotiationsTargets({
    required BuildContext context,
    required GlobalKey tabsKey,
    required GlobalKey searchFilterKey,
    required GlobalKey negotiationCardKey,
  }) {
    return [
      TargetFocus(
        identify: 'negotiations_tabs',
        keyTarget: tabsKey,
        shape: ShapeLightFocus.RRect,
        radius: 16,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return _buildTutorialCard(
                context: context,
                controller: controller,
                stepNumber: 1,
                totalSteps: 3,
                title: 'Pestañas de Negociación',
                description:
                    'Alterna ágilmente entre Solicitudes Recientes, Acuerdos Concretados y Negociaciones Canceladas.',
                icon: Icons.segment_rounded,
                isLastStep: false,
              );
            },
          ),
        ],
      ),
      TargetFocus(
        identify: 'negotiations_filter',
        keyTarget: searchFilterKey,
        shape: ShapeLightFocus.RRect,
        radius: 16,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return _buildTutorialCard(
                context: context,
                controller: controller,
                stepNumber: 2,
                totalSteps: 3,
                title: 'Búsqueda y Filtros Avanzados',
                description:
                    'Filtra por producto, rol de Comprador o Proveedor y selecciona rangos de fecha específicos para tus transacciones.',
                icon: Icons.tune_rounded,
                isLastStep: false,
              );
            },
          ),
        ],
      ),
      TargetFocus(
        identify: 'negotiations_card',
        keyTarget: negotiationCardKey,
        shape: ShapeLightFocus.RRect,
        radius: 16,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return _buildTutorialCard(
                context: context,
                controller: controller,
                stepNumber: 3,
                totalSteps: 3,
                title: 'Gestión Directa y Acuerdos',
                description:
                    'Examina precios por volumen, responde mensajes, envía contraofertas y confirma el cierre de la venta con un solo toque.',
                icon: Icons.handshake_outlined,
                isLastStep: true,
              );
            },
          ),
        ],
      ),
    ];
  }

  /// Muestra el tutorial interactivo cuando el usuario ingresa por primera vez
  /// a la pantalla de Gestión de Cupones (CouponsManagerScreen).
  void showCouponsManagerTutorial(
    BuildContext context, {
    required GlobalKey metricsKey,
    required GlobalKey searchFilterKey,
    required GlobalKey createButtonKey,
    bool force = false,
    VoidCallback? onFinish,
  }) {
    if (!force && UserSession.hasSeenCouponsManagerTutorial) {
      return;
    }

    final bindingStr = WidgetsBinding.instance.runtimeType.toString();
    if (bindingStr.contains('TestWidgetsFlutterBinding') ||
        bindingStr.contains('AutomatedTestWidgetsFlutterBinding')) {
      UserSession.hasSeenCouponsManagerTutorial = true;
      onFinish?.call();
      return;
    }

    UserSession.hasSeenCouponsManagerTutorial = true;

    final targets = _createCouponsManagerTargets(
      context: context,
      metricsKey: metricsKey,
      searchFilterKey: searchFilterKey,
      createButtonKey: createButtonKey,
    );

    final isDark = Theme.of(context).brightness == Brightness.dark;

    _currentTutorial = TutorialCoachMark(
      targets: targets,
      colorShadow: isDark ? const Color(0xFF020C07) : const Color(0xFF0F172A),
      paddingFocus: 10,
      opacityShadow: 0.82,
      imageFilter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
      hideSkip: true,
      beforeFocus: (target) async {
        final targetCtx = target.keyTarget?.currentContext;
        if (targetCtx != null && targetCtx.mounted) {
          await Scrollable.ensureVisible(
            targetCtx,
            alignment: 0.1,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
          );
        }
      },
      onFinish: () {
        _currentTutorial = null;
        onFinish?.call();
      },
      onSkip: () {
        SoundService.playButtonClick();
        _currentTutorial = null;
        onFinish?.call();
        return true;
      },
      onClickTarget: (target) {
        SoundService.playButtonClick();
      },
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      if (context.mounted) {
        _currentTutorial?.show(context: context);
      }
    });
  }

  List<TargetFocus> _createCouponsManagerTargets({
    required BuildContext context,
    required GlobalKey metricsKey,
    required GlobalKey searchFilterKey,
    required GlobalKey createButtonKey,
  }) {
    return [
      TargetFocus(
        identify: 'coupons_metrics',
        keyTarget: metricsKey,
        shape: ShapeLightFocus.RRect,
        radius: 16,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return _buildTutorialCard(
                context: context,
                controller: controller,
                stepNumber: 1,
                totalSteps: 3,
                title: 'Resumen de Rendimiento',
                description:
                    'Monitorea las ventas generadas, el total de cupones canjeados y el impacto financiero de tus promociones activas.',
                icon: Icons.insights_rounded,
                isLastStep: false,
              );
            },
          ),
        ],
      ),
      TargetFocus(
        identify: 'coupons_filters',
        keyTarget: searchFilterKey,
        shape: ShapeLightFocus.RRect,
        radius: 16,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return _buildTutorialCard(
                context: context,
                controller: controller,
                stepNumber: 2,
                totalSteps: 3,
                title: 'Búsqueda y Estado de Cupones',
                description:
                    'Encuentra promociones por código o título y filtra entre cupones Activos, Pausados o Finalizados.',
                icon: Icons.filter_alt_rounded,
                isLastStep: false,
              );
            },
          ),
        ],
      ),
      TargetFocus(
        identify: 'coupons_create_button',
        keyTarget: createButtonKey,
        shape: ShapeLightFocus.RRect,
        radius: 20,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return _buildTutorialCard(
                context: context,
                controller: controller,
                stepNumber: 3,
                totalSteps: 3,
                title: 'Crear Nueva Promoción',
                description:
                    'Diseña cupones personalizados definiendo montos mínimos de compra, porcentajes de descuento y límites de canje.',
                icon: Icons.add_circle_outline_rounded,
                isLastStep: true,
              );
            },
          ),
        ],
      ),
    ];
  }

  /// Muestra el tutorial interactivo cuando el usuario ingresa por primera vez
  /// a la pantalla de Gestión de Ofertas Relámpago (FlashOffersManagerScreen).
  void showFlashOffersManagerTutorial(
    BuildContext context, {
    required GlobalKey tabsKey,
    required GlobalKey activeBannerKey,
    required GlobalKey newOfferActionKey,
    bool force = false,
    VoidCallback? onFinish,
  }) {
    if (!force && UserSession.hasSeenFlashOffersManagerTutorial) {
      return;
    }

    final bindingStr = WidgetsBinding.instance.runtimeType.toString();
    if (bindingStr.contains('TestWidgetsFlutterBinding') ||
        bindingStr.contains('AutomatedTestWidgetsFlutterBinding')) {
      UserSession.hasSeenFlashOffersManagerTutorial = true;
      onFinish?.call();
      return;
    }

    UserSession.hasSeenFlashOffersManagerTutorial = true;

    final targets = _createFlashOffersManagerTargets(
      context: context,
      tabsKey: tabsKey,
      activeBannerKey: activeBannerKey,
      newOfferActionKey: newOfferActionKey,
    );

    final isDark = Theme.of(context).brightness == Brightness.dark;

    _currentTutorial = TutorialCoachMark(
      targets: targets,
      colorShadow: isDark ? const Color(0xFF020C07) : const Color(0xFF0F172A),
      paddingFocus: 10,
      opacityShadow: 0.82,
      imageFilter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
      hideSkip: true,
      beforeFocus: (target) async {
        final targetCtx = target.keyTarget?.currentContext;
        if (targetCtx != null && targetCtx.mounted) {
          await Scrollable.ensureVisible(
            targetCtx,
            alignment: 0.1,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
          );
        }
      },
      onFinish: () {
        _currentTutorial = null;
        onFinish?.call();
      },
      onSkip: () {
        SoundService.playButtonClick();
        _currentTutorial = null;
        onFinish?.call();
        return true;
      },
      onClickTarget: (target) {
        SoundService.playButtonClick();
      },
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      if (context.mounted) {
        _currentTutorial?.show(context: context);
      }
    });
  }

  List<TargetFocus> _createFlashOffersManagerTargets({
    required BuildContext context,
    required GlobalKey tabsKey,
    required GlobalKey activeBannerKey,
    required GlobalKey newOfferActionKey,
  }) {
    return [
      TargetFocus(
        identify: 'flash_offers_tabs',
        keyTarget: tabsKey,
        shape: ShapeLightFocus.RRect,
        radius: 16,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return _buildTutorialCard(
                context: context,
                controller: controller,
                stepNumber: 1,
                totalSteps: 3,
                title: 'Gestor de Ofertas Flash',
                description:
                    'Navega entre Ofertas en curso, tu catálogo de Productos disponibles y el Histórico de promociones concluidas.',
                icon: Icons.tab_rounded,
                isLastStep: false,
              );
            },
          ),
        ],
      ),
      TargetFocus(
        identify: 'flash_offers_active_banner',
        keyTarget: activeBannerKey,
        shape: ShapeLightFocus.RRect,
        radius: 16,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return _buildTutorialCard(
                context: context,
                controller: controller,
                stepNumber: 2,
                totalSteps: 3,
                title: 'Temporizador y Estado en Vivo',
                description:
                    'Visualiza en tiempo real las horas y minutos restantes de cada oferta relámpago antes de su expiración automática.',
                icon: Icons.timer_outlined,
                isLastStep: false,
              );
            },
          ),
        ],
      ),
      TargetFocus(
        identify: 'flash_offers_action_button',
        keyTarget: newOfferActionKey,
        shape: ShapeLightFocus.RRect,
        radius: 14,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return _buildTutorialCard(
                context: context,
                controller: controller,
                stepNumber: 3,
                totalSteps: 3,
                title: 'Lanzar Oferta Relámpago',
                description:
                    'Publica descuentos por tiempo limitado para acelerar la rotación de cosecha y atraer compradores en minutos.',
                icon: Icons.bolt_rounded,
                isLastStep: true,
              );
            },
          ),
        ],
      ),
    ];
  }

  /// Muestra el tutorial interactivo cuando el usuario ingresa por primera vez
  /// a la pantalla de Análisis de Mercado (MarketAnalysisScreen).
  void showMarketAnalysisTutorial(
    BuildContext context, {
    required GlobalKey tabsKey,
    required GlobalKey modeSwitchKey,
    required GlobalKey pricesListKey,
    bool force = false,
    VoidCallback? onFinish,
  }) {
    if (!force && UserSession.hasSeenMarketAnalysisTutorial) {
      return;
    }

    final bindingStr = WidgetsBinding.instance.runtimeType.toString();
    if (bindingStr.contains('TestWidgetsFlutterBinding') ||
        bindingStr.contains('AutomatedTestWidgetsFlutterBinding')) {
      UserSession.hasSeenMarketAnalysisTutorial = true;
      onFinish?.call();
      return;
    }

    UserSession.hasSeenMarketAnalysisTutorial = true;

    final targets = _createMarketAnalysisTargets(
      context: context,
      tabsKey: tabsKey,
      modeSwitchKey: modeSwitchKey,
      pricesListKey: pricesListKey,
    );

    final isDark = Theme.of(context).brightness == Brightness.dark;

    _currentTutorial = TutorialCoachMark(
      targets: targets,
      colorShadow: isDark ? const Color(0xFF020C07) : const Color(0xFF0F172A),
      paddingFocus: 10,
      opacityShadow: 0.82,
      imageFilter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
      hideSkip: true,
      beforeFocus: (target) async {
        final targetCtx = target.keyTarget?.currentContext;
        if (targetCtx != null && targetCtx.mounted) {
          await Scrollable.ensureVisible(
            targetCtx,
            alignment: 0.1,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
          );
        }
      },
      onFinish: () {
        _currentTutorial = null;
        onFinish?.call();
      },
      onSkip: () {
        SoundService.playButtonClick();
        _currentTutorial = null;
        onFinish?.call();
        return true;
      },
      onClickTarget: (target) {
        SoundService.playButtonClick();
      },
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      if (context.mounted) {
        _currentTutorial?.show(context: context);
      }
    });
  }

  List<TargetFocus> _createMarketAnalysisTargets({
    required BuildContext context,
    required GlobalKey tabsKey,
    required GlobalKey modeSwitchKey,
    required GlobalKey pricesListKey,
  }) {
    return [
      TargetFocus(
        identify: 'market_tabs',
        keyTarget: tabsKey,
        shape: ShapeLightFocus.RRect,
        radius: 16,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return _buildTutorialCard(
                context: context,
                controller: controller,
                stepNumber: 1,
                totalSteps: 3,
                title: 'Herramientas de Mercado',
                description:
                    'Consulta Precios de referencia oficiales, Noticias del sector agropecuario y Tendencias de oferta y demanda.',
                icon: Icons.query_stats_rounded,
                isLastStep: false,
              );
            },
          ),
        ],
      ),
      TargetFocus(
        identify: 'market_mode_switch',
        keyTarget: modeSwitchKey,
        shape: ShapeLightFocus.RRect,
        radius: 16,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return _buildTutorialCard(
                context: context,
                controller: controller,
                stepNumber: 2,
                totalSteps: 3,
                title: 'Modalidad Detalle vs Mayorista',
                description:
                    'Alterna entre precios al detalle en supermercados y cotizaciones al por mayor en centrales de abastos y mercados mayoristas.',
                icon: Icons.swap_horiz_rounded,
                isLastStep: false,
              );
            },
          ),
        ],
      ),
      TargetFocus(
        identify: 'market_prices_list',
        keyTarget: pricesListKey,
        shape: ShapeLightFocus.RRect,
        radius: 16,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return _buildTutorialCard(
                context: context,
                controller: controller,
                stepNumber: 3,
                totalSteps: 3,
                title: 'Tendencias y Variaciones',
                description:
                    'Compara precios promedios, variaciones porcentuales por producto y detalles por variedad para negociar informado.',
                icon: Icons.trending_up_rounded,
                isLastStep: true,
              );
            },
          ),
        ],
      ),
    ];
  }

  /// Construye los 5 pasos interactivos correspondientes a la navegación principal
  List<TargetFocus> _createNavTargets({
    required BuildContext context,
    required GlobalKey homeKey,
    required GlobalKey cartKey,
    required GlobalKey marketKey,
    required GlobalKey providersKey,
    required GlobalKey chatsKey,
  }) {
    return [
      // 1. Inicio
      TargetFocus(
        identify: "nav_home",
        keyTarget: homeKey,
        shape: ShapeLightFocus.Circle,
        radius: 32,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return _buildTutorialCard(
                context: context,
                controller: controller,
                stepNumber: 1,
                totalSteps: 5,
                title: 'Inicio y Feed Fresco',
                description:
                    'Tu punto de partida. Aquí encontrarás ofertas relámpago con temporizadores, productos destacados y las mejores oportunidades agrícolas del día.',
                icon: Icons.home_rounded,
                isLastStep: false,
              );
            },
          ),
        ],
      ),

      // 2. Carrito
      TargetFocus(
        identify: "nav_cart",
        keyTarget: cartKey,
        shape: ShapeLightFocus.Circle,
        radius: 32,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return _buildTutorialCard(
                context: context,
                controller: controller,
                stepNumber: 2,
                totalSteps: 5,
                title: 'Carrito de Compras',
                description:
                    'Gestiona tus productos agregados, cambia entre venta al por mayor o al detalle y calcula los precios antes de empezar la negociación.',
                icon: Icons.shopping_cart_rounded,
                isLastStep: false,
              );
            },
          ),
        ],
      ),

      // 3. Mercado
      TargetFocus(
        identify: "nav_market",
        keyTarget: marketKey,
        shape: ShapeLightFocus.Circle,
        radius: 32,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return _buildTutorialCard(
                context: context,
                controller: controller,
                stepNumber: 3,
                totalSteps: 5,
                title: 'Mercado y Catálogo',
                description:
                    'Explora todos los productos que te ofrece El Mercadito.',
                icon: Icons.storefront_rounded,
                isLastStep: false,
              );
            },
          ),
        ],
      ),

      // 4. Proveedores
      TargetFocus(
        identify: "nav_providers",
        keyTarget: providersKey,
        shape: ShapeLightFocus.Circle,
        radius: 32,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return _buildTutorialCard(
                context: context,
                controller: controller,
                stepNumber: 4,
                totalSteps: 5,
                title: 'Proveedores',
                description:
                    'Conecta directamente con agricultores y fincas aliadas. Revisa su ubicación exacta, horarios de atención, niveles de reputación y políticas de venta.',
                icon: Icons.person_search_rounded,
                isLastStep: false,
              );
            },
          ),
        ],
      ),

      // 5. Chats
      TargetFocus(
        identify: "nav_chats",
        keyTarget: chatsKey,
        shape: ShapeLightFocus.Circle,
        radius: 32,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return _buildTutorialCard(
                context: context,
                controller: controller,
                stepNumber: 5,
                totalSteps: 5,
                title: 'Negociaciones y Mensajería',
                description:
                    'Habla en tiempo real con distintos proveedores para realizar una negociación y solicita demostraciones del producto en vivo.',
                icon: Icons.chat_bubble_rounded,
                isLastStep: true,
              );
            },
          ),
        ],
      ),
    ];
  }

  /// Tarjeta con diseño premium, compatible con modo día y noche,
  /// animación y feedback sonoro en cada botón.
  Widget _buildTutorialCard({
    required BuildContext context,
    required dynamic controller,
    required int stepNumber,
    required int totalSteps,
    required String title,
    required String description,
    required IconData icon,
    required bool isLastStep,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final primaryColor = isDark ? const Color(0xFF67C83B) : AppTheme.primary;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.18),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con badge de progreso y botón de icono
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: isDark ? 0.25 : 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: primaryColor.withValues(alpha: isDark ? 0.4 : 0.25),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 14, color: primaryColor),
                    const SizedBox(width: 6),
                    Text(
                      'Paso $stepNumber de $totalSteps',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: primaryColor,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
              // Dots indicators
              Row(
                children: List.generate(totalSteps, (idx) {
                  final active = (idx + 1) == stepNumber;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.only(left: 4),
                    width: active ? 16 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: active ? primaryColor : (isDark ? Colors.white24 : Colors.black12),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Título
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: textColor,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),

          // Descripción explicativa
          Text(
            description,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: subtitleColor,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 20),

          // Botones de acción: Omitir / Siguiente
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Botón Omitir
              TextButton(
                onPressed: () {
                  SoundService.playButtonClick();
                  controller.skip();
                },
                style: TextButton.styleFrom(
                  foregroundColor: subtitleColor,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                child: Text(
                  'Omitir guía',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              // Botón Siguiente / ¡Entendido!
              ElevatedButton.icon(
                onPressed: () {
                  SoundService.playButtonClick();
                  if (isLastStep) {
                    controller.next();
                  } else {
                    controller.next();
                  }
                },
                icon: Icon(
                  isLastStep ? Icons.check_rounded : Icons.arrow_forward_rounded,
                  size: 16,
                  color: Colors.white,
                ),
                label: Text(
                  isLastStep ? '¡Entendido, gracias!' : 'Siguiente',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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
