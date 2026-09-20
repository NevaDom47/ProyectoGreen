import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user_report.dart';
import '../services/reports_service.dart';
import '../services/user_session.dart';

/// Modal bottom sheet that presents a streamlined form to report a Provider or Buyer.
///
/// Implements strict requirements:
/// 1. Dynamic selectable reasons based on reported role.
/// 2. Mandatory comment section with a maximum of 200 characters.
/// 3. Unique identifier data for both reporter and reported user.
/// 4. Submits directly into [ReportsService].
class ReportUserBottomSheet extends StatefulWidget {
  final String reportedId;
  final String reportedName;
  final String reportedRole; // 'proveedor' | 'comprador'
  final String reportedAvatar;
  final String reportedLocation;

  const ReportUserBottomSheet({
    super.key,
    required this.reportedId,
    required this.reportedName,
    required this.reportedRole,
    required this.reportedAvatar,
    required this.reportedLocation,
  });

  /// Convenient static helper to show the bottom sheet anywhere in the app.
  static Future<bool?> show({
    required BuildContext context,
    required String reportedId,
    required String reportedName,
    required String reportedRole,
    String reportedAvatar = '',
    String reportedLocation = 'República Dominicana',
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ReportUserBottomSheet(
        reportedId: reportedId,
        reportedName: reportedName,
        reportedRole: reportedRole,
        reportedAvatar: reportedAvatar,
        reportedLocation: reportedLocation,
      ),
    );
  }

  @override
  State<ReportUserBottomSheet> createState() => _ReportUserBottomSheetState();
}

class _ReportUserBottomSheetState extends State<ReportUserBottomSheet> {
  final TextEditingController _commentController = TextEditingController();
  final Set<String> _selectedReasons = {};
  String? _commentError;
  String? _reasonsError;
  bool _isSubmitting = false;

  static const Color _primaryEmerald = Color(0xFF016042);
  static const Color _dangerRed = Color(0xFFDC2626);
  static const int _maxCommentLength = 200;

  /// Returns only the sector/zone for other users (privacy preservation).
  /// E.g. "Central de Abastos • Cuauhtémoc, CDMX" -> "Cuauhtémoc, CDMX"
  String get _displaySector {
    final raw = widget.reportedLocation.trim();
    if (raw.contains('•')) {
      final parts = raw.split('•');
      final last = parts.last.trim();
      if (last.isNotEmpty) {
        return last;
      }
    }
    return raw;
  }

  List<String> get _availableReasons {
    if (widget.reportedRole.toLowerCase() == 'comprador') {
      return ReportsService.buyerReportReasons;
    }
    return ReportsService.providerReportReasons;
  }

  Color _getStatusColor(String? status) {
    switch (status ?? 'pending') {
      case 'pending':
        return const Color(0xFFD97706);
      case 'in_review':
        return const Color(0xFF2563EB);
      case 'resolved':
        return const Color(0xFF059669);
      case 'dismissed':
        return const Color(0xFF64748B);
      default:
        return const Color(0xFFD97706);
    }
  }

  String _getStatusDisplay(String? status) {
    switch (status ?? 'pending') {
      case 'pending':
        return 'Pendiente';
      case 'in_review':
        return 'En Revisión';
      case 'resolved':
        return 'Resuelto';
      case 'dismissed':
        return 'Desestimado';
      default:
        return status ?? 'Pendiente';
    }
  }

  String _formatReportDate(DateTime date) {
    String pad(int n) => n.toString().padLeft(2, '0');
    return '${pad(date.day)}/${pad(date.month)}/${date.year} ${pad(date.hour)}:${pad(date.minute)}';
  }

  @override
  void initState() {
    super.initState();
    _commentController.addListener(() {
      setState(() {
        if (_commentError != null && _commentController.text.trim().isNotEmpty) {
          _commentError = null;
        }
      });
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Widget _buildAvatar(String? avatarUrl, double size) {
    final url = avatarUrl ?? '';
    final isBuyer = widget.reportedRole == 'comprador';

    if (url.isEmpty) {
      return CircleAvatar(
        radius: size / 2,
        backgroundColor: const Color(0xFFE2E8F0),
        child: Icon(
          isBuyer ? Icons.person : Icons.store,
          size: size * 0.55,
          color: const Color(0xFF64748B),
        ),
      );
    }
    if (url.startsWith('http')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(size / 2),
        child: Image.network(
          url,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => CircleAvatar(
            radius: size / 2,
            backgroundColor: const Color(0xFFE2E8F0),
            child: Icon(
              isBuyer ? Icons.person : Icons.store,
              size: size * 0.55,
              color: const Color(0xFF64748B),
            ),
          ),
        ),
      );
    }
    if (url.startsWith('assets/')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(size / 2),
        child: Image.asset(
          url,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => CircleAvatar(
            radius: size / 2,
            backgroundColor: const Color(0xFFE2E8F0),
            child: Icon(
              isBuyer ? Icons.person : Icons.store,
              size: size * 0.55,
              color: const Color(0xFF64748B),
            ),
          ),
        ),
      );
    }
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: const Color(0xFFE2E8F0),
      child: Icon(
        isBuyer ? Icons.person : Icons.store,
        size: size * 0.55,
        color: const Color(0xFF64748B),
      ),
    );
  }

