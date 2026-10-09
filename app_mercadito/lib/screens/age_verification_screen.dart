import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/user_session.dart';

class AgeVerificationScreen extends StatefulWidget {
  const AgeVerificationScreen({super.key});

  @override
  State<AgeVerificationScreen> createState() => _AgeVerificationScreenState();
}

class _AgeVerificationScreenState extends State<AgeVerificationScreen> {
  DateTime? _selectedDate;
  bool _adultConsentChecked = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (UserSession.birthDate != null) {
      _selectedDate = UserSession.birthDate;
      if (_calculatedAge != null && _calculatedAge! < 18) {
        _adultConsentChecked = UserSession.hasAdultConsent;
      }
    }
  }

  static const Color _colorPrimary = Color(0xFF00462f);
  static const Color _colorSecondary = Color(0xFF80C652);

  int? get _calculatedAge {
    if (_selectedDate == null) return null;
    final now = DateTime.now();
    int age = now.year - _selectedDate!.year;
    if (now.month < _selectedDate!.month ||
        (now.month == _selectedDate!.month && now.day < _selectedDate!.day)) {
      age--;
    }
    return age;
  }

  bool get _isUnderage {
    final age = _calculatedAge;
    return age != null && age < 18;
  }

  bool get _canProceed {
    if (_selectedDate == null) return false;
    final age = _calculatedAge!;
    if (age < 0 || age > 120) return false;
    if (age >= 18) return true;
    return _adultConsentChecked;
  }

  Future<void> _pickDate(BuildContext context) async {
    HapticFeedback.lightImpact();
    final now = DateTime.now();
    final initial = _selectedDate ?? DateTime(now.year - 20, now.month, now.day);
    
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1910),
      lastDate: now,
      helpText: 'SELECCIONA TU FECHA DE NACIMIENTO',
      cancelText: 'CANCELAR',
      confirmText: 'CONFIRMAR',
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? const ColorScheme.dark(
                    primary: _colorSecondary,
                    onPrimary: Color(0xFF003824),
                    surface: Color(0xFF1E2621),
                    onSurface: Colors.white,
                  )
                : const ColorScheme.light(
                    primary: _colorPrimary,
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: Color(0xFF1B3828),
                  ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _errorMessage = null;
        if (!_isUnderage) {
          _adultConsentChecked = false;
        }
      });
    }
  }

  void _handleContinue() {
    HapticFeedback.mediumImpact();
    if (_selectedDate == null) {
      setState(() {
        _errorMessage = 'Por favor selecciona tu fecha de nacimiento para continuar.';
      });
      return;
    }

    final age = _calculatedAge!;
    if (age < 18 && !_adultConsentChecked) {
      setState(() {
        _errorMessage =
            'Al ser menor de 18 años, un adulto responsable debe revisar y aceptar los Términos y Condiciones.';
      });
      _showUnderageWarningDialog();
      return;
    }

    // Save state in UserSession
    UserSession.birthDate = _selectedDate;
    UserSession.hasAdultConsent = age < 18 ? _adultConsentChecked : true;

    // Proceed to SelectRoleScreen
    context.go('/select-role');
  }

  void _showUnderageWarningDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E2621) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.gavel_rounded, color: Color(0xFFE5A93C), size: 26),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Requisito Legal',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: isDark ? Colors.white : const Color(0xFF1B3828),
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'Para proteger la seguridad de los usuarios y de acuerdo a nuestras políticas, los menores de 18 años deben contar con la revisión y consentimiento explícito de un padre o tutor legal para poder registrarse en El Mercadito.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            height: 1.5,
            color: isDark ? const Color(0xFFB0C2B7) : const Color(0xFF4A6856),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Entendido',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                color: isDark ? _colorSecondary : _colorPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return '${date.day} de ${months[date.month - 1]} de ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final actualBg = isDark ? const Color(0xFF121814) : const Color(0xFFF7FAF5);
    final actualCardBg = isDark ? const Color(0xFF1A231E) : Colors.white;
    final actualPrimary = isDark ? _colorSecondary : _colorPrimary;
    final textDark = isDark ? Colors.white : const Color(0xFF1B3828);
    final textMuted = isDark ? const Color(0xFF90A397) : const Color(0xFF5A7264);

    return Scaffold(
      backgroundColor: actualBg,
      body: SafeArea(
        child: Column(
          children: [
            // Barra superior fija en la parte superior
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_rounded, color: actualPrimary),
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/welcome');
                      }
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: SvgPicture.asset(
                      isDark
                          ? 'assets/images/logos/logo_m_blanco.svg'
                          : 'assets/images/logos/logo_m_color.svg',
                      height: 34,
                      fit: BoxFit.contain,
                      semanticsLabel: 'El Mercadito',
                    ),
                  ),
                ],
              ),
            ),

            // Contenido central scrollable
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 580),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Header icon
                        Container(
                          width: 72,
                          height: 72,
                    decoration: BoxDecoration(
                      color: actualPrimary.withValues(alpha: isDark ? 0.18 : 0.12),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: actualPrimary.withValues(alpha: isDark ? 0.35 : 0.2),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      Icons.cake_rounded,
                      size: 34,
                      color: actualPrimary,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Title
                  Text(
                    '¿Cuál es tu fecha de nacimiento?',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: textDark,
                      height: 1.25,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),

                  // Subtitle
                  Text(
                    'Verificamos tu edad para garantizar una experiencia confiable, segura y adaptada a tu perfil.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w500,
                      color: textMuted,
                      height: 1.45,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),

                  // Interactive Date Selection Card
                  InkWell(
                    onTap: () => _pickDate(context),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      decoration: BoxDecoration(
                        color: actualCardBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _selectedDate != null
                              ? actualPrimary.withValues(alpha: 0.6)
                              : (isDark ? const Color(0xFF2B3A31) : const Color(0xFFDCE6DF)),
                          width: _selectedDate != null ? 1.8 : 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: actualPrimary.withValues(alpha: isDark ? 0.2 : 0.1),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              Icons.calendar_month_rounded,
                              color: actualPrimary,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedDate == null
                                      ? 'Toca para seleccionar tu fecha'
                                      : 'Fecha de Nacimiento',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: textMuted,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _selectedDate == null
                                      ? 'DD / MM / AAAA'
                                      : _formatDate(_selectedDate!),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 16.5,
                                    fontWeight: FontWeight.w700,
                                    color: _selectedDate == null
                                        ? textMuted.withValues(alpha: 0.6)
                                        : textDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: actualPrimary,
                            size: 28,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Age Feedback Card (when date is chosen)
                  if (_selectedDate != null && _calculatedAge != null) ...[
                    const SizedBox(height: 20),
                    if (!_isUnderage)
                      // Adult status card (>= 18)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF285E44).withValues(alpha: isDark ? 0.25 : 0.12),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF285E44).withValues(alpha: isDark ? 0.45 : 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.verified_user_rounded,
                              color: Color(0xFF4CAF50),
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Tienes $_calculatedAge años (Mayor de edad). Puedes continuar con el registro.',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? const Color(0xFFC7E5D3) : const Color(0xFF1B4D36),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      // Underage warning and consent card (< 18)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD97706).withValues(alpha: isDark ? 0.16 : 0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFD97706).withValues(alpha: isDark ? 0.45 : 0.3),
                            width: 1.4,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD97706).withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.shield_outlined,
                                    color: Color(0xFFD97706),
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Menor de 18 años ($_calculatedAge años)',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.w800,
                                      color: isDark ? const Color(0xFFFDE68A) : const Color(0xFF92400E),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'De acuerdo con las normativas de protección, un padre, madre o tutor legal debe haber revisado los Términos y Condiciones para que puedas continuar con el registro.',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.5,
                                height: 1.45,
                                color: isDark ? const Color(0xFFF3F4F6) : const Color(0xFF78350F),
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Link to review terms
                            InkWell(
                              onTap: () => context.push('/legal-policies'),
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.menu_book_rounded,
                                      size: 16,
                                      color: isDark ? _colorSecondary : _colorPrimary,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Leer Términos y Condiciones',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        decoration: TextDecoration.underline,
                                        color: isDark ? _colorSecondary : _colorPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Divider(height: 24),

                            // Adult consent checkbox
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Checkbox(
                                  value: _adultConsentChecked,
                                  activeColor: actualPrimary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  onChanged: (val) {
                                    HapticFeedback.selectionClick();
                                    setState(() {
                                      _adultConsentChecked = val ?? false;
                                      if (_adultConsentChecked) {
                                        _errorMessage = null;
                                      }
                                    });
                                  },
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      HapticFeedback.selectionClick();
                                      setState(() {
                                        _adultConsentChecked = !_adultConsentChecked;
                                        if (_adultConsentChecked) {
                                          _errorMessage = null;
                                        }
                                      });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 10.0),
                                      child: Text(
                                        'Confirmo que un adulto responsable (padre, madre o tutor) revisó y autorizó los Términos y Condiciones.',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          height: 1.35,
                                          color: textDark,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                  ],

                  // Error message banner if any
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: isDark ? 0.2 : 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.red.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                color: isDark ? Colors.red[200] : Colors.red[900],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 36),

                  // Primary Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _canProceed ? _handleContinue : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: actualPrimary,
                        disabledBackgroundColor: isDark
                            ? const Color(0xFF223028)
                            : const Color(0xFFBEC9C1),
                        foregroundColor: isDark ? const Color(0xFF003824) : Colors.white,
                        disabledForegroundColor: Colors.white.withValues(alpha: 0.5),
                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        elevation: _canProceed ? 4 : 0,
                      ),
                      child: Text(
                        'CONTINUAR',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ),
                  ),

                  // Secondary cancel / underage cannot register message
                  if (_isUnderage && !_adultConsentChecked) ...[
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        _showUnderageWarningDialog();
                      },
                      child: Text(
                        '¿Qué hago si no tengo supervisión de un adulto?',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: textMuted,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    ],
  ),
),
);
  }
}
