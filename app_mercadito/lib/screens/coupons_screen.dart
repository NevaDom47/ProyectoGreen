import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../main.dart';
import '../models/coupon_model.dart';
import '../services/coupons_service.dart';

class CouponsScreen extends StatefulWidget {
  const CouponsScreen({super.key});

  @override
  State<CouponsScreen> createState() => _CouponsScreenState();
}

class _CouponsScreenState extends State<CouponsScreen> {
  final TextEditingController _codeController = TextEditingController();
  int _selectedTabIndex = 0; // 0 = Activos, 1 = Historial

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _handleClaimCoupon() {
    final rawCode = _codeController.text;
    FocusScope.of(context).unfocus();

    final result = CouponsService.instance.claimCouponCode(rawCode);

    if (result.success) {
      _codeController.clear();
      if (_selectedTabIndex != 0) {
        setState(() => _selectedTabIndex = 0);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  result.message,
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF016142),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  result.message,
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFBA1A1A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  IconData _getCategoryIcon(String category) {
    final cat = category.toUpperCase();
    if (cat.contains('FRUTA') || cat.contains('VERDURA') || cat.contains('VEGETAL')) {
      return Icons.local_grocery_store;
    } else if (cat.contains('ORG')) {
      return Icons.eco;
    } else if (cat.contains('PAN') || cat.contains('REPOST')) {
      return Icons.bakery_dining;
    } else if (cat.contains('LÁCT') || cat.contains('QUESO')) {
      return Icons.egg_outlined;
    } else if (cat.contains('CARN')) {
      return Icons.restaurant;
    }
    return Icons.local_offer;
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appThemeMode,
      builder: (context, currentMode, _) {
        final platformBrightness = MediaQuery.platformBrightnessOf(context);
        final isDark = currentMode == ThemeMode.dark ||
            (currentMode == ThemeMode.system && platformBrightness == Brightness.dark);

        final bgColor = isDark ? const Color(0xFF101815) : const Color(0xFFF7F9F8);
        final primaryColor = isDark ? const Color(0xFF67C83B) : const Color(0xFF016042);
        final surfaceColor = isDark ? const Color(0xFF1C2924) : Colors.white;
        final textColor = isDark ? const Color(0xFFF1F5F3) : const Color(0xFF20262B);
        final subtextColor = isDark ? const Color(0xFFAAB8B1) : const Color(0xFF697177);
        final borderColor = isDark ? const Color(0xFF2B3A34) : const Color(0xFFE2E7E4);
        final stubColor = isDark ? const Color(0xFF17221E) : const Color(0xFFEEF5F1);

        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            backgroundColor: bgColor,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: primaryColor),
              onPressed: () => context.pop(),
            ),
            title: Text(
              'Mis Cupones',
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.w800,
                fontSize: 18,
                fontFamily: 'Plus Jakarta Sans',
                letterSpacing: -0.5,
              ),
            ),
            centerTitle: false,
            actions: [
              IconButton(
                icon: Icon(Icons.help_outline, color: primaryColor),
                onPressed: () => _showHelpDialog(context, primaryColor, surfaceColor, textColor, subtextColor),
              ),
            ],
          ),
          body: Column(
            children: [
              // 1. Barra de Canje de Códigos
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 14),
                      Icon(Icons.confirmation_number_outlined,
                          color: primaryColor.withValues(alpha: 0.7), size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _codeController,
                          textCapitalization: TextCapitalization.characters,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _handleClaimCoupon(),
                          decoration: InputDecoration(
                            hintText: 'Ingresar código de cupón',
                            hintStyle: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              color: subtextColor.withValues(alpha: 0.7),
                              fontSize: 13,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            color: textColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(11),
                            bottomRight: Radius.circular(11),
                          ),
                          onTap: _handleClaimCoupon,
                          child: Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(11),
                                bottomRight: Radius.circular(11),
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                'Canjear',
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Selector de Pestañas (Activos / Historial)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: borderColor)),
                  ),
                  child: Row(
                    children: [
                      // Pestaña Activos
                      Expanded(
                        child: ValueListenableBuilder<List<Coupon>>(
                          valueListenable: CouponsService.instance.activeBuyerCouponsNotifier,
                          builder: (context, activeCoupons, _) {
                            final isSelected = _selectedTabIndex == 0;
                            return InkWell(
                              onTap: () => setState(() => _selectedTabIndex = 0),
                              child: Container(
                                padding: const EdgeInsets.only(bottom: 12, top: 8),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: isSelected ? primaryColor : Colors.transparent,
                                      width: 3,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  'Activos (${activeCoupons.length})',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    color: isSelected ? primaryColor : subtextColor,
                                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // Pestaña Historial
                      Expanded(
                        child: ValueListenableBuilder<List<CouponRedemptionHistory>>(
                          valueListenable: CouponsService.instance.redemptionHistoryNotifier,
                          builder: (context, historyList, _) {
                            final isSelected = _selectedTabIndex == 1;
                            return InkWell(
                              onTap: () => setState(() => _selectedTabIndex = 1),
                              child: Container(
                                padding: const EdgeInsets.only(bottom: 12, top: 8),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: isSelected ? primaryColor : Colors.transparent,
                                      width: 3,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  'Historial (${historyList.length})',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    color: isSelected ? primaryColor : subtextColor,
                                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 3. Contenido según pestaña
              Expanded(
                child: _selectedTabIndex == 0
                    ? _buildActiveCouponsTab(
                        isDark: isDark,
                        primaryColor: primaryColor,
                        surfaceColor: surfaceColor,
                        textColor: textColor,
                        subtextColor: subtextColor,
                        borderColor: borderColor,
                        stubColor: stubColor,
                      )
                    : _buildHistoryTab(
                        isDark: isDark,
                        primaryColor: primaryColor,
                        surfaceColor: surfaceColor,
                        textColor: textColor,
                        subtextColor: subtextColor,
                        borderColor: borderColor,
                        stubColor: stubColor,
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- Vista de Cupones Activos ---
  Widget _buildActiveCouponsTab({
    required bool isDark,
    required Color primaryColor,
    required Color surfaceColor,
    required Color textColor,
    required Color subtextColor,
    required Color borderColor,
    required Color stubColor,
  }) {
    return ValueListenableBuilder<List<Coupon>>(
      valueListenable: CouponsService.instance.activeBuyerCouponsNotifier,
      builder: (context, activeList, _) {
        if (activeList.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.confirmation_number_outlined,
                      size: 56, color: primaryColor.withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  Text(
                    'No tienes cupones activos',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ingresa un código de promoción arriba para canjear tu primer cupón.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 13,
                      color: subtextColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: activeList.length,
          itemBuilder: (context, index) {
            final coupon = activeList[index];
            final categoryIcon = _getCategoryIcon(coupon.category);

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: TicketCardWrapper(
                surfaceColor: surfaceColor,
                borderColor: borderColor,
                isDark: isDark,
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Franja lateral estilo Ticket
                      Container(
                        width: 92,
                        color: stubColor,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(categoryIcon, color: primaryColor, size: 34),
                              const SizedBox(height: 6),
                              Text(
                                coupon.category.toUpperCase(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  color: primaryColor,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.2,
                                  height: 1.15,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Línea vertical punteada (perforación de ticket)
                      SizedBox(
                        width: 2,
                        child: CustomPaint(
                          painter: DashedVerticalLinePainter(
                            color: primaryColor.withValues(alpha: isDark ? 0.30 : 0.20),
                            dashHeight: 4,
                            dashSpace: 4,
                            strokeWidth: 1.5,
                          ),
                        ),
                      ),

                      // Contenido Derecho
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Fila Superior: Beneficio + Badge NUEVO / DISPONIBLE
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      coupon.benefit.displayTitle,
                                      style: TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: 22,
                                        fontWeight: FontWeight.w900,
                                        color: primaryColor,
                                        height: 1.1,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: primaryColor.withValues(alpha: isDark ? 0.22 : 0.12),
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: Text(
                                      'NUEVO',
                                      style: TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w800,
                                        color: primaryColor,
                                        letterSpacing: 0.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 5),

                              // Condición / Detalle
                              Text(
                                coupon.rule.conditionSummary,
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: subtextColor,
                                  height: 1.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),

                              const SizedBox(height: 10),

                              // Fila Inferior: VENCE EL + Fecha & Código y Botón Copiar
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  // Vence el + fecha y código
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'VENCE EL',
                                          style: TextStyle(
                                            fontFamily: 'Plus Jakarta Sans',
                                            fontSize: 9,
                                            fontWeight: FontWeight.w800,
                                            color: subtextColor,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        const SizedBox(height: 1),
                                        Wrap(
                                          crossAxisAlignment: WrapCrossAlignment.center,
                                          spacing: 6,
                                          children: [
                                            Text(
                                              _formatDate(coupon.rule.endDate),
                                              style: TextStyle(
                                                fontFamily: 'Plus Jakarta Sans',
                                                fontSize: 11.5,
                                                fontWeight: FontWeight.w800,
                                                color: textColor,
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                              decoration: BoxDecoration(
                                                color: primaryColor.withValues(alpha: 0.08),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                coupon.code,
                                                style: TextStyle(
                                                  fontFamily: 'Plus Jakarta Sans',
                                                  fontSize: 9.5,
                                                  fontWeight: FontWeight.w700,
                                                  color: primaryColor,
                                                  letterSpacing: 0.3,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Botón Copiar
                                  Material(
                                    color: primaryColor,
                                    borderRadius: BorderRadius.circular(8),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(8),
                                      onTap: () {
                                        Clipboard.setData(ClipboardData(text: coupon.code));
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Row(
                                              children: [
                                                const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    'Código ${coupon.code} copiado al portapapeles',
                                                    style: const TextStyle(
                                                      fontFamily: 'Plus Jakarta Sans',
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 12.5,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            backgroundColor: const Color(0xFF016142),
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            duration: const Duration(seconds: 2),
                                          ),
                                        );
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: const [
                                            Icon(Icons.copy_rounded, size: 13, color: Colors.white),
                                            SizedBox(width: 5),
                                            Text(
                                              'Copiar',
                                              style: TextStyle(
                                                fontFamily: 'Plus Jakarta Sans',
                                                fontSize: 11.5,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
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
              ),
            );
          },
        );
      },
    );
  }

  // --- Vista de Historial de Cupones Utilizados ---
  Widget _buildHistoryTab({
    required bool isDark,
    required Color primaryColor,
    required Color surfaceColor,
    required Color textColor,
    required Color subtextColor,
    required Color borderColor,
    required Color stubColor,
  }) {
    return ValueListenableBuilder<List<CouponRedemptionHistory>>(
      valueListenable: CouponsService.instance.redemptionHistoryNotifier,
      builder: (context, historyList, _) {
        if (historyList.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_toggle_off_rounded,
                      size: 56, color: primaryColor.withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  Text(
                    'Sin historial de cupones',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Aquí verás los cupones que hayas utilizado en tus compras y las fechas en que fueron aplicados.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 13,
                      color: subtextColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: historyList.length,
          itemBuilder: (context, index) {
            final item = historyList[index];
            final categoryIcon = _getCategoryIcon(item.category);
            final statusColor = item.isExpired ? const Color(0xFFD97706) : primaryColor;
            final statusLabel = item.isExpired ? 'EXPIRADO' : 'UTILIZADO';

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: TicketCardWrapper(
                surfaceColor: surfaceColor,
                borderColor: borderColor,
                isDark: isDark,
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Franja lateral estilo Ticket con stubColor
                      Container(
                        width: 92,
                        color: stubColor,
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(categoryIcon, color: primaryColor, size: 28),
                              const SizedBox(height: 6),
                              Text(
                                item.category,
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

                      // Línea vertical punteada (perforación de ticket)
                      SizedBox(
                        width: 2,
                        child: CustomPaint(
                          painter: DashedVerticalLinePainter(
                            color: primaryColor.withValues(alpha: isDark ? 0.30 : 0.20),
                            dashHeight: 4,
                            dashSpace: 4,
                            strokeWidth: 1.5,
                          ),
                        ),
                      ),

                      // Contenido Derecho
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Fila 1: Descuento aplicado + Badge de Estado
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    item.discountApplied,
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      color: primaryColor,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                                    decoration: BoxDecoration(
                                      color: statusColor.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      statusLabel,
                                      style: TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: statusColor,
                                        letterSpacing: 0.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 3),

                              // Nombre de la promoción
                              Text(
                                item.couponTitle,
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

                              // Proveedor / Tienda y Orden
                              Row(
                                children: [
                                  Icon(Icons.storefront_outlined, size: 14, color: subtextColor),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      item.providerName,
                                      style: TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: subtextColor,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    item.orderId,
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: subtextColor,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 10),

                              // Bloque de Productos en los que se usó
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: primaryColor.withValues(alpha: isDark ? 0.08 : 0.04),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: primaryColor.withValues(alpha: 0.1),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.shopping_bag_outlined,
                                            size: 13, color: primaryColor),
                                        const SizedBox(width: 6),
                                        Text(
                                          'PRODUCTOS EN ESTA COMPRA:',
                                          style: TextStyle(
                                            fontFamily: 'Plus Jakarta Sans',
                                            fontSize: 9,
                                            fontWeight: FontWeight.w800,
                                            color: primaryColor,
                                            letterSpacing: 0.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    if (item.productDetails.isNotEmpty)
                                      for (final prodItem in item.productDetails)
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 5),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  '• ${prodItem.name}',
                                                  style: TextStyle(
                                                    fontFamily: 'Plus Jakarta Sans',
                                                    fontSize: 11.5,
                                                    fontWeight: FontWeight.w600,
                                                    color: textColor,
                                                    height: 1.25,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                    horizontal: 5, vertical: 1.5),
                                                decoration: BoxDecoration(
                                                  color: isDark
                                                      ? const Color(0xFF1E293B)
                                                      : const Color(0xFFF1F5F9),
                                                  borderRadius: BorderRadius.circular(4),
                                                  border: Border.all(
                                                    color: isDark
                                                        ? const Color(0xFF334155)
                                                        : const Color(0xFFCBD5E1),
                                                  ),
                                                ),
                                                child: Text(
                                                  '#${prodItem.sku}',
                                                  style: TextStyle(
                                                    fontFamily: 'Plus Jakarta Sans',
                                                    fontSize: 9.5,
                                                    fontWeight: FontWeight.w700,
                                                    color: isDark
                                                        ? const Color(0xFF94A3B8)
                                                        : const Color(0xFF475569),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 5),
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                    horizontal: 6, vertical: 1.5),
                                                decoration: BoxDecoration(
                                                  color: prodItem.isWholesale
                                                      ? const Color(0xFF0369A1).withValues(alpha: 0.12)
                                                      : const Color(0xFF059669).withValues(alpha: 0.12),
                                                  borderRadius: BorderRadius.circular(4),
                                                  border: Border.all(
                                                    color: prodItem.isWholesale
                                                        ? const Color(0xFF0369A1).withValues(alpha: 0.3)
                                                        : const Color(0xFF059669).withValues(alpha: 0.3),
                                                  ),
                                                ),
                                                child: Text(
                                                  prodItem.isWholesale ? 'Por mayor' : 'Al detalle',
                                                  style: TextStyle(
                                                    fontFamily: 'Plus Jakarta Sans',
                                                    fontSize: 9.5,
                                                    fontWeight: FontWeight.w800,
                                                    color: prodItem.isWholesale
                                                        ? const Color(0xFF0369A1)
                                                        : const Color(0xFF059669),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                    else
                                      for (final prod in item.products)
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 2),
                                          child: Text(
                                            '• $prod',
                                            style: TextStyle(
                                              fontFamily: 'Plus Jakarta Sans',
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500,
                                              color: textColor,
                                              height: 1.25,
                                            ),
                                          ),
                                        ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 10),

                              // Fila inferior: Fecha y Ahorro
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Icon(Icons.calendar_today_outlined,
                                            size: 12, color: subtextColor),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            item.formattedDate,
                                            style: TextStyle(
                                              fontFamily: 'Plus Jakarta Sans',
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500,
                                              color: subtextColor,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (!item.isExpired && item.savingsAmount > 0)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2.5),
                                      decoration: BoxDecoration(
                                        color: primaryColor.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'Ahorro: RD\$ ${item.savingsAmount.toStringAsFixed(0)}',
                                        style: TextStyle(
                                          fontFamily: 'Plus Jakarta Sans',
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w800,
                                          color: primaryColor,
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
              ),
            );
          },
        );
      },
    );
  }

  void _showHelpDialog(
    BuildContext context,
    Color primaryColor,
    Color surfaceColor,
    Color textColor,
    Color subtextColor,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: surfaceColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.help_outline, color: primaryColor),
              const SizedBox(width: 8),
              Text(
                'Cómo canjear cupones',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: textColor,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '1. Ingresa el código promocional (ej. COSECHA10 o REGRESA15) en la barra superior y pulsa "Canjear".',
                style: TextStyle(fontSize: 13, color: textColor),
              ),
              const SizedBox(height: 8),
              Text(
                '2. El cupón aparecerá en tu pestaña "Activos" listo para usarse.',
                style: TextStyle(fontSize: 13, color: textColor),
              ),
              const SizedBox(height: 8),
              Text(
                '3. En "Historial" podrás consultar en qué productos y en qué fechas canjeaste tus cupones.',
                style: TextStyle(fontSize: 13, color: textColor),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Entendido', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}

/// Contenedor con silueta estilo Ticket inspirada en Stitch (.ticket-cutout).
/// Integra muescas circulares laterales recortadas y sombra adaptativa que bordea las muescas.
class TicketCardWrapper extends StatelessWidget {
  final Widget child;
  final Color surfaceColor;
  final Color borderColor;
  final bool isDark;
  final double punchRadius;
  final double cornerRadius;

  const TicketCardWrapper({
    super.key,
    required this.child,
    required this.surfaceColor,
    required this.borderColor,
    required this.isDark,
    this.punchRadius = 9.0,
    this.cornerRadius = 14.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: TicketShapePainter(
        surfaceColor: surfaceColor,
        borderColor: borderColor,
        isDark: isDark,
        punchRadius: punchRadius,
        cornerRadius: cornerRadius,
      ),
      child: ClipPath(
        clipper: TicketClipper(
          punchRadius: punchRadius,
          cornerRadius: cornerRadius,
        ),
        child: child,
      ),
    );
  }
}

/// Clipper que genera la silueta de ticket con esquinas redondeadas y
/// muescas semicirculares en el lateral izquierdo (.ticket-cutout).
class TicketClipper extends CustomClipper<Path> {
  final double punchRadius;
  final double cornerRadius;

  const TicketClipper({
    this.punchRadius = 9.0,
    this.cornerRadius = 14.0,
  });

  @override
  Path getClip(Size size) {
    return buildTicketPath(size, punchRadius, cornerRadius);
  }

  @override
  bool shouldReclip(covariant TicketClipper oldClipper) {
    return oldClipper.punchRadius != punchRadius ||
        oldClipper.cornerRadius != cornerRadius;
  }

  static Path buildTicketPath(Size size, double punchRadius, double cornerRadius) {
    final path = Path();
    final w = size.width;
    final h = size.height;
    final r = cornerRadius;
    final pr = punchRadius;

    // Calcular posiciones verticales de las dos muescas (a ~32% y ~68% de altura)
    final y1 = (h * 0.32).clamp(r + pr + 2, h - r - pr - 2);
    final y2 = (h * 0.68).clamp(r + pr + 2, h - r - pr - 2);

    // Inicio en la arista superior tras la esquina sup-izq
    path.moveTo(r, 0);
    // Borde superior
    path.lineTo(w - r, 0);
    path.arcToPoint(Offset(w, r), radius: Radius.circular(r));
    // Borde lateral derecho
    path.lineTo(w, h - r);
    path.arcToPoint(Offset(w - r, h), radius: Radius.circular(r));
    // Borde inferior
    path.lineTo(r, h);
    path.arcToPoint(Offset(0, h - r), radius: Radius.circular(r));

    // Borde izquierdo de abajo hacia arriba:
    // 1. Tramo recto hasta muesca inferior
    path.lineTo(0, y2 + pr);
    // 2. Muesca semicircular hacia adentro
    path.arcToPoint(
      Offset(0, y2 - pr),
      radius: Radius.circular(pr),
      clockwise: true,
    );

    // 3. Tramo recto entre muescas
    path.lineTo(0, y1 + pr);
    // 4. Muesca semicircular superior
    path.arcToPoint(
      Offset(0, y1 - pr),
      radius: Radius.circular(pr),
      clockwise: true,
    );

    // 5. Tramo recto final hasta esquina sup-izq
    path.lineTo(0, r);
    path.arcToPoint(Offset(r, 0), radius: Radius.circular(r));

    path.close();
    return path;
  }
}

/// Painter para la sombra, el fondo y el borde perimetral del ticket
class TicketShapePainter extends CustomPainter {
  final Color surfaceColor;
  final Color borderColor;
  final bool isDark;
  final double punchRadius;
  final double cornerRadius;

  TicketShapePainter({
    required this.surfaceColor,
    required this.borderColor,
    required this.isDark,
    required this.punchRadius,
    required this.cornerRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = TicketClipper.buildTicketPath(size, punchRadius, cornerRadius);

    // Sombra perimetral que acompaña la curva de las muescas
    final shadowColor = Colors.black.withValues(alpha: isDark ? 0.35 : 0.08);
    canvas.drawShadow(path, shadowColor, 3.5, false);

    // Relleno de fondo del ticket
    final fillPaint = Paint()
      ..color = surfaceColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // Borde sutil continuo
    final strokePaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant TicketShapePainter oldDelegate) {
    return oldDelegate.surfaceColor != surfaceColor ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.isDark != isDark ||
        oldDelegate.punchRadius != punchRadius ||
        oldDelegate.cornerRadius != cornerRadius;
  }
}

/// Painter que dibuja la línea discontinua/punteada de perforación vertical
class DashedVerticalLinePainter extends CustomPainter {
  final Color color;
  final double dashHeight;
  final double dashSpace;
  final double strokeWidth;

  const DashedVerticalLinePainter({
    required this.color,
    this.dashHeight = 4.0,
    this.dashSpace = 4.0,
    this.strokeWidth = 1.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    double startY = 0;
    final x = size.width / 2;

    while (startY < size.height) {
      final endY = (startY + dashHeight > size.height) ? size.height : startY + dashHeight;
      canvas.drawLine(Offset(x, startY), Offset(x, endY), paint);
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant DashedVerticalLinePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.dashHeight != dashHeight ||
        oldDelegate.dashSpace != dashSpace ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
