import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../main.dart'; // import appThemeMode global variable

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  // Visibilidad del Perfil
  bool _publicProfile = true;
  bool _showLocation = false;
  bool _showRegistrationDate = true;

  // Actividad y Negociaciones
  bool _showPurchaseHistory = false;
  bool _showFollowedSellers = true;
  bool _showReviews = true;

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
        final borderColor = isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05);
        final vividGreen = const Color(0xFF10B981);
        final dangerColor = const Color(0xFFfc424d);
        final subtextColor = isDark ? const Color(0xFF64748b) : const Color(0xFF64748b);

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
              'Privacidad del Perfil',
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                fontFamily: 'Plus Jakarta Sans',
              ),
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section 1: VISIBILIDAD DEL PERFIL
                      _buildSectionHeader('VISIBILIDAD DEL PERFIL', primaryColor),
                      const SizedBox(height: 12),
                      _buildSettingsGroup(
                        surfaceColor: surfaceColor,
                        borderColor: borderColor,
                        children: [
                          _buildSwitchTile(
                            title: 'Perfil público',
                            subtitle: 'Permitir que otros me encuentren',
                            value: _publicProfile,
                            textColor: textColor,
                            subtextColor: subtextColor,
                            activeColor: vividGreen,
                            onChanged: (val) => setState(() => _publicProfile = val),
                          ),
                          _buildDivider(borderColor),
                          _buildSwitchTile(
                            title: 'Mostrar mi ubicación exacta',
                            value: _showLocation,
                            textColor: textColor,
                            activeColor: vividGreen,
                            onChanged: (val) => setState(() => _showLocation = val),
                          ),
                          _buildDivider(borderColor),
                          _buildSwitchTile(
                            title: 'Mostrar fecha de registro',
                            value: _showRegistrationDate,
                            textColor: textColor,
                            activeColor: vividGreen,
                            onChanged: (val) => setState(() => _showRegistrationDate = val),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Section 2: ACTIVIDAD Y NEGOCIACIONES
                      _buildSectionHeader('ACTIVIDAD Y NEGOCIACIONES', primaryColor),
                      const SizedBox(height: 12),
                      _buildSettingsGroup(
                        surfaceColor: surfaceColor,
                        borderColor: borderColor,
                        children: [
                          _buildSwitchTile(
                            title: 'Mostrar mi historial de compras',
                            value: _showPurchaseHistory,
                            textColor: textColor,
                            activeColor: vividGreen,
                            onChanged: (val) => setState(() => _showPurchaseHistory = val),
                          ),
                          _buildDivider(borderColor),
                          _buildSwitchTile(
                            title: 'Mostrar vendedores que sigo',
                            value: _showFollowedSellers,
                            textColor: textColor,
                            activeColor: vividGreen,
                            onChanged: (val) => setState(() => _showFollowedSellers = val),
                          ),
                          _buildDivider(borderColor),
                          _buildSwitchTile(
                            title: 'Mostrar mis reseñas a otros',
                            value: _showReviews,
                            textColor: textColor,
                            activeColor: vividGreen,
                            onChanged: (val) => setState(() => _showReviews = val),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Section 3: SEGURIDAD
                      _buildSectionHeader('SEGURIDAD', primaryColor),
                      const SizedBox(height: 12),
                      _buildSettingsGroup(
                        surfaceColor: surfaceColor,
                        borderColor: borderColor,
                        children: [
                          _buildActionTile(
                            title: 'Usuarios Reportados',
                            icon: Icons.block,
                            textColor: textColor,
                            iconColor: subtextColor,
                            onTap: () => context.push('/reported-users'),
                          ),
                          _buildDivider(borderColor),
                          _buildActionTile(
                            title: 'Eliminar mi cuenta',
                            icon: Icons.delete_forever,
                            textColor: dangerColor,
                            iconColor: dangerColor,
                            onTap: () {},
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      Center(
                        child: Text(
                          'Tus datos son procesados siguiendo nuestra\npolítica de protección de datos personales de El Mercadito.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: subtextColor,
                            fontSize: 10,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),

              // Bottom Action Bar
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
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Configuración de privacidad guardada'),
                            backgroundColor: primaryColor,
                          ),
                        );
                      },
                      icon: const Icon(Icons.save, color: Colors.white),
                      label: const Text(
                        'Guardar Configuración',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        shadowColor: primaryColor.withOpacity(0.4),
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

  Widget _buildSectionHeader(String title, Color primaryColor) {
    return Text(
      title,
      style: TextStyle(
        color: primaryColor,
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildSettingsGroup({required Color surfaceColor, required Color borderColor, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    String? subtitle,
    required bool value,
    required Color textColor,
    Color? subtextColor,
    required Color activeColor,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
      ),
      subtitle: subtitle != null ? Text(
        subtitle,
        style: TextStyle(
          color: subtextColor,
          fontSize: 13,
        ),
      ) : null,
      value: value,
      activeColor: activeColor,
      onChanged: onChanged,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildActionTile({
    required String title,
    required IconData icon,
    required Color textColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: iconColor.withOpacity(0.5)),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildDivider(Color borderColor) {
    return Divider(height: 1, thickness: 1, color: borderColor);
  }
}
