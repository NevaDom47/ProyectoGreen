import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart'; // import appThemeMode global variable
import '../models/user_report.dart';
import '../services/reports_service.dart';

class ReportedUser {
  final String name;
  final String username;
  final String? avatarUrl;
  final String? initials;
  final DateTime reportedAt;

  ReportedUser({
    required this.name,
    required this.username,
    required this.reportedAt,
    this.avatarUrl,
    this.initials,
  });
}

class ReportedUsersScreen extends StatefulWidget {
  const ReportedUsersScreen({super.key});

  @override
  State<ReportedUsersScreen> createState() => _ReportedUsersScreenState();
}

class _ReportedUsersScreenState extends State<ReportedUsersScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  DateTime? _selectedFilterDate;

  final List<ReportedUser> _allUsers = [
    ReportedUser(
      name: 'Carlos Rodríguez',
      username: '@carlos_rod89',
      avatarUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBjICzybPKvS5Xqs5EgqqAa5omMklKIYUcyKDaRL_07LUHApmJPULuU_BJ1BSfuxjDNuOJN4_BUJ78BS5ynmTkM1oYFgbZ6NpSZmRSNZ8eBgQybBhxe1cfxRN2suyyZ71WQq-Oodoe2-TigzReePlYj8obUTsbIptPvEXrgcyCW0lwCNDwVDjN3iDhSNbGWZ2ogRZYyPAvoOhZG-PRqCeIecaAhdGT_irbaIDi_hGq2eLMhZurCKAf8wh4KNUDW7KrBSGkxU582zB4',
      reportedAt: DateTime(2026, 3, 28, 14, 30),
    ),
    ReportedUser(
      name: 'Ana María López',
      username: '@ana_mx_7',
      initials: 'A',
      reportedAt: DateTime(2026, 3, 29, 9, 15),
    ),
    ReportedUser(
      name: 'Spam Bot 2024',
      username: '@crypto_king_bot',
      initials: 'S',
      reportedAt: DateTime(2026, 4, 1, 8, 45),
    ),
    ReportedUser(
      name: 'Juan Pérez',
      username: '@juanperez',
      initials: 'J',
      reportedAt: DateTime(2026, 4, 1, 11, 20),
    ),
  ];

  String _formatDate(DateTime date) {
    String pad(int n) => n.toString().padLeft(2, '0');
    return '${pad(date.day)}/${pad(date.month)}/${date.year} a las ${pad(date.hour)}:${pad(date.minute)}';
  }

  String _formatDateOnly(DateTime date) {
    String pad(int n) => n.toString().padLeft(2, '0');
    return '${pad(date.day)}/${pad(date.month)}/${date.year}';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedFilterDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? const ColorScheme.dark(
                    primary: Color(0xFFf20d0d),
                    onPrimary: Colors.white,
                    surface: Color(0xFF1E2923),
                    onSurface: Color(0xFFF1F5F9),
                  )
                : const ColorScheme.light(
                    primary: Color(0xFFf20d0d),
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: Color(0xFF0F172A),
                  ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedFilterDate = picked;
      });
    }
  }

  UserReport _getReportForUser(ReportedUser user) {
    final reports = ReportsService.instance.reportsNotifier.value;
    for (final r in reports) {
      if (r.reportedName.toLowerCase().trim() == user.name.toLowerCase().trim() ||
          user.name.toLowerCase().contains(r.reportedName.toLowerCase()) ||
          r.reportedName.toLowerCase().contains(user.name.toLowerCase())) {
        return r;
      }
    }
    return UserReport(
      id: 'REP-${user.reportedAt.year}-099',
      createdAt: user.reportedAt,
      reporterId: 'USR-88291',
      reporterName: 'Usuario de la Plataforma',
      reporterRole: 'comprador',
      reporterAvatar: '',
      reportedId: user.username,
      reportedName: user.name,
      reportedRole: 'comprador',
      reportedAvatar: user.avatarUrl ?? '',
      reportedLocation: 'Sector Central',
      reasons: const ['Comportamiento inusual o sospechoso reportado'],
      comment: 'Reporte generado por incidencia comunicada en la plataforma.',
      status: 'in_review',
      resolutionNotes: 'Caso bajo revisión por el equipo de moderación.',
    );
  }

  void _showReportSummaryModal(BuildContext context, ReportedUser user, UserReport report) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF0F172A) : Colors.white;
    final cardColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC);
    final textPrimary = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    const dangerColor = Color(0xFFDC2626);

    Color statusColor;
    String statusLabel;
    IconData statusIcon;
    String statusDesc;

    switch (report.status) {
      case 'in_review':
        statusColor = const Color(0xFF2563EB);
        statusLabel = 'En Investigación';
        statusIcon = Icons.manage_search_rounded;
        statusDesc = 'El equipo de moderación y confianza se encuentra evaluando las pruebas y mediando entre ambas partes.';
        break;
      case 'resolved':
        statusColor = const Color(0xFF059669);
        statusLabel = 'Caso Resuelto';
        statusIcon = Icons.check_circle_rounded;
        statusDesc = 'La incidencia fue procesada y resuelta formalmente por el equipo de mediación y soporte.';
        break;
      case 'dismissed':
        statusColor = const Color(0xFF64748B);
        statusLabel = 'Desestimado / Archivado';
        statusIcon = Icons.archive_outlined;
        statusDesc = 'El reporte fue evaluado y concluido sin sanción disciplinaria mayor.';
        break;
      case 'pending':
      default:
        statusColor = const Color(0xFFD97706);
        statusLabel = 'Pendiente de Revisión';
        statusIcon = Icons.hourglass_top_rounded;
        statusDesc = 'El reporte ha sido recibido por moderación y se encuentra en espera de asignación de caso.';
        break;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(ctx).size.height * 0.90,
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
                // Drag handle
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

                // Top Header Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: dangerColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.description_outlined,
                          color: dangerColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Resumen de Reporte',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: textPrimary,
                                letterSpacing: -0.3,
                              ),
                            ),
                            Text(
                              'Caso #${report.id} • ${_formatDate(report.createdAt)}',
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
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                // Scrollable content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status Card Banner
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(statusIcon, color: statusColor, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'Estatus: ',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: textSecondary,
                                          ),
                                        ),
                                        Text(
                                          statusLabel,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w800,
                                            color: statusColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      statusDesc,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11.5,
                                        color: textPrimary,
                                        height: 1.35,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Section 1: Reported User Card
                        Text(
                          'Usuario Reportado',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: borderColor),
                          ),
                          child: Row(
                            children: [
                              // Avatar or Initials using safe ClipOval
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isDark ? const Color(0xFF2D1A1A) : const Color(0xFFE2E8F0),
                                ),
                                child: ClipOval(
                                  child: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                                      ? Image.network(
                                          user.avatarUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => Center(
                                            child: Text(
                                              user.initials ?? (user.name.isNotEmpty ? user.name[0] : 'U'),
                                              style: const TextStyle(
                                                color: dangerColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                        )
                                      : Center(
                                          child: Text(
                                            user.initials ?? (user.name.isNotEmpty ? user.name[0] : 'U'),
                                            style: const TextStyle(
                                              color: dangerColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            report.reportedName,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 14.5,
                                              fontWeight: FontWeight.w700,
                                              color: textPrimary,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: report.reportedRole == 'proveedor'
                                                ? const Color(0xFF059669).withValues(alpha: 0.15)
                                                : Colors.blue.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            report.reportedRole.toUpperCase(),
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.w800,
                                              color: report.reportedRole == 'proveedor'
                                                  ? const Color(0xFF059669)
                                                  : Colors.blue[700],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      '${user.username} • Sector: ${report.reportedLocation}',
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
                        const SizedBox(height: 16),

                        // Section 2: Reporter Info
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF162232) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: borderColor),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.person_pin_outlined, size: 18, color: textSecondary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Reportado por: ${report.reporterName} (${report.reporterRole.toLowerCase() == 'proveedor' ? 'Proveedor' : 'Comprador'})',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Section 3: Motives selected in form
                        Text(
                          'Motivo(s) del reporte seleccionado(s)',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: report.reasons.map((reason) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: dangerColor.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: dangerColor.withValues(alpha: 0.3)),
                              ),
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    const WidgetSpan(
                                      alignment: PlaceholderAlignment.middle,
                                      child: Padding(
                                        padding: EdgeInsets.only(right: 6),
                                        child: Icon(Icons.report_problem_outlined, size: 14, color: dangerColor),
                                      ),
                                    ),
                                    TextSpan(
                                      text: reason,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? const Color(0xFFFCA5A5) : const Color(0xFF991B1B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 18),

                        // Section 4: Comment and description
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Comentario colocado en el reporte',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: textPrimary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${report.comment.runes.length} / 200 caracteres',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
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
                            color: cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: borderColor),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.format_quote_rounded, size: 20, color: dangerColor.withValues(alpha: 0.7)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  report.comment,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12.5,
                                    color: textPrimary,
                                    height: 1.45,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Section 5: Moderation / Resolution Notes
                        if (report.resolutionNotes != null && report.resolutionNotes!.isNotEmpty) ...[
                          const SizedBox(height: 18),
                          Text(
                            'Seguimiento y Notas de Moderación',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF0F241D) : const Color(0xFFECFDF5),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.verified_user_outlined, size: 16, color: Color(0xFF059669)),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Resolución de Moderación Mercadito:',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF065F46),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  report.resolutionNotes!,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    color: textPrimary,
                                    height: 1.4,
                                  ),
                                ),
                                if (report.resolvedAt != null) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    'Resuelto el ${_formatDate(report.resolvedAt!)}',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: textSecondary,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),

                // Bottom button
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: bgColor,
                    border: Border(top: BorderSide(color: borderColor)),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: dangerColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        'Cerrar Resumen',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                        ),
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appThemeMode,
      builder: (context, currentMode, _) {
        final platformBrightness = MediaQuery.platformBrightnessOf(context);
        final isDark = currentMode == ThemeMode.dark || (currentMode == ThemeMode.system && platformBrightness == Brightness.dark);
        
        final bgColor = isDark ? const Color(0xFF1c0d0d) : const Color(0xFFf8f5f5);
        const primaryColor = Color(0xFFf20d0d); // Danger red tone
        final textColor = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0f172a);
        final subtextColor = isDark ? const Color(0xFF94a3b8) : const Color(0xFF475569);
        final borderColor = isDark ? primaryColor.withValues(alpha: 0.2) : primaryColor.withValues(alpha: 0.1);

        return ValueListenableBuilder<List<UserReport>>(
          valueListenable: ReportsService.instance.reportsNotifier,
          builder: (context, serviceReports, _) {
            // Merge base users with any extra reports from service
            final List<ReportedUser> combinedUsers = List.from(_allUsers);
            for (final rep in serviceReports) {
              final alreadyPresent = combinedUsers.any((u) =>
                  u.name.toLowerCase().trim() == rep.reportedName.toLowerCase().trim());
              if (!alreadyPresent) {
                combinedUsers.insert(
                  0,
                  ReportedUser(
                    name: rep.reportedName,
                    username: rep.reportedId.startsWith('@') ? rep.reportedId : '@${rep.reportedId.toLowerCase()}',
                    avatarUrl: rep.reportedAvatar.startsWith('http') ? rep.reportedAvatar : null,
                    initials: rep.reportedName.isNotEmpty ? rep.reportedName[0].toUpperCase() : 'U',
                    reportedAt: rep.createdAt,
                  ),
                );
              }
            }

            final filteredUsers = combinedUsers.where((user) {
              final query = _searchQuery.toLowerCase();
              final matchesText = user.name.toLowerCase().contains(query) ||
                     user.username.toLowerCase().contains(query);
              
              if (_selectedFilterDate != null) {
                final isSameDate = user.reportedAt.year == _selectedFilterDate!.year &&
                                   user.reportedAt.month == _selectedFilterDate!.month &&
                                   user.reportedAt.day == _selectedFilterDate!.day;
                return matchesText && isSameDate;
              }
              
              return matchesText;
            }).toList();

            return Scaffold(
              backgroundColor: bgColor,
              appBar: AppBar(
                backgroundColor: bgColor,
                elevation: 0,
                scrolledUnderElevation: 0,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back_ios_new, color: textColor),
                  onPressed: () => context.pop(),
                ),
                title: Text(
                  'Usuarios Reportados',
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    fontFamily: 'Plus Jakarta Sans',
                  ),
                ),
                centerTitle: true,
              ),
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: isDark ? primaryColor.withValues(alpha: 0.1) : primaryColor.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.transparent),
                      ),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Icon(Icons.search, color: primaryColor.withValues(alpha: 0.7)),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              style: TextStyle(color: textColor),
                              onChanged: (value) {
                                setState(() {
                                  _searchQuery = value;
                                });
                              },
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Buscar usuarios...',
                                hintStyle: TextStyle(color: subtextColor),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.calendar_month, color: primaryColor.withValues(alpha: 0.7)),
                            onPressed: _pickDate,
                            tooltip: 'Filtrar por fecha',
                          ),
                          const SizedBox(width: 4),
                        ],
                      ),
                    ),
                  ),

                  // Active Date Filter Chip
                  if (_selectedFilterDate != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0).copyWith(bottom: 12.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.event, size: 14, color: primaryColor),
                                const SizedBox(width: 6),
                                Text(
                                  'Fecha: ${_formatDateOnly(_selectedFilterDate!)}',
                                  style: const TextStyle(
                                    color: primaryColor,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                InkWell(
                                  onTap: () => setState(() => _selectedFilterDate = null),
                                  child: const Icon(Icons.close, size: 16, color: primaryColor),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Info Text
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                    child: Text(
                      'Aquí podrás visualizar los usuarios que han sido reportados por algún comportamiento inusual por los demás proveedores y compradores.',
                      style: TextStyle(
                        color: subtextColor,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Users List
                  Expanded(
                    child: ListView.separated(
                      itemCount: filteredUsers.length,
                      separatorBuilder: (context, index) => Divider(
                        height: 1,
                        thickness: 1,
                        color: borderColor,
                      ),
                      itemBuilder: (context, index) {
                        final user = filteredUsers[index];
                        return InkWell(
                          onTap: () {
                            final report = _getReportForUser(user);
                            _showReportSummaryModal(context, user, report);
                          },
                          hoverColor: primaryColor.withValues(alpha: 0.05),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isDark ? const Color(0xFF2d1a1a) : const Color(0xFFe2e8f0),
                                  ),
                                  child: ClipOval(
                                    child: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                                        ? Image.network(
                                            user.avatarUrl!,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) => Center(
                                              child: Text(
                                                user.initials ?? (user.name.isNotEmpty ? user.name[0] : 'U'),
                                                style: const TextStyle(
                                                  color: primaryColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                ),
                                              ),
                                            ),
                                          )
                                        : Center(
                                            child: Text(
                                              user.initials ?? (user.name.isNotEmpty ? user.name[0] : 'U'),
                                              style: const TextStyle(
                                                color: primaryColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        user.name,
                                        style: TextStyle(
                                          color: textColor,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        user.username,
                                        style: TextStyle(
                                          color: subtextColor,
                                          fontSize: 14,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(Icons.access_time, size: 12, color: primaryColor.withValues(alpha: 0.8)),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Reportado el ${_formatDate(user.reportedAt)}',
                                            style: TextStyle(
                                              color: primaryColor.withValues(alpha: 0.8),
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                SizedBox(
                                  height: 32,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      final report = _getReportForUser(user);
                                      _showReportSummaryModal(context, user, report);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryColor,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      minimumSize: Size.zero,
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text(
                                      'Ver Reporte',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
