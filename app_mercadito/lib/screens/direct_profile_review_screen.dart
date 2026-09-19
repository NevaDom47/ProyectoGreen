import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/reviews_service.dart';
import '../services/user_session.dart';

class DirectProfileReviewScreen extends StatefulWidget {
  final String targetId;
  final String targetName;
  final String targetRole; // 'proveedor' o 'comprador'
  final String? targetAvatar;

  const DirectProfileReviewScreen({
    super.key,
    required this.targetId,
    required this.targetName,
    required this.targetRole,
    this.targetAvatar,
  });

  @override
  State<DirectProfileReviewScreen> createState() => _DirectProfileReviewScreenState();
}

class _DirectProfileReviewScreenState extends State<DirectProfileReviewScreen> {
  final TextEditingController _commentController = TextEditingController();
  final Map<String, double> _scores = {};
  bool _isSubmitting = false;

  bool get _isRatingProvider => widget.targetRole.toLowerCase() == 'proveedor';

  List<Map<String, dynamic>> get _criteria {
    if (_isRatingProvider) {
      return [
        {'key': 'Recomendación', 'min': 0, 'max': 5, 'default': 5.0, 'icon': Icons.thumb_up_outlined},
        {'key': 'Calidad del servicio', 'min': 1, 'max': 5, 'default': 5.0, 'icon': Icons.verified_outlined},
        {'key': 'Puntualidad', 'min': 1, 'max': 5, 'default': 5.0, 'icon': Icons.schedule_outlined},
        {'key': 'Comunicación', 'min': 1, 'max': 5, 'default': 5.0, 'icon': Icons.chat_bubble_outline},
        {'key': 'Cumplimiento', 'min': 0, 'max': 5, 'default': 5.0, 'icon': Icons.task_alt_outlined},
        {'key': 'Confiabilidad', 'min': 0, 'max': 5, 'default': 5.0, 'icon': Icons.shield_outlined},
        {'key': 'Correspondencia con lo ofrecido', 'min': 1, 'max': 5, 'default': 5.0, 'icon': Icons.fact_check_outlined},
      ];
    } else {
      return [
        {'key': 'Comunicación', 'min': 1, 'max': 5, 'default': 5.0, 'icon': Icons.chat_bubble_outline},
        {'key': 'Puntualidad', 'min': 1, 'max': 5, 'default': 5.0, 'icon': Icons.schedule_outlined},
        {'key': 'Cumplimiento del acuerdo', 'min': 0, 'max': 5, 'default': 5.0, 'icon': Icons.handshake_outlined},
        {'key': 'Cumplimiento de pago', 'min': 0, 'max': 5, 'default': 5.0, 'icon': Icons.payments_outlined},
        {'key': 'Seriedad en la compra', 'min': 1, 'max': 5, 'default': 5.0, 'icon': Icons.verified_user_outlined},
        {'key': 'Comportamiento general', 'min': 1, 'max': 5, 'default': 5.0, 'icon': Icons.sentiment_satisfied_alt_outlined},
      ];
    }
  }

