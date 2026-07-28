import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final int chatBadgeCount;

  const CustomBottomNavBar({
    super.key, 
    required this.currentIndex,
    this.chatBadgeCount = 5, // Default dummy counter
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 8, top: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111827) : Colors.white,
        border: Border(top: BorderSide(color: isDark ? const Color(0xFF424242) : const Color(0xFFEEEEEE))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildNavIcon(
            icon: Icons.home,
            label: 'Inicio',
            isActive: currentIndex == 0,
            theme: theme,
            onTap: () {
              if (currentIndex != 0) context.go('/home');
            },
          ),
          _buildNavIcon(
            icon: Icons.shopping_cart_outlined,
            activeIcon: Icons.shopping_cart,
            label: 'Carrito',
            isActive: currentIndex == 1,
            theme: theme,
            onTap: () {
              if (currentIndex != 1) context.go('/cart');
            },
          ),
          _buildCenterNavIcon(
            icon: Icons.storefront,
            label: 'Mercado',
            isActive: currentIndex == 2,
            theme: theme,
            isDark: isDark,
          ),
          _buildNavIcon(
            icon: Icons.favorite_border,
            activeIcon: Icons.favorite,
            label: 'Favoritos',
            isActive: currentIndex == 3,
            theme: theme,
            onTap: () {
              if (currentIndex != 3) context.go('/favorites');
            },
          ),
          _buildNavIcon(
            icon: Icons.chat_bubble_outline,
            activeIcon: Icons.chat_bubble,
            label: 'Chats',
            isActive: currentIndex == 4,
            badgeCount: chatBadgeCount,
            theme: theme,
            onTap: () {
              // Si no estamos en chats, usamos go o push según sea necesario. 
              // go es mejor para top-level navigation, pero si no está en la base, usamos push o go dependiendo de tu estructura de router.
              // En este caso, asumiremos que chats es top-level screen a partir de ahora al tener barra inferior.
              if (currentIndex != 4) context.go('/chats'); 
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNavIcon({
    required IconData icon,
    IconData? activeIcon,
    required String label,
    required bool isActive,
    required ThemeData theme,
    int badgeCount = 0,
    VoidCallback? onTap,
  }) {
    final displayIcon = (isActive && activeIcon != null) ? activeIcon : icon;
    
    Widget iconWidget = Icon(displayIcon, color: isActive ? theme.colorScheme.primary : const Color(0xFF9E9E9E), size: 28);

    if (badgeCount > 0) {
      iconWidget = Stack(
        clipBehavior: Clip.none,
        children: [
          iconWidget,
          Positioned(
            right: -4,
            top: -4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                badgeCount > 99 ? '99+' : badgeCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  height: 1.0,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      );
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          iconWidget,
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: isActive ? theme.colorScheme.primary : const Color(0xFF9E9E9E), fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildCenterNavIcon({
    required IconData icon,
    required String label,
    required bool isActive,
    required ThemeData theme,
    required bool isDark,
  }) {
    final color = isActive ? theme.colorScheme.primary : const Color(0xFF9E9E9E);
    
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const SizedBox(height: 32),
            Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
        Positioned(
          bottom: 22,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isActive ? theme.colorScheme.primary : (isDark ? const Color(0xFF1f2937) : Colors.white),
              shape: BoxShape.circle,
              border: Border.all(color: isActive ? Colors.transparent : (isDark ? const Color(0xFF616161) : const Color(0xFFE0E0E0)), width: 2),
              boxShadow: [
                if (isActive) 
                  BoxShadow(color: theme.colorScheme.primary.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))
                else 
                  const BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
              ],
            ),
            child: Icon(icon, color: isActive ? Colors.white : const Color(0xFF9E9E9E), size: 28),
          ),
        ),
      ],
    );
  }
}
