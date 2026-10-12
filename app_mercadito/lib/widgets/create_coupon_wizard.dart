import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/coupon_model.dart';
import '../services/coupons_service.dart';

class CreateCouponWizard extends StatefulWidget {
  final Coupon? initialCoupon;

  const CreateCouponWizard({super.key, this.initialCoupon});

  static void show(BuildContext context, {Coupon? coupon}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateCouponWizard(initialCoupon: coupon),
    );
  }

  @override
  State<CreateCouponWizard> createState() => _CreateCouponWizardState();
}

class _CreateCouponWizardState extends State<CreateCouponWizard> {
  int _currentStep = 1;

  // Paso 1: Info Básica
  final _titleController = TextEditingController();
  final _codeController = TextEditingController();
  String _selectedCategory = 'FRUTAS & VERDURAS';
  bool _showTitleError = false;

  bool get _isTitleValid => _titleController.text.trim().length >= 4;

  String get _titleErrorMessage {
    final text = _titleController.text.trim();
    if (text.isEmpty) {
      return 'El título de la promoción es obligatorio.';
    }
    if (text.length < 4) {
      return 'Debe contener al menos 4 caracteres (ingresaste ${text.length}).';
    }
    return '';
  }

  void _onTitleChanged() {
    if (_showTitleError) {
      setState(() {
        if (_isTitleValid) {
          _showTitleError = false;
        }
      });
    } else {
      setState(() {});
    }
  }

  // Paso 2: Beneficio
  CouponBenefitType _selectedBenefitType = CouponBenefitType.percentage;
  final _benefitValueController = TextEditingController(text: '10');
  final _giftNameController = TextEditingController();
  final _specialPriceLabelController = TextEditingController();

  // Paso 3: Reglas
  CouponScope _selectedScope = CouponScope.allProducts;
  final _productSearchController = TextEditingController();
  final Set<String> _selectedProductIds = {};
  final _minPurchaseController = TextEditingController(text: '1500');
  final _totalUsageLimitController = TextEditingController(text: '100');
  final _usagePerBuyerController = TextEditingController(text: '1');
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  final Set<int> _selectedDays = {}; // 1=Lun, 7=Dom

  // Paso 4: Segmentación
  CouponAudience _selectedAudience = CouponAudience.allBuyers;
  final _buyerSearchController = TextEditingController();
  final Set<String> _selectedBuyerIds = {};
  final _inactiveDaysController = TextEditingController(text: '15');

  final List<String> _categories = [
    'FRUTAS & VERDURAS',
    'ORGÁNICOS',
    'PANADERÍA',
    'LÁCTEOS',
    'GRANOS & CEREALES',
    'GENERAL',
  ];

  @override
  void initState() {
    super.initState();
    _titleController.addListener(_onTitleChanged);
    if (widget.initialCoupon != null) {
      final c = widget.initialCoupon!;
      _titleController.text = c.title;
      _codeController.text = c.code;
      _selectedCategory = c.category;

      _selectedBenefitType = c.benefit.type;
      _benefitValueController.text = c.benefit.value.toStringAsFixed(0);
      _giftNameController.text = c.benefit.customGiftName ?? '';
      _specialPriceLabelController.text = c.benefit.specialPriceLabel ?? '';

      _selectedScope = c.rule.scope == CouponScope.specificCategories
          ? CouponScope.allProducts
          : c.rule.scope;
      _selectedProductIds.addAll(c.rule.targetProducts);
      _minPurchaseController.text = c.rule.minPurchase.toStringAsFixed(0);
      _totalUsageLimitController.text = c.rule.totalUsageLimit.toString();
      _usagePerBuyerController.text = c.rule.usagePerBuyer.toString();
      _startDate = c.rule.startDate;
      _endDate = c.rule.endDate;
      _selectedDays.addAll(c.rule.applicableDays);

      _selectedAudience = c.target.audience;
      _selectedBuyerIds.addAll(c.target.selectedBuyerIds);
      _inactiveDaysController.text = c.target.inactiveDaysThreshold.toString();
    } else {
      _codeController.text = CouponsService.instance.generateCouponCode(prefix: 'PROMO');
    }
  }

  @override
  void dispose() {
    _titleController.removeListener(_onTitleChanged);
    _titleController.dispose();
    _codeController.dispose();
    _benefitValueController.dispose();
    _giftNameController.dispose();
    _specialPriceLabelController.dispose();
    _productSearchController.dispose();
    _minPurchaseController.dispose();
    _totalUsageLimitController.dispose();
    _usagePerBuyerController.dispose();
    _buyerSearchController.dispose();
    _inactiveDaysController.dispose();
    super.dispose();
  }

