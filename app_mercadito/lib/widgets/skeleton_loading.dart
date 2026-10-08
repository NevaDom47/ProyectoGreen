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

/// ShimmerBox es un alias de SkeletonContainer para compatibilidad
typedef ShimmerBox = SkeletonContainer;

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
    final bool isCompact = width < 250;
    final double imgHeight = isCompact ? 120 : 180;
    final double paddingVal = isCompact ? 12 : 20;

    return SkeletonShimmer(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(isCompact ? 18 : 24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonContainer(
              width: double.infinity,
              height: imgHeight,
              borderRadius: isCompact ? 18 : 24,
            ),
            Padding(
              padding: EdgeInsets.all(paddingVal),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SkeletonText(width: isCompact ? 80 : 120, height: isCompact ? 14 : 18),
                            const SizedBox(height: 6),
                            SkeletonText(width: isCompact ? 45 : 60, height: isCompact ? 11 : 14),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          SkeletonText(width: isCompact ? 50 : 80, height: isCompact ? 18 : 22),
                          const SizedBox(height: 4),
                          SkeletonText(width: isCompact ? 30 : 40, height: 10),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: isCompact ? 10 : 16),
                  const SkeletonContainer(width: double.infinity, height: 1), // Divider
                  SizedBox(height: isCompact ? 10 : 16),
                  Row(
                    children: [
                      SkeletonContainer(width: isCompact ? 28 : 36, height: isCompact ? 28 : 36, shape: BoxShape.circle),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SkeletonText(width: 50, height: 10),
                          const SizedBox(height: 4),
                          SkeletonText(width: isCompact ? 70 : 100, height: 14),
                        ],
                      ),
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

class SkeletonGridProductCard extends StatelessWidget {
  const SkeletonGridProductCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SkeletonContainer(
              width: double.infinity,
              height: 105,
              borderRadius: 0,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SkeletonText(width: 100, height: 12),
                  SizedBox(height: 4),
                  SkeletonText(width: 60, height: 8),
                  SizedBox(height: 6),
                  SkeletonContainer(width: double.infinity, height: 20, borderRadius: 6),
                  SizedBox(height: 6),
                  SkeletonText(width: 80, height: 8),
                  SizedBox(height: 4),
                  SkeletonText(width: 70, height: 8),
                  SizedBox(height: 8),
                  SkeletonText(width: 50, height: 14),
                  SizedBox(height: 6),
                  SkeletonContainer(width: double.infinity, height: 28, borderRadius: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton para la lista o directorio de Proveedores
class SkeletonProvidersView extends StatelessWidget {
  const SkeletonProvidersView({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 6,
        separatorBuilder: (context, index) => const SizedBox(height: 14),
        itemBuilder: (context, index) => Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const SkeletonContainer(width: 64, height: 64, shape: BoxShape.circle),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    SkeletonText(width: 160, height: 16),
                    SizedBox(height: 6),
                    SkeletonText(width: 110, height: 12),
                    SizedBox(height: 8),
                    SkeletonContainer(width: 90, height: 20, borderRadius: 6),
                  ],
                ),
              ),
              const SkeletonContainer(width: 36, height: 36, shape: BoxShape.circle),
            ],
          ),
        ),
      ),
    );
  }
}

