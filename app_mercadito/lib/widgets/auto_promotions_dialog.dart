import 'package:flutter/material.dart';
import '../models/coupon_model.dart';
import '../services/coupons_service.dart';

class AutoPromotionsDialog extends StatefulWidget {
  final AutoPromotionRule? initialRule;

  const AutoPromotionsDialog({super.key, this.initialRule});

  static void show(BuildContext context, {AutoPromotionRule? rule}) {
    // Si no se especifica una regla, usar la primera existente si hay alguna
    final currentRule = rule ??
        (CouponsService.instance.autoPromotionsNotifier.value.isNotEmpty
            ? CouponsService.instance.autoPromotionsNotifier.value.first
            : null);

    showDialog(
      context: context,
      builder: (context) => AutoPromotionsDialog(initialRule: currentRule),
    );
  }

  @override
  State<AutoPromotionsDialog> createState() => _AutoPromotionsDialogState();
}

class _AutoPromotionsDialogState extends State<AutoPromotionsDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _minOrdersController;
  late final TextEditingController _minSpentController;
  late final TextEditingController _rewardController;
  late final TextEditingController _expirationDaysController;
  late bool _isEnabled;

  @override
  void initState() {
    super.initState();
    final rule = widget.initialRule;
    _titleController =
        TextEditingController(text: rule?.title ?? 'Recompensa por Fidelidad');
    _minOrdersController =
        TextEditingController(text: '${rule?.minCompletedOrders ?? 5}');
    _minSpentController = TextEditingController(
      text: rule != null ? rule.minAccumulatedSpent.toStringAsFixed(0) : '10000',
    );
    _rewardController = TextEditingController(
      text: rule != null ? rule.rewardDiscountAmount.toStringAsFixed(0) : '500',
    );
    _expirationDaysController =
        TextEditingController(text: '${rule?.expirationDays ?? 15}');
    _isEnabled = rule?.isEnabled ?? true;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _minOrdersController.dispose();
    _minSpentController.dispose();
    _rewardController.dispose();
    _expirationDaysController.dispose();
    super.dispose();
  }

  void _confirmDelete(BuildContext context, AutoPromotionRule rule) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          '¿Eliminar motor de promociones?',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
        content: Text(
          'Se eliminará la regla "${rule.title}" y el sistema dejará de generar cupones automáticos para los compradores que cumplan las metas.',
          style: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 13,
            color: Color(0xFF64748b),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.delete_outline, size: 16),
            label: const Text('Eliminar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              CouponsService.instance.deleteAutoPromotion(rule.id);
              Navigator.pop(ctx); // Cierra confirmación
              Navigator.pop(context); // Cierra diálogo principal
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Motor de promociones eliminado correctamente.'),
                  backgroundColor: Color(0xFFDC2626),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    const primary = Color(0xFF016142);
    final bg = isDark ? const Color(0xFF0d1a15) : Colors.white;
    final cardBg = isDark ? const Color(0xFF162520) : const Color(0xFFF6FAF7);
    final text = isDark ? Colors.white : const Color(0xFF0f172a);
    final subtext = isDark ? const Color(0xFF94a3b8) : const Color(0xFF64748b);
    final border = isDark ? const Color(0xFF22382e) : const Color(0xFFE2E8F0);

    final isExistingRule = widget.initialRule != null;
    final rule = widget.initialRule;

    return Dialog(
      backgroundColor: bg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con Icono y Botón Cerrar
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.auto_awesome_rounded,
                          color: primary, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Motor de Promociones',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: text,
                            ),
                          ),
                          Text(
                            'Generación automática de cupones por fidelidad',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 12,
                              color: subtext,
                            ),
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

                const SizedBox(height: 14),
                const Divider(height: 1),
                const SizedBox(height: 14),

                // Control de Estado: Activo / Pausado
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: _isEnabled
                        ? const Color(0xFFEDF3F0)
                        : (isDark ? const Color(0xFF2A2016) : const Color(0xFFFEF3C7)),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _isEnabled
                          ? primary.withValues(alpha: 0.3)
                          : const Color(0xFFF59E0B).withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: _isEnabled ? primary : const Color(0xFFD97706),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _isEnabled
                                  ? Icons.check_circle_rounded
                                  : Icons.pause_circle_filled_rounded,
                              color: Colors.white,
                              size: 13,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              _isEnabled ? 'ACTIVO' : 'PAUSADO',
                              style: const TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Regla Activa del Motor',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: _isEnabled
                                    ? const Color(0xFF004532)
                                    : const Color(0xFF92400E),
                              ),
                            ),
                            Text(
                              _isEnabled
                                  ? 'Generación automática cuando los compradores cumplen la meta.'
                                  : 'Motor pausado: No se emitirán cupones hasta reanudar.',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 11,
                                color: _isEnabled
                                    ? const Color(0xFF004532)
                                    : const Color(0xFF92400E),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _isEnabled,
                        activeThumbColor: primary,
                        activeTrackColor: primary.withValues(alpha: 0.35),
                        onChanged: (val) {
                          setState(() {
                            _isEnabled = val;
                          });
                        },
                      ),
                    ],
                  ),
                ),

                // Sección de Desarrollo de los Cupones (Métricas si la regla existe)
                if (isExistingRule && rule != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.analytics_outlined,
                                color: primary, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              'Desarrollo del Motor y Cupones',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: text,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _buildMetricPill(
                                icon: Icons.auto_awesome,
                                label: 'Emitidos',
                                value: '${rule.generatedCouponsCount}',
                                color: primary,
                                isDark: isDark,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: _buildMetricPill(
                                icon: Icons.shopping_bag_outlined,
                                label: 'Canjeados',
                                value: '${rule.redeemedCouponsCount}',
                                color: const Color(0xFF2563EB),
                                isDark: isDark,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: _buildMetricPill(
                                icon: Icons.monetization_on_outlined,
                                label: 'Premios',
                                value: 'RD\$ ${rule.totalRewardsGiven.toStringAsFixed(0)}',
                                color: const Color(0xFF059669),
                                isDark: isDark,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 14),

                // Nombre de la Regla
                Text(
                  'Nombre de la regla',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: text,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: 'Ej. Recompensa por Fidelidad',
                    filled: true,
                    fillColor: cardBg,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: border),
                    ),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                ),

                const SizedBox(height: 14),

                // Condición 1: Compras mínimas y Gasto acumulado
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Compras mínimas (>=)',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: text,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _minOrdersController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              suffixText: 'pedidos',
                              filled: true,
                              fillColor: cardBg,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: border),
                              ),
                            ),
                            validator: (v) =>
                                (v == null || v.isEmpty) ? 'Requerido' : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Gasto acumulado (>=)',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: text,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _minSpentController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              prefixText: 'RD\$ ',
                              filled: true,
                              fillColor: cardBg,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: border),
                              ),
                            ),
                            validator: (v) =>
                                (v == null || v.isEmpty) ? 'Requerido' : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Recompensa y Expiración
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Descuento otorgado',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: text,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _rewardController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              prefixText: 'RD\$ ',
                              filled: true,
                              fillColor: cardBg,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: border),
                              ),
                            ),
                            validator: (v) =>
                                (v == null || v.isEmpty) ? 'Requerido' : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Expira en',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: text,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _expirationDaysController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              suffixText: 'días',
                              filled: true,
                              fillColor: cardBg,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: border),
                              ),
                            ),
                            validator: (v) =>
                                (v == null || v.isEmpty) ? 'Requerido' : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                // Actions: Borrar (si existe), Cancelar y Guardar
                SizedBox(
                  width: double.infinity,
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (isExistingRule && rule != null)
                        TextButton.icon(
                          icon: const Icon(Icons.delete_outline,
                              size: 18, color: Color(0xFFDC2626)),
                          label: const Text(
                            'Borrar',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFDC2626),
                            ),
                          ),
                          onPressed: () => _confirmDelete(context, rule),
                        )
                      else
                        const SizedBox.shrink(),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child:
                                Text('Cancelar', style: TextStyle(color: subtext)),
                          ),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.check_circle_outline, size: 18),
                            label: const Text(
                              'Guardar y Activar',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primary,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(0, 44),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                            if (_formKey.currentState?.validate() ?? false) {
                              final updatedRule = AutoPromotionRule(
                                id: widget.initialRule?.id ??
                                    'AUTO-${DateTime.now().millisecondsSinceEpoch}',
                                title: _titleController.text.trim(),
                                minCompletedOrders: int.tryParse(
                                        _minOrdersController.text) ??
                                    5,
                                minAccumulatedSpent: double.tryParse(
                                        _minSpentController.text) ??
                                    10000.0,
                                rewardDiscountAmount: double.tryParse(
                                        _rewardController.text) ??
                                    500.0,
                                expirationDays: int.tryParse(
                                        _expirationDaysController.text) ??
                                    15,
                                isEnabled: _isEnabled,
                                generatedCouponsCount:
                                    widget.initialRule?.generatedCouponsCount ?? 0,
                                redeemedCouponsCount:
                                    widget.initialRule?.redeemedCouponsCount ?? 0,
                                totalRewardsGiven:
                                    widget.initialRule?.totalRewardsGiven ?? 0.0,
                                createdAt: widget.initialRule?.createdAt ??
                                    DateTime.now(),
                              );
                              CouponsService.instance
                                  .saveAutoPromotion(updatedRule);
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    _isEnabled
                                        ? '¡Motor de promociones guardado y ACTIVO!'
                                        : 'Motor de promociones guardado como PAUSADO.',
                                  ),
                                  backgroundColor: _isEnabled
                                      ? primary
                                      : const Color(0xFFD97706),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricPill({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E3228) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? const Color(0xFF284838) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748b),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF0f172a),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
