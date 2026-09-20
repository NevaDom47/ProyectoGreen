import 'package:flutter/material.dart';
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
    final bg = isDark ? const Color(0xFF0d1a15) : Colors.white;
    final text = isDark ? Colors.white : const Color(0xFF0f172a);
    final subtext = isDark ? const Color(0xFF94a3b8) : const Color(0xFF64748b);
    final border = isDark ? const Color(0xFF22382e) : const Color(0xFFE2E8F0);

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
                    color: subtext.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),

              // Top Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.initialCoupon != null ? 'Editar Cupón' : 'Crear Nuevo Cupón',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: text,
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

              // Stepper Indicator (1 a 4)
              _buildStepIndicator(primary, isDark),

              const Divider(height: 1),

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
              _buildBottomControls(primary, subtext),
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
          _stepLine(1, primary),
          _stepNode(2, 'Beneficio', primary, isDark),
          _stepLine(2, primary),
          _stepNode(3, 'Reglas', primary, isDark),
          _stepLine(3, primary),
          _stepNode(4, 'Segmento', primary, isDark),
        ],
      ),
    );
  }

  Widget _stepNode(int step, String label, Color primary, bool isDark) {
    final isDone = _currentStep > step;
    final isCurrent = _currentStep == step;

    Color circleColor;
    Color iconColor;

    if (isDone || isCurrent) {
      circleColor = primary;
      iconColor = Colors.white;
    } else {
      circleColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
      iconColor = isDark ? Colors.grey[400]! : const Color(0xFF64748B);
    }

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _currentStep = step),
        child: Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: circleColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: isDone
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : Text(
                        '$step',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: iconColor,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 10,
                fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
                color: isCurrent ? primary : Colors.grey,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepLine(int afterStep, Color primary) {
    final isDone = _currentStep > afterStep;
    return Container(
      width: 24,
      height: 2,
      margin: const EdgeInsets.only(bottom: 14),
      color: isDone ? primary : const Color(0xFFCBD5E1),
    );
  }

  // --- PASO 1 ---
  Widget _buildStep1(Color text, Color subtext, Color border, bool isDark, Color primary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Paso 1 — Información básica',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: text,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Define el nombre comercial y el código que usarán tus clientes.',
          style: TextStyle(fontSize: 13, color: subtext),
        ),
        const SizedBox(height: 20),

        // Nombre
        Text('Nombre de la promoción',
            style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12, fontWeight: FontWeight.bold, color: text)),
        const SizedBox(height: 6),
        TextField(
          controller: _titleController,
          decoration: InputDecoration(
            hintText: 'Ej. Feria de Septiembre, Cosecha Fresca',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),

        const SizedBox(height: 18),

        // Código del cupón
        Text('Código del cupón',
            style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12, fontWeight: FontWeight.bold, color: text)),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _codeController,
                textCapitalization: TextCapitalization.characters,
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                ),
                decoration: InputDecoration(
                  hintText: 'Ej. SEPTIEMBRE10',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Generar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primary.withValues(alpha: 0.12),
                foregroundColor: primary,
                minimumSize: const Size(0, 48),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _generateRandomCode,
            ),
          ],
        ),

        const SizedBox(height: 18),

        // Categoría
        Text('Categoría de productos',
            style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12, fontWeight: FontWeight.bold, color: text)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCategory,
              isExpanded: true,
              items: _categories.map((cat) {
                return DropdownMenuItem(value: cat, child: Text(cat, style: const TextStyle(fontSize: 13)));
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
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: text,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Selecciona la modalidad de beneficio o descuento que aplicará el cupón.',
          style: TextStyle(fontSize: 13, color: subtext),
        ),
        const SizedBox(height: 20),

        // Selector de modalidades
        Column(
          children: CouponBenefitType.values.map((type) {
            final isSelected = _selectedBenefitType == type;
            return InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => setState(() => _selectedBenefitType = type),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isSelected ? primary : border, width: isSelected ? 1.8 : 1.0),
                  color: isSelected ? primary.withValues(alpha: 0.06) : Colors.transparent,
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                      color: isSelected ? primary : border,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        type.label,
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                          color: text,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 16),

        // Campo numérico si es porcentaje o monto
        if (_selectedBenefitType == CouponBenefitType.percentage ||
            _selectedBenefitType == CouponBenefitType.fixedAmount) ...[
          Text(
            _selectedBenefitType == CouponBenefitType.percentage
                ? 'Porcentaje de descuento (%)'
                : 'Monto fijo a descontar (RD\$)',
            style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12, fontWeight: FontWeight.bold, color: text),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _benefitValueController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              suffixText: _selectedBenefitType == CouponBenefitType.percentage ? '%' : 'RD\$',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],

        if (_selectedBenefitType == CouponBenefitType.giftProduct) ...[
          Text('Nombre del producto de regalo',
              style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12, fontWeight: FontWeight.bold, color: text)),
          const SizedBox(height: 6),
          TextField(
            controller: _giftNameController,
            decoration: InputDecoration(
              hintText: 'Ej. 1 Canasta de fresas de cortesía',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],

        if (_selectedBenefitType == CouponBenefitType.specialPrice) ...[
          Text('Etiqueta o precio especial',
              style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12, fontWeight: FontWeight.bold, color: text)),
          const SizedBox(height: 6),
          TextField(
            controller: _specialPriceLabelController,
            decoration: InputDecoration(
              hintText: 'Ej. RD\$ 35 / KG en Tomate',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: text,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Establece límites de uso, compra mínima, productos aplicables y vigencia.',
          style: TextStyle(fontSize: 13, color: subtext),
        ),
        const SizedBox(height: 20),

        // Ámbito de aplicación (Todos o Específicos)
        Text(
          '¿Dónde aplica el cupón?',
          style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12, fontWeight: FontWeight.bold, color: text),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedScope = CouponScope.allProducts),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _selectedScope == CouponScope.allProducts ? primary : border,
                      width: _selectedScope == CouponScope.allProducts ? 1.8 : 1.0,
                    ),
                    color: _selectedScope == CouponScope.allProducts ? primary.withValues(alpha: 0.1) : Colors.transparent,
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.select_all,
                        size: 20,
                        color: _selectedScope == CouponScope.allProducts ? primary : subtext,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Todos los productos',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 12,
                          fontWeight: _selectedScope == CouponScope.allProducts ? FontWeight.w800 : FontWeight.w500,
                          color: _selectedScope == CouponScope.allProducts ? primary : text,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Sin distinción de producto',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 10, color: subtext),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedScope = CouponScope.specificProducts),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _selectedScope == CouponScope.specificProducts ? primary : border,
                      width: _selectedScope == CouponScope.specificProducts ? 1.8 : 1.0,
                    ),
                    color: _selectedScope == CouponScope.specificProducts ? primary.withValues(alpha: 0.1) : Colors.transparent,
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.checklist_outlined,
                        size: 20,
                        color: _selectedScope == CouponScope.specificProducts ? primary : subtext,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Productos específicos',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 12,
                          fontWeight: _selectedScope == CouponScope.specificProducts ? FontWeight.w800 : FontWeight.w500,
                          color: _selectedScope == CouponScope.specificProducts ? primary : text,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Detalle o al por mayor',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 10, color: subtext),
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
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF162520) : const Color(0xFFF6FAF7),
              borderRadius: BorderRadius.circular(14),
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
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: text,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${_selectedProductIds.length} selec.',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _productSearchController,
                  onChanged: (_) => setState(() {}),
                  style: TextStyle(fontSize: 13, color: text),
                  decoration: InputDecoration(
                    hintText: 'Buscar por nombre o SKU...',
                    hintStyle: TextStyle(fontSize: 12, color: subtext),
                    prefixIcon: const Icon(Icons.search, size: 18),
                    suffixIcon: _productSearchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 16),
                            onPressed: () => setState(() => _productSearchController.clear()),
                          )
                        : null,
                    isDense: true,
                    filled: true,
                    fillColor: isDark ? const Color(0xFF0F172A) : Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: border),
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
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: primary),
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
                              style: TextStyle(fontSize: 12, color: subtext),
                            ),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          itemCount: filteredProducts.length,
                          separatorBuilder: (context, index) => const Divider(height: 1),
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
                                            style: TextStyle(
                                              fontFamily: 'Plus Jakarta Sans',
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
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
                                                  style: TextStyle(
                                                    fontFamily: 'monospace',
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
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
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
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
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
        Text('Compra mínima requerida (RD\$)',
            style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12, fontWeight: FontWeight.bold, color: text)),
        const SizedBox(height: 6),
        TextField(
          controller: _minPurchaseController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            prefixText: 'RD\$ ',
            hintText: '1500',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                  Text('Usos máximos totales',
                      style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans', fontSize: 12, fontWeight: FontWeight.bold, color: text)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _totalUsageLimitController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: '100',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                  Text('Usos por comprador',
                      style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans', fontSize: 12, fontWeight: FontWeight.bold, color: text)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _usagePerBuyerController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: '1',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        // Vigencia
        Text('Vigencia del cupón',
            style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12, fontWeight: FontWeight.bold, color: text)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.calendar_month, size: 16),
                label: Text(
                  '${_startDate.day}/${_startDate.month}/${_startDate.year}',
                  style: const TextStyle(fontSize: 12),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: text,
                  side: BorderSide(color: border),
                  padding: const EdgeInsets.symmetric(vertical: 12),
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
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text('hasta'),
            ),
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.calendar_month, size: 16),
                label: Text(
                  '${_endDate.day}/${_endDate.month}/${_endDate.year}',
                  style: const TextStyle(fontSize: 12),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: text,
                  side: BorderSide(color: border),
                  padding: const EdgeInsets.symmetric(vertical: 12),
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

        // Días de la semana con nombres completos
        Text('Días válidos de la semana (opcional)',
            style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12, fontWeight: FontWeight.bold, color: text)),
        const SizedBox(height: 4),
        Text('Si no seleccionas ninguno, el cupón será válido todos los días.',
            style: TextStyle(fontSize: 11, color: subtext)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (int d = 1; d <= 7; d++)
              FilterChip(
                label: Text([
                  'Lunes',
                  'Martes',
                  'Miércoles',
                  'Jueves',
                  'Viernes',
                  'Sábado',
                  'Domingo'
                ][d - 1]),
                selected: _selectedDays.contains(d),
                selectedColor: primary.withValues(alpha: 0.15),
                checkmarkColor: primary,
                backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                labelStyle: TextStyle(
                  color: _selectedDays.contains(d) ? primary : text,
                  fontWeight: _selectedDays.contains(d) ? FontWeight.bold : FontWeight.w500,
                  fontSize: 12,
                ),
                side: BorderSide(
                  color: _selectedDays.contains(d) ? primary : border,
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedDays.add(d);
                    } else {
                      _selectedDays.remove(d);
                    }
                  });
                },
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
            final name = (b['name'] as String).toLowerCase();
            final owner = (b['owner'] as String).toLowerCase();
            return name.contains(buyerQuery) || owner.contains(buyerQuery);
          }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Paso 4 — ¿Quién puede utilizar este cupón?',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: text,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Segmenta la audiencia para transformar tus cupones en una herramienta de fidelización.',
          style: TextStyle(fontSize: 13, color: subtext),
        ),
        const SizedBox(height: 12),

        // Explicación de negociación
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: primary.withValues(alpha: 0.2)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.handshake_outlined, size: 18, color: primary),
              const SizedBox(width: 8),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(fontSize: 11, color: text, height: 1.3),
                    children: [
                      TextSpan(
                        text: '¿Qué es una negociación? ',
                        style: TextStyle(fontWeight: FontWeight.bold, color: primary),
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
            String badgeText;
            Color badgeColor;
            IconData iconData;

            switch (aud) {
              case CouponAudience.allBuyers:
                audienceTitle = 'Todos los compradores';
                audienceDescription = 'Cualquier usuario puede usarlo ingresando o copiando el código manualmente.';
                badgeText = 'Manual / Público';
                badgeColor = const Color(0xFF64748B);
                iconData = Icons.public;
                break;
              case CouponAudience.newBuyers:
                audienceTitle = 'Nuevos compradores';
                audienceDescription = 'Se envía automáticamente a clientes que apenas cerraron 1 negociación con usted.';
                badgeText = 'Automático';
                badgeColor = const Color(0xFF0284C7);
                iconData = Icons.person_add_outlined;
                break;
              case CouponAudience.frequentBuyers:
                audienceTitle = 'Compradores frecuentes';
                audienceDescription = 'Se envía automáticamente a clientes con más de 2 negociaciones cerradas.';
                badgeText = 'Automático';
                badgeColor = const Color(0xFF059669);
                iconData = Icons.loyalty_outlined;
                break;
              case CouponAudience.inactiveBuyers:
                audienceTitle = 'Recuperación de clientes inactivos';
                audienceDescription = 'Se envía automáticamente a clientes que cerraron negociaciones en el pasado pero llevan días inactivos.';
                badgeText = 'Automático';
                badgeColor = const Color(0xFFD97706);
                iconData = Icons.history_toggle_off;
                break;
              case CouponAudience.selectedBuyers:
                audienceTitle = 'Compradores seleccionados';
                audienceDescription = 'Selecciona manualmente a qué compradores específicos con negociaciones cerradas asignar este cupón.';
                badgeText = 'Selección manual';
                badgeColor = const Color(0xFF7C3AED);
                iconData = Icons.how_to_reg_outlined;
                break;
            }

            return InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => setState(() => _selectedAudience = aud),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isSelected ? primary : border, width: isSelected ? 1.8 : 1.0),
                  color: isSelected ? primary.withValues(alpha: 0.06) : Colors.transparent,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Icon(
                        isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                        color: isSelected ? primary : border,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(iconData, size: 16, color: isSelected ? primary : subtext),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  audienceTitle,
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 13,
                                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                    color: text,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: badgeColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  badgeText,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: badgeColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            audienceDescription,
                            style: TextStyle(fontSize: 11.5, color: subtext, height: 1.25),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),

        // Si es clientes inactivos: input de días (default 15)
        if (_selectedAudience == CouponAudience.inactiveBuyers) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF162520) : const Color(0xFFF6FAF7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Días de inactividad requeridos (umbral)',
                  style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12, fontWeight: FontWeight.bold, color: text),
                ),
                const SizedBox(height: 4),
                Text(
                  'Clientes con negociaciones cerradas previas pero sin pedidos en este período:',
                  style: TextStyle(fontSize: 11, color: subtext),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _inactiveDaysController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(fontSize: 13, color: text),
                  decoration: InputDecoration(
                    suffixText: 'días de inactividad',
                    hintText: '15',
                    isDense: true,
                    filled: true,
                    fillColor: isDark ? const Color(0xFF0F172A) : Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
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
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF162520) : const Color(0xFFF6FAF7),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Compradores con Negociaciones',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: text,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${_selectedBuyerIds.length} selec.',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _buyerSearchController,
                  onChanged: (_) => setState(() {}),
                  style: TextStyle(fontSize: 13, color: text),
                  decoration: InputDecoration(
                    hintText: 'Buscar comprador o negocio...',
                    hintStyle: TextStyle(fontSize: 12, color: subtext),
                    prefixIcon: const Icon(Icons.search, size: 18),
                    suffixIcon: _buyerSearchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 16),
                            onPressed: () => setState(() => _buyerSearchController.clear()),
                          )
                        : null,
                    isDense: true,
                    filled: true,
                    fillColor: isDark ? const Color(0xFF0F172A) : Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: border),
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
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: primary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  constraints: const BoxConstraints(maxHeight: 220),
                  child: filteredBuyers.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                            child: Text(
                              'No se encontraron compradores',
                              style: TextStyle(fontSize: 12, color: subtext),
                            ),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          itemCount: filteredBuyers.length,
                          separatorBuilder: (context, index) => const Divider(height: 1),
                          itemBuilder: (context, idx) {
                            final buyer = filteredBuyers[idx];
                            final id = buyer['id'] as String;
                            final isSelected = _selectedBuyerIds.contains(id);

                            return InkWell(
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
                                              _selectedBuyerIds.add(id);
                                            } else {
                                              _selectedBuyerIds.remove(id);
                                            }
                                          });
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    CircleAvatar(
                                      radius: 14,
                                      backgroundColor: primary.withValues(alpha: 0.15),
                                      child: Text(
                                        (buyer['name'] as String)[0],
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: primary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            buyer['name'] as String,
                                            style: TextStyle(
                                              fontFamily: 'Plus Jakarta Sans',
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: text,
                                            ),
                                          ),
                                          Text(
                                            buyer['owner'] as String,
                                            style: TextStyle(fontSize: 10, color: subtext),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF016142).withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            '${buyer['closedNegotiations']} tratos',
                                            style: const TextStyle(
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF016142),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Hace ${buyer['lastNegotiationDaysAgo']}d',
                                          style: TextStyle(fontSize: 9.5, color: subtext),
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
  Widget _buildBottomControls(Color primary, Color subtext) {
    final isLastStep = _currentStep == 4;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF162520)
            : const Color(0xFFF6FAF7),
        border: Border(
          top: BorderSide(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF22382e)
                : const Color(0xFFE2E8F0),
          ),
        ),
      ),
      child: Row(
        children: [
          if (_currentStep > 1) ...[
            OutlinedButton.icon(
              icon: const Icon(Icons.arrow_back, size: 16),
              label: const Text('Atrás'),
              style: OutlinedButton.styleFrom(
                foregroundColor: primary,
                side: BorderSide(color: primary),
                minimumSize: const Size(0, 48),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => setState(() => _currentStep--),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: ElevatedButton.icon(
              icon: Icon(isLastStep ? Icons.check_circle : Icons.arrow_forward, size: 16),
              label: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(isLastStep
                    ? (widget.initialCoupon != null ? 'Guardar Cambios' : 'Guardar Cupón (Pausado)')
                    : 'Siguiente'),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 48),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
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
    final title = _titleController.text.trim().isNotEmpty
        ? _titleController.text.trim()
        : 'Promoción Especial';
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
