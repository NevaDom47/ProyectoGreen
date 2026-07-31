import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AnimatedFavoriteButton extends StatefulWidget {
  final bool isFavorite;
  final VoidCallback onTap;
  final double size;
  final Color? backgroundColor;

  const AnimatedFavoriteButton({
    super.key, 
    required this.isFavorite, 
    required this.onTap,
    this.size = 20,
    this.backgroundColor,
  });

  @override
  State<AnimatedFavoriteButton> createState() => _AnimatedFavoriteButtonState();
}

class _AnimatedFavoriteButtonState extends State<AnimatedFavoriteButton> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late AnimationController _lottieController;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.4).chain(CurveTween(curve: Curves.easeOutCubic)), weight: 40),
      TweenSequenceItem(tween: Tween<double>(begin: 1.4, end: 1.0).chain(CurveTween(curve: Curves.elasticIn)), weight: 60),
    ]).animate(_controller);

    _lottieController = AnimationController(vsync: this);
    _lottieController.value = widget.isFavorite ? 1.0 : 0.0;
  }

  @override
  void didUpdateWidget(AnimatedFavoriteButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isFavorite != widget.isFavorite) {
      if (widget.isFavorite) {
        _lottieController.forward(from: 0.0);
      } else {
        _lottieController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _lottieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onTap();
        _controller.forward(from: 0.0);
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? Colors.white.withValues(alpha: 0.9),
            shape: BoxShape.circle,
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
          ),
          child: SizedBox(
            width: widget.size * 1.5,
            height: widget.size * 1.5,
            child: Lottie.asset(
              'assets/animations/Favorito2.json',
              controller: _lottieController,
              onLoaded: (composition) {
                _lottieController.duration = composition.duration;
              },
              delegates: LottieDelegates(
                values: [
                  ValueDelegate.color(
                    const ['**', 'green', '**'],
                    value: const Color(0xFFFC424D),
                  ),
                  ValueDelegate.color(
                    const ['**', 'grey', '**'],
                    value: Colors.grey[400]!,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
