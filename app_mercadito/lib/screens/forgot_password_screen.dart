import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_error_field.dart';
import '../widgets/bouncing_button.dart';

enum ForgotPasswordStep {
  enterEmail,
  enterCode,
  newPassword,
  success,
}

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  ForgotPasswordStep _currentStep = ForgotPasswordStep.enterEmail;

  // Controllers Step 1: Email
  final _emailController = TextEditingController();
  final _formKeyEmail = GlobalKey<FormState>();
  String? _emailError;

  // Controllers Step 2: 6-Digit OTP
  final List<TextEditingController> _codeControllers =
      List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _codeFocusNodes =
      List.generate(6, (index) => FocusNode());
  String? _codeError;

  Timer? _resendTimer;
  int _resendSeconds = 55;
  bool _canResend = false;

  // Controllers Step 3: New Password
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKeyPassword = GlobalKey<FormState>();
  String? _passwordError;
  String? _confirmPasswordError;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    for (var c in _codeControllers) {
      c.dispose();
    }
    for (var f in _codeFocusNodes) {
      f.dispose();
    }
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    setState(() {
      _resendSeconds = 55;
      _canResend = false;
    });
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_resendSeconds > 1) {
        setState(() {
          _resendSeconds--;
        });
      } else {
        timer.cancel();
        setState(() {
          _canResend = true;
          _resendSeconds = 0;
        });
      }
    });
  }

  // --- Actions ---

  Future<void> _handleSendEmail() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _emailError = 'Por favor ingresa tu correo electrónico.');
      return;
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      setState(() => _emailError = 'Por favor ingresa un correo electrónico válido.');
      return;
    }

    setState(() {
      _isLoading = true;
      _emailError = null;
    });
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _currentStep = ForgotPasswordStep.enterCode;
    });
    _startResendTimer();
  }

  Future<void> _handleVerifyCode() async {
    final code = _codeControllers.map((c) => c.text.trim()).join();
    if (code.length < 6) {
      setState(() => _codeError = 'Ingresa los 6 dígitos del código de verificación.');
      return;
    }

    setState(() {
      _isLoading = true;
      _codeError = null;
    });
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _currentStep = ForgotPasswordStep.newPassword;
    });
  }

  Future<void> _handleResetPassword() async {
    final pass = _passwordController.text;
    final confirm = _confirmPasswordController.text;

    String? pErr;
    String? cpErr;

    if (pass.isEmpty) {
      pErr = 'Por favor ingresa una nueva contraseña.';
    } else if (pass.length < 8) {
      pErr = 'La contraseña debe tener al menos 8 caracteres.';
    }

    if (confirm.isEmpty) {
      cpErr = 'Por favor confirma tu contraseña.';
    } else if (pass != confirm) {
      cpErr = 'Las contraseñas no coinciden.';
    }

    if (pErr != null || cpErr != null) {
      setState(() {
        _passwordError = pErr;
        _confirmPasswordError = cpErr;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _passwordError = null;
      _confirmPasswordError = null;
    });
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _currentStep = ForgotPasswordStep.success;
    });
  }

  void _handleResendCode() {
    if (!_canResend) return;
    _startResendTimer();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Nuevo código enviado a ${_emailController.text.trim()}'),
        backgroundColor: const Color(0xFF016042),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final theme = Theme.of(context);
    final primaryColor = AppTheme.getPrimaryColor(context);
    final textColor = AppTheme.getTextColor(context);
    final secondaryTextColor = AppTheme.getSecondaryTextColor(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () {
            if (_currentStep == ForgotPasswordStep.enterCode) {
              setState(() => _currentStep = ForgotPasswordStep.enterEmail);
            } else if (_currentStep == ForgotPasswordStep.newPassword) {
              setState(() => _currentStep = ForgotPasswordStep.enterCode);
            } else {
              context.pop();
            }
          },
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 448),
              padding: const EdgeInsets.all(28.0),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildCurrentStep(
                  isDark: isDark,
                  primaryColor: primaryColor,
                  textColor: textColor,
                  secondaryTextColor: secondaryTextColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStep({
    required bool isDark,
    required Color primaryColor,
    required Color textColor,
    required Color secondaryTextColor,
  }) {
    switch (_currentStep) {
      case ForgotPasswordStep.enterEmail:
        return _buildStepEmail(isDark, primaryColor, textColor, secondaryTextColor);
      case ForgotPasswordStep.enterCode:
        return _buildStepCode(isDark, primaryColor, textColor, secondaryTextColor);
      case ForgotPasswordStep.newPassword:
        return _buildStepNewPassword(isDark, primaryColor, textColor, secondaryTextColor);
      case ForgotPasswordStep.success:
        return _buildStepSuccess(isDark, primaryColor, textColor, secondaryTextColor);
    }
  }

  // --- STEP 1: SOLICITAR CÓDIGO POR CORREO ---
  Widget _buildStepEmail(
    bool isDark,
    Color primaryColor,
    Color textColor,
    Color secondaryTextColor,
  ) {
    return Column(
      key: const ValueKey('step_email'),
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Icono superior
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.lock_reset_rounded,
            size: 42,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 20),

        Text(
          '¿Olvidaste tu contraseña?',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),

        Text(
          'Ingresa tu correo electrónico registrado y te enviaremos un código de seguridad para restablecerla.',
          style: TextStyle(
            fontSize: 14,
            color: secondaryTextColor,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 28),

        // Campo de correo
        Form(
          key: _formKeyEmail,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Correo electrónico',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              AnimatedErrorField(
                errorText: _emailError,
                borderRadius: 12,
                child: TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'tu@correo.com',
                    prefixIcon: Icon(Icons.mail_outline_rounded),
                  ),
                  onChanged: (_) {
                    if (_emailError != null) {
                      setState(() => _emailError = null);
                    }
                  },
                  onSubmitted: (_) => _handleSendEmail(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Botón Responsive & Central
        BouncingButton(
          onTap: _isLoading ? null : _handleSendEmail,
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleSendEmail,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Enviar código de verificación',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Volver a login
        TextButton(
          onPressed: () => context.pop(),
          child: Text(
            'Volver a Iniciar Sesión',
            style: TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  // --- STEP 2: VERIFICAR CÓDIGO (6 DÍGITOS) ---
  Widget _buildStepCode(
    bool isDark,
    Color primaryColor,
    Color textColor,
    Color secondaryTextColor,
  ) {
    final email = _emailController.text.trim();

    return Column(
      key: const ValueKey('step_code'),
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.mark_email_read_rounded,
            size: 40,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 20),

        Text(
          'Verificar código',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),

        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(fontSize: 14, color: secondaryTextColor, height: 1.4),
            children: [
              const TextSpan(text: 'Hemos enviado un código de 6 dígitos a:\n'),
              TextSpan(
                text: email,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: () {
            setState(() => _currentStep = ForgotPasswordStep.enterEmail);
          },
          child: Text(
            '¿Correo incorrecto? Cambiar',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: primaryColor,
            ),
          ),
        ),
        const SizedBox(height: 28),

        // 6 Inputs para OTP adaptables
        AnimatedErrorField(
          errorText: _codeError,
          borderRadius: 14,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(6, (index) {
              return Expanded(
                child: Container(
                  height: 54,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: TextFormField(
                    controller: _codeControllers[index],
                    focusNode: _codeFocusNodes[index],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      contentPadding: EdgeInsets.zero,
                      filled: true,
                      fillColor: isDark ? const Color(0xFF17221E) : const Color(0xFFEEF5F1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: primaryColor.withValues(alpha: 0.3),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: primaryColor,
                          width: 2,
                        ),
                      ),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    onChanged: (value) {
                      if (_codeError != null) {
                        setState(() => _codeError = null);
                      }
                      if (value.isNotEmpty) {
                        if (index < 5) {
                          _codeFocusNodes[index + 1].requestFocus();
                        } else {
                          _codeFocusNodes[index].unfocus();
                          _handleVerifyCode();
                        }
                      } else {
                        if (index > 0) {
                          _codeFocusNodes[index - 1].requestFocus();
                        }
                      }
                    },
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 24),

        // Botón Responsive & Central
        BouncingButton(
          onTap: _isLoading ? null : _handleVerifyCode,
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleVerifyCode,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Verificar código',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Reenviar código (Wrap responsivo)
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              '¿No recibiste el código? ',
              style: TextStyle(fontSize: 13, color: secondaryTextColor),
            ),
            if (_canResend)
              InkWell(
                onTap: _handleResendCode,
                child: Text(
                  'Reenviar',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              )
            else
              Text(
                'Reenviar en ${_resendSeconds}s',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
          ],
        ),
      ],
    );
  }

  // --- STEP 3: CREAR NUEVA CONTRASEÑA ---
  Widget _buildStepNewPassword(
    bool isDark,
    Color primaryColor,
    Color textColor,
    Color secondaryTextColor,
  ) {
    return Column(
      key: const ValueKey('step_password'),
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.lock_outline_rounded,
            size: 40,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 20),

        Text(
          'Nueva Contraseña',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),

        Text(
          'Ingresa una nueva contraseña segura para tu cuenta.',
          style: TextStyle(
            fontSize: 14,
            color: secondaryTextColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 28),

        Form(
          key: _formKeyPassword,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nueva Contraseña',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textColor),
              ),
              const SizedBox(height: 8),
              AnimatedErrorField(
                errorText: _passwordError,
                borderRadius: 12,
                child: TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'Mínimo 8 caracteres',
                    prefixIcon: const Icon(Icons.lock_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                  ),
                  onChanged: (_) {
                    if (_passwordError != null) {
                      setState(() => _passwordError = null);
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'Confirmar Contraseña',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textColor),
              ),
              const SizedBox(height: 8),
              AnimatedErrorField(
                errorText: _confirmPasswordError,
                borderRadius: 12,
                child: TextField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirm,
                  decoration: InputDecoration(
                    hintText: 'Repite tu nueva contraseña',
                    prefixIcon: const Icon(Icons.lock_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirm ? Icons.visibility : Icons.visibility_off),
                      onPressed: () {
                        setState(() => _obscureConfirm = !_obscureConfirm);
                      },
                    ),
                  ),
                  onChanged: (_) {
                    if (_confirmPasswordError != null) {
                      setState(() => _confirmPasswordError = null);
                    }
                  },
                  onSubmitted: (_) => _handleResetPassword(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Botón Responsive & Central
        BouncingButton(
          onTap: _isLoading ? null : _handleResetPassword,
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleResetPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Restablecer Contraseña',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  // --- STEP 4: ÉXITO Y CONFIRMACIÓN ---
  Widget _buildStepSuccess(
    bool isDark,
    Color primaryColor,
    Color textColor,
    Color secondaryTextColor,
  ) {
    return Column(
      key: const ValueKey('step_success'),
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: const Color(0xFF67C83B).withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle_rounded,
            size: 54,
            color: Color(0xFF67C83B),
          ),
        ),
        const SizedBox(height: 24),

        Text(
          '¡Contraseña restablecida!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),

        Text(
          'Tu contraseña ha sido actualizada exitosamente. Ahora puedes ingresar a El Mercadito con tus nuevas credenciales.',
          style: TextStyle(
            fontSize: 14,
            color: secondaryTextColor,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),

        // Botón Responsive & Central para Iniciar Sesión
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () => context.go('/login'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Iniciar Sesión',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}
