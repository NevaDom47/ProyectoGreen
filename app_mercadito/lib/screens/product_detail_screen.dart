import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../data/global_state.dart';
import '../widgets/animated_favorite_button.dart';
import '../widgets/product_reviews_modal.dart';
import '../widgets/quality_info_bottom_sheet.dart';
import '../widgets/supplier_quick_view_bottom_sheet.dart';
import '../widgets/skeleton_loading.dart';

class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final PageController _pageController = PageController();
  int _quantity = 1;
  late String _selectedUnit;
  late List<String> _availableUnits;
  late String _selectedSaleType; // 'detalle' or 'mayor'
  late bool _hasBothSaleTypes;
  final TextEditingController _qtyController = TextEditingController(text: '1');
  final GlobalKey<ShakeWidgetState> _shakeKey = GlobalKey<ShakeWidgetState>();
  bool _isExpanded = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _hasBothSaleTypes = _checkHasBothSaleTypes();

    final rawSaleType = (widget.product['saleType'] ?? widget.product['salesMode'] ?? '').toString().toLowerCase();
    if (rawSaleType == 'mayor' && !_hasBothSaleTypes) {
      _selectedSaleType = 'mayor';
    } else {
      _selectedSaleType = 'detalle';
    }

    _syncUnitsForSaleType(isInitial: true);

    var limits = _getUnitLimits(_selectedUnit);
    _quantity = limits['min']!;
    _qtyController.text = _quantity.toString();

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _qtyController.dispose();
    super.dispose();
  }

  bool _checkHasBothSaleTypes() {
    final saleType = (widget.product['saleType'] ?? '').toString().toLowerCase();
    final salesMode = (widget.product['salesMode'] ?? '').toString().toLowerCase();
    if (saleType == 'ambos' || saleType == 'both' || salesMode == 'both' || salesMode == 'ambos') {
      return true;
    }

    if (widget.product['unitConfigs'] is List) {
      final configs = widget.product['unitConfigs'] as List;
      final hasDetalle = configs.any((c) => c is Map && c['saleType'] == 'detalle');
      final hasMayor = configs.any((c) => c is Map && c['saleType'] == 'mayor');
      if (hasDetalle && hasMayor) return true;
    }

    final hasWholesalePrice = widget.product['wholesalePrice'] != null || widget.product['wholesalePriceNum'] != null;
    final hasRegularPrice = widget.product['price'] != null || widget.product['priceNum'] != null;
    if (hasWholesalePrice && hasRegularPrice) {
      return true;
    }

    final rawUnits = widget.product['availableUnits'];
    if (rawUnits is List && rawUnits.any((u) => u.toString().toLowerCase().contains('saco') || u.toString().toLowerCase().contains('caja'))) {
      return true;
    }

    final name = (widget.product['name'] ?? '').toString().toLowerCase();
    if (name.contains('papa blanca') || name.contains('limón') || name.contains('zanahoria')) {
      return true;
    }

    return false;
  }

  void _syncUnitsForSaleType({bool isInitial = false}) {
    List<String> units = [];

    // 1. Check unitConfigs
    if (widget.product['unitConfigs'] is List) {
      final configs = widget.product['unitConfigs'] as List;
      for (var c in configs) {
        if (c is Map && c['saleType'] == _selectedSaleType && c['unit'] != null) {
          units.add(c['unit'].toString());
        }
      }
    }

    // 2. Filter from availableUnits if present and no configs matched
    if (units.isEmpty && widget.product['availableUnits'] is List) {
      final allAvailable = (widget.product['availableUnits'] as List).map((e) => e.toString()).toList();
      if (_selectedSaleType == 'mayor') {
        units = allAvailable.where((u) => u.toLowerCase().contains('saco') || u.toLowerCase().contains('caja')).toList();
      } else {
        units = allAvailable.where((u) => !u.toLowerCase().contains('saco') && !u.toLowerCase().contains('caja')).toList();
      }
    }

    // 3. Fallbacks
    if (units.isEmpty) {
      if (_selectedSaleType == 'mayor') {
        units = ['Saco', 'Caja'];
      } else {
        units = ['Por Libra', 'Unidad'];
      }
    }

    _availableUnits = units;

    if (isInitial) {
      String rawUnit = widget.product['unit'] ?? '';
      String candidate = '';
      if (rawUnit.toLowerCase().contains('libra')) {
        candidate = 'Por Libra';
      } else if (rawUnit.toLowerCase().contains('saco')) {
        candidate = 'Saco';
      } else if (rawUnit.toLowerCase().contains('caja')) {
        candidate = 'Caja';
      } else if (rawUnit.toLowerCase().contains('unidad')) {
        candidate = 'Unidad';
      }

      if (_availableUnits.contains(candidate)) {
        _selectedUnit = candidate;
      } else if (_availableUnits.contains(rawUnit)) {
        _selectedUnit = rawUnit;
      } else if (_availableUnits.contains('Unidad')) {
        _selectedUnit = 'Unidad';
      } else {
        _selectedUnit = _availableUnits.first;
      }
    } else {
      if (!_availableUnits.contains(_selectedUnit)) {
        _selectedUnit = _availableUnits.first;
      }
    }

    var limits = _getUnitLimits(_selectedUnit);
    int min = limits['min']!;
    int max = limits['max']!;
    if (_quantity < min) {
      _quantity = min;
      _qtyController.text = _quantity.toString();
    } else if (max > 0 && max < 500 && _quantity > max) {
      _quantity = max;
      _qtyController.text = _quantity.toString();
    }
  }

  void _onSaleTypeChanged(String newType) {
    if (_selectedSaleType == newType) return;
    HapticFeedback.selectionClick();
    setState(() {
      _selectedSaleType = newType;
      _syncUnitsForSaleType(isInitial: false);
    });
  }

  double _getCurrentUnitPrice() {
    // 1. Check unitConfigs
    if (widget.product['unitConfigs'] is List) {
      final configs = widget.product['unitConfigs'] as List;
      for (var c in configs) {
        if (c is Map && c['saleType'] == _selectedSaleType && c['unit'] == _selectedUnit) {
          if (_selectedSaleType == 'mayor' && c['priceWholesale'] != null) {
            return (c['priceWholesale'] as num).toDouble();
          }
          if (_selectedSaleType == 'detalle' && c['priceRetail'] != null) {
            return (c['priceRetail'] as num).toDouble();
          }
        }
      }
    }

    // 2. Base price fallback
    final String priceStr = widget.product['price'] ?? '\$18.00';
    final double baseRetail = double.tryParse(priceStr.replaceAll('\$', '')) ?? 18.0;

    if (_selectedSaleType == 'mayor') {
      final wp = widget.product['wholesalePrice'] ?? widget.product['wholesalePriceNum'];
      double baseWholesale = wp != null
          ? (double.tryParse(wp.toString().replaceAll('\$', '')) ?? 14.50)
          : (baseRetail * 0.8);

      if (_selectedUnit.toLowerCase().contains('saco')) {
        return 280.00;
      } else if (_selectedUnit.toLowerCase().contains('caja')) {
        return 220.00;
      }
      return baseWholesale;
    } else {
      if (_selectedUnit.toLowerCase().contains('saco')) {
        return 320.00;
      } else if (_selectedUnit.toLowerCase().contains('caja')) {
        return 250.00;
      }
      return baseRetail;
    }
  }

  String _getLimitsText() {
    final limits = _getUnitLimits(_selectedUnit);
    final min = limits['min'] ?? 1;
    final max = limits['max'] ?? 99;

    if (_selectedSaleType == 'mayor') {
      if (max >= 500 || max == 0) {
        return 'Venta mínima: $min | Sin límites';
      }
      return 'Venta mínima: $min | Máx. $max';
    } else {
      if (max >= 500 || max == 0) {
        return 'Mín. $min | Sin límites';
      }
      return 'Mín. $min | Máx. $max';
    }
  }

  Map<String, int> _getUnitLimits(String unit) {
    if (_selectedSaleType == 'mayor') {
      int defaultWholesaleMin = 10;
      final wm = widget.product['wholesaleMin'];
      if (wm != null) {
        final match = RegExp(r'\d+').firstMatch(wm.toString());
        if (match != null) {
          defaultWholesaleMin = int.tryParse(match.group(0)!) ?? 10;
        }
      }
      if (unit.toLowerCase().contains('saco')) return {'min': 2, 'max': 50};
      if (unit.toLowerCase().contains('caja')) return {'min': 3, 'max': 100};
      if (unit.toLowerCase().contains('libra') || unit.toLowerCase().contains('lb')) return {'min': defaultWholesaleMin, 'max': 500};
      if (unit.toLowerCase().contains('kg')) return {'min': defaultWholesaleMin, 'max': 500};
      return {'min': defaultWholesaleMin, 'max': 500};
    }

    if (unit.toLowerCase().contains('unidad')) return {'min': 5, 'max': 20};
    if (unit.toLowerCase().contains('libra') || unit.toLowerCase().contains('lb')) return {'min': 2, 'max': 50};
    if (unit.toLowerCase().contains('saco')) return {'min': 1, 'max': 10};
    if (unit.toLowerCase().contains('caja')) return {'min': 1, 'max': 15};
    return {'min': 1, 'max': 99};
  }

  void _updateQuantity(int newQty) {
    var limits = _getUnitLimits(_selectedUnit);
    int min = limits['min']!;
    int max = limits['max']!;

    bool outOfBounds = false;

    if (newQty < min || newQty == 0) {
      newQty = min;
      outOfBounds = true;
    } else if (max > 0 && max < 500 && newQty > max) {
      newQty = max;
      outOfBounds = true;
    }

    if (outOfBounds) {
      _shakeKey.currentState?.shake();
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Valores introducidos no permitidos para este producto',
            style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }

    setState(() {
      _quantity = newQty;
      _qtyController.text = _quantity.toString();
      _qtyController.selection = TextSelection.fromPosition(
          TextPosition(offset: _qtyController.text.length));
    });
  }

  void _handleAddToCart() {
    String mappedUnit = _selectedUnit.toUpperCase();
    if (_selectedUnit == 'Por Libra') {
      mappedUnit = 'LIBRA';
    } else if (_selectedUnit == 'Saco') {
      mappedUnit = 'SACO';
    } else if (_selectedUnit == 'Caja') {
      mappedUnit = 'CAJA';
    } else if (_selectedUnit == 'Unidad') {
      mappedUnit = 'UNIDAD';
    }

    final double unitPrice = _getCurrentUnitPrice();

    final cartProduct = {
      ...widget.product,
      'unit': mappedUnit,
      'saleType': _selectedSaleType,
      'price': '\$${unitPrice.toStringAsFixed(2)}',
      'priceNum': unitPrice,
    };

    for (int i = 0; i < _quantity; i++) {
      addToCart(cartProduct);
    }

    final isWholesale = _selectedSaleType == 'mayor';
    final modeLabel = isWholesale ? ' (Al por mayor)' : '';

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '$_quantity $mappedUnit$modeLabel agregado(s) al carrito',
                style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: isWholesale ? const Color(0xFF0284C7) : const Color(0xFF00462f),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showSupplierQuickView() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SupplierQuickViewBottomSheet(supplierData: widget.product);
      },
    );
  }

  void _showQualityBottomSheet() {
    final quality = widget.product['quality'] ?? widget.product['badge'] ?? 'Primera';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return QualityInfoBottomSheet(quality: quality);
      },
    );
  }

  void _showReviewsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 20, // Leave some space at the top
          ),
          child: ProductReviewsModal(product: widget.product),
        );
      },
    );
  }

  Widget _buildSaleTypeSwitcher(bool isDark, Color primary) {
    if (!_hasBothSaleTypes) {
      final isWholesale = _selectedSaleType == 'mayor';
      final badgeColor = isWholesale ? const Color(0xFF0284C7) : primary;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: badgeColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: badgeColor.withValues(alpha: 0.25), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isWholesale ? Icons.inventory_2_outlined : Icons.shopping_bag_outlined,
              size: 13,
              color: badgeColor,
            ),
            const SizedBox(width: 5),
            Text(
              isWholesale ? 'Por Mayor' : 'Al Detalle',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: badgeColor,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF262C28) : const Color(0xFFEBF0EC),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white12 : const Color(0xFFD3DDD5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSaleTypeTab(
            type: 'detalle',
            label: 'Detalle',
            icon: Icons.shopping_bag_outlined,
            isSelected: _selectedSaleType == 'detalle',
            activeColor: primary,
            isDark: isDark,
          ),
          _buildSaleTypeTab(
            type: 'mayor',
            label: 'Por Mayor',
            icon: Icons.inventory_2_outlined,
            isSelected: _selectedSaleType == 'mayor',
            activeColor: const Color(0xFF0284C7),
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildSaleTypeTab({
    required String type,
    required String label,
    required IconData icon,
    required bool isSelected,
    required Color activeColor,
    required bool isDark,
  }) {
    final subtitleColor = isDark ? Colors.grey[400]! : const Color(0xFF6B7A73);

    return GestureDetector(
      onTap: () => _onSaleTypeChanged(type),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13,
              color: isSelected ? Colors.white : subtitleColor,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? Colors.white : subtitleColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = const Color(0xFF00462f);
    final bgColor = isDark ? const Color(0xFF181d1a) : Colors.white;
    final surfaceColor = isDark ? const Color(0xFF2d312e) : const Color(0xFFf7faf5);
    final textColor = isDark ? Colors.white : const Color(0xFF181d1a);
    final subtitleColor = isDark ? Colors.grey[400]! : const Color(0xFF88968f);

    final String name = widget.product['name'] ?? 'Producto';
    final String category = widget.product['category'] ?? 'General';
    final String sku = (widget.product['sku'] != null && widget.product['sku'].toString().isNotEmpty)
        ? widget.product['sku'].toString()
        : (widget.product['id'] != null && widget.product['id'].toString().startsWith('PROD-')
            ? widget.product['id'].toString()
            : (() {
                final catCode = category.replaceAll(' ', '').toUpperCase();
                final nmCode = name.replaceAll(' ', '').toUpperCase();
                final c3 = catCode.length >= 3 ? catCode.substring(0, 3) : catCode.padRight(3, 'X');
                final n3 = nmCode.length >= 3 ? nmCode.substring(0, 3) : nmCode.padRight(3, 'X');
                return '$c3-$n3-01';
              })());
    final String image = widget.product['image'] ?? widget.product['img'] ?? 'https://via.placeholder.com/400';
    final double basePrice = _getCurrentUnitPrice();
    final double totalPrice = basePrice * _quantity;
    final String rating = (widget.product['rating'] ?? '5.0').toString().split(' ').first;
    final String quality = widget.product['quality'] ?? widget.product['badge'] ?? 'Primera';
    final String supplier = widget.product['supplier'] ?? 'Mercadito Local';
    final String fullDescription = widget.product['description'] ?? 
        'Este es un producto cultivado localmente bajo estrictos estándares de calidad. Todas nuestras frutas son seleccionadas a mano y revisadas para garantizar la mejor frescura del campo a su mesa. Nuestro proceso asegura que cada ítem mantenga sus propiedades naturales y su sabor auténtico, apoyando a los productores locales y ofreciendo un precio justo para todos.';
    
    // Logic to truncate the description
    const int truncateLimit = 120;
    final bool canTruncate = fullDescription.length > truncateLimit;
    final String displayDescription = (_isExpanded || !canTruncate) 
        ? fullDescription 
        : '${fullDescription.substring(0, truncateLimit)}... ';

    // Product images (fallback to single image repeated or default)
    final List<String> images = (widget.product['photos'] is List && (widget.product['photos'] as List).isNotEmpty)
        ? (widget.product['photos'] as List).map((e) => e.toString()).toList()
        : [image, image, image];

    return Scaffold(
      backgroundColor: bgColor,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: _isLoading
          ? _buildSkeletonLoader(context, bgColor, surfaceColor)
          : Stack(
              children: [
                SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 120), // Space for bottom bar
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Hero Image Section with curved bottom
                SizedBox(
                  height: 400,
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(40),
                          bottomRight: Radius.circular(40),
                        ),
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: images.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () => _openFullScreenImage(images, index),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                Hero(
                                  tag: 'product_image_$index',
                                  child: images[index].startsWith('assets/')
                                      ? Image.asset(
                                          images[index],
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => Container(
                                            color: surfaceColor,
                                            child: const Icon(Icons.image_not_supported),
                                          ),
                                        )
                                      : CachedNetworkImage(
                                          imageUrl: images[index],
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) => Container(color: surfaceColor),
                                          errorWidget: (context, url, error) => Container(color: surfaceColor, child: const Icon(Icons.error)),
                                        ),
                                ),
                                // Gradient Overlay
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.black.withValues(alpha: 0.5),
                                        Colors.transparent,
                                        Colors.black.withValues(alpha: 0.4),
                                      ],
                                      stops: const [0.0, 0.5, 1.0],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                      // Top SafeArea Bar
                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () => context.pop(),
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.arrow_back, color: Colors.black, size: 24),
                                ),
                              ),
                              Text(
                                'Producto',
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              ValueListenableBuilder<List<Map<String, dynamic>>>(
                                valueListenable: globalFavorites,
                                builder: (context, favorites, child) {
                                  final isFav = isFavorite(name);
                                  return AnimatedFavoriteButton(
                                    isFavorite: isFav,
                                    size: 24,
                                    onTap: () {
                                      toggleFavorite(widget.product);
                                      ScaffoldMessenger.of(context).clearSnackBars();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Row(
                                            children: [
                                              Icon(isFav ? Icons.heart_broken : Icons.favorite, color: Colors.white, size: 20),
                                              const SizedBox(width: 12),
                                              Text(isFav ? 'Eliminado de favoritos' : 'Agregado a favoritos', style: const TextStyle(fontWeight: FontWeight.bold)),
                                            ],
                                          ),
                                          backgroundColor: isFav ? Colors.red : const Color(0xFF016142),
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Page Indicator
                      Positioned(
                        bottom: 24,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: SmoothPageIndicator(
                            controller: _pageController,
                            count: images.length,
                            effect: ExpandingDotsEffect(
                              dotHeight: 6,
                              dotWidth: 8,
                              spacing: 6,
                              expansionFactor: 3,
                              activeDotColor: Color(0xFF00462f),
                              dotColor: Colors.white70,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 2. Content Details
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Row: Category, Title, Limits (Left) and Sale Type Switcher (Right in red box area)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Category & SKU
                                Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  spacing: 4,
                                  children: [
                                    Text(
                                      category,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14,
                                        color: subtitleColor,
                                        fontWeight: FontWeight.w600,
                                        height: 1.0,
                                      ),
                                    ),
                                    if (sku.isNotEmpty) ...[
                                      Text(
                                        '•',
                                        style: TextStyle(
                                          color: subtitleColor,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        'SKU: $sku',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11,
                                          color: subtitleColor,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 4),
                                // Title
                                Text(
                                  name,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 24,
                                    color: textColor,
                                    fontWeight: FontWeight.bold,
                                    height: 1.1,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                ShakeWidget(
                                  key: _shakeKey,
                                  child: Text(
                                    _getLimitsText(),
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      color: subtitleColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Switcher positioned exactly in the red box
                          _buildSaleTypeSwitcher(isDark, primary),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Price & Quantity Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '\$',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              color: const Color(0xFFf59e0b),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            basePrice.toStringAsFixed(2),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 32,
                              color: textColor,
                              fontWeight: FontWeight.w800,
                              height: 1.0,
                            ),
                          ),
                          if (_selectedSaleType == 'mayor') ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0284C7).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFF0284C7).withValues(alpha: 0.25), width: 1),
                              ),
                              child: Text(
                                'Por Mayor',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF0284C7),
                                ),
                              ),
                            ),
                          ],
                          const Spacer(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // Unit Chips
                              Row(
                                children: _availableUnits.map((unit) {
                                  final isSelected = _selectedUnit == unit;
                                  final activeColor = _selectedSaleType == 'mayor' ? const Color(0xFF0284C7) : primary;
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedUnit = unit;
                                        _updateQuantity(_quantity);
                                      });
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(left: 6),
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isSelected ? activeColor : (isDark ? Colors.grey[800] : const Color(0xFFe9eceb)),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        unit,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                          color: isSelected ? Colors.white : subtitleColor,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 12),
                              // Quantity Selector
                              Container(
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.grey[800] : const Color(0xFFe9eceb),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                child: Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () => _updateQuantity(_quantity - 1),
                                      child: Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Icon(Icons.remove, size: 18, color: textColor),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    SizedBox(
                                      width: 40,
                                      child: Focus(
                                        onFocusChange: (hasFocus) {
                                          if (!hasFocus) {
                                            int val = int.tryParse(_qtyController.text) ?? _getUnitLimits(_selectedUnit)['min']!;
                                            _updateQuantity(val);
                                          }
                                        },
                                        child: TextField(
                                          controller: _qtyController,
                                          keyboardType: TextInputType.number,
                                          textAlign: TextAlign.center,
                                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: textColor,
                                          ),
                                          decoration: const InputDecoration(
                                            border: InputBorder.none,
                                            contentPadding: EdgeInsets.zero,
                                            isDense: true,
                                          ),
                                          onChanged: (val) {
                                            if (val.isEmpty) return;
                                            int newQty = int.tryParse(val) ?? _getUnitLimits(_selectedUnit)['min']!;
                                            var limits = _getUnitLimits(_selectedUnit);
                                            if (newQty > limits['max']! || newQty == 0) {
                                              _updateQuantity(newQty);
                                            } else {
                                              setState(() {
                                                _quantity = newQty;
                                              });
                                            }
                                          },
                                          onSubmitted: (val) {
                                            int newQty = int.tryParse(val) ?? _getUnitLimits(_selectedUnit)['min']!;
                                            _updateQuantity(newQty);
                                          },
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: () => _updateQuantity(_quantity + 1),
                                      child: Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Icon(Icons.add, size: 18, color: textColor),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (_selectedSaleType == 'mayor') ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0284C7).withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFF0284C7).withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.inventory_2_outlined, size: 16, color: Color(0xFF0284C7)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Estás comprando por mayor. Precios especiales por volumen aplicados.',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    color: const Color(0xFF0284C7),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),
                      Divider(color: outlineVariantColor(isDark)),
                      const SizedBox(height: 16),

                      // Metrics Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 10,
                            child: GestureDetector(
                              onTap: _showReviewsModal,
                              behavior: HitTestBehavior.opaque,
                              child: _buildMetricCol('Clasificación', Icons.star, const Color(0xFFFFB300), rating, isDark, textColor, subtitleColor, subtitle: '(124 reseñas)'),
                            ),
                          ),
                          Expanded(
                            flex: 11,
                            child: GestureDetector(
                              onTap: _showQualityBottomSheet,
                              behavior: HitTestBehavior.opaque,
                              child: _buildMetricCol(
                                'Calidad', 
                                Icons.eco, 
                                quality.toUpperCase().contains('PRIMERA') 
                                  ? const Color(0xFF016142) 
                                  : (quality.toUpperCase().contains('SEGUNDA') ? Colors.orange : Colors.red), 
                                quality.toUpperCase(), 
                                isDark, 
                                textColor, 
                                subtitleColor,
                                useIconColorForText: true,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 9,
                            child: GestureDetector(
                              onTap: _showSupplierQuickView,
                              behavior: HitTestBehavior.opaque,
                              child: _buildMetricCol('Proveedor', Icons.store, primary, supplier, isDark, textColor, subtitleColor),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      Divider(color: outlineVariantColor(isDark)),
                      const SizedBox(height: 24),

                      // Provider Note
                      Text(
                        'Nota del proveedor',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      RichText(
                        text: TextSpan(
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            color: subtitleColor,
                            height: 1.5,
                          ),
                          children: [
                            TextSpan(text: displayDescription),
                            if (canTruncate)
                              TextSpan(
                                text: _isExpanded ? ' Ver menos' : ' Leer más',
                                style: GoogleFonts.plusJakartaSans(
                                  color: primary,
                                  fontWeight: FontWeight.bold,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    setState(() {
                                      _isExpanded = !_isExpanded;
                                    });
                                  },
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),
                      
                      // Location Section
                      Text(
                        'Ubicación',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          children: [
                            Image.network(
                              'https://images.unsplash.com/photo-1524661135-423995f22d0b?q=80&w=400&auto=format&fit=crop',
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                height: 150,
                                width: double.infinity,
                                color: surfaceColor,
                                child: const Center(child: Icon(Icons.store, color: Colors.grey)),
                              ),
                            ),
                            Positioned.fill(
                              child: Container(
                                color: Colors.black.withValues(alpha: 0.1),
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
          ),

          // 3. Sticky Bottom Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 16,
                bottom: MediaQuery.of(context).padding.bottom + 16,
              ),
              decoration: BoxDecoration(
                color: bgColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Total Price
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _selectedSaleType == 'mayor' ? 'Precio Total (Mayoreo)' : 'Precio Total',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: subtitleColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '\$',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              color: const Color(0xFFf59e0b),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            totalPrice.toStringAsFixed(2),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 24,
                              color: textColor,
                              fontWeight: FontWeight.w800,
                              height: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(width: 24),
                  // Add to Cart Button
                  Expanded(
                    child: GestureDetector(
                      onTap: _handleAddToCart,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: _selectedSaleType == 'mayor' ? const Color(0xFF0284C7) : primary,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: (_selectedSaleType == 'mayor' ? const Color(0xFF0284C7) : primary).withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _selectedSaleType == 'mayor' ? Icons.inventory_2_outlined : Icons.shopping_cart_outlined,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Agregar al carrito',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
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
    );
  }

  Color outlineVariantColor(bool isDark) {
    return isDark ? Colors.grey[800]! : const Color(0xFFe9eceb);
  }

  Widget _buildMetricCol(String title, IconData icon, Color iconColor, String value, bool isDark, Color textColor, Color subtitleColor, {bool useIconColorForText = false, String? subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: subtitleColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: iconColor),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: useIconColorForText ? iconColor : textColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        color: subtitleColor,
                        fontWeight: FontWeight.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSkeletonLoader(BuildContext context, Color bgColor, Color surfaceColor) {
    return SkeletonShimmer(
      child: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Hero Image
                const SkeletonContainer(
                  height: 400,
                  width: double.infinity,
                  customBorderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category
                      const SkeletonContainer(width: 100, height: 14, borderRadius: 4),
                      const SizedBox(height: 8),
                      // Title
                      const SkeletonContainer(width: 250, height: 28, borderRadius: 6),
                      const SizedBox(height: 6),
                      // Min/Max
                      const SkeletonContainer(width: 150, height: 12, borderRadius: 4),
                      const SizedBox(height: 16),
                      // Price & Quantity
                      Row(
                        children: [
                          const SkeletonContainer(width: 100, height: 32, borderRadius: 8),
                          const Spacer(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // Unit chips
                              Row(
                                children: List.generate(3, (index) => const Padding(
                                  padding: EdgeInsets.only(left: 6),
                                  child: SkeletonContainer(width: 50, height: 24, borderRadius: 8),
                                )),
                              ),
                              const SizedBox(height: 12),
                              // Counter
                              const SkeletonContainer(width: 120, height: 32, borderRadius: 12),
                            ],
                          )
                        ],
                      ),
                      const SizedBox(height: 24),
                      Divider(color: Colors.grey.withValues(alpha: 0.2)),
                      const SizedBox(height: 16),
                      // Metrics
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(3, (index) => const SkeletonContainer(width: 80, height: 40, borderRadius: 8)),
                      ),
                      const SizedBox(height: 16),
                      Divider(color: Colors.grey.withValues(alpha: 0.2)),
                      const SizedBox(height: 24),
                      // Description
                      const SkeletonContainer(width: 150, height: 20, borderRadius: 4),
                      const SizedBox(height: 8),
                      const SkeletonContainer(width: double.infinity, height: 14, borderRadius: 4),
                      const SizedBox(height: 4),
                      const SkeletonContainer(width: double.infinity, height: 14, borderRadius: 4),
                      const SizedBox(height: 4),
                      const SkeletonContainer(width: 200, height: 14, borderRadius: 4),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Bottom Bar
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: EdgeInsets.only(left: 24, right: 24, top: 16, bottom: MediaQuery.of(context).padding.bottom + 16),
              color: bgColor,
              child: Row(
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SkeletonContainer(width: 80, height: 12, borderRadius: 4),
                      SizedBox(height: 4),
                      SkeletonContainer(width: 100, height: 24, borderRadius: 6),
                    ],
                  ),
                  const SizedBox(width: 24),
                  const Expanded(child: SkeletonContainer(height: 52, borderRadius: 16)),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  void _openFullScreenImage(List<String> images, int initialIndex) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black.withValues(alpha: 0.9),
        pageBuilder: (context, _, _) => FullScreenImageViewer(
          images: images,
          initialIndex: initialIndex,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }
}

class ShakeWidget extends StatefulWidget {
  final Widget child;
  const ShakeWidget({super.key, required this.child});

  @override
  State<ShakeWidget> createState() => ShakeWidgetState();
}

class ShakeWidgetState extends State<ShakeWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isShaking = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _animation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 5.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 5.0, end: -5.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -5.0, end: 5.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 5.0, end: -5.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -5.0, end: 0.0), weight: 1),
    ]).animate(_controller);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) setState(() => _isShaking = false);
        _controller.reset();
      }
    });
  }

  void shake() {
    if (!_isShaking && mounted) {
      setState(() => _isShaking = true);
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_animation.value, 0),
          child: DefaultTextStyle.merge(
            style: TextStyle(color: _isShaking ? Colors.red : null),
            child: widget.child,
          ),
        );
      },
    );
  }
}

class FullScreenImageViewer extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const FullScreenImageViewer({super.key, required this.images, required this.initialIndex});

  @override
  State<FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer> {
  late PageController _controller;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: widget.images.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return InteractiveViewer(
                minScale: 1.0,
                maxScale: 4.0,
                child: Center(
                  child: Hero(
                    tag: 'product_image_$index',
                    child: widget.images[index].startsWith('assets/')
                        ? Image.asset(
                            widget.images[index],
                            fit: BoxFit.contain,
                          )
                        : CachedNetworkImage(
                            imageUrl: widget.images[index],
                            fit: BoxFit.contain,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            ),
                          ),
                  ),
                ),
              );
            },
          ),
          // Header Overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 10,
                left: 20,
                right: 20,
                bottom: 20,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, color: Colors.white, size: 24),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_currentIndex + 1} / ${widget.images.length}',
                      style: const TextStyle(
                        color: Colors.white, 
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 44), // balance
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
