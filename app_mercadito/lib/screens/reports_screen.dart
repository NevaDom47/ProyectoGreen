import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user_report.dart';
import '../services/reports_service.dart';

/// Redesigned Reports Management Screen (Gestión de Reportes) for El Mercadito.
/// Built with the Stitch "Emerald Harvest" design system aesthetics:
/// - Clean Tonal Layering with zero unnecessary lines
/// - Bento-lite KPI triage bar for quick filtering
/// - Incident cards featuring dual-party comparison (denunciante vs reportado)
/// - Motive badges, mandatory quote box with character length, and moderation tools
/// - 100% resilient on Web, Desktop, and Mobile (zero null assertions, web-safe avatars)
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedRoleFilter = 'all'; // 'all', 'proveedor', 'comprador'
  String _selectedStatusFilter = 'all'; // 'all', 'pending', 'in_review', 'resolved', 'dismissed'

  // Brand Palette (Emerald Harvest)
  static const Color _primaryEmerald = Color(0xFF016042);
  static const Color _primaryDark = Color(0xFF00462F);
  static const Color _amberPending = Color(0xFFD97706);
  static const Color _blueInReview = Color(0xFF2563EB);
  static const Color _greenResolved = Color(0xFF059669);
  static const Color _slateDismissed = Color(0xFF64748B);
  static const Color _dangerRed = Color(0xFFDC2626);

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<UserReport> _applyFilters(List<UserReport> reports) {
    return reports.where((report) {
      // Role filter (matches the reported party's role)
      if (_selectedRoleFilter != 'all') {
        final role = (report.reportedRole).trim().toLowerCase();
        if (role != _selectedRoleFilter) {
          return false;
        }
      }

      // Status filter
      if (_selectedStatusFilter != 'all') {
        if (report.status != _selectedStatusFilter) {
          return false;
        }
      }

      // Search query
      if (_searchQuery.isNotEmpty) {
        final reporter = report.reporterName.toLowerCase();
        final repId = report.reporterId.toLowerCase();
        final reported = report.reportedName.toLowerCase();
        final reportedId = report.reportedId.toLowerCase();
        final location = report.reportedLocation.toLowerCase();
        final comment = report.comment.toLowerCase();
        final id = report.id.toLowerCase();
        final reasonsMatch = report.reasons.any((r) => r.toLowerCase().contains(_searchQuery));

        final matches = reporter.contains(_searchQuery) ||
            repId.contains(_searchQuery) ||
            reported.contains(_searchQuery) ||
            reportedId.contains(_searchQuery) ||
            location.contains(_searchQuery) ||
            comment.contains(_searchQuery) ||
            id.contains(_searchQuery) ||
            reasonsMatch;

        if (!matches) return false;
      }

      return true;
    }).toList();
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '';
    final now = DateTime.now();
    final difference = now.difference(dt);

    if (difference.inMinutes < 60) {
      final mins = difference.inMinutes <= 0 ? 1 : difference.inMinutes;
      return 'Hace $mins min';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours} h';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} d';
    } else {
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    }
  }

  Color _getStatusColor(String? status) {
    switch (status ?? 'pending') {
      case 'pending':
        return _amberPending;
      case 'in_review':
        return _blueInReview;
      case 'resolved':
        return _greenResolved;
      case 'dismissed':
        return _slateDismissed;
      default:
        return _amberPending;
    }
  }

  String _getStatusLabel(String? status) {
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

  IconData _getStatusIcon(String? status) {
    switch (status ?? 'pending') {
      case 'pending':
        return Icons.hourglass_top_rounded;
      case 'in_review':
        return Icons.sync_rounded;
      case 'resolved':
        return Icons.check_circle_rounded;
      case 'dismissed':
        return Icons.archive_outlined;
      default:
        return Icons.info_outline;
    }
  }

  /// Web-safe, crash-proof Avatar widget.
  /// Uses initials + high-contrast brand styling.
  Widget _buildCrashProofAvatar(String name, String role, {double size = 32}) {
    final cleanName = name.trim();
    final initial = cleanName.isNotEmpty ? cleanName[0].toUpperCase() : (role == 'proveedor' ? 'P' : 'C');
    final isProvider = role.toLowerCase() == 'proveedor';

    final bg = isProvider ? const Color(0xFFFEF3C7) : const Color(0xFFE8F5ED);
    final fg = isProvider ? const Color(0xFFB45309) : _primaryDark;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: Border.all(color: fg.withValues(alpha: 0.25), width: 1.5),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: GoogleFonts.plusJakartaSans(
          fontSize: size * 0.42,
          fontWeight: FontWeight.w800,
          color: fg,
        ),
      ),
    );
  }

  void _showModerationDialog(UserReport report) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final notesController = TextEditingController(text: report.resolutionNotes ?? '');
    String selectedStatus = report.status;

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _primaryEmerald.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.gavel_rounded, color: _primaryEmerald, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Moderar Incidencia',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          'ID: #${report.id}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Actualizar Estado de Moderación:',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        {'key': 'pending', 'label': 'Pendiente', 'color': _amberPending},
                        {'key': 'in_review', 'label': 'En Revisión', 'color': _blueInReview},
                        {'key': 'resolved', 'label': 'Resuelto', 'color': _greenResolved},
                        {'key': 'dismissed', 'label': 'Desestimar', 'color': _slateDismissed},
                      ].map((item) {
                        final key = item['key'] as String;
                        final label = item['label'] as String;
                        final color = item['color'] as Color;
                        final isSelected = selectedStatus == key;

                        return ChoiceChip(
                          label: Text(label),
                          labelStyle: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: isSelected ? Colors.white : (isDark ? Colors.white70 : const Color(0xFF334155)),
                          ),
                          selected: isSelected,
                          selectedColor: color,
                          backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                          side: BorderSide(
                            color: isSelected ? color : (isDark ? const Color(0xFF475569) : const Color(0xFFE2E8F0)),
                          ),
                          onSelected: (val) {
                            if (val) {
                              setDialogState(() {
                                selectedStatus = key;
                              });
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Notas o Medidas Tomadas:',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: notesController,
                      maxLines: 3,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                      decoration: InputDecoration(
                        hintText: 'Describe la resolución o mediación aplicada...',
                        hintStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                        ),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogCtx).pop(),
                  child: Text(
                    'Cancelar',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    final notes = notesController.text.trim();
                    ReportsService.instance.updateReportStatus(
                      report.id,
                      selectedStatus,
                      resolutionNotes: notes.isNotEmpty ? notes : null,
                    );
                    Navigator.of(dialogCtx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: _primaryEmerald,
                        content: Text(
                          'Incidencia #${report.id} actualizada a "${_getStatusLabel(selectedStatus)}".',
                          style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w600),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryEmerald,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(
                    'Guardar',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showReportDetailModal(UserReport report) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : Colors.white;
    final textPrimary = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final cardColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC);
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final statusColor = _getStatusColor(report.status);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Detalle del Reporte',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: textPrimary,
                          ),
                        ),
                        Text(
                          'Expediente #${report.id} • ${_formatDate(report.createdAt)}',
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
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: textSecondary),
                    onPressed: () => Navigator.of(sheetCtx).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Badge Banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(_getStatusIcon(report.status), color: statusColor, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Estado del caso: ${_getStatusLabel(report.status)}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Participants Header
                    Text(
                      'PARTICIPANTES DE LA INCIDENCIA',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: textSecondary,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Reporter Box
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        children: [
                          _buildCrashProofAvatar(report.reporterName, report.reporterRole, size: 40),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: _primaryEmerald.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'DENUNCIANTE (${report.reporterRole.toUpperCase()})',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800,
                                          color: _primaryEmerald,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  report.reporterName,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    color: textPrimary,
                                  ),
                                ),
                                Text(
                                  'ID: ${report.reporterId}${report.reporterContact != null ? " • ${report.reporterContact}" : ""}',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    color: textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Reported Box
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        children: [
                          _buildCrashProofAvatar(report.reportedName, report.reportedRole, size: 40),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: _dangerRed.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'REPORTADO (${report.reportedRole.toUpperCase()})',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800,
                                          color: _dangerRed,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  report.reportedName,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    color: textPrimary,
                                  ),
                                ),
                                Text(
                                  'ID: ${report.reportedId} • ${report.reportedLocation}',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    color: textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Reasons Header & List
                    Text(
                      'MOTIVOS SELECCIONADOS',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: textSecondary,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: report.reasons.map((reason) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: _dangerRed.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: _dangerRed.withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.error_outline_rounded, size: 14, color: _dangerRed),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  reason,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? const Color(0xFFFCA5A5) : _dangerRed,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // Mandatory Comment Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'COMENTARIO OBLIGATORIO DEL DENUNCIANTE',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: textSecondary,
                            letterSpacing: 0.8,
                          ),
                        ),
                        Text(
                          '${report.charactersLength}/200',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.format_quote_rounded, color: _primaryEmerald.withValues(alpha: 0.6), size: 24),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              report.comment,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                height: 1.45,
                                fontStyle: FontStyle.italic,
                                color: textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (report.resolutionNotes != null && report.resolutionNotes!.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Text(
                        'RESOLUCIÓN Y ACCIONES DISCIPLINARIAS',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: textSecondary,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _greenResolved.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _greenResolved.withValues(alpha: 0.25)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.verified_user_rounded, size: 16, color: _greenResolved),
                                const SizedBox(width: 6),
                                Text(
                                  'Dictamen de Moderación',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: _greenResolved,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              report.resolutionNotes!,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12.5,
                                color: textPrimary,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: bgColor,
                border: Border(top: BorderSide(color: borderColor)),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(sheetCtx).pop();
                    _showModerationDialog(report);
                  },
                  icon: const Icon(Icons.edit_note_rounded),
                  label: const Text('Moderar o Resolver Caso'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryEmerald,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBentoCard({
    required String title,
    required String count,
    required String subtitle,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                count,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportCard(UserReport report, bool isDark) {
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final textPrimary = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final statusColor = _getStatusColor(report.status);
    final isReportedProvider = report.reportedRole.toLowerCase() == 'proveedor';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left Status Color Strip (Signature Stitch accent bar)
            Container(
              width: 5,
              color: statusColor,
            ),
            // Card Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header: ID + Timestamp + Status Pill
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 6,
                            runSpacing: 2,
                            children: [
                              Text(
                                '#${report.id}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: textPrimary,
                                  letterSpacing: 0.4,
                                ),
                              ),
                              Text(
                                '• ${_formatDate(report.createdAt)}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_getStatusIcon(report.status), size: 12, color: statusColor),
                              const SizedBox(width: 4),
                              Text(
                                _getStatusLabel(report.status),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  color: statusColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Counterparts Dual Box (Denunciante vs Reportado)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor.withValues(alpha: 0.6)),
                      ),
                      child: Column(
                        children: [
                          // Reporter Row
                          Row(
                            children: [
                              _buildCrashProofAvatar(report.reporterName, report.reporterRole, size: 28),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'DENUNCIANTE',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 8.5,
                                        fontWeight: FontWeight.w800,
                                        color: textSecondary,
                                        letterSpacing: 0.4,
                                      ),
                                    ),
                                    Text(
                                      report.reporterName,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: textPrimary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _primaryEmerald.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      report.reporterRole.toUpperCase(),
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 7.5,
                                        fontWeight: FontWeight.w800,
                                        color: _primaryEmerald,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '#${report.reporterId}',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 8,
                                      fontWeight: FontWeight.w600,
                                      color: textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Divider(
                              height: 1,
                              color: borderColor.withValues(alpha: 0.5),
                            ),
                          ),

                          // Reported Row
                          Row(
                            children: [
                              _buildCrashProofAvatar(report.reportedName, report.reportedRole, size: 28),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'REPORTADO',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 8.5,
                                        fontWeight: FontWeight.w800,
                                        color: _dangerRed,
                                        letterSpacing: 0.4,
                                      ),
                                    ),
                                    Text(
                                      report.reportedName,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: textPrimary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isReportedProvider
                                          ? Colors.orange.withValues(alpha: 0.15)
                                          : Colors.blue.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      report.reportedRole.toUpperCase(),
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 7.5,
                                        fontWeight: FontWeight.w800,
                                        color: isReportedProvider ? const Color(0xFFC2410C) : const Color(0xFF1D4ED8),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '#${report.reportedId}',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 8,
                                      fontWeight: FontWeight.w600,
                                      color: textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Motives / Reasons Tags
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: report.reasons.map((reason) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _dangerRed.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: _dangerRed.withValues(alpha: 0.2)),
                          ),
                          child: Text(
                            reason,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: isDark ? const Color(0xFFFCA5A5) : _dangerRed,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 8),

                    // Mandatory Comment Quote Box
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(10),
                        border: Border(left: BorderSide(color: statusColor, width: 3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  'Comentario obligatorio:',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: textSecondary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${report.charactersLength}/200 caracteres',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w600,
                                  color: textSecondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '"${report.comment}"',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              height: 1.35,
                              color: textPrimary,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Actions Bar (Wrapped for narrow mobile screens)
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        TextButton.icon(
                          onPressed: () => _showReportDetailModal(report),
                          icon: const Icon(Icons.visibility_outlined, size: 15),
                          label: const Text('Ver Expediente'),
                          style: TextButton.styleFrom(
                            foregroundColor: textSecondary,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            textStyle: GoogleFonts.plusJakartaSans(fontSize: 11.5, fontWeight: FontWeight.w700),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _showModerationDialog(report),
                          icon: const Icon(Icons.tune_rounded, size: 14),
                          label: const Text('Moderar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryEmerald,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            textStyle: GoogleFonts.plusJakartaSans(fontSize: 11.5, fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _primaryEmerald.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline_rounded,
                size: 48,
                color: _primaryEmerald,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No hay reportes que coincidan',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty || _selectedRoleFilter != 'all' || _selectedStatusFilter != 'all'
                  ? 'Intenta ajustar tus criterios de búsqueda o filtros para ver más resultados.'
                  : 'No existen incidencias reportadas en este momento. La plataforma opera con normalidad.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  _selectedRoleFilter = 'all';
                  _selectedStatusFilter = 'all';
                });
              },
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Restablecer Filtros'),
              style: TextButton.styleFrom(
                foregroundColor: _primaryEmerald,
                textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0B1120) : const Color(0xFFF6F8F6);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textPrimary = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: isDark ? Colors.white : const Color(0xFF0F172A)),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/home');
            }
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gestión de Reportes',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: textPrimary,
              ),
            ),
            Text(
              'Panel de Moderación & Incidentes',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          ValueListenableBuilder<List<UserReport>>(
            valueListenable: ReportsService.instance.reportsNotifier,
            builder: (context, reports, _) {
              final pending = reports.where((r) => r.status == 'pending').length;
              return Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: pending > 0 ? _amberPending.withValues(alpha: 0.15) : _greenResolved.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: pending > 0 ? _amberPending.withValues(alpha: 0.3) : _greenResolved.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          pending > 0 ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                          size: 13,
                          color: pending > 0 ? _amberPending : _greenResolved,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$pending Pendientes',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: pending > 0 ? _amberPending : _greenResolved,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: ValueListenableBuilder<List<UserReport>>(
        valueListenable: ReportsService.instance.reportsNotifier,
        builder: (context, allReports, _) {
          final filteredReports = _applyFilters(allReports);

          final pendingCount = allReports.where((r) => r.status == 'pending').length;
          final inReviewCount = allReports.where((r) => r.status == 'in_review').length;
          final resolvedCount = allReports.where((r) => r.status == 'resolved').length;

          return ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            children: [
              // Bento-lite Quick Triage Row (Stitch Design)
              Row(
                children: [
                  _buildBentoCard(
                    title: 'Pendientes',
                    count: '$pendingCount',
                    subtitle: 'Por revisar',
                    color: _amberPending,
                    isDark: isDark,
                    onTap: () {
                      setState(() {
                        _selectedStatusFilter = _selectedStatusFilter == 'pending' ? 'all' : 'pending';
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildBentoCard(
                    title: 'En Revisión',
                    count: '$inReviewCount',
                    subtitle: 'En mediación',
                    color: _blueInReview,
                    isDark: isDark,
                    onTap: () {
                      setState(() {
                        _selectedStatusFilter = _selectedStatusFilter == 'in_review' ? 'all' : 'in_review';
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildBentoCard(
                    title: 'Resueltos',
                    count: '$resolvedCount',
                    subtitle: 'Completados',
                    color: _greenResolved,
                    isDark: isDark,
                    onTap: () {
                      setState(() {
                        _selectedStatusFilter = _selectedStatusFilter == 'resolved' ? 'all' : 'resolved';
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Search Box
              Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 6,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  style: GoogleFonts.plusJakartaSans(fontSize: 13, color: textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Buscar por ID (#REP), nombre o motivo...',
                    hintStyle: GoogleFonts.plusJakartaSans(fontSize: 12, color: textSecondary),
                    prefixIcon: Icon(Icons.search_rounded, color: textSecondary, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () => _searchController.clear(),
                          )
                        : null,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Filter Chips Row (Horizontal Scroll)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildChip(
                      label: 'Todos',
                      isSelected: _selectedRoleFilter == 'all' && _selectedStatusFilter == 'all',
                      onTap: () {
                        setState(() {
                          _selectedRoleFilter = 'all';
                          _selectedStatusFilter = 'all';
                        });
                      },
                      isDark: isDark,
                    ),
                    const SizedBox(width: 6),
                    _buildChip(
                      label: 'Compradores',
                      isSelected: _selectedRoleFilter == 'comprador',
                      onTap: () {
                        setState(() {
                          _selectedRoleFilter = _selectedRoleFilter == 'comprador' ? 'all' : 'comprador';
                        });
                      },
                      isDark: isDark,
                    ),
                    const SizedBox(width: 6),
                    _buildChip(
                      label: 'A Proveedores',
                      isSelected: _selectedRoleFilter == 'proveedor',
                      onTap: () {
                        setState(() {
                          _selectedRoleFilter = _selectedRoleFilter == 'proveedor' ? 'all' : 'proveedor';
                        });
                      },
                      isDark: isDark,
                    ),
                    const SizedBox(width: 6),
                    _buildChip(
                      label: 'Pendientes',
                      isSelected: _selectedStatusFilter == 'pending',
                      accentColor: _amberPending,
                      onTap: () {
                        setState(() {
                          _selectedStatusFilter = _selectedStatusFilter == 'pending' ? 'all' : 'pending';
                        });
                      },
                      isDark: isDark,
                    ),
                    const SizedBox(width: 6),
                    _buildChip(
                      label: 'En Revisión',
                      isSelected: _selectedStatusFilter == 'in_review',
                      accentColor: _blueInReview,
                      onTap: () {
                        setState(() {
                          _selectedStatusFilter = _selectedStatusFilter == 'in_review' ? 'all' : 'in_review';
                        });
                      },
                      isDark: isDark,
                    ),
                    const SizedBox(width: 6),
                    _buildChip(
                      label: 'Resueltos',
                      isSelected: _selectedStatusFilter == 'resolved',
                      accentColor: _greenResolved,
                      onTap: () {
                        setState(() {
                          _selectedStatusFilter = _selectedStatusFilter == 'resolved' ? 'all' : 'resolved';
                        });
                      },
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Reports List or Empty State
              if (filteredReports.isEmpty)
                _buildEmptyState(isDark)
              else
                ...filteredReports.map((report) => _buildReportCard(report, isDark)),

              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
    Color? accentColor,
  }) {
    final activeColor = accentColor ?? _primaryEmerald;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor
              : (isDark ? const Color(0xFF1E293B) : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? activeColor
                : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected
                ? Colors.white
                : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569)),
          ),
        ),
      ),
    );
  }
}
