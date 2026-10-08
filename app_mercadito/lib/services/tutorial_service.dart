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
