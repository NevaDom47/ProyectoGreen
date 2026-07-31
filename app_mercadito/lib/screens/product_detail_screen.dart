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
  final TextEditingController _qtyController = TextEditingController(text: '1');
  final GlobalKey<ShakeWidgetState> _shakeKey = GlobalKey<ShakeWidgetState>();
  bool _isExpanded = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // In a real app we'd get this from the product map.
    // Here we deduce it from the design or default strings.
    String rawUnit = widget.product['unit'] ?? 'Por Libra';
    if (rawUnit.toLowerCase().contains('libra')) {
      _selectedUnit = 'Por Libra';
    } else if (rawUnit.toLowerCase().contains('saco')) {
      _selectedUnit = 'Saco';
    } else if (rawUnit.toLowerCase().contains('caja')) {
      _selectedUnit = 'Caja';
    } else {
      _selectedUnit = 'Unidad';
    }
    _availableUnits = ['Por Libra', 'Unidad', 'Saco', 'Caja'];
    
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

  Map<String, int> _getUnitLimits(String unit) {
    if (unit.toLowerCase().contains('unidad')) return {'min': 5, 'max': 20};
    if (unit.toLowerCase().contains('libra')) return {'min': 2, 'max': 50};
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
    } else if (newQty > max) {
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
    // Map the selected unit back to the format globalCart expects
    String mappedUnit;
    if (_selectedUnit == 'Por Libra') {
      mappedUnit = 'LIBRA';
    } else if (_selectedUnit == 'Saco') {
      mappedUnit = 'SACO';
    } else if (_selectedUnit == 'Caja') {
      mappedUnit = 'CAJA';
    } else {
      mappedUnit = 'UNIDAD';
    }

    final cartProduct = {
      ...widget.product,
      'unit': mappedUnit, // Send mapped unit
    };
    
    // We add it repeatedly _quantity times, or directly add with quantity if addToCart supports it.
    // The current addToCart just adds 1 by default, but we can call it multiple times for simplicity,
    // or modify addToCart. Let's assume we can just add the raw product and it will add 1.
    // Actually, in global_state.dart `addToCart` ignores incoming quantity and sets it to 1.
    // To support quantity, we'd need to modify `addToCart`.
    // For now, we call it multiple times.
    for (int i = 0; i < _quantity; i++) {
      addToCart(cartProduct);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              '$_quantity agregado(s) al carrito',
              style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF00462f),
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
    final String image = widget.product['image'] ?? widget.product['img'] ?? 'https://via.placeholder.com/400';
    final String priceStr = widget.product['price'] ?? '\$0.00';
    final double basePrice = double.tryParse(priceStr.replaceAll('\$', '')) ?? 0.0;
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

    // Dummy multiple images if none provided
    final List<String> images = [image, image, image];

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
                                  child: CachedNetworkImage(
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
                      // Category
                      Text(
                        category,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: subtitleColor,
                          fontWeight: FontWeight.w600,
                          height: 1.0,
                        ),
                      ),
                      // Title
                      Text(
                        name,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 24,
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 6),
                      ShakeWidget(
                        key: _shakeKey,
                        child: Text(
                          'Mín. ${_getUnitLimits(_selectedUnit)['min']} | Máx. ${_getUnitLimits(_selectedUnit)['max']}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: subtitleColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
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
                          const Spacer(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // Unit Chips
                              Row(
                                children: _availableUnits.map((unit) {
                                  final isSelected = _selectedUnit == unit;
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
                                        color: isSelected ? primary : (isDark ? Colors.grey[800] : const Color(0xFFe9eceb)),
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
                        'Precio Total',
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
                          color: primary,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: primary.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 20),
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
                    child: CachedNetworkImage(
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
