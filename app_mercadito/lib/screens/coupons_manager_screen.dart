import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../models/coupon_model.dart';
import '../services/coupons_service.dart';
import '../widgets/coupon_stats_sheet.dart';
// import '../widgets/share_coupon_sheet.dart'; // Comentado temporalmente para futura actualización
import '../widgets/create_coupon_wizard.dart';

class CouponsManagerScreen extends StatefulWidget {
  const CouponsManagerScreen({super.key});

  @override
  State<CouponsManagerScreen> createState() => _CouponsManagerScreenState();
}

class _CouponsManagerScreenState extends State<CouponsManagerScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'Todos'; // 'Todos', 'Activos', 'Pausados', 'Finalizados'

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF0d1a15) : const Color(0xFFf8fdfb);
    const primaryColor = Color(0xFF016142);
    final surfaceColor = isDark ? const Color(0xFF162520) : Colors.white;
    final textColor = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0f172a);
    final subtextColor = isDark ? const Color(0xFF94a3b8) : const Color(0xFF64748b);
    final borderColor = isDark ? const Color(0xFF22382e) : primaryColor.withValues(alpha: 0.12);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        title: const Text(
          'Gestión de Cupones',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: primaryColor,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: 'Ayuda',
            icon: const Icon(Icons.help_outline, color: primaryColor),
            onPressed: () => _showHelpDialog(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add, size: 20),
        label: const Text(
          'Crear cupón',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
        onPressed: () => CreateCouponWizard.show(context),
      ),
      body: ValueListenableBuilder<List<Coupon>>(
        valueListenable: CouponsService.instance.couponsNotifier,
        builder: (context, allCoupons, _) {
          // Filtrado de cupones
          final filteredCoupons = allCoupons.where((c) {
            final matchesSearch = _searchQuery.isEmpty ||
                c.code.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                c.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                c.category.toLowerCase().contains(_searchQuery.toLowerCase());

            if (!matchesSearch) return false;

            if (_selectedFilter == 'Activos') return c.status == CouponStatus.active;
            if (_selectedFilter == 'Pausados') return c.status == CouponStatus.paused;
            if (_selectedFilter == 'Finalizados') {
              return c.status == CouponStatus.expired || c.status == CouponStatus.depleted;
            }
            return true;
          }).toList();

          final metrics = CouponsService.instance.getGlobalMetrics();

          return Column(
            children: [
              // 1. Resumen superior de indicadores
              _buildMetricsHeader(metrics, isDark, primaryColor, surfaceColor, borderColor, textColor, subtextColor),

              // 2. Buscador y Filtros
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Column(
                  children: [
                    _buildSearchBar(isDark, surfaceColor, borderColor, textColor, subtextColor, primaryColor),
                    const SizedBox(height: 10),
                    _buildFilterChips(isDark, primaryColor, surfaceColor, borderColor, subtextColor),
                  ],
                ),
              ),

              // 3. Listado de Cupones
              Expanded(
                child: filteredCoupons.isEmpty
                    ? _buildEmptyState(isDark, subtextColor, primaryColor)
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
                        itemCount: filteredCoupons.length,
                        itemBuilder: (context, index) {
                          final coupon = filteredCoupons[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _buildCouponManagerCard(
                              coupon: coupon,
                              isDark: isDark,
                              primaryColor: primaryColor,
                              surfaceColor: surfaceColor,
                              borderColor: borderColor,
                              textColor: textColor,
                              subtextColor: subtextColor,
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- Indicadores / KPIs superiores ---
  Widget _buildMetricsHeader(
    Map<String, dynamic> metrics,
    bool isDark,
    Color primaryColor,
    Color surfaceColor,
    Color borderColor,
    Color textColor,
    Color subtextColor,
  ) {
    final activeCount = metrics['activeCount'] ?? 0;
    final usedCount = metrics['usedCount'] ?? 0;
    final redemptionsMonth = metrics['redemptionsThisMonth'] ?? 0;
    final totalDiscount = (metrics['totalDiscount'] as num?)?.toDouble() ?? 0.0;
    final totalSales = (metrics['totalSales'] as num?)?.toDouble() ?? 0.0;

    final kpis = [
      {'label': 'Cupones activos', 'value': '$activeCount', 'icon': Icons.local_activity_outlined, 'color': primaryColor},
      {'label': 'Cupones utilizados', 'value': '$usedCount', 'icon': Icons.check_circle_outline, 'color': const Color(0xFF0284C7)},
      {'label': 'Redenciones mes', 'value': '$redemptionsMonth', 'icon': Icons.calendar_month_outlined, 'color': const Color(0xFFD97706)},
      {'label': 'Descuento otorgado', 'value': 'RD\$ ${totalDiscount.toStringAsFixed(0)}', 'icon': Icons.price_change_outlined, 'color': const Color(0xFFBA1A1A)},
      {'label': 'Ventas generadas', 'value': 'RD\$ ${totalSales.toStringAsFixed(0)}', 'icon': Icons.trending_up_rounded, 'color': primaryColor},
    ];

    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 2),
      height: 58,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            for (int i = 0; i < kpis.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Container(
                width: 146,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            (kpis[i]['label'] as String).toUpperCase(),
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 8.5,
                              fontWeight: FontWeight.w800,
                              color: subtextColor,
                              letterSpacing: 0.4,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(kpis[i]['icon'] as IconData, size: 13, color: kpis[i]['color'] as Color),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      kpis[i]['value'] as String,
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: textColor,
                        letterSpacing: -0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // --- Buscador ---
  Widget _buildSearchBar(
    bool isDark,
    Color surfaceColor,
    Color borderColor,
    Color textColor,
    Color subtextColor,
    Color primaryColor,
  ) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Icon(Icons.search, color: primaryColor.withValues(alpha: 0.8), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 13, color: textColor),
              decoration: InputDecoration(
                hintText: 'Buscar por código, nombre o categoría...',
                hintStyle: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 13, color: subtextColor),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            GestureDetector(
              onTap: () => setState(() {
                _searchController.clear();
                _searchQuery = '';
              }),
              child: Icon(Icons.cancel, size: 18, color: subtextColor),
            ),
        ],
      ),
    );
  }

  // --- Filtros ---
  Widget _buildFilterChips(
    bool isDark,
    Color primaryColor,
    Color surfaceColor,
    Color borderColor,
    Color subtextColor,
  ) {
    final filters = ['Todos', 'Activos', 'Pausados', 'Finalizados'];

    return SizedBox(
      height: 34,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (int i = 0; i < filters.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              GestureDetector(
                onTap: () => setState(() => _selectedFilter = filters[i]),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: _selectedFilter == filters[i] ? primaryColor : surfaceColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _selectedFilter == filters[i] ? Colors.transparent : borderColor,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      filters[i],
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: _selectedFilter == filters[i] ? Colors.white : subtextColor,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // --- Tarjeta de Gestión de Cupón (Estilo Ticket como "Mis Cupones") ---
  Widget _buildCouponManagerCard({
    required Coupon coupon,
    required bool isDark,
    required Color primaryColor,
    required Color surfaceColor,
    required Color borderColor,
    required Color textColor,
    required Color subtextColor,
  }) {
    final isPaused = coupon.status == CouponStatus.paused;

    Color badgeColor;
    if (coupon.status == CouponStatus.active) {
      badgeColor = primaryColor;
    } else if (isPaused) {
      badgeColor = const Color(0xFFD97706);
    } else {
      badgeColor = const Color(0xFFBA1A1A);
    }

    // Icono por categoría
    IconData categoryIcon = Icons.local_offer_outlined;
    if (coupon.category.contains('FRUTAS') || coupon.category.contains('VERDURAS')) {
      categoryIcon = Icons.local_grocery_store;
    } else if (coupon.category.contains('ORGÁNICOS')) {
      categoryIcon = Icons.eco;
    } else if (coupon.category.contains('PANADERÍA')) {
      categoryIcon = Icons.bakery_dining;
    }

    final usageLimit = coupon.rule.totalUsageLimit;
    final usedCount = coupon.analytics.redeemed;
    final usagePercent = usageLimit > 0 ? (usedCount / usageLimit).clamp(0.0, 1.0) : 0.0;

    return Opacity(
      opacity: isPaused ? 0.85 : 1.0,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            // Parte Superior: Ticket Strip + Detalles
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Franja lateral izquierda estilo Ticket
                  Container(
                    width: 90,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1B2E26) : const Color(0xFFEDF3F0),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(15),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(categoryIcon, color: primaryColor, size: 28),
                          const SizedBox(height: 6),
                          Text(
                            coupon.category,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              color: primaryColor,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Separador vertical
                  Container(
                    width: 1,
                    color: primaryColor.withValues(alpha: 0.15),
                  ),

                // Contenido derecho del ticket
                Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Fila 1: Título de Beneficio + Badge de Estado
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  coupon.benefit.displayTitle,
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: primaryColor,
                                    height: 1.1,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: badgeColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  coupon.status.label.toUpperCase(),
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    color: badgeColor,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 4),

                          // Nombre de promoción
                          Text(
                            coupon.title,
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: textColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 4),

                          // Condición
                          Text(
                            coupon.rule.conditionSummary,
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 11.5,
                              color: subtextColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 8),

                          // Código y Audiencia
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Clipboard.setData(ClipboardData(text: coupon.code));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Código "${coupon.code}" copiado'),
                                      backgroundColor: primaryColor,
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: primaryColor.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: primaryColor.withValues(alpha: 0.2)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.confirmation_number_outlined, size: 12, color: primaryColor),
                                      const SizedBox(width: 4),
                                      Text(
                                        coupon.code,
                                        style: TextStyle(
                                          fontFamily: 'Plus Jakarta Sans',
                                          fontSize: 11,
                                          fontWeight: FontWeight.w900,
                                          color: primaryColor,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Vence: ${coupon.rule.endDate.day}/${coupon.rule.endDate.month}/${coupon.rule.endDate.year}',
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 11,
                                    color: subtextColor,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          // Progreso de uso (ej. 34 / 100 usos)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'USOS',
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  color: subtextColor,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Text(
                                '$usedCount / $usageLimit (${(usagePercent * 100).toStringAsFixed(0)}%)',
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: usagePercent,
                              minHeight: 5,
                              backgroundColor: primaryColor.withValues(alpha: 0.1),
                              valueColor: AlwaysStoppedAnimation<Color>(badgeColor),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Divisor
            Divider(height: 1, color: borderColor),

            // Parte Inferior: Fila de Acciones
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 1. Ver / Detalle
                  TextButton.icon(
                    icon: const Icon(Icons.visibility_outlined, size: 15),
                    label: const Text('Ver', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    style: TextButton.styleFrom(foregroundColor: primaryColor),
                    onPressed: () => _showCouponDetailsDialog(context, coupon),
                  ),

                  // 2. Estadísticas (Embudo)
                  TextButton.icon(
                    icon: const Icon(Icons.bar_chart_rounded, size: 15),
                    label: const Text('Estadísticas', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    style: TextButton.styleFrom(foregroundColor: const Color(0xFF0284C7)),
                    onPressed: () => CouponStatsSheet.show(context, coupon),
                  ),

                  // 3. Compartir (Inactivado temporalmente para futura actualización)
                  /*
                  IconButton(
                    tooltip: 'Compartir',
                    icon: const Icon(Icons.share_outlined, size: 17),
                    color: subtextColor,
                    onPressed: () => ShareCouponSheet.show(context, coupon),
                  ),
                  */

                  // 4. Pausar / Reanudar
                  IconButton(
                    tooltip: isPaused ? 'Reanudar' : 'Pausar',
                    icon: Icon(isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded, size: 18),
                    color: isPaused ? const Color(0xFF016142) : const Color(0xFFD97706),
                    onPressed: () {
                      CouponsService.instance.togglePauseCoupon(coupon.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(isPaused
                              ? 'Cupón "${coupon.code}" activado.'
                              : 'Cupón "${coupon.code}" pausado temporalmente.'),
                          backgroundColor: primaryColor,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),

                  // 5. Más opciones (Editar si nunca fue activado, Duplicar, Finalizar)
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, size: 18, color: subtextColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    onSelected: (val) {
                      if (val == 'edit') {
                        CreateCouponWizard.show(context, coupon: coupon);
                      } else if (val == 'duplicate') {
                        CouponsService.instance.duplicateCoupon(coupon.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Cupón duplicado en modo pausa con éxito.'),
                            backgroundColor: Color(0xFF016142),
                          ),
                        );
                      } else if (val == 'finalize') {
                        _confirmFinalize(context, coupon);
                      }
                    },
                    itemBuilder: (context) => [
                      // Solo se permite editar si el cupón está en pausa y NUNCA ha sido activado
                      if (coupon.canBeEdited)
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined, size: 16),
                              SizedBox(width: 8),
                              Text('Editar', style: TextStyle(fontSize: 13)),
                            ],
                          ),
                        ),
                      const PopupMenuItem(
                        value: 'duplicate',
                        child: Row(
                          children: [
                            Icon(Icons.copy_rounded, size: 16),
                            SizedBox(width: 8),
                            Text('Duplicar', style: TextStyle(fontSize: 13)),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                        value: 'finalize',
                        child: Row(
                          children: [
                            Icon(Icons.stop_circle_outlined, size: 16, color: Color(0xFFBA1A1A)),
                            SizedBox(width: 8),
                            Text('Finalizar', style: TextStyle(fontSize: 13, color: Color(0xFFBA1A1A))),
                          ],
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

  // --- Estado Vacío ---
  Widget _buildEmptyState(
    bool isDark,
    Color subtextColor,
    Color primaryColor,
  ) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.confirmation_number_outlined,
                size: 48,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No se encontraron cupones para "$_searchQuery"'
                  : 'No tienes cupones en este estado',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Crea cupones para fidelizar compradores o recuperar clientes inactivos.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: subtextColor),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Crear mi primer cupón'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => CreateCouponWizard.show(context),
            ),
          ],
        ),
      ),
    );
  }

  // --- Diálogo de Detalle ---
  void _showCouponDetailsDialog(BuildContext context, Coupon coupon) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.confirmation_number_outlined, color: Color(0xFF016142)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  coupon.code,
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(coupon.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              Text('Beneficio: ${coupon.benefit.displayTitle}', style: const TextStyle(fontSize: 13)),
              Text('Condición: ${coupon.rule.conditionSummary}', style: const TextStyle(fontSize: 13)),
              Text('Vigencia: ${coupon.dateRangeFormatted}', style: const TextStyle(fontSize: 13)),
              Text('Límite por comprador: ${coupon.rule.usagePerBuyer}', style: const TextStyle(fontSize: 13)),
              Text('Audiencia objetivo: ${coupon.target.audienceLabel}', style: const TextStyle(fontSize: 13)),
              Text('Estado actual: ${coupon.status.label}', style: const TextStyle(fontSize: 13)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  void _confirmFinalize(BuildContext context, Coupon coupon) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          '¿Finalizar cupón?',
          style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w800),
        ),
        content: Text(
          '¿Estás seguro de que deseas finalizar el cupón "${coupon.code}"? Este cupón dejará de ser funcional inmediatamente y pasará a la sección de finalizados.',
          style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 13, color: Color(0xFF64748b)),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.stop_circle_outlined, size: 16),
                  label: const Text('Finalizar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFBA1A1A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    CouponsService.instance.finalizeCoupon(coupon.id);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Cupón "${coupon.code}" finalizado.'),
                        backgroundColor: const Color(0xFFBA1A1A),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.help_outline, color: Color(0xFF016142)),
            SizedBox(width: 8),
            Text('Ciclo de Vida del Cupón', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '1. Crear: Diseña la promoción en 4 sencillos pasos.\n'
              '2. Publicar: Activa el cupón para tus clientes.\n'
              '3. Compartir: Envía por WhatsApp o genera código QR.\n'
              '4. Usar & Validar: El sistema valida automáticamente compras mínimas y vigencias.\n'
              '5. Monitorear: Revisa en tiempo real el embudo de conversión y las ventas generadas.',
              style: TextStyle(fontSize: 13, height: 1.45),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
}
