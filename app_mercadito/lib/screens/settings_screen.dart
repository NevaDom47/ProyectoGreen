import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../main.dart'; // import appThemeMode global variable
import '../theme/app_theme.dart';
import '../theme/theme_controller.dart';
import '../services/notification_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeMode,
      builder: (context, currentMode, _) {
        final isDark = currentMode == ThemeMode.dark;
        
        final bgColor = isDark ? AppTheme.darkBackground : AppTheme.lightBackground;
        final surfaceColor = isDark ? AppTheme.darkCard : AppTheme.lightCard;
        final primaryColor = isDark ? AppTheme.darkPrimary : AppTheme.lightPrimary;
        final textColor = isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;
        final subtextColor = isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary;
        final borderColor = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;

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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Group 1: Appearance (Día - Noche - Automático)
                  _buildSectionHeader('PREFERENCIA VISUAL', subtextColor),
                  ValueListenableBuilder<AppThemePreference>(
                    valueListenable: ThemeController.preference,
                    builder: (context, currentPreference, _) {
                      return _buildAppearanceGroup(
                        surfaceColor: surfaceColor,
                        borderColor: borderColor,
                        textColor: textColor,
                        subtextColor: subtextColor,
                        primaryColor: primaryColor,
                        isDark: isDark,
                        currentPreference: currentPreference,
                      );
                    },
                  ),

                  // Group 2: Security & Account
                  const SizedBox(height: 24),
                  _buildSectionHeader('SEGURIDAD Y CUENTA', subtextColor),
                  ValueListenableBuilder<NotificationPreferences>(
                    valueListenable: NotificationService().preferences,
                    builder: (context, prefs, _) {
                      return _buildSettingsGroup(
                        surfaceColor: surfaceColor,
                        borderColor: borderColor,
                        children: [
                          _buildSwitchSettingsTile(
                            title: 'Notificaciones',
                            subtitle: prefs.notificationsEnabled
                                ? 'Alertas y avisos activos'
                                : 'Inactivas (icono oculto en el inicio)',
                            icon: Icons.notifications_active,
                            value: prefs.notificationsEnabled,
                            textColor: textColor,
                            subtextColor: subtextColor,
                            activeColor: primaryColor,
                            isDark: isDark,
                            onChanged: (val) {
                              NotificationService().toggleNotificationsEnabled(val);
                            },
                          ),
                          if (prefs.notificationsEnabled) ...[
                            _buildDivider(borderColor),
                            _buildSettingsTile(
                              'Configuración de Alertas',
                              Icons.tune,
                              textColor,
                              true,
                              'Personalizadas',
                              isDark: isDark,
                              onTap: () => context.push('/alerts'),
                            ),
                          ],
                          _buildDivider(borderColor),
                          _buildSettingsTile(
                            'Cambio de Contraseña',
                            Icons.lock_reset,
                            textColor,
                            true,
                            null,
                            isDark: isDark,
                            onTap: () => context.push('/change-password'),
                          ),
                          _buildDivider(borderColor),
                          _buildSettingsTile(
                            'Privacidad',
                            Icons.admin_panel_settings,
                            textColor,
                            true,
                            null,
                            isDark: isDark,
                            onTap: () => context.push('/privacy'),
                          ),
                        ],
                      );
                    },
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
                            isDark: isDark,
                            onTap: () => context.push('/language'),
                          ),
                        ],
                      );
                    },
                  ),

                  // Footer Text
                  const SizedBox(height: 40),
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'EL MERCADITO V2.4.1 (EMERALD HARVEST)',
                          style: TextStyle(
                            color: subtextColor.withValues(alpha: 0.6),
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Modo Nocturno Adaptativo & Zona Horaria',
                          style: TextStyle(
                            color: subtextColor.withValues(alpha: 0.5),
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppearanceGroup({
    required Color surfaceColor,
    required Color borderColor,
    required Color textColor,
    required Color subtextColor,
    required Color primaryColor,
    required bool isDark,
    required AppThemePreference currentPreference,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkPrimary.withValues(alpha: 0.15) : const Color(0xFFDCE7E3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.palette_outlined,
                  size: 20,
                  color: isDark ? AppTheme.darkPrimary : const Color(0xFF285E44),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tema de la Aplicación',
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        fontFamily: 'Plus Jakarta Sans',
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Elige entre modo claro, nocturno o automático',
                      style: TextStyle(
                        color: subtextColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 3-Option Selector: Día - Noche - Automático
          Row(
            children: [
              Expanded(
                child: _buildThemeOptionCard(
                  title: 'Día',
                  subtitle: 'Claro',
                  icon: Icons.wb_sunny_rounded,
                  isSelected: currentPreference == AppThemePreference.day,
                  isDark: isDark,
                  primaryColor: primaryColor,
                  borderColor: borderColor,
                  surfaceColor: surfaceColor,
                  onTap: () => ThemeController.setPreference(AppThemePreference.day),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildThemeOptionCard(
                  title: 'Noche',
                  subtitle: 'Oscuro',
                  icon: Icons.nightlight_round,
                  isSelected: currentPreference == AppThemePreference.night,
                  isDark: isDark,
                  primaryColor: primaryColor,
                  borderColor: borderColor,
                  surfaceColor: surfaceColor,
                  onTap: () => ThemeController.setPreference(AppThemePreference.night),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildThemeOptionCard(
                  title: 'Automático',
                  subtitle: 'Zona horaria',
                  icon: Icons.schedule_rounded,
                  isSelected: currentPreference == AppThemePreference.automatic,
                  isDark: isDark,
                  primaryColor: primaryColor,
                  borderColor: borderColor,
                  surfaceColor: surfaceColor,
                  onTap: () => ThemeController.setPreference(AppThemePreference.automatic),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOptionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required bool isDark,
    required Color primaryColor,
    required Color borderColor,
    required Color surfaceColor,
    required VoidCallback onTap,
  }) {
    final activeBg = isDark
        ? AppTheme.darkPrimaryLight.withValues(alpha: 0.7)
        : AppTheme.lightPrimaryLight.withValues(alpha: 0.6);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? activeBg : (isDark ? AppTheme.darkSecondaryBackground : const Color(0xFFF9FAF9)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? primaryColor : borderColor,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? primaryColor
                        : (isDark ? AppTheme.darkCardElevated : Colors.white),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: isSelected
                        ? Colors.white
                        : (isDark ? AppTheme.darkIcon : AppTheme.lightIcon),
                  ),
                ),
                if (isSelected)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: const BoxDecoration(
                        color: AppTheme.functionalSuccess,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, size: 10, color: Colors.white),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? primaryColor : (isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? primaryColor : (isDark ? AppTheme.darkTextTertiary : AppTheme.lightTextTertiary),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
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

  Widget _buildSettingsTile(
    String title,
    IconData icon,
    Color textColor,
    bool showArrow,
    String? trailingText, {
    required bool isDark,
    VoidCallback? onTap,
  }) {
    final iconBgColor = isDark
        ? AppTheme.darkPrimary.withValues(alpha: 0.15)
        : const Color(0xFFDCE7E3);
    final iconColor = isDark ? AppTheme.darkPrimary : const Color(0xFF285E44);

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconBgColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(title, style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null)
            Text(
              trailingText,
              style: TextStyle(
                color: isDark ? AppTheme.darkPrimary : AppTheme.lightPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          if (trailingText != null && showArrow)
            const SizedBox(width: 8),
          if (showArrow)
            Icon(
              Icons.chevron_right,
              color: isDark ? AppTheme.darkTextTertiary : Colors.grey,
            ),
        ],
      ),
      onTap: onTap ?? () {},
    );
  }

  Widget _buildSwitchSettingsTile({
    required String title,
    String? subtitle,
    required IconData icon,
    required bool value,
    required Color textColor,
    Color? subtextColor,
    required Color activeColor,
    required bool isDark,
    required ValueChanged<bool> onChanged,
  }) {
    final iconBgColor = isDark
        ? AppTheme.darkPrimary.withValues(alpha: 0.15)
        : const Color(0xFFDCE7E3);
    final iconColor = isDark ? AppTheme.darkPrimary : const Color(0xFF285E44);

    return SwitchListTile(
      secondary: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconBgColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(title, style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
      subtitle: subtitle != null
          ? Text(subtitle, style: TextStyle(color: subtextColor, fontSize: 11))
          : null,
      value: value,
      activeThumbColor: activeColor,
      activeTrackColor: activeColor.withValues(alpha: 0.38),
      onChanged: onChanged,
    );
  }

  Widget _buildDivider(Color borderColor) {
    return Divider(height: 1, thickness: 1, color: borderColor);
  }
}
