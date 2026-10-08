import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/sound_service.dart';

/// Widget que envuelve un campo de formulario o input y le proporciona:
/// 1. Animación de vibración horizontal (Shake) ante errores.
/// 2. Borde resaltado en color rojo según el tema.
/// 3. Mensaje de error visible directamente debajo del campo con transición animada.
/// 4. Respuesta háptica sutil en dispositivos compatibles.
class AnimatedErrorField extends StatefulWidget {
  final Widget child;
  final String? errorText;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final bool animateOnChange;

  const AnimatedErrorField({
    super.key,
    required this.child,
    this.errorText,
    this.borderRadius = 12.0,
    this.padding = EdgeInsets.zero,
    this.animateOnChange = true,
  });

  @override
  State<AnimatedErrorField> createState() => AnimatedErrorFieldState();
}

class AnimatedErrorFieldState extends State<AnimatedErrorField>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    // Oscilación amortiguada: va de -8 a +8 y se atenúa a 0
    _shakeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.easeOut),
    );

    if (widget.errorText != null && widget.errorText!.isNotEmpty) {
      shake();
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedErrorField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si aparece un nuevo error o cambia el texto de error, ejecutamos vibración
    if (widget.animateOnChange &&
        widget.errorText != null &&
        widget.errorText!.isNotEmpty &&
        widget.errorText != oldWidget.errorText) {
      shake();
    }
  }

  /// Ejecuta la vibración háptica, sonido de error y la animación visual
  void shake() {
    HapticFeedback.lightImpact();
    SoundService.playError();
    _shakeController.forward(from: 0.0);
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool hasError = widget.errorText != null && widget.errorText!.trim().isNotEmpty;

    // Colores de error según tema (Rojo coral suave para noche, rojo institucional para día)
    final Color errorColor = isDark ? const Color(0xFFFF6B6B) : const Color(0xFFE03131);

    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        // Cálculo del desplazamiento horizontal senoidal amortiguado
        final double t = _shakeAnimation.value;
        final double offset = hasError
            ? sin(t * 3.5 * pi) * 9.0 * (1.0 - t)
            : 0.0;

        return Transform.translate(
          offset: Offset(offset, 0),
          child: child,
        );
      },
      child: Padding(
        padding: widget.padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Contenedor con borde rojo animado si hay error
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                border: Border.all(
                  color: hasError ? errorColor : Colors.transparent,
                  width: hasError ? 1.6 : 0.0,
                ),
              ),
              child: widget.child,
            ),

            // Mensaje de error inferior con animación de aparición
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 200),
              crossFadeState: hasError
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              firstChild: Padding(
                padding: const EdgeInsets.only(top: 6.0, left: 4.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 14,
                      color: errorColor,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        widget.errorText ?? '',
                        style: TextStyle(
                          color: errorColor,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              secondChild: const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
