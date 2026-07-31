import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// ============================================================
// Enums
// ============================================================
enum _RangeFilter { week, month, day }
enum _EntryType { lowest, stable, high, highest }

// ============================================================
// Interactive Animated Chart Painter
// ============================================================
class _ChartPainter extends CustomPainter {
  final List<double> values;
  final double progress;
  final double? touchXNorm;
  final Color lineColor;

  const _ChartPainter({
    required this.values,
    required this.progress,
    this.touchXNorm,
    required this.lineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;

    final minV = values.reduce(math.min);
    final maxV = values.reduce(math.max);
    final vRange = (maxV - minV) == 0 ? 1.0 : maxV - minV;
    final displayMin = minV - vRange * 0.18;
    final displayMax = maxV + vRange * 0.18;
    final displayRange = displayMax - displayMin;
    final n = values.length;
    final stepX = size.width / (n - 1);

    Offset pt(int i) {
      final x = i * stepX;
      final y = (1.0 - (values[i] - displayMin) / displayRange) * size.height;
      return Offset(x, y);
    }

    // --- Build paths ---
    final linePath = Path();
    final areaPath = Path();
    linePath.moveTo(pt(0).dx, pt(0).dy);
    areaPath.moveTo(pt(0).dx, size.height);
    areaPath.lineTo(pt(0).dx, pt(0).dy);
    for (int i = 0; i < n - 1; i++) {
      final p0 = pt(i);
      final p1 = pt(i + 1);
      final cpX = (p0.dx + p1.dx) / 2;
      linePath.cubicTo(cpX, p0.dy, cpX, p1.dy, p1.dx, p1.dy);
      areaPath.cubicTo(cpX, p0.dy, cpX, p1.dy, p1.dx, p1.dy);
    }
    areaPath.lineTo(pt(n - 1).dx, size.height);
    areaPath.close();

    // --- Grid lines ---
    final gridPaint = Paint()
      ..color = const Color(0xFFE5EEFF)
      ..strokeWidth = 1;
    for (int i = 1; i <= 4; i++) {
      final y = size.height * i / 5;
      // Dashed line
      double x = 0;
      while (x < size.width) {
        canvas.drawLine(Offset(x, y), Offset(math.min(x + 6, size.width), y), gridPaint);
        x += 10;
      }
    }

    // --- Clip for draw animation ---
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, -100, size.width * progress, size.height + 200));

    // Area gradient
    final areaGrad = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        lineColor.withValues(alpha: 0.28),
        lineColor.withValues(alpha: 0.0),
      ],
    );
    canvas.drawPath(
      areaPath,
      Paint()
        ..shader =
            areaGrad.createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Line
    canvas.drawPath(
      linePath,
      Paint()
        ..color = lineColor
        ..strokeWidth = 2.8
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    canvas.restore();

    // --- Data points (within progress) ---
    for (int i = 0; i < n; i++) {
      final o = pt(i);
      if (o.dx > size.width * progress + 2) break;
      canvas.drawCircle(o, 3.5, Paint()..color = Colors.white);
      canvas.drawCircle(
        o,
        3.5,
        Paint()
          ..color = lineColor
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke,
      );
    }

    // --- Touch crosshair ---
    if (touchXNorm != null) {
      final touchedIdx = ((touchXNorm! * (n - 1)).round()).clamp(0, n - 1);
      final touchedPt = pt(touchedIdx);

      // Vertical dashed line
      final crossPaint = Paint()
        ..color = lineColor.withValues(alpha: 0.55)
        ..strokeWidth = 1.2;
      double y = 0;
      while (y < size.height) {
        canvas.drawLine(
          Offset(touchedPt.dx, y),
          Offset(touchedPt.dx, math.min(y + 6, size.height)),
          crossPaint,
        );
        y += 10;
      }

      // Highlighted ring + dot
      canvas.drawCircle(touchedPt, 8, Paint()..color = lineColor.withValues(alpha: 0.15));
      canvas.drawCircle(touchedPt, 6, Paint()..color = Colors.white);
      canvas.drawCircle(
        touchedPt,
        6,
        Paint()
          ..color = lineColor
          ..strokeWidth = 2.5
          ..style = PaintingStyle.stroke,
      );
      canvas.drawCircle(touchedPt, 3, Paint()..color = lineColor);
    }
  }

  @override
  bool shouldRepaint(covariant _ChartPainter old) =>
      old.progress != progress ||
      old.touchXNorm != touchXNorm ||
      old.values != values ||
      old.lineColor != lineColor;
}

