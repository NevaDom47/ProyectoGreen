import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../main.dart'; // import appThemeMode global variable

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appThemeMode,
      builder: (context, currentMode, _) {
        final platformBrightness = MediaQuery.platformBrightnessOf(context);
        final isDark = currentMode == ThemeMode.dark || (currentMode == ThemeMode.system && platformBrightness == Brightness.dark);
        
        final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFf7faf5);
        final primaryColor = const Color(0xFF00462f);
        final textColor = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0f172a);
        final surfaceColor = isDark ? const Color(0xFF1E293B) : Colors.white;
        final borderColor = isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.1);
        final subtextColor = isDark ? const Color(0xFF94a3b8) : const Color(0xFF475569);
        final inputFillColor = isDark ? const Color(0xFF1E293B) : Colors.white;
        
        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            backgroundColor: bgColor,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: textColor),
              onPressed: () => context.pop(),
            ),
            title: Text(
              'Cambiar Contraseña',
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                fontFamily: 'Plus Jakarta Sans',
              ),
            ),
            centerTitle: true,
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ingresa tu contraseña actual y la nueva contraseña que deseas usar. Asegúrate de usar una contraseña segura.',
                        style: TextStyle(
                          color: subtextColor,
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Current Password
                      _buildPasswordField(
                        label: 'Contraseña actual',
                        obscureText: _obscureCurrent,
                        onToggleVisibility: () {
                          setState(() {
                            _obscureCurrent = !_obscureCurrent;
                          });
                        },
                        textColor: textColor,
                        fillColor: inputFillColor,
                        borderColor: borderColor,
                        primaryColor: primaryColor,
                        subtextColor: subtextColor,
                      ),
                      const SizedBox(height: 24),

                      // New Password
                      _buildPasswordField(
                        label: 'Nueva contraseña',
                        obscureText: _obscureNew,
                        helperText: 'Debe tener al menos 8 caracteres.',
                        onToggleVisibility: () {
                          setState(() {
                            _obscureNew = !_obscureNew;
                          });
                        },
                        textColor: textColor,
                        fillColor: inputFillColor,
                        borderColor: borderColor,
                        primaryColor: primaryColor,
                        subtextColor: subtextColor,
                      ),
                      const SizedBox(height: 24),

                      // Confirm New Password
                      _buildPasswordField(
                        label: 'Confirmar nueva contraseña',
                        obscureText: _obscureConfirm,
                        onToggleVisibility: () {
                          setState(() {
                            _obscureConfirm = !_obscureConfirm;
                          });
                        },
                        textColor: textColor,
                        fillColor: inputFillColor,
                        borderColor: borderColor,
                        primaryColor: primaryColor,
                        subtextColor: subtextColor,
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Action Area
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: bgColor,
                  border: Border(
                    top: BorderSide(color: borderColor),
                  ),
                ),
                child: SafeArea(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        context.pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Contraseña actualizada exitosamente', style: TextStyle(color: Colors.white)),
                            backgroundColor: primaryColor,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        minimumSize: Size.zero, // Override global style
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30), // Rounded pill shape as in design
                        ),
                        elevation: 4,
                        shadowColor: primaryColor.withOpacity(0.4),
                      ),
                      child: const Text(
                        'Actualizar Contraseña',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildPasswordField({
    required String label,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    required Color textColor,
    required Color fillColor,
    required Color borderColor,
    required Color primaryColor,
    required Color subtextColor,
    String? helperText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          obscureText: obscureText,
          style: TextStyle(color: textColor),
          decoration: InputDecoration(
            hintText: '••••••••',
            hintStyle: TextStyle(color: subtextColor.withOpacity(0.5)),
            filled: true,
            fillColor: fillColor,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: primaryColor),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                obscureText ? Icons.visibility_off : Icons.visibility,
                color: subtextColor,
              ),
              onPressed: onToggleVisibility,
            ),
          ),
        ),
        if (helperText != null) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: Text(
              helperText,
              style: TextStyle(
                color: subtextColor,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