/// Skeleton para la pantalla del Carrito de Compras
class SkeletonCartView extends StatelessWidget {
  const SkeletonCartView({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: 4,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) => Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const SkeletonContainer(width: 72, height: 72, borderRadius: 10),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          SkeletonText(width: 130, height: 15),
                          SizedBox(height: 6),
                          SkeletonText(width: 80, height: 12),
                          SizedBox(height: 10),
                          SkeletonText(width: 60, height: 14),
                        ],
                      ),
                    ),
                    const SkeletonContainer(width: 80, height: 32, borderRadius: 8),
                  ],
                ),
              ),
            ),
          ),
          // Resumen inferior
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: const [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SkeletonText(width: 80, height: 14),
                    SkeletonText(width: 60, height: 14),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SkeletonText(width: 100, height: 18),
                    SkeletonText(width: 80, height: 18),
                  ],
                ),
                SizedBox(height: 16),
                SkeletonContainer(width: double.infinity, height: 48, borderRadius: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton para Notificaciones y Alertas
class SkeletonNotificationsView extends StatelessWidget {
  const SkeletonNotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: 7,
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemBuilder: (context, index) => Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SkeletonContainer(width: 44, height: 44, shape: BoxShape.circle),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    SkeletonText(width: 140, height: 14),
                    SizedBox(height: 6),
                    SkeletonText(width: double.infinity, height: 12),
                    SizedBox(height: 4),
                    SkeletonText(width: 180, height: 12),
                    SizedBox(height: 8),
                    SkeletonText(width: 60, height: 10),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Skeleton para Pantallas de Análisis de Mercado y Precios
class SkeletonMarketView extends StatelessWidget {
  const SkeletonMarketView({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SkeletonContainer(width: double.infinity, height: 50, borderRadius: 12),
            const SizedBox(height: 18),
            Row(
              children: const [
                Expanded(child: SkeletonContainer(height: 90, borderRadius: 14)),
                SizedBox(width: 12),
                Expanded(child: SkeletonContainer(height: 90, borderRadius: 14)),
              ],
            ),
            const SizedBox(height: 20),
            const SkeletonContainer(width: double.infinity, height: 210, borderRadius: 16),
            const SizedBox(height: 20),
            const SkeletonText(width: 140, height: 16),
            const SizedBox(height: 12),
            ...List.generate(
              4,
              (_) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: const SkeletonContainer(width: double.infinity, height: 64, borderRadius: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton para Misiones y Tareas
class SkeletonTasksView extends StatelessWidget {
  const SkeletonTasksView({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SkeletonContainer(width: double.infinity, height: 140, borderRadius: 18),
            const SizedBox(height: 20),
            Row(
              children: const [
                Expanded(child: SkeletonContainer(height: 70, borderRadius: 12)),
                SizedBox(width: 12),
                Expanded(child: SkeletonContainer(height: 70, borderRadius: 12)),
              ],
            ),
            const SizedBox(height: 24),
            ...List.generate(
              4,
              (_) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: const SkeletonContainer(width: double.infinity, height: 80, borderRadius: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton para Pantallas de Perfil (Comprador o Proveedor)
class SkeletonProfileView extends StatelessWidget {
  const SkeletonProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 16),
            const SkeletonContainer(width: 96, height: 96, shape: BoxShape.circle),
            const SizedBox(height: 14),
            const SkeletonText(width: 160, height: 18),
            const SizedBox(height: 8),
            const SkeletonText(width: 110, height: 12),
            const SizedBox(height: 24),
            Row(
              children: const [
                Expanded(child: SkeletonContainer(height: 60, borderRadius: 12)),
                SizedBox(width: 10),
                Expanded(child: SkeletonContainer(height: 60, borderRadius: 12)),
                SizedBox(width: 10),
                Expanded(child: SkeletonContainer(height: 60, borderRadius: 12)),
              ],
            ),
            const SizedBox(height: 24),
            ...List.generate(
              5,
              (_) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: const SkeletonContainer(width: double.infinity, height: 56, borderRadius: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton universal para formularios y pantallas de configuración
class SkeletonFormView extends StatelessWidget {
  const SkeletonFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SkeletonText(width: 180, height: 22),
            const SizedBox(height: 8),
            const SkeletonText(width: 260, height: 13),
            const SizedBox(height: 28),
            ...List.generate(
              4,
              (_) => Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    SkeletonText(width: 120, height: 13),
                    SizedBox(height: 8),
                    SkeletonContainer(width: double.infinity, height: 50, borderRadius: 12),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const SkeletonContainer(width: double.infinity, height: 50, borderRadius: 12),
          ],
        ),
      ),
    );
  }
}

/// Cargador contenedor universal que alterna entre skeleton y contenido con transición fluida
class SkeletonScreenLoader extends StatelessWidget {
  final bool isLoading;
  final Widget skeleton;
  final Widget child;
  final Duration duration;

  const SkeletonScreenLoader({
    super.key,
    required this.isLoading,
    required this.skeleton,
    required this.child,
    this.duration = const Duration(milliseconds: 280),
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: Curves.easeIn,
      switchOutCurve: Curves.easeOut,
      child: isLoading
          ? KeyedSubtree(key: const ValueKey('skeleton_view'), child: skeleton)
          : KeyedSubtree(key: const ValueKey('content_view'), child: child),
    );
  }
}

/// Skeleton para la pantalla principal (Home Feed)
class SkeletonHomeFeedView extends StatelessWidget {
  const SkeletonHomeFeedView({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            // Header bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                SkeletonContainer(width: 120, height: 28, borderRadius: 8),
                Row(
                  children: [
                    SkeletonContainer(width: 36, height: 36, shape: BoxShape.circle),
                    SizedBox(width: 12),
                    SkeletonContainer(width: 36, height: 36, shape: BoxShape.circle),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Search field
            const SkeletonContainer(width: double.infinity, height: 48, borderRadius: 14),
            const SizedBox(height: 16),
            // Market ticker
            const SkeletonContainer(width: double.infinity, height: 36, borderRadius: 10),
            const SizedBox(height: 24),
            // Banner Hero
            const SkeletonContainer(width: double.infinity, height: 160, borderRadius: 16),
            const SizedBox(height: 28),
            // Horizontal Suppliers
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                SkeletonText(width: 160, height: 18),
                SkeletonText(width: 60, height: 14),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 110,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 4,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) => const SkeletonContainer(
                  width: 130,
                  height: 110,
                  borderRadius: 14,
                ),
              ),
            ),
            const SizedBox(height: 28),
            // Flash offers
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                SkeletonText(width: 140, height: 18),
                SkeletonContainer(width: 80, height: 24, borderRadius: 12),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 260,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 3,
                separatorBuilder: (context, index) => const SizedBox(width: 14),
                itemBuilder: (context, index) => const SkeletonContainer(
                  width: 180,
                  height: 260,
                  borderRadius: 16,
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
