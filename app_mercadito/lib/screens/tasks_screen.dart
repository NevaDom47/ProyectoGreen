import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../theme/app_theme.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _bgController;
  late AnimationController _pulseController;

  // Gamification State
  int _totalPoints = 1450;
  int _completedTasks = 5;
  final int _totalDailyTasks = 10;
  int _streakDays = 5;

  late List<_TaskModel> _tasks;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    final isTest = WidgetsBinding.instance.runtimeType.toString().contains('Test');
    if (!isTest) {
      _bgController.repeat();
      _pulseController.repeat(reverse: true);
    }

    _initTasks();
  }

  void _initTasks() {
    _tasks = [
      _TaskModel(
        id: '1',
        title: 'Subir 1 Reel de Cosecha',
        description: 'Muestra el proceso de recolección de tus tomates frescos para atraer más clientes locales.',
        points: 50,
        icon: Icons.photo_camera_rounded,
        status: TaskStatus.pendiente,
        steps: [
          'Graba un video corto de al menos 10 segundos en tu huerto o almacén.',
          'Muestra el estado fresco de tus hortalizas o frutas cosechadas.',
          'Publica con precio de referencia para que los compradores locales te contacten.',
        ],
        validationCriteria: 'El sistema valida que el reel tenga al menos 10 segundos de duración, audio activo y esté vinculado a un producto de tu catálogo.',
      ),
      _TaskModel(
        id: '2',
        title: 'Responder Mensajes',
        description: 'Tienes 3 consultas de clientes sobre horarios y disponibilidad inmediata.',
        points: 20,
        icon: Icons.forum_rounded,
        status: TaskStatus.reclamable,
        hasNotification: true,
        steps: [
          'Abre la bandeja de entrada de tus mensajes pendientes.',
          'Responde a las 3 preguntas sobre disponibilidad de entrega.',
          'Mantén un tiempo promedio de respuesta menor a 30 minutos.',
        ],
        validationCriteria: 'El sistema comprueba que todos los mensajes de compradores del día hayan recibido respuesta cordial y oportuna.',
      ),
      _TaskModel(
        id: '3',
        title: 'Actualizar Precios',
        description: 'Revisa y ajusta los precios de temporada según la oferta del mercado local.',
        points: 30,
        icon: Icons.storefront_rounded,
        status: TaskStatus.pendiente,
        steps: [
          'Ingresa a tu catálogo de productos agrícolas activos.',
          'Compara tus precios con el índice de referencia de Mercadito.',
          'Guarda los cambios actualizados para que aparezcan en el Mercado.',
        ],
        validationCriteria: 'El sistema valida que al menos un producto haya actualizado su precio en las últimas 24 horas.',
      ),
      _TaskModel(
        id: '4',
        title: 'Inventario Semanal',
        description: 'Realiza el conteo físico de insumos cosechados y registra mermas de almacén.',
        points: 40,
        icon: Icons.inventory_2_rounded,
        status: TaskStatus.completado,
        steps: [
          'Revisa las existencias físicas en tus bodegas o huerto.',
          'Actualiza los kilogramos disponibles para venta mayorista.',
          'Registra mermas para mantener tus métricas de confiabilidad intactas.',
        ],
        validationCriteria: 'El sistema valida el balance de inventario semanal y confirma disponibilidad de stock.',
      ),
    ];
  }

  @override
  void dispose() {
    _controller.dispose();
    _bgController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _startTaskValidation(_TaskModel task) {
    if (task.status == TaskStatus.completado || task.status == TaskStatus.reclamable) return;

    setState(() {
      task.status = TaskStatus.enProgreso;
      task.isValidating = true;
    });

    HapticFeedback.lightImpact();

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Misión activa: ${task.title}. Ejecutando validaciones automáticas...',
                style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        duration: const Duration(milliseconds: 1800),
        backgroundColor: AppTheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    final isTest = WidgetsBinding.instance.runtimeType.toString().contains('Test');
    final validationDelay = isTest ? Duration.zero : const Duration(milliseconds: 1600);

    Future.delayed(validationDelay, () {
      if (!mounted) return;
      setState(() {
        task.isValidating = false;
        task.status = TaskStatus.reclamable;
      });
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '¡Validación exitosa! Tarea lista para reclamar +${task.points} Pts.',
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFD97706),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    });
  }

  void _claimTaskReward(_TaskModel task) {
    if (task.status == TaskStatus.completado) return;

    setState(() {
      task.status = TaskStatus.completado;
      _totalPoints += task.points;
      if (_completedTasks < _totalDailyTasks) {
        _completedTasks++;
      }
    });

    _showRewardCelebrationDialog(task);
  }

  void _completeTask(_TaskModel task) {
    _claimTaskReward(task);
  }

  void _showRewardCelebrationDialog(_TaskModel task) {
    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.slate800 : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark ? const Color(0xFF2E6348) : const Color(0xFFA7E8C3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.25),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFFBBF24), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFBBF24).withValues(alpha: 0.3),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.military_tech_rounded,
                      color: Color(0xFFB45309),
                      size: 38,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '¡Misión Cumplida!',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppTheme.slate900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  task.title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppTheme.slate400 : AppTheme.slate500,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE3F7EB), Color(0xFFFEF7E5)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFA7E8C3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.stars_rounded, color: Color(0xFFD97706), size: 20),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          '+${task.points} Pts de Prestigio',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Tu reputación y confianza ante otros compradores acaba de aumentar.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: isDark ? AppTheme.slate400 : AppTheme.slate500,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                    ),
                    child: Text(
                      'Continuar Jugando',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _animateItem(Widget child, int index) {
    final double start = (index * 0.08).clamp(0.0, 0.9);
    final double end = (start + 0.2).clamp(0.0, 1.0);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final curve = CurvedAnimation(
          parent: _controller,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        );
        return Opacity(
          opacity: curve.value,
          child: Transform.translate(
            offset: Offset(0, 16 * (1 - curve.value)),
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
    final surfaceColor = isDark ? AppTheme.backgroundDark : const Color(0xFFF9FAF5);

    return Scaffold(
      backgroundColor: surfaceColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopAppBar(isDark),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _animateItem(_buildGamifiedHeroBanner(isDark), 0),
                    const SizedBox(height: 20),
                    _animateItem(_buildDailySummaryRow(isDark), 1),
                    const SizedBox(height: 24),
                    _animateItem(_buildTaskListHeader(isDark), 2),
                    const SizedBox(height: 12),
                    _buildTaskGrid(isDark),
                    const SizedBox(height: 24),
                    _animateItem(_buildTrustProfileCard(isDark), 5),
                    const SizedBox(height: 20),
                    _animateItem(_buildDailyTipCard(isDark), 6),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            const CustomBottomNavBar(currentIndex: -1),
          ],
        ),
      ),
    );
  }

  Widget _buildTopAppBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    } else {
                      try {
                        context.pop();
                      } catch (_) {}
                    }
                  },
                  icon: Icon(
                    Icons.arrow_back,
                    color: isDark ? const Color(0xFF89D6B0) : AppTheme.primary,
                    size: 20,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: isDark ? const Color(0xFF1E382E) : const Color(0xFFE5F1EB),
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(40, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tareas y Prestigio',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          color: isDark ? const Color(0xFF89D6B0) : AppTheme.primary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Gamificación comunitaria',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppTheme.slate400 : AppTheme.slate500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Points Counter Badge in AppBar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E382E) : const Color(0xFFEBF7F0),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? const Color(0xFF2E6348) : const Color(0xFFA7E8C3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.stars_rounded, color: Color(0xFFD97706), size: 16),
                const SizedBox(width: 5),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                  child: Text(
                    '$_totalPoints Pts',
                    key: ValueKey<int>(_totalPoints),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: isDark ? const Color(0xFF89D6B0) : AppTheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGamifiedHeroBanner(bool isDark) {
    // Current level 3 (1000 - 2000 points range)
    final double levelProgress = ((_totalPoints - 1000) / 1000).clamp(0.0, 1.0);

    return AnimatedBuilder(
      animation: _bgController,
      builder: (context, child) {
        final angle = _bgController.value * 2 * pi;
        final alignmentX = cos(angle) * 0.4;
        final alignmentY = sin(angle) * 0.4;

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment(alignmentX - 0.7, alignmentY - 0.7),
              end: Alignment(-alignmentX + 0.7, -alignmentY + 0.7),
              colors: const [
                Color(0xFF014B32),
                Color(0xFF016042),
                Color(0xFF003D27),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withValues(alpha: 0.35),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: child,
        );
      },
      child: Stack(
        children: [
          // Background ambient radial blur
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFA5F3CB).withValues(alpha: 0.22),
                    const Color(0xFFA5F3CB).withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Level & Date
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFA5F3CB).withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.military_tech_rounded, color: Color(0xFFFBBF24), size: 15),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                'NIVEL 3 • PRODUCTOR CONFIABLE',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                  color: const Color(0xFFA5F3CB),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Hoy, 24 Octubre',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Main Points Display
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        '$_totalPoints',
                        key: ValueKey<int>(_totalPoints),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Puntos de Prestigio Acumulados',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFA5F3CB),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // XP Progress Bar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            'Progreso a Nivel 4 (Productor Oro)',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${(_totalPoints - 1000)} / 1,000 XP',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFFBBF24),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Stack(
                        children: [
                          Container(
                            height: 7,
                            width: double.infinity,
                            color: Colors.white.withValues(alpha: 0.15),
                          ),
                          FractionallySizedBox(
                            widthFactor: levelProgress,
                            child: Container(
                              height: 7,
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Color(0xFF34D399), Color(0xFFFBBF24)],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Trust pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.verified_user_rounded, color: Color(0xFF34D399), size: 14),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Sello de Confianza: 98% visible en tu perfil público',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFA5F3CB),
                          ),
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
    );
  }

  Widget _buildDailySummaryRow(bool isDark) {
    final surfaceLowest = isDark ? const Color(0xFF162B23) : Colors.white;
    final surfaceLow = isDark ? const Color(0xFF1E382E) : const Color(0xFFF3F6EC);
    final outlineVariant = isDark ? const Color(0xFF2E4E41) : const Color(0xFFD0D9CD);
    final onSurface = isDark ? Colors.white : const Color(0xFF141A15);
    final onSurfaceVariant = isDark ? AppTheme.slate400 : const Color(0xFF435245);

    final double dailyProgress = (_completedTasks / _totalDailyTasks).clamp(0.0, 1.0);

    return Row(
      children: [
        // Daily Summary Card with Flame Streak
        Expanded(
          flex: 5,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: surfaceLowest,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: outlineVariant.withValues(alpha: 0.6)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Resumen Diario',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Completa tus misiones para mantener tu racha y ganar visibilidad de confianza.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 12),
                // Lottie flame / Animated streak chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF332617) : const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? const Color(0xFF78541D) : const Color(0xFFFDE68A),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 22,
                        height: 22,
                        child: Lottie.asset(
                          'assets/animations/Racha_fire_1.json',
                          fit: BoxFit.contain,
                          animate: !WidgetsBinding.instance.runtimeType.toString().contains('Test'),
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.local_fire_department_rounded,
                            color: Color(0xFFD97706),
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'RACHA: $_streakDays DÍAS',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309),
                            letterSpacing: 0.5,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Progress Sidebar Card (Radial Gauge)
        Expanded(
          flex: 3,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: surfaceLowest,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: outlineVariant.withValues(alpha: 0.6)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 68,
                  height: 68,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: 1.0,
                        strokeWidth: 7,
                        color: surfaceLow,
                      ),
                      CircularProgressIndicator(
                        value: dailyProgress,
                        strokeWidth: 7,
                        color: AppTheme.primary,
                        strokeCap: StrokeCap.round,
                      ),
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: Text(
                                '$_completedTasks',
                                key: ValueKey<int>(_completedTasks),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? const Color(0xFF89D6B0) : AppTheme.primary,
                                  height: 1.0,
                                ),
                              ),
                            ),
                            Text(
                              'DE $_totalDailyTasks',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 8.5,
                                fontWeight: FontWeight.w800,
                                color: onSurfaceVariant,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Hoy',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTaskListHeader(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  'Tareas Pendientes',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF141A15),
                    letterSpacing: -0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E382E) : const Color(0xFFE5F1EB),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${_tasks.where((t) => t.status == TaskStatus.enProgreso).length} activas',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: isDark ? const Color(0xFF89D6B0) : AppTheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        TextButton(
          onPressed: () {
            context.push('/all-tasks');
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Row(
            children: [
              Text(
                'VER TODAS',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: isDark ? const Color(0xFF89D6B0) : AppTheme.primary,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(width: 2),
              Icon(
                Icons.chevron_right_rounded,
                size: 16,
                color: isDark ? const Color(0xFF89D6B0) : AppTheme.primary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTaskGrid(bool isDark) {
    return GridView.builder(
      itemCount: _tasks.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.15,
      ),
      itemBuilder: (context, index) {
        return _animateItem(_buildGamifiedTaskCard(_tasks[index], isDark), index + 2);
      },
    );
  }

  Widget _buildGamifiedTaskCard(_TaskModel task, bool isDark) {
    final surfaceLowest = isDark ? const Color(0xFF162B23) : Colors.white;
    final surfaceLow = isDark ? const Color(0xFF1E382E) : const Color(0xFFF3F6EC);
    final outlineVariant = isDark ? const Color(0xFF2E4E41) : const Color(0xFFD0D9CD);
    final onSurface = isDark ? Colors.white : const Color(0xFF141A15);
    final onSurfaceVariant = isDark ? AppTheme.slate400 : const Color(0xFF435245);

    final bool isCompleted = task.status == TaskStatus.completado;
    final bool isReclamable = task.status == TaskStatus.reclamable;
    final bool isProgress = task.status == TaskStatus.enProgreso;

    Color badgeBg;
    Color badgeText;
    String statusText;

    if (isCompleted) {
      badgeBg = isDark ? const Color(0xFF1E382E) : const Color(0xFFD1FAE5);
      badgeText = isDark ? const Color(0xFF89D6B0) : AppTheme.primary;
      statusText = 'COMPLETADO';
    } else if (isReclamable) {
      badgeBg = isDark ? const Color(0xFF332617) : const Color(0xFFFEF3C7);
      badgeText = isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309);
      statusText = 'LISTA';
    } else if (isProgress) {
      badgeBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFDBEAFE);
      badgeText = isDark ? const Color(0xFF60A5FA) : const Color(0xFF1D4ED8);
      statusText = task.isValidating ? 'VALIDANDO' : 'ACTIVA';
    } else {
      badgeBg = surfaceLow;
      badgeText = onSurfaceVariant;
      statusText = 'PENDIENTE';
    }

    return Container(
      decoration: BoxDecoration(
        color: surfaceLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isCompleted
              ? AppTheme.primary.withValues(alpha: 0.35)
              : (isReclamable
                  ? const Color(0xFFF59E0B)
                  : (isProgress
                      ? const Color(0xFF3B82F6).withValues(alpha: 0.7)
                      : outlineVariant.withValues(alpha: 0.6))),
          width: (isCompleted || isReclamable || isProgress) ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isReclamable
                ? const Color(0xFFF59E0B).withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: () => _showTaskDetailSheet(task, isDark),
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 11.0, vertical: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Icon and Badge Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? AppTheme.primary.withValues(alpha: 0.15)
                                : (isReclamable
                                    ? const Color(0xFFFEF3C7)
                                    : (isProgress ? const Color(0xFFDBEAFE) : surfaceLow)),
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Icon(
                            isCompleted ? Icons.check_circle_rounded : task.icon,
                            color: isCompleted
                                ? AppTheme.primary
                                : (isReclamable
                                    ? const Color(0xFFB45309)
                                    : (isProgress ? const Color(0xFF1D4ED8) : AppTheme.primary)),
                            size: 16,
                          ),
                        ),
                        if (task.hasNotification && !isCompleted)
                          Positioned(
                            top: -2,
                            right: -2,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFFEF4444),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                    // Status Badge
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: badgeBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (task.isValidating) ...[
                              const SizedBox(
                                width: 8,
                                height: 8,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.5,
                                  color: Color(0xFF1D4ED8),
                                ),
                              ),
                              const SizedBox(width: 4),
                            ],
                            Flexible(
                              child: Text(
                                statusText,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w800,
                                  color: badgeText,
                                  letterSpacing: 0.2,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                // Text Column
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: onSurface,
                        decoration: isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      task.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9.5,
                        color: onSurfaceVariant,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
                // Points and Action Button Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Points Pill
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? surfaceLow
                              : (isDark ? const Color(0xFF1E382E) : const Color(0xFFEBF7F0)),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '+${task.points} Pts',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: isCompleted ? onSurfaceVariant : AppTheme.primary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    // Action Button
                    _buildTaskActionButton(task, isDark),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskActionButton(_TaskModel task, bool isDark) {
    final surfaceLow = isDark ? const Color(0xFF1E382E) : const Color(0xFFF3F6EC);
    final onSurfaceVariant = isDark ? AppTheme.slate400 : const Color(0xFF435245);

    if (task.status == TaskStatus.completado) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
        decoration: BoxDecoration(
          color: surfaceLow,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'Listo ✓',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 9.5,
            fontWeight: FontWeight.w800,
            color: onSurfaceVariant,
          ),
        ),
      );
    }

    if (task.status == TaskStatus.reclamable) {
      return InkWell(
        onTap: () => _claimTaskReward(task),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            'Reclamar',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    if (task.status == TaskStatus.enProgreso) {
      return InkWell(
        onTap: () => _showTaskDetailSheet(task, isDark),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
          decoration: BoxDecoration(
            color: const Color(0xFF2563EB),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (task.isValidating) ...[
                const SizedBox(
                  width: 9,
                  height: 9,
                  child: CircularProgressIndicator(strokeWidth: 1.5, color: Colors.white),
                ),
                const SizedBox(width: 4),
              ],
              Text(
                task.isValidating ? 'Validando' : 'En curso',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Pendiente -> Hacer
    return InkWell(
      onTap: () => _startTaskValidation(task),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.primary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'Hacer',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 9.5,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _showTaskDetailSheet(_TaskModel task, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final isCompleted = task.status == TaskStatus.completado;
            final isReclamable = task.status == TaskStatus.reclamable;
            final isProgress = task.status == TaskStatus.enProgreso;

            final surfaceColor = isDark ? const Color(0xFF162B23) : Colors.white;
            final containerColor = isDark ? const Color(0xFF1E382E) : const Color(0xFFF3F6EC);
            final outlineColor = isDark ? const Color(0xFF2E4E41) : const Color(0xFFD0D9CD);
            final textColor = isDark ? Colors.white : const Color(0xFF141A15);
            final subtextColor = isDark ? AppTheme.slate400 : const Color(0xFF435245);

            Color badgeBg;
            Color badgeText;
            String statusText;

            if (isCompleted) {
              badgeBg = isDark ? const Color(0xFF1E382E) : const Color(0xFFD1FAE5);
              badgeText = isDark ? const Color(0xFF89D6B0) : AppTheme.primary;
              statusText = 'COMPLETADO';
            } else if (isReclamable) {
              badgeBg = isDark ? const Color(0xFF332617) : const Color(0xFFFEF3C7);
              badgeText = isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309);
              statusText = 'LISTA PARA RECLAMAR';
            } else if (isProgress) {
              badgeBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFDBEAFE);
              badgeText = isDark ? const Color(0xFF60A5FA) : const Color(0xFF1D4ED8);
              statusText = task.isValidating ? 'VALIDANDO REQUISITOS...' : 'EN PROGRESO';
            } else {
              badgeBg = containerColor;
              badgeText = subtextColor;
              statusText = 'PENDIENTE';
            }

            return Container(
              margin: EdgeInsets.only(
                bottom: MediaQuery.of(sheetCtx).viewInsets.bottom,
              ),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Handle
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: outlineColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Header Row
                      Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: isCompleted
                                  ? AppTheme.primary.withValues(alpha: 0.15)
                                  : (isReclamable
                                      ? const Color(0xFFFEF3C7)
                                      : (isProgress ? const Color(0xFFDBEAFE) : containerColor)),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isReclamable
                                    ? const Color(0xFFFBBF24)
                                    : (isCompleted ? AppTheme.primary.withValues(alpha: 0.3) : outlineColor),
                              ),
                            ),
                            child: Icon(
                              isCompleted ? Icons.check_circle_rounded : task.icon,
                              color: isCompleted
                                  ? AppTheme.primary
                                  : (isReclamable
                                      ? const Color(0xFFB45309)
                                      : (isProgress ? const Color(0xFF1D4ED8) : AppTheme.primary)),
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  task.title,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                                      decoration: BoxDecoration(
                                        color: badgeBg,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        statusText,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800,
                                          color: badgeText,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                                      decoration: BoxDecoration(
                                        color: isDark ? const Color(0xFF1E382E) : const Color(0xFFEBF7F0),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        '+${task.points} Pts Prestigio',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w800,
                                          color: AppTheme.primary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Full Description
                      Text(
                        'Descripción de la Tarea',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        task.description,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          color: subtextColor,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Steps checklist
                      if (task.steps.isNotEmpty) ...[
                        Text(
                          'Pasos para Completar',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...task.steps.asMap().entries.map((entry) {
                          final stepNum = entry.key + 1;
                          final stepText = entry.value;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: isCompleted
                                        ? AppTheme.primary
                                        : (isReclamable
                                            ? const Color(0xFFD97706)
                                            : (isProgress ? const Color(0xFF2563EB) : outlineColor)),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: isCompleted
                                        ? const Icon(Icons.check, size: 12, color: Colors.white)
                                        : Text(
                                            '$stepNum',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.white,
                                            ),
                                          ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    stepText,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      color: textColor,
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                        const SizedBox(height: 8),
                      ],
                      // System Validation Box
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1F2F27) : const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isDark ? const Color(0xFF2E6348) : const Color(0xFFBBF7D0),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.verified_user_rounded, color: Color(0xFF16A34A), size: 18),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Validación Automática del Sistema',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: isDark ? const Color(0xFF86EFAC) : const Color(0xFF15803D),
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    task.validationCriteria.isNotEmpty
                                        ? task.validationCriteria
                                        : 'El sistema valida tu actividad para asegurar la reputación y confianza en tu perfil.',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      color: isDark ? AppTheme.slate400 : const Color(0xFF166534),
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Action Button in Modal
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (isCompleted) {
                              Navigator.of(sheetCtx).pop();
                            } else if (isReclamable) {
                              Navigator.of(sheetCtx).pop();
                              _claimTaskReward(task);
                            } else if (isProgress && task.isValidating) {
                              // Currently validating
                            } else if (task.status == TaskStatus.pendiente) {
                              Navigator.of(sheetCtx).pop();
                              _startTaskValidation(task);
                            } else {
                              Navigator.of(sheetCtx).pop();
                              _startTaskValidation(task);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isCompleted
                                ? outlineColor
                                : (isReclamable
                                    ? const Color(0xFFD97706)
                                    : (isProgress ? const Color(0xFF2563EB) : AppTheme.primary)),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: (isCompleted || (isProgress && task.isValidating)) ? 0 : 2,
                          ),
                          child: (isProgress && task.isValidating)
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Validando Misión...',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                )
                              : Text(
                                  isCompleted
                                      ? 'Misión Completada ✓'
                                      : (isReclamable
                                          ? 'Reclamar +${task.points} Pts de Prestigio'
                                          : (isProgress ? 'Validando Requisitos...' : 'Hacer Misión (Iniciar Validación)')),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Profile Trust and Prestige explanation card
  Widget _buildTrustProfileCard(bool isDark) {
    final surfaceLowest = isDark ? const Color(0xFF162B23) : Colors.white;
    final outlineVariant = isDark ? const Color(0xFF2E6348) : const Color(0xFFD0D9CD);
    final onSurface = isDark ? Colors.white : const Color(0xFF141A15);
    final onSurfaceVariant = isDark ? AppTheme.slate400 : const Color(0xFF435245);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: outlineVariant.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF332918) : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFBBF24)),
                ),
                child: const Icon(
                  Icons.shield_rounded,
                  color: Color(0xFFD97706),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tu Confianza y Prestigio en Perfil',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: onSurface,
                      ),
                    ),
                    Text(
                      'Visible para toda la comunidad de compradores',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E382E) : const Color(0xFFF3F6EC),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.verified_rounded,
                  color: Color(0xFF10B981),
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Cada tarea suma puntos que certifican tu cuenta. Los perfiles con racha activa reciben hasta 3x más solicitudes de acuerdos.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      color: onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyTipCard(bool isDark) {
    final surfaceLow = isDark ? const Color(0xFF1E382E) : const Color(0xFFF3F6EC);
    final outlineVariant = isDark ? const Color(0xFF2E6348) : const Color(0xFFD0D9CD);
    final onSurface = isDark ? Colors.white : const Color(0xFF141A15);
    final onSurfaceVariant = isDark ? AppTheme.slate400 : const Color(0xFF435245);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF162B23) : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: outlineVariant.withValues(alpha: 0.6)),
            ),
            child: const Icon(Icons.lightbulb_rounded, color: Color(0xFFD97706), size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Consejo de la Comunidad',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: onSurface,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Las fotos de cosecha tomadas con luz natural matutina aumentan el cierre de acuerdos en un 30%.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    color: onSurfaceVariant,
                    height: 1.3,
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

enum TaskStatus {
  pendiente,
  enProgreso,
  reclamable,
  completado,
}

class _TaskModel {
  final String id;
  final String title;
  final String description;
  final int points;
  final IconData icon;
  TaskStatus status;
  final bool hasNotification;
  final List<String> steps;
  final String validationCriteria;
  bool isValidating;

  _TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.points,
    required this.icon,
    required this.status,
    this.hasNotification = false,
    this.steps = const [],
    this.validationCriteria = '',
    this.isValidating = false,
  });
}
