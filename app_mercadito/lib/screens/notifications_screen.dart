import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  int _selectedTab = 0;
  final List<String> _tabs = ['Todo', 'Pedidos', 'Ofertas', 'Cupones', 'Vendedores'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0f231d) : const Color(0xFFf5f8f7),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(theme, isDark),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 40),
                children: _buildNotificationsList(theme, isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0f231d).withValues(alpha: 0.9) : const Color(0xFFf5f8f7).withValues(alpha: 0.9),
        border: Border(bottom: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.1))),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: theme.colorScheme.primary),
                  onPressed: () => context.pop(),
                ),
                const SizedBox(width: 8),
                Text(
                  'Notificaciones',
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _tabs.length,
              separatorBuilder: (context, index) => const SizedBox(width: 24),
              itemBuilder: (context, index) {
                final isSelected = _selectedTab == index;
                return GestureDetector(
                  onTap: () => setState(() => _selectedTab = index),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: isSelected ? theme.colorScheme.primary : Colors.transparent, width: 2)),
                    ),
                    padding: const EdgeInsets.only(bottom: 12, top: 8),
                    child: Text(
                      _tabs[index],
                      style: TextStyle(
                        color: isSelected ? theme.colorScheme.primary : (isDark ? Colors.grey[400] : Colors.grey[500]),
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildNotificationsList(ThemeData theme, bool isDark) {
    List<Widget> items = [];

    // HOY
    List<Widget> hoyItems = [];
    if (_selectedTab == 0 || _selectedTab == 1) hoyItems.add(_buildDeliveryCard(theme, isDark));
    if (_selectedTab == 0 || _selectedTab == 2) hoyItems.add(_buildNegotiationCard(theme, isDark));
    if (_selectedTab == 0 || _selectedTab == 3) hoyItems.add(_buildCouponCard(theme, isDark));

    if (hoyItems.isNotEmpty) {
      items.add(_buildDateLabel('Hoy', isDark));
      for (int i = 0; i < hoyItems.length; i++) {
        items.add(hoyItems[i]);
        if (i < hoyItems.length - 1) items.add(const SizedBox(height: 12));
      }
      items.add(const SizedBox(height: 24));
    }

    // AYER
    List<Widget> ayerItems = [];
    if (_selectedTab == 0 || _selectedTab == 4) ayerItems.add(_buildVideoCard(theme, isDark));
    if (_selectedTab == 0 || _selectedTab == 1) ayerItems.add(_buildDeliveryCompletedCard(theme, isDark));

    if (ayerItems.isNotEmpty) {
      items.add(_buildDateLabel('Ayer', isDark));
      for (int i = 0; i < ayerItems.length; i++) {
        items.add(ayerItems[i]);
        if (i < ayerItems.length - 1) items.add(const SizedBox(height: 12));
      }
    }

    if (items.isEmpty) {
      items.add(
        Padding(
          padding: const EdgeInsets.only(top: 60),
          child: Column(
            children: [
              Icon(Icons.notifications_off_outlined, size: 64, color: isDark ? Colors.grey[700] : Colors.grey[300]),
              const SizedBox(height: 16),
              Text(
                'No hay notificaciones aquí',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.grey[500] : Colors.grey[400]),
              )
            ],
          ),
        ),
      );
    }

    return items;
  }

  Widget _buildDateLabel(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 4),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400], fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0),
      ),
    );
  }

  Widget _buildBaseCard({
    required ThemeData theme,
    required bool isDark,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required String time,
    required String description,
    Widget? bottomWidget,
    bool isInactive = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131c26) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.05)),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: iconBgColor, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold, 
                          fontSize: 16, 
                          color: isInactive ? (isDark ? Colors.grey[600] : Colors.grey[500]) : (isDark ? Colors.white : Colors.black87),
                          height: 1.2,
                        )
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      time, 
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? Colors.grey[400] : Colors.grey[400])
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description, 
                  style: TextStyle(
                    color: isInactive ? (isDark ? Colors.grey[600] : Colors.grey[500]) : (isDark ? Colors.grey[400] : Colors.grey[600]), 
                    fontSize: 14,
                    fontStyle: isInactive ? FontStyle.italic : FontStyle.normal,
                  )
                ),
                if (bottomWidget != null) ...[
                  const SizedBox(height: 8),
                  bottomWidget,
                ],
              ],
            ),
          ),
        ],
      )
    );
  }

  Widget _buildDeliveryCard(ThemeData theme, bool isDark) {
    return _buildBaseCard(
      theme: theme,
      isDark: isDark,
      icon: Icons.local_shipping,
      iconBgColor: theme.colorScheme.primary.withValues(alpha: 0.1),
      iconColor: theme.colorScheme.primary,
      title: 'Tu pedido #MERC-9928 está en camino!',
      time: '2 min',
      description: 'El transportista ya recolectó tus productos y llegará en aprox. 45 min.',
    );
  }

  Widget _buildNegotiationCard(ThemeData theme, bool isDark) {
    return _buildBaseCard(
      theme: theme,
      isDark: isDark,
      icon: Icons.chat_bubble,
      iconBgColor: theme.colorScheme.primary.withValues(alpha: 0.1),
      iconColor: theme.colorScheme.primary,
      title: 'Nueva oferta de Juan Pérez',
      time: '1 h',
      description: 'El productor Juan Pérez envió una contraoferta por tus Aguacates Hass.',
    );
  }

  Widget _buildCouponCard(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: isDark ? 0.1 : 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: theme.colorScheme.primary, borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.confirmation_number, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text('¡Cupón de 20% OFF disponible!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: theme.colorScheme.primary, height: 1.2))),
                    Text('3 h', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: theme.colorScheme.primary.withValues(alpha: 0.7))),
                  ],
                ),
                const SizedBox(height: 4),
                Text('Aprovecha este descuento exclusivo en frutas orgánicas solo por hoy.', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 14)),
              ],
            ),
          ),
        ],
      )
    );
  }

  Widget _buildVideoCard(ThemeData theme, bool isDark) {
    return _buildBaseCard(
      theme: theme,
      isDark: isDark,
      icon: Icons.videocam,
      iconBgColor: theme.colorScheme.primary.withValues(alpha: 0.1),
      iconColor: theme.colorScheme.primary,
      title: 'Nueva cosecha en Huerta Los Arcos',
      time: '1 d',
      description: 'Mira el nuevo video de la cosecha de tomates de esta mañana.',
      bottomWidget: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.network(
              'https://lh3.googleusercontent.com/aida-public/AB6AXuDZb3XgoNfixW3tUuuVb9VRAF1luoaxnuwBt5ENpHn4M4CkzTMafAzyTiMQQkkExG2MWzJXkKolAvVD4dh42jypWyNXmY7AFcxn0-k7UYRSUiKHTbhigyc813TJHOY4k3AnNExhG_ainPC6dWQHL16DGUohjp2-NAYdauQEAWumLseaZzHld-eYTqm3D5HbmZ39Va6EWGOWHpiF2Wu0dHsDsRnCxDLfuD_FDqnOL6Z_Icl0AeefsjY-WZQjeTeYo_6ySivyfnZQjFw',
              height: 96,
              width: double.infinity,
              fit: BoxFit.cover,
              headers: const {'User-Agent': 'Mozilla/5.0'},
              errorBuilder: (c, e, s) => Container(height: 96, color: Colors.grey[300]),
            ),
            Container(
              height: 96,
              width: double.infinity,
              color: Colors.black.withValues(alpha: 0.2), // Dark overlay filter
            ),
            const Icon(Icons.play_circle_outline, color: Colors.white, size: 36),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryCompletedCard(ThemeData theme, bool isDark) {
    return _buildBaseCard(
      theme: theme,
      isDark: isDark,
      icon: Icons.check_circle,
      iconBgColor: isDark ? Colors.grey[800]! : Colors.grey[200]!,
      iconColor: isDark ? Colors.grey[500]! : Colors.grey[400]!,
      title: 'Pedido entregado exitosamente',
      time: '1 d',
      description: 'Tu pedido de la semana pasada ha sido marcado como entregado.',
      isInactive: true,
    );
  }
}
