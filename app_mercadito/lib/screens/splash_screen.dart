import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

/// Pantalla de bienvenida (Splash Screen) que se ejecuta al iniciar la aplicación.
/// Muestra el logo oficial de El Mercadito con animaciones sutiles y luego
/// realiza la transición fluida a la pantalla de inicio de sesión (/login).
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final AnimationController _pulseController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _pulseAnimation;
  late final Animation<double> _textFadeAnimation;
  late final Animation<Offset> _textSlideAnimation;
  late final Animation<double> _progressAnimation;

  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );

    // Animación continua de latidos / respiración (+zoom y -zoom lento)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.50, curve: Curves.easeOutBack),
      ),
    );

    _pulseAnimation = Tween<double>(begin: 0.96, end: 1.06).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    _textFadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.25, 0.70, curve: Curves.easeOut),
    );

    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.25, 0.70, curve: Curves.easeOutCubic),
      ),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.95, curve: Curves.easeInOutCubic),
      ),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _goToLogin();
      }
    });

    _controller.forward();
  }

  void _goToLogin() {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;
    context.go('/login');
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final primaryColor = AppTheme.getPrimaryColor(context);
    final secondaryTextColor = AppTheme.getSecondaryTextColor(context);

    // Fondo con gradiente sutil y armónico según el modo activo
    final bgColor1 = isDark ? const Color(0xFF101815) : const Color(0xFFF9FBFA);
    final bgColor2 = isDark ? const Color(0xFF0C1411) : const Color(0xFFEEF5F1);

    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _goToLogin, // Permite saltar al tocar cualquier parte de la pantalla
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [bgColor1, bgColor2],
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                // Botón "Saltar" en la esquina superior derecha
                Positioned(
                  top: 12,
                  right: 16,
                  child: AnimatedBuilder(
                    animation: _textFadeAnimation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _textFadeAnimation.value,
                        child: child,
                      );
                    },
                    child: TextButton.icon(
                      onPressed: _goToLogin,
                      style: TextButton.styleFrom(
                        foregroundColor: isDark ? Colors.grey[400] : Colors.grey[600],
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                      label: const Text(
                        'Saltar',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),

                // Contenido principal centrado
                Center(
                  child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Animación del Logo con entrada y latido continuo (+zoom / -zoom lento)
                          AnimatedBuilder(
                            animation: Listenable.merge([_controller, _pulseController]),
                            builder: (context, child) {
                              return FadeTransition(
                                opacity: _fadeAnimation,
                                child: ScaleTransition(
                                  scale: _scaleAnimation,
                                  child: ScaleTransition(
                                    scale: _pulseAnimation,
                                    child: child,
                                  ),
                                ),
                              );
                            },
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Resplandor verde suave de fondo que acompaña el latido
                                Container(
                                  width: 220,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    boxShadow: [
                                      BoxShadow(
                                        color: primaryColor.withValues(
                                          alpha: isDark ? 0.35 : 0.20,
                                        ),
                                        blurRadius: 40,
                                        spreadRadius: 6,
                                      ),
                                    ],
                                  ),
                                ),
                                SvgPicture.asset(
                                  isDark
                                      ? 'assets/images/logos/logo_horizontal_blanco.svg'
                                      : 'assets/images/logos/logo_horizontal_color.svg',
                                  width: 270,
                                  fit: BoxFit.contain,
                                  semanticsLabel: 'El Mercadito',
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Lema y valor diferencial con Fade y Slide suave
                          AnimatedBuilder(
                            animation: _controller,
                            builder: (context, child) {
                              return FadeTransition(
                                opacity: _textFadeAnimation,
                                child: SlideTransition(
                                  position: _textSlideAnimation,
                                  child: child,
                                ),
                              );
                            },
                            child: Column(
                              children: [
                                Text(
                                  'Accede a la frescura del campo en un clic',
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        color: secondaryTextColor,
                                        fontSize: 15,
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 18),

                                // Badge de valor diferencial
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: primaryColor.withValues(alpha: isDark ? 0.16 : 0.08),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: primaryColor.withValues(alpha: isDark ? 0.3 : 0.15),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.eco_rounded,
                                        size: 16,
                                        color: primaryColor,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Conexión directa productor - comprador',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Parte inferior: barra de progreso animada y pie de versión
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 24,
                  child: Column(
                    children: [
                      // Barra de progreso estilizada
                      AnimatedBuilder(
                        animation: _progressAnimation,
                        builder: (context, child) {
                          return Container(
                            width: 130,
                            height: 4,
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white12 : Colors.black12,
                              borderRadius: BorderRadius.circular(2),
                            ),
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: _progressAnimation.value.clamp(0.0, 1.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: primaryColor,
                                  borderRadius: BorderRadius.circular(2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primaryColor.withValues(alpha: 0.5),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 14),
                      Text(
                        '© 2026 El Mercadito S.A.',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[600] : Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
