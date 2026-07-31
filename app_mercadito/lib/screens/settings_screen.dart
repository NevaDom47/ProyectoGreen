import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../main.dart'; // import appThemeMode global variable

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appThemeMode,
      builder: (context, currentMode, _) {
        final platformBrightness = MediaQuery.platformBrightnessOf(context);
        final isDark = currentMode == ThemeMode.dark || (currentMode == ThemeMode.system && platformBrightness == Brightness.dark);
        
        final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFf7faf5); // slate-900 / background
        final surfaceColor = isDark ? const Color(0xFF1E293B) : Colors.white; // slate-800 / surface-lowest
        final primaryColor = const Color(0xFF00462f);
        final textColor = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0f172a); // slate-100 / slate-900
        final subtextColor = isDark ? const Color(0xFF64748b) : const Color(0xFF64748b);
        final borderColor = isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05);

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
              'Configuración',
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                fontFamily: 'Plus Jakarta Sans',
              ),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Group 1: Appearance
                  _buildSectionHeader('PREFERENCIA VISUAL', subtextColor),
                  _buildSettingsGroup(
                    surfaceColor: surfaceColor,
                    borderColor: borderColor,
                    children: [
                      ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: 0.15), // vibrant emerald light
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(Icons.palette, color: Color(0xFF10B981)), // vivid green
                        ),
                        title: Text('Tema', style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(isDark ? 'Oscuro' : 'Claro', style: TextStyle(color: subtextColor, fontWeight: FontWeight.w600, fontSize: 13)),
                            const SizedBox(width: 12),
                            Switch(
                              value: isDark,
                              activeThumbColor: primaryColor,
                              onChanged: (val) {
                                // Toggle globally
                                appThemeMode.value = val ? ThemeMode.dark : ThemeMode.light;
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Group 2: Security & Account
                  const SizedBox(height: 24),
                  _buildSectionHeader('SEGURIDAD Y CUENTA', subtextColor),
                  _buildSettingsGroup(
                    surfaceColor: surfaceColor,
                    borderColor: borderColor,
                    children: [
                      _buildSettingsTile(
                        'Alertas',
                        Icons.notifications_active,
                        textColor,
                        true,
                        null,
                        onTap: () => context.push('/alerts'),
                      ),
                      _buildDivider(borderColor),
                      _buildSettingsTile(
                        'Cambio de Contraseña',
                        Icons.lock_reset,
                        textColor,
                        true,
                        null,
                        onTap: () => context.push('/change-password'),
                      ),
                      _buildDivider(borderColor),
                      _buildSettingsTile(
                        'Privacidad',
                        Icons.admin_panel_settings,
                        textColor,
                        true,
                        null,
                        onTap: () => context.push('/privacy'),
                      ),
                    ],
                  ),

                  // Group 3: App Config
                  const SizedBox(height: 24),
                  _buildSectionHeader('CONFIGURACIÓN GENERAL', subtextColor),
                  ValueListenableBuilder<String>(
                    valueListenable: appLanguage,
                    builder: (context, currentLang, _) {
                      return _buildSettingsGroup(
                        surfaceColor: surfaceColor,
                        borderColor: borderColor,
                        children: [
                          _buildSettingsTile(
                            'Idioma',
                            Icons.language,
                            textColor,
                            true,
                            currentLang,
                            onTap: () => context.push('/language'),
                          ),
                        ],
                      );
                    }
                  ),

                  // Footer Text
                  const SizedBox(height: 48),
                  Center(
                    child: Text(
                      'EL MERCADITO V2.4.1 (EMERALD HARVEST EDITION)',
                      style: TextStyle(
                        color: subtextColor.withValues(alpha: 0.5),
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsGroup({required Color surfaceColor, required Color borderColor, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Material(
          color: surfaceColor,
          child: Column(
            children: children,
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTile(String title, IconData icon, Color textColor, bool showArrow, String? trailingText, {VoidCallback? onTap}) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF10B981).withValues(alpha: 0.15), // vibrant emerald light
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(icon, color: const Color(0xFF10B981)), // vivid green
      ),
      title: Text(title, style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null)
            Text(trailingText, style: const TextStyle(color: Color(0xFF00462f), fontWeight: FontWeight.bold, fontSize: 13)),
          if (trailingText != null && showArrow)
            const SizedBox(width: 8),
          if (showArrow)
            const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
      onTap: onTap ?? () {},
    );
  }

  Widget _buildDivider(Color borderColor) {
    return Divider(height: 1, thickness: 1, color: borderColor);
  }
}