  @override
  void initState() {
    super.initState();
    for (var c in _criteria) {
      _scores[c['key'] as String] = (c['default'] as num).toDouble();
    }
    final authorRole = widget.targetRole == 'comprador' ? 'proveedor' : 'comprador';
    final authorId = authorRole == 'comprador' ? 'BUY-88291' : 'PROV-1';
    final reviews = ReviewsService.instance.getDirectReviewsForTarget(widget.targetId);
    final existing = reviews.where((r) => r.authorId == authorId).firstOrNull;
    if (existing != null) {
      _commentController.text = existing.comment;
      for (var entry in existing.scores.entries) {
        if (_scores.containsKey(entry.key)) {
          _scores[entry.key] = entry.value;
        }
      }
    }
    _commentController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  double get _currentAverage {
    if (_scores.isEmpty) return 5.0;
    double sum = 0;
    _scores.forEach((key, val) => sum += val);
    return double.parse((sum / _scores.length).toStringAsFixed(1));
  }

  bool get _isCommentValid {
    final len = _commentController.text.trim().length;
    return len >= 10 && len <= 100;
  }

  void _handleSubmit() async {
    if (!_isCommentValid || _isSubmitting) return;

    setState(() => _isSubmitting = true);

    final authorRole = widget.targetRole == 'comprador' ? 'proveedor' : 'comprador';
    final authorName = (authorRole == 'comprador')
        ? (UserSession.fullName ?? 'Juan Pérez')
        : (UserSession.fullName ?? 'Agro Negocios');
    final authorId = authorRole == 'comprador' ? 'BUY-88291' : 'PROV-1';

    final success = ReviewsService.instance.submitDirectReview(
      authorId: authorId,
      authorName: authorName,
      authorRole: authorRole,
      authorAvatar: UserSession.profilePictureUrl,
      targetId: widget.targetId,
      targetName: widget.targetName,
      targetRole: widget.targetRole,
      comment: _commentController.text.trim(),
      scores: _scores,
      allowUpdate: true,
    );

    setState(() => _isSubmitting = false);

    if (success) {
      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Color(0xFF016042)),
              SizedBox(width: 8),
              Flexible(child: Text('¡Reseña Publicada!')),
            ],
          ),
          content: Text(
            'Tu evaluación para ${widget.targetName} ha sido registrada exitosamente en su perfil reputacional.',
            style: GoogleFonts.plusJakartaSans(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pop(true);
              },
              child: const Text('Entendido'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Text(
            'No se pudo publicar la reseña. Verifica los requisitos.',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight;
    final surfaceColor = isDark ? AppTheme.slate800 : Colors.white;
    final onSurfaceColor = isDark ? AppTheme.slate100 : AppTheme.slate900;
    final secondaryTextColor = isDark ? AppTheme.slate400 : AppTheme.slate500;
    final borderColor = isDark ? AppTheme.slate700 : AppTheme.slate200;

    final commentLength = _commentController.text.trim().length;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: surfaceColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Center(
            child: InkWell(
              onTap: () => Navigator.of(context).pop(),
              borderRadius: BorderRadius.circular(999),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? AppTheme.slate900 : const Color(0xFFF1F4F0),
                ),
                child: Icon(
                  Icons.arrow_back,
                  color: isDark ? AppTheme.slate200 : AppTheme.primary,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
        title: Text(
          _isRatingProvider ? 'Calificar Proveedor' : 'Calificar Comprador',
          style: GoogleFonts.plusJakartaSans(
            color: onSurfaceColor,
            fontWeight: FontWeight.w700,
            fontSize: 18,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: borderColor, height: 1),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Target Info Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: isDark ? AppTheme.slate700 : AppTheme.slate200,
                      backgroundImage: (widget.targetAvatar != null && widget.targetAvatar!.isNotEmpty)
                          ? NetworkImage(widget.targetAvatar!)
                          : null,
                      child: (widget.targetAvatar == null || widget.targetAvatar!.isEmpty)
                          ? Icon(
                              _isRatingProvider ? Icons.storefront : Icons.person,
                              color: AppTheme.primary,
                              size: 26,
                            )
                          : null,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.targetName,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: onSurfaceColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.primary.withValues(alpha: isDark ? 0.3 : 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  _isRatingProvider ? 'PROVEEDOR VERIFICADO' : 'COMPRADOR COMERCIAL',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: isDark ? const Color(0xFF89D6B0) : AppTheme.primary,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_criteria.length} criterios · 1 reseña por perfil',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Live Average Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F3628),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star, color: Color(0xFFFBBF24), size: 16),
                              const SizedBox(width: 4),
                              Text(
                                _currentAverage.toStringAsFixed(1),
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'PROMEDIO',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white70,
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Title Section: Criterios a Evaluar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Criterios a Evaluar',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: onSurfaceColor,
                      ),
                    ),
                  ),
                  Text(
                    'Promedio: ${_currentAverage.toStringAsFixed(1)} ⭐',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFF89D6B0) : AppTheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // List of criteria sliders / star bars
              ..._criteria.map((c) {
                final key = c['key'] as String;
                final minVal = c['min'] as int;
                final maxVal = c['max'] as int;
                final currentVal = _scores[key] ?? 5.0;
                final icon = c['icon'] as IconData;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(icon, size: 18, color: AppTheme.primary),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              key,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: onSurfaceColor,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: isDark ? AppTheme.slate900 : const Color(0xFFF1F5F2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star_rounded, size: 14, color: Color(0xFFF59E0B)),
                                const SizedBox(width: 3),
                                Text(
                                  '${currentVal.toInt()}/$maxVal',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: onSurfaceColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Interactive Stars / Scale Selector
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(maxVal - minVal + 1, (idx) {
                          final scoreVal = (minVal + idx).toDouble();
                          final isSelected = scoreVal <= currentVal;

                          return InkWell(
                            onTap: () {
                              setState(() {
                                _scores[key] = scoreVal;
                              });
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.all(6),
                              child: Column(
                                children: [
                                  Icon(
                                    scoreVal == 0
                                        ? (currentVal == 0 ? Icons.cancel : Icons.cancel_outlined)
                                        : (isSelected ? Icons.star_rounded : Icons.star_outline_rounded),
                                    color: isSelected
                                        ? (scoreVal == 0 ? Colors.red : const Color(0xFFF59E0B))
                                        : (isDark ? Colors.white24 : Colors.black12),
                                    size: 26,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${scoreVal.toInt()}',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10,
                                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                                      color: isSelected ? onSurfaceColor : secondaryTextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 16),

              // Comment Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Comentario Reputacional',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: onSurfaceColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$commentLength / 100 caracteres',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: commentLength == 0
                          ? secondaryTextColor
                          : (_isCommentValid
                              ? (isDark ? const Color(0xFF89D6B0) : AppTheme.primary)
                              : Colors.red[600]),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Mínimo 10 caracteres y máximo 100 dígitos. Describe tu experiencia comercial directa.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: secondaryTextColor,
                ),
              ),
              const SizedBox(height: 10),

              Container(
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: commentLength > 0 && !_isCommentValid ? Colors.red.withValues(alpha: 0.5) : borderColor,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                child: TextField(
                  controller: _commentController,
                  maxLength: 100,
                  maxLines: 3,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: onSurfaceColor,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    border: InputBorder.none,
                    hintText: _isRatingProvider
                        ? 'Ejemplo: Excelente trato, entrega en tiempo pactado y mercancía de calidad.'
                        : 'Ejemplo: Comprador serio, pago oportuno y excelente comunicación en el acuerdo.',
                    hintStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: secondaryTextColor.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ),

              if (commentLength > 0 && commentLength < 10) ...[
                const SizedBox(height: 6),
                Text(
                  'Faltan ${10 - commentLength} caracteres para alcanzar el mínimo requerido (10).',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: Colors.red[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ] else if (_isCommentValid) ...[
                const SizedBox(height: 6),
                Text(
                  '✓ Longitud válida ($commentLength caracteres)',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: isDark ? const Color(0xFF89D6B0) : AppTheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],

              const SizedBox(height: 28),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isCommentValid && !_isSubmitting ? _handleSubmit : null,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.send_rounded, size: 18),
                  label: Text(
                    _isSubmitting ? 'Publicando...' : 'Publicar Reseña de Perfil',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: isDark ? AppTheme.slate700 : Colors.grey[300],
                    disabledForegroundColor: Colors.grey[500],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
