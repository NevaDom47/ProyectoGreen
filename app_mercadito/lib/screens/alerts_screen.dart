import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../main.dart'; // import appThemeMode global variable
import '../services/notification_service.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  late bool _notificationsEnabled;
  late bool _pushEnabled;
  late bool _inAppEnabled;
  late bool _quietHoursEnabled;
  late bool _allowUrgentDuringQuietHours;

  // Pedidos y Negociaciones
  late bool _orderUpdates;
  late bool _newMessages;
  late bool _newCounterOffers;

  // Ofertas y Cupones
  late bool _flashSales;
  late bool _newCoupons;

  // Alertas de Mercado y Productores
  late bool _priceDrops;
  late bool _newProducts;
  late bool _marketTrends;
  late bool _smartRecommendations;

  @override
  void initState() {
    super.initState();
    final prefs = NotificationService().preferences.value;
    _notificationsEnabled = prefs.notificationsEnabled;
    _pushEnabled = prefs.pushEnabled;
    _inAppEnabled = prefs.inAppEnabled;
    _quietHoursEnabled = prefs.quietHoursEnabled;
    _allowUrgentDuringQuietHours = prefs.allowUrgentDuringQuietHours;
    _orderUpdates = prefs.orderUpdates;
    _newMessages = prefs.chatMessages;
    _newCounterOffers = prefs.counterOffers;
    _flashSales = prefs.flashSales;
    _newCoupons = prefs.newCoupons;
    _priceDrops = prefs.priceDrops;
    _newProducts = prefs.followedSellers;
    _marketTrends = prefs.marketTrends;
    _smartRecommendations = prefs.smartRecommendations;
  }

  void _savePreferences(Color primaryColor) {
    final current = NotificationService().preferences.value;
    final updated = current.copyWith(
      notificationsEnabled: _notificationsEnabled,
      pushEnabled: _pushEnabled,
      inAppEnabled: _inAppEnabled,
      quietHoursEnabled: _quietHoursEnabled,
      allowUrgentDuringQuietHours: _allowUrgentDuringQuietHours,
      orderUpdates: _orderUpdates,
      chatMessages: _newMessages,
      counterOffers: _newCounterOffers,
      flashSales: _flashSales,
      newCoupons: _newCoupons,
      priceDrops: _priceDrops,
      followedSellers: _newProducts,
      marketTrends: _marketTrends,
      smartRecommendations: _smartRecommendations,
    );
    NotificationService().updatePreferences(updated);
    context.pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Preferencias guardadas'),
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
        final isDark = currentMode == ThemeMode.dark || (currentMode == ThemeMode.system && platformBrightness == Brightness.dark);
        
        final bgColor = isDark ? const Color(0xFF101815) : const Color(0xFFF7F9F8);
        final primaryColor = isDark ? const Color(0xFF67C83B) : const Color(0xFF365D46);
        final textColor = isDark ? const Color(0xFFF1F5F3) : const Color(0xFF20262B);
        final subtextColor = isDark ? const Color(0xFFAAB8B1) : const Color(0xFF64748B);
        final surfaceColor = isDark ? const Color(0xFF1C2924) : Colors.white;
        final borderColor = isDark ? const Color(0xFF2B3A34) : const Color(0xFFE2E7E4);
        final vividGreen = isDark ? const Color(0xFF67C83B) : const Color(0xFF365D46);

        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            backgroundColor: bgColor,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: isDark ? textColor : const Color(0xFF365D46)),
              onPressed: () => context.pop(),
            ),
            title: Text(
              'Configuración de Alertas',
              style: TextStyle(
                color: isDark ? textColor : const Color(0xFF365D46),
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
                      // Section 0: Master Toggle (Inactivar Notificaciones)
                      _buildSectionHeader(
                        context,
                        title: 'ESTADO DE NOTIFICACIONES',
                        icon: Icons.power_settings_new_rounded,
                        primaryColor: vividGreen,
                      ),
                      const SizedBox(height: 10),
                      _buildSettingsGroup(
                        surfaceColor: surfaceColor,
                        borderColor: borderColor,
                        children: [
                          _buildSwitchTile(
                            title: 'Permitir Notificaciones',
                            subtitle: _notificationsEnabled
                                ? 'Alertas y avisos activos en toda la aplicación'
                                : 'Notificaciones inactivas (icono oculto en el inicio)',
                            value: _notificationsEnabled,
                            textColor: textColor,
                            subtextColor: subtextColor,
                            activeColor: vividGreen,
                            onChanged: (val) {
                              setState(() {
                                _notificationsEnabled = val;
                                if (!val) {
                                  _pushEnabled = false;
                                  _inAppEnabled = false;
                                  _quietHoursEnabled = false;
                                  _allowUrgentDuringQuietHours = false;
                                  _orderUpdates = false;
                                  _newMessages = false;
                                  _newCounterOffers = false;
                                  _flashSales = false;
                                  _newCoupons = false;
                                  _priceDrops = false;
                                  _newProducts = false;
                                  _marketTrends = false;
                                  _smartRecommendations = false;
                                } else {
                                  _pushEnabled = true;
                                  _inAppEnabled = true;
                                  _quietHoursEnabled = true;
                                  _allowUrgentDuringQuietHours = true;
                                  _orderUpdates = true;
                                  _newMessages = true;
                                  _newCounterOffers = true;
                                  _flashSales = true;
                                  _newCoupons = true;
                                  _priceDrops = true;
                                  _newProducts = true;
                                  _marketTrends = true;
                                  _smartRecommendations = true;
                                }
                              });
                            },
                          ),
                        ],
                      ),
                      if (!_notificationsEnabled) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF241C1A) : const Color(0xFFFFF4F2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFBD4437).withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline, color: Color(0xFFBD4437), size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Las notificaciones están inactivas. No se mostrará el icono en el inicio ni recibirás alertas sonoras o emergentes.',
                                  style: TextStyle(
                                    color: isDark ? const Color(0xFFFFB4AB) : const Color(0xFF93000A),
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 20),

                      // Sections container (dimmed if notifications disabled)
                      Opacity(
                        opacity: _notificationsEnabled ? 1.0 : 0.5,
                        child: AbsorbPointer(
                          absorbing: !_notificationsEnabled,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Section 1: Canales de Entrega
                              _buildSectionHeader(
                                context,
                                title: 'Canales de Entrega',
                                icon: Icons.send_to_mobile_rounded,
                                primaryColor: vividGreen,
                              ),
                              const SizedBox(height: 10),
                              _buildSettingsGroup(
                                surfaceColor: surfaceColor,
                                borderColor: borderColor,
                                children: [
                                  _buildSwitchTile(
                                    title: 'Notificaciones Push',
                                    subtitle: 'Alertas directas en la barra de tu dispositivo',
                                    value: _pushEnabled,
                                    textColor: textColor,
                                    subtextColor: subtextColor,
                                    activeColor: vividGreen,
                                    onChanged: (val) => setState(() => _pushEnabled = val),
                                  ),
                                  _buildDivider(borderColor),
                                  _buildSwitchTile(
                                    title: 'Notificaciones In-App',
                                    subtitle: 'Bandeja de avisos dentro de El Mercadito',
                                    value: _inAppEnabled,
                                    textColor: textColor,
                                    subtextColor: subtextColor,
                                    activeColor: vividGreen,
                                    onChanged: (val) => setState(() => _inAppEnabled = val),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 20),

                              // Section 2: Descanso y Horario Silencioso
                              _buildSectionHeader(
                                context,
                                title: 'Descanso y Horario Silencioso',
                                icon: Icons.bedtime_outlined,
                                primaryColor: vividGreen,
                              ),
                              const SizedBox(height: 10),
                              _buildSettingsGroup(
                                surfaceColor: surfaceColor,
                                borderColor: borderColor,
                                children: [
                                  _buildSwitchTile(
                                    title: 'Horario silencioso (10:00 PM – 7:00 AM)',
                                    subtitle: 'Silencia avisos nocturnos para proteger tu descanso',
                                    value: _quietHoursEnabled,
                                    textColor: textColor,
                                    subtextColor: subtextColor,
                                    activeColor: vividGreen,
                                    onChanged: (val) => setState(() => _quietHoursEnabled = val),
                                  ),
                                  _buildDivider(borderColor),
                                  CheckboxListTile(
                                    title: Text(
                                      'Permitir eventos urgentes durante descanso',
                                      style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w500),
                                    ),
                                    subtitle: Text(
                                      'Pagos rechazados, pedidos cancelados o contingencias',
                                      style: TextStyle(color: subtextColor, fontSize: 11),
                                    ),
                                    value: _allowUrgentDuringQuietHours,
                                    activeColor: vividGreen,
                                    checkColor: Colors.white,
                                    controlAffinity: ListTileControlAffinity.leading,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                                    onChanged: (val) => setState(() => _allowUrgentDuringQuietHours = val ?? true),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 20),

                              // Section 3: Pedidos y Negociaciones
                              _buildSectionHeader(
                                context,
                                title: 'Pedidos y Negociaciones',
                                icon: Icons.handshake,
                                primaryColor: vividGreen,
                              ),
                              const SizedBox(height: 10),
                              _buildSettingsGroup(
                                surfaceColor: surfaceColor,
                                borderColor: borderColor,
                                children: [
                                  _buildSwitchTile(
                                    title: 'Actualizaciones de pedido',
                                    subtitle: 'Estatus del camión, despachos y entrega',
                                    value: _orderUpdates,
                                    textColor: textColor,
                                    subtextColor: subtextColor,
                                    activeColor: vividGreen,
                                    onChanged: (val) => setState(() => _orderUpdates = val),
                                  ),
                                  _buildDivider(borderColor),
                                  _buildSwitchTile(
                                    title: 'Nuevos mensajes de chat',
                                    subtitle: 'Avisos directos en negociaciones activas',
                                    value: _newMessages,
                                    textColor: textColor,
                                    subtextColor: subtextColor,
                                    activeColor: vividGreen,
                                    onChanged: (val) => setState(() => _newMessages = val),
                                  ),
                                  _buildDivider(borderColor),
                                  _buildSwitchTile(
                                    title: 'Nuevas contraofertas',
                                    subtitle: 'Propuestas directas de precio de proveedores',
                                    value: _newCounterOffers,
                                    textColor: textColor,
                                    subtextColor: subtextColor,
                                    activeColor: vividGreen,
                                    onChanged: (val) => setState(() => _newCounterOffers = val),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 20),

                              // Section 4: Ofertas y Cupones
                              _buildSectionHeader(
                                context,
                                title: 'Ofertas y Cupones',
                                icon: Icons.confirmation_number,
                                primaryColor: vividGreen,
                              ),
                              const SizedBox(height: 10),
                              _buildSettingsGroup(
                                surfaceColor: surfaceColor,
                                borderColor: borderColor,
                                children: [
                                  _buildSwitchTile(
                                    title: 'Ofertas relámpago',
                                    subtitle: 'Descuentos por tiempo limitado y productos en liquidación',
                                    value: _flashSales,
                                    textColor: textColor,
                                    subtextColor: subtextColor,
                                    activeColor: vividGreen,
                                    onChanged: (val) => setState(() => _flashSales = val),
                                  ),
                                  _buildDivider(borderColor),
                                  _buildSwitchTile(
                                    title: 'Nuevos cupones disponibles',
                                    subtitle: 'Cupones exclusivos y avisos de expiración',
                                    value: _newCoupons,
                                    textColor: textColor,
                                    subtextColor: subtextColor,
                                    activeColor: vividGreen,
                                    onChanged: (val) => setState(() => _newCoupons = val),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 20),

                              // Section 5: Alertas de Mercado y Productores
                              _buildSectionHeader(
                                context,
                                title: 'Alertas de Mercado',
                                icon: Icons.storefront,
                                primaryColor: vividGreen,
                              ),
                              const SizedBox(height: 10),
                              _buildSettingsGroup(
                                surfaceColor: surfaceColor,
                                borderColor: borderColor,
                                children: [
                                  _buildSwitchTile(
                                    title: 'Bajas de precio en favoritos',
                                    subtitle: 'Avisos cuando tus productos guardados bajan de precio',
                                    value: _priceDrops,
                                    textColor: textColor,
                                    subtextColor: subtextColor,
                                    activeColor: vividGreen,
                                    onChanged: (val) => setState(() => _priceDrops = val),
                                  ),
                                  _buildDivider(borderColor),
                                  _buildSwitchTile(
                                    title: 'Nuevos productos de vendedores seguidos',
                                    subtitle: 'Publicaciones y cosechas de tus vendedores seguidos',
                                    value: _newProducts,
                                    textColor: textColor,
                                    subtextColor: subtextColor,
                                    activeColor: vividGreen,
                                    onChanged: (val) => setState(() => _newProducts = val),
                                  ),
                                  _buildDivider(borderColor),
                                  _buildSwitchTile(
                                    title: 'Tendencias y radar de mercado',
                                    subtitle: 'Radar predictivo de precios y agro-noticias',
                                    value: _marketTrends,
                                    textColor: textColor,
                                    subtextColor: subtextColor,
                                    activeColor: vividGreen,
                                    onChanged: (val) => setState(() => _marketTrends = val),
                                  ),
                                  _buildDivider(borderColor),
                                  _buildSwitchTile(
                                    title: 'Recomendaciones inteligentes',
                                    subtitle: 'Sugerencias personalizadas según tu consumo',
                                    value: _smartRecommendations,
                                    textColor: textColor,
                                    subtextColor: subtextColor,
                                    activeColor: vividGreen,
                                    onChanged: (val) => setState(() => _smartRecommendations = val),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),

              // Footer Button
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
                      onPressed: () => _savePreferences(primaryColor),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        shadowColor: primaryColor.withValues(alpha: 0.4),
                      ),
                      child: const Text(
                        'Guardar Cambios',
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

  Widget _buildSectionHeader(BuildContext context, {required String title, required IconData icon, required Color primaryColor}) {
    return Row(
      children: [
        Icon(icon, color: primaryColor, size: 20),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: TextStyle(
            color: primaryColor,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
      ],
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
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                color: subtextColor,
                fontSize: 11,
              ),
            )
          : null,
      value: value,
      activeThumbColor: activeColor,
      activeTrackColor: activeColor.withValues(alpha: 0.38),
      onChanged: onChanged,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildDivider(Color borderColor) {
    return Divider(height: 1, thickness: 1, color: borderColor);
  }
}
