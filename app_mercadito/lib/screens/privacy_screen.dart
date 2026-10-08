import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../main.dart'; // import appThemeMode global variable
import '../services/privacy_service.dart';
import '../services/user_session.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  // Comprador Privacy Options
  late bool _buyerShowProfilePicture;
  late bool _buyerShowName;
  late bool _buyerShowLocation;
  late bool _buyerShowPublicProfile;
  late bool _buyerShowNegotiationHistory;
  late bool _buyerShowLoyaltyLevel;
  late bool _buyerShowShoppingPreferences;
  late bool _buyerAllowProviderOffers;

  // Proveedor Privacy Options
  late bool _providerShowLocation;
  late bool _providerShowContactInfo;
  late bool _providerShowBusinessHours;
  late bool _providerShowOnlineStatus;
  late bool _providerShowLastSeen;

  @override
  void initState() {
    super.initState();

    final buyerSettings = PrivacyService.buyerSettings;
    _buyerShowProfilePicture = buyerSettings.showProfilePicture;
    _buyerShowName = buyerSettings.showName;
    _buyerShowLocation = buyerSettings.showLocation;
    _buyerShowPublicProfile = buyerSettings.showPublicProfile;
    _buyerShowNegotiationHistory = buyerSettings.showNegotiationHistory;
    _buyerShowLoyaltyLevel = buyerSettings.showLoyaltyLevel;
    _buyerShowShoppingPreferences = buyerSettings.showShoppingPreferences;
    _buyerAllowProviderOffers = buyerSettings.allowProviderOffers;

    final providerSettings = PrivacyService.providerSettings;
    _providerShowLocation = providerSettings.showLocation;
    _providerShowContactInfo = providerSettings.showContactInfo;
    _providerShowBusinessHours = providerSettings.showBusinessHours;
    _providerShowOnlineStatus = providerSettings.showOnlineStatus;
    _providerShowLastSeen = providerSettings.showLastSeen;
  }

  void _saveSettings(Color primaryColor) {
    final isProvider = UserSession.selectedRole == 'proveedor';

    if (isProvider) {
      PrivacyService.saveProviderSettings(
        ProviderPrivacySettings(
          showLocation: _providerShowLocation,
          showContactInfo: _providerShowContactInfo,
          showBusinessHours: _providerShowBusinessHours,
          showOnlineStatus: _providerShowOnlineStatus,
          showLastSeen: _providerShowLastSeen,
        ),
      );
    } else {
      PrivacyService.saveBuyerSettings(
        BuyerPrivacySettings(
          showProfilePicture: _buyerShowProfilePicture,
          showName: _buyerShowName,
          showLocation: _buyerShowLocation,
          showPublicProfile: _buyerShowPublicProfile,
          showNegotiationHistory: _buyerShowNegotiationHistory,
          showLoyaltyLevel: _buyerShowLoyaltyLevel,
          showShoppingPreferences: _buyerShowShoppingPreferences,
          allowProviderOffers: _buyerAllowProviderOffers,
        ),
      );
    }

    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Text('Configuración de privacidad guardada correctamente'),
            ),
          ],
        ),
        backgroundColor: primaryColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appThemeMode,
      builder: (context, currentMode, _) {
        final platformBrightness = MediaQuery.platformBrightnessOf(context);
        final isDark = currentMode == ThemeMode.dark ||
            (currentMode == ThemeMode.system && platformBrightness == Brightness.dark);

        final bgColor = isDark ? const Color(0xFF101815) : const Color(0xFFF7F9F8);
        final primaryColor = isDark ? const Color(0xFF67C83B) : const Color(0xFF285E44);
        final switchTrackColor = isDark ? const Color(0xFF67C83B).withValues(alpha: 0.38) : const Color(0xFFA5C2B7);
        final textColor = isDark ? const Color(0xFFF1F5F3) : const Color(0xFF20262B);
        final surfaceColor = isDark ? const Color(0xFF1C2924) : Colors.white;
        final borderColor = isDark ? const Color(0xFF2B3A34) : const Color(0xFFE2E7E4);
        final vividGreen = isDark ? const Color(0xFF67C83B) : const Color(0xFF285E44);
        final dangerColor = const Color(0xFFFF6B6B);
        final subtextColor = isDark ? const Color(0xFFAAB8B1) : const Color(0xFF697177);

        final isProvider = UserSession.selectedRole == 'proveedor';

        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            backgroundColor: bgColor,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: isDark ? textColor : const Color(0xFF285E44)),
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
            ),
            title: Text(
              'Privacidad del Perfil',
              style: TextStyle(
                color: isDark ? textColor : const Color(0xFF285E44),
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Role Banner (Shows logged-in role only, no switcher)
                      _buildRoleBanner(
                        surfaceColor: surfaceColor,
                        borderColor: borderColor,
                        primaryColor: primaryColor,
                        textColor: textColor,
                        subtextColor: subtextColor,
                        isProvider: isProvider,
                      ),
                      const SizedBox(height: 20),

                      if (!isProvider) ...[
                        // ================= COMPRADOR =================
                        _buildSectionHeader('IDENTIDAD Y VISIBILIDAD', primaryColor),
                        const SizedBox(height: 12),
                        _buildSettingsGroup(
                          surfaceColor: surfaceColor,
                          borderColor: borderColor,
                          children: [
                            _buildSwitchTile(
                              title: 'Mostrar foto de perfil',
                              subtitle: 'Permitir que otros usuarios vean tu imagen de perfil',
                              value: _buyerShowProfilePicture,
                              textColor: textColor,
                              subtextColor: subtextColor,
                              activeColor: vividGreen,
                              activeTrackColor: switchTrackColor,
                              onChanged: (val) => setState(() => _buyerShowProfilePicture = val),
                            ),
                            _buildDivider(borderColor),
                            _buildSwitchTile(
                              title: 'Mostrar nombre',
                              subtitle: 'Mostrar tu nombre real en lugar de identificador anónimo',
                              value: _buyerShowName,
                              textColor: textColor,
                              subtextColor: subtextColor,
                              activeColor: vividGreen,
                              activeTrackColor: switchTrackColor,
                              onChanged: (val) => setState(() => _buyerShowName = val),
                            ),
                            _buildDivider(borderColor),
                            _buildSwitchTile(
                              title: 'Mostrar ubicación',
                              subtitle: 'Permitir que otros vean tu sector o provincia aproximada',
                              value: _buyerShowLocation,
                              textColor: textColor,
                              subtextColor: subtextColor,
                              activeColor: vividGreen,
                              activeTrackColor: switchTrackColor,
                              onChanged: (val) => setState(() => _buyerShowLocation = val),
                            ),
                            _buildDivider(borderColor),
                            _buildSwitchTile(
                              title: 'Mostrar perfil público',
                              subtitle: 'Permitir que proveedores y otros usuarios exploren tu perfil',
                              value: _buyerShowPublicProfile,
                              textColor: textColor,
                              subtextColor: subtextColor,
                              activeColor: vividGreen,
                              activeTrackColor: switchTrackColor,
                              onChanged: (val) => setState(() => _buyerShowPublicProfile = val),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        _buildSectionHeader('ACTIVIDAD Y NEGOCIACIONES', primaryColor),
                        const SizedBox(height: 12),
                        _buildSettingsGroup(
                          surfaceColor: surfaceColor,
                          borderColor: borderColor,
                          children: [
                            _buildSwitchTile(
                              title: 'Mostrar Historial de negociaciones',
                              subtitle: 'Hacer visible tu registro de compras y acuerdos anteriores',
                              value: _buyerShowNegotiationHistory,
                              textColor: textColor,
                              subtextColor: subtextColor,
                              activeColor: vividGreen,
                              activeTrackColor: switchTrackColor,
                              onChanged: (val) => setState(() => _buyerShowNegotiationHistory = val),
                            ),
                            _buildDivider(borderColor),
                            _buildSwitchTile(
                              title: 'Mostrar Nivel de fidelidad',
                              subtitle: 'Mostrar tu insignia de nivel de cliente en la comunidad',
                              value: _buyerShowLoyaltyLevel,
                              textColor: textColor,
                              subtextColor: subtextColor,
                              activeColor: vividGreen,
                              activeTrackColor: switchTrackColor,
                              onChanged: (val) => setState(() => _buyerShowLoyaltyLevel = val),
                            ),
                            _buildDivider(borderColor),
                            _buildSwitchTile(
                              title: 'Mostrar Preferencia de compras',
                              subtitle: 'Permitir ver tus categorías y productos más solicitados',
                              value: _buyerShowShoppingPreferences,
                              textColor: textColor,
                              subtextColor: subtextColor,
                              activeColor: vividGreen,
                              activeTrackColor: switchTrackColor,
                              onChanged: (val) => setState(() => _buyerShowShoppingPreferences = val),
                            ),
                            _buildDivider(borderColor),
                            _buildSwitchTile(
                              title: 'Permitir que proveedores me envíen ofertas',
                              subtitle: 'Recibir propuestas directas y promociones personalizadas',
                              value: _buyerAllowProviderOffers,
                              textColor: textColor,
                              subtextColor: subtextColor,
                              activeColor: vividGreen,
                              activeTrackColor: switchTrackColor,
                              onChanged: (val) => setState(() => _buyerAllowProviderOffers = val),
                            ),
                          ],
                        ),
                      ] else ...[
                        // ================= PROVEEDOR =================
                        _buildSectionHeader('INFORMACIÓN COMERCIAL', primaryColor),
                        const SizedBox(height: 12),
                        _buildSettingsGroup(
                          surfaceColor: surfaceColor,
                          borderColor: borderColor,
                          children: [
                            _buildSwitchTile(
                              title: 'Mostrar ubicación',
                              subtitle: 'Permitir que compradores vean tu sector y distancia geográfica',
                              value: _providerShowLocation,
                              textColor: textColor,
                              subtextColor: subtextColor,
                              activeColor: vividGreen,
                              activeTrackColor: switchTrackColor,
                              onChanged: (val) => setState(() => _providerShowLocation = val),
                            ),
                            _buildDivider(borderColor),
                            _buildSwitchTile(
                              title: 'Mostrar información de contacto',
                              subtitle: 'Mostrar teléfono directo y botón de WhatsApp comercial',
                              value: _providerShowContactInfo,
                              textColor: textColor,
                              subtextColor: subtextColor,
                              activeColor: vividGreen,
                              activeTrackColor: switchTrackColor,
                              onChanged: (val) => setState(() => _providerShowContactInfo = val),
                            ),
                            _buildDivider(borderColor),
                            _buildSwitchTile(
                              title: 'Mostrar horario de atención',
                              subtitle: 'Mostrar estado abierto/cerrado y horario semanal',
                              value: _providerShowBusinessHours,
                              textColor: textColor,
                              subtextColor: subtextColor,
                              activeColor: vividGreen,
                              activeTrackColor: switchTrackColor,
                              onChanged: (val) => setState(() => _providerShowBusinessHours = val),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        _buildSectionHeader('ESTADO Y DISPONIBILIDAD', primaryColor),
                        const SizedBox(height: 12),
                        _buildSettingsGroup(
                          surfaceColor: surfaceColor,
                          borderColor: borderColor,
                          children: [
                            _buildSwitchTile(
                              title: 'Mostrar "En línea"',
                              subtitle: 'Indicador de disponibilidad activa en tiempo real',
                              value: _providerShowOnlineStatus,
                              textColor: textColor,
                              subtextColor: subtextColor,
                              activeColor: vividGreen,
                              activeTrackColor: switchTrackColor,
                              onChanged: (val) => setState(() => _providerShowOnlineStatus = val),
                            ),
                            _buildDivider(borderColor),
                            _buildSwitchTile(
                              title: 'Mostrar última conexión',
                              subtitle: 'Mostrar la hora o momento de tu actividad más reciente',
                              value: _providerShowLastSeen,
                              textColor: textColor,
                              subtextColor: subtextColor,
                              activeColor: vividGreen,
                              activeTrackColor: switchTrackColor,
                              onChanged: (val) => setState(() => _providerShowLastSeen = val),
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Section: SEGURIDAD
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
                            iconColor: isDark ? subtextColor : primaryColor,
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
                      onPressed: () => _saveSettings(primaryColor),
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
                        shadowColor: primaryColor.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRoleBanner({
    required Color surfaceColor,
    required Color borderColor,
    required Color primaryColor,
    required Color textColor,
    required Color subtextColor,
    required bool isProvider,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isProvider ? Icons.storefront_outlined : Icons.person_outline,
              color: primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ROL DE CUENTA',
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Rol activo: ${isProvider ? 'Proveedor' : 'Comprador'}',
                  style: TextStyle(
                    color: subtextColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: primaryColor.withValues(alpha: 0.25)),
            ),
            child: Text(
              isProvider ? 'Proveedor' : 'Comprador',
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
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

  Widget _buildSettingsGroup({
    required Color surfaceColor,
    required Color borderColor,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
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
    required Color activeTrackColor,
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
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                color: subtextColor,
                fontSize: 13,
              ),
            )
          : null,
      value: value,
      activeThumbColor: activeColor,
      activeTrackColor: activeTrackColor,
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
      trailing: Icon(Icons.chevron_right, color: iconColor.withValues(alpha: 0.5)),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildDivider(Color borderColor) {
    return Divider(height: 1, thickness: 1, color: borderColor);
  }
}
