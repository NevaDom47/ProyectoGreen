import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/help_guide_modal.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  void _showSupportOptionsSheet(BuildContext context, Color primaryColor, bool isDark) {
    final sheetBg = isDark ? const Color(0xFF0F231D) : Colors.white;
    final cardBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC);
    final textHeader = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A);
    final subtext = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
            decoration: BoxDecoration(
          color: sheetBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 20,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.support_agent_rounded, color: primaryColor, size: 26),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Canales de Atención Directa',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textHeader,
                        ),
                      ),
                      Text(
                        'Respuesta rápida de nuestro equipo humano',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: subtext,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  color: subtext,
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Opción 1: Chat asistido en la app
            _buildContactOption(
              icon: Icons.chat_bubble_outline_rounded,
              title: 'Chat con Asesor en la App',
              subtitle: 'Atención técnica y comercial en tiempo real',
              cardBg: cardBg,
              borderColor: borderColor,
              textHeader: textHeader,
              subtext: subtext,
              primaryColor: primaryColor,
              onTap: () {
                Navigator.pop(ctx);
                context.push('/chat-detail', extra: {
                  'name': 'Soporte Técnico Mercadito',
                  'id': 'SUPPORT_ADMIN',
                  'role': 'soporte',
                });
              },
            ),

            const SizedBox(height: 10),

            // Opción 2: Línea telefónica y WhatsApp
            _buildContactOption(
              icon: Icons.phone_in_talk_outlined,
              title: 'Línea Directa / WhatsApp',
              subtitle: '+1 (829) 942-1923 (Toca para copiar)',
              cardBg: cardBg,
              borderColor: borderColor,
              textHeader: textHeader,
              subtext: subtext,
              primaryColor: primaryColor,
              onTap: () {
                Clipboard.setData(const ClipboardData(text: '+18299421923'));
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Número de Soporte copiado al portapapeles (+1 829-942-1923)',
                      style: GoogleFonts.plusJakartaSans(),
                    ),
                    backgroundColor: primaryColor,
                    duration: const Duration(seconds: 3),
                  ),
                );
              },
            ),

            const SizedBox(height: 10),

            // Opción 3: Canal formal de denuncias
            _buildContactOption(
              icon: Icons.shield_outlined,
              title: 'Centro de Denuncias y Reportes',
              subtitle: 'Informa sobre incumplimientos, fraudes o anomalías',
              cardBg: cardBg,
              borderColor: borderColor,
              textHeader: textHeader,
              subtext: subtext,
              primaryColor: const Color(0xFFDC2626),
              onTap: () {
                Navigator.pop(ctx);
                context.push('/reports');
              },
            ),
          ],
        ),
      ),
    ),
  ),
);
  }

  Widget _buildContactOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color cardBg,
    required Color borderColor,
    required Color textHeader,
    required Color subtext,
    required Color primaryColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: primaryColor, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: textHeader,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: subtext,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, size: 14, color: subtext),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF0F231D) : const Color(0xFFF5F8F7);
    final surfaceColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    const primaryColor = Color(0xFF016042);
    final textHeaderColor = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A);
    const subtextColor = Color(0xFF64748B);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor.withValues(alpha: 0.8),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Ayuda y Soporte',
          style: GoogleFonts.plusJakartaSans(
            color: textHeaderColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Grid de Categorías (4 opciones interactivas)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CATEGORÍAS DE AYUDA',
                      style: GoogleFonts.plusJakartaSans(
                        color: subtextColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 2.3,
                      children: [
                        _buildCategoryCard(
                          context,
                          title: 'Preguntas Frecuentes',
                          icon: Icons.quiz,
                          primaryColor: primaryColor,
                          surfaceColor: surfaceColor,
                          isDark: isDark,
                          onTap: () => HelpGuideModal.showFaqGuide(context),
                        ),
                        _buildCategoryCard(
                          context,
                          title: 'Guía para Compradores',
                          icon: Icons.shopping_basket,
                          primaryColor: primaryColor,
                          surfaceColor: surfaceColor,
                          isDark: isDark,
                          onTap: () => HelpGuideModal.showBuyerGuide(context),
                        ),
                        _buildCategoryCard(
                          context,
                          title: 'Guía para Vendedores',
                          icon: Icons.storefront,
                          primaryColor: primaryColor,
                          surfaceColor: surfaceColor,
                          isDark: isDark,
                          onTap: () => HelpGuideModal.showSellerGuide(context),
                        ),
                        _buildCategoryCard(
                          context,
                          title: 'Seguridad y Denuncias',
                          icon: Icons.gpp_maybe,
                          primaryColor: primaryColor,
                          surfaceColor: surfaceColor,
                          isDark: isDark,
                          onTap: () => HelpGuideModal.showSecurityGuide(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Sección Consultas Populares (Con demostración y pasos visuales)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CONSULTAS POPULARES',
                      style: GoogleFonts.plusJakartaSans(
                        color: subtextColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Consulta 1: ¿Cómo negociar un precio?
                    _buildDetailedFaqTile(
                      context: context,
                      question: '¿Cómo negociar un precio?',
                      answer:
                          'Puedes usar la función de "Oferta" directamente en el chat con el vendedor para proponer un precio justo basado en el volumen de compra.',
                      steps: const [
                        '1. Toca "Negociar / Ofertar" en el producto o chat.',
                        '2. Propón el volumen (kg/lb) y tu precio unitario.',
                        '3. Al acordar, se genera el comprobante PDF oficial.',
                      ],
                      actionLabel: 'Ir a Mis Negociaciones',
                      onAction: () => context.push('/negotiations'),
                      guideLabel: 'Ver Guía Completa de Compra',
                      onGuide: () => HelpGuideModal.showBuyerGuide(context),
                      primaryColor: primaryColor,
                      surfaceColor: surfaceColor,
                      isDark: isDark,
                    ),

                    const SizedBox(height: 12),

                    // Consulta 2: ¿Cómo rastrear mi pedido?
                    _buildDetailedFaqTile(
                      context: context,
                      question: '¿Cómo rastrear mi pedido?',
                      answer:
                          'En la sección "Mis Pedidos", selecciona el acuerdo activo para ver la trazabilidad de los 4 hitos en tiempo real.',
                      steps: const [
                        '1. Entra a "Historial de Pedidos" desde tu perfil.',
                        '2. Selecciona el pedido con estado "En preparación" o "En ruta".',
                        '3. Visualiza la línea de tiempo: Pactado ➔ Cosechado ➔ En camino ➔ Entregado.',
                      ],
                      actionLabel: 'Ver Historial de Pedidos',
                      onAction: () => context.push('/order-history'),
                      guideLabel: 'Ver Guía de Trazabilidad',
                      onGuide: () => HelpGuideModal.showBuyerGuide(context),
                      primaryColor: primaryColor,
                      surfaceColor: surfaceColor,
                      isDark: isDark,
                    ),

                    const SizedBox(height: 12),

                    // Consulta 3: Métodos de pago aceptados
                    _buildDetailedFaqTile(
                      context: context,
                      question: 'Métodos de pago aceptados',
                      answer:
                          'Aceptamos transferencias bancarias directas, tarjetas de débito/crédito y pagos en efectivo contra entrega acordada.',
                      steps: const [
                        '🏦 Transferencia bancaria (adjuntas comprobante de depósito).',
                        '💳 Tarjeta débito o crédito (procesamiento seguro e inmediato).',
                        '💵 Efectivo contra entrega (al recibir y verificar la cosecha).',
                      ],
                      extraNote:
                          '🛡️ Toda transacción está respaldada por el Comprobante Oficial en PDF con N° correlativo.',
                      actionLabel: 'Ver Políticas Comerciales',
                      onAction: () => context.push('/legal-policies'),
                      guideLabel: 'Ver Garantías de Seguridad',
                      onGuide: () => HelpGuideModal.showSecurityGuide(context),
                      primaryColor: primaryColor,
                      surfaceColor: surfaceColor,
                      isDark: isDark,
                    ),

                    const SizedBox(height: 12),

                    // Consulta 4: ¿Cómo descargar el comprobante oficial?
                    _buildDetailedFaqTile(
                      context: context,
                      question: '¿Cómo descargar el comprobante de un trato?',
                      answer:
                          'Al concluir cualquier negociación, se emite un comprobante formal con los datos del proveedor, comprador, precios y totales.',
                      steps: const [
                        '1. Ingresa a "Negociaciones" y selecciona el trato cerrado.',
                        '2. Presiona el botón verde "COMPROBANTE" o el icono de previsualización.',
                        '3. Guarda o imprime el documento PDF directamente en tu teléfono.',
                      ],
                      actionLabel: 'Ver Mis Negociaciones',
                      onAction: () => context.push('/negotiations'),
                      guideLabel: 'Ver Guía de Venta y Factura',
                      onGuide: () => HelpGuideModal.showSellerGuide(context),
                      primaryColor: primaryColor,
                      surfaceColor: surfaceColor,
                      isDark: isDark,
                    ),

                    const SizedBox(height: 12),

                    // Consulta 5: ¿Cómo verificar mi negocio para vender?
                    _buildDetailedFaqTile(
                      context: context,
                      question: '¿Cómo verificar mi negocio o perfil?',
                      answer:
                          'La verificación comercial te otorga un sello de confianza verde visible para todos los compradores en el mercado.',
                      steps: const [
                        '1. Ve a tu Perfil y toca "Verificación Comercial".',
                        '2. Sube foto de tu Cédula o RNC y comprobante de dirección.',
                        '3. Nuestro equipo valida tus credenciales en menos de 24 horas.',
                      ],
                      actionLabel: 'Iniciar Verificación',
                      onAction: () => context.push('/business-verification'),
                      guideLabel: 'Ver Requisitos de Seguridad',
                      onGuide: () => HelpGuideModal.showSecurityGuide(context),
                      primaryColor: primaryColor,
                      surfaceColor: surfaceColor,
                      isDark: isDark,
                    ),
                  ],
                ),
              ),

              // Tarjeta de Contacto / Soporte Humano
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Brillo superior derecho
                      Positioned(
                        right: -50,
                        top: -50,
                        child: Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '¿Necesitas hablar con nosotros?',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Nuestro equipo de soporte técnico está disponible 24/7 para ayudarte con lo que necesites.',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.forum_rounded, size: 20),
                              label: Text(
                                'Chat en vivo',
                                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              onPressed: () => _showSupportOptionsSheet(context, primaryColor, isDark),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: primaryColor,
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                elevation: 0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Redes Sociales Bottom
              Padding(
                padding: const EdgeInsets.only(bottom: 32, top: 12),
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        'Síguenos en nuestras redes',
                        style: GoogleFonts.plusJakartaSans(
                          color: subtextColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.facebook, color: subtextColor),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Mercadito Oficial en Facebook', style: GoogleFonts.plusJakartaSans()),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.camera_alt_outlined, color: subtextColor),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Mercadito Oficial en Instagram', style: GoogleFonts.plusJakartaSans()),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.share, color: subtextColor),
                            onPressed: () {
                              Clipboard.setData(const ClipboardData(text: 'https://diaztecnologies.es'));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Enlace oficial copiado: diaztecnologies.es', style: GoogleFonts.plusJakartaSans()),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
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
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color primaryColor,
    required Color surfaceColor,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryColor.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: primaryColor, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailedFaqTile({
    required BuildContext context,
    required String question,
    required String answer,
    required List<String> steps,
    String? extraNote,
    required String actionLabel,
    required VoidCallback onAction,
    String? guideLabel,
    VoidCallback? onGuide,
    required Color primaryColor,
    required Color surfaceColor,
    required bool isDark,
  }) {
    final subtext = isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569);
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0);

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryColor.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: primaryColor,
          collapsedIconColor: primaryColor,
          tilePadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          title: Text(
            question,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    answer,
                    style: GoogleFonts.plusJakartaSans(
                      color: subtext,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),

                  // Pasos demostrativos numerados
                  if (steps.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFF1F5F3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.bolt_rounded, size: 14, color: primaryColor),
                              const SizedBox(width: 6),
                              Text(
                                'PASOS RÁPIDOS:',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: primaryColor,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ...steps.map((st) => Padding(
                                padding: const EdgeInsets.only(bottom: 5),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.check_circle_outline_rounded, size: 14, color: primaryColor),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        st,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                                          height: 1.35,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                        ],
                      ),
                    ),
                  ],

                  if (extraNote != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      extraNote,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                      ),
                    ),
                  ],

                  const SizedBox(height: 14),

                  // Fila de acciones funcionales
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: onAction,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            actionLabel,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      if (guideLabel != null && onGuide != null) ...[
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: onGuide,
                          style: TextButton.styleFrom(
                            foregroundColor: primaryColor,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                          ),
                          child: Text(
                            'Ver guía',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
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
