import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../services/user_session.dart';
import '../widgets/animated_error_field.dart';
import '../widgets/bouncing_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    String? eError;
    String? pError;
    String? cpError;

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (email.isEmpty) {
      eError = 'Por favor ingresa tu correo electrónico.';
    } else if (!emailRegex.hasMatch(email)) {
      eError = 'Por favor ingresa un correo electrónico válido.';
    }

    if (password.isEmpty) {
      pError = 'Por favor ingresa una contraseña.';
    } else if (password.length < 8) {
      pError = 'La contraseña debe tener al menos 8 caracteres.';
    }

    if (confirmPassword.isEmpty) {
      cpError = 'Por favor confirma tu contraseña.';
    } else if (password != confirmPassword) {
      cpError = 'Las contraseñas no coinciden.';
    }

    if (eError != null || pError != null || cpError != null) {
      setState(() {
        _emailError = eError;
        _passwordError = pError;
        _confirmPasswordError = cpError;
      });
      return;
    }

    // Save session email and name
    UserSession.email = email;
    UserSession.fullName = email.split('@').first;
    UserSession.isEmailVerified = false;

    // Navigate to email verification screen
    context.push('/verify-registration-email', extra: email);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final primaryColor = const Color(0xFF016042);
    final accentGreen = isDark ? const Color(0xFF80C652) : primaryColor;
    final bgColor = isDark ? const Color(0xFF0F1C18) : const Color(0xFFF5F8F7);
    final surfaceColor = isDark ? const Color(0xFF1F2924) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A); 
    final hintColor = isDark ? const Color(0xFF6B7280) : Colors.grey.shade400;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Navigation
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/login');
                        }
                      },
                    ),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            'Crear cuenta nueva',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Únete a El Mercadito',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 48), // Spacer to balance the row space taken by back button
                  ],
                ),
              ),
              
              // Form Content
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildInputField(
                          label: 'Correo Electrónico',
                          hint: 'correo@ejemplo.com',
                          icon: Icons.mail,
                          controller: _emailController,
                          surfaceColor: surfaceColor,
                          primaryColor: primaryColor,
                          accentColor: accentGreen,
                          textColor: textColor,
                          hintColor: hintColor,
                          isDark: isDark,
                          errorText: _emailError,
                          onChanged: (_) {
                            if (_emailError != null) {
                              setState(() => _emailError = null);
                            }
                          },
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 24),
                        _buildInputField(
                          label: 'Contraseña',
                          hint: 'Crea una contraseña',
                          icon: Icons.lock,
                          controller: _passwordController,
                          surfaceColor: surfaceColor,
                          primaryColor: primaryColor,
                          accentColor: accentGreen,
                          textColor: textColor,
                          hintColor: hintColor,
                          isDark: isDark,
                          isPassword: true,
                          obscureText: _obscurePassword,
                          errorText: _passwordError,
                          onChanged: (_) {
                            if (_passwordError != null) {
                              setState(() => _passwordError = null);
                            }
                          },
                          onToggleVisibility: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(30),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _buildInputField(
                          label: 'Confirmar Contraseña',
                          hint: 'Repite tu contraseña',
                          icon: Icons.lock_reset,
                          controller: _confirmPasswordController,
                          surfaceColor: surfaceColor,
                          primaryColor: primaryColor,
                          accentColor: accentGreen,
                          textColor: textColor,
                          hintColor: hintColor,
                          isDark: isDark,
                          isPassword: true,
                          obscureText: _obscureConfirmPassword,
                          errorText: _confirmPasswordError,
                          onChanged: (_) {
                            if (_confirmPasswordError != null) {
                              setState(() => _confirmPasswordError = null);
                            }
                          },
                          onToggleVisibility: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          },
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(30),
                          ],
                        ),
                        
                        const SizedBox(height: 40),
                        
                        // Submit Button with Bouncing micro-animation
                        BouncingButton(
                          onTap: _handleRegister,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            decoration: BoxDecoration(
                              color: accentGreen,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: accentGreen.withValues(alpha: isDark ? 0.35 : 0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Crear cuenta',
                                  style: TextStyle(
                                    color: isDark ? const Color(0xFF0F1C18) : Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Icon(
                                  Icons.arrow_forward,
                                  color: isDark ? const Color(0xFF0F1C18) : Colors.white,
                                  size: 22,
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Already have an account text
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              '¿Ya tienes una cuenta? ',
                              style: TextStyle(
                                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                fontSize: 15,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                if (context.canPop()) {
                                  context.pop();
                                } else {
                                  context.go('/login');
                                }
                              },
                              child: Text(
                                'Inicia sesión aquí',
                                style: TextStyle(
                                  color: accentGreen,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 40),
                        
                        // Terms
                        Center(
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 11,
                                letterSpacing: 1.1,
                                color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
                                height: 1.6,
                              ),
                              children: [
                                const TextSpan(text: 'AL REGISTRARTE, ACEPTAS NUESTROS\n'),
                                const TextSpan(text: 'TÉRMINOS DE SERVICIO', style: TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                                const TextSpan(text: ' Y '),
                                const TextSpan(text: 'POLÍTICA DE PRIVACIDAD', style: TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    required Color surfaceColor,
    required Color primaryColor,
    required Color accentColor,
    required Color textColor,
    required Color hintColor,
    required bool isDark,
    String? errorText,
    ValueChanged<String>? onChanged,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: TextStyle(
              color: isDark ? accentColor : primaryColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        AnimatedErrorField(
          errorText: errorText,
          borderRadius: 12,
          child: Container(
            height: 58,
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: errorText != null
                    ? Colors.transparent
                    : (isDark ? const Color(0xFF2A3D34) : primaryColor.withValues(alpha: 0.2)),
              ),
              boxShadow: [
                if (!isDark)
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 54,
                  alignment: Alignment.center,
                  child: Icon(
                    icon,
                    color: isDark ? accentColor : primaryColor.withValues(alpha: 0.6),
                    size: 24,
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: controller,
                    keyboardType: keyboardType,
                    obscureText: obscureText,
                    inputFormatters: inputFormatters,
                    onChanged: onChanged,
                    style: TextStyle(color: textColor, fontSize: 16),
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: TextStyle(color: hintColor, fontSize: 16),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                  ),
                ),
                if (isPassword)
                  GestureDetector(
                    onTap: onToggleVisibility,
                    child: Container(
                      width: 54,
                      alignment: Alignment.center,
                      child: Icon(
                        obscureText ? Icons.visibility : Icons.visibility_off,
                        color: isDark ? accentColor : primaryColor.withValues(alpha: 0.4),
                        size: 24,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
