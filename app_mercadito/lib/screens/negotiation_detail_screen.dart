import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:printing/printing.dart';
import '../services/pdf_invoice_service.dart';

class NegotiationDetailScreen extends StatelessWidget {
  final Map<String, dynamic> negotiation;

  const NegotiationDetailScreen({
    super.key,
    required this.negotiation,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final surfaceColor = isDark ? const Color(0xFF181d1a) : const Color(0xFFf7faf5);
    final surfaceContainerLowestColor = isDark ? const Color(0xFF0f1613) : const Color(0xFFffffff);
    final surfaceContainerLowColor = isDark ? const Color(0xFF15221d) : const Color(0xFFf1f4f0);
    final surfaceContainerHighColor = isDark ? const Color(0xFF29322d) : const Color(0xFFe6e9e4);
    
    final primaryColor = isDark ? const Color(0xFF89d6b0) : const Color(0xFF00462f);
    final primaryContainerColor = isDark ? const Color(0xFF005137) : const Color(0xFF036042);
    final primaryFixedColor = isDark ? const Color(0xFF89d6b0) : const Color(0xFFa5f3cb);
    final onPrimaryContainerColor = isDark ? const Color(0xFF8bd8b2) : const Color(0xFF8bd8b2);
    
    final secondaryColor = isDark ? const Color(0xFFb0ccc0) : const Color(0xFF486456);
    final secondaryContainerColor = isDark ? const Color(0xFF314c3f) : const Color(0xFFcaead7);
    
    final onSurfaceColor = isDark ? const Color(0xFFe0e3df) : const Color(0xFF181d1a);
    final onSurfaceVariantColor = isDark ? const Color(0xFFbec9c1) : const Color(0xFF3f4943);
    final outlineColor = isDark ? const Color(0xFF89938c) : const Color(0xFF6f7a73);
    final outlineVariantColor = isDark ? const Color(0xFF3f4943) : const Color(0xFFbec9c1);

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
                    backgroundColor: Colors.transparent,
                    hoverColor: surfaceContainerHighColor,
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
              const SizedBox(height: 24),
              _buildProductPartnerCard(
                context,
                surfaceContainerLowestColor,
                surfaceContainerLowColor,
                secondaryContainerColor,
                primaryColor,
                secondaryColor,
                onSurfaceColor,
                onSurfaceVariantColor,
                outlineVariantColor,
              ),
              const SizedBox(height: 24),
              _buildTimelineSection(
                surfaceContainerLowestColor,
                surfaceContainerHighColor,
                primaryColor,
                primaryContainerColor,
                primaryFixedColor,
                secondaryColor,
                secondaryContainerColor,
                onSurfaceColor,
                outlineColor,
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
                    top: 16,
                    bottom: MediaQuery.of(context).padding.bottom > 0 ? MediaQuery.of(context).padding.bottom + 16 : 16,
                  ),
                  decoration: BoxDecoration(
                    color: surfaceColor.withValues(alpha: 0.8),
                    border: Border(top: BorderSide(color: outlineVariantColor.withValues(alpha: 0.2))),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
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
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 8,
                            shadowColor: primaryColor.withValues(alpha: 0.4),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.download, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'COMPROBANTE',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
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
                            backgroundColor: surfaceContainerHighColor,
                            foregroundColor: onSurfaceColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: const Icon(Icons.receipt_long),
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
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [primaryColor, primaryContainerColor],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryContainerColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
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
                      primaryFixedColor.withValues(alpha: 0.2),
                      primaryFixedColor.withValues(alpha: 0.0),
                    ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.stars, color: primaryFixedColor, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '¡TRATO HECHO CON ÉXITO!',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.0,
                            color: primaryFixedColor,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      negotiation['invoice_id'] ?? '#FAC0001',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: primaryFixedColor.withValues(alpha: 0.9),
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'INVERSIÓN FINAL ACORDADA',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2.0,
                    color: primaryFixedColor.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  negotiation['total'] ?? '\$6,750.00',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${negotiation['date'] ?? '12 de Octubre, 2023'} • ${negotiation['time'] ?? '10:45 AM'}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: primaryFixedColor.withValues(alpha: 0.9),
                  ),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceContainerLowestColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: outlineVariantColor.withValues(alpha: 0.3)),
                  image: negotiation['image'] != null && negotiation['image'].toString().isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(negotiation['image']),
                          fit: BoxFit.cover,
                        )
                      : null,
                  color: surfaceContainerLowColor,
                ),
                child: negotiation['image'] == null || negotiation['image'].toString().isEmpty
                    ? Icon(Icons.image_not_supported, color: outlineVariantColor)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      negotiation['product'] ?? 'Tomates Cherry Orgánicos',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Detalle del acuerdo mutuo',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: onSurfaceVariantColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: outlineVariantColor.withValues(alpha: 0.2))),
            ),
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: surfaceContainerLowColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PRECIO POR KG',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: secondaryColor,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          negotiation['price'] ?? '\$45.00',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: onSurfaceColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: surfaceContainerLowColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'VOLUMEN TOTAL',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: secondaryColor,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          negotiation['quantity'] ?? '150 kg',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: onSurfaceColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: secondaryContainerColor.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                      )
                    ],
                    image: const DecorationImage(
                      image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuCYzSOjmcWCw65BnWRM8kOutj9cN98FPiXb2yJStvIYIUaeAJrBhYpEHxalCknNyIzC3qcQ0aeErJFU3OGiY7uoNy-L6m69cp_gHHTbByyWIdJV0pCZ1txUPVNAnKX9o-OpyWsiBa-md94KD5KgrI3tmU237PeV6Cz8zBjGnOSVzA3NSwaE9KIK3TKR0xcaQ38DE7WDvluyNKDYzebeilNoNmT_hPl0bhT2eII0wjtZAbTk3LiHnBDx-RmDjHX2sFiQ9B4Qfw2TBrY'),
                      fit: BoxFit.cover,
                    ),
                  ),
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
                          fontWeight: FontWeight.bold,
                          color: secondaryColor,
                          letterSpacing: 2.0,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            (negotiation['buyer'] ?? 'Juan Pérez').split(' • ').first,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: onSurfaceColor,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.verified, color: primaryColor, size: 14),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                      )
                    ],
                  ),
                  child: IconButton(
                    icon: Icon(Icons.chat, color: primaryColor, size: 20),
                    onPressed: () => ctx.push('/chat-detail'),
                    padding: const EdgeInsets.all(8),
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

  Widget _buildTimelineSection(
    Color surfaceContainerLowestColor,
    Color surfaceContainerHighColor,
    Color primaryColor,
    Color primaryContainerColor,
    Color primaryFixedColor,
    Color secondaryColor,
    Color secondaryContainerColor,
    Color onSurfaceColor,
    Color outlineColor,
    Color outlineVariantColor,
    Color onPrimaryContainerColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Text(
            'Tu progreso con ${negotiation['buyer']?.split(' ').first ?? 'Juan'}',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: onSurfaceColor,
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildTimelineItem(
          icon: Icons.request_quote,
          iconColor: secondaryColor,
          iconBgColor: surfaceContainerHighColor,
          time: '10:00 AM',
          timeColor: outlineColor,
          content: RichText(
            text: TextSpan(
              style: GoogleFonts.plusJakartaSans(fontSize: 14, color: onSurfaceColor),
              children: [
                TextSpan(text: '${negotiation['buyer']?.split(' ').first ?? 'Juan'} envió la solicitud inicial por '),
                const TextSpan(text: '\$50.00/kg', style: TextStyle(fontWeight: FontWeight.bold)),
                const TextSpan(text: '.'),
              ],
            ),
          ),
          bgColor: surfaceContainerLowestColor,
          borderColor: outlineVariantColor.withValues(alpha: 0.2),
        ),
        const SizedBox(height: 16),
        _buildTimelineItem(
          icon: Icons.sync_alt,
          iconColor: secondaryColor,
          iconBgColor: surfaceContainerHighColor,
          time: '10:15 AM',
          timeColor: outlineColor,
          content: RichText(
            text: TextSpan(
              style: GoogleFonts.plusJakartaSans(fontSize: 14, color: onSurfaceColor),
              children: const [
                TextSpan(text: 'Propusiste una contraoferta de '),
                TextSpan(text: '\$48.00/kg', style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: ' para ajustar costos.'),
              ],
            ),
          ),
          bgColor: surfaceContainerLowestColor,
          borderColor: outlineVariantColor.withValues(alpha: 0.2),
        ),
        const SizedBox(height: 16),
        _buildTimelineItem(
          icon: Icons.chat_bubble,
          iconColor: primaryColor,
          iconBgColor: secondaryContainerColor.withValues(alpha: 0.5),
          time: '10:30 AM',
          timeColor: primaryColor,
          content: Text(
            '"¿Podemos cerrar en \$45.00 si compro el lote completo?"',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w500,
              color: onSurfaceColor,
            ),
          ),
          bgColor: surfaceContainerLowestColor,
          borderColor: outlineVariantColor.withValues(alpha: 0.2),
          rightIndicatorColor: primaryFixedColor,
        ),
        const SizedBox(height: 16),
        _buildTimelineItem(
          icon: Icons.handshake,
          iconColor: Colors.white,
          iconBgColor: Colors.white.withValues(alpha: 0.2),
          time: '10:45 AM',
          timeColor: onPrimaryContainerColor.withValues(alpha: 0.8),
          content: Text(
            '¡Acuerdo aceptado! Ambos han cerrado el trato satisfactoriamente.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: onPrimaryContainerColor,
            ),
          ),
          bgColor: primaryContainerColor,
          borderColor: Colors.transparent,
          isSuccess: true,
        ),
      ],
    );
  }

  Widget _buildTimelineItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String time,
    required Color timeColor,
    required Widget content,
    required Color bgColor,
    required Color borderColor,
    Color? rightIndicatorColor,
    bool isSuccess = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          if (!isSuccess)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          else
            BoxShadow(
              color: bgColor.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            )
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        time,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: timeColor,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      content,
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (rightIndicatorColor != null)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: 4,
              child: Container(color: rightIndicatorColor),
            ),
        ],
      ),
    );
  }
}
