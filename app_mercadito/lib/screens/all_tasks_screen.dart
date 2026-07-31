import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

class AllTasksScreen extends StatefulWidget {
  const AllTasksScreen({super.key});

  @override
  State<AllTasksScreen> createState() => _AllTasksScreenState();
}

class _AllTasksScreenState extends State<AllTasksScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _progressController;

  // Theme colors
  final Color primaryColor = const Color(0xFF00462f);
  final Color primaryContainerColor = const Color(0xFF036042);
  final Color secondaryContainerColor = const Color(0xFFcaead7);
  final Color tertiaryColor = const Color(0xFF682826);
  final Color tertiaryContainerColor = const Color(0xFF853e3b);
  final Color outlineColor = const Color(0xFF6f7a73);
  final Color outlineVariantColor = const Color(0xFFbec9c1);
  final Color surfaceContainerLowestColor = const Color(0xFFffffff);
  final Color surfaceContainerHighColor = const Color(0xFFe6e9e4);
  final Color onSurfaceColor = const Color(0xFF181d1a);
  final Color onSurfaceVariantColor = const Color(0xFF3f4943);
  final Color secondaryColor = const Color(0xFF486456);
  final Color backgroundColor = const Color(0xFFf7faf5);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _controller.forward();

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // Esperar 2 segundos antes de empezar la animación de carga
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _progressController.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _progressController.dispose();
    super.dispose();
  }

  Widget _animateItem(Widget child, int index) {
    final double start = (index * 0.1).clamp(0.0, 0.9);
    final double end = (start + 0.2).clamp(0.0, 1.0);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final curve = CurvedAnimation(
          parent: _controller,
          curve: Interval(start, end, curve: Curves.easeOutBack),
        );
        return Opacity(
          opacity: CurvedAnimation(parent: _controller, curve: Interval(start, end, curve: Curves.easeIn)).value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - curve.value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF181d1a) : backgroundColor;
    final onBg = isDark ? Colors.white : onSurfaceColor;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            _animateItem(_buildTopAppBar(isDark), 0),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  _animateItem(_buildHeader(onBg), 1),
                  const SizedBox(height: 24),
                  _animateItem(_buildProgressCard(), 2),
                  const SizedBox(height: 24),
                  ..._buildTasksList(isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopAppBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      color: isDark ? const Color(0xFF1f2937) : surfaceContainerLowestColor,
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: Icon(Icons.arrow_back, color: isDark ? const Color(0xFF89d6b0) : primaryColor),
            style: IconButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(40, 40),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Tareas',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: isDark ? const Color(0xFF89d6b0) : primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(Color onBg) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tareas Pendientes',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: onBg,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Completa tus tareas para mejorar tu puesto.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: onSurfaceVariantColor,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceContainerLowestColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: outlineVariantColor.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: AnimatedBuilder(
        animation: _progressController,
        builder: (context, child) {
          final curve = CurvedAnimation(
            parent: _progressController,
            curve: Curves.easeOutCubic,
          );
          final progress = curve.value * 0.6; // Target is 60%

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Progreso Diario',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '6 de 10 tareas completadas',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: onSurfaceVariantColor,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: primaryContainerColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  height: 12,
                  color: surfaceContainerHighColor,
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress,
                    child: Container(
                      decoration: BoxDecoration(
                        color: primaryContainerColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Mantén la racha para ganar más confianza para tus compradores.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: secondaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Lottie.asset(
                    'assets/animations/Racha_fire_1.json',
                    width: 28,
                    height: 28,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildTasksList(bool isDark) {
    return [
      _animateItem(_buildAllTaskCard(
        title: 'Subir 1 Reel de Cosecha',
        description: 'Muestra el proceso de recolección de tus tomates frescos para atraer más clientes locales.',
        points: '+50 PTS',
        status: 'Pendiente',
        icon: Icons.photo_camera_outlined,
        isDark: isDark,
      ), 3),
      const SizedBox(height: 16),
      _animateItem(_buildAllTaskCard(
        title: 'Responder Mensajes Pendientes',
        description: 'Tienes 3 consultas de clientes sobre horarios de entrega y disponibilidad de productos orgánicos.',
        points: '+20 PTS',
        status: 'En Progreso',
        icon: Icons.forum_outlined,
        isDark: isDark,
        isInProgress: true,
      ), 4),
      const SizedBox(height: 16),
      _animateItem(_buildAllTaskCard(
        title: 'Actualizar Precios de Mercado',
        description: 'Revisa y ajusta los precios de temporada para el aguacate y el limón según el mercado local.',
        points: '+30 PTS',
        status: 'Pendiente',
        icon: Icons.storefront_outlined,
        isDark: isDark,
      ), 5),
      const SizedBox(height: 16),
      _animateItem(_buildAllTaskCard(
        title: 'Inventario Semanal',
        description: 'Realiza el conteo físico de insumos agrícolas y registra mermas.',
        points: '+100 PTS',
        status: 'Completado',
        icon: Icons.inventory_2_outlined,
        isDark: isDark,
        isCompleted: true,
      ), 6),
    ];
  }

  Widget _buildAllTaskCard({
    required String title,
    required String description,
    required String points,
    required String status,
    required IconData icon,
    required bool isDark,
    bool isInProgress = false,
    bool isCompleted = false,
  }) {
    final cardBg = isDark ? const Color(0xFF1f2937) : surfaceContainerLowestColor;
    final onCardBg = isDark ? Colors.white : onSurfaceColor;

    Color iconBgColor;
    Color iconColor;

    if (isInProgress) {
      iconBgColor = tertiaryContainerColor.withValues(alpha: 0.1);
      iconColor = tertiaryContainerColor;
    } else if (isCompleted) {
      iconBgColor = surfaceContainerHighColor;
      iconColor = outlineColor;
    } else {
      iconBgColor = secondaryContainerColor;
      iconColor = primaryColor;
    }

    return Opacity(
      opacity: isCompleted ? 0.6 : 1.0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: outlineVariantColor.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            if (isInProgress)
              Positioned(
                left: -16,
                top: -16,
                bottom: -16,
                width: 4,
                child: Container(color: tertiaryColor),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: onCardBg,
                                decoration: isCompleted ? TextDecoration.lineThrough : null,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isCompleted ? Colors.transparent : primaryContainerColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              points,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: isCompleted ? outlineColor : primaryContainerColor,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: onSurfaceVariantColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isInProgress ? tertiaryColor.withValues(alpha: 0.3) : outlineColor.withValues(alpha: 0.3),
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isInProgress) ...[
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: tertiaryColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                ],
                                Text(
                                  status.toUpperCase(),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    color: isInProgress ? tertiaryColor : outlineColor,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!isCompleted)
                            InkWell(
                              onTap: () {},
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isInProgress ? surfaceContainerHighColor : primaryContainerColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  isInProgress ? 'CONTINUAR' : 'EMPEZAR',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: isInProgress ? onSurfaceColor : Colors.white,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ),
                            ),
                          if (isCompleted)
                            Icon(Icons.check_circle, color: outlineColor, size: 20),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