  void _submit() {
    final comment = _commentController.text.trim();
    bool hasError = false;

    if (_selectedReasons.isEmpty) {
      setState(() {
        _reasonsError = 'Selecciona al menos un motivo del reporte.';
      });
      hasError = true;
    } else {
      setState(() {
        _reasonsError = null;
      });
    }

    if (comment.isEmpty) {
      setState(() {
        _commentError = 'El comentario es obligatorio para generar un reporte.';
      });
      hasError = true;
    } else if (comment.runes.length > _maxCommentLength) {
      setState(() {
        _commentError = 'El comentario no puede exceder los 200 caracteres.';
      });
      hasError = true;
    } else {
      setState(() {
        _commentError = null;
      });
    }

    if (hasError) return;

    setState(() {
      _isSubmitting = true;
    });

    // Determine current user reporter info
    final currentRole = UserSession.selectedRole ?? 'comprador';
    final reporterName = UserSession.fullName ?? (currentRole == 'comprador' ? 'Comprador Registrado' : 'Productor Verificado');
    final reporterId = currentRole == 'comprador' ? 'BUY-88291' : 'SELL-9942';

    if (ReportsService.instance.hasActiveReport(reporterId, widget.reportedId)) {
      setState(() {
        _isSubmitting = false;
      });
      final active = ReportsService.instance.getActiveReport(reporterId, widget.reportedId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: _dangerRed,
          content: Text(
            'Ya existe un reporte activo (#${active?.id}) en revisión para este usuario. Solo puedes volver a reportarlo si el caso fue marcado como resuelto.',
          ),
        ),
      );
      return;
    }
    final reporterAvatar = UserSession.profilePictureUrl ??
        (currentRole == 'comprador'
            ? 'assets/images/Foto sin perfil.png'
            : 'assets/images/Foto Sin perfil Proveedor.png');