  void _generateRandomCode() {
    setState(() {
      _codeController.text = CouponsService.instance.generateCouponCode(
        prefix: _titleController.text.isNotEmpty
            ? _titleController.text.substring(0, _titleController.text.length.clamp(0, 5))
            : 'OFERTA',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    const primary = Color(0xFF016142);
    final bg = isDark ? const Color(0xFF162B23) : const Color(0xFFF9FAF5);
    final text = isDark ? Colors.white : const Color(0xFF141A15);
    final subtext = isDark ? const Color(0xFF94A3B8) : const Color(0xFF435245);
    final border = isDark ? const Color(0xFF2E4E41) : const Color(0xFFD0D9CD);
    final mintContainer = isDark ? const Color(0xFF1E382E) : const Color(0xFFE5F1EB);
    final mintBorder = isDark ? const Color(0xFF2E6348) : const Color(0xFFA7E8C3);

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.6,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                    color: subtext.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),

              // Top Title Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: mintContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.close_rounded, size: 20, color: primary),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          widget.initialCoupon != null ? 'Editar Cupón' : 'Crear Nuevo Cupón',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            color: text,
                          ),
                        ),
                      ],
                    ),
                    // Live Step pill badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: mintContainer,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: mintBorder),
                      ),
                      child: Text(
                        'Paso $_currentStep de 4',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Stepper Indicator (1 a 4)
              _buildStepIndicator(primary, isDark),

              Divider(
                height: 1,
                color: isDark ? const Color(0xFF2E4E41) : const Color(0xFFD0D9CD).withValues(alpha: 0.5),
              ),

              // Content of current step
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    if (_currentStep == 1) _buildStep1(text, subtext, border, isDark, primary),
                    if (_currentStep == 2) _buildStep2(text, subtext, border, isDark, primary),
                    if (_currentStep == 3) _buildStep3(text, subtext, border, isDark, primary),
                    if (_currentStep == 4) _buildStep4(text, subtext, border, isDark, primary),
                  ],
                ),
              ),

              // Bottom Navigation Bar (Atrás / Siguiente / Guardar)
              _buildBottomControls(primary, subtext, border, isDark),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStepIndicator(Color primary, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          _stepNode(1, 'Básico', primary, isDark),
          _stepLine(1, primary, isDark),
          _stepNode(2, 'Beneficio', primary, isDark),
          _stepLine(2, primary, isDark),
          _stepNode(3, 'Reglas', primary, isDark),
          _stepLine(3, primary, isDark),
          _stepNode(4, 'Segmento', primary, isDark),
        ],
      ),
    );
  }

  Widget _stepNode(int step, String label, Color primary, bool isDark) {
    final isDone = _currentStep > step;
    final isCurrent = _currentStep == step;

    Color circleColor;
    Color textColor;
    Border? border;

    if (isCurrent) {
      circleColor = primary;
      textColor = Colors.white;
    } else if (isDone) {
      circleColor = isDark ? const Color(0xFF1E382E) : const Color(0xFFD1FAE5);
      textColor = primary;
    } else {
      circleColor = isDark ? const Color(0xFF1E382E) : const Color(0xFFF3F6EC);
      textColor = isDark ? Colors.grey[400]! : const Color(0xFF435245);
      border = Border.all(color: isDark ? const Color(0xFF2E4E41) : const Color(0xFFD0D9CD));
    }

    return Expanded(
      child: InkWell(
        onTap: () {
          if (step > 1 && !_isTitleValid) {
            setState(() {
              _showTitleError = true;
              _currentStep = 1;
            });
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _titleErrorMessage,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                backgroundColor: const Color(0xFFDC2626),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                duration: const Duration(seconds: 3),
              ),
            );
            return;
          }
          setState(() => _currentStep = step);
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: circleColor,
                borderRadius: BorderRadius.circular(10),
                border: border,
                boxShadow: isCurrent
                    ? [
                        BoxShadow(
                          color: primary.withValues(alpha: 0.28),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: isDone
                    ? Icon(Icons.check_rounded, size: 16, color: primary)
                    : Text(
                        '$step',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
                color: isCurrent
                    ? primary
                    : (isDark ? Colors.grey[400] : const Color(0xFF435245)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepLine(int afterStep, Color primary, bool isDark) {
    final isDone = _currentStep > afterStep;
    return Expanded(
      child: Container(
        height: 2.5,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isDone
              ? primary
              : (isDark ? const Color(0xFF2E4E41) : const Color(0xFFD0D9CD)),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  // --- PASO 1 ---
  Widget _buildStep1(Color text, Color subtext, Color border, bool isDark, Color primary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Paso 1 — Información básica',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: text,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Define el título descriptivo, código de canje y categoría comercial.',
          style: GoogleFonts.plusJakartaSans(fontSize: 13, color: subtext),
        ),
        const SizedBox(height: 20),

        // Título del cupón
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Título de la promoción / cupón *',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _showTitleError && !_isTitleValid
                      ? const Color(0xFFEF4444)
                      : text,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _titleController.text.trim().isNotEmpty
                  ? '${_titleController.text.trim().length} / 4 mín.'
                  : 'Mínimo 4 caracteres',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _showTitleError && !_isTitleValid
                    ? const Color(0xFFEF4444)
                    : (_isTitleValid
                        ? (isDark ? const Color(0xFF80C652) : const Color(0xFF059669))
                        : subtext),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _titleController,
          style: GoogleFonts.plusJakartaSans(fontSize: 13, color: text),
          decoration: InputDecoration(
            hintText: 'Ej. 10% Descuento de Temporada',
            hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: subtext.withValues(alpha: 0.6)),
            filled: true,
            fillColor: isDark ? const Color(0xFF1E382E) : Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            errorText: _showTitleError && !_isTitleValid ? _titleErrorMessage : null,
            errorStyle: GoogleFonts.plusJakartaSans(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFEF4444),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: _showTitleError && !_isTitleValid
                    ? const Color(0xFFEF4444)
                    : border,
                width: _showTitleError && !_isTitleValid ? 1.5 : 1.2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: _showTitleError && !_isTitleValid
                    ? const Color(0xFFEF4444)
                    : primary,
                width: 1.8,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.8),
            ),
            suffixIcon: _isTitleValid
                ? const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF10B981),
                    size: 20,
                  )
                : (_showTitleError
                    ? const Icon(
                        Icons.error_outline_rounded,
                        color: Color(0xFFEF4444),
                        size: 20,
                      )
                    : null),
          ),
        ),

        const SizedBox(height: 18),

        // Código del cupón
        Text(
          'Código del cupón',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: text,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _codeController,
                textCapitalization: TextCapitalization.characters,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  fontSize: 14,
                  color: text,
                ),
                decoration: InputDecoration(
                  hintText: 'Ej. SEPTIEMBRE10',
                  hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: subtext.withValues(alpha: 0.6)),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1E382E) : Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: border, width: 1.2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: primary, width: 1.8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: Text(
                'Generar',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? const Color(0xFF1E382E) : const Color(0xFFE5F1EB),
                foregroundColor: isDark ? const Color(0xFF67C83B) : primary,
                side: BorderSide(
                  color: isDark ? const Color(0xFF2E6348) : const Color(0xFFA7E8C3),
                ),
                minimumSize: const Size(0, 48),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _generateRandomCode,
            ),
          ],
        ),

        const SizedBox(height: 18),

        // Categoría
        Text(
          'Categoría de productos',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: text,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E382E) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: border, width: 1.2),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCategory,
              isExpanded: true,
              dropdownColor: isDark ? const Color(0xFF1E382E) : Colors.white,
              items: _categories.map((cat) {
                return DropdownMenuItem(
                  value: cat,
                  child: Text(
                    cat,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: text,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedCategory = val);
              },
            ),
          ),
        ),
      ],
    );
  }

  // --- PASO 2 ---
  Widget _buildStep2(Color text, Color subtext, Color border, bool isDark, Color primary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Paso 2 — ¿Qué beneficio obtiene el comprador?',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
            color: text,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Selecciona la modalidad de beneficio o descuento que aplicará el cupón.',
          style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: subtext, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 20),

        // Selector de modalidades estilo tarjetas de misiones
        Column(
          children: CouponBenefitType.values.map((type) {
            final isSelected = _selectedBenefitType == type;

            IconData iconData;
            Color iconBg;
            Color iconColor;
            String typeDesc;

            switch (type) {
              case CouponBenefitType.percentage:
                iconData = Icons.percent_rounded;
                iconBg = isDark ? const Color(0xFF1E382E) : const Color(0xFFE5F1EB);
                iconColor = isDark ? const Color(0xFF67C83B) : primary;
                typeDesc = 'Descuento porcentual sobre el valor de la compra';
                break;
              case CouponBenefitType.fixedAmount:
                iconData = Icons.monetization_on_rounded;
                iconBg = isDark ? const Color(0xFF332617) : const Color(0xFFFEF3C7);
                iconColor = isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706);
                typeDesc = 'Monto fijo exacto a rebajar del total en RD\$';
                break;
              case CouponBenefitType.freeShipping:
                iconData = Icons.local_shipping_rounded;
                iconBg = isDark ? const Color(0xFF162520) : const Color(0xFFE0F2FE);
                iconColor = isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7);
                typeDesc = 'Envío o transporte bonificado al 100%';
                break;
              case CouponBenefitType.twoForOne:
                iconData = Icons.repeat_rounded;
                iconBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFDBEAFE);
                iconColor = isDark ? const Color(0xFF60A5FA) : const Color(0xFF1D4ED8);
                typeDesc = 'Lleva 2 y paga 1 en productos seleccionados';
                break;
              case CouponBenefitType.giftProduct:
                iconData = Icons.card_giftcard_rounded;
                iconBg = isDark ? const Color(0xFF2E1A38) : const Color(0xFFF3E8FF);
                iconColor = isDark ? const Color(0xFFC084FC) : const Color(0xFF9333EA);
                typeDesc = 'Obsequio o producto de cortesía adicional';
                break;
              case CouponBenefitType.specialPrice:
                iconData = Icons.sell_rounded;
                iconBg = isDark ? const Color(0xFF132E2B) : const Color(0xFFCCFBF1);
                iconColor = isDark ? const Color(0xFF5EEAD4) : const Color(0xFF0F766E);
                typeDesc = 'Tarifa especial o precio promocional por unidad';
                break;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => setState(() => _selectedBenefitType = type),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isDark ? const Color(0xFF1E382E) : const Color(0xFFF0FDF4))
                        : (isDark ? const Color(0xFF1E382E) : Colors.white),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isSelected
                          ? primary
                          : border.withValues(alpha: 0.7),
                      width: isSelected ? 1.8 : 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected
                            ? primary.withValues(alpha: 0.12)
                            : Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Badge ícono 44x44
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: iconBg,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(iconData, size: 22, color: iconColor),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              type.label,
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w800,
                                fontSize: 13.5,
                                color: text,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              typeDesc,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                color: subtext,
                                height: 1.25,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Radio indicador estilo tareas
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? primary : Colors.transparent,
                          border: Border.all(
                            color: isSelected ? primary : border,
                            width: 1.8,
                          ),
                        ),
                        child: isSelected
                            ? const Center(
                                child: Icon(Icons.circle, size: 8, color: Colors.white),
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 16),

        // Inputs dinámicos según el tipo de beneficio seleccionado
        if (_selectedBenefitType == CouponBenefitType.percentage ||
            _selectedBenefitType == CouponBenefitType.fixedAmount) ...[
          Text(
            _selectedBenefitType == CouponBenefitType.percentage
                ? 'Valor del porcentaje de descuento (%) *'
                : 'Monto de descuento directo (RD\$) *',
            style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: text),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _benefitValueController,
            keyboardType: TextInputType.number,
            style: GoogleFonts.plusJakartaSans(fontSize: 13, color: text),
            decoration: InputDecoration(
              suffixText: _selectedBenefitType == CouponBenefitType.percentage ? '%' : 'RD\$',
              suffixStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: primary),
              hintText: _selectedBenefitType == CouponBenefitType.percentage ? '10' : '200',
              hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: subtext.withValues(alpha: 0.6)),
              filled: true,
              fillColor: isDark ? const Color(0xFF1E382E) : Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: border, width: 1.2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: primary, width: 1.8),
              ),
            ),
          ),
        ],

        if (_selectedBenefitType == CouponBenefitType.giftProduct) ...[
          Text(
            'Nombre del producto de regalo',
            style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: text),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _giftNameController,
            style: GoogleFonts.plusJakartaSans(fontSize: 13, color: text),
            decoration: InputDecoration(
              hintText: 'Ej. 1 Canasta de fresas de cortesía',
              hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: subtext.withValues(alpha: 0.6)),
              filled: true,
              fillColor: isDark ? const Color(0xFF1E382E) : Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: border, width: 1.2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: primary, width: 1.8),
              ),
            ),
          ),
        ],

        if (_selectedBenefitType == CouponBenefitType.specialPrice) ...[
          Text(
            'Etiqueta o precio especial',
            style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: text),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _specialPriceLabelController,
            style: GoogleFonts.plusJakartaSans(fontSize: 13, color: text),
            decoration: InputDecoration(
              hintText: 'Ej. RD\$ 35 / KG en Tomate',
              hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: subtext.withValues(alpha: 0.6)),
              filled: true,
              fillColor: isDark ? const Color(0xFF1E382E) : Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: border, width: 1.2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: primary, width: 1.8),
              ),
            ),
          ),
        ],
      ],
    );
  }

  // --- PASO 3 ---
  Widget _buildStep3(Color text, Color subtext, Color border, bool isDark, Color primary) {
    final allProducts = CouponsService.instance.getProviderProductsForCoupons();
    final query = _productSearchController.text.trim().toLowerCase();
    final filteredProducts = query.isEmpty
        ? allProducts
        : allProducts.where((p) {
            final name = (p['name'] as String).toLowerCase();
            final sku = (p['sku'] as String).toLowerCase();
            return name.contains(query) || sku.contains(query);
          }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Paso 3 — Reglas del cupón',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
            color: text,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Establece límites de uso, compra mínima, productos aplicables y vigencia.',
          style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: subtext, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 20),

        // Ámbito de aplicación (Todos o Específicos)
        Text(
          '¿Dónde aplica el cupón?',
          style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: text),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedScope = CouponScope.allProducts),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _selectedScope == CouponScope.allProducts ? primary : border,
                      width: _selectedScope == CouponScope.allProducts ? 1.8 : 1.0,
                    ),
                    color: _selectedScope == CouponScope.allProducts
                        ? (isDark ? const Color(0xFF1E382E) : const Color(0xFFF0FDF4))
                        : (isDark ? const Color(0xFF1E382E) : Colors.white),
                    boxShadow: [
                      BoxShadow(
                        color: _selectedScope == CouponScope.allProducts
                            ? primary.withValues(alpha: 0.08)
                            : Colors.black.withValues(alpha: 0.025),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _selectedScope == CouponScope.allProducts
                              ? (isDark ? const Color(0xFF1E382E) : const Color(0xFFE5F1EB))
                              : (isDark ? const Color(0xFF162B23) : const Color(0xFFF3F6EC)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.select_all_rounded,
                          size: 22,
                          color: _selectedScope == CouponScope.allProducts ? primary : subtext,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Todos los productos',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          fontWeight: _selectedScope == CouponScope.allProducts ? FontWeight.w800 : FontWeight.w700,
                          color: _selectedScope == CouponScope.allProducts ? primary : text,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Sin distinción de producto',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(fontSize: 10.5, color: subtext, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedScope = CouponScope.specificProducts),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _selectedScope == CouponScope.specificProducts ? primary : border,
                      width: _selectedScope == CouponScope.specificProducts ? 1.8 : 1.0,
                    ),
                    color: _selectedScope == CouponScope.specificProducts
                        ? (isDark ? const Color(0xFF1E382E) : const Color(0xFFF0FDF4))
                        : (isDark ? const Color(0xFF1E382E) : Colors.white),
                    boxShadow: [
                      BoxShadow(
                        color: _selectedScope == CouponScope.specificProducts
                            ? primary.withValues(alpha: 0.08)
                            : Colors.black.withValues(alpha: 0.025),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _selectedScope == CouponScope.specificProducts
                              ? (isDark ? const Color(0xFF1E382E) : const Color(0xFFE5F1EB))
                              : (isDark ? const Color(0xFF162B23) : const Color(0xFFF3F6EC)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.checklist_rounded,
                          size: 22,
                          color: _selectedScope == CouponScope.specificProducts ? primary : subtext,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Productos específicos',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          fontWeight: _selectedScope == CouponScope.specificProducts ? FontWeight.w800 : FontWeight.w700,
                          color: _selectedScope == CouponScope.specificProducts ? primary : text,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Detalle o al por mayor',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(fontSize: 10.5, color: subtext, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        // Catálogo interactivo de productos con buscador
        if (_selectedScope == CouponScope.specificProducts) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E382E) : const Color(0xFFF3F6EC),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Catálogo de Productos',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: text,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF162B23) : const Color(0xFFE5F1EB),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark ? const Color(0xFF2E6348) : const Color(0xFFA7E8C3),
                        ),
                      ),
                      child: Text(
                        '${_selectedProductIds.length} selec.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _productSearchController,
                  onChanged: (_) => setState(() {}),
                  style: GoogleFonts.plusJakartaSans(fontSize: 13, color: text),
                  decoration: InputDecoration(
                    hintText: 'Buscar por nombre o SKU...',
                    hintStyle: GoogleFonts.plusJakartaSans(fontSize: 12, color: subtext.withValues(alpha: 0.6)),
                    prefixIcon: const Icon(Icons.search_rounded, size: 18),
                    suffixIcon: _productSearchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 16),
                            onPressed: () => setState(() => _productSearchController.clear()),
                          )
                        : null,
                    isDense: true,
                    filled: true,
                    fillColor: isDark ? const Color(0xFF162B23) : Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: primary, width: 1.8),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: () {
                        setState(() {
                          if (_selectedProductIds.length == filteredProducts.length) {
                            _selectedProductIds.clear();
                          } else {
                            _selectedProductIds.addAll(filteredProducts.map((p) => p['id'] as String));
                          }
                        });
                      },
                      child: Text(
                        _selectedProductIds.length == filteredProducts.length ? 'Desmarcar todos' : 'Marcar todos',
                        style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w800, color: primary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  constraints: const BoxConstraints(maxHeight: 220),
                  child: filteredProducts.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                            child: Text(
                              'No se encontraron productos coincidentes',
                              style: GoogleFonts.plusJakartaSans(fontSize: 12, color: subtext),
                            ),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          itemCount: filteredProducts.length,
                          separatorBuilder: (context, index) => Divider(height: 1, color: border.withValues(alpha: 0.4)),
                          itemBuilder: (context, idx) {
                            final prod = filteredProducts[idx];
                            final id = prod['id'] as String;
                            final isWholesale = prod['isWholesale'] as bool;
                            final isSelected = _selectedProductIds.contains(id);

                            return InkWell(
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    _selectedProductIds.remove(id);
                                  } else {
                                    _selectedProductIds.add(id);
                                  }
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: Checkbox(
                                        value: isSelected,
                                        activeColor: primary,
                                        onChanged: (val) {
                                          setState(() {
                                            if (val == true) {
                                              _selectedProductIds.add(id);
                                            } else {
                                              _selectedProductIds.remove(id);
                                            }
                                          });
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            prod['name'] as String,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: text,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                                decoration: BoxDecoration(
                                                  color: isDark ? Colors.grey[800] : const Color(0xFFE2E8F0),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  '#${prod['sku']}',
                                                  style: GoogleFonts.plusJakartaSans(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w600,
                                                    color: isDark ? Colors.grey[300] : const Color(0xFF475569),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                                decoration: BoxDecoration(
                                                  color: isWholesale
                                                      ? const Color(0xFF0369A1).withValues(alpha: 0.12)
                                                      : const Color(0xFF059669).withValues(alpha: 0.12),
                                                  borderRadius: BorderRadius.circular(4),
                                                  border: Border.all(
                                                    color: isWholesale
                                                        ? const Color(0xFF0369A1).withValues(alpha: 0.3)
                                                        : const Color(0xFF059669).withValues(alpha: 0.3),
                                                  ),
                                                ),
                                                child: Text(
                                                  prod['modality'] as String,
                                                  style: GoogleFonts.plusJakartaSans(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w800,
                                                    color: isWholesale ? const Color(0xFF0369A1) : const Color(0xFF059669),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      prod['priceFormatted'] as String,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 18),

        // Compra Mínima
        Text(
          'Compra mínima requerida (RD\$)',
          style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: text),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _minPurchaseController,
          keyboardType: TextInputType.number,
          style: GoogleFonts.plusJakartaSans(fontSize: 13, color: text),
          decoration: InputDecoration(
            prefixText: 'RD\$ ',
            prefixStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: primary),
            hintText: '1500',
            filled: true,
            fillColor: isDark ? const Color(0xFF1E382E) : Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: border, width: 1.2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: primary, width: 1.8),
            ),
          ),
        ),

        const SizedBox(height: 18),

        // Límites de Usos
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Usos máximos totales',
                    style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: text),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _totalUsageLimitController,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.plusJakartaSans(fontSize: 13, color: text),
                    decoration: InputDecoration(
                      hintText: '100',
                      filled: true,
                      fillColor: isDark ? const Color(0xFF1E382E) : Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: border, width: 1.2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: primary, width: 1.8),
                      ),
                    ),
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
                    'Usos por comprador',
                    style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: text),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _usagePerBuyerController,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.plusJakartaSans(fontSize: 13, color: text),
                    decoration: InputDecoration(
                      hintText: '1',
                      filled: true,
                      fillColor: isDark ? const Color(0xFF1E382E) : Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: border, width: 1.2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: primary, width: 1.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        // Vigencia
        Text(
          'Vigencia del cupón',
          style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: text),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.calendar_month_rounded, size: 16),
                label: Text(
                  '${_startDate.day}/${_startDate.month}/${_startDate.year}',
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: text,
                  backgroundColor: isDark ? const Color(0xFF1E382E) : Colors.white,
                  side: BorderSide(color: border, width: 1.2),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _startDate,
                    firstDate: DateTime.now().subtract(const Duration(days: 30)),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) setState(() => _startDate = picked);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'hasta',
                style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: subtext, fontWeight: FontWeight.w600),
              ),
            ),
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.calendar_month_rounded, size: 16),
                label: Text(
                  '${_endDate.day}/${_endDate.month}/${_endDate.year}',
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: text,
                  backgroundColor: isDark ? const Color(0xFF1E382E) : Colors.white,
                  side: BorderSide(color: border, width: 1.2),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _endDate,
                    firstDate: _startDate,
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) setState(() => _endDate = picked);
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Días de la semana con nombres completos (estilo Chips de Tareas)
        Text(
          'Días válidos de la semana (opcional)',
          style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: text),
        ),
        const SizedBox(height: 4),
        Text(
          'Si no seleccionas ninguno, el cupón será válido todos los días.',
          style: GoogleFonts.plusJakartaSans(fontSize: 11, color: subtext, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (int d = 1; d <= 7; d++)
              InkWell(
                onTap: () {
                  setState(() {
                    if (_selectedDays.contains(d)) {
                      _selectedDays.remove(d);
                    } else {
                      _selectedDays.add(d);
                    }
                  });
                },
                borderRadius: BorderRadius.circular(20),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: _selectedDays.contains(d)
                        ? primary
                        : (isDark ? const Color(0xFF1E382E) : const Color(0xFFF3F6EC)),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _selectedDays.contains(d)
                          ? primary
                          : (isDark ? const Color(0xFF2E4E41) : const Color(0xFFD0D9CD)),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_selectedDays.contains(d)) ...[
                        const Icon(Icons.check_rounded, size: 14, color: Colors.white),
                        const SizedBox(width: 5),
                      ],
                      Text(
                        [
                          'Lunes',
                          'Martes',
                          'Miércoles',
                          'Jueves',
                          'Viernes',
                          'Sábado',
                          'Domingo'
                        ][d - 1],
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: _selectedDays.contains(d) ? FontWeight.w800 : FontWeight.w600,
                          color: _selectedDays.contains(d)
                              ? Colors.white
                              : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF334155)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  // --- PASO 4 ---
  Widget _buildStep4(Color text, Color subtext, Color border, bool isDark, Color primary) {
    final allBuyers = CouponsService.instance.getProviderClosedNegotiationBuyers();
    final buyerQuery = _buyerSearchController.text.trim().toLowerCase();
    final filteredBuyers = buyerQuery.isEmpty
        ? allBuyers
        : allBuyers.where((b) {
            final name = (b['name'] as String? ?? '').toLowerCase();
            final owner = (b['owner'] as String? ?? '').toLowerCase();
            final id = (b['id'] as String? ?? '').toLowerCase();
            final business = (b['business'] as String? ?? '').toLowerCase();
            return name.contains(buyerQuery) ||
                owner.contains(buyerQuery) ||
                id.contains(buyerQuery) ||
                business.contains(buyerQuery);
          }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Paso 4 — ¿Quién puede utilizar este cupón?',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: text,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Segmenta la audiencia para transformar tus cupones en una herramienta de fidelización.',
          style: GoogleFonts.plusJakartaSans(fontSize: 13, color: subtext),
        ),
        const SizedBox(height: 14),

        // Explicación de negociación estilo AllTasksScreen
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E382E) : const Color(0xFFE5F1EB),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? const Color(0xFF2E4E41) : const Color(0xFFA7E8C3),
              width: 1.2,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF162B23) : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.handshake_rounded, size: 20, color: primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.plusJakartaSans(fontSize: 12, color: text, height: 1.35),
                    children: [
                      TextSpan(
                        text: '¿Qué es una negociación? ',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          color: primary,
                        ),
                      ),
                      const TextSpan(
                        text: 'Consiste en haber cerrado y completado un trato o pedido comercial con su negocio.',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        Column(
          children: CouponAudience.values.map((aud) {
            final isSelected = _selectedAudience == aud;

            String audienceTitle;
            String audienceDescription;
            IconData iconData;
            Color iconBg;
            Color iconColor;

            switch (aud) {
              case CouponAudience.allBuyers:
                audienceTitle = 'Todos los compradores';
                audienceDescription = 'Cualquier usuario puede usarlo ingresando o copiando el código manualmente.';
                iconData = Icons.public_rounded;
                iconBg = isDark ? const Color(0xFF1E382E) : const Color(0xFFE5F1EB);
                iconColor = isDark ? const Color(0xFF67C83B) : primary;
                break;
              case CouponAudience.newBuyers:
                audienceTitle = 'Nuevos compradores';
                audienceDescription = 'Se envía automáticamente a clientes que apenas cerraron 1 negociación con usted.';
                iconData = Icons.person_add_alt_1_rounded;
                iconBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFDBEAFE);
                iconColor = isDark ? const Color(0xFF60A5FA) : const Color(0xFF1D4ED8);
                break;
              case CouponAudience.frequentBuyers:
                audienceTitle = 'Compradores frecuentes';
                audienceDescription = 'Se envía automáticamente a clientes con más de 2 negociaciones cerradas.';
                iconData = Icons.loyalty_rounded;
                iconBg = isDark ? const Color(0xFF332617) : const Color(0xFFFEF3C7);
                iconColor = isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706);
                break;
              case CouponAudience.inactiveBuyers:
                audienceTitle = 'Recuperación de clientes inactivos';
                audienceDescription = 'Se envía automáticamente a clientes que cerraron negociaciones en el pasado pero llevan días inactivos.';
                iconData = Icons.history_toggle_off_rounded;
                iconBg = isDark ? const Color(0xFF2E1A38) : const Color(0xFFF3E8FF);
                iconColor = isDark ? const Color(0xFFC084FC) : const Color(0xFF9333EA);
                break;
              case CouponAudience.selectedBuyers:
                audienceTitle = 'Compradores seleccionados';
                audienceDescription = 'Selecciona manualmente a qué compradores específicos con negociaciones cerradas asignar este cupón.';
                iconData = Icons.how_to_reg_rounded;
                iconBg = isDark ? const Color(0xFF132E2B) : const Color(0xFFCCFBF1);
                iconColor = isDark ? const Color(0xFF5EEAD4) : const Color(0xFF0F766E);
                break;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => setState(() => _selectedAudience = aud),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isDark ? const Color(0xFF1E382E) : const Color(0xFFF0FDF4))
                        : (isDark ? const Color(0xFF1E382E) : Colors.white),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isSelected ? primary : border.withValues(alpha: 0.7),
                      width: isSelected ? 1.8 : 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected
                            ? primary.withValues(alpha: 0.12)
                            : Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Badge ícono 44x44
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: iconBg,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(iconData, size: 22, color: iconColor),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              audienceTitle,
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w800,
                                fontSize: 13.5,
                                color: text,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              audienceDescription,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                color: subtext,
                                height: 1.25,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Radio indicador estilo tareas
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? primary : Colors.transparent,
                          border: Border.all(
                            color: isSelected ? primary : border,
                            width: 1.8,
                          ),
                        ),
                        child: isSelected
                            ? const Center(
                                child: Icon(Icons.circle, size: 8, color: Colors.white),
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        // Si es clientes inactivos: input de días (default 15)
        if (_selectedAudience == CouponAudience.inactiveBuyers) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E382E) : const Color(0xFFF3F6EC),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: isDark ? const Color(0xFF2E4E41) : const Color(0xFFD0D9CD)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Días de inactividad requeridos (umbral)',
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w800, color: text),
                ),
                const SizedBox(height: 4),
                Text(
                  'Clientes con negociaciones cerradas previas pero sin pedidos en este período:',
                  style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: subtext),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _inactiveDaysController,
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.plusJakartaSans(fontSize: 13, color: text),
                  decoration: InputDecoration(
                    suffixText: 'días de inactividad',
                    suffixStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: primary),
                    hintText: '15',
                    filled: true,
                    fillColor: isDark ? const Color(0xFF162B23) : Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: border, width: 1.2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: primary, width: 1.8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        // Si es compradores seleccionados: lista interactiva con buscador
        if (_selectedAudience == CouponAudience.selectedBuyers) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E382E) : const Color(0xFFF3F6EC),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: isDark ? const Color(0xFF2E4E41) : const Color(0xFFD0D9CD)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Compradores con Negociaciones',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: text,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF162B23) : const Color(0xFFE5F1EB),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? const Color(0xFF2E4E41) : const Color(0xFFA7E8C3),
                        ),
                      ),
                      child: Text(
                        '${_selectedBuyerIds.length} selec.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _buyerSearchController,
                  onChanged: (_) => setState(() {}),
                  style: GoogleFonts.plusJakartaSans(fontSize: 13, color: text),
                  decoration: InputDecoration(
                    hintText: 'Buscar comprador o negocio...',
                    hintStyle: GoogleFonts.plusJakartaSans(fontSize: 12, color: subtext.withValues(alpha: 0.6)),
                    prefixIcon: const Icon(Icons.search_rounded, size: 18),
                    suffixIcon: _buyerSearchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 16),
                            onPressed: () => setState(() => _buyerSearchController.clear()),
                          )
                        : null,
                    isDense: true,
                    filled: true,
                    fillColor: isDark ? const Color(0xFF162B23) : Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: primary, width: 1.8),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: () {
                        setState(() {
                          if (_selectedBuyerIds.length == filteredBuyers.length) {
                            _selectedBuyerIds.clear();
                          } else {
                            _selectedBuyerIds.addAll(filteredBuyers.map((b) => b['id'] as String));
                          }
                        });
                      },
                      child: Text(
                        _selectedBuyerIds.length == filteredBuyers.length ? 'Desmarcar todos' : 'Marcar todos',
                        style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w800, color: primary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  constraints: const BoxConstraints(maxHeight: 230),
                  child: filteredBuyers.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: Text(
                              'No se encontraron compradores',
                              style: GoogleFonts.plusJakartaSans(fontSize: 12, color: subtext),
                            ),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          itemCount: filteredBuyers.length,
                          separatorBuilder: (context, index) => Divider(
                            height: 1,
                            color: isDark ? const Color(0xFF2E4E41) : const Color(0xFFD0D9CD).withValues(alpha: 0.5),
                          ),
                          itemBuilder: (context, idx) {
                            final buyer = filteredBuyers[idx];
                            final id = (buyer['id'] ?? '').toString();
                            final buyerName = (buyer['name'] != null && (buyer['name'] as String).trim().isNotEmpty)
                                ? (buyer['name'] as String).trim()
                                : (buyer['owner'] ?? 'Comprador').toString().trim();
                            final isSelected = _selectedBuyerIds.contains(id);

                            return InkWell(
                              borderRadius: BorderRadius.circular(10),
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    _selectedBuyerIds.remove(id);
                                  } else {
                                    _selectedBuyerIds.add(id);
                                  }
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: Checkbox(
                                        value: isSelected,
                                        activeColor: primary,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                        onChanged: (val) {
                                          setState(() {
                                            if (val == true) {
                                              _selectedBuyerIds.add(id);
                                            } else {
                                              _selectedBuyerIds.remove(id);
                                            }
                                          });
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: isDark ? const Color(0xFF162B23) : const Color(0xFFE5F1EB),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Center(
                                        child: Text(
                                          buyerName.isNotEmpty ? buyerName[0].toUpperCase() : 'C',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 12,
                                            color: primary,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            buyerName,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w800,
                                              color: text,
                                            ),
                                          ),
                                          const SizedBox(height: 1),
                                          Text(
                                            id,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.w700,
                                              color: subtext,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                                          decoration: BoxDecoration(
                                            color: isDark ? const Color(0xFF162B23) : const Color(0xFFE5F1EB),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                              color: isDark ? const Color(0xFF2E4E41) : const Color(0xFFA7E8C3),
                                            ),
                                          ),
                                          child: Text(
                                            '${buyer['closedNegotiations']} tratos',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.w800,
                                              color: primary,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          'Hace ${buyer['lastNegotiationDaysAgo']}d',
                                          style: GoogleFonts.plusJakartaSans(fontSize: 10, color: subtext),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // --- BOTONES INFERIORES ---
  Widget _buildBottomControls(Color primary, Color subtext, Color border, bool isDark) {
    final isLastStep = _currentStep == 4;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF162B23) : const Color(0xFFF9FAF5),
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFF2E4E41) : const Color(0xFFD0D9CD).withValues(alpha: 0.8),
          ),
        ),
      ),
      child: Row(
        children: [
          if (_currentStep > 1) ...[
            OutlinedButton.icon(
              icon: const Icon(Icons.arrow_back_rounded, size: 16),
              label: Text(
                'Atrás',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: primary,
                backgroundColor: isDark ? const Color(0xFF1E382E) : const Color(0xFFE5F1EB),
                side: BorderSide(color: isDark ? const Color(0xFF2E4E41) : const Color(0xFFA7E8C3), width: 1.2),
                minimumSize: const Size(0, 48),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () => setState(() => _currentStep--),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: ElevatedButton.icon(
              icon: Icon(isLastStep ? Icons.check_circle_rounded : Icons.arrow_forward_rounded, size: 16),
              label: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  isLastStep
                      ? (widget.initialCoupon != null ? 'Guardar Cambios' : 'Guardar Cupón (Pausado)')
                      : 'Siguiente',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    fontSize: 13.5,
                  ),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shadowColor: primary.withValues(alpha: 0.4),
                minimumSize: const Size(0, 48),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () {
                if (_currentStep == 1 && !_isTitleValid) {
                  setState(() {
                    _showTitleError = true;
                  });
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _titleErrorMessage,
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: const Color(0xFFDC2626),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      duration: const Duration(seconds: 3),
                    ),
                  );
                  return;
                }
                if (isLastStep) {
                  _saveAndSubmit();
                } else {
                  setState(() => _currentStep++);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void _saveAndSubmit() {
    if (!_isTitleValid) {
      setState(() {
        _currentStep = 1;
        _showTitleError = true;
      });
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _titleErrorMessage,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    final title = _titleController.text.trim();
    final code = _codeController.text.trim().isNotEmpty
        ? _codeController.text.trim().toUpperCase()
        : CouponsService.instance.generateCouponCode();

    final benefitValue = double.tryParse(_benefitValueController.text) ?? 10.0;
    final minPurchase = double.tryParse(_minPurchaseController.text) ?? 1500.0;
    final totalUsage = int.tryParse(_totalUsageLimitController.text) ?? 100;
    final usagePerBuyer = int.tryParse(_usagePerBuyerController.text) ?? 1;
    final inactiveDays = int.tryParse(_inactiveDaysController.text) ?? 15;

    final benefit = CouponBenefit(
      type: _selectedBenefitType,
      value: benefitValue,
      customGiftName: _giftNameController.text.trim(),
      specialPriceLabel: _specialPriceLabelController.text.trim(),
    );

    final rule = CouponRule(
      scope: _selectedScope,
      targetProducts: _selectedProductIds.toList(),
      minPurchase: minPurchase,
      totalUsageLimit: totalUsage,
      usagePerBuyer: usagePerBuyer,
      startDate: _startDate,
      endDate: _endDate,
      applicableDays: _selectedDays.toList(),
    );

    final target = CouponTarget(
      audience: _selectedAudience,
      inactiveDaysThreshold: inactiveDays,
      selectedBuyerIds: _selectedBuyerIds.toList(),
    );

    if (widget.initialCoupon != null) {
      final updated = widget.initialCoupon!.copyWith(
        title: title,
        code: code,
        category: _selectedCategory,
        benefit: benefit,
        rule: rule,
        target: target,
      );
      CouponsService.instance.updateCoupon(updated);
    } else {
      final newCoupon = Coupon(
        id: 'CPN-${DateTime.now().millisecondsSinceEpoch}',
        providerId: 'PROV-00000001',
        code: code,
        title: title,
        category: _selectedCategory,
        benefit: benefit,
        rule: rule,
        target: target,
        status: CouponStatus.paused,
        hasBeenActivated: false,
        analytics: CouponAnalytics(
          publishedCount: totalUsage * 4,
        ),
        createdAt: DateTime.now(),
      );
      CouponsService.instance.createCoupon(newCoupon);
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.initialCoupon != null
            ? '¡Cupón "$code" actualizado con éxito!'
            : '¡Cupón "$code" creado en estado Pausado! Podrás activarlo cuando desees.'),
        backgroundColor: const Color(0xFF016142),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
