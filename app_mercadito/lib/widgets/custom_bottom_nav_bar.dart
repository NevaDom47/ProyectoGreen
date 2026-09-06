import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class CustomBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final int chatBadgeCount;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    this.chatBadgeCount = 5,
  });

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _currentPosition = 0.0;
  int _targetIndex = 0;

  final List<_NavItemData> _items = const [
    _NavItemData(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Inicio',
      route: '/home',
    ),
    _NavItemData(
      icon: Icons.shopping_cart_outlined,
      activeIcon: Icons.shopping_cart_rounded,
      label: 'Carrito',
      route: '/cart',
    ),
    _NavItemData(
      icon: Icons.storefront_outlined,
      activeIcon: Icons.storefront_rounded,
      label: 'Mercado',
      route: '/search',
    ),
    _NavItemData(
      icon: Icons.person_search_outlined,
      activeIcon: Icons.person_search_rounded,
      label: 'Proveedores',
      route: '/providers',
    ),
    _NavItemData(
      icon: Icons.chat_bubble_outline_rounded,
      activeIcon: Icons.chat_bubble_rounded,
      label: 'Chats',
      route: '/chats',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _targetIndex = (widget.currentIndex >= 0 && widget.currentIndex < _items.length)
        ? widget.currentIndex
        : 0;
    _currentPosition = _targetIndex.toDouble();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    );

    _animation = Tween<double>(begin: _currentPosition, end: _currentPosition)
        .animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void didUpdateWidget(covariant CustomBottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != oldWidget.currentIndex) {
      final newIndex = (widget.currentIndex >= 0 && widget.currentIndex < _items.length)
          ? widget.currentIndex
          : _targetIndex;

      if (newIndex != _targetIndex) {
        _animateTo(newIndex);
      }
    }
  }

  void _animateTo(int newIndex) {
    _targetIndex = newIndex;
    _animation = Tween<double>(
      begin: _currentPosition,
      end: newIndex.toDouble(),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.forward(from: 0.0).then((_) {
      _currentPosition = newIndex.toDouble();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    HapticFeedback.lightImpact();
    if (widget.currentIndex != index) {
      _animateTo(index);
      context.go(_items[index].route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final barColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final bubbleColor = isDark ? const Color(0xFF0F172A) : Colors.white;
    final activeColor = isDark ? const Color(0xFF34D399) : const Color(0xFF00462F);
    final inactiveColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final shadowColor = isDark ? Colors.black.withValues(alpha: 0.45) : Colors.black.withValues(alpha: 0.09);
    final bubbleBorder = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    const double barHeight = 64.0;
    const double bubbleDiameter = 54.0;
    const double notchDepth = 22.0;
    const double notchWidth = 38.0;

    final isSelectionVisible = widget.currentIndex >= 0 && widget.currentIndex < _items.length;
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    final totalHeight = barHeight + bottomPadding;

    return Padding(
      padding: const EdgeInsets.only(top: 22),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final barWidth = constraints.maxWidth;
          final itemWidth = barWidth / _items.length;

          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final animPos = _animation.value;
              final activeX = (animPos + 0.5) * itemWidth;

              return SizedBox(
                height: totalHeight,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // 1. Curved Background with Smooth Notch Painter (Flush to screen edges)
                    CustomPaint(
                      size: Size(barWidth, totalHeight),
                      painter: _CurvedNavBarPainter(
                        activeIndex: isSelectionVisible ? animPos : -10.0,
                        itemCount: _items.length,
                        barColor: barColor,
                        shadowColor: shadowColor,
                        notchDepth: notchDepth,
                        notchWidth: notchWidth,
                      ),
                    ),

                    // 2. Interactive Navigation Items (Icon + Label)
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 0,
                      height: barHeight,
                      child: Row(
                          children: List.generate(_items.length, (index) {
                            final item = _items[index];
                            final distance = (animPos - index).abs();
                            // Inactive icon fades out as the bubble arrives over it
                            final iconOpacity = isSelectionVisible ? (distance / 0.5).clamp(0.0, 1.0) : 1.0;
                            final isActive = isSelectionVisible && index == _targetIndex;
                            final badge = (index == 4) ? widget.chatBadgeCount : 0;

                            return Expanded(
                              child: GestureDetector(
                                onTap: () => _onItemTapped(index),
                                behavior: HitTestBehavior.opaque,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Inactive Icon (Positioned in normal row)
                                    Positioned(
                                      top: 10,
                                      child: Opacity(
                                        opacity: iconOpacity,
                                        child: Stack(
                                          clipBehavior: Clip.none,
                                          alignment: Alignment.center,
                                          children: [
                                            Icon(
                                              item.icon,
                                              size: 24,
                                              color: inactiveColor,
                                            ),
                                            if (badge > 0)
                                              Positioned(
                                                right: -8,
                                                top: -4,
                                                child: _buildBadge(badge, isDark),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    // Label (Aligned along bottom of bar)
                                    Positioned(
                                      bottom: 8,
                                      child: AnimatedDefaultTextStyle(
                                        duration: const Duration(milliseconds: 200),
                                        style: TextStyle(
                                          fontFamily: 'Manrope',
                                          fontSize: isActive ? 10.5 : 9.5,
                                          fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                                          color: isActive ? activeColor : inactiveColor,
                                          letterSpacing: -0.2,
                                        ),
                                        child: Text(item.label),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ),
                      ),

                      // 3. Floating Elevated Circular Bubble
                      if (isSelectionVisible)
                        Positioned(
                          left: activeX - (bubbleDiameter / 2),
                          top: -(bubbleDiameter / 2) + 2, // Protrudes cleanly above the bar
                          child: GestureDetector(
                            onTap: () => _onItemTapped(_targetIndex),
                            child: Container(
                              width: bubbleDiameter,
                              height: bubbleDiameter,
                              decoration: BoxDecoration(
                                color: bubbleColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: bubbleBorder,
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: activeColor.withValues(alpha: isDark ? 0.25 : 0.20),
                                    blurRadius: 14,
                                    offset: const Offset(0, 4),
                                  ),
                                  BoxShadow(
                                    color: shadowColor,
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 220),
                                    transitionBuilder: (child, anim) => ScaleTransition(
                                      scale: anim,
                                      child: FadeTransition(opacity: anim, child: child),
                                    ),
                                    child: Icon(
                                      _items[_targetIndex].activeIcon,
                                      key: ValueKey('active_icon_$_targetIndex'),
                                      color: activeColor,
                                      size: 26,
                                    ),
                                  ),
                                  if (_targetIndex == 4 && widget.chatBadgeCount > 0)
                                    Positioned(
                                      right: 4,
                                      top: 4,
                                      child: _buildBadge(widget.chatBadgeCount, isDark),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      );
  }

  Widget _buildBadge(int count, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        count > 99 ? '99+' : count.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.bold,
          height: 1.0,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _NavItemData {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;

  const _NavItemData({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
  });
}

class _CurvedNavBarPainter extends CustomPainter {
  final double activeIndex;
  final int itemCount;
  final Color barColor;
  final Color shadowColor;
  final double notchDepth;
  final double notchWidth;

  _CurvedNavBarPainter({
    required this.activeIndex,
    required this.itemCount,
    required this.barColor,
    required this.shadowColor,
    this.notchDepth = 22.0,
    this.notchWidth = 38.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final itemWidth = size.width / itemCount;
    final activeX = (activeIndex + 0.5) * itemWidth;

    final paint = Paint()
      ..color = barColor
      ..style = PaintingStyle.fill;

    final path = Path();

    // Top-left starting point (flush to left edge)
    path.moveTo(0, 0);

    // If an item is active, draw the concave smooth notch
    if (activeIndex >= 0 && activeIndex < itemCount) {
      final leftScoop = (activeX - notchWidth).clamp(0.0, size.width);
      final rightScoop = (activeX + notchWidth).clamp(0.0, size.width);

      path.lineTo(leftScoop, 0);

      // Left cubic curve into notch trough
      path.cubicTo(
        activeX - (notchWidth * 0.55), 0,
        activeX - (notchWidth * 0.45), notchDepth,
        activeX, notchDepth,
      );

      // Right cubic curve out of notch trough
      path.cubicTo(
        activeX + (notchWidth * 0.45), notchDepth,
        activeX + (notchWidth * 0.55), 0,
        rightScoop, 0,
      );
    }

    // Top edge to top-right corner (flush)
    path.lineTo(size.width, 0);

    // Right edge down to bottom of screen (flush)
    path.lineTo(size.width, size.height);

    // Bottom edge to bottom-left corner (flush)
    path.lineTo(0, size.height);

    // Left edge back to origin
    path.lineTo(0, 0);

    path.close();

    // Draw soft shadow and main curved bar
    canvas.drawShadow(path, shadowColor, 10.0, false);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CurvedNavBarPainter oldDelegate) {
    return oldDelegate.activeIndex != activeIndex ||
        oldDelegate.barColor != barColor ||
        oldDelegate.shadowColor != shadowColor;
  }
}

