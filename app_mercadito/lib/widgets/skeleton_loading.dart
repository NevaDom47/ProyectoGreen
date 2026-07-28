import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonShimmer extends StatelessWidget {
  final Widget child;
  const SkeletonShimmer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: child,
    );
  }
}

class SkeletonContainer extends StatelessWidget {
  final double? width;
  final double height;
  final double borderRadius;
  final BorderRadiusGeometry? customBorderRadius;
  final BoxShape shape;

  const SkeletonContainer({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = 8,
    this.customBorderRadius,
    this.shape = BoxShape.rectangle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: shape == BoxShape.circle ? null : (customBorderRadius ?? BorderRadius.circular(borderRadius)),
        shape: shape,
      ),
    );
  }
}

class SkeletonText extends StatelessWidget {
  final double? width;
  final double height;
  final double borderRadius;

  const SkeletonText({
    super.key,
    this.width,
    this.height = 14,
    this.borderRadius = 4,
  });

  @override
  Widget build(BuildContext context) {
    return SkeletonContainer(width: width, height: height, borderRadius: borderRadius);
  }
}

class SkeletonProductCard extends StatelessWidget {
  final double width;
  final double height;
  const SkeletonProductCard({super.key, this.width = 280, this.height = 360});

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SkeletonContainer(width: double.infinity, height: 180, borderRadius: 24),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          SkeletonText(width: 120, height: 18),
                          SizedBox(height: 6),
                          SkeletonText(width: 60, height: 14),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: const [
                          SkeletonText(width: 80, height: 22),
                          SizedBox(height: 4),
                          SkeletonText(width: 40, height: 10),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const SkeletonContainer(width: double.infinity, height: 1), // Divider
                  const SizedBox(height: 16),
                  Row(
                    children: const [
                      SkeletonContainer(width: 36, height: 36, shape: BoxShape.circle),
                      SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SkeletonText(width: 50, height: 10),
                          SizedBox(height: 4),
                          SkeletonText(width: 100, height: 14),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: const [
                      SkeletonContainer(width: 36, height: 36, shape: BoxShape.circle),
                      SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SkeletonText(width: 50, height: 10),
                          SizedBox(height: 4),
                          SkeletonText(width: 100, height: 14),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SkeletonSearchProductCard extends StatelessWidget {
  const SkeletonSearchProductCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const SkeletonContainer(width: 120, height: double.infinity, borderRadius: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        SkeletonText(width: 160, height: 16),
                        SizedBox(height: 8),
                        SkeletonText(width: 120, height: 12),
                        SizedBox(height: 4),
                        SkeletonText(width: 100, height: 10),
                        SizedBox(height: 8),
                        SkeletonText(width: 140, height: 14),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: const [
                        SkeletonText(width: 80, height: 20),
                        SkeletonContainer(width: 32, height: 32, shape: BoxShape.circle),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SkeletonListTile extends StatelessWidget {
  const SkeletonListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            const SkeletonContainer(width: 50, height: 50, shape: BoxShape.circle),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SkeletonText(width: 150, height: 16),
                  SizedBox(height: 8),
                  SkeletonText(width: double.infinity, height: 14),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: const [
                SkeletonText(width: 40, height: 12),
                SizedBox(height: 8),
                SkeletonContainer(width: 20, height: 20, shape: BoxShape.circle),
              ],
            )
          ],
        ),
      ),
    );
  }
}
