import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/user_session.dart';
import '../widgets/animated_error_field.dart';
import '../widgets/bouncing_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    final email = _emailController.text.trim();
    final pass = _passwordController.text;

    String? newEmailError;
    String? newPassError;

    if (email.isEmpty) {
      newEmailError = 'Por favor ingresa tu correo electrónico o usuario.';
    }

    if (pass.isEmpty) {
      newPassError = 'Por favor ingresa tu contraseña.';
    }

    if (newEmailError != null || newPassError != null) {
      setState(() {
        _emailError = newEmailError;
        _passwordError = newPassError;
      });
      return;
    }

    UserSession.email ??= email;

    // Navigate to welcome if user has no role defined yet
    if (!UserSession.hasRole) {
      context.go('/welcome');
    } else if (UserSession.selectedRole == 'comprador' && !UserSession.isBuyerOnboarded) {
      context.go('/buyer-onboarding');
    } else if (UserSession.selectedRole == 'proveedor' && !UserSession.isProviderOnboarded) {
      context.go('/provider-onboarding');
    } else {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Accessing theme colors
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 448),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Back button area
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: InkWell(
                          onTap: () {
                            // Back action if needed, though this is initial route
                          },
                          child: Icon(
                            Icons.arrow_back,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                    
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                      child: Column(
                        children: [
                          // Logo Oficial de El Mercadito
                          Container(
                            width: 96,
                            height: 96,
                            margin: const EdgeInsets.only(bottom: 24),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.colorScheme.primary.withValues(alpha: isDarkMode ? 0.35 : 0.2),
                                  blurRadius: 20,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: Image.asset(
                                'assets/images/el_mercadito_logo.png',
                                width: 96,
                                height: 96,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  width: 96,
                                  height: 96,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: Icon(
                                    Icons.storefront,
                                    size: 48,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          
                          // Welcome Text
                          Text(
                            'Bienvenido de nuevo',
                            style: theme.textTheme.displayLarge?.copyWith(
                              fontSize: 28,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Accede a la frescura del campo en un clic',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),
                          
                          // Form
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Correo electrónico o Usuario', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              AnimatedErrorField(
                                errorText: _emailError,
                                borderRadius: 12,
                                child: TextField(
                                  controller: _emailController,
                                  decoration: const InputDecoration(
                                    hintText: 'tu@correo.com',
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  onChanged: (_) {
                                    if (_emailError != null) {
                                      setState(() => _emailError = null);
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(height: 16),
                              
                              Text('Contraseña', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              AnimatedErrorField(
                                errorText: _passwordError,
                                borderRadius: 12,
                                child: TextField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  decoration: InputDecoration(
                                    hintText: '••••••••',
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                        color: isDarkMode ? Colors.grey[500] : Colors.grey[400],
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                      hoverColor: Colors.transparent,
                                    ),
                                  ),
                                  onChanged: (_) {
                                    if (_passwordError != null) {
                                      setState(() => _passwordError = null);
                                    }
                                  },
                                ),
                              ),
                              
                              // Forgot Password
                              const SizedBox(height: 6),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () => context.push('/forgot-password'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: theme.colorScheme.primary,
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: const Text(
                                    '¿Olvidé mi contraseña?',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              
                              // Login Button (Responsive y Central con rebote táctil)
                              BouncingButton(
                                onTap: _handleLogin,
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: _handleLogin,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: theme.colorScheme.primary,
                                      foregroundColor: Colors.white,
                                      elevation: 2,
                                      shadowColor: theme.colorScheme.primary.withValues(alpha: 0.3),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      textStyle: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                    child: const Text('Iniciar Sesión'),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          // Divider
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 32),
                            child: Row(
                              children: [
                                Expanded(child: Divider(color: theme.colorScheme.outline)),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    'O',
                                    style: TextStyle(
                                      color: isDarkMode ? Colors.grey[500] : Colors.grey[400],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(child: Divider(color: theme.colorScheme.outline)),
                              ],
                            ),
                          ),
                          
                          // Google Button
                          InkWell(
                            onTap: () {},
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: isDarkMode ? const Color(0xFF1f2937) : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: theme.colorScheme.primary, width: 1.5),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.network(
                                    'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/120px-Google_%22G%22_logo.svg.png',
                                    height: 24,
                                    width: 24,
                                    errorBuilder: (c, e, s) => const Icon(Icons.g_mobiledata, color: Colors.blue, size: 32),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Iniciar con Google',
                                    style: TextStyle(
                                      color: isDarkMode ? Colors.white : Colors.black87,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          
                          // Register Link
                          Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                '¿No tienes cuenta? ',
                                style: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                              ),
                              MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  onTap: () => context.push('/register'),
                                  child: Text(
                                    'Regístrate',
                                    style: TextStyle(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.bold,
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
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Text(
            '© 2024 El Mercadito S.A. Todos los derechos reservados.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: isDarkMode ? Colors.grey[500] : Colors.grey[400],
            ),
          ),
        ),
      ),
    );
  }
}
