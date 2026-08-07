import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AnimatedDiscountBadge extends StatefulWidget {
  final String discountText;
  final bool isExpired;

  const AnimatedDiscountBadge({
    super.key,
    required this.discountText,
    this.isExpired = false,
  });

  @override
  State<AnimatedDiscountBadge> createState() => _AnimatedDiscountBadgeState();
}

class _AnimatedDiscountBadgeState extends State<AnimatedDiscountBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    if (!widget.isExpired) {
      _controller.repeat(reverse: true);
    }

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(AnimatedDiscountBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isExpired != widget.isExpired) {
      if (widget.isExpired) {
        _controller.stop();
        _controller.reset();
      } else {
        _controller.repeat(reverse: true);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isExpired) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF64748B).withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.timer_off_outlined,
              color: Colors.white,
              size: 13,
            ),
            const SizedBox(width: 3),
            Text(
              'Expirado',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      );
    }

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFFD9312).withValues(alpha: 0.88),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.85),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFD9312).withValues(alpha: 0.45),
              blurRadius: 8,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.local_fire_department,
              color: Colors.white,
              size: 13,
            ),
            const SizedBox(width: 3),
            Text(
              widget.discountText,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
