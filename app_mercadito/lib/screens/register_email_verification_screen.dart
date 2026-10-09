import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/user_session.dart';
import '../widgets/bouncing_button.dart';

class RegisterEmailVerificationScreen extends StatefulWidget {
  final String? email;

  const RegisterEmailVerificationScreen({
    super.key,
    this.email,
  });

  @override
  State<RegisterEmailVerificationScreen> createState() =>
      _RegisterEmailVerificationScreenState();
}

class _RegisterEmailVerificationScreenState
    extends State<RegisterEmailVerificationScreen>
    with SingleTickerProviderStateMixin {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  String? _errorMessage;
  int _secondsRemaining = 45;
  Timer? _timer;
  bool _canResend = false;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _shakeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _shakeController,
        curve: Curves.easeInOut,
      ),
    );

    _startResendTimer();
  }

  void _startResendTimer() {
    _timer?.cancel();
    setState(() {
      _secondsRemaining = 45;
      _canResend = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsRemaining > 1) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        timer.cancel();
        setState(() {
          _secondsRemaining = 0;
          _canResend = true;
        });
      }
    });
  }

  void _triggerErrorShake(String message) {
    HapticFeedback.lightImpact();
    setState(() {
      _errorMessage = message;
    });
    _shakeController.forward(from: 0.0);
  }

  void _clearError() {
    if (_errorMessage != null) {
      setState(() {
        _errorMessage = null;
      });
    }
  }

  void _handleResend() {
    if (!_canResend) return;

    HapticFeedback.selectionClick();
    _startResendTimer();
    _clearError();

    for (var c in _controllers) {
      c.clear();
    }
    _focusNodes[0].requestFocus();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.mark_email_read_rounded, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Nuevo código de verificación enviado a tu correo.',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF00462F),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _verifyCode() {
    _clearError();
    final otpCode = _controllers.map((c) => c.text.trim()).join();

    if (otpCode.length < 6) {
      _triggerErrorShake('Por favor ingresa los 6 dígitos del código.');
      return;
    }

    // Accepts 123456 or any 6-digit numeric code for full demo/testing flexibility
    if (otpCode != '123456' && !RegExp(r'^\d{6}$').hasMatch(otpCode)) {
      _triggerErrorShake('El código ingresado es incorrecto o ha expirado.');
      return;
    }

    setState(() {
      _isVerifying = true;
    });

    HapticFeedback.mediumImpact();

    // Mark email as verified in user session
    UserSession.isEmailVerified = true;
    final registeredEmail = widget.email ?? UserSession.email;
    if (registeredEmail != null && registeredEmail.isNotEmpty) {
      UserSession.email = registeredEmail;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.check_circle_rounded, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                '¡Correo verificado con éxito!',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF00462F),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );

    // If first time user accessing the app, present Welcome Screen
    Future.delayed(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      if (UserSession.isFirstTimeUser) {
        context.go('/welcome');
      } else if (!UserSession.hasRole) {
        context.go('/select-role');
      } else {
        context.go('/home');
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _shakeController.dispose();
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryColor = isDark ? const Color(0xFF80C652) : const Color(0xFF00462F);
    final bgColor = isDark ? const Color(0xFF101815) : const Color(0xFFF7FAF5);
    final cardBg = isDark ? const Color(0xFF1E2621) : Colors.white;
    final textMuted = isDark ? const Color(0xFF90A397) : const Color(0xFF3F4943);
    final errorBorderColor = isDark ? const Color(0xFFFF6B6B) : const Color(0xFFE03131);
    final displayEmail = widget.email ?? UserSession.email ?? 'tu correo';

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: primaryColor),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/register');
            }
          },
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Verification Mail Hero Icon
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withValues(alpha: isDark ? 0.2 : 0.08),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.mark_email_unread_rounded,
                        size: 46,
                        color: primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Title
                  Text(
                    'Verifica tu correo',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF00462F),
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),

                  // Subtitle & Email
                  Text.rich(
                    TextSpan(
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.5,
                        color: textMuted,
                        height: 1.5,
                      ),
                      children: [
                        const TextSpan(text: 'Hemos enviado un código de 6 dígitos a\n'),
                        TextSpan(
                          text: displayEmail,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF00462F),
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),

                  // Change Email Action
                  TextButton.icon(
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/register');
                      }
                    },
                    icon: Icon(Icons.edit_outlined, size: 14, color: primaryColor),
                    label: Text(
                      'Cambiar correo electrónico',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // OTP Container with Shake Physics
                  AnimatedBuilder(
                    animation: _shakeAnimation,
                    builder: (context, child) {
                      final hasError = _errorMessage != null;
                      final offset = hasError
                          ? sin(_shakeAnimation.value * 6 * pi) * 10 * (1 - _shakeAnimation.value)
                          : 0.0;
                      return Transform.translate(
                        offset: Offset(offset, 0),
                        child: child,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: _errorMessage != null
                              ? errorBorderColor
                              : (isDark ? const Color(0xFF2C3932) : const Color(0xFFE2E8F0)),
                          width: _errorMessage != null ? 1.8 : 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // 6 OTP Digit Inputs
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(6, (index) {
                              return _buildOtpBox(
                                index: index,
                                isDark: isDark,
                                primaryColor: primaryColor,
                                errorBorderColor: errorBorderColor,
                                hasError: _errorMessage != null,
                              );
                            }),
                          ),

                          // Animated Error Message below OTP boxes
                          AnimatedSize(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeInOut,
                            child: _errorMessage != null
                                ? Padding(
                                    padding: const EdgeInsets.only(top: 16.0),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.error_outline_rounded,
                                          size: 16,
                                          color: errorBorderColor,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            _errorMessage!,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w600,
                                              color: errorBorderColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Resend Code Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 16,
                        color: textMuted,
                      ),
                      const SizedBox(width: 6),
                      if (!_canResend) ...[
                        Text(
                          'Reenviar código en ',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            color: textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '00:${_secondsRemaining.toString().padLeft(2, '0')}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            color: primaryColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ] else ...[
                        GestureDetector(
                          onTap: _handleResend,
                          child: Text(
                            '¿No recibiste el código? Reenviar código',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: primaryColor,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Test code tip pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.info_outline, size: 14, color: primaryColor),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'Código de prueba para demostración: 123456',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Verify Button
                  BouncingButton(
                    onTap: _isVerifying ? null : _verifyCode,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(9999),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withValues(alpha: 0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Center(
                        child: _isVerifying
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                'VERIFICAR Y CONTINUAR',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.5,
                                  color: isDark ? const Color(0xFF003824) : Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOtpBox({
    required int index,
    required bool isDark,
    required Color primaryColor,
    required Color errorBorderColor,
    required bool hasError,
  }) {
    return Container(
      width: 44,
      height: 54,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141C18) : const Color(0xFFF1F5F3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasError
              ? errorBorderColor
              : (_controllers[index].text.isNotEmpty
                  ? primaryColor
                  : Colors.transparent),
          width: 1.6,
        ),
      ),
      child: Center(
        child: TextField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: hasError
                ? errorBorderColor
                : (isDark ? Colors.white : const Color(0xFF00462F)),
          ),
          decoration: const InputDecoration(
            counterText: '',
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.zero,
          ),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          onChanged: (value) {
            _clearError();
            if (value.isNotEmpty) {
              if (index < 5) {
                _focusNodes[index + 1].requestFocus();
              } else {
                _focusNodes[index].unfocus();
              }
            } else if (value.isEmpty && index > 0) {
              _focusNodes[index - 1].requestFocus();
            }
          },
        ),
      ),
    );
  }
}
