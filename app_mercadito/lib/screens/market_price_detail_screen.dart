import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ---------------------------------------------------------------------------
// Data model for a single market entry
// ---------------------------------------------------------------------------
class _MarketEntry {
  final String name;
  final String label;
  final double price;
  final _EntryType type;

  const _MarketEntry({
    required this.name,
    required this.label,
    required this.price,
    required this.type,
  });
}

enum _EntryType { lowest, stable, high, highest }

// ---------------------------------------------------------------------------
// 7-day sparkline data (relative Y values, lower = cheaper)
// ---------------------------------------------------------------------------
class _SparklinePainter extends CustomPainter {
  final List<double> values; // e.g. [19, 19.5, 18.8, 20, 19.2, 18.5, 19]
  final Color lineColor;
  final Color areaColor;

  _SparklinePainter({
    required this.values,
    required this.lineColor,
    required this.areaColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;

    final minV = values.reduce(math.min);
    final maxV = values.reduce(math.max);
    final range = (maxV - minV) == 0 ? 1.0 : (maxV - minV);

    final double stepX = size.width / (values.length - 1);

    Offset toOffset(int i) {
      final normalised = 1.0 - (values[i] - minV) / range;
      final y = 12 + normalised * (size.height - 24); // 12px padding top/bottom
      return Offset(i * stepX, y);
    }

    // Build smooth path with cubic bezier between points
    final path = Path();
    final areaPath = Path();

    path.moveTo(toOffset(0).dx, toOffset(0).dy);
    areaPath.moveTo(toOffset(0).dx, size.height);
    areaPath.lineTo(toOffset(0).dx, toOffset(0).dy);

    for (int i = 0; i < values.length - 1; i++) {
      final p0 = toOffset(i);
      final p1 = toOffset(i + 1);
      final cpX = (p0.dx + p1.dx) / 2;
      path.cubicTo(cpX, p0.dy, cpX, p1.dy, p1.dx, p1.dy);
      areaPath.cubicTo(cpX, p0.dy, cpX, p1.dy, p1.dx, p1.dy);
    }

    final last = toOffset(values.length - 1);
    areaPath.lineTo(last.dx, size.height);
    areaPath.close();

    // Grid lines
    final gridPaint = Paint()
      ..color = const Color(0xFFE5EEFF)
      ..strokeWidth = 1;
    for (final y in [0.25, 0.5, 0.75]) {
      canvas.drawLine(
        Offset(0, size.height * y),
        Offset(size.width, size.height * y),
        gridPaint,
      );
    }

    // Area fill
    final areaGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [areaColor.withValues(alpha: 0.30), areaColor.withValues(alpha: 0.0)],
    );
    canvas.drawPath(
      areaPath,
      Paint()..shader = areaGradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Line
    canvas.drawPath(
      path,
      Paint()
        ..color = lineColor
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Data points
    for (int i = 0; i < values.length; i++) {
      final o = toOffset(i);
      final isLast = i == values.length - 1;
      canvas.drawCircle(
        o,
        isLast ? 5 : 4,
        Paint()..color = Colors.white,
      );
      canvas.drawCircle(
        o,
        isLast ? 5 : 4,
        Paint()
          ..color = lineColor
          ..strokeWidth = isLast ? 2.5 : 2
          ..style = PaintingStyle.stroke,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) =>
      oldDelegate.values != values;
}

// ---------------------------------------------------------------------------
// Main Screen
// ---------------------------------------------------------------------------
class MarketPriceDetailScreen extends StatelessWidget {
  /// Data passed from the parent screen
  final Map<String, dynamic> item;

  /// Parent product data (for image URL, unit, etc.)
  final Map<String, dynamic> product;

  const MarketPriceDetailScreen({
    super.key,
    required this.item,
    required this.product,
  });

  // Palette (Emerald Harvest – same as market_analysis_screen)
  static const _primary = Color(0xFF004532);
  static const _primaryContainer = Color(0xFF065F46);
  static const _onPrimaryContainer = Color(0xFF8BD6B7);
  static const _primaryFixed = Color(0xFFA6F2D1);
  static const _surfaceContainerLowest = Color(0xFFFFFFFF);
  static const _surfaceContainerHigh = Color(0xFFDFE9FA);
  static const _surfaceVariant = Color(0xFFD9E3F4);
  static const _outlineVariant = Color(0xFFBEC9C2);
  static const _onSurface = Color(0xFF121C28);
  static const _onSurfaceVariant = Color(0xFF3F4944);
  static const _error = Color(0xFFBA1A1A);
  static const _errorContainer = Color(0xFFFFDAD6);
  static const _onErrorContainer = Color(0xFF93000A);
  static const _background = Color(0xFFF8F9FF);

  // Mock market data for the given sub-item
  List<_MarketEntry> _getMarketEntries(String itemName) {
    // In a real app, these would come from an API.
    // We generate realistic-looking mock data based on the item name.
    final base = double.tryParse(item['price']?.toString() ?? '20') ?? 20.0;
    return [
      _MarketEntry(
        name: 'Merca Santo Domingo',
        label: 'Precio más bajo',
        price: double.parse((base * 0.91).toStringAsFixed(2)),
        type: _EntryType.lowest,
      ),
      _MarketEntry(
        name: 'Mercado Nuevo',
        label: 'Venta Promedio',
        price: double.parse((base * 0.98).toStringAsFixed(2)),
        type: _EntryType.stable,
      ),
      _MarketEntry(
        name: 'Mercado Los Minas',
        label: 'Precio elevado',
        price: double.parse((base * 1.01).toStringAsFixed(2)),
        type: _EntryType.high,
      ),
      _MarketEntry(
        name: 'La Duarte',
        label: 'Precio más alto',
        price: double.parse((base * 1.20).toStringAsFixed(2)),
        type: _EntryType.highest,
      ),
    ];
  }

  // 7-day sparkline values for the lowest-price market
  List<double> _getSparklineValues() {
    final base = double.tryParse(item['price']?.toString() ?? '20') ?? 20.0;
    final low = base * 0.91;
    // Simulate slight variation over 7 days
    return [
      low + 0.4,
      low - 0.1,
      low + 0.6,
      low + 0.2,
      low - 0.3,
      low - 0.6,
      low,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final entries = _getMarketEntries(item['name'] as String? ?? '');
    final sparkValues = _getSparklineValues();
    final avgPrice = double.tryParse(item['price']?.toString() ?? '0') ?? 0.0;
    final unit = product['unit'] as String? ?? 'kg';
    final imageUrl = product['imageUrl'] as String?;

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.black12,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          item['name'] as String? ?? 'Detalle',
          style: GoogleFonts.manrope(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: _primary,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _outlineVariant.withValues(alpha: 0.4)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---- 1. SUMMARY HEADER CARD ----
            _buildSummaryCard(imageUrl, avgPrice, unit),
            const SizedBox(height: 28),

            // ---- 2. MARKET COMPARISON LIST ----
            Text(
              'Precio en Mercados',
              style: GoogleFonts.manrope(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: _onSurface,
              ),
            ),
            const SizedBox(height: 14),
            ...entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildMarketCard(e),
                )),
            const SizedBox(height: 16),

            // ---- 3. 7-DAY TREND CHART ----
            Text(
              '7-Day Trend (Merca Santo Domingo)',
              style: GoogleFonts.manrope(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: _onSurface,
              ),
            ),
            const SizedBox(height: 14),
            _buildSparklineCard(sparkValues),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 1. Summary header card
  // ---------------------------------------------------------------------------
  Widget _buildSummaryCard(String? imageUrl, double avgPrice, String unit) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _outlineVariant.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Product image
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _outlineVariant.withValues(alpha: 0.5)),
              color: _surfaceContainerHigh,
            ),
            clipBehavior: Clip.antiAlias,
            child: imageUrl != null && imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.grain,
                      size: 36,
                      color: _primaryContainer,
                    ),
                  )
                : const Icon(Icons.grain, size: 36, color: _primaryContainer),
          ),
          const SizedBox(width: 16),
          // Price info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PRECIO PROMEDIO DEL MERCADO',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                    color: _onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '\$${avgPrice.toStringAsFixed(2)}',
                      style: GoogleFonts.manrope(
                        fontSize: 38,
                        fontWeight: FontWeight.w800,
                        color: _primary,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '/ $unit',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: _onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 2. Single market comparison card
  // ---------------------------------------------------------------------------
  Widget _buildMarketCard(_MarketEntry entry) {
    final isHighest = entry.type == _EntryType.highest;

    Color priceColor;
    Color badgeBg;
    Color badgeIcon;
    IconData icon;

    switch (entry.type) {
      case _EntryType.lowest:
        priceColor = _primaryContainer;
        badgeBg = _primaryFixed;
        badgeIcon = _primaryContainer;
        icon = Icons.arrow_downward_rounded;
        break;
      case _EntryType.stable:
        priceColor = _onSurface;
        badgeBg = _surfaceVariant;
        badgeIcon = _onSurfaceVariant;
        icon = Icons.remove_rounded;
        break;
      case _EntryType.high:
        priceColor = _error;
        badgeBg = const Color(0xFFFFEDD5); // light amber
        badgeIcon = const Color(0xFF904D00);
        icon = Icons.arrow_upward_rounded;
        break;
      case _EntryType.highest:
        priceColor = _error;
        badgeBg = _errorContainer;
        badgeIcon = _onErrorContainer;
        icon = Icons.arrow_upward_rounded;
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: _surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: isHighest
            ? Border.all(color: _error, width: 2)
            : Border.all(color: _outlineVariant.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: isHighest
                ? _error.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: isHighest ? 12 : 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Red left accent bar for highest
          if (isHighest)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(width: 4, color: _error),
            ),
          Padding(
            padding: EdgeInsets.fromLTRB(isHighest ? 20 : 16, 16, 16, 16),
            child: Row(
              children: [
                // Name + label
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.name,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        entry.label,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: _onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Price + badge
                isHighest
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Elevado',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                              color: _error,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '\$${entry.price.toStringAsFixed(2)}',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: _error,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Text(
                            '\$${entry.price.toStringAsFixed(2)}',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: priceColor,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: badgeBg,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(icon, size: 18, color: badgeIcon),
                          ),
                        ],
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 3. Sparkline chart card
  // ---------------------------------------------------------------------------
  Widget _buildSparklineCard(List<double> values) {
    const days = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: BoxDecoration(
        color: _surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _outlineVariant.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 160,
            child: CustomPaint(
              painter: _SparklinePainter(
                values: values,
                lineColor: _primaryContainer,
                areaColor: _primaryContainer,
              ),
              size: Size.infinite,
            ),
          ),
          const SizedBox(height: 12),
          // X-axis labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(days.length, (i) {
              final isLast = i == days.length - 1;
              return Text(
                days[i],
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 11,
                  fontWeight: isLast ? FontWeight.w700 : FontWeight.w500,
                  color: isLast ? _primaryContainer : _onSurfaceVariant,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