    final reportId = 'REP-${DateTime.now().year}-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    final report = UserReport(
      id: reportId,
      createdAt: DateTime.now(),
      reporterId: reporterId,
      reporterName: reporterName,
      reporterRole: currentRole,
      reporterAvatar: reporterAvatar,
      reporterContact: UserSession.phone ?? UserSession.email,
      reportedId: widget.reportedId,
      reportedName: widget.reportedName,
      reportedRole: widget.reportedRole.toLowerCase(),
      reportedAvatar: widget.reportedAvatar,
      reportedLocation: _displaySector,
      reasons: _selectedReasons.toList(),
      comment: comment,
      status: 'pending',
    );

    ReportsService.instance.submitReport(report);

    if (mounted) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF064E3B),
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Reporte enviado a moderación exitosamente (#$reportId).',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF0F172A) : Colors.white;
    final cardColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC);
    final textPrimary = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    final isProviderTarget = widget.reportedRole.toLowerCase() == 'proveedor';
    final roleTitle = isProviderTarget ? 'Proveedor' : 'Comprador';
    final currentLength = _commentController.text.runes.length;
    final isOverLimit = currentLength > _maxCommentLength;

    final currentRole = UserSession.selectedRole ?? 'comprador';
    final reporterId = currentRole == 'comprador' ? 'BUY-88291' : 'SELL-9942';
    final activeReport = ReportsService.instance.getActiveReport(reporterId, widget.reportedId);
    final hasActive = activeReport != null;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 24,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Grab handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            // Header bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _dangerRed.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.flag_rounded,
                      color: _dangerRed,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Reportar $roleTitle',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: textPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                        Text(
                          'Envía una incidencia formal a moderación',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: textSecondary, size: 22),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Scrollable Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Target preview card
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        children: [
                          _buildAvatar(widget.reportedAvatar, 44),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        widget.reportedName,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: textPrimary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isProviderTarget
                                            ? _primaryEmerald.withValues(alpha: 0.15)
                                            : Colors.blue.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        roleTitle.toUpperCase(),
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800,
                                          color: isProviderTarget ? _primaryEmerald : Colors.blue[700],
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'ID: ${widget.reportedId} • $_displaySector',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11.5,
                                    color: textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (hasActive) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF2D1515) : const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: _dangerRed.withValues(alpha: 0.35)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.info_outline_rounded, color: _dangerRed, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Reporte Activo en Revisión (#${activeReport.id})',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w800,
                                      color: _dangerRed,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(activeReport.status).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: _getStatusColor(activeReport.status).withValues(alpha: 0.4)),
                                  ),
                                  child: Text(
                                    _getStatusDisplay(activeReport.status),
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                      color: _getStatusColor(activeReport.status),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Ya tienes una incidencia en moderación para este usuario enviada el ${_formatReportDate(activeReport.createdAt)}. Por políticas de la plataforma, no puedes generar más de un reporte hasta que el caso previo sea marcado como resuelto.',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: textPrimary,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: borderColor),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Motivo(s) reportado(s):',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    activeReport.reasons.join(', '),
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                      color: textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Comentario enviado:',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    '"${activeReport.comment}"',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11.5,
                                      fontStyle: FontStyle.italic,
                                      color: textPrimary,
                                    ),
                                  ),
                                  if (activeReport.resolutionNotes != null && activeReport.resolutionNotes!.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      'Seguimiento de moderación:',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF059669),
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      activeReport.resolutionNotes!,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11.5,
                                        color: textPrimary,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ] else ...[
                      const SizedBox(height: 18),

                      // Reasons section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Selecciona el motivo (uno o varios)*',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: textPrimary,
                            ),
                          ),
                          if (_selectedReasons.isNotEmpty)
                            Text(
                              '${_selectedReasons.length} seleccionado(s)',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: _primaryEmerald,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _availableReasons.map((reason) {
                          final isSelected = _selectedReasons.contains(reason);
                          return FilterChip(
                            label: Text(reason),
                            labelStyle: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155)),
                            ),
                            selected: isSelected,
                            selectedColor: _dangerRed.withValues(alpha: 0.88),
                            backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                            checkmarkColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(
                                color: isSelected
                                    ? _dangerRed
                                    : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedReasons.add(reason);
                                } else {
                                  _selectedReasons.remove(reason);
                                }
                                if (_selectedReasons.isNotEmpty) {
                                  _reasonsError = null;
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),

                      if (_reasonsError != null) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.error_outline, size: 14, color: _dangerRed),
                            const SizedBox(width: 6),
                            Text(
                              _reasonsError!,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: _dangerRed,
                              ),
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: 18),

                      // Comment field (Mandatory, max 200)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Detalles de la incidencia (Obligatorio)*',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: textPrimary,
                            ),
                          ),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: isOverLimit
                                  ? _dangerRed
                                  : (currentLength >= 180 ? Colors.amber[800] : textSecondary),
                            ),
                            child: Text('$currentLength / $_maxCommentLength'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      TextField(
                        controller: _commentController,
                        maxLines: 4,
                        maxLength: _maxCommentLength,
                        buildCounter: (
                          _, {
                          required currentLength,
                          required isFocused,
                          maxLength,
                        }) =>
                            null, // We use custom counter in the row above
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Explica con precisión lo sucedido para que el equipo de moderación pueda investigar (máx. 200 caracteres)...',
                          hintStyle: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            color: textSecondary.withValues(alpha: 0.8),
                          ),
                          filled: true,
                          fillColor: cardColor,
                          contentPadding: const EdgeInsets.all(12),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: _commentError != null ? _dangerRed : borderColor,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: _commentError != null ? _dangerRed : _primaryEmerald,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),

                      if (_commentError != null) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.error_outline, size: 14, color: _dangerRed),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                _commentError!,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: _dangerRed,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: 14),

                      // Confidentiality notice banner
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: (isDark ? const Color(0xFF064E3B) : const Color(0xFFECFDF5))
                              .withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _primaryEmerald.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.shield_outlined,
                              size: 16,
                              color: _primaryEmerald,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Tu reporte será procesado de forma confidencial. El usuario reportado no sabrá quién generó la alerta.',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  height: 1.35,
                                  color: isDark ? const Color(0xFFA7F3D0) : const Color(0xFF065F46),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ],
                ),
              ),
            ),

            // Action buttons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: bgColor,
                border: Border(top: BorderSide(color: borderColor)),
              ),
              child: hasActive
                  ? SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.check_circle_outline, size: 18),
                        label: Text(
                          'Entendido (Caso en Revisión)',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFF0F172A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              side: BorderSide(color: borderColor),
                            ),
                            child: Text(
                              'Cancelar',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: textSecondary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _dangerRed,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: _isSubmitting
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.send_rounded, size: 16),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Enviar Reporte',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
