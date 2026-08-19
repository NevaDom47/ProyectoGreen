import 'package:flutter/material.dart';
import '../data/global_state.dart';

class FlashOfferEditDialog extends StatefulWidget {
  final Map<String, dynamic> product;
  final Map<String, dynamic>? existingOffer;

  const FlashOfferEditDialog({
    super.key,
    required this.product,
    this.existingOffer,
  });

  @override
  State<FlashOfferEditDialog> createState() => _FlashOfferEditDialogState();
}

class _FlashOfferEditDialogState extends State<FlashOfferEditDialog> {
  // Step tracker: 0 = Form, 1 = Loading, 2 = Success
  int _currentStep = 0;

  bool _isPercentage = true;
  double _discountValue = 25.0; // Default 25%
  double _durationHours = 12.0; // Default 12 hours
  final int _stockLimit = 50; // 50 KG max in offer

  // Sales mode & Unit selection
  String _salesMode = 'retail'; // 'retail' (Detalle) or 'wholesale' (Por Mayor)
  String _selectedUnit = 'KG'; // 'KG', 'LB', 'CAJA', 'SACO', or 'TODAS'
  late List<String> _availableUnits;

  late double _originalPrice;
  late TextEditingController _discountController;

  @override
  void initState() {
    super.initState();
    _parseInitialData();
  }

  double _calculateBasePrice(String mode, String unit) {
    final double baseRetail =
        (widget.product['priceRetailKg'] as num?)?.toDouble() ?? 28.50;
    final double baseWholesale =
        (widget.product['priceWholesaleKg'] as num?)?.toDouble() ?? 22.00;
    final double basePriceKg =
        (mode == 'wholesale') ? baseWholesale : baseRetail;

    final u = unit.toUpperCase().replaceAll('POR ', '').trim();
    if (u == 'LB' || u == 'LIBRA') {
      return basePriceKg / 2.20462;
    } else if (u == 'CAJA') {
      return basePriceKg * 15.0;
    } else if (u == 'SACO') {
      return basePriceKg * 20.0;
    } else if (u == 'BULTO') {
      return basePriceKg * 25.0;
    } else if (u == 'ARROBA' || u == '@') {
      return basePriceKg * 11.339;
    } else if (u == 'TON' || u == 'TONELADA') {
      return basePriceKg * 1000.0;
    } else if (u == 'MANOJO') {
      return basePriceKg * 0.5;
    } else {
      return basePriceKg; // KG or base
    }
  }

  void _parseInitialData() {
    // 1. Initialize sales mode
    if (widget.existingOffer != null &&
        widget.existingOffer!['salesMode'] != null) {
      _salesMode =
          widget.existingOffer!['salesMode'] == 'wholesale'
              ? 'wholesale'
              : 'retail';
    } else if (widget.product['salesMode'] != null) {
      _salesMode =
          widget.product['salesMode'] == 'wholesale' ? 'wholesale' : 'retail';
    } else {
      _salesMode = 'retail';
    }

    // 2. Initialize available units list
    final List<dynamic>? rawUnits =
        widget.product['availableUnits'] as List<dynamic>?;
    if (rawUnits != null && rawUnits.isNotEmpty) {
      _availableUnits =
          rawUnits.map((e) => e.toString().toUpperCase()).toList();
    } else {
      _availableUnits = ['KG', 'LB', 'CAJA'];
    }

    // 3. Initialize selected unit
    final initialUnitRaw =
        (widget.product['selectedUnit'] ??
                widget.product['unit'] ??
                widget.existingOffer?['unit'] ??
                'KG')
            .toString()
            .toUpperCase()
            .replaceAll('POR ', '')
            .trim();

    if (initialUnitRaw.contains('TODAS')) {
      _selectedUnit = 'TODAS';
    } else if (_availableUnits.contains(initialUnitRaw)) {
      _selectedUnit = initialUnitRaw;
    } else {
      _selectedUnit = _availableUnits.first;
    }

    _updateOriginalPrice();

    if (widget.existingOffer != null) {
      final discNum = widget.existingOffer!['discountNumber'] as num? ?? 25;
      _discountValue = discNum.toDouble();

      final secs = widget.existingOffer!['secondsRemaining'] as int? ?? 43200;
      _durationHours = (secs / 3600).clamp(1.0, 24.0);
    }

    _discountController = TextEditingController(
      text:
          _isPercentage
              ? _discountValue.toInt().toString()
              : _discountValue.toStringAsFixed(2),
    );
  }

