import 'package:flutter/material.dart';

/// Insignia oficial de verificación para perfiles de comerciantes y proveedores.
/// Presenta la roseta/estrella festoneada azul (#1D9BF0) con palomita blanca,
/// montada sobre una base circular blanca con relieve, idéntica a la insignia
/// de verificación de proveedores en Mercadito.
class VerifiedBadge extends StatelessWidget {
  final double size;
  final bool showWhiteCircle;
  final VoidCallback? onTap;
  final String? tooltip;

  const VerifiedBadge({
    super.key,
    this.size = 22,
    this.showWhiteCircle = true,
    this.onTap,
    this.tooltip,
  });

  /// Azul oficial de verificación Mercadito / Meta / Twitter Verified
  static const Color verifiedBlue = Color(0xFF1D9BF0);

  @override
  Widget build(BuildContext context) {
    Widget badge;

    if (showWhiteCircle) {
      badge = Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: size * 0.15,
              offset: Offset(0, size * 0.05),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            Icons.verified,
            color: verifiedBlue,
            size: size * 0.76,
          ),
        ),
      );
    } else {
      badge = SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: size * 0.50,
              height: size * 0.50,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            Icon(
              Icons.verified,
              color: verifiedBlue,
              size: size,
            ),
          ],
        ),
      );
    }

    if (tooltip != null && tooltip!.isNotEmpty) {
      badge = Tooltip(
        message: tooltip!,
        child: badge,
      );
    }

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: badge,
      );
    }

    return badge;
  }
}
