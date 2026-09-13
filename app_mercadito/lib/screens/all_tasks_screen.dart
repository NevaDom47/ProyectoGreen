import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import '../theme/app_theme.dart';

enum AllTaskFilter {
  todas,
  pendientes,
  enCurso,
  porReclamar,
  completadas,
}

enum AllTaskStatus {
  pendiente,
  enProgreso,
  reclamable,
  completado,
}

class _AllTaskModel {
  final String id;
  final String title;
  final String description;
  final int points;
  final IconData icon;
  AllTaskStatus status;
  final List<String> steps;
  final String validationCriteria;
  bool isValidating;

  _AllTaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.points,
    required this.icon,
    required this.status,
    this.steps = const [],
    this.validationCriteria = '',
    this.isValidating = false,
  });
}

class AllTasksScreen extends StatefulWidget {
  const AllTasksScreen({super.key});

  @override
  State<AllTasksScreen> createState() => _AllTasksScreenState();
}

class _AllTasksScreenState extends State<AllTasksScreen> with TickerProviderStateMixin {
  late AnimationController _controller;

  // Gamification state
  int _totalPoints = 1520;
  final int _streakDays = 5;
  AllTaskFilter _selectedFilter = AllTaskFilter.todas;
  late List<_AllTaskModel> _tasks;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _controller.forward();

