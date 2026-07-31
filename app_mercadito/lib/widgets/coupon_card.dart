import 'package:flutter/material.dart';

class CouponCard extends StatelessWidget {
  final IconData icon;
  final String category;
  final String discount;
  final String? badge;
  final String condition;
  final String? code;
  final String expiry;
  final String buttonLabel;
  final IconData? buttonIcon;
  final Color bgColor;
  final Color surfaceColor;
  final Color primaryColor;
  final Color textColor;
  final Color subtextColor;
  final Color borderColor;
  final bool isFaded;
  final VoidCallback? onButtonTap;

  const CouponCard({
    super.key,
    required this.icon,
    required this.category,
    required this.discount,
    this.badge,
    required this.condition,
    this.code,
    required this.expiry,
    required this.buttonLabel,
    this.buttonIcon,
    required this.bgColor,
    required this.surfaceColor,
    required this.primaryColor,
    required this.textColor,
    required this.subtextColor,
    required this.borderColor,
    this.isFaded = false,
    this.onButtonTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectivePrimary = isFaded ? subtextColor.withValues(alpha: 0.6) : primaryColor;
    final effectiveText = isFaded ? subtextColor : textColor;

    return Opacity(
      opacity: isFaded ? 0.8 : 1.0,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.centerLeft,
        children: [
          Container(
            height: 160,
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 2))
              ],
            ),
            child: Row(
              children: [
                // Left Ticket Strip
                Container(
                  width: 96,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: effectivePrimary.withValues(alpha: 0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(11),
                      bottomLeft: Radius.circular(11),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, color: effectivePrimary, size: 36),
                      const SizedBox(height: 4),
                      Text(
                        category,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: effectivePrimary,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                // Dashed vertical line
                SizedBox(
                  width: 2,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final boxHeight = constraints.constrainHeight();
                      const dashHeight = 4.0;
                      final dashCount = (boxHeight / (2 * dashHeight)).floor();
                      return Flex(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        direction: Axis.vertical,
                        children: List.generate(dashCount, (_) {
                          return SizedBox(
                            width: 2,
                            height: dashHeight,
                            child: DecoratedBox(
                              decoration: BoxDecoration(color: effectivePrimary.withValues(alpha: 0.3)),
                            ),
                          );
                        }),
                      );
                    },
                  ),
                ),
                // Right Content
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  discount,
                                  style: TextStyle(
                                    color: effectivePrimary,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    height: 1.0,
                                  ),
                                ),
                                if (badge != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: effectivePrimary.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      badge!,
                                      style: TextStyle(color: effectivePrimary, fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              condition,
                              style: TextStyle(color: subtextColor, fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                            if (code != null) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: effectivePrimary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.sell_outlined, size: 12, color: effectivePrimary),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Código: ${code!}',
                                      style: TextStyle(
                                        color: effectivePrimary, 
                                        fontSize: 10, 
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'VENCE EL',
                                  style: TextStyle(color: subtextColor.withValues(alpha: 0.6), fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  expiry,
                                  style: TextStyle(color: effectiveText, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: onButtonTap,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isFaded ? effectivePrimary.withValues(alpha: 0.2) : effectivePrimary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (buttonIcon != null) ...[
                                      Icon(buttonIcon, color: isFaded ? effectivePrimary : Colors.white, size: 14),
                                      const SizedBox(width: 4),
                                    ],
                                    Text(
                                      buttonLabel,
                                      style: TextStyle(
                                        color: isFaded ? effectivePrimary : Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Left Edge Ticket cutouts (holes)
          Positioned(
            left: -10,
            top: 25,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: -10,
            bottom: 25,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