  void _updateOriginalPrice() {
    if (_selectedUnit == 'TODAS') {
      _isPercentage = true; // Rule 2: Cannot use fixed amount for all units!
      _originalPrice = _calculateBasePrice(_salesMode, 'KG');
    } else {
      _originalPrice = _calculateBasePrice(_salesMode, _selectedUnit);
    }
  }

  void _onSalesModeChanged(String newMode) {
    setState(() {
      _salesMode = newMode;
      _updateOriginalPrice();
      if (!_isPercentage && _discountValue >= _originalPrice) {
        _discountValue = (_originalPrice * 0.25);
        _discountController.text = _discountValue.toStringAsFixed(2);
      }
    });
  }

  void _onUnitChanged(String newUnit) {
    setState(() {
      _selectedUnit = newUnit;
      if (_selectedUnit == 'TODAS') {
        _isPercentage = true;
        _discountController.text = _discountValue.toInt().toString();
      }
      _updateOriginalPrice();
      if (!_isPercentage && _discountValue >= _originalPrice) {
        _discountValue = (_originalPrice * 0.25);
        _discountController.text = _discountValue.toStringAsFixed(2);
      }
    });
  }

  @override
  void dispose() {
    _discountController.dispose();
    super.dispose();
  }

  double get _calculatedOfferPrice {
    if (_isPercentage) {
      final percentage = _discountValue.clamp(0.0, 99.0) / 100.0;
      return _originalPrice * (1.0 - percentage);
    } else {
      return (_originalPrice - _discountValue).clamp(0.0, _originalPrice);
    }
  }

  double get _calculatedDiscountPercentage {
    if (_isPercentage) {
      return _discountValue;
    } else {
      if (_originalPrice <= 0) return 0;
      return ((_originalPrice - _calculatedOfferPrice) / _originalPrice) * 100;
    }
  }

  String get _formattedEndTime {
    final endTime = DateTime.now().add(
      Duration(minutes: (_durationHours * 60).round()),
    );
    final hour12 = endTime.hour % 12 == 0 ? 12 : endTime.hour % 12;
    final minuteStr = endTime.minute.toString().padLeft(2, '0');
    final period = endTime.hour >= 12 ? 'PM' : 'AM';
    return '${hour12.toString().padLeft(2, '0')}:$minuteStr $period';
  }

  String get _formattedEndDay {
    final now = DateTime.now();
    final endTime = now.add(
      Duration(minutes: (_durationHours * 60).round()),
    );
    return endTime.day != now.day ? 'mañana' : 'hoy';
  }