    _initTasks();
  }

  void _initTasks() {
    _tasks = [
      _AllTaskModel(
        id: '1',
        title: 'Subir 1 Reel de Cosecha',
        description: 'Muestra el proceso de recolección de tus tomates frescos para atraer más clientes locales.',
        points: 50,
        icon: Icons.photo_camera_rounded,
        status: AllTaskStatus.pendiente,
        steps: [
          'Graba un video corto de al menos 10 segundos en tu huerto o almacén.',
          'Muestra el estado fresco de tus hortalizas o frutas cosechadas.',
          'Publica con precio de referencia para que los compradores locales te contacten.',
        ],
        validationCriteria: 'El sistema valida que el reel tenga al menos 10 segundos de duración, audio activo y esté vinculado a un producto de tu catálogo.',
      ),
      _AllTaskModel(
        id: '2',
        title: 'Responder Mensajes Pendientes',
        description: 'Tienes 3 consultas de clientes sobre horarios y disponibilidad de productos orgánicos.',
        points: 20,
        icon: Icons.forum_rounded,
        status: AllTaskStatus.reclamable,
        steps: [
          'Abre la bandeja de entrada de tus mensajes pendientes.',
          'Responde a las 3 preguntas sobre disponibilidad de entrega.',
          'Mantén un tiempo promedio de respuesta menor a 30 minutos.',
        ],
        validationCriteria: 'El sistema comprueba que todos los mensajes de compradores del día hayan recibido respuesta cordial y oportuna.',
      ),
      _AllTaskModel(
        id: '3',
        title: 'Actualizar Precios de Mercado',
        description: 'Revisa y ajusta los precios de temporada según la oferta y demanda del mercado local.',
        points: 30,
        icon: Icons.storefront_rounded,
        status: AllTaskStatus.pendiente,
        steps: [
          'Ingresa a tu catálogo de productos agrícolas activos.',
          'Compara tus precios con el índice de referencia de Mercadito.',
          'Guarda los cambios actualizados para que aparezcan en el Mercado.',
        ],
        validationCriteria: 'El sistema valida que al menos un producto haya actualizado su precio en las últimas 24 horas.',
      ),
      _AllTaskModel(
        id: '4',
        title: 'Inventario Semanal de Bodega',
        description: 'Realiza el conteo físico de insumos cosechados y registra mermas de almacén.',
        points: 40,
        icon: Icons.inventory_2_rounded,
        status: AllTaskStatus.completado,
        steps: [
          'Revisa las existencias físicas en tus bodegas o huerto.',
          'Actualiza los kilogramos disponibles para venta mayorista.',
          'Registra mermas para mantener tus métricas de confiabilidad intactas.',
        ],
        validationCriteria: 'El sistema valida el balance de inventario semanal y confirma disponibilidad de stock.',
      ),
      _AllTaskModel(
        id: '5',
        title: 'Verificar Certificación de Calidad',
        description: 'Sube una fotografía de tu certificado de buenas prácticas agrícolas para obtener la insignia verde.',
        points: 60,
        icon: Icons.verified_rounded,
        status: AllTaskStatus.pendiente,
        steps: [
          'Adjunta el documento o sello oficial de certificación.',
          'Confirma la vigencia y número de folio del certificado.',
          'Envía a revisión para que el equipo valide el sello de calidad.',
        ],
        validationCriteria: 'El sistema verifica la legibilidad y vigencia del documento de certificación emitido.',
      ),
      _AllTaskModel(
        id: '6',
        title: 'Solicitar Reseña a Comprador',
        description: 'Pide una valoración a tu último comprador para sumar reputación a tu perfil.',
        points: 25,
        icon: Icons.star_rate_rounded,
        status: AllTaskStatus.reclamable,
        steps: [
          'Selecciona un acuerdo cerrado recientemente.',
          'Envía un recordatorio amistoso solicitando feedback.',
          'Recibe la puntuación para impulsar tu visibilidad.',
        ],
        validationCriteria: 'El sistema registra que la solicitud se envió dentro de las 48 horas posteriores a la entrega.',
      ),
      _AllTaskModel(
        id: '7',
        title: 'Publicar Oferta Relámpago',
        description: 'Lanza un descuento por lote de excedente de cosecha con duración de 24 horas.',
        points: 35,
        icon: Icons.bolt_rounded,
        status: AllTaskStatus.pendiente,
        steps: [
          'Elige un producto de cosecha con excedente.',
          'Aplica al menos un 10% de descuento sobre el precio base.',
          'Define una ventana de entrega rápida de 24 a 48 horas.',
        ],
        validationCriteria: 'El sistema comprueba que el precio con descuento sea real y el producto tenga stock disponible.',
      ),
    ];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startTaskValidation(_AllTaskModel task) {
    if (task.status == AllTaskStatus.completado || task.status == AllTaskStatus.reclamable) return;

    setState(() {
      task.status = AllTaskStatus.enProgreso;
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
                'Misión activa: ${task.title}. Ejecutando validación...',
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
        task.status = AllTaskStatus.reclamable;
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
                  '¡Misión validada! Reclama tus +${task.points} Pts de prestigio.',
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

  void _claimTaskReward(_AllTaskModel task) {
    if (task.status == AllTaskStatus.completado) return;

    setState(() {
      task.status = AllTaskStatus.completado;
      _totalPoints += task.points;
    });

    _showRewardCelebrationDialog(task);
  }

  void _showRewardCelebrationDialog(_AllTaskModel task) {
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
                  'Tu reputación y prestigio aumentan en tu perfil público de productor.',
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
                      'Continuar',
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

  void _showTaskDetailSheet(_AllTaskModel task, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final isCompleted = task.status == AllTaskStatus.completado;
            final isReclamable = task.status == AllTaskStatus.reclamable;
            final isProgress = task.status == AllTaskStatus.enProgreso;

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
              statusText = task.isValidating ? 'VALIDANDO REQUISITOS...' : 'EN CURSO';
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
                            } else if (task.status == AllTaskStatus.pendiente) {
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

  List<_AllTaskModel> get _filteredTasks {
    switch (_selectedFilter) {
      case AllTaskFilter.pendientes:
        return _tasks.where((t) => t.status == AllTaskStatus.pendiente).toList();
      case AllTaskFilter.enCurso:
        return _tasks.where((t) => t.status == AllTaskStatus.enProgreso).toList();
      case AllTaskFilter.porReclamar:
        return _tasks.where((t) => t.status == AllTaskStatus.reclamable).toList();
      case AllTaskFilter.completadas:
        return _tasks.where((t) => t.status == AllTaskStatus.completado).toList();
      case AllTaskFilter.todas:
      default:
        return _tasks;
    }
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
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                children: [
                  _buildHeader(isDark),
                  const SizedBox(height: 16),
                  _buildDailyProgressCard(isDark),
                  const SizedBox(height: 18),
                  _buildFilterChips(isDark),
                  const SizedBox(height: 16),
                  ..._buildFilteredTaskList(isDark),
                  const SizedBox(height: 24),
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
                        'Todas las Tareas',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          color: isDark ? const Color(0xFF89D6B0) : AppTheme.primary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Catálogo completo de misiones',
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
          // Live points badge
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

  Widget _buildHeader(bool isDark) {
    final onSurface = isDark ? Colors.white : const Color(0xFF141A15);
    final onSurfaceVariant = isDark ? AppTheme.slate400 : const Color(0xFF435245);

    final activeCount = _tasks.where((t) => t.status == AllTaskStatus.enProgreso).length;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Misiones y Prestigio',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Completa misiones para elevar tu nivel y confianza ante la comunidad.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E382E) : const Color(0xFFE5F1EB),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$activeCount activas',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: isDark ? const Color(0xFF89D6B0) : AppTheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDailyProgressCard(bool isDark) {
    final surfaceLowest = isDark ? const Color(0xFF162B23) : Colors.white;
    final outlineVariant = isDark ? const Color(0xFF2E4E41) : const Color(0xFFD0D9CD);
    final onSurface = isDark ? Colors.white : const Color(0xFF141A15);
    final onSurfaceVariant = isDark ? AppTheme.slate400 : const Color(0xFF435245);

    final completedCount = _tasks.where((t) => t.status == AllTaskStatus.completado).length;
    final totalCount = _tasks.length;
    final double progressFraction = totalCount > 0 ? (completedCount / totalCount).clamp(0.0, 1.0) : 0.0;
    final int percent = (progressFraction * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(18),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Progreso de Misiones',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: onSurface,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '$completedCount de $totalCount tareas completadas',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E382E) : const Color(0xFFE5F1EB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? const Color(0xFF2E6348) : const Color(0xFFA7E8C3),
                  ),
                ),
                child: Text(
                  '$percent%',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: isDark ? const Color(0xFF89D6B0) : AppTheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Dual-color progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              children: [
                Container(
                  height: 9,
                  width: double.infinity,
                  color: isDark ? const Color(0xFF1E382E) : const Color(0xFFE5EBE0),
                ),
                FractionallySizedBox(
                  widthFactor: progressFraction,
                  child: Container(
                    height: 9,
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
          const SizedBox(height: 14),
          // Streak Row with Lottie
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                        width: 20,
                        height: 20,
                        child: Lottie.asset(
                          'assets/animations/Racha_fire_1.json',
                          fit: BoxFit.contain,
                          animate: !WidgetsBinding.instance.runtimeType.toString().contains('Test'),
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.local_fire_department_rounded,
                            color: Color(0xFFD97706),
                            size: 16,
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
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Bonificador x1.2 Pts activo',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(bool isDark) {
    final filters = [
      {'filter': AllTaskFilter.todas, 'label': 'Todas', 'count': _tasks.length},
      {
        'filter': AllTaskFilter.pendientes,
        'label': 'Pendientes',
        'count': _tasks.where((t) => t.status == AllTaskStatus.pendiente).length,
      },
      {
        'filter': AllTaskFilter.enCurso,
        'label': 'En Curso',
        'count': _tasks.where((t) => t.status == AllTaskStatus.enProgreso).length,
      },
      {
        'filter': AllTaskFilter.porReclamar,
        'label': 'Por Reclamar',
        'count': _tasks.where((t) => t.status == AllTaskStatus.reclamable).length,
      },
      {
        'filter': AllTaskFilter.completadas,
        'label': 'Completadas',
        'count': _tasks.where((t) => t.status == AllTaskStatus.completado).length,
      },
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: filters.map((item) {
          final filter = item['filter'] as AllTaskFilter;
          final label = item['label'] as String;
          final count = item['count'] as int;
          final isSelected = _selectedFilter == filter;

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedFilter = filter;
                });
                HapticFeedback.selectionClick();
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primary
                      : (isDark ? const Color(0xFF1E382E) : const Color(0xFFF3F6EC)),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primary
                        : (isDark ? const Color(0xFF2E4E41) : const Color(0xFFD0D9CD)),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : (isDark ? AppTheme.slate400 : const Color(0xFF334155)),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.25)
                            : (isDark ? const Color(0xFF162B23) : Colors.white),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$count',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: isSelected
                              ? Colors.white
                              : (isDark ? const Color(0xFF89D6B0) : AppTheme.primary),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  List<Widget> _buildFilteredTaskList(bool isDark) {
    final tasks = _filteredTasks;

    if (tasks.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 40.0),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.task_alt_rounded,
                  size: 48,
                  color: isDark ? AppTheme.slate500 : const Color(0xFF94A3B8),
                ),
                const SizedBox(height: 12),
                Text(
                  'No hay tareas en esta categoría',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF334155),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Selecciona otro filtro para ver más misiones disponibles.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: isDark ? AppTheme.slate400 : AppTheme.slate500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ];
    }

    return tasks.map((task) => Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: _buildTaskCard(task, isDark),
    )).toList();
  }

  Widget _buildTaskCard(_AllTaskModel task, bool isDark) {
    final surfaceLowest = isDark ? const Color(0xFF162B23) : Colors.white;
    final surfaceLow = isDark ? const Color(0xFF1E382E) : const Color(0xFFF3F6EC);
    final outlineVariant = isDark ? const Color(0xFF2E4E41) : const Color(0xFFD0D9CD);
    final onSurface = isDark ? Colors.white : const Color(0xFF141A15);
    final onSurfaceVariant = isDark ? AppTheme.slate400 : const Color(0xFF435245);

    final bool isCompleted = task.status == AllTaskStatus.completado;
    final bool isReclamable = task.status == AllTaskStatus.reclamable;
    final bool isProgress = task.status == AllTaskStatus.enProgreso;

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
                ? const Color(0xFFF59E0B).withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.025),
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
            padding: const EdgeInsets.all(14.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppTheme.primary.withValues(alpha: 0.15)
                        : (isReclamable
                            ? const Color(0xFFFEF3C7)
                            : (isProgress ? const Color(0xFFDBEAFE) : surfaceLow)),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    isCompleted ? Icons.check_circle_rounded : task.icon,
                    color: isCompleted
                        ? AppTheme.primary
                        : (isReclamable
                            ? const Color(0xFFB45309)
                            : (isProgress ? const Color(0xFF1D4ED8) : AppTheme.primary)),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              task.title,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: onSurface,
                                decoration: isCompleted ? TextDecoration.lineThrough : null,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: isCompleted
                                  ? surfaceLow
                                  : (isDark ? const Color(0xFF1E382E) : const Color(0xFFEBF7F0)),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '+${task.points} Pts',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: isCompleted ? onSurfaceVariant : AppTheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        task.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: onSurfaceVariant,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
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
                                Text(
                                  statusText,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w800,
                                    color: badgeText,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Action Button
                          _buildTaskActionButton(task, isDark),
                        ],
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

  Widget _buildTaskActionButton(_AllTaskModel task, bool isDark) {
    final surfaceLow = isDark ? const Color(0xFF1E382E) : const Color(0xFFF3F6EC);
    final onSurfaceVariant = isDark ? AppTheme.slate400 : const Color(0xFF435245);

    if (task.status == AllTaskStatus.completado) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: surfaceLow,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'Listo ✓',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: onSurfaceVariant,
          ),
        ),
      );
    }

    if (task.status == AllTaskStatus.reclamable) {
      return InkWell(
        onTap: () => _claimTaskReward(task),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    if (task.status == AllTaskStatus.enProgreso) {
      return InkWell(
        onTap: () => _showTaskDetailSheet(task, isDark),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                  fontSize: 10,
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppTheme.primary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'Hacer',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
