import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/global_state.dart';
import '../widgets/animated_favorite_button.dart';
import '../widgets/skeleton_loading.dart';
import '../widgets/quality_info_bottom_sheet.dart';
import '../widgets/supplier_quick_view_bottom_sheet.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> with TickerProviderStateMixin {
  String _selectedCategory = 'Todos';
  String _selectedQuality = 'Todas';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  final Map<String, String> _selectedProductModes = {};

  final List<String> categories = ['Todos', 'Frutas', 'Verduras', 'Lácteos'];
  final List<String> qualities = ['Todas', 'Primera calidad', 'Segunda calidad', 'Tercera calidad'];

  @override
  void initState() {
    super.initState();
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
    _searchController.dispose();
    super.dispose();
  }

  String _getProductSku(Map<String, dynamic> item) {
    if (item['sku'] != null && item['sku'].toString().trim().isNotEmpty) {
      return item['sku'].toString().trim();
    }
    final name = (item['name'] ?? 'PROD').toString().replaceAll(' ', '').toUpperCase();
    final nameCode = name.length >= 3 ? name.substring(0, 3) : name.padRight(3, 'X');
    final cat = (item['category'] ?? 'GEN').toString().replaceAll(' ', '').toUpperCase();
    final catCode = cat.length >= 3 ? cat.substring(0, 3) : cat.padRight(3, 'X');
    return '$catCode-$nameCode-01';
  }

  List<Map<String, dynamic>> _getFilteredProducts(List<Map<String, dynamic>> allFavorites) {
    return allFavorites.where((product) {
      final matchesCategory = _selectedCategory == 'Todos' || product['category'] == _selectedCategory;
      final matchesQuality = _selectedQuality == 'Todas' || product['quality'] == _selectedQuality;
      final sku = (product['sku'] ?? _getProductSku(product)).toString().toLowerCase();
      final matchesSearch = product['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
                            product['supplier'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
                            sku.contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesQuality && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final bgColor = isDark ? const Color(0xFF0f231d) : const Color(0xFFf5f8f7);
    final surfaceColor = isDark ? const Color(0xFF1f2937) : Colors.white;
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, surfaceColor, primaryColor),
            _buildSearchAndFilters(surfaceColor, primaryColor, isDark),
            Expanded(
              child: ValueListenableBuilder<List<Map<String, dynamic>>>(
                valueListenable: globalFavorites,
                builder: (context, favoritesList, child) {
                  if (_isLoading) {
                    return GridView.builder(
                      padding: const EdgeInsets.only(left: 14, right: 14, top: 14, bottom: 120),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 12,
                        mainAxisExtent: 300,
                      ),
                      itemCount: 4,
                      itemBuilder: (context, index) {
                        return const SkeletonGridProductCard();
                      },
                    );
                  }

                  final filteredList = _getFilteredProducts(favoritesList);
                  
                  if (filteredList.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.heart_broken, size: 48, color: Colors.grey.withValues(alpha: 0.5)),
                          const SizedBox(height: 16),
                          const Text('No hay favoritos en esta categoría', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    );
                  }
                  
                  return GridView.builder(
                    padding: const EdgeInsets.only(left: 14, right: 14, top: 14, bottom: 120),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 12,
                      mainAxisExtent: 300,
                    ),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      return _buildProductCard(
                        context: context,
                        theme: theme,
                        surfaceColor: surfaceColor,
                        primaryColor: primaryColor,
                        isDark: isDark,
                        data: filteredList[index],
                      );
                    },
                  );
                }
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color surfaceColor, Color primaryColor) {
    return Container(
      color: surfaceColor,
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: primaryColor),
            style: IconButton.styleFrom(
              backgroundColor: Colors.transparent, // match transparent design logic as discussed for other back buttons
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/home');
              }
            },
          ),
          const Text(
            'Mis Favoritos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(width: 48), // matching width of IconButton for true center
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters(Color surfaceColor, Color primaryColor, bool isDark) {
    return Container(
      color: surfaceColor,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Buscar en mis favoritos',
                hintStyle: TextStyle(color: primaryColor.withValues(alpha: 0.4)),
                prefixIcon: Icon(Icons.search, color: primaryColor.withValues(alpha: 0.6)),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = category == _selectedCategory;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: isSelected ? primaryColor : primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: isSelected
                          ? [BoxShadow(color: primaryColor.withValues(alpha: 0.2), blurRadius: 4, offset: const Offset(0, 2))]
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      category,
                      style: TextStyle(
                        color: isSelected ? Colors.white : primaryColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: qualities.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final quality = qualities[index];
                final isSelected = quality == _selectedQuality;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedQuality = quality;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.orange.shade700 : Colors.orange.shade700.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isSelected ? Colors.transparent : Colors.orange.shade700.withValues(alpha: 0.3),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isSelected) const Icon(Icons.check, size: 14, color: Colors.white),
                        if (isSelected) const SizedBox(width: 4),
                        Text(
                          quality,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.orange.shade700,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
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
    );
  }

  void _runFlyToCartAnimation(BuildContext itemContext, Map<String, dynamic> data) {
    final RenderBox? renderBox = itemContext.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final Offset startPosition = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;
    
    final Size screenSize = MediaQuery.of(itemContext).size;
    // Proximate cart icon in bottom nav bar
    final Offset endPosition = Offset(screenSize.width * 0.35, screenSize.height - 40);

    final overlay = Overlay.of(itemContext);
    late OverlayEntry overlayEntry;
    
    AnimationController controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    Animation<Offset> positionAnimation = Tween<Offset>(
      begin: startPosition,
      end: endPosition,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOutCubic,
    ));

    Animation<double> scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeIn,
    ));

    overlayEntry = OverlayEntry(
      builder: (context) {
        return AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            return Positioned(
              left: positionAnimation.value.dx,
              top: positionAnimation.value.dy,
              child: Transform.scale(
                scale: scaleAnimation.value,
                child: Material(
                  color: Colors.transparent,
                  elevation: 12,
                  borderRadius: BorderRadius.circular(16),
                  clipBehavior: Clip.antiAlias,
                  child: Container(
                    width: size.width,
                    height: size.height,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 120,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(data['image'] ?? 'https://via.placeholder.com/150'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        // Just an empty colored block to mimic card shape without complex rendering
                        Expanded(child: Container(color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    overlay.insert(overlayEntry);
    controller.forward().then((_) {
      overlayEntry.remove();
      controller.dispose();
      
      addToCart(data);
      
      ScaffoldMessenger.of(itemContext).clearSnackBars();
      ScaffoldMessenger.of(itemContext).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.shopping_cart_checkout, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              const Expanded(child: Text('Agregado al carrito exitosamente', style: TextStyle(fontWeight: FontWeight.bold))),
            ],
          ),
          backgroundColor: const Color(0xFF016142),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
    });
  }

  Widget _buildProductImage(String? src) {
    final imgSrc = (src != null && src.isNotEmpty) ? src : 'https://via.placeholder.com/400';
    if (imgSrc.startsWith('assets/')) {
      return Image.asset(
        imgSrc,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[200]),
      );
    }
    return Image.network(
      imgSrc,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[200]),
    );
  }

  Widget? _buildSalesModeBadge(
    String? salesMode,
    ThemeData theme,
    bool isDark, {
    required String productName,
  }) {
    if (salesMode == null) return null;

    if (salesMode == 'both') {
      final currentMode = _selectedProductModes[productName] ?? 'retail';
      final bool isRetailSelected = currentMode == 'retail';
      final bool isWholesaleSelected = currentMode == 'wholesale';

      return Container(
        padding: const EdgeInsets.all(1.5),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF111827) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
            width: 0.8,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedProductModes[productName] = 'retail';
                  });
                },
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 2.5),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isRetailSelected
                        ? (isDark ? const Color(0xFF047857) : const Color(0xFF059669))
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Text(
                      'Detalle',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        color: isRetailSelected
                            ? Colors.white
                            : (isDark ? Colors.grey[400] : Colors.grey[600]),
                        fontSize: 9.5,
                        fontWeight: isRetailSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 2),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedProductModes[productName] = 'wholesale';
                  });
                },
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 2.5),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isWholesaleSelected
                        ? (isDark ? const Color(0xFF0284C7) : const Color(0xFF0369A1))
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Text(
                      'Por Mayor',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        color: isWholesaleSelected
                            ? Colors.white
                            : (isDark ? Colors.grey[400] : Colors.grey[600]),
                        fontSize: 9.5,
                        fontWeight: isWholesaleSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final bool isRetailOnly = salesMode == 'retail_only' || salesMode == 'retail';
    final String label = isRetailOnly ? 'Solo al Detalle' : 'Solo por Mayor';
    final IconData icon = isRetailOnly ? Icons.shopping_bag_outlined : Icons.inventory_2_outlined;

    final Color bgColor = isRetailOnly
        ? (isDark ? const Color(0xFF064E3B).withValues(alpha: 0.35) : const Color(0xFFECFDF5))
        : (isDark ? const Color(0xFF075985).withValues(alpha: 0.35) : const Color(0xFFF0F9FF));
    final Color borderColor = isRetailOnly
        ? (isDark ? const Color(0xFF059669).withValues(alpha: 0.4) : const Color(0xFFA7F3D0))
        : (isDark ? const Color(0xFF0284C7).withValues(alpha: 0.4) : const Color(0xFFBAE6FD));
    final Color textColor = isRetailOnly
        ? (isDark ? const Color(0xFF6EE7B7) : const Color(0xFF047857))
        : (isDark ? const Color(0xFF7DD3FC) : const Color(0xFF0369A1));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: borderColor, width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: textColor),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.1,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard({
    required BuildContext context,
    required ThemeData theme,
    required Color surfaceColor,
    required Color primaryColor,
    required bool isDark,
    required Map<String, dynamic> data,
  }) {
    final String productName = data['name'] ?? '';
    final String qualityStr = (data['quality'] ?? data['badge'] ?? 'Primera Calidad').toString();
    final String lowerQuality = qualityStr.toLowerCase();
    Color badgeColor = primaryColor;
    if (lowerQuality.contains('segunda')) {
      badgeColor = const Color(0xFFFF8A5B);
    } else if (lowerQuality.contains('tercera')) {
      badgeColor = Colors.red[400]!;
    }

    final salesMode = data['salesMode'] ?? 'both';
    final currentMode = (salesMode == 'both')
        ? (_selectedProductModes[productName] ?? 'retail')
        : (salesMode == 'wholesale_only' ? 'wholesale' : 'retail');
    final bool isWholesale = currentMode == 'wholesale';

    final String displayPrice = isWholesale
        ? (data['wholesalePrice'] ?? data['price'] ?? '\$16.50')
        : (data['price'] ?? '\$22.50');

    final String displayUnitText;
    if (isWholesale) {
      displayUnitText = data['wholesaleMin'] != null
          ? 'por mayor (${data['wholesaleMin'].toString().toLowerCase()})'
          : 'por mayor';
    } else {
      final u = (data['unit'] ?? 'kilo').toString().toLowerCase().trim();
      displayUnitText = u.startsWith('por ') ? u : 'por $u';
    }

    final salesBadge = _buildSalesModeBadge(
      salesMode,
      theme,
      isDark,
      productName: productName,
    );

    final itemForDetail = {
      ...data,
      'salesMode': salesMode,
      'saleType': isWholesale ? 'mayor' : 'detalle',
      'selectedMode': currentMode,
    };

    final String supplierStr = data['supplier'] ?? 'Don Pedro H.';
    final String locationStr = data['location'] ?? 'Tecomán, Colima';
    final String? discount = data['discount'];

    return GestureDetector(
      onTap: () => context.push('/product_detail', extra: itemForDetail),
      child: Container(
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.grey[800]! : const Color(0xFFE2E8F0),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Top Image Stack
            Stack(
              children: [
                SizedBox(
                  height: 105,
                  width: double.infinity,
                  child: _buildProductImage(data['image'] ?? data['img']),
                ),
                // Top-Left Discount Pill
                if (discount != null && discount.isNotEmpty)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.bolt, color: Colors.amber, size: 11),
                          const SizedBox(width: 2),
                          Text(
                            discount,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                // Top-Right Floating Heart Button
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: AnimatedFavoriteButton(
                      isFavorite: true,
                      size: 16,
                      onTap: () {
                        toggleFavorite(data);
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Eliminado de favoritos: $productName'),
                            backgroundColor: Colors.red[600],
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // Bottom-Right Verified Badge
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(3.5),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 3),
                      ],
                    ),
                    child: const Icon(
                      Icons.verified,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ),
              ],
            ),

            // 2. Card Content Body
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      productName,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        height: 1.15,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 1),
                    // SKU
                    Text(
                      'SKU: ${_getProductSku(data)}',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 8.5,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.grey.shade400 : const Color(0xFF94A3B8),
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Sales Mode Switcher [ Detalle | Por Mayor ]
                    ?salesBadge,
                    const SizedBox(height: 4),

                    // Metadata Row 1: CALIDAD
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => QualityInfoBottomSheet(quality: qualityStr),
                        );
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Row(
                        children: [
                          Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: badgeColor.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.workspace_premium, color: badgeColor, size: 11),
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'CALIDAD',
                                  style: TextStyle(
                                    fontSize: 7.5,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                    letterSpacing: 0.3,
                                    height: 1.0,
                                  ),
                                ),
                                Text(
                                  qualityStr.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: badgeColor,
                                    height: 1.1,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 3),

                    // Metadata Row 2: PROVEEDOR
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => SupplierQuickViewBottomSheet(supplierData: data),
                        );
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Row(
                        children: [
                          Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.local_florist, color: primaryColor, size: 11),
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'PROVEEDOR',
                                  style: TextStyle(
                                    fontSize: 7.5,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                    letterSpacing: 0.3,
                                    height: 1.0,
                                  ),
                                ),
                                Text(
                                  supplierStr,
                                  style: const TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    height: 1.1,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 3),

                    // Metadata Row 3: UBICACIÓN
                    Row(
                      children: [
                        Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey[800] : Colors.grey[200],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.location_on,
                            color: isDark ? Colors.grey[300] : Colors.grey[700],
                            size: 11,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'UBICACIÓN',
                                style: TextStyle(
                                  fontSize: 7.5,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                  letterSpacing: 0.3,
                                  height: 1.0,
                                ),
                              ),
                              Text(
                                locationStr,
                                style: TextStyle(
                                  fontSize: 9,
                                  color: isDark ? Colors.grey[300] : Colors.grey[700],
                                  height: 1.1,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    // Price & Unit
                    SizedBox(
                      width: double.infinity,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        child: SizedBox(
                          key: ValueKey<String>('$displayPrice-$displayUnitText'),
                          width: double.infinity,
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: displayPrice,
                                  style: TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w900,
                                    color: isWholesale
                                        ? (isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7))
                                        : primaryColor,
                                  ),
                                ),
                                TextSpan(
                                  text: ' / $displayUnitText',
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
                                    letterSpacing: 0.1,
                                  ),
                                ),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),

                    // Action Button
                    Builder(
                      builder: (btnContext) {
                        return ValueListenableBuilder<List<Map<String, dynamic>>>(
                          valueListenable: globalCart,
                          builder: (context, cart, child) {
                            final bool inCart = isInCart(itemForDetail);
                            return SizedBox(
                              width: double.infinity,
                              height: 30,
                              child: ElevatedButton.icon(
                                onPressed: inCart
                                    ? null
                                    : () {
                                        _runFlyToCartAnimation(btnContext, itemForDetail);
                                      },
                                icon: Icon(inCart ? Icons.check : Icons.shopping_cart_outlined, size: 12),
                                label: Text(
                                  inCart ? 'EN EL CARRITO' : 'AGREGAR AL CARRITO',
                                  style: const TextStyle(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  disabledBackgroundColor: isDark ? Colors.grey[800] : Colors.grey[300],
                                  disabledForegroundColor: isDark ? Colors.grey[500] : Colors.grey[600],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 0,
                                ),
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
          ],
        ),
      ),
    );
  }
}
