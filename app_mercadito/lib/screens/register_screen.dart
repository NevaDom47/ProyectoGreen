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
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  String? _usernameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    String? uError;
    String? eError;
    String? pError;
    String? cpError;

    // Username is optional; validate if provided
    if (username.isNotEmpty && username.length > 20) {
      uError = 'El nombre no puede exceder 20 caracteres.';
    }

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

    if (uError != null || eError != null || pError != null || cpError != null) {
      setState(() {
        _usernameError = uError;
        _emailError = eError;
        _passwordError = pError;
        _confirmPasswordError = cpError;
      });
      return;
    }

    // Save session email and name
    UserSession.email = email;
    UserSession.fullName = username.isNotEmpty ? username : email.split('@').first;
    UserSession.isEmailVerified = false;

    // Navigate to email verification screen
    context.push('/verify-registration-email', extra: email);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final primaryColor = const Color(0xFF016042);
    final bgColor = isDark ? const Color(0xFF0f231d) : const Color(0xFFf5f8f7);
    final surfaceColor = isDark ? const Color(0xFF1e293b).withValues(alpha: 0.5) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0f172a); 
    final hintColor = isDark ? Colors.grey.shade500 : Colors.grey.shade400;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Navigation
              Container(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 24),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
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
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.18),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.asset(
                                'assets/images/logos/logo_app_icon.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const Text(
                            'Crear cuenta nueva',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Únete a El Mercadito',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 48), // Spacer to balance the row space taken by back button
                  ],
                ),
              ),
              
              // Banner Image
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    children: [
                      Image.network(
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuAYjEvl6GqW5CMVrL5GOdDov67oCvtBLLBP3YjBKSHMn4wqbdZJWu5BkTVHmsrtHHlk3cXiPeDLh6ZrVIwaoAohEig_BIXyHfn8rFByjod8KEw0NjE0Z8Rcb_wY0DVRSYwHZknzv_XjMURYKbFRRlA2p20EsZGWrxaxEJErOby4apO1RCpM8Taa2e7xXWvZam0UkOocPSXRQPBHPUlExyQpRsnFfeB5uQ3UJgzgYfsL6WBrK-01xLDU-Re8zVMtUjWvuRyqJQ67Cts',
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 160,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [primaryColor, primaryColor.withValues(alpha: 0.8)],
                            ),
                          ),
                          child: const Center(
                            child: Icon(Icons.agriculture_rounded, size: 56, color: Colors.white70),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                primaryColor.withValues(alpha: 0.85),
                                Colors.transparent,
                              ],
                            ),
                          ),
                          child: const Text(
                            'Productos frescos desde el productor hasta tu mesa',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Form Content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildInputField(
                      label: 'Nombre de Usuario (Opcional)',
                      hint: 'Ej. juan_perez',
                      icon: Icons.person,
                      controller: _usernameController,
                      surfaceColor: surfaceColor,
                      primaryColor: primaryColor,
                      textColor: textColor,
                      hintColor: hintColor,
                      isDark: isDark,
                      errorText: _usernameError,
                      onChanged: (_) {
                        if (_usernameError != null) {
                          setState(() => _usernameError = null);
                        }
                      },
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(20),
                        FilteringTextInputFormatter.deny(RegExp(r'\s')),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildInputField(
                      label: 'Correo Electrónico',
                      hint: 'correo@ejemplo.com',
                      icon: Icons.mail,
                      controller: _emailController,
                      surfaceColor: surfaceColor,
                      primaryColor: primaryColor,
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
                    const SizedBox(height: 16),
                    _buildInputField(
                      label: 'Contraseña',
                      hint: 'Crea una contraseña',
                      icon: Icons.lock,
                      controller: _passwordController,
                      surfaceColor: surfaceColor,
                      primaryColor: primaryColor,
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
                    const SizedBox(height: 16),
                    _buildInputField(
                      label: 'Confirmar Contraseña',
                      hint: 'Repite tu contraseña',
                      icon: Icons.lock_reset,
                      controller: _confirmPasswordController,
                      surfaceColor: surfaceColor,
                      primaryColor: primaryColor,
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
                    
                    const SizedBox(height: 32),
                    
                    // Submit Button with Bouncing micro-animation
                    BouncingButton(
                      onTap: _handleRegister,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withValues(alpha: 0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text(
                              'Crear cuenta',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Already have an account text
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '¿Ya tienes una cuenta? ',
                          style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade500, fontSize: 14),
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
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Terms
                    Center(
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 1.2,
                            color: Colors.grey.shade400,
                            height: 1.5,
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
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            label,
            style: TextStyle(
              color: isDark ? primaryColor.withValues(alpha: 0.9) : primaryColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        AnimatedErrorField(
          errorText: errorText,
          borderRadius: 8,
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: errorText != null
                    ? Colors.transparent
                    : primaryColor.withValues(alpha: 0.2),
              ),
              boxShadow: [
                if (!isDark)
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  alignment: Alignment.center,
                  child: Icon(icon, color: primaryColor.withValues(alpha: 0.6), size: 20),
                ),
                Expanded(
                  child: TextField(
                    controller: controller,
                    keyboardType: keyboardType,
                    obscureText: obscureText,
                    inputFormatters: inputFormatters,
                    onChanged: onChanged,
                    style: TextStyle(color: textColor, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: TextStyle(color: hintColor, fontSize: 14),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                if (isPassword)
                  GestureDetector(
                    onTap: onToggleVisibility,
                    child: Container(
                      width: 48,
                      alignment: Alignment.center,
                      child: Icon(
                        obscureText ? Icons.visibility : Icons.visibility_off,
                        color: primaryColor.withValues(alpha: 0.4),
                        size: 20,
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
