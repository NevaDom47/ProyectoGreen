import 'package:flutter/material.dart';
import '../models/coupon_model.dart';

class CouponStatsSheet extends StatelessWidget {
  final Coupon coupon;

  const CouponStatsSheet({super.key, required this.coupon});

  static void show(BuildContext context, Coupon coupon) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CouponStatsSheet(coupon: coupon),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = const Color(0xFF016142);
    final bg = isDark ? const Color(0xFF0d1a15) : Colors.white;
    final cardBg = isDark ? const Color(0xFF162520) : const Color(0xFFF6FAF7);
    final text = isDark ? Colors.white : const Color(0xFF0f172a);
    final subtext = isDark ? const Color(0xFF94a3b8) : const Color(0xFF64748b);
    final border = isDark ? const Color(0xFF22382e) : const Color(0xFFE2E8F0);

    final analytics = coupon.analytics;
    final totalLimit = coupon.rule.totalUsageLimit;
    final usedCount = analytics.redeemed;
    final usagePercent = totalLimit > 0 ? (usedCount / totalLimit) * 100 : 0.0;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, -4),
              )
            ],
          ),
          child: Column(
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  decoration: BoxDecoration(
                    color: subtext.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.bar_chart_rounded, color: primary, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                coupon.code,
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: primary,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: (coupon.status == CouponStatus.active ? primary : Colors.grey)
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  coupon.status.label.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: coupon.status == CouponStatus.active ? primary : Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            coupon.title,
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 13,
                              color: subtext,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                      color: subtext,
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Body
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Section 1: Rendimiento / KPIs principales
                    Text(
                      'RENDIMIENTO GENERAL',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: primary,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Usos & Barra de Progreso
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  'Límite de Utilización',
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: text,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '$usedCount / $totalLimit usos (${usagePercent.toStringAsFixed(1)}%)',
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: totalLimit > 0 ? (usedCount / totalLimit).clamp(0.0, 1.0) : 0,
                              minHeight: 8,
                              backgroundColor: primary.withValues(alpha: 0.1),
                              valueColor: AlwaysStoppedAnimation<Color>(primary),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Grid de 4 Métricas Clave
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 2.2,
                      children: [
                        _buildMetricCard(
                          'Ventas generadas',
                          'RD\$ ${analytics.salesGenerated.toStringAsFixed(0)}',
                          Icons.trending_up_rounded,
                          const Color(0xFF016142),
                          cardBg,
                          border,
                          text,
                          subtext,
                        ),
                        _buildMetricCard(
                          'Descuento otorgado',
                          'RD\$ ${analytics.discountGiven.toStringAsFixed(0)}',
                          Icons.local_offer_outlined,
                          const Color(0xFFBA1A1A),
                          cardBg,
                          border,
                          text,
                          subtext,
                        ),
                        _buildMetricCard(
                          'Ticket promedio',
                          'RD\$ ${analytics.averageTicket.toStringAsFixed(0)}',
                          Icons.receipt_long_outlined,
                          const Color(0xFF0284C7),
                          cardBg,
                          border,
                          text,
                          subtext,
                        ),
                        _buildMetricCard(
                          'Nuevos compradores',
                          '${analytics.newBuyersAcquired}',
                          Icons.person_add_alt_1_outlined,
                          const Color(0xFFD97706),
                          cardBg,
                          border,
                          text,
                          subtext,
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // Section 2: Embudo de Conversión (Funnel)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'EMBUDO DE CONVERSIÓN',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: primary,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        Text(
                          'Tasa: ${analytics.utilizationRate.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Tarjeta de Embudo
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: border),
                      ),
                      child: Column(
                        children: [
                          _buildFunnelStep(
                            stepNumber: '1',
                            title: 'Cupón publicado',
                            count: analytics.publishedCount,
                            percentage: 100,
                            color: primary.withValues(alpha: 0.9),
                            text: text,
                            subtext: subtext,
                          ),
                          _buildFunnelConnector(
                            conversionText: analytics.publishedCount > 0
                                ? '${((analytics.views / analytics.publishedCount) * 100).toStringAsFixed(0)}% vieron el cupón'
                                : '0%',
                            subtext: subtext,
                          ),
                          _buildFunnelStep(
                            stepNumber: '2',
                            title: 'Personas que lo vieron',
                            count: analytics.views,
                            percentage: analytics.publishedCount > 0
                                ? (analytics.views / analytics.publishedCount) * 100
                                : 0,
                            color: const Color(0xFF0284C7),
                            text: text,
                            subtext: subtext,
                          ),
                          _buildFunnelConnector(
                            conversionText: analytics.views > 0
                                ? '${((analytics.saved / analytics.views) * 100).toStringAsFixed(0)}% lo guardaron'
                                : '0%',
                            subtext: subtext,
                          ),
                          _buildFunnelStep(
                            stepNumber: '3',
                            title: 'Personas que lo guardaron',
                            count: analytics.saved,
                            percentage: analytics.publishedCount > 0
                                ? (analytics.saved / analytics.publishedCount) * 100
                                : 0,
                            color: const Color(0xFFD97706),
                            text: text,
                            subtext: subtext,
                          ),
                          _buildFunnelConnector(
                            conversionText: analytics.saved > 0
                                ? '${((analytics.redeemed / analytics.saved) * 100).toStringAsFixed(0)}% lo utilizaron'
                                : '0%',
                            subtext: subtext,
                          ),
                          _buildFunnelStep(
                            stepNumber: '4',
                            title: 'Personas que lo utilizaron',
                            count: analytics.redeemed,
                            percentage: analytics.publishedCount > 0
                                ? (analytics.redeemed / analytics.publishedCount) * 100
                                : 0,
                            color: const Color(0xFF016142),
                            isLast: true,
                            text: text,
                            subtext: subtext,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Resumen de Regla
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: primary.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: primary, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Vigencia: ${coupon.dateRangeFormatted} • ${coupon.target.audienceLabel}',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: text,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetricCard(
    String label,
    String value,
    IconData icon,
    Color iconColor,
    Color cardBg,
    Color border,
    Color text,
    Color subtext,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
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
                  label.toUpperCase(),
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: subtext,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Icon(icon, size: 15, color: iconColor),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: text,
              letterSpacing: -0.3,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildFunnelStep({
    required String stepNumber,
    required String title,
    required int count,
    required double percentage,
    required Color color,
    bool isLast = false,
    required Color text,
    required Color subtext,
  }) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 1.5),
          ),
          alignment: Alignment.center,
          child: Text(
            stepNumber,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w900,
              fontSize: 12,
              color: color,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: text,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$count',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (percentage / 100).clamp(0.05, 1.0),
                  minHeight: 6,
                  backgroundColor: color.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFunnelConnector({
    required String conversionText,
    required Color subtext,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 14),
      child: Row(
        children: [
          Container(
            width: 2,
            height: 20,
            color: subtext.withValues(alpha: 0.3),
          ),
          const SizedBox(width: 24),
          Text(
            conversionText,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: subtext,
            ),
          ),
        ],
      ),
    );
  }
}
