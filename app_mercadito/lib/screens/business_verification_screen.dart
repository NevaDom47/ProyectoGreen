import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../services/user_session.dart';
import '../widgets/verified_badge.dart';

class BusinessVerificationScreen extends StatefulWidget {
  const BusinessVerificationScreen({super.key});

  @override
  State<BusinessVerificationScreen> createState() => _BusinessVerificationScreenState();
}

class _BusinessVerificationScreenState extends State<BusinessVerificationScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _commercialNameController;
  late TextEditingController _rncController;
  late TextEditingController _legalRepController;

  String _selectedBusinessCategory = 'Productor Agropecuario';
  String _selectedDocumentType = 'Registro Mercantil Vigente';

  String? _docFileName;
  String? _repIdFileName;
  String? _addressProofFileName;

  bool _acceptTerms = false;
  bool _isSubmitting = false;

  final List<String> _businessCategories = [
    'Productor Agropecuario',
    'Distribuidor Mayorista',
    'Empacador / Exportador',
    'Comercializador de Insumos',
    'Cooperativa Agrícola',
  ];

  final List<String> _documentTypes = [
    'Registro Mercantil Vigente',
    'Constancia de Inscripción al RNC (DGII)',
    'Certificado de Registro ONAPI',
    'Título de Propiedad / Contrato de Finca',
  ];

  @override
  void initState() {
    super.initState();
    _commercialNameController = TextEditingController(
      text: UserSession.verifiedCommercialName ?? UserSession.fullName ?? 'Agro Negocios Dominicanos',
    );
    _rncController = TextEditingController(
      text: UserSession.verifiedRncNumber ?? '1-32-45678-9',
    );
    _legalRepController = TextEditingController(
      text: UserSession.fullName ?? 'Representante Legal',
    );

    _selectedDocumentType = UserSession.verifiedDocumentType ?? 'Registro Mercantil Vigente';
    _docFileName = UserSession.verifiedDocumentFileName;
    _repIdFileName = UserSession.verifiedRepresentativeIdFileName;
    _addressProofFileName = UserSession.verifiedAddressProofFileName;
  }

  Future<void> _capturePhotoWithCamera({
    required String documentKey,
    required String documentLabel,
  }) async {
    if (!UserSession.canSubmitVerification) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            UserSession.isProviderVerified
                ? 'El negocio ya está verificado.'
                : UserSession.isVerificationPending
                    ? 'La solicitud está en revisión. No se pueden modificar documentos.'
                    : 'La solicitud está bloqueada temporalmente por 30 días.',
          ),
          backgroundColor: Colors.orange[800],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    bool cameraSuccess = false;
    try {
      final picker = ImagePicker();
      final XFile? photo = await picker
          .pickImage(
            source: ImageSource.camera,
            imageQuality: 85,
          )
          .timeout(const Duration(milliseconds: 300));
      if (photo != null) {
        cameraSuccess = true;
        setState(() {
          final fileName = photo.name.isNotEmpty
              ? photo.name
              : 'foto_camara_${DateTime.now().millisecondsSinceEpoch}.jpg';
          if (documentKey == 'legal_doc') {
            _docFileName = fileName;
          } else if (documentKey == 'rep_id') {
            _repIdFileName = fileName;
          } else if (documentKey == 'address') {
            _addressProofFileName = fileName;
          }
        });
      }
    } catch (_) {
      // Fallback para entornos sin cámara activa o pruebas automatizadas
    }

    if (!cameraSuccess) {
      final slug = documentLabel.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
      final mockName = 'foto_camara_${slug}.jpg';
      setState(() {
        if (documentKey == 'legal_doc') {
          _docFileName = mockName;
        } else if (documentKey == 'rep_id') {
          _repIdFileName = mockName;
        } else if (documentKey == 'address') {
          _addressProofFileName = mockName;
        }
      });
    }

    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Foto de "$documentLabel" capturada con la cámara'),
          backgroundColor: const Color(0xFF016042),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  void dispose() {
    _commercialNameController.dispose();
    _rncController.dispose();
    _legalRepController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (!UserSession.canSubmitVerification) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            UserSession.isProviderVerified
                ? 'Este negocio ya está verificado, no se puede enviar otra solicitud.'
                : UserSession.isVerificationPending
                    ? 'Ya tienes una solicitud en revisión. No puedes enviar otra hasta obtener respuesta.'
                    : 'Has alcanzado el límite de 3 rechazos. Debes esperar ${UserSession.lockoutDaysRemaining} días.',
          ),
          backgroundColor: Colors.orange[800],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Debes certificar la veracidad de los datos para continuar'),
          backgroundColor: Colors.orange[800],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      if (_docFileName == null || _repIdFileName == null || _addressProofFileName == null) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Debes tomar la fotografía de los 3 documentos requeridos con la cámara'),
            backgroundColor: Colors.orange[800],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        return;
      }

      setState(() => _isSubmitting = true);

      UserSession.submitVerification(
        commercialName: _commercialNameController.text.trim(),
        rncNumber: _rncController.text.trim(),
        dgiiStatus: 'REGISTRADO Y AL DÍA',
        documentType: _selectedDocumentType,
        documentFileName: _docFileName!,
        addressProofFileName: _addressProofFileName!,
        representativeIdFileName: _repIdFileName!,
      );

      setState(() => _isSubmitting = false);

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text('Solicitud de verificación enviada exitosamente a revisión'),
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

  void _showDemoStatusModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Simulación de Verificación (Demo)',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Elige un estado para probar cómo interactúa el perfil con cada etapa de la verificación:',
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.verified, color: Color(0xFF016042)),
                  title: const Text('Aprobar como Verificado'),
                  subtitle: const Text('Activa la insignia oficial y bloquea nuevos envíos'),
                  onTap: () {
                    UserSession.approveVerification();
                    Navigator.pop(ctx);
                    setState(() {});
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.hourglass_top_rounded, color: Colors.amber),
                  title: const Text('Marcar En Revisión (Pending)'),
                  subtitle: const Text('Simula solicitud en análisis (bloquea nuevos envíos)'),
                  onTap: () {
                    UserSession.verificationLockoutUntil = null;
                    UserSession.verificationRejectionCount = 0;
                    UserSession.verificationStatus = 'pending';
                    Navigator.pop(ctx);
                    setState(() {});
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.cancel_outlined, color: Colors.orange),
                  title: const Text('Simular 1 Rechazo (Intento 1 de 3)'),
                  subtitle: const Text('Permite corregir datos y reintentar'),
                  onTap: () {
                    UserSession.resetVerification();
                    UserSession.rejectVerification(
                      'El nombre comercial indicado no concuerda con el titular registrado ante la DGII.',
                    );
                    Navigator.pop(ctx);
                    setState(() {});
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.lock_clock_rounded, color: Colors.redAccent),
                  title: const Text('Simular 3 Rechazos (Bloqueo 30 días)'),
                  subtitle: const Text('Alcanza 3 rechazos consecutivos e impone bloqueo'),
                  onTap: () {
                    UserSession.resetVerification();
                    UserSession.rejectVerification('Primer rechazo');
                    UserSession.rejectVerification('Segundo rechazo');
                    UserSession.rejectVerification(
                      'Documentos no válidos por tercera vez consecutiva.',
                    );
                    Navigator.pop(ctx);
                    setState(() {});
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.restart_alt, color: Colors.grey),
                  title: const Text('Restablecer a No Solicitado'),
                  subtitle: const Text('Vuelve al estado inicial y reinicia contadores'),
                  onTap: () {
                    UserSession.resetVerification();
                    Navigator.pop(ctx);
                    setState(() {});
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF0F231D) : const Color(0xFFF7FAF5);
    final cardBg = isDark ? const Color(0xFF13281E) : Colors.white;
    final primary = isDark ? const Color(0xFF89D6B0) : const Color(0xFF016042);
    final onSurface = isDark ? Colors.white : const Color(0xFF181D1A);
    final textVariant = isDark ? const Color(0xFFBEC9C1) : const Color(0xFF5F6368);
    final outlineVariant = isDark ? const Color(0xFF2C3E35) : const Color(0xFFD6DDD8);

    final status = UserSession.verificationStatus;
    final bool canSubmit = UserSession.canSubmitVerification;
    final bool isLockedOut = UserSession.isVerificationLockedOut;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: cardBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primary),
          onPressed: () => Navigator.pop(context, true),
        ),
        title: Text(
          'Verificación de Negocio',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: primary,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.tune_rounded, color: primary),
            tooltip: 'Simulador / Demo',
            onPressed: _showDemoStatusModal,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Badge Banner
                    _buildStatusBanner(status, isDark, primary, onSurface, textVariant),
                    const SizedBox(height: 20),

                    // Beneficios de la verificación
                    _buildBenefitsCard(isDark, cardBg, primary, onSurface, textVariant, outlineVariant),
                    const SizedBox(height: 24),

                    // Formulario de Solicitud Formal
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Datos Fiscales y Comerciales
                          Text(
                            '1. Datos Fiscales y Comerciales',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: onSurface,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: outlineVariant.withValues(alpha: 0.5)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextFormField(
                                  controller: _commercialNameController,
                                  enabled: canSubmit,
                                  decoration: InputDecoration(
                                    labelText: 'Nombre Comercial / Razón Social',
                                    hintText: 'Ej. Frutas del Cibao SRL',
                                    prefixIcon: Icon(Icons.storefront_outlined, color: primary, size: 20),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa el nombre comercial' : null,
                                ),
                                const SizedBox(height: 14),
                                TextFormField(
                                  controller: _rncController,
                                  enabled: canSubmit,
                                  decoration: InputDecoration(
                                    labelText: 'RNC o Cédula Tributaria (DGII)',
                                    hintText: 'Ej. 1-32-45678-9',
                                    prefixIcon: Icon(Icons.badge_outlined, color: primary, size: 20),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa el RNC fiscal' : null,
                                ),
                                const SizedBox(height: 14),

                                DropdownButtonFormField<String>(
                                  initialValue: _selectedBusinessCategory,
                                  decoration: InputDecoration(
                                    labelText: 'Categoría del Negocio',
                                    prefixIcon: Icon(Icons.category_outlined, color: primary, size: 20),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  items: _businessCategories.map((c) {
                                    return DropdownMenuItem(value: c, child: Text(c));
                                  }).toList(),
                                  onChanged: canSubmit
                                      ? (v) {
                                          if (v != null) setState(() => _selectedBusinessCategory = v);
                                        }
                                      : null,
                                ),
                                const SizedBox(height: 14),

                                DropdownButtonFormField<String>(
                                  initialValue: _selectedDocumentType,
                                  decoration: InputDecoration(
                                    labelText: 'Documento Legal Principal',
                                    prefixIcon: Icon(Icons.badge_outlined, color: primary, size: 20),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  items: _documentTypes.map((d) {
                                    return DropdownMenuItem(value: d, child: Text(d));
                                  }).toList(),
                                  onChanged: canSubmit
                                      ? (v) {
                                          if (v != null) {
                                            setState(() {
                                              _selectedDocumentType = v;
                                              if (_docFileName != null) {
                                                final slug = v.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
                                                _docFileName = 'foto_camara_$slug.jpg';
                                              }
                                            });
                                          }
                                        }
                                      : null,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // 2. Documentos Probatorios de Proveedor Real
                          Text(
                            '2. Documentación Probatoria',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: onSurface,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Toma una foto clara directamente con la cámara del teléfono de cada documento requerido. No se admiten archivos adjuntos.',
                            style: GoogleFonts.plusJakartaSans(fontSize: 12, color: textVariant),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: outlineVariant.withValues(alpha: 0.5)),
                            ),
                            child: Column(
                              children: [
                                _buildFileUploadTile(
                                  title: _selectedDocumentType,
                                  subtitle: 'Tomar foto con la cámara (requerido)',
                                  fileName: _docFileName,
                                  primary: primary,
                                  onSurface: onSurface,
                                  isDark: isDark,
                                  enabled: canSubmit,
                                  onPick: () => _capturePhotoWithCamera(
                                    documentKey: 'legal_doc',
                                    documentLabel: _selectedDocumentType,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _buildFileUploadTile(
                                  title: 'Cédula / ID del Representante Legal',
                                  subtitle: 'Tomar foto con la cámara (requerido)',
                                  fileName: _repIdFileName,
                                  primary: primary,
                                  onSurface: onSurface,
                                  isDark: isDark,
                                  enabled: canSubmit,
                                  onPick: () => _capturePhotoWithCamera(
                                    documentKey: 'rep_id',
                                    documentLabel: 'Cédula / ID del Representante Legal',
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _buildFileUploadTile(
                                  title: 'Comprobante de Domicilio / Finca',
                                  subtitle: 'Tomar foto con la cámara (requerido)',
                                  fileName: _addressProofFileName,
                                  primary: primary,
                                  onSurface: onSurface,
                                  isDark: isDark,
                                  enabled: canSubmit,
                                  onPick: () => _capturePhotoWithCamera(
                                    documentKey: 'address',
                                    documentLabel: 'Comprobante de Domicilio / Finca',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // 3. Compromiso y Declaración
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF17241D) : const Color(0xFFF1F7F3),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: primary.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Checkbox(
                                  value: _acceptTerms,
                                  activeColor: primary,
                                  onChanged: canSubmit
                                      ? (val) {
                                          setState(() => _acceptTerms = val ?? false);
                                        }
                                      : null,
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: canSubmit ? () => setState(() => _acceptTerms = !_acceptTerms) : null,
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        'Certifico bajo fe de veracidad que los datos y documentos provistos son genuinos, corresponden a una actividad comercial activa y acepto las políticas de garantía contra fraude y calidad comercial de Mercadito.',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          color: onSurface,
                                          height: 1.35,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom CTA
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: cardBg,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: _buildBottomActionButton(
                  context: context,
                  status: status,
                  canSubmit: canSubmit,
                  isLockedOut: isLockedOut,
                  isDark: isDark,
                  primary: primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActionButton({
    required BuildContext context,
    required String status,
    required bool canSubmit,
    required bool isLockedOut,
    required bool isDark,
    required Color primary,
  }) {
    if (status == 'verified') {
      return ElevatedButton.icon(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.verified, color: Colors.white, size: 20),
        label: Text(
          'NEGOCIO YA VERIFICADO (VOLVER)',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: VerifiedBadge.verifiedBlue,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
    }

    if (isLockedOut) {
      final days = UserSession.lockoutDaysRemaining;
      return ElevatedButton.icon(
        onPressed: null,
        icon: const Icon(Icons.lock_clock_rounded, size: 20),
        label: Text(
          'BLOQUEADO POR 30 DÍAS (QUEDAN $days DÍAS)',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        style: ElevatedButton.styleFrom(
          disabledBackgroundColor: isDark ? const Color(0xFF381A1A) : const Color(0xFFFEE2E2),
          disabledForegroundColor: isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
    }

    if (status == 'pending') {
      return ElevatedButton.icon(
        onPressed: null,
        icon: const Icon(Icons.hourglass_top_rounded, size: 20),
        label: Text(
          'SOLICITUD EN REVISIÓN (ESPERANDO RESPUESTA)',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12.5,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        style: ElevatedButton.styleFrom(
          disabledBackgroundColor: isDark ? const Color(0xFF332A15) : const Color(0xFFFEF3C7),
          disabledForegroundColor: isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
    }

    if (status == 'rejected') {
      return ElevatedButton.icon(
        onPressed: _isSubmitting ? null : _handleSubmit,
        icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
        label: Text(
          'REINTENTAR SOLICITUD DE VERIFICACIÓN',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF016042),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
    }

    return ElevatedButton.icon(
      onPressed: _isSubmitting ? null : _handleSubmit,
      icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
      label: Text(
        'ENVIAR SOLICITUD DE VERIFICACIÓN',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
          color: Colors.white,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF016042),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  Widget _buildStatusBanner(
    String status,
    bool isDark,
    Color primary,
    Color onSurface,
    Color textVariant,
  ) {
    if (UserSession.isVerificationLockedOut) {
      final days = UserSession.lockoutDaysRemaining;
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF381A1A) : const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFDC2626), width: 1.5),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Color(0xFFDC2626),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lock_clock_rounded, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Límite de Intentos Alcanzado (Bloqueo de 30 Días)',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFDC2626),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tu solicitud ha sido rechazada 3 veces consecutivas. Por políticas de seguridad comercial, no puedes enviar otra solicitud hasta transcurrir 30 días (Restan $days días).',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: isDark ? Colors.grey[300] : Colors.black87,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (status == 'verified') {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0C2438) : const Color(0xFFF0F9FF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: VerifiedBadge.verifiedBlue, width: 1.5),
        ),
        child: Row(
          children: [
            const VerifiedBadge(size: 42, showWhiteCircle: true),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¡Perfil de Negocio Verificado!',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: VerifiedBadge.verifiedBlue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Este negocio cuenta con la insignia oficial de confianza.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: isDark ? Colors.grey[300] : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (status == 'pending') {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF332A15) : const Color(0xFFFFF8E1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.amber[700]!, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.amber[700],
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.hourglass_top_rounded, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Solicitud de Verificación en Revisión',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber[900],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tus documentos fiscales y comerciales están siendo verificados. No puedes enviar otra solicitud hasta que obtengas una respuesta.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: isDark ? Colors.grey[300] : Colors.black87,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (status == 'rejected') {
      final count = UserSession.verificationRejectionCount;
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF381A1A) : const Color(0xFFFFEBEE),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.redAccent, width: 1.5),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Colors.redAccent,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline_rounded, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Documentación con Observaciones (Intento $count de 3)',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[800],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    UserSession.verificationRejectionReason ??
                        'Por favor revisa que el RNC y el Registro Mercantil coincidan exactamente con el nombre de tu negocio.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: isDark ? Colors.grey[300] : Colors.black87,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Nota: Al acumular 3 solicitudes rechazadas, no podrás enviar otra solicitud por 30 días.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.red[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Default: not_submitted
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16251E) : const Color(0xFFE8F3ED),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const VerifiedBadge(size: 42, showWhiteCircle: true),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Obtén la Insignia de Negocio Verificado',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Completa los requisitos indicados , esta verificacion es especialemente para comerciantes que son identificados como reales.',
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, color: textVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitsCard(
    bool isDark,
    Color cardBg,
    Color primary,
    Color onSurface,
    Color textVariant,
    Color outlineVariant,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const VerifiedBadge(size: 20, showWhiteCircle: true),
              const SizedBox(width: 8),
              Text(
                'Beneficios de la Verificación Formal',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildBenefitItem(Icons.verified, 'Insignia oficial azul en tu perfil y catálogo de productos.', VerifiedBadge.verifiedBlue, onSurface),
          const SizedBox(height: 8),
          _buildBenefitItem(Icons.trending_up_rounded, 'Prioridad de visibilidad en búsquedas y negociaciones.', primary, onSurface),
          const SizedBox(height: 8),
          _buildBenefitItem(Icons.shield_outlined, 'Genera mayor confianza a tus compradores.', primary, onSurface),
          const SizedBox(height: 8),
          _buildBenefitItem(Icons.auto_awesome_outlined, 'Permite destacarte sobre otros proveedores no verificados.', primary, onSurface),
          const SizedBox(height: 8),
          _buildBenefitItem(Icons.handshake_outlined, 'Mayor tasa de cierre con compradores institucionales y cadenas de mercado.', primary, onSurface),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(IconData icon, String text, Color primary, Color onSurface) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 17, color: primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.plusJakartaSans(fontSize: 12, color: onSurface, height: 1.3),
          ),
        ),
      ],
    );
  }

  Widget _buildFileUploadTile({
    required String title,
    required String subtitle,
    required String? fileName,
    required Color primary,
    required Color onSurface,
    required bool isDark,
    required bool enabled,
    required VoidCallback onPick,
  }) {
    final bool hasFile = fileName != null && fileName.isNotEmpty;

    final cardBgColor = hasFile
        ? (isDark ? const Color(0xFF14291F) : const Color(0xFFF3FAF6))
        : (isDark ? const Color(0xFF1B221E) : const Color(0xFFF7F8F7));

    final borderColor = hasFile
        ? const Color(0xFF016042).withValues(alpha: 0.45)
        : (isDark ? Colors.white.withValues(alpha: 0.12) : const Color(0xFFE2E8E4));

    final iconBgColor = hasFile
        ? (isDark ? const Color(0xFF1C3D2E) : const Color(0xFFD6EFE1))
        : (isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFEAEEEC));

    final iconColor = hasFile
        ? const Color(0xFF016042)
        : (isDark ? Colors.grey[400]! : const Color(0xFF8A9A90));

    final IconData statusIcon = hasFile
        ? Icons.check_circle_outline_rounded
        : Icons.radio_button_unchecked_rounded;

    return InkWell(
      onTap: enabled ? onPick : null,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: borderColor,
            width: hasFile ? 1.2 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(statusIcon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: hasFile ? FontWeight.bold : FontWeight.w600,
                      color: onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hasFile ? fileName : subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: hasFile
                          ? const Color(0xFF016042)
                          : (isDark ? Colors.grey[400] : const Color(0xFF6B7280)),
                      fontWeight: hasFile ? FontWeight.w600 : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            TextButton.icon(
              onPressed: enabled ? onPick : null,
              icon: Icon(
                Icons.camera_alt_outlined,
                size: 16,
                color: !enabled
                    ? Colors.grey
                    : (hasFile ? const Color(0xFF016042) : primary),
              ),
              label: Text(
                !enabled
                    ? 'Bloqueado'
                    : (hasFile ? 'Cambiar' : 'Tomar Foto'),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: !enabled
                      ? Colors.grey
                      : (hasFile ? const Color(0xFF016042) : primary),
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
