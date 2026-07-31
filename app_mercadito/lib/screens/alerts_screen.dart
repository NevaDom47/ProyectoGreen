import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../main.dart'; // import appThemeMode global variable

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  // Alertas de Mercado
  bool _priceDrops = true;
  bool _newProducts = true;

  // Pedidos y Negociaciones
  bool _orderUpdates = true;
  bool _newMessages = true;
  bool _newCounterOffers = false;

  // Ofertas y Cupones
  bool _newCoupons = false;
  bool _flashSales = true;

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
        final borderColor = isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05);
        final vividGreen = const Color(0xFF10B981);

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
              'Configuración de Alertas',
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
                      // Section 1: Alertas de Mercado
                      _buildSectionHeader(
                        context,
                        title: 'Alertas de Mercado',
                        icon: Icons.storefront,
                        primaryColor: vividGreen,
                      ),
                      const SizedBox(height: 12),
                      _buildSettingsGroup(
                        surfaceColor: surfaceColor,
                        borderColor: borderColor,
                        children: [
                          _buildSwitchTile(
                            title: 'Bajas de precio en favoritos',
                            value: _priceDrops,
                            textColor: textColor,
                            activeColor: vividGreen,
                            onChanged: (val) => setState(() => _priceDrops = val),
                          ),
                          _buildDivider(borderColor),
                          _buildSwitchTile(
                            title: 'Nuevos productos de vendedores seguidos',
                            value: _newProducts,
                            textColor: textColor,
                            activeColor: vividGreen,
                            onChanged: (val) => setState(() => _newProducts = val),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Section 2: Pedidos y Negociaciones
                      _buildSectionHeader(
                        context,
                        title: 'Pedidos y Negociaciones',
                        icon: Icons.handshake,
                        primaryColor: vividGreen,
                      ),
                      const SizedBox(height: 12),
                      _buildSettingsGroup(
                        surfaceColor: surfaceColor,
                        borderColor: borderColor,
                        children: [
                          _buildSwitchTile(
                            title: 'Actualizaciones de pedido',
                            value: _orderUpdates,
                            textColor: textColor,
                            activeColor: vividGreen,
                            onChanged: (val) => setState(() => _orderUpdates = val),
                          ),
                          _buildDivider(borderColor),
                          _buildSwitchTile(
                            title: 'Nuevos mensajes de chat',
                            value: _newMessages,
                            textColor: textColor,
                            activeColor: vividGreen,
                            onChanged: (val) => setState(() => _newMessages = val),
                          ),
                          _buildDivider(borderColor),
                          _buildSwitchTile(
                            title: 'Nuevas contraofertas',
                            value: _newCounterOffers,
                            textColor: textColor,
                            activeColor: vividGreen,
                            onChanged: (val) => setState(() => _newCounterOffers = val),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Section 3: Ofertas y Cupones
                      _buildSectionHeader(
                        context,
                        title: 'Ofertas y Cupones',
                        icon: Icons.confirmation_number,
                        primaryColor: vividGreen,
                      ),
                      const SizedBox(height: 12),
                      _buildSettingsGroup(
                        surfaceColor: surfaceColor,
                        borderColor: borderColor,
                        children: [
                          _buildSwitchTile(
                            title: 'Nuevos cupones disponibles',
                            value: _newCoupons,
                            textColor: textColor,
                            activeColor: vividGreen,
                            onChanged: (val) => setState(() => _newCoupons = val),
                          ),
                          _buildDivider(borderColor),
                          _buildSwitchTile(
                            title: 'Ofertas relámpago',
                            value: _flashSales,
                            textColor: textColor,
                            activeColor: vividGreen,
                            onChanged: (val) => setState(() => _flashSales = val),
                          ),
                        ],
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
                      onPressed: () {
                        // Guardar cambios: para esta demo solo hacemos pop
                        context.pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Preferencias guardadas'),
                            backgroundColor: primaryColor,
                          ),
                        );
                      },
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
        Icon(icon, color: primaryColor, size: 24),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: TextStyle(
            color: primaryColor,
            fontSize: 14,
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
    required bool value,
    required Color textColor,
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
      value: value,
      activeThumbColor: activeColor,
      onChanged: onChanged,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildDivider(Color borderColor) {
    return Divider(height: 1, thickness: 1, color: borderColor);
  }
}
