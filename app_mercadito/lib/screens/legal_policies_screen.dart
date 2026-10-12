import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/legal_policies_data.dart';
import '../main.dart';
import '../services/legal_pdf_service.dart';
import '../widgets/skeleton_loading.dart';

class LegalPoliciesScreen extends StatefulWidget {
  final int initialTabIndex;
  final Future<Uint8List> Function(String assetPath)? customPdfLoader;

  const LegalPoliciesScreen({
    super.key,
    this.initialTabIndex = 0,
    this.customPdfLoader,
  });

  @override
  State<LegalPoliciesScreen> createState() => _LegalPoliciesScreenState();
}

class _LegalPoliciesScreenState extends State<LegalPoliciesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const String _termsAssetPath =
      'assets/documents/Terminos_y_Condiciones_Mercadito.pdf';
  static const String _privacyAssetPath =
      'assets/documents/Politica_de_Privacidad_Mercadito.pdf';

  @override
  void initState() {
    super.initState();
    final initialIndex = widget.initialTabIndex.clamp(0, 1);
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: initialIndex,
    );
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _launchEmail(BuildContext context, String email) async {
    final uri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=${Uri.encodeComponent('Consulta Legal - El Mercadito')}',
    );

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uri);
      }
    } catch (_) {
      await Clipboard.setData(ClipboardData(text: email));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Correo copiado al portapapeles: $email',
                    style: GoogleFonts.plusJakartaSans(fontSize: 13),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF016042),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  void _showLegalContactDialog(BuildContext context, Color primaryColor, Color textColor, Color subtextColor, Color surfaceColor) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            Icon(Icons.help_outline_rounded, color: primaryColor, size: 24),
            const SizedBox(width: 10),
            Text(
              'Contacto Legal',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                fontSize: 17,
                color: textColor,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Para dudas, ejercicio de derechos de privacidad o consultas contractuales con El Mercadito y Diaz Tecnologies:',
              style: GoogleFonts.plusJakartaSans(
                color: subtextColor,
                fontSize: 13.5,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () {
                Navigator.of(ctx).pop();
                _launchEmail(context, LegalPoliciesData.contactEmail);
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: primaryColor.withValues(alpha: 0.25)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.mail_outline, color: primaryColor, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        LegalPoliciesData.contactEmail,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                          fontSize: 13.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cerrar',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w600,
                color: subtextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appThemeMode,
      builder: (context, currentMode, _) {
        final platformBrightness = MediaQuery.platformBrightnessOf(context);
        final isDark = currentMode == ThemeMode.dark ||
            (currentMode == ThemeMode.system &&
                platformBrightness == Brightness.dark);

        final bgColor = isDark ? const Color(0xFF101815) : const Color(0xFFF7F9F8);
        final primaryColor = isDark ? const Color(0xFF67C83B) : const Color(0xFF016042);
        final surfaceColor = isDark ? const Color(0xFF1C2924) : Colors.white;
        final textColor = isDark ? const Color(0xFFF1F5F3) : const Color(0xFF20262B);
        final subtextColor = isDark ? const Color(0xFFAAB8B1) : const Color(0xFF697177);
        final borderColor = isDark ? const Color(0xFF2B3A34) : const Color(0xFFE2E7E4);
        final activeTabBg = isDark ? const Color(0xFF273830) : primaryColor;
        final inactiveTabBg = isDark ? const Color(0xFF141F1A) : const Color(0xFFECEFEA);

        final isTerms = _tabController.index == 0;

        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            backgroundColor: bgColor,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: primaryColor),
              onPressed: () => context.pop(),
            ),
            title: Text(
              'Políticas Legales',
              style: GoogleFonts.plusJakartaSans(
                color: primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            centerTitle: false,
            actions: [
              IconButton(
                tooltip: 'Contacto legal',
                icon: Icon(Icons.help_outline_rounded, color: primaryColor, size: 22),
                onPressed: () => _showLegalContactDialog(
                  context,
                  primaryColor,
                  textColor,
                  subtextColor,
                  surfaceColor,
                ),
              ),
              const SizedBox(width: 4),
            ],
          ),
          body: Column(
            children: [
              // Header Summary Card & Tabs Selector
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                child: Column(
                  children: [
                    // Icon and Entity info
                    Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isTerms ? Icons.gavel_rounded : Icons.privacy_tip_outlined,
                            color: primaryColor,
                            size: 23,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isTerms
                                    ? 'Términos y Condiciones'
                                    : 'Política de Privacidad',
                                style: GoogleFonts.plusJakartaSans(
                                  color: textColor,
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Documento oficial • ${LegalPoliciesData.entityName}',
                                style: GoogleFonts.plusJakartaSans(
                                  color: subtextColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Segmented Tabs Pill Selector
                    Container(
                      height: 44,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: inactiveTabBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildSegmentButton(
                              index: 0,
                              label: 'Términos y Condiciones',
                              icon: Icons.description_outlined,
                              isActive: isTerms,
                              activeColor: activeTabBg,
                              textColor: Colors.white,
                              inactiveTextColor: subtextColor,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: _buildSegmentButton(
                              index: 1,
                              label: 'Política de Privacidad',
                              icon: Icons.shield_outlined,
                              isActive: !isTerms,
                              activeColor: activeTabBg,
                              textColor: Colors.white,
                              inactiveTextColor: subtextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 10, thickness: 1),

              // Embedded PDF Document Viewer
              // Usamos un KeyedSubtree con ValueKey para que al cambiar de pestaña
              // el visor previo se destruya limpiamente y monte el visor activo con
              // su propio Web Worker y buffer independiente (evita DataCloneError en Flutter Web).
              Expanded(
                child: KeyedSubtree(
                  key: ValueKey<int>(_tabController.index),
                  child: _buildActivePdfPreview(
                    isTerms: isTerms,
                    bgColor: bgColor,
                    primaryColor: primaryColor,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSegmentButton({
    required int index,
    required String label,
    required IconData icon,
    required bool isActive,
    required Color activeColor,
    required Color textColor,
    required Color inactiveTextColor,
  }) {
    return GestureDetector(
      onTap: () {
        if (_tabController.index != index) {
          _tabController.animateTo(index);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isActive ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? textColor : inactiveTextColor,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                  color: isActive ? textColor : inactiveTextColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivePdfPreview({
    required bool isTerms,
    required Color bgColor,
    required Color primaryColor,
  }) {
    final fileName = isTerms
        ? 'Terminos_y_Condiciones_Mercadito.pdf'
        : 'Politica_de_Privacidad_Mercadito.pdf';

    return PdfPreview(
      key: ValueKey<String>('pdf_viewer_${isTerms ? 'terms' : 'privacy'}'),
      build: (format) async {
        if (widget.customPdfLoader != null) {
          final path = isTerms ? _termsAssetPath : _privacyAssetPath;
          final raw = await widget.customPdfLoader!(path);
          return Uint8List.fromList(raw);
        }

        // Siempre devuelve una copia fresca en memoria de los bytes
        // para prevenir DataCloneError cuando el Web Worker detacha el ArrayBuffer.
        return isTerms
            ? await LegalPdfService.getTermsPdf()
            : await LegalPdfService.getPrivacyPdf();
      },
      canChangeOrientation: false,
      canChangePageFormat: false,
      canDebug: false,
      maxPageWidth: 720,
      scrollViewDecoration: BoxDecoration(
        color: bgColor,
      ),
      pdfFileName: fileName,
      loadingWidget: _buildPdfLoadingSkeleton(),
    );
  }

  Widget _buildPdfLoadingSkeleton() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SkeletonShimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                SkeletonContainer(width: 160, height: 26, borderRadius: 8),
                SkeletonContainer(width: 90, height: 26, borderRadius: 8),
              ],
            ),
            const SizedBox(height: 20),
            const SkeletonContainer(width: double.infinity, height: 16, borderRadius: 4),
            const SizedBox(height: 10),
            const SkeletonContainer(width: double.infinity, height: 16, borderRadius: 4),
            const SizedBox(height: 10),
            const SkeletonContainer(width: 240, height: 16, borderRadius: 4),
            const SizedBox(height: 24),
            Expanded(
              child: SkeletonContainer(
                width: double.infinity,
                height: double.infinity,
                borderRadius: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
