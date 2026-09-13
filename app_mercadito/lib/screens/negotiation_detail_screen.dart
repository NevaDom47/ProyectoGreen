import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:printing/printing.dart';
import '../services/pdf_invoice_service.dart';
import '../theme/app_theme.dart';

class NegotiationDetailScreen extends StatelessWidget {
  final Map<String, dynamic> negotiation;

  const NegotiationDetailScreen({
    super.key,
    required this.negotiation,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Tokens matching design snippet and AppTheme
    final surfaceColor = isDark ? AppTheme.backgroundDark : const Color(0xFFF9FAF5);
    final surfaceContainerLowestColor = isDark ? const Color(0xFF162B23) : Colors.white;
    final surfaceContainerLowColor = isDark ? const Color(0xFF1E382E) : const Color(0xFFF3F6EC);
    final surfaceContainerHighColor = isDark ? const Color(0xFF264639) : const Color(0xFFEBF0E3);
    
    final primaryColor = isDark ? const Color(0xFF89D6B0) : AppTheme.primary;
    final primaryContainerColor = isDark ? const Color(0xFF005137) : const Color(0xFF036042);
    final primaryFixedColor = isDark ? const Color(0xFF89D6B0) : const Color(0xFFA5F3CB);
    final onPrimaryContainerColor = isDark ? const Color(0xFF8BD8B2) : const Color(0xFF8BD8B2);
    
    final secondaryColor = isDark ? const Color(0xFFB0CCC0) : const Color(0xFF486456);
    final secondaryContainerColor = isDark ? const Color(0xFF314C3F) : const Color(0xFFCAEAD7);
    
    final onSurfaceColor = isDark ? AppTheme.slate50 : const Color(0xFF141A15);
    final onSurfaceVariantColor = isDark ? AppTheme.slate400 : const Color(0xFF435245);
    final outlineVariantColor = isDark ? const Color(0xFF2E4E41) : const Color(0xFFD0D9CD);

    return Scaffold(
      backgroundColor: surfaceColor,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AppBar(
              backgroundColor: surfaceColor.withValues(alpha: 0.9),
              elevation: 0,
              scrolledUnderElevation: 0,
              centerTitle: true,
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: primaryColor),
                  style: IconButton.styleFrom(
                    backgroundColor: isDark ? surfaceContainerLowColor : const Color(0xFFE5F1EB),
                    hoverColor: surfaceContainerHighColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => context.pop(),
                ),
              ),
              title: Text(
                'Detalle del acuerdo',
                style: GoogleFonts.plusJakartaSans(
                  color: primaryColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + kToolbarHeight + 16,
              left: 16.0,
              right: 16.0,
              bottom: 120.0,
            ),
            children: [
              _buildHeroSection(primaryColor, primaryContainerColor, primaryFixedColor),
              const SizedBox(height: 20),
              _buildProductPartnerCard(
                context,
                isDark,
                surfaceContainerLowestColor,
                surfaceContainerLowColor,
                secondaryContainerColor,
                primaryColor,
                secondaryColor,
                onSurfaceColor,
                onSurfaceVariantColor,
                outlineVariantColor,
              ),
              const SizedBox(height: 20),
              _buildDealMetricsBanner(
                isDark,
                surfaceContainerLowestColor,
                primaryColor,
                onSurfaceColor,
                onSurfaceVariantColor,
                outlineVariantColor,
              ),
              const SizedBox(height: 24),
              _buildTimelineSection(
                isDark,
                surfaceContainerLowestColor,
                surfaceContainerLowColor,
                surfaceContainerHighColor,
                primaryColor,
                primaryContainerColor,
                primaryFixedColor,
                secondaryColor,
                secondaryContainerColor,
                onSurfaceColor,
                onSurfaceVariantColor,
                outlineVariantColor,
                onPrimaryContainerColor,
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 14,
                    bottom: MediaQuery.of(context).padding.bottom > 0 ? MediaQuery.of(context).padding.bottom + 14 : 16,
                  ),
                  decoration: BoxDecoration(
                    color: surfaceColor.withValues(alpha: 0.92),
                    border: Border(top: BorderSide(color: outlineVariantColor.withValues(alpha: 0.5))),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: ElevatedButton(
                          onPressed: () async {
                            try {
                              final pdfBytes = await PdfInvoiceService.generateInvoice(negotiation);
                              await Printing.layoutPdf(
                                onLayout: (format) async => pdfBytes,
                                name: 'comprobante_${negotiation['invoice_id'] ?? 'factura'}.pdf',
                              );
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error al generar PDF: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark ? AppTheme.primaryLight : AppTheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 4,
                            shadowColor: primaryColor.withValues(alpha: 0.3),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.download_rounded, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'COMPROBANTE',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 1,
                        child: ElevatedButton(
                          onPressed: () {
                            context.push('/pdf_preview', extra: negotiation);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark ? surfaceContainerLowColor : const Color(0xFFE5F1EB),
                            foregroundColor: primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(color: outlineVariantColor.withValues(alpha: 0.5)),
                            ),
                            elevation: 0,
                          ),
                          child: const Icon(Icons.receipt_long_rounded, size: 22),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(Color primaryColor, Color primaryContainerColor, Color primaryFixedColor) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF015237),
            primaryContainerColor,
            const Color(0xFF013B28),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: primaryContainerColor.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -30,
            bottom: -30,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    primaryFixedColor.withValues(alpha: 0.22),
                    primaryFixedColor.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: primaryFixedColor.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified_rounded, color: primaryFixedColor, size: 14),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                '¡TRATO HECHO CON ÉXITO!',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                  color: primaryFixedColor,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        negotiation['invoice_id'] ?? '#FAC-88290',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white.withValues(alpha: 0.9),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'INVERSIÓN FINAL ACORDADA',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: primaryFixedColor.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  negotiation['total'] ?? '\$6,750.00',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.event_available_rounded, size: 15, color: primaryFixedColor.withValues(alpha: 0.85)),
                    const SizedBox(width: 6),
                    Text(
                      '${negotiation['date'] ?? '12 Oct 2023'} • ${negotiation['time'] ?? '10:45 AM'}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductPartnerCard(
    BuildContext ctx,
    bool isDark,
    Color surfaceContainerLowestColor,
    Color surfaceContainerLowColor,
    Color secondaryContainerColor,
    Color primaryColor,
    Color secondaryColor,
    Color onSurfaceColor,
    Color onSurfaceVariantColor,
    Color outlineVariantColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surfaceContainerLowestColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: outlineVariantColor.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: outlineVariantColor.withValues(alpha: 0.4)),
                  image: negotiation['image'] != null && negotiation['image'].toString().isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(negotiation['image']),
                          fit: BoxFit.cover,
                        )
                      : null,
                  color: surfaceContainerLowColor,
                ),
                child: negotiation['image'] == null || negotiation['image'].toString().isEmpty
                    ? Icon(Icons.inventory_2_outlined, color: outlineVariantColor)
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      negotiation['product'] ?? 'Tomates Cherry Orgánicos',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: onSurfaceColor,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Detalle del acuerdo mutuo',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: onSurfaceVariantColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Fresh harvest guarantee pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E382E) : const Color(0xFFEBF7F0),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isDark ? const Color(0xFF2E5E4A) : const Color(0xFFC7EBD4)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.eco_rounded,
                  size: 16,
                  color: isDark ? const Color(0xFF89D6B0) : AppTheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Cosecha directa • Calidad garantizada en entrega',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFF89D6B0) : AppTheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: surfaceContainerLowColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: outlineVariantColor.withValues(alpha: 0.4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PRECIO POR KG',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: onSurfaceVariantColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        negotiation['price'] ?? '\$45.00 / kg',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: surfaceContainerLowColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: outlineVariantColor.withValues(alpha: 0.4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'VOLUMEN TOTAL',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: onSurfaceVariantColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        negotiation['quantity'] ?? '150 kg',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: onSurfaceColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E382E) : const Color(0xFFF3F7F2),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: outlineVariantColor.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: surfaceContainerLowColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 4,
                      )
                    ],
                    image: (negotiation['avatar'] != null && negotiation['avatar'].toString().isNotEmpty)
                        ? DecorationImage(
                            image: NetworkImage(negotiation['avatar']),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: (negotiation['avatar'] == null || negotiation['avatar'].toString().isEmpty)
                      ? Icon(Icons.person_rounded, color: primaryColor, size: 22)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (negotiation['role'] ?? 'Comprador').toString().toUpperCase(),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: onSurfaceVariantColor,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              (negotiation['buyer'] ?? 'Juan Pérez').split(' • ').first,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: onSurfaceColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.verified_rounded, color: primaryColor, size: 16),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: surfaceContainerLowestColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: outlineVariantColor.withValues(alpha: 0.5)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                      )
                    ],
                  ),
                  child: IconButton(
                    icon: Icon(Icons.chat_outlined, color: primaryColor, size: 20),
                    onPressed: () => ctx.push('/chat-detail'),
                    padding: const EdgeInsets.all(9),
                    constraints: const BoxConstraints(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Inspired by the 3-column community banner from user reference
  Widget _buildDealMetricsBanner(
    bool isDark,
    Color surfaceContainerLowestColor,
    Color primaryColor,
    Color onSurfaceColor,
    Color onSurfaceVariantColor,
    Color outlineVariantColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceContainerLowestColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: outlineVariantColor.withValues(alpha: 0.6)),
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
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF332918) : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.handshake_outlined,
                  color: isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Trazabilidad del Acuerdo Bilateral',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: onSurfaceColor,
                      ),
                    ),
                    Text(
                      'Condiciones pactadas sin intermediarios',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: onSurfaceVariantColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E382E) : const Color(0xFFF3F6EC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: outlineVariantColor.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildMetricItem(
                    isDark,
                    negotiation['quantity'] ?? '150 kg',
                    'Volumen pactado',
                    primaryColor,
                    onSurfaceVariantColor,
                  ),
                ),
                Container(
                  width: 1,
                  height: 36,
                  color: outlineVariantColor.withValues(alpha: 0.5),
                ),
                Expanded(
                  child: _buildMetricItem(
                    isDark,
                    negotiation['price']?.toString().split(' ').first ?? '\$45.00',
                    'Precio final',
                    isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309),
                    onSurfaceVariantColor,
                  ),
                ),
                Container(
                  width: 1,
                  height: 36,
                  color: outlineVariantColor.withValues(alpha: 0.5),
                ),
                Expanded(
                  child: _buildMetricItem(
                    isDark,
                    '100%',
                    'Trato directo',
                    primaryColor,
                    onSurfaceVariantColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(
    bool isDark,
    String value,
    String label,
    Color valueColor,
    Color labelColor,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: valueColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: labelColor,
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineSection(
    bool isDark,
    Color surfaceContainerLowestColor,
    Color surfaceContainerLowColor,
    Color surfaceContainerHighColor,
    Color primaryColor,
    Color primaryContainerColor,
    Color primaryFixedColor,
    Color secondaryColor,
    Color secondaryContainerColor,
    Color onSurfaceColor,
    Color onSurfaceVariantColor,
    Color outlineVariantColor,
    Color onPrimaryContainerColor,
  ) {
    final buyerName = (negotiation['buyer'] ?? 'Juan Pérez').toString().split(' ').first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Text(
            'Tu progreso con $buyerName',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: onSurfaceColor,
              letterSpacing: -0.5,
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Mini Radar / Visual Bar inspired by the user's snippet
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF16382A), const Color(0xFF263820), const Color(0xFF16382A)]
                  : [const Color(0xFFE3F7EB), const Color(0xFFFEF7E5), const Color(0xFFE9F8EE)],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? const Color(0xFF2E6348) : const Color(0xFFA7E8C3),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withValues(alpha: 0.6),
                            blurRadius: 6,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Estado: ',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: onSurfaceColor,
                              ),
                            ),
                            TextSpan(
                              text: 'Trato Concluido',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF162B23) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? const Color(0xFF2E6348) : const Color(0xFFC7EBD4),
                  ),
                ),
                child: Text(
                  '4 de 4 hitos logrados',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Traceability vertical connected timeline
        _buildConnectedTimeline(
          isDark: isDark,
          buyerName: buyerName,
          surfaceLowest: surfaceContainerLowestColor,
          surfaceLow: surfaceContainerLowColor,
          primaryColor: primaryColor,
          primaryContainerColor: primaryContainerColor,
          onSurfaceColor: onSurfaceColor,
          onSurfaceVariantColor: onSurfaceVariantColor,
          outlineVariant: outlineVariantColor,
        ),
      ],
    );
  }

  Widget _buildConnectedTimeline({
    required bool isDark,
    required String buyerName,
    required Color surfaceLowest,
    required Color surfaceLow,
    required Color primaryColor,
    required Color primaryContainerColor,
    required Color onSurfaceColor,
    required Color onSurfaceVariantColor,
    required Color outlineVariant,
  }) {
    final steps = [
      _TimelineStepData(
        stepNumber: '1',
        title: 'Solicitud inicial recibida',
        roleLabel: '$buyerName (Comprador)',
        time: '10:00 AM',
        icon: Icons.send_rounded,
        iconBg: isDark ? const Color(0xFF352B1E) : const Color(0xFFFEF3C7),
        iconColor: isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309),
        content: RichText(
          text: TextSpan(
            style: GoogleFonts.plusJakartaSans(fontSize: 13, color: onSurfaceColor),
            children: [
              TextSpan(text: '$buyerName envió la solicitud de compra por '),
              const TextSpan(text: '\$50.00 / kg', style: TextStyle(fontWeight: FontWeight.bold)),
              const TextSpan(text: ' solicitando disponibilidad del lote.'),
            ],
          ),
        ),
        statusBadge: 'Recibido',
        statusBadgeColor: isDark ? const Color(0xFF352B1E) : const Color(0xFFFEF3C7),
        statusTextColor: isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309),
      ),
      _TimelineStepData(
        stepNumber: '2',
        title: 'Contraoferta enviada',
        roleLabel: 'Tú (Proveedor)',
        time: '10:15 AM',
        icon: Icons.sync_alt_rounded,
        iconBg: isDark ? const Color(0xFF1D323F) : const Color(0xFFE0F2FE),
        iconColor: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
        content: RichText(
          text: TextSpan(
            style: GoogleFonts.plusJakartaSans(fontSize: 13, color: onSurfaceColor),
            children: const [
              TextSpan(text: 'Propusiste un ajuste a '),
              TextSpan(text: '\$48.00 / kg', style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: ' para asegurar costos de cosecha y selección fresca.'),
            ],
          ),
        ),
        statusBadge: 'Ajustado',
        statusBadgeColor: isDark ? const Color(0xFF1D323F) : const Color(0xFFE0F2FE),
        statusTextColor: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
      ),
      _TimelineStepData(
        stepNumber: '3',
        title: 'Negociación por volumen',
        roleLabel: '$buyerName (Comprador)',
        time: '10:30 AM',
        icon: Icons.chat_bubble_outline_rounded,
        iconBg: isDark ? const Color(0xFF1E382E) : const Color(0xFFE0F2FE),
        iconColor: primaryColor,
        content: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: surfaceLow,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: outlineVariant.withValues(alpha: 0.4)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.format_quote_rounded, size: 18, color: primaryColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '"¿Podemos cerrar en \$45.00 si compro el lote completo de 150 kg?"',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w600,
                    color: onSurfaceColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        statusBadge: 'Propuesta final',
        statusBadgeColor: isDark ? const Color(0xFF1E382E) : const Color(0xFFE8F5E9),
        statusTextColor: primaryColor,
      ),
      _TimelineStepData(
        stepNumber: '4',
        title: '¡Trato cerrado con éxito!',
        roleLabel: 'Acuerdo bilateral',
        time: '10:45 AM',
        icon: Icons.check_circle_rounded,
        iconBg: isDark ? primaryColor : AppTheme.primary,
        iconColor: Colors.white,
        isCompleted: true,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¡Acuerdo aceptado! Ambos cerraron el trato en \$45.00 / kg por 150 kg (Total: \$6,750.00).',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: onSurfaceColor,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E382E) : const Color(0xFFEBF7F0),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark ? const Color(0xFF2E6348) : const Color(0xFFA7E8C3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.receipt_long_rounded, size: 14, color: primaryColor),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'Folio: ${negotiation['invoice_id'] ?? '#FAC-88290'}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: primaryColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        statusBadge: 'Cerrado ✓',
        statusBadgeColor: isDark ? const Color(0xFF1E382E) : const Color(0xFFD1FAE5),
        statusTextColor: primaryColor,
      ),
    ];

    return Column(
      children: steps.asMap().entries.map((entry) {
        final index = entry.key;
        final step = entry.value;
        final isFirst = index == 0;
        final isLast = index == steps.length - 1;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Column for the vertical connector line & node
              SizedBox(
                width: 38,
                child: Column(
                  children: [
                    // Top line
                    Container(
                      width: 2.5,
                      height: 12,
                      color: isFirst
                          ? Colors.transparent
                          : (step.isCompleted ? primaryColor : outlineVariant),
                    ),
                    // Circle node
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: step.iconBg,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: step.isCompleted ? primaryColor : outlineVariant.withValues(alpha: 0.6),
                          width: 2,
                        ),
                        boxShadow: [
                          if (step.isCompleted)
                            BoxShadow(
                              color: primaryColor.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                        ],
                      ),
                      child: Icon(step.icon, size: 17, color: step.iconColor),
                    ),
                    // Bottom line
                    Expanded(
                      child: Container(
                        width: 2.5,
                        color: isLast
                            ? Colors.transparent
                            : (step.isCompleted ? primaryColor : outlineVariant),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Step Card
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: surfaceLowest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: step.isCompleted
                            ? primaryColor.withValues(alpha: 0.5)
                            : outlineVariant.withValues(alpha: 0.6),
                        width: step.isCompleted ? 1.5 : 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Card Header: Step title & Time
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                step.title,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: onSurfaceColor,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              step.time,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: onSurfaceVariantColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // Role pill & status badge
                        Row(
                          children: [
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                                decoration: BoxDecoration(
                                  color: surfaceLow,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: outlineVariant.withValues(alpha: 0.4)),
                                ),
                                child: Text(
                                  step.roleLabel,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: onSurfaceVariantColor,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                              decoration: BoxDecoration(
                                color: step.statusBadgeColor,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                step.statusBadge,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: step.statusTextColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        step.content,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _TimelineStepData {
  final String stepNumber;
  final String title;
  final String roleLabel;
  final String time;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final Widget content;
  final String statusBadge;
  final Color statusBadgeColor;
  final Color statusTextColor;
  final bool isCompleted;

  _TimelineStepData({
    required this.stepNumber,
    required this.title,
    required this.roleLabel,
    required this.time,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.content,
    required this.statusBadge,
    required this.statusBadgeColor,
    required this.statusTextColor,
    this.isCompleted = false,
  });
}
