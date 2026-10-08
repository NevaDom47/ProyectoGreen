import 'package:flutter/material.dart';
import '../models/provider_map_item.dart';
import 'verified_badge.dart';

class ProviderMapPin extends StatelessWidget {
  final ProviderMapItem provider;
  final bool isSelected;
  final double currentZoom;
  final VoidCallback onTap;

  const ProviderMapPin({
    super.key,
    required this.provider,
    required this.isSelected,
    this.currentZoom = 8.2,
    required this.onTap,
  });

  static const IconData providerIcon = Icons.local_florist;

  /// Retorna el nivel de detalle según el nivel de zoom:
  /// 0: Solo pin compacto (zoom lejano < 7.8)
  /// 1: Pin + Píldora con Nombre y Reputación (zoom intermedio 7.8 a 10.5)
  /// 2: Pin + Tarjeta expandida con Nombre, Reputación, Especialidad, Distancia y Estado (zoom cercano >= 10.5)
  static int getZoomTier(double zoom) {
    if (zoom < 7.8) return 0;
    if (zoom < 10.5) return 1;
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    const primaryGreen = Color(0xFF285E44);
    const softMintBg = Color(0xFFEBF4EE);

    final tier = getZoomTier(currentZoom);
    final showDetails = isSelected || tier == 2;
    final showLabel = isSelected || tier >= 1;

    final cardBg = isDark ? const Color(0xFF16251F) : Colors.white;
    final textColor = isDark ? const Color(0xFFF1F5F3) : const Color(0xFF1E293B);
    final subtextColor = isDark ? const Color(0xFFAAB8B1) : const Color(0xFF64748B);
    final borderColor = isDark ? const Color(0xFF243B32) : const Color(0xFFCBD5E1);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: isSelected ? 1.08 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutBack,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. Floating Name & Reputation Badge
            if (showLabel) ...[
              _buildFloatingBadge(
                context: context,
                isDark: isDark,
                isDetailed: showDetails,
                cardBg: cardBg,
                textColor: textColor,
                subtextColor: subtextColor,
                borderColor: borderColor,
                primaryGreen: primaryGreen,
              ),
              const SizedBox(height: 3),
            ],

            // 2. The Pin Circle and Pointer
            _buildPinCircle(
              primaryGreen: primaryGreen,
              softMintBg: softMintBg,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingBadge({
    required BuildContext context,
    required bool isDark,
    required bool isDetailed,
    required Color cardBg,
    required Color textColor,
    required Color subtextColor,
    required Color borderColor,
    required Color primaryGreen,
  }) {
    return Container(
      constraints: BoxConstraints(maxWidth: isDetailed ? 200 : 160),
      padding: EdgeInsets.symmetric(
        horizontal: isDetailed ? 8 : 7,
        vertical: isDetailed ? 4 : 3.5,
      ),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(isDetailed ? 12 : 16),
        border: Border.all(
          color: isSelected ? primaryGreen : borderColor,
          width: isSelected ? 1.8 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: (isSelected ? primaryGreen : Colors.black).withValues(
              alpha: isSelected ? 0.25 : 0.12,
            ),
            blurRadius: isSelected ? 8 : 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Name + Verified rosette + Reputation (Star + Rating)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  provider.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: isDetailed ? 11 : 10.5,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                    fontFamily: 'Plus Jakarta Sans',
                  ),
                ),
              ),
              if (provider.verified) ...[
                const SizedBox(width: 3),
                const VerifiedBadge(size: 13, showWhiteCircle: false),
              ],
              const SizedBox(width: 4),
              // Rating Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF332A15) : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 11,
                      color: Color(0xFFF59E0B),
                    ),
                    const SizedBox(width: 1.5),
                    Text(
                      provider.rating,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: isDark ? const Color(0xFFFCD34D) : const Color(0xFF92400E),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Row 2 (When detailed / zoomed in): Specialty, Distance, Open status
          if (isDetailed) ...[
            const SizedBox(height: 2),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    '${provider.specialty} • ${provider.distance}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w600,
                      color: primaryGreen,
                    ),
                  ),
                ),
                if (provider.open) ...[
                  const SizedBox(width: 3),
                  Container(
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Text(
                    'Abierto',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF10B981),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPinCircle({
    required Color primaryGreen,
    required Color softMintBg,
  }) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        // Selection Glow ring
        if (isSelected)
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primaryGreen.withValues(alpha: 0.25),
              border: Border.all(color: primaryGreen, width: 2),
            ),
          ),

        // Main Pin Body
        Container(
          width: isSelected ? 36 : 30,
          height: isSelected ? 36 : 30,
          decoration: BoxDecoration(
            color: isSelected ? primaryGreen : softMintBg,
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected ? Colors.white : primaryGreen,
              width: 2.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.20),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              providerIcon,
              size: isSelected ? 18 : 15,
              color: isSelected ? Colors.white : primaryGreen,
            ),
          ),
        ),

        // Official Verified Badge (Rosette with white outline on the Pin!)
        if (provider.verified)
          Positioned(
            right: isSelected ? -2 : -1,
            top: isSelected ? -2 : -1,
            child: VerifiedBadge(
              size: isSelected ? 15 : 13,
              showWhiteCircle: true,
            ),
          ),

        // Bottom Pin Pointer Triangle
        Positioned(
          bottom: -4,
          child: CustomPaint(
            size: const Size(8, 5),
            painter: _PinTrianglePainter(
              color: isSelected ? primaryGreen : softMintBg,
              borderColor: isSelected ? Colors.white : primaryGreen,
            ),
          ),
        ),
      ],
    );
  }
}

class _PinTrianglePainter extends CustomPainter {
  final Color color;
  final Color borderColor;

  _PinTrianglePainter({required this.color, required this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _PinTrianglePainter oldDelegate) =>
      color != oldDelegate.color || borderColor != oldDelegate.borderColor;
}
