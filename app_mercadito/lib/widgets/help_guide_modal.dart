import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

/// Modelo de paso para las guías visuales de ayuda.
class HelpGuideStep {
  final int stepNumber;
  final String title;
  final String description;
  final IconData icon;
  final String? chipLabel;

  const HelpGuideStep({
    required this.stepNumber,
    required this.title,
    required this.description,
    required this.icon,
    this.chipLabel,
  });
}

/// Modal Bottom Sheet visual que explica de forma interactiva y concisa
/// los procesos operativos clave de App Mercadito.
class HelpGuideModal extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData headerIcon;
  final String? badgeText;
  final Color accentColor;
  final List<String> flowBadges;
  final List<HelpGuideStep> steps;
  final String? primaryActionLabel;
  final VoidCallback? onPrimaryAction;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;
  final Widget? extraWidget;

  const HelpGuideModal({
    super.key,
    required this.title,
    required this.subtitle,
    required this.headerIcon,
    this.badgeText,
    this.accentColor = const Color(0xFF016042),
    this.flowBadges = const [],
    required this.steps,
    this.primaryActionLabel,
    this.onPrimaryAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.extraWidget,
  });

  /// Muestra el modal con diseño adaptativo y scroll suave.
  static Future<void> show({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData headerIcon,
    String? badgeText,
    Color accentColor = const Color(0xFF016042),
    List<String> flowBadges = const [],
    required List<HelpGuideStep> steps,
    String? primaryActionLabel,
    VoidCallback? onPrimaryAction,
    String? secondaryActionLabel,
    VoidCallback? onSecondaryAction,
    Widget? extraWidget,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => HelpGuideModal(
        title: title,
        subtitle: subtitle,
        headerIcon: headerIcon,
        badgeText: badgeText,
        accentColor: accentColor,
        flowBadges: flowBadges,
        steps: steps,
        primaryActionLabel: primaryActionLabel,
        onPrimaryAction: onPrimaryAction,
        secondaryActionLabel: secondaryActionLabel,
        onSecondaryAction: onSecondaryAction,
        extraWidget: extraWidget,
      ),
    );
  }

  // --- GUÍAS PREDEFINIDAS PARA LOS PROCESOS PRINCIPALES ---

  /// Guía paso a paso para Compradores
  static void showBuyerGuide(BuildContext context) {
    show(
      context: context,
      title: 'Guía para Compradores',
      subtitle: 'Aprende a encontrar cosechas frescas, negociar precios justos y rastrear tus pedidos.',
      headerIcon: Icons.shopping_basket_rounded,
      accentColor: const Color(0xFF016042),
      flowBadges: ['1. Explorar', '2. Ofertar', '3. Negociar', '4. Cerrar Trato'],
      steps: const [
        HelpGuideStep(
          stepNumber: 1,
          title: 'Explora en el Mapa y Catálogo',
          description: 'Usa el mapa geolocalizado o el catálogo con filtros de calidad (1ra, 2da y 3ra) para encontrar productores locales directos.',
          icon: Icons.map_outlined,
        ),
        HelpGuideStep(
          stepNumber: 2,
          title: 'Propón tu Oferta o Volumen',
          description: 'Ingresa a la ficha del producto o inicia un chat. Define los kg o libras deseadas y el precio unitario sugerido.',
          icon: Icons.local_offer_outlined,
        ),
        HelpGuideStep(
          stepNumber: 3,
          title: 'Negocia Precio y Condiciones',
          description: 'Conversa directamente con el vendedor en el chat para ajustar precios por volumen, formas de pago y fecha de entrega.',
          icon: Icons.forum_outlined,
        ),
        HelpGuideStep(
          stepNumber: 4,
          title: 'Cierra el Acuerdo y Comprobante',
          description: 'Al llegar a un acuerdo con el vendedor, se genera automáticamente el comprobante oficial en PDF con número correlativo.',
          icon: Icons.picture_as_pdf_outlined,
        ),
      ],
    );
  }

  /// Guía paso a paso para Vendedores y Productores
  static void showSellerGuide(BuildContext context) {
    show(
      context: context,
      title: 'Guía para Vendedores',
      subtitle: 'Publica tus cosechas con inteligencia de precios, gestiona ofertas y formaliza acuerdos.',
      headerIcon: Icons.storefront_rounded,
      accentColor: const Color(0xFF016042),
      flowBadges: ['1. Publicar', '2. Contraofertar', '3. Negociar', '4. Facturar'],
      steps: const [
        HelpGuideStep(
          stepNumber: 1,
          title: 'Publica con Catálogo Estandarizado',
          description: 'Elige tu producto del catálogo oficial. La app te sugerirá precios de mercado mayorista y minorista de referencia.',
          icon: Icons.add_business_outlined,
        ),
        HelpGuideStep(
          stepNumber: 2,
          title: 'Gestiona Ofertas y Contraofertas',
          description: 'Revisa las propuestas de los compradores en la pestaña de Negociaciones. Puedes aceptar de inmediato o enviar una contrapropuesta.',
          icon: Icons.swap_horiz_rounded,
        ),
        HelpGuideStep(
          stepNumber: 3,
          title: 'Negocia Precios y Condiciones',
          description: 'Coordina directamente con el comprador en el chat para ajustar cantidades, precios acordados y la logística de entrega.',
          icon: Icons.forum_outlined,
        ),
        HelpGuideStep(
          stepNumber: 4,
          title: 'Factura y Emite el Comprobante',
          description: 'Cada trato cerrado cuenta con un comprobante formal con tus datos fiscales/comerciales, subtotal, descuentos y total neto.',
          icon: Icons.receipt_long_outlined,
        ),
      ],
    );
  }

  /// Guía de Seguridad y Denuncias
  static void showSecurityGuide(BuildContext context) {
    show(
      context: context,
      title: 'Seguridad y Denuncias',
      subtitle: 'Garantías de confianza, verificación comercial y protección para todos los miembros.',
      headerIcon: Icons.gpp_maybe_rounded,
      accentColor: const Color(0xFF016042),
      steps: const [
        HelpGuideStep(
          stepNumber: 1,
          title: 'Verificación de Identidad y Negocio',
          description: 'Sube tu documento de identidad o RNC en Verificación Comercial para recibir la insignia de verificación que avala tu credibilidad.',
          icon: Icons.verified_user_outlined,
        ),
        HelpGuideStep(
          stepNumber: 2,
          title: 'Comprobante Oficial Vinculante',
          description: 'Todas las transacciones quedan selladas en un documento PDF con folio único que sirve de respaldo formal entre ambas partes.',
          icon: Icons.policy_outlined,
        ),
        HelpGuideStep(
          stepNumber: 3,
          title: 'Seguridad de Cuenta con 2FA',
          description: 'Refuerza tu acceso activando la autenticación de dos factores por SMS, correo electrónico o Google Authenticator.',
          icon: Icons.lock_outline_rounded,
        ),
        HelpGuideStep(
          stepNumber: 4,
          title: 'Canal de Denuncias Directo',
          description: 'Si observas fraude, producto en mal estado o incumplimiento de entrega, puedes abrir un reporte formal con pruebas adjuntas.',
          icon: Icons.report_problem_outlined,
        ),
      ],
    );
  }

  /// Guía de Preguntas Frecuentes Interactiva
  static void showFaqGuide(BuildContext context) {
    show(
      context: context,
      title: 'Preguntas Frecuentes',
      subtitle: 'Respuestas directas a las dudas más comunes sobre compras, ventas y seguridad.',
      headerIcon: Icons.quiz_rounded,
      accentColor: const Color(0xFF016042),
      steps: const [
        HelpGuideStep(
          stepNumber: 1,
          title: '¿Tiene algún costo publicar productos?',
          description: 'No, publicar tus cosechas y productos en Mercadito es totalmente libre. Solo acuerdas precios y volúmenes con compradores.',
          icon: Icons.money_off_csred_outlined,
        ),
        HelpGuideStep(
          stepNumber: 2,
          title: '¿Qué significa la calidad 1ra, 2da y 3ra?',
          description: '1ra es calidad premium estética; 2da tiene pequeñas imperfecciones visuales con el mismo sabor; 3ra es para procesamiento o jugos.',
          icon: Icons.eco_outlined,
        ),
        HelpGuideStep(
          stepNumber: 3,
          title: '¿Cómo se garantiza la entrega del producto?',
          description: 'Cada trato cerrado incluye un comprobante PDF con datos del productor y comprador, además de un seguimiento de 4 hitos.',
          icon: Icons.verified_outlined,
        ),
        HelpGuideStep(
          stepNumber: 4,
          title: '¿Puedo solicitar una muestra antes de compras grandes?',
          description: 'Sí, a través del chat puedes acordar con el productor el envío de un lote de muestra previo a cerrar compras por volumen.',
          icon: Icons.chat_bubble_outline_rounded,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final sheetBg = isDark ? const Color(0xFF0F231D) : Colors.white;
    final cardBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC);
    final textHeader = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A);
    final subtext = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0);

    return DraggableScrollableSheet(
      initialChildSize: 0.82,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: sheetBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 25,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: Column(
            children: [
              // Barra de arrastre superior
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              // Contenido con scroll
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  children: [
                    // Encabezado
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: isDark ? 0.2 : 0.12),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: accentColor.withValues(alpha: 0.25)),
                          ),
                          child: Icon(headerIcon, color: accentColor, size: 28),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (badgeText != null && badgeText!.trim().isNotEmpty) ...[
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: accentColor.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        badgeText!.toUpperCase(),
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          color: accentColor,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                              ],
                              Text(
                                title,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: textHeader,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          color: subtext,
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: subtext,
                        height: 1.45,
                      ),
                    ),

                    // Barra visual de flujo (demostración de pasos rápidos)
                    if (flowBadges.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: borderColor),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.route_rounded, size: 14, color: accentColor),
                                const SizedBox(width: 6),
                                Text(
                                  'FLUJO RÁPIDO DEL PROCESO',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.6,
                                    color: accentColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: flowBadges.asMap().entries.map((entry) {
                                final isLast = entry.key == flowBadges.length - 1;
                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: borderColor),
                                      ),
                                      child: Text(
                                        entry.value,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: textHeader,
                                        ),
                                      ),
                                    ),
                                    if (!isLast) ...[
                                      const SizedBox(width: 4),
                                      Icon(Icons.arrow_forward_rounded, size: 12, color: subtext),
                                    ],
                                  ],
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),
                    Text(
                      'PASO A PASO EXPLICATIVO',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                        color: subtext,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Lista de pasos detallados
                    ...steps.map((step) => _buildStepCard(
                          step: step,
                          cardBg: cardBg,
                          borderColor: borderColor,
                          textHeader: textHeader,
                          subtext: subtext,
                          accentColor: accentColor,
                          isDark: isDark,
                        )),

                    if (extraWidget != null) ...[
                      const SizedBox(height: 12),
                      extraWidget!,
                    ],

                    const SizedBox(height: 20),

                    // Botones de acción directa
                    if (primaryActionLabel != null) ...[
                      ElevatedButton(
                        onPressed: onPrimaryAction,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 2,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              primaryActionLabel!,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward_rounded, size: 18),
                          ],
                        ),
                      ),
                    ],

                    if (secondaryActionLabel != null) ...[
                      const SizedBox(height: 10),
                      OutlinedButton(
                        onPressed: onSecondaryAction,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: textHeader,
                          side: BorderSide(color: borderColor),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          secondaryActionLabel!,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStepCard({
    required HelpGuideStep step,
    required Color cardBg,
    required Color borderColor,
    required Color textHeader,
    required Color subtext,
    required Color accentColor,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Número de paso en círculo
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: isDark ? 0.25 : 0.12),
              shape: BoxShape.circle,
              border: Border.all(color: accentColor.withValues(alpha: 0.3)),
            ),
            child: Text(
              '${step.stepNumber}',
              style: GoogleFonts.plusJakartaSans(
                color: accentColor,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Contenido del paso
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(step.icon, size: 16, color: accentColor),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        step.title,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: textHeader,
                        ),
                      ),
                    ),
                    if (step.chipLabel != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          step.chipLabel!,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: subtext,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  step.description,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: subtext,
                    height: 1.45,
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