  void _onPublishOffer() async {
    setState(() {
      _currentStep = 1; // Show Skeleton Loading phase
    });

    // Simulate backend processing & database sync
    await Future.delayed(const Duration(milliseconds: 1600));

    if (!mounted) return;

    // Build offer object
    final finalDiscountPct = _calculatedDiscountPercentage.round();
    final offerPriceStr = '\$${_calculatedOfferPrice.toStringAsFixed(2)}';
    final origPriceStr = '\$${_originalPrice.toStringAsFixed(2)}';
    final secondsRemaining = (_durationHours * 3600).toInt();

    final productName =
        widget.product['name'] ?? widget.product['title'] ?? 'Producto';
    final category = widget.product['category'] ?? 'General';
    final image =
        widget.product['img'] ??
        widget.product['image'] ??
        widget.product['iconUrl'] ??
        'assets/images/PapaGemini.png';
    final supplier = widget.product['supplier'] ?? 'Mi Proveedora';
    final location = widget.product['location'] ?? 'Central de Abasto';

    final now = DateTime.now();
    final hour12 = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final period = now.hour >= 12 ? 'PM' : 'AM';
    final startTimeFormatted =
        'hoy, ${hour12.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} $period';
    final durationFormatted = '${_durationHours.toInt()} Horas';

    final String unitFormatted;
    if (_selectedUnit == 'TODAS') {
      unitFormatted =
          'Todas las unidades (${_salesMode == 'wholesale' ? 'Por Mayor' : 'Detalle'})';
    } else {
      unitFormatted = 'por $_selectedUnit';
    }

    final updatedOffer = {
      'name': productName,
      'category': category,
      'discount': '-$finalDiscountPct%',
      'discountNumber': finalDiscountPct,
      'price': offerPriceStr,
      'oldPrice': origPriceStr,
      'wholesalePrice':
          '\$${(_calculatedOfferPrice * 0.85).toStringAsFixed(2)}',
      'wholesaleOldPrice':
          '\$${(_originalPrice * 0.85).toStringAsFixed(2)}',
      'wholesaleMin': 'MIN. 15 KG',
      'rating': widget.product['rating'] ?? '4.9',
      'badge': widget.product['badge'] ?? 'PRIMERA CALIDAD',
      'unit': unitFormatted,
      'selectedUnit': _selectedUnit,
      'availableUnits': _availableUnits,
      'supplier': supplier,
      'location': location,
      'tags': widget.product['tags'] ?? [category, 'Oferta'],
      'salesMode': _salesMode,
      'secondsRemaining': secondsRemaining,
      'startTime': startTimeFormatted,
      'duration': durationFormatted,
      'stockLimit': _stockLimit,
      'img': image,
      'status': 'active',
    };

    // Update reactive global offers state
    final currentList = List<Map<String, dynamic>>.from(
      globalFlashOffers.value,
    );

    if (widget.existingOffer != null) {
      final existingIdx = currentList.indexOf(widget.existingOffer!);
      if (existingIdx >= 0) {
        currentList[existingIdx] = updatedOffer;
      } else {
        currentList.insert(0, updatedOffer);
      }
    } else {
      // Always insert new offer for new unit/mode without replacing existing active offers
      currentList.insert(0, updatedOffer);
    }
    globalFlashOffers.value = currentList;

    setState(() {
      _currentStep = 2; // Show Success Modal phase
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    const primaryColor = Color(0xFF004532);
    final surfaceBg =
        isDark ? const Color(0xFF121C28) : const Color(0xFFF8F9FF);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor =
        isDark ? const Color(0xFF334155) : const Color(0xFFBEC9C2);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        decoration: BoxDecoration(
          color: surfaceBg,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _buildCurrentStepView(
              context,
              theme,
              isDark,
              primaryColor,
              cardBg,
              borderColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStepView(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    Color primaryColor,
    Color cardBg,
    Color borderColor,
  ) {
    if (_currentStep == 1) {
      return _buildLoadingStepView(
        context,
        isDark,
        primaryColor,
        cardBg,
        borderColor,
      );
    } else if (_currentStep == 2) {
      return _buildSuccessStepView(context, isDark, primaryColor, cardBg);
    } else {
      return _buildFormStepView(
        context,
        theme,
        isDark,
        primaryColor,
        cardBg,
        borderColor,
      );
    }
  }

  // ---------------------------------------------------------
  // FASE 1: Formulario de Configuración (code-edit.html design)
  // ---------------------------------------------------------
  Widget _buildFormStepView(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    Color primaryColor,
    Color cardBg,
    Color borderColor,
  ) {
    final productName =
        widget.product['name'] ??
        widget.product['title'] ??
        'Tomate Saladette';
    final productImg =
        widget.product['img'] ??
        widget.product['image'] ??
        'assets/images/PapaGemini.png';
    final category = widget.product['category'] ?? 'Hortalizas';

    final bool hasDuplicateOffer = widget.existingOffer == null &&
        hasActiveOfferForProductUnit(
          productName: productName,
          salesMode: _salesMode,
          unit: _selectedUnit,
        );

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: cardBg,
              border: Border(
                bottom: BorderSide(
                  color: borderColor.withValues(alpha: 0.5),
                ),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.arrow_back,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    widget.existingOffer != null
                        ? 'Editar Oferta Relámpago'
                        : 'Gestionar Oferta',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ),
                Icon(Icons.help_outline, color: Colors.grey.shade500),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Selection Summary Card
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: borderColor.withValues(alpha: 0.6),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey.shade100,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child:
                              productImg.startsWith('http')
                                  ? Image.network(
                                    productImg,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (ctx, err, stack) => const Icon(
                                          Icons.shopping_bag,
                                          color: Colors.grey,
                                        ),
                                  )
                                  : Image.asset(
                                    productImg,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (ctx, err, stack) => const Icon(
                                          Icons.shopping_bag,
                                          color: Colors.grey,
                                        ),
                                  ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PRODUCTO SELECCIONADO',
                              style: TextStyle(
                                fontFamily: 'JetBrains Mono',
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              productName,
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            Text(
                              'Categoría: $category',
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                    isDark
                                        ? Colors.grey.shade400
                                        : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // NUEVA SECCIÓN: Alcance y Modalidad de la Oferta
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: borderColor.withValues(alpha: 0.6),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.tune, size: 18, color: primaryColor),
                          const SizedBox(width: 8),
                          Text(
                            'Alcance de la Oferta',
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Define la modalidad de venta y las unidades donde aplicará la oferta',
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              isDark
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // 1. Modalidad de Venta (Detalle vs Por Mayor)
                      Text(
                        'Modalidad de Venta',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color:
                              isDark
                                  ? Colors.grey.shade300
                                  : Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _onSalesModeChanged('retail'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 8,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      _salesMode == 'retail'
                                          ? primaryColor.withValues(alpha: 0.1)
                                          : (isDark
                                              ? const Color(0xFF0F172A)
                                              : const Color(0xFFF1F5F9)),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color:
                                        _salesMode == 'retail'
                                            ? primaryColor
                                            : borderColor.withValues(
                                              alpha: 0.5,
                                            ),
                                    width: _salesMode == 'retail' ? 1.5 : 1.0,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.shopping_bag_outlined,
                                      size: 16,
                                      color:
                                          _salesMode == 'retail'
                                              ? primaryColor
                                              : Colors.grey,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Al Detalle',
                                      style: TextStyle(
                                        fontFamily: 'Manrope',
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            _salesMode == 'retail'
                                                ? primaryColor
                                                : (isDark
                                                    ? Colors.grey.shade400
                                                    : Colors.grey.shade700),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _onSalesModeChanged('wholesale'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 8,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      _salesMode == 'wholesale'
                                          ? primaryColor.withValues(alpha: 0.1)
                                          : (isDark
                                              ? const Color(0xFF0F172A)
                                              : const Color(0xFFF1F5F9)),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color:
                                        _salesMode == 'wholesale'
                                            ? primaryColor
                                            : borderColor.withValues(
                                              alpha: 0.5,
                                            ),
                                    width:
                                        _salesMode == 'wholesale' ? 1.5 : 1.0,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.store_outlined,
                                      size: 16,
                                      color:
                                          _salesMode == 'wholesale'
                                              ? primaryColor
                                              : Colors.grey,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Al Por Mayor',
                                      style: TextStyle(
                                        fontFamily: 'Manrope',
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            _salesMode == 'wholesale'
                                                ? primaryColor
                                                : (isDark
                                                    ? Colors.grey.shade400
                                                    : Colors.grey.shade700),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // 2. Unidad de Medida (Unidades individuales + Todas las Unidades)
                      Text(
                        'Unidad de Medida Aplicable',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color:
                              isDark
                                  ? Colors.grey.shade300
                                  : Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ..._availableUnits.map((u) {
                            final isSelected =
                                _selectedUnit.toUpperCase() ==
                                u.toUpperCase();
                            return ChoiceChip(
                              label: Text(u),
                              selected: isSelected,
                              selectedColor: primaryColor.withValues(
                                alpha: 0.15,
                              ),
                              side: BorderSide(
                                color:
                                    isSelected
                                        ? primaryColor
                                        : borderColor.withValues(
                                          alpha: 0.6,
                                        ),
                                width: isSelected ? 1.2 : 0.8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              labelStyle: TextStyle(
                                fontFamily: 'JetBrains Mono',
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color:
                                    isSelected
                                        ? primaryColor
                                        : (isDark
                                            ? Colors.white
                                            : Colors.black87),
                              ),
                              onSelected: (selected) {
                                if (selected) _onUnitChanged(u);
                              },
                            );
                          }),
                          // Opción "Todas las Unidades"
                          ChoiceChip(
                            avatar: Icon(
                              Icons.auto_awesome,
                              size: 14,
                              color:
                                  _selectedUnit == 'TODAS'
                                      ? primaryColor
                                      : const Color(0xFFD97706),
                            ),
                            label: const Text('Todas las Unidades'),
                            selected: _selectedUnit == 'TODAS',
                            selectedColor: primaryColor.withValues(
                              alpha: 0.18,
                            ),
                            side: BorderSide(
                              color:
                                  _selectedUnit == 'TODAS'
                                      ? primaryColor
                                      : const Color(0xFFF59E0B),
                              width: _selectedUnit == 'TODAS' ? 1.5 : 1.0,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            labelStyle: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color:
                                  _selectedUnit == 'TODAS'
                                      ? primaryColor
                                      : (isDark
                                          ? const Color(0xFFFCD34D)
                                          : const Color(0xFFB45309)),
                            ),
                            onSelected: (selected) {
                              if (selected) _onUnitChanged('TODAS');
                            },
                          ),
                        ],
                      ),

                      if (_selectedUnit == 'TODAS') ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.amber.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 16,
                                color: Colors.amber.shade800,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Al seleccionar "Todas las Unidades", la oferta se aplicará proporcionalmente en porcentaje (%) a todas las presentaciones al ${_salesMode == 'wholesale' ? 'Por Mayor' : 'Detalle'}. Solo se permite descuento porcentual.',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color:
                                        isDark
                                            ? Colors.amber.shade200
                                            : Colors.amber.shade900,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (hasDuplicateOffer) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.red.withValues(alpha: 0.35),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.block,
                                size: 16,
                                color: Color(0xFFEF4444),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Ya existe una oferta activa para este producto al ${_salesMode == 'wholesale' ? 'Por Mayor' : 'Detalle'} (${_selectedUnit == 'TODAS' ? 'Todas las unidades' : 'unidad $_selectedUnit'}). No se puede duplicar hasta que culmine o sea cancelada.',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? const Color(0xFFFCA5A5)
                                        : const Color(0xFFB91C1C),
                                    height: 1.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Discount Configuration Card
                Container(
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: borderColor.withValues(alpha: 0.6),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Configuración de Descuento',
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Mode Toggle (Porcentaje vs Monto Fijo)
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color:
                                    isDark
                                        ? const Color(0xFF0F172A)
                                        : const Color(0xFFEEF4FF),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _isPercentage = true;
                                          _discountValue = 25.0;
                                          _discountController.text = '25';
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              _isPercentage
                                                  ? cardBg
                                                  : Colors.transparent,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          boxShadow:
                                              _isPercentage
                                                  ? [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withValues(
                                                            alpha: 0.05,
                                                          ),
                                                      blurRadius: 4,
                                                    ),
                                                  ]
                                                  : null,
                                          border:
                                              _isPercentage
                                                  ? Border.all(
                                                    color: borderColor
                                                        .withValues(alpha: 0.4),
                                                  )
                                                  : null,
                                        ),
                                        child: Text(
                                          'Porcentaje (%)',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color:
                                                _isPercentage
                                                    ? primaryColor
                                                    : (isDark
                                                        ? Colors.grey.shade400
                                                        : Colors.grey.shade600),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap:
                                          _selectedUnit == 'TODAS'
                                              ? () {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'Para "Todas las Unidades", solo se permite descuento en Porcentaje (%).',
                                                    ),
                                                    duration: Duration(
                                                      seconds: 2,
                                                    ),
                                                  ),
                                                );
                                              }
                                              : () {
                                                setState(() {
                                                  _isPercentage = false;
                                                  _discountValue = 5.0;
                                                  _discountController.text =
                                                      '5.00';
                                                });
                                              },
                                      child: Opacity(
                                        opacity:
                                            _selectedUnit == 'TODAS' ? 0.45 : 1.0,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                (!_isPercentage &&
                                                        _selectedUnit !=
                                                            'TODAS')
                                                    ? cardBg
                                                    : Colors.transparent,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            boxShadow:
                                                (!_isPercentage &&
                                                        _selectedUnit !=
                                                            'TODAS')
                                                    ? [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withValues(
                                                              alpha: 0.05,
                                                            ),
                                                        blurRadius: 4,
                                                      ),
                                                    ]
                                                    : null,
                                            border:
                                                (!_isPercentage &&
                                                        _selectedUnit !=
                                                            'TODAS')
                                                    ? Border.all(
                                                      color: borderColor
                                                          .withValues(
                                                            alpha: 0.4,
                                                          ),
                                                    )
                                                    : null,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'Monto Fijo (\$)',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color:
                                                      !_isPercentage
                                                          ? primaryColor
                                                          : (isDark
                                                              ? Colors
                                                                  .grey
                                                                  .shade400
                                                              : Colors
                                                                  .grey
                                                                  .shade600),
                                                ),
                                              ),
                                              if (_selectedUnit == 'TODAS') ...[
                                                const SizedBox(width: 4),
                                                const Icon(
                                                  Icons.lock_outline,
                                                  size: 13,
                                                  color: Colors.grey,
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Discount Value Input & Preset Chips
                            Text(
                              'Valor del Descuento',
                              style: TextStyle(
                                fontSize: 13,
                                color:
                                    isDark
                                        ? Colors.grey.shade400
                                        : Colors.grey.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 6),

                            TextField(
                              controller: _discountController,
                              keyboardType: TextInputType.numberWithOptions(
                                decimal: !_isPercentage,
                              ),
                              style: const TextStyle(
                                fontFamily: 'JetBrains Mono',
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              onChanged: (val) {
                                final parsed = double.tryParse(val) ?? 0.0;
                                setState(() {
                                  _discountValue = parsed;
                                });
                              },
                              decoration: InputDecoration(
                                suffixText: _isPercentage ? '%' : '\$',
                                suffixStyle: TextStyle(
                                  fontFamily: 'JetBrains Mono',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                            ),

                            if (_isPercentage) ...[
                              const SizedBox(height: 12),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children:
                                      [15, 20, 25, 30, 50].map((preset) {
                                        final isSelected =
                                            _discountValue.toInt() == preset;
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            right: 8,
                                          ),
                                          child: ChoiceChip(
                                            label: Text('-$preset%'),
                                            selected: isSelected,
                                            selectedColor: primaryColor
                                                .withValues(alpha: 0.15),
                                            side: BorderSide.none,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              side: BorderSide.none,
                                            ),
                                            labelStyle: TextStyle(
                                              fontFamily: 'JetBrains Mono',
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  isSelected
                                                      ? primaryColor
                                                      : (isDark
                                                          ? Colors.white
                                                          : Colors.black87),
                                            ),
                                            onSelected: (selected) {
                                              if (selected) {
                                                setState(() {
                                                  _discountValue =
                                                      preset.toDouble();
                                                  _discountController.text =
                                                      preset.toString();
                                                });
                                              }
                                            },
                                          ),
                                        );
                                      }).toList(),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Calculation Preview Zone (code-edit.html design)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color:
                              isDark
                                  ? const Color(0xFF132030)
                                  : const Color(0xFFE5EEFF),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(16),
                            bottomRight: Radius.circular(16),
                          ),
                        ),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Precio Base (${_salesMode == 'wholesale' ? 'P. Mayor' : 'Detalle'})',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color:
                                        isDark
                                            ? Colors.grey.shade400
                                            : Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _selectedUnit == 'TODAS'
                                      ? '\$${_originalPrice.toStringAsFixed(2)}/kg base'
                                      : '\$${_originalPrice.toStringAsFixed(2)} / ${_selectedUnit.toLowerCase()}',
                                  style: TextStyle(
                                    fontFamily: 'JetBrains Mono',
                                    fontSize: 13,
                                    decoration: TextDecoration.lineThrough,
                                    color:
                                        isDark
                                            ? Colors.grey.shade400
                                            : Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Icon(
                                Icons.arrow_forward,
                                color: Colors.grey,
                                size: 20,
                              ),
                            ),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: primaryColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: primaryColor.withValues(alpha: 0.2),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'PRECIO DE OFERTA',
                                      style: TextStyle(
                                        fontFamily: 'JetBrains Mono',
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: primaryColor,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _selectedUnit == 'TODAS'
                                          ? '-${_calculatedDiscountPercentage.round()}%'
                                          : '\$${_calculatedOfferPrice.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontFamily: 'Manrope',
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                        color: primaryColor,
                                      ),
                                    ),
                                    Text(
                                      _selectedUnit == 'TODAS'
                                          ? 'En todas las unidades'
                                          : 'por ${_selectedUnit.toLowerCase()}',
                                      style: TextStyle(
                                        fontFamily: 'JetBrains Mono',
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: primaryColor.withValues(
                                          alpha: 0.8,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Duration Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor.withValues(alpha: 0.6)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Duración de la Oferta',
                                style: TextStyle(
                                  fontFamily: 'Manrope',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Selecciona cuánto tiempo estará activa',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: primaryColor.withValues(alpha: 0.2)),
                            ),
                            child: Text(
                              '${_durationHours.toInt()} Horas',
                              style: TextStyle(
                                fontFamily: 'JetBrains Mono',
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      SliderTheme(
                        data: SliderThemeData(
                          activeTrackColor: primaryColor,
                          inactiveTrackColor: borderColor,
                          thumbColor: primaryColor,
                          overlayColor: primaryColor.withValues(alpha: 0.2),
                          trackHeight: 6,
                        ),
                        child: Slider(
                          value: _durationHours,
                          min: 1,
                          max: 24,
                          divisions: 23,
                          onChanged: (val) {
                            setState(() {
                              _durationHours = val;
                            });
                          },
                        ),
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('1h', style: TextStyle(fontSize: 11, color: Colors.grey)),
                          Text('12h', style: TextStyle(fontSize: 11, color: Colors.grey)),
                          Text('24h', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // Finalization Indicator Box
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFEEF4FF),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: borderColor.withValues(alpha: 0.5)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.timer_outlined, size: 20, color: primaryColor),
                            const SizedBox(width: 10),
                            Text(
                              'Finaliza $_formattedEndDay a las ',
                              style: TextStyle(
                                fontSize: 13,
                                color:
                                    isDark
                                        ? Colors.grey.shade300
                                        : Colors.grey.shade800,
                              ),
                            ),
                            Text(
                              _formattedEndTime,
                              style: TextStyle(
                                fontFamily: 'JetBrains Mono',
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Action Footer
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: hasDuplicateOffer ? null : _onPublishOffer,
                        icon: const Icon(Icons.bolt, color: Colors.white, size: 20),
                        label: Text(
                          hasDuplicateOffer
                              ? 'Oferta Ya Existente'
                              : 'Activar Oferta Relámpago',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          disabledBackgroundColor: isDark
                              ? const Color(0xFF334155)
                              : const Color(0xFF94A3B8),
                          disabledForegroundColor: Colors.white70,
                          minimumSize: const Size(double.infinity, 50),
                        ),
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

  // ---------------------------------------------------------
  // FASE 2: Estado de Carga Animado (code_carga.html design)
  // ---------------------------------------------------------
  Widget _buildLoadingStepView(
    BuildContext context,
    bool isDark,
    Color primaryColor,
    Color cardBg,
    Color borderColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: SizedBox(
                width: 44,
                height: 44,
                child: CircularProgressIndicator(
                  strokeWidth: 3.5,
                  valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Procesando Oferta Relámpago...',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Aplicando descuentos y notificando al catálogo en tiempo real.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          // Skeleton Bar simulation
          Container(
            height: 6,
            width: 200,
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(3),
            ),
            child: const LinearProgressIndicator(
              backgroundColor: Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // FASE 3: Modal de Confirmación Éxito (code_exito.html design)
  // ---------------------------------------------------------
  Widget _buildSuccessStepView(
    BuildContext context,
    bool isDark,
    Color primaryColor,
    Color cardBg,
  ) {
    final productName = widget.product['name'] ?? widget.product['title'] ?? 'Tomate Saladette';

    return Container(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle,
              size: 48,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '¡Oferta Activada con Éxito!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Tu oferta relámpago para "$productName" ya está visible para todos los compradores en El Mercadito.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
              color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(
              'Aceptar y Ver Ofertas',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
