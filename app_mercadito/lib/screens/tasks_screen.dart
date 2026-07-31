import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import '../widgets/custom_bottom_nav_bar.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _bgController;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _controller.forward();

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    _bgController.dispose();
    super.dispose();
  }

  Widget _animateItem(Widget child, int index) {
    final double start = (index * 0.1).clamp(0.0, 0.9);
    final double end = (start + 0.15).clamp(0.0, 1.0);
    
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final curve = CurvedAnimation(
          parent: _controller,
          curve: Interval(start, end, curve: Curves.easeOutBack),
        );
        return Opacity(
          opacity: CurvedAnimation(parent: _controller, curve: Interval(start, end, curve: Curves.easeIn)).value,
          child: Transform.scale(
            scale: curve.value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
  // Theme colors
  final Color primaryColor = const Color(0xFF00462f);
  final Color primaryContainerColor = const Color(0xFF036042);
  final Color onPrimaryContainerColor = const Color(0xFF8bd8b2);
  
  final Color secondaryColor = const Color(0xFF486456);
  final Color secondaryContainerColor = const Color(0xFFcaead7);
  final Color onSecondaryContainerColor = const Color(0xFF4e6b5b);

  final Color tertiaryColor = const Color(0xFF682826);
  final Color tertiaryContainerColor = const Color(0xFF853e3b);

  final Color surfaceContainerLowestColor = const Color(0xFFffffff);
  final Color surfaceContainerLowColor = const Color(0xFFf1f4f0);
  final Color surfaceContainerHighColor = const Color(0xFFe6e9e4);
  
  final Color outlineVariantColor = const Color(0xFFbec9c1);
  final Color onSurfaceVariantColor = const Color(0xFF3f4943);
  final Color onBackgroundColor = const Color(0xFF181d1a);
  final Color errorColor = const Color(0xFFba1a1a);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF111827) : const Color(0xFFf7faf5),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopAppBar(isDark),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _animateItem(_buildHeroBanner(), 0),
                    const SizedBox(height: 24),
                    _animateItem(_buildDailySummary(), 1),
                    const SizedBox(height: 24),
                    _animateItem(_buildTaskListHeader(), 2),
                    const SizedBox(height: 12),
                    _buildTaskGrid(isDark),
                    const SizedBox(height: 32),
                    _animateItem(_buildPromoCard(), 7),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            // Reusing existing CustomBottomNavBar and treating this as a new root section (or part of existing)
            // The HTML calls for Tasks index. Let's pass a dummy index like 5 for now since the nav bar has 5 items.
            // Or just reuse an existing index if the user meant to replace it. We will use an index that doesn't highlight if we just want it neutral.
            const CustomBottomNavBar(currentIndex: -1), 
          ],
        ),
      ),
    );
  }

  Widget _buildTopAppBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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

  Widget _buildHeroBanner() {
    return AnimatedBuilder(
      animation: _bgController,
      builder: (context, child) {
        // Animating the alignment in a continuous circle for a smooth "water lamp" effect
        final angle = _bgController.value * 2 * pi;
        final alignmentX = cos(angle);
        final alignmentY = sin(angle);
        
        return Container(
          width: double.infinity,
          height: 140,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment(alignmentX, alignmentY),
              end: Alignment(-alignmentX, -alignmentY),
              colors: [primaryColor, primaryContainerColor],
            ),
            boxShadow: [
              BoxShadow(
                color: primaryContainerColor.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: child,
        );
      },
      child: Stack(
        children: [
          // Decorative circle pattern
          Positioned(
            right: -48,
            bottom: -48,
            child: Container(
              width: 192,
              height: 192,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFa5f3cb).withValues(alpha: 0.2),
                    const Color(0xFFa5f3cb).withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          // Text Content
          Positioned(
            bottom: 16,
            left: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tareas Diarias',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Martes, 24 de Octubre',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: const Color(0xFFa5f3cb), // primary-fixed
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailySummary() {
    return Row(
      children: [
        // Daily Summary Text Card
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: surfaceContainerLowestColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: outlineVariantColor.withValues(alpha: 0.2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                // Decorative blur circle
                Positioned(
                  right: -40,
                  top: -40,
                  child: Container(
                    width: 128,
                    height: 128,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: secondaryContainerColor.withValues(alpha: 0.5),
                    ),
                    // Adding a blur effect in Flutter is tricky on containers directly,
                    // typically we use ImageFilter.blur in a BackdropFilter, but for a solid circle:
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Resumen Diario',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: onBackgroundColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Vas por buen camino. Completa tus tareas para mejorar tu visibilidad.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: onSurfaceVariantColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: primaryContainerColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Lottie.asset(
                            'assets/animations/Racha_fire_1.json',
                            width: 24,
                            height: 24,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'RACHA: 5 DÍAS',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Progress Sidebar Card
        Container(
          width: 104,
          height: 140, // Match height of left card roughly
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: surfaceContainerLowestColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: outlineVariantColor.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 64,
                height: 64,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: 1.0,
                      strokeWidth: 8,
                      color: surfaceContainerHighColor,
                    ),
                    CircularProgressIndicator(
                      value: 0.5, // 5 out of 10
                      strokeWidth: 8,
                      color: primaryColor,
                      strokeCap: StrokeCap.round,
                    ),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '5',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: primaryColor,
                              height: 1.0,
                            ),
                          ),
                          Text(
                            'DE 10',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: onSurfaceVariantColor,
                              letterSpacing: 1.0,
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
      ],
    );
  }

  Widget _buildTaskListHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Tareas Pendientes',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: onBackgroundColor,
          ),
        ),
        TextButton(
          onPressed: () {
            context.push('/all-tasks');
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'VER TODAS',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: primaryColor,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTaskGrid(bool isDark) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.25,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _animateItem(_buildTaskCard(
          status: 'PENDIENTE',
          title: 'Subir 1 Reel de Cosecha',
          description: 'Muestra el proceso de recolección de tus tomates frescos para atraer más clientes locales.',
          points: '+50 Pts',
          icon: Icons.photo_camera_outlined,
          statusColorType: TaskStatusColor.gray,
          isDark: isDark,
        ), 3),
        _animateItem(_buildTaskCard(
          status: 'EN PROGRESO',
          title: 'Responder Mensajes',
          description: 'Tienes 3 consultas de clientes sobre horarios y disponibilidad.',
          points: '+20 Pts',
          icon: Icons.forum_outlined,
          statusColorType: TaskStatusColor.orange,
          isDark: isDark,
          showBadge: true,
        ), 4),
        _animateItem(_buildTaskCard(
          status: 'PENDIENTE',
          title: 'Actualizar Precios',
          description: 'Revisa y ajusta los precios de temporada según el mercado local.',
          points: '+30 Pts',
          icon: Icons.storefront_outlined,
          statusColorType: TaskStatusColor.gray,
          isDark: isDark,
        ), 5),
        _animateItem(_buildTaskCard(
          status: 'COMPLETADO',
          title: 'Inventario Semanal',
          description: 'Realiza el conteo físico de insumos y registra mermas.',
          points: '',
          icon: Icons.inventory_2_outlined,
          statusColorType: TaskStatusColor.green,
          isDark: isDark,
          isCompleted: true,
        ), 6),
      ],
    );
  }

  Widget _buildTaskCard({
    required String status,
    required String title,
    required String description,
    required String points,
    required IconData icon,
    required TaskStatusColor statusColorType,
    required bool isDark,
    bool isCompleted = false,
    bool showBadge = false,
  }) {
    Color getTopBarColor() {
      switch (statusColorType) {
        case TaskStatusColor.gray: return secondaryColor.withValues(alpha: 0.2);
        case TaskStatusColor.green: return primaryColor;
        case TaskStatusColor.red: return tertiaryContainerColor.withValues(alpha: 0.2);
        case TaskStatusColor.orange: return secondaryColor;
      }
    }

    Color getIconBgColor() {
      switch (statusColorType) {
        case TaskStatusColor.gray: return secondaryContainerColor.withValues(alpha: 0.4);
        case TaskStatusColor.green: return primaryColor.withValues(alpha: 0.2);
        case TaskStatusColor.red: return tertiaryContainerColor.withValues(alpha: 0.3);
        case TaskStatusColor.orange: return secondaryContainerColor.withValues(alpha: 0.5);
      }
    }

    Color getIconColor() {
      switch (statusColorType) {
        case TaskStatusColor.gray: return secondaryColor;
        case TaskStatusColor.green: return primaryColor;
        case TaskStatusColor.red: return tertiaryColor;
        case TaskStatusColor.orange: return secondaryColor;
      }
    }

    Color getBadgeBgColor() {
      switch (statusColorType) {
        case TaskStatusColor.gray: return surfaceContainerHighColor;
        case TaskStatusColor.green: return primaryContainerColor;
        case TaskStatusColor.red: return surfaceContainerHighColor;
        case TaskStatusColor.orange: return secondaryContainerColor;
      }
    }

    Color getBadgeTextColor() {
      switch (statusColorType) {
        case TaskStatusColor.gray: return onSurfaceVariantColor;
        case TaskStatusColor.green: return onPrimaryContainerColor;
        case TaskStatusColor.red: return onSurfaceVariantColor;
        case TaskStatusColor.orange: return onSecondaryContainerColor;
      }
    }

    final topBarColor = getTopBarColor();
    final iconBgColor = getIconBgColor();
    final iconColor = getIconColor();
    final badgeBgColor = getBadgeBgColor();
    final badgeTextColor = getBadgeTextColor();
    
    final borderColor = isCompleted ? primaryColor.withValues(alpha: 0.2) : outlineVariantColor.withValues(alpha: 0.1);
    final cardBgColor = isCompleted ? surfaceContainerLowColor : surfaceContainerLowestColor;

    return Container(
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColorType == TaskStatusColor.orange ? secondaryColor.withValues(alpha: 0.3) : borderColor,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Top bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 4,
            child: Container(color: topBarColor),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row (Icon + Badge)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: iconBgColor,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
                          ),
                          child: Icon(icon, color: iconColor, size: 16),
                        ),
                        if (showBadge)
                          Positioned(
                            top: -2,
                            right: -2,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: errorColor,
                                shape: BoxShape.circle,
                                border: Border.all(color: surfaceContainerLowestColor, width: 2),
                              ),
                            ),
                          ),
                      ],
                    ),
                    // Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: badgeBgColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        status,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: badgeTextColor,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Title & Description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: onBackgroundColor,
                          decoration: isCompleted ? TextDecoration.lineThrough : null,
                          decorationColor: outlineVariantColor.withValues(alpha: 0.5),
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: isCompleted ? outlineVariantColor : onSurfaceVariantColor,
                        ),
                      ),
                    ],
                  ),
                ),
                // Bottom row (Points or Check icon)
                Row(
                  mainAxisAlignment: isCompleted ? MainAxisAlignment.end : MainAxisAlignment.spaceBetween,
                  children: [
                    if (!isCompleted)
                      Text(
                        points,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    if (isCompleted)
                      Icon(Icons.check_circle, color: primaryColor, size: 16),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            surfaceContainerLowColor,
            const Color(0xFFebefea), // surface-container
          ],
        ),
        border: Border.all(color: outlineVariantColor.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(color: surfaceContainerLowestColor, width: 2),
            ),
            child: Icon(Icons.lightbulb_outline, color: primaryColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Consejo del Día',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: onBackgroundColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Las fotos con luz natural aumentan las ventas en un 30%. ¡Inténtalo hoy!',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: onSurfaceVariantColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum TaskStatusColor {
  gray,
  green,
  red,
  orange,
}