// ============================================================
// Screen
// ============================================================
class MarketPriceDetailScreen extends StatefulWidget {
  final Map<String, dynamic> item;
  final Map<String, dynamic> product;

  const MarketPriceDetailScreen({
    super.key,
    required this.item,
    required this.product,
  });

  @override
  State<MarketPriceDetailScreen> createState() =>
      _MarketPriceDetailScreenState();
}

class _MarketPriceDetailScreenState extends State<MarketPriceDetailScreen>
    with TickerProviderStateMixin {
  // --- Palette ---
  static const _primary = Color(0xFF004532);
  static const _primaryContainer = Color(0xFF065F46);
  static const _primaryFixed = Color(0xFFA6F2D1);
  static const _surfaceContainerLowest = Color(0xFFFFFFFF);
  static const _surfaceContainerHigh = Color(0xFFDFE9FA);
  static const _outlineVariant = Color(0xFFBEC9C2);
  static const _onSurface = Color(0xFF121C28);
  static const _onSurfaceVariant = Color(0xFF3F4944);
  static const _error = Color(0xFFBA1A1A);
  static const _errorContainer = Color(0xFFFFDAD6);
  static const _onErrorContainer = Color(0xFF93000A);
  static const _background = Color(0xFFF8F9FF);
  static const _surfaceVariant = Color(0xFFD9E3F4);

  static const _marketFullNames = [
    'Merca Santo Domingo',
    'Mercado Nuevo',
    'Mercado Los Minas',
    'La Duarte',
  ];

  static const _marketShortNames = [
    'Merca Sto. Dom.',
    'Merc. Nuevo',
    'Los Minas',
    'La Duarte',
  ];

  static const _marketColors = [
    Color(0xFF065F46), // green
    Color(0xFF00415F), // teal
    Color(0xFF904D00), // amber
    Color(0xFFBA1A1A), // red
  ];

  static const _marketMultipliers = [0.91, 0.98, 1.01, 1.20];
  static const _marketLabels = [
    'Precio más bajo',
    'Venta Promedio',
    'Precio elevado',
    'Precio más alto',
  ];
  static const _marketTypes = [
    _EntryType.lowest,
    _EntryType.stable,
    _EntryType.high,
    _EntryType.highest,
  ];

  // --- State ---
  _RangeFilter _selectedRange = _RangeFilter.week;
  int _selectedMarketIndex = 0;
  double? _touchXNorm;
  int? _touchedPointIndex;
  DateTime _selectedDay = DateTime.now();

  // Chart layout key to get actual width
  final GlobalKey _chartKey = GlobalKey();

  // --- Animations ---
  late AnimationController _chartAnimController;
  late Animation<double> _chartAnimation;
  late AnimationController _cardAnimController;
  late AnimationController _headerAnimController;
  late Animation<double> _headerAnimation;

  // --- Data ---
  late double _basePrice;
  late Map<String, Map<_RangeFilter, List<double>>> _allData;

  @override
  void initState() {
    super.initState();
    _basePrice =
        double.tryParse(widget.item['price']?.toString() ?? '20') ?? 20.0;
    _allData = _generateAllData();

    // Header fade+slide
    _headerAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _headerAnimation = CurvedAnimation(
      parent: _headerAnimController,
      curve: Curves.easeOutCubic,
    );
    _headerAnimController.forward();

    // Chart draw
    _chartAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    );
    _chartAnimation = CurvedAnimation(
      parent: _chartAnimController,
      curve: Curves.easeInOut,
    );
    _chartAnimController.forward();

    // Staggered cards
    _cardAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _cardAnimController.forward();
    });
  }

  @override
  void dispose() {
    _chartAnimController.dispose();
    _cardAnimController.dispose();
    _headerAnimController.dispose();
    super.dispose();
  }

  // ---- Data generation ----
  List<double> _series(double base, int count, double vol, int seed) {
    final rng = math.Random(seed);
    final vals = <double>[base];
    for (int i = 1; i < count; i++) {
      final delta = (rng.nextDouble() - 0.47) * vol;
      vals.add((vals.last + delta).clamp(base * 0.72, base * 1.38));
    }
    return vals.map((v) => double.parse(v.toStringAsFixed(2))).toList();
  }

  Map<String, Map<_RangeFilter, List<double>>> _generateAllData() {
    final out = <String, Map<_RangeFilter, List<double>>>{};
    for (int mi = 0; mi < _marketFullNames.length; mi++) {
      final mb = _basePrice * _marketMultipliers[mi];
      final seed = (_basePrice * 100).toInt() + mi * 31;
      out[_marketFullNames[mi]] = {
        _RangeFilter.week: _series(mb, 7, mb * 0.04, seed),
        _RangeFilter.month: _series(mb, 30, mb * 0.025, seed + 7),
        _RangeFilter.day: _series(mb, 24, mb * 0.012, seed + 13),
      };
    }
    return out;
  }

  // ---- Derived getters ----
  List<double> get _currentValues =>
      _allData[_marketFullNames[_selectedMarketIndex]]![_selectedRange]!;

  Color get _selectedMarketColor => _marketColors[_selectedMarketIndex];

  double get _avgPrice {
    final v = _currentValues;
    return v.reduce((a, b) => a + b) / v.length;
  }

  double? get _touchedPrice {
    final idx = _touchedPointIndex;
    final v = _currentValues;
    if (idx == null || idx >= v.length) return null;
    return v[idx];
  }

  // ---- X-axis labels ----
  List<String> _xLabels() {
    switch (_selectedRange) {
      case _RangeFilter.week:
        return ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
      case _RangeFilter.month:
        return ['1', '5', '10', '15', '20', '25', '30'];
      case _RangeFilter.day:
        return ['00h', '04h', '08h', '12h', '16h', '20h', '23h'];
    }
  }

  List<int> _xLabelIndices() {
    switch (_selectedRange) {
      case _RangeFilter.week:
        return [0, 1, 2, 3, 4, 5, 6];
      case _RangeFilter.month:
        return [0, 4, 9, 14, 19, 24, 29];
      case _RangeFilter.day:
        return [0, 4, 8, 12, 16, 20, 23];
    }
  }

  // ---- Range change ----
  void _changeRange(_RangeFilter r) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedRange = r;
      _touchXNorm = null;
      _touchedPointIndex = null;
    });
    _chartAnimController.forward(from: 0);
  }

  // ---- Market change ----
  void _changeMarket(int idx) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedMarketIndex = idx;
      _touchXNorm = null;
      _touchedPointIndex = null;
    });
    _chartAnimController.forward(from: 0);
  }

  // ---- Touch handling ----
  void _onChartPan(Offset local, double chartWidth) {
    if (chartWidth <= 0) return;
    final norm = (local.dx / chartWidth).clamp(0.0, 1.0);
    final n = _currentValues.length;
    final idx = ((norm * (n - 1)).round()).clamp(0, n - 1);
    setState(() {
      _touchXNorm = norm;
      _touchedPointIndex = idx;
    });
    HapticFeedback.selectionClick();
  }

  void _onChartPanEnd() {
    setState(() {
      _touchXNorm = null;
      _touchedPointIndex = null;
    });
  }

  // ---- Date picker for "Día" ----
  Future<void> _pickDay() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDay,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      builder: (ctx, child) {
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _primaryContainer,
              onPrimary: Colors.white,
              surface: _surfaceContainerLowest,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDay) {
      setState(() {
        _selectedDay = picked;
        _touchXNorm = null;
        _touchedPointIndex = null;
      });
      _chartAnimController.forward(from: 0);
    }
  }

  // ---- Card animation helper ----
  Animation<double> _cardAnim(int index) {
    final start = (index * 0.18).clamp(0.0, 1.0);
    final end = (start + 0.45).clamp(0.0, 1.0);
    return CurvedAnimation(
      parent: _cardAnimController,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================
  @override
  Widget build(BuildContext context) {
    final unit = widget.product['unit'] as String? ?? 'kg';
    final imageUrl = widget.product['imageUrl'] as String?;
    final itemName = widget.item['name'] as String? ?? 'Producto';

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: _primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          itemName,
          style: GoogleFonts.manrope(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: _primary,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: _outlineVariant.withValues(alpha: 0.4),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header summary card (animated)
            _buildAnimatedHeader(imageUrl, unit),
            const SizedBox(height: 28),

            // 2. Interactive chart card
            _buildChartCard(),
            const SizedBox(height: 28),

            // 3. Market comparison list
            Text(
              'Precio en Mercados',
              style: GoogleFonts.manrope(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: _onSurface,
              ),
            ),
            const SizedBox(height: 14),
            ..._buildMarketCards(),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 1. Header Card
  // ============================================================
  Widget _buildAnimatedHeader(String? imageUrl, String unit) {
    return AnimatedBuilder(
      animation: _headerAnimation,
      builder: (_, child) => Transform.translate(
        offset: Offset(0, 20 * (1 - _headerAnimation.value)),
        child: Opacity(opacity: _headerAnimation.value, child: child),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _surfaceContainerLowest,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _outlineVariant.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Product image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _outlineVariant.withValues(alpha: 0.4)),
                color: _surfaceContainerHigh,
              ),
              clipBehavior: Clip.antiAlias,
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) =>
                          const Icon(Icons.grain, size: 36, color: _primaryContainer),
                    )
                  : const Icon(Icons.grain, size: 36, color: _primaryContainer),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PRECIO PROMEDIO DEL MERCADO',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.7,
                      color: _onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '\$${_avgPrice.toStringAsFixed(2)}',
                        style: GoogleFonts.manrope(
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          color: _primary,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '/ ${widget.product['unit'] ?? 'kg'}',
                        style: GoogleFonts.inter(
                          fontSize: 14,
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
      ),
    );
  }

  // ============================================================
  // 2. Chart Card (interactive)
  // ============================================================
  Widget _buildChartCard() {
    final labels = _xLabels();
    final labelIndices = _xLabelIndices();
    final n = _currentValues.length;
    final touchedPrice = _touchedPrice;
    final color = _selectedMarketColor;

    return Container(
      decoration: BoxDecoration(
        color: _surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _outlineVariant.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ----- Header row (title + price tooltip) -----
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Tendencia de Precios',
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _onSurface,
                    ),
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, anim) =>
                      ScaleTransition(scale: anim, child: child),
                  child: touchedPrice != null
                      ? Container(
                          key: ValueKey(touchedPrice),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: color.withValues(alpha: 0.4)),
                          ),
                          child: Text(
                            '\$${touchedPrice.toStringAsFixed(2)}',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: color,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ----- Range filter chips -----
            _buildRangeFilterRow(),
            const SizedBox(height: 12),

            // ----- Market selector chips -----
            _buildMarketSelectorRow(),
            const SizedBox(height: 16),

            // ----- Chart area -----
            LayoutBuilder(
              builder: (ctx, constraints) {
                final chartWidth = constraints.maxWidth;
                return Column(
                  children: [
                    // Y-axis price labels + chart
                    SizedBox(
                      height: 180,
                      child: Row(
                        children: [
                          // Y labels
                          _buildYLabels(chartWidth),
                          const SizedBox(width: 8),
                          // Chart + gesture
                          Expanded(
                            child: GestureDetector(
                              key: _chartKey,
                              behavior: HitTestBehavior.opaque,
                              onPanStart: (d) => _onChartPan(
                                  d.localPosition, chartWidth - 40),
                              onPanUpdate: (d) => _onChartPan(
                                  d.localPosition, chartWidth - 40),
                              onPanEnd: (_) => _onChartPanEnd(),
                              onTapDown: (d) => _onChartPan(
                                  d.localPosition, chartWidth - 40),
                              onTapUp: (_) => _onChartPanEnd(),
                              child: AnimatedBuilder(
                                animation: _chartAnimation,
                                builder: (_, _) => CustomPaint(
                                  painter: _ChartPainter(
                                    values: _currentValues,
                                    progress: _chartAnimation.value,
                                    touchXNorm: _touchXNorm,
                                    lineColor: color,
                                  ),
                                  size: Size.infinite,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // X-axis labels
                    Padding(
                      padding: const EdgeInsets.only(left: 40),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(labels.length, (i) {
                          final idx = labelIndices[i];
                          final isTouched =
                              _touchedPointIndex != null &&
                              (_touchedPointIndex! - idx).abs() <= (n / (labels.length * 1.5)).round();
                          return AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 10,
                              fontWeight: isTouched
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isTouched ? color : _onSurfaceVariant,
                            ),
                            child: Text(labels[i]),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Touch hint
                    AnimatedOpacity(
                      opacity: _touchXNorm == null ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.touch_app_rounded,
                              size: 14, color: _onSurfaceVariant.withValues(alpha: 0.6)),
                          const SizedBox(width: 4),
                          Text(
                            'Toca o desliza para ver el precio',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: _onSurfaceVariant.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Y-axis labels
  Widget _buildYLabels(double chartWidth) {
    final vals = _currentValues;
    final minV = vals.reduce(math.min);
    final maxV = vals.reduce(math.max);
    final vRange = (maxV - minV) == 0 ? 1.0 : maxV - minV;
    final displayMin = minV - vRange * 0.18;
    final displayMax = maxV + vRange * 0.18;

    return SizedBox(
      width: 40,
      height: 180,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _yLabel(displayMax),
          _yLabel((displayMax + displayMin) / 2),
          _yLabel(displayMin),
        ],
      ),
    );
  }

  Widget _yLabel(double value) => Text(
        '\$${value.toStringAsFixed(0)}',
        style: GoogleFonts.jetBrainsMono(
          fontSize: 9,
          color: _onSurfaceVariant.withValues(alpha: 0.7),
        ),
      );

  // Range filter chips
  Widget _buildRangeFilterRow() {
    return Row(
      children: [
        _rangeChip('Semana', _RangeFilter.week, Icons.calendar_view_week_rounded),
        const SizedBox(width: 8),
        _rangeChip('Mes', _RangeFilter.month, Icons.calendar_month_rounded),
        const SizedBox(width: 8),
        _rangeChip('Día', _RangeFilter.day, Icons.today_rounded),
        if (_selectedRange == _RangeFilter.day) ...[
          const SizedBox(width: 8),
          _dayPickerChip(),
        ],
      ],
    );
  }

  Widget _rangeChip(String label, _RangeFilter range, IconData icon) {
    final isSelected = _selectedRange == range;
    return GestureDetector(
      onTap: () => _changeRange(range),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? _primaryContainer.withValues(alpha: 0.12)
              : _surfaceVariant.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? _primaryContainer.withValues(alpha: 0.6)
                : _outlineVariant.withValues(alpha: 0.4),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? _primaryContainer : _onSurfaceVariant,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? _primaryContainer : _onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dayPickerChip() {
    final formatted =
        '${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}';
    return GestureDetector(
      onTap: _pickDay,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: _primaryContainer.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _primaryContainer.withValues(alpha: 0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              formatted,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _primaryContainer,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.edit_calendar_rounded,
                size: 13, color: _primaryContainer),
          ],
        ),
      ),
    );
  }

  // Market selector chips
  Widget _buildMarketSelectorRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_marketShortNames.length, (i) {
          final isSelected = _selectedMarketIndex == i;
          final color = _marketColors[i];
          return Padding(
            padding: EdgeInsets.only(right: i < _marketShortNames.length - 1 ? 8 : 0),
            child: GestureDetector(
              onTap: () => _changeMarket(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withValues(alpha: 0.14)
                      : _surfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? color.withValues(alpha: 0.7)
                        : _outlineVariant.withValues(alpha: 0.35),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _marketShortNames[i],
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: isSelected ? color : _onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ============================================================
  // 3. Market comparison cards
  // ============================================================
  List<Widget> _buildMarketCards() {
    return List.generate(_marketFullNames.length, (i) {
      final vals =
          _allData[_marketFullNames[i]]![_selectedRange]!;
      final avg = vals.reduce((a, b) => a + b) / vals.length;
      final type = _marketTypes[i];
      final isHighest = type == _EntryType.highest;
      final anim = _cardAnim(i);

      return AnimatedBuilder(
        animation: anim,
        builder: (_, child) => Transform.translate(
          offset: Offset(0, 30 * (1 - anim.value)),
          child: Opacity(opacity: anim.value.clamp(0.0, 1.0), child: child),
        ),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildOneMarketCard(
            name: _marketFullNames[i],
            label: _marketLabels[i],
            price: avg,
            type: type,
            isHighest: isHighest,
            isSelected: _selectedMarketIndex == i,
            onTap: () => _changeMarket(i),
          ),
        ),
      );
    });
  }

  Widget _buildOneMarketCard({
    required String name,
    required String label,
    required double price,
    required _EntryType type,
    required bool isHighest,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    Color priceColor;
    Color badgeBg;
    Color badgeIconColor;
    IconData icon;

    switch (type) {
      case _EntryType.lowest:
        priceColor = _primaryContainer;
        badgeBg = _primaryFixed;
        badgeIconColor = _primaryContainer;
        icon = Icons.arrow_downward_rounded;
        break;
      case _EntryType.stable:
        priceColor = _onSurface;
        badgeBg = _surfaceVariant;
        badgeIconColor = _onSurfaceVariant;
        icon = Icons.remove_rounded;
        break;
      case _EntryType.high:
        priceColor = const Color(0xFF904D00);
        badgeBg = const Color(0xFFFFEDD5);
        badgeIconColor = const Color(0xFF904D00);
        icon = Icons.arrow_upward_rounded;
        break;
      case _EntryType.highest:
        priceColor = _error;
        badgeBg = _errorContainer;
        badgeIconColor = _onErrorContainer;
        icon = Icons.arrow_upward_rounded;
        break;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: isSelected
              ? priceColor.withValues(alpha: 0.05)
              : _surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: isHighest
              ? Border.all(color: _error, width: 2)
              : Border.all(
                  color: isSelected
                      ? priceColor.withValues(alpha: 0.5)
                      : _outlineVariant.withValues(alpha: 0.6),
                  width: isSelected ? 1.5 : 1,
                ),
          boxShadow: [
            BoxShadow(
              color: isHighest
                  ? _error.withValues(alpha: 0.08)
                  : (isSelected
                      ? priceColor.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.04)),
              blurRadius: isHighest || isSelected ? 12 : 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Left accent bar for highest
            if (isHighest)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(width: 4, color: _error),
              ),
            // Selected market indicator
            if (isSelected && !isHighest)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: priceColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
                ),
              ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                  isHighest || isSelected ? 20 : 16, 14, 16, 14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              name,
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: _onSurface,
                              ),
                            ),
                            if (isSelected) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: priceColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Viendo',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: priceColor,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          label,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: _onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  isHighest
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Elevado',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.4,
                                color: _error,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '\$${price.toStringAsFixed(2)}',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: _error,
                              ),
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            Text(
                              '\$${price.toStringAsFixed(2)}',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
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
                              child: Icon(icon, size: 18, color: badgeIconColor),
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
