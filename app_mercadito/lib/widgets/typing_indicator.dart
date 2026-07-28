import 'dart:math' as math;
import 'package:flutter/material.dart';

class TypingIndicator extends StatefulWidget {
  final String userName;
  final String avatarUrl;

  const TypingIndicator({
    super.key,
    this.userName = 'Finca La Esperanza',
    this.avatarUrl = 'https://lh3.googleusercontent.com/aida-public/AB6AXuB1-y62nOYyFJ87wJ8XFk4QalbfUVPOWB0Eo3ft82Kz8cCrvoW2OKvmm0tWikghVu0SiZD63IGVwe1Z68hWKVgLfFCGLZSj4q1G4kJNdQ9eJ1mer0RAA-8wAKGb3FWW_R7mvTRDQnxAA9aPbrnIQYDKHs5gpb17cjjifu7lwpgh6r1i6VUk5RsfzbkFVMhQJFSf5Vg8Exy7zAuGqJETv1ccQWXdu_oyrUnSiDBFvoiyr1MOCaJo6XJitj7IyKcK7pcjdxKJ_jbn9VE',
  });

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _startAnimationIfAllowed();
  }

  void _startAnimationIfAllowed() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final disableAnimations = MediaQuery.of(context).disableAnimations;
        if (!disableAnimations) {
          _controller.repeat();
        }
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Recheck animation settings if they change
    final disableAnimations = MediaQuery.of(context).disableAnimations;
    if (disableAnimations) {
      if (_controller.isAnimating) {
        _controller.stop();
      }
    } else {
      if (!_controller.isAnimating) {
        _controller.repeat();
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bubbleBg = isDark ? const Color(0xFF1f2937) : Colors.white;
    final dotColor = theme.colorScheme.primary;

    return Semantics(
      label: '${widget.userName} está escribiendo',
      child: Container(
        key: const ValueKey('typing_indicator_container'),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            CircleAvatar(
              radius: 14,
              backgroundImage: NetworkImage(widget.avatarUrl),
            ),
            const SizedBox(width: 8),
            Container(
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: bubbleBg,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(0),
                  bottomRight: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final disableAnimations = MediaQuery.of(context).disableAnimations;
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(3, (index) {
                      double bounceProgress = 0.0;
                      double opacity = 0.5;

                      if (disableAnimations) {
                        // Static dots for accessibility
                        opacity = 0.7;
                      } else {
                        // Staggered sine phase offsets: 0, 120 (2*pi/3), 240 (4*pi/3) degrees
                        final phaseOffset = index * (2 * math.pi / 3);
                        final radians = (2 * math.pi * _controller.value) - phaseOffset;
                        final sineValue = math.sin(radians);
                        
                        // Stay on ground in negative phase, bounce up in positive phase
                        bounceProgress = sineValue > 0 ? sineValue : 0.0;
                        opacity = 0.4 + (0.6 * bounceProgress);
                      }

                      return Padding(
                        padding: EdgeInsets.only(
                          right: index < 2 ? 4.0 : 0.0,
                          bottom: bounceProgress * 6.0, // bounce up to 6px
                        ),
                        child: Opacity(
                          opacity: opacity,
                          child: Container(
                            width: 6.5,
                            height: 6.5,
                            decoration: BoxDecoration(
                              color: dotColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
