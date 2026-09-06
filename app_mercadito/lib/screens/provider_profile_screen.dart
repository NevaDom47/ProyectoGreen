import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/skeleton_loading.dart';
import '../widgets/animated_favorite_button.dart';
import '../widgets/quality_info_bottom_sheet.dart';
import '../data/global_state.dart';

class ProviderProfileScreen extends StatefulWidget {
  final Map<String, dynamic> provider;

  const ProviderProfileScreen({super.key, required this.provider});

  @override
  State<ProviderProfileScreen> createState() => _ProviderProfileScreenState();
}

class _ProviderProfileScreenState extends State<ProviderProfileScreen> with TickerProviderStateMixin {
  bool _isLoading = true;
  final Map<String, String> _selectedProductModes = {};

  @override
  void initState() {
    super.initState();
    // Simulate initial load for Skeleton effect
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0f231d) : const Color(0xFFf5f8f7),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: _isLoading 
            ? _buildSkeletonLoader(context)
            : DefaultTabController(
                length: 3,
                child: NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) {
                    return [
                      // Header Section (Banner, Top Nav, and overlapping Avatar)
                      SliverToBoxAdapter(
                        child: Column(
                          children: [
                            Stack(
                              clipBehavior: Clip.none,
                              alignment: Alignment.bottomCenter,
                              children: [
                                // Banner
                                _EntranceAnimation(
                                  delay: 0,
                                  child: Container(
                                    height: 240,
                                    margin: const EdgeInsets.only(bottom: 50),
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.only(
                                        bottomLeft: Radius.circular(32),
                                        bottomRight: Radius.circular(32),
                                      ),
                                      image: DecorationImage(
                                        image: NetworkImage(widget.provider['banner'] ?? widget.provider['img'] ?? ''),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                                // Dark gradient overlay
                                Positioned(
                                  top: 0, left: 0, right: 0, height: 100,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(32),
                                        bottomRight: Radius.circular(32),
                                      ),
                                      gradient: LinearGradient(
                                        colors: [Colors.black54, Colors.transparent],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                    ),
                                  ),
                                ),
                                // Top Navigation
                                Positioned(
                                  top: 16, left: 16, right: 16,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: Colors.white,
                                        child: IconButton(
                                          icon: const Icon(Icons.arrow_back, color: Colors.black),
                                          onPressed: () => context.pop(),
                                        ),
                                      ),
                                      const Text(
                                        'Proveedor',
                                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                                      ),
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: Colors.white,
                                            child: IconButton(
                                              icon: const Icon(Icons.verified, color: Colors.blue),
                                              onPressed: () {},
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          ValueListenableBuilder<List<Map<String, dynamic>>>(
                                            valueListenable: globalFavoriteProviders,
                                            builder: (context, favorites, child) {
                                              final isFav = isFavoriteProvider(widget.provider['name'] ?? '');
                                              return AnimatedFavoriteButton(
                                                isFavorite: isFav,
                                                size: 24,
                                                onTap: () {
                                                  toggleFavoriteProvider(widget.provider);
                                                  ScaffoldMessenger.of(context).clearSnackBars();
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        isFav 
                                                          ? 'Eliminado de favoritos' 
                                                          : 'Agregado a favoritos',
                                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                                      ),
                                                      backgroundColor: isFav ? Colors.red : theme.colorScheme.primary,
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
                                    ],
                                  ),
                                ),
                                // Square Profile Avatar
                                Positioned(
                                  bottom: 0,
                                  child: _EntranceAnimation(
                                    delay: 200,
                                    type: EntranceType.scale,
                                    child: Hero(
                                      tag: widget.provider['name'],
                                      child: Container(
                                        width: 100,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          color: isDark ? const Color(0xFF0f231d) : Colors.white,
                                          borderRadius: BorderRadius.circular(16),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.1),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                          image: (widget.provider['img']?.toString().isNotEmpty == true)
                                              ? DecorationImage(
                                                  image: NetworkImage(widget.provider['img'] ?? ''),
                                                  fit: BoxFit.cover,
                                                )
                                              : null,
                                        ),
                                        child: (widget.provider['img']?.toString().isNotEmpty != true)
                                            ? Icon(
                                                Icons.storefront,
                                                size: 48,
                                                color: isDark ? const Color(0xFF89d6b0) : const Color(0xFF00462f),
                                              )
                                            : null,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            // Provider Info
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: Column(
                                children: [
                                  _EntranceAnimation(
                                    delay: 300,
                                    child: Text(widget.provider['name'] ?? '', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                                  ),
                                  const SizedBox(height: 4),
                                  _EntranceAnimation(
                                    delay: 400,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.location_on, size: 16, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Text(widget.provider['distance'] ?? '', style: const TextStyle(color: Colors.grey)),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 8),
                                  _EntranceAnimation(
                                    delay: 500,
                                    child: Text(
                                      widget.provider['tags'] ?? '',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: theme.colorScheme.primary,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  _EntranceAnimation(
                                    delay: 550,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: isDark ? const Color(0xFF16251E) : const Color(0xFFEAF2E8),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: isDark ? const Color(0xFF23352B) : theme.colorScheme.primary.withValues(alpha: 0.2),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.sell_outlined,
                                            size: 14,
                                            color: isDark ? const Color(0xFF8BD8B2) : theme.colorScheme.primary,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            widget.provider['salesType'] ?? 'Al Detalle',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: isDark ? const Color(0xFF8BD8B2) : theme.colorScheme.primary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  _EntranceAnimation(
                                    delay: 600,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        _buildStatColumn(Icons.star, widget.provider['rating']?.toString() ?? '4.8', 'Valoración', isIcon: true),
                                        _buildStatColumn(null, widget.provider['traded']?.toString() ?? widget.provider['sales']?.toString() ?? '1,240', 'Ventas'),
                                        _buildStatColumn(null, widget.provider['productsCount']?.toString() ?? '15', 'Productos'),
                                      ],
                                    ),
                                  ),
                                  // Action buttons
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _EntranceAnimation(
                                          delay: 700,
                                          child: ValueListenableBuilder<List<Map<String, dynamic>>>(
                                            valueListenable: globalFollowedSellers,
                                            builder: (context, followedList, child) {
                                              final isFollowing = isFollowingSeller(widget.provider['name'] ?? '');
                                              return ElevatedButton.icon(
                                                onPressed: () {
                                                  toggleFollowSeller(widget.provider);
                                                  ScaffoldMessenger.of(context).clearSnackBars();
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        isFollowing 
                                                          ? 'Dejaste de seguir a ${widget.provider['name']}' 
                                                          : 'Ahora sigues a ${widget.provider['name']}',
                                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                                      ),
                                                      backgroundColor: const Color(0xFF00462f),
                                                      behavior: SnackBarBehavior.floating,
                                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                                      duration: const Duration(seconds: 2),
                                                    ),
                                                  );
                                                },
                                                icon: Icon(
                                                  isFollowing ? Icons.check : Icons.person_add_outlined,
                                                  size: 18,
                                                ),
                                                label: Text(
                                                  isFollowing ? 'Siguiendo' : 'Seguir',
                                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                                ),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: isFollowing
                                                      ? const Color(0xFF00462f)
                                                      : theme.colorScheme.primary.withValues(alpha: 0.1),
                                                  foregroundColor: isFollowing
                                                      ? Colors.white
                                                      : theme.colorScheme.primary,
                                                  elevation: 0,
                                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _EntranceAnimation(
                                          delay: 800,
                                          child: ElevatedButton.icon(
                                            onPressed: () {
                                              context.push('/chat-detail', extra: widget.provider);
                                            },
                                            icon: const Icon(Icons.chat_bubble_outline, size: 18),
                                            label: const Text('Chat', style: TextStyle(fontWeight: FontWeight.bold)),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: theme.colorScheme.primary,
                                              foregroundColor: Colors.white,
                                              elevation: 0,
                                              padding: const EdgeInsets.symmetric(vertical: 12),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                            ),
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
                      ),
                      // TabBar Pinned
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: _SliverAppBarDelegate(
                          tabBar: TabBar(
                            labelColor: theme.colorScheme.primary,
                            unselectedLabelColor: Colors.grey,
                            indicatorColor: theme.colorScheme.primary,
                            indicatorWeight: 3,
                            tabs: const [
                              Tab(text: 'Productos'),
                              Tab(text: 'Reseñas'),
                              Tab(text: 'Información'),
                            ],
                          ),
                          color: isDark ? const Color(0xFF0f231d) : const Color(0xFFf5f8f7),
                        ),
                      ),
                    ];
                  },
                  body: TabBarView(
                    children: [
                      _buildProductsTab(context),
                      _buildReviewsTab(context),
                      _buildInfoTab(context),
                    ],
                  ),
                ),
              ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(IconData? icon, String value, String label, {bool isIcon = false}) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isIcon && icon != null) Icon(icon, color: Colors.amber, size: 16),
            if (isIcon && icon != null) const SizedBox(width: 4),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
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
                          height: 105,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(data['image'] ?? data['img'] ?? 'https://via.placeholder.com/150'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
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

  String _getProductSku(Map<String, dynamic> item) {
    if (item['sku'] != null && item['sku'].toString().isNotEmpty) {
      return item['sku'].toString();
    }
    final name = (item['title'] ?? item['name'] ?? 'PRD').toString();
    final parts = name.split(' ');
    final catCode = parts.isNotEmpty && parts[0].length >= 3
        ? parts[0].substring(0, 3).toUpperCase()
        : 'AGR';
    final subCode = parts.length > 1 && parts[1].length >= 3
        ? parts[1].substring(0, 3).toUpperCase()
        : 'GEN';
    final int hashVal = (name.hashCode.abs() % 90) + 10;
    return '$catCode-$subCode-$hashVal';
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

  Widget _buildProviderProductCard({
    required BuildContext context,
    required ThemeData theme,
    required Color surfaceColor,
    required Color primaryColor,
    required bool isDark,
    required Map<String, dynamic> data,
  }) {
    final String productName = (data['title'] ?? data['name'] ?? '').toString();
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
        ? (data['wholesalePrice'] ?? data['price'] ?? '16.50').toString()
        : (data['price'] ?? '22.50').toString();
    final String displayPriceFormatted = displayPrice.startsWith('\$') ? displayPrice : '\$$displayPrice';

    final String displayUnitText;
    if (isWholesale) {
      displayUnitText = data['wholesaleMin'] != null
          ? 'por mayor (${data['wholesaleMin'].toString().toLowerCase()})'
          : 'por mayor';
    } else {
      final rawUnit = (data['unit'] ?? 'lb').toString().replaceAll('/', '').trim();
      displayUnitText = _formatUnit(rawUnit).toLowerCase();
    }

    final salesBadge = _buildSalesModeBadge(
      salesMode,
      theme,
      isDark,
      productName: productName,
    );

    final itemForDetail = {
      ...data,
      'name': productName,
      'title': productName,
      'price': displayPriceFormatted,
      'unit': displayUnitText,
      'image': data['image'] ?? data['img'],
      'quality': qualityStr,
      'salesMode': salesMode,
      'saleType': isWholesale ? 'mayor' : 'detalle',
      'selectedMode': currentMode,
      'supplier': widget.provider['name'] ?? 'Don Pedro H.',
      'location': widget.provider['location'] ?? 'Tecomán, Colima',
    };

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
                    child: ValueListenableBuilder<List<Map<String, dynamic>>>(
                      valueListenable: globalFavorites,
                      builder: (context, favs, child) {
                        final bool fav = isFavorite(productName);
                        return AnimatedFavoriteButton(
                          isFavorite: fav,
                          size: 16,
                          onTap: () {
                            toggleFavorite(data);
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(fav ? 'Eliminado de favoritos: $productName' : 'Agregado a favoritos: $productName'),
                                backgroundColor: fav ? Colors.red[600] : const Color(0xFF016142),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
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
                    if (salesBadge != null) ...[
                      salesBadge,
                      const SizedBox(height: 4),
                    ],

                    // Metadata Row: CALIDAD
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

                    // Note: PROVEEDOR and UBICACIÓN rows are intentionally omitted
                    // as requested since all products in this screen belong to the provider.
                    const Spacer(),

                    // Price & Unit
                    SizedBox(
                      width: double.infinity,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        child: SizedBox(
                          key: ValueKey<String>('$displayPriceFormatted-$displayUnitText'),
                          width: double.infinity,
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: displayPriceFormatted,
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

  Widget _buildProductsTab(BuildContext context) {
    // Mock data for Primera (4 products)
    final primera = [
      {
        'title': 'Fresas Extra',
        'price': '8.500',
        'unit': 'lb',
        'wholesalePrice': '6.800',
        'wholesaleMin': 'Caja 10 lb',
        'salesMode': 'both',
        'sku': 'FRU-FRE-01',
        'quality': 'Primera Calidad',
        'discount': '-15%',
        'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuCnW6_MorKLz7ezxkGcHG6rQjhSFNPk8HPgeIsUbUJgp9DUy5kB2jUbGf4NDVs02rHGeJ4ro5fC_o-CVgZdBbzfhnoIX6Oz-YBKAMbwvBnKt0DUNJfnQJ-4cR8YhjFg7n2YTsCUja9uRWf099e4MF7xhxHmzFwjLCdCgywatNoUU6oNbjKVFR4AvgIv8s4ecmGAnIR2EtLvlghaKIOjsvzYQBd-K2z9jJ0Zk9LsA0e7JsmFHImz82G7W_vMJG5zDP64iTEgJpRLJF0',
      },
      {
        'title': 'Zanahoria Orgánica',
        'price': '3.200',
        'unit': 'kg',
        'wholesalePrice': '2.400',
        'wholesaleMin': 'Bulto 25 kg',
        'salesMode': 'both',
        'sku': 'RAI-ZAN-02',
        'quality': 'Primera Calidad',
        'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuAUP07pMS-fkGRl_e-A_ksfxKmrKWa-uMZFZ7hvjE42DscxBHwUsx6fScNLD5TRZrw8Uh6fGNy9JYfNt6iISLHMW5-uMUFqybHPkrQwig52Qn0dn7Rix-GwCC_XihkPXq3G1-sGNzsnk3yb8ZB3mcXS7lnPrYUf_ovpd-ND9zD970NSGVKIzVbzFZiEz2lcIUcI03Ezq9NjBZrvVnut5BAKWvqPARC1Cef9NKXci0FArJHZlt8dqNTLc9Zl80YSPAtDKDEH0cl8mEw',
      },
      {
        'title': 'Tomates Premium',
        'price': '2.100',
        'unit': 'lb',
        'wholesalePrice': '1.600',
        'wholesaleMin': 'Caja 20 lb',
        'salesMode': 'both',
        'sku': 'HOR-TOM-03',
        'quality': 'Primera Calidad',
        'image': 'https://images.unsplash.com/photo-1592924357228-91a4daadc239?q=80&w=300&auto=format&fit=crop',
      },
      {
        'title': 'Lechuga Hidropónica',
        'price': '1.500',
        'unit': 'unidad',
        'wholesalePrice': '1.100',
        'wholesaleMin': 'Caja 24 un',
        'salesMode': 'both',
        'sku': 'HOR-LEC-04',
        'quality': 'Primera Calidad',
        'image': 'https://images.unsplash.com/photo-1622206151226-18ca2c9ab4a1?q=80&w=300&auto=format&fit=crop',
      },
    ];
    // Mock data for Segunda (2 products)
    final segunda = [
      {
        'title': 'Fresa Mediana',
        'price': '5.500',
        'unit': 'lb',
        'wholesalePrice': '4.200',
        'wholesaleMin': 'Caja 10 lb',
        'salesMode': 'both',
        'sku': 'FRU-FRE-05',
        'quality': 'Segunda Calidad',
        'image': 'https://images.unsplash.com/photo-1464965911861-746a04b4bca6?q=80&w=300&auto=format&fit=crop',
      },
      {
        'title': 'Zanahoria Estándar',
        'price': '2.000',
        'unit': 'kg',
        'wholesalePrice': '1.500',
        'wholesaleMin': 'Bulto 25 kg',
        'salesMode': 'both',
        'sku': 'RAI-ZAN-06',
        'quality': 'Segunda Calidad',
        'image': 'https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?q=80&w=300&auto=format&fit=crop',
      },
    ];
    // Mock data for Tercera (2 products)
    final tercera = [
      {
        'title': 'Hortalizas para Caldo',
        'price': '2.000',
        'unit': 'atado',
        'wholesalePrice': '1.400',
        'wholesaleMin': 'Atado x10',
        'salesMode': 'both',
        'sku': 'HOR-CAL-07',
        'quality': 'Tercera Calidad',
        'image': 'https://images.unsplash.com/photo-1601648764658-cf37e8c89b70?q=80&w=300&auto=format&fit=crop',
      },
      {
        'title': 'Tomate para Guiso',
        'price': '1.000',
        'unit': 'lb',
        'wholesalePrice': '750',
        'wholesaleMin': 'Caja 25 lb',
        'salesMode': 'both',
        'sku': 'HOR-TOM-08',
        'quality': 'Tercera Calidad',
        'image': 'https://images.unsplash.com/photo-1518977676601-b53f82aba655?q=80&w=300&auto=format&fit=crop',
      },
    ];

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      children: [
        _buildSection(context, 'Calidad: Primera', 'PRIMERA', primera, isPrimera: true),
        const SizedBox(height: 24),
        _buildSection(context, 'Calidad: Segunda', 'SEGUNDA', segunda, isSegunda: true),
        const SizedBox(height: 24),
        _buildSection(context, 'Calidad: Tercera', 'TERCERA', tercera, isTercera: true),
      ],
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    String badgeText,
    List<Map<String, dynamic>> items, {
    bool isPrimera = false,
    bool isSegunda = false,
    bool isTercera = false,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Header
    Widget header = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isPrimera 
                    ? theme.colorScheme.primary.withValues(alpha: 0.1)
                    : isSegunda 
                        ? const Color(0xFFFF8A5B).withValues(alpha: 0.15) // Mamey
                        : Colors.red.withValues(alpha: 0.1), // Tercera/Red
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                badgeText, 
                style: TextStyle(
                  fontSize: 10, 
                  fontWeight: FontWeight.bold, 
                  color: isPrimera 
                      ? theme.colorScheme.primary 
                      : isSegunda 
                          ? const Color(0xFFFF8A5B) // Mamey
                          : Colors.red[700] // Tercera/Red
                )
              ),
            ),
            const SizedBox(width: 4),
            TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () {},
              child: Text('Ver todo', style: TextStyle(color: theme.colorScheme.primary, fontSize: 12, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ],
    );

    // List of items in 2 columns
    Widget content = GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 12,
        mainAxisExtent: 268,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final p = items[index];
        final defaultQuality = isPrimera ? 'Primera Calidad' : (isSegunda ? 'Segunda Calidad' : 'Tercera Calidad');
        return _EntranceAnimation(
          delay: 200 + (index * 100),
          child: _buildProviderProductCard(
            context: context,
            theme: theme,
            surfaceColor: isDark ? const Color(0xFF1a2f26) : Colors.white,
            primaryColor: theme.colorScheme.primary,
            isDark: isDark,
            data: {
              ...p,
              'quality': p['quality'] ?? defaultQuality,
              'supplier': widget.provider['name'] ?? 'Don Pedro H.',
              'location': widget.provider['location'] ?? 'Tecomán, Colima',
            },
          ),
        );
      },
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _EntranceAnimation(delay: 100, child: header),
        const SizedBox(height: 16),
        content,
      ],
    );
  }

  Widget _buildInfoTab(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF1a2f26) : Colors.white;
    final borderColor = Colors.grey.withValues(alpha: 0.1);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      children: [
        // Sobre el Vendedor
        _EntranceAnimation(
          delay: 100,
          child: Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.local_florist_outlined, color: theme.colorScheme.primary, size: 20),
                    const SizedBox(width: 8),
                    Text('SOBRE EL VENDEDOR', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: theme.colorScheme.primary, letterSpacing: 1.0)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Granja El Sol cuenta con más de 20 años cultivando productos orgánicos en el corazón del Valle de Santiago. Nuestro compromiso con la frescura comienza al amanecer; cada hortaliza es recolectada a mano solo horas antes de llegar a su mesa. Creemos en una agricultura regenerativa que respeta los ciclos de la tierra y garantiza el sabor más auténtico de nuestra región.',
                  style: TextStyle(fontSize: 14, height: 1.5, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),

        // Contacto
        _EntranceAnimation(
          delay: 200,
          child: Container(
             padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Row(
                  children: [
                    Icon(Icons.call_outlined, color: theme.colorScheme.primary, size: 20),
                    const SizedBox(width: 8),
                     Text('CONTACTO', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: theme.colorScheme.primary, letterSpacing: 1.0)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                     Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         const Text('TELÉFONO DIRECTO', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.0)),
                         const SizedBox(height: 4),
                         const Text('+52 464 123 4567', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                       ],
                     ),
                       ElevatedButton.icon(
                         onPressed: () {},
                         icon: const Icon(Icons.chat, size: 16),
                         label: const Text('WHATSAPP', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.0)),
                         style: ElevatedButton.styleFrom(
                           backgroundColor: const Color(0xFF25D366),
                           foregroundColor: Colors.white,
                           elevation: 2,
                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                           minimumSize: Size.zero, 
                         ),
                       )
                  ],
                )
              ],
            )
          ),
        ),

        // Horarios
        _EntranceAnimation(
          delay: 300,
          child: Container(
             padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Row(
                  children: [
                    Icon(Icons.schedule, color: theme.colorScheme.primary, size: 20),
                    const SizedBox(width: 8),
                     Text('HORARIOS DE ATENCIÓN', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: theme.colorScheme.primary, letterSpacing: 1.0)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Lunes a Sábado', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('8:00 AM - 6:00 PM', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                    )
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Domingo', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[800] : Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('Cerrado', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                    )
                  ],
                ),
              ]
            )
          ),
        ),

        // Ubicación
        _EntranceAnimation(
          delay: 400,
          child: Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Row(
                  children: [
                    Icon(Icons.location_on_outlined, color: theme.colorScheme.primary, size: 20),
                    const SizedBox(width: 8),
                     Text('UBICACIÓN', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: theme.colorScheme.primary, letterSpacing: 1.0)),
                  ],
                ),
                const SizedBox(height: 12),
                const Text('Valle de Santiago, Guanajuato, México', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                     height: 180,
                     width: double.infinity,
                     child: Stack(
                       fit: StackFit.expand,
                       children: [
                          Image.network(
                            'https://lh3.googleusercontent.com/aida-public/AB6AXuBH7ADNB7QWvMbN33Gx_W3uAMM3kyaKNjbiBTi1fY3Sn5QlGIUG7Lfu93jpSklUVHqVn9uWyJrx-O7Kv6qwOzpFHvmeyi3gawpEQwgNo2qSJbINr_vDd-vX_eE51dy0VfjPJUd1hgMeFx3PKMmbJR4ZnDfevwnVv7g35h1NEG9lbvS3pvrQEruRanSbBeuKqi2unhwDtla0oV5ax8sxFHalcNqmYnSU_DgmqPp4VKU-sV1aO6TCrCo8PLcifbWHmKz8OaKVV_IyH7o',
                            fit: BoxFit.cover,
                          ),
                          Container(color: Colors.black.withValues(alpha: 0.1)),
                          const Center(child: Icon(Icons.location_on, color: Colors.red, size: 40)),
                          Positioned(
                            bottom: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                 color: isDark ? Colors.grey[900]!.withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.8),
                                 borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.open_in_new, size: 20, color: isDark ? Colors.white : Colors.black54),
                            )
                          )
                       ],
                     )
                  ),
                )
              ]
            )
          ),
        ),

        // Report
        _EntranceAnimation(
          delay: 500,
          child: Center(
            child: TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.report_outlined, size: 16, color: Colors.grey),
              label: const Text('REPORTAR VENDEDOR', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.5)),
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  String _formatUnit(String unit) {
    var raw = unit.replaceAll('/', '').toLowerCase();
    switch (raw) {
      case 'lb':
        return 'Por Libra';
      case 'kg':
        return 'Por Kilo';
      case 'unidad':
        return 'Por Unidad';
      case 'atado':
        return 'Por Atado';
      case 'caja':
        return 'Por Caja';
      case 'saco':
      case 'sacos':
        return 'Por Saco';
      default:
        // Capitalize first letter
        if (raw.isNotEmpty) {
          raw = raw[0].toUpperCase() + raw.substring(1);
        }
        return 'Por $raw';
    }
  }

  Widget _buildReviewsTab(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      children: [
        _EntranceAnimation(
          delay: 100,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Big Score (col-span-5 equivalent)
                Expanded(
                  flex: 5,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1a2f26) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('4.8', style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: theme.colorScheme.primary, height: 1.0)),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.star, color: theme.colorScheme.primary, size: 14),
                            Icon(Icons.star, color: theme.colorScheme.primary, size: 14),
                            Icon(Icons.star, color: theme.colorScheme.primary, size: 14),
                            Icon(Icons.star, color: theme.colorScheme.primary, size: 14),
                            Icon(Icons.star_half, color: theme.colorScheme.primary, size: 14),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text('128 RESEÑAS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.5)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Star Bars (col-span-7 equivalent)
                Expanded(
                  flex: 7,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0f231d) : const Color(0xFFf1f4f0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildStarBar(5, 0.85, theme),
                        const SizedBox(height: 8),
                        _buildStarBar(4, 0.10, theme),
                        const SizedBox(height: 8),
                        _buildStarBar(3, 0.03, theme),
                        const SizedBox(height: 8),
                        _buildStarBar(2, 0.01, theme),
                        const SizedBox(height: 8),
                        _buildStarBar(1, 0.01, theme),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Filters
        _EntranceAnimation(
          delay: 200,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('MÁS RECIENTES', true, theme),
                _buildFilterChip('CON FOTOS', false, theme),
                _buildFilterChip('ALTA CALIFICACIÓN', false, theme),
                _buildFilterChip('BAJA CALIFICACIÓN', false, theme),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Reviews List
        _EntranceAnimation(
          delay: 300,
          child: _buildReviewCard(
            context: context,
            name: 'Mariana Ortiz',
            date: 'hace 2 días',
            avatar: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBYJzD8Jv__HCofoE_9GXHz6ThLuAmE4GY780JgKF_CnF0e0Ag7eeBdUuo91rwB6Zu0SQvC0ZQxHfm-2ptRUB-8M06caS-RMrBIzj8QHpqkj5QX6vhBO9445gMwzqiu6Yt5juCbYloMuTe9AcbgO7tyDHdemyOCuU_oA7_LQpePOm4X00XfFhNY8SIY-x6DalOZ5-JMFeO2FTK_BoTu-2i9_A-FY9mHZui7BXNQCnwMBtaGINBTm0JmtYFeZAcAz2D5DX2EJlMSLnM',
            rating: 5,
            text: 'Los tomates llegaron frescos y a tiempo, excelente proveedor. La calidad es mucho mejor que la del supermercado tradicional.',
            images: [
              'https://lh3.googleusercontent.com/aida-public/AB6AXuBfAcdyVzjhfvN9bCOWgt1hQ64s4Hx-8jspVL2MsfJBefubpqPK10mJ5FHQdP5Asyxm_lL7ms8LgpEJZGwsf2ZkdV4H4QrFNK2fHOwcS3YMV_sc0UV-Z5tUSuho5AC1mK6ZN6CMLzpeJ-5DZPw5NDktO7wbqmNGnx0eioi__Is31kw3J_xbksGQjIt34jambbxhRB2oPS0BqU7HyozLkQPRfmQZxNHC4dkqvqe3-v5uil4IMQ8z8oAn23hB4ElnFsNIxIqyJaQWwdY',
              'https://lh3.googleusercontent.com/aida-public/AB6AXuCEBY6N0chL89FL7-rhhhwW_ggemOEv9BIecv0foRE0qNYml9czEo9CuAY2boBe2sUVluP7ouBl7Tms3r6vhfCRH1fgbJJRizEBAQLkonmgKyPJq-sUMMExfk9N4NDFzI508xE_Z6BCtPIy2xS4eGiMs64YiDOO0Hzf3YO-OofiyKSH9OB2J0YVUlYawViIAcFqk_1C-X0cbMRW0dIRDvrTRhxKwpugSFoY-vS6v_z0WL3o7HIKur7qd1mA0vbMt1R1j9bQId0Rm30'
            ],
            productBought: 'COMPRÓ: TOMATES SALADETTE',
            sellerResponse: '¡Muchas gracias por tu confianza Mariana! Nos esforzamos por seleccionar siempre lo mejor de la cosecha.',
          ),
        ),
        const SizedBox(height: 16),
        _EntranceAnimation(
          delay: 400,
          child: _buildReviewCard(
            context: context,
            name: 'Roberto G.',
            date: 'hace 1 semana',
            avatar: 'https://lh3.googleusercontent.com/aida-public/AB6AXuC86MsmWl10UM74dTqXN5cvWFEfmYUHsvKCR-y0wD2lYq9QbU1pPOuisx8V-kTEWaa2qDlT0WLBok7LgAyVI4oYfdDfTjkty2sjutfWf8TgR-dczjEg_hjEjyNx_Jt4gpAXDFR7Dgw2FV4_Lhg89Dm7gXQfTgCGY6TtUH9-Gra8NJFrRaoI6KS_t8z3wZKcmelvinox1Ah-7VlOqLa6B1FsrxJQwJPtzLlVN6e8tC5R9kIwziSN6peMLip0X-9igzwYS5lNu2tOSA0',
            rating: 4,
            text: 'Muy buen servicio. El aguacate estaba en su punto exacto. Solo un detalle con el empaque que venía un poco golpeado pero el producto intacto.',
            productBought: 'COMPRÓ: AGUACATE HASS PREMIUM',
          ),
        ),

        const SizedBox(height: 24),
        // Write Review CTA
        Center(
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.edit_note, size: 20),
            label: const Text('ESCRIBIR MI RESEÑA', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 2.0)),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildStarBar(int star, double percentage, ThemeData theme) {
    return Row(
      children: [
        SizedBox(width: 12, child: Text(star.toString(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 6,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(3),
            ),
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: percentage,
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? theme.colorScheme.primary : (theme.brightness == Brightness.dark ? const Color(0xFF1a2f26) : const Color(0xFFf1f4f0)),
        borderRadius: BorderRadius.circular(20),
        border: isSelected ? null : Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.grey[700],
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildReviewCard({
    required BuildContext context,
    required String name,
    required String date,
    required String avatar,
    required int rating,
    required String text,
    List<String>? images,
    required String productBought,
    String? sellerResponse,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1a2f26) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(avatar),
                    radius: 20,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text(date, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
              Row(
                children: List.generate(5, (index) => Icon(
                  index < rating ? Icons.star : Icons.star_border,
                  color: index < rating ? theme.colorScheme.primary : (isDark ? Colors.grey[700] : Colors.grey[300]),
                  size: 14,
                )),
              )
            ],
          ),
          const SizedBox(height: 12),
          // Text
          Text(text, style: TextStyle(fontSize: 14, color: isDark ? Colors.grey[400] : Colors.grey[600], height: 1.5)),
          const SizedBox(height: 12),
          // Images if any
          if (images != null && images.isNotEmpty) ...[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: images.map((img) => Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(img, width: 80, height: 80, fit: BoxFit.cover),
                  ),
                )).toList(),
              ),
            ),
            const SizedBox(height: 12),
          ],
          // Product bought tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0f231d) : const Color(0xFFf1f4f0),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.shopping_basket, size: 12, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(productBought, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
              ],
            ),
          ),
          // Seller Response if any
          if (sellerResponse != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0f231d) : const Color(0xFFebefea),
                borderRadius: BorderRadius.circular(12),
                border: Border(left: BorderSide(color: theme.colorScheme.primary, width: 4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.reply, size: 14, color: theme.colorScheme.primary),
                      const SizedBox(width: 4),
                      Text('RESPUESTA DE EL MERCADITO', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: theme.colorScheme.primary, letterSpacing: 1.0)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(sellerResponse, style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: isDark ? Colors.grey[400] : Colors.grey[600])),
                ],
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildSkeletonLoader(BuildContext context) {
    return SkeletonShimmer(
      child: ListView(
        primary: false,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          // Banner Skeleton
          const SkeletonContainer(
            height: 240,
            width: double.infinity,
            customBorderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -50),
            child: Column(
              children: [
                // Avatar Circle Skeleton
                const SkeletonContainer(
                  width: 100,
                  height: 100,
                  borderRadius: 16,
                ),
                const SizedBox(height: 12),
                // Name Skeleton
                const SkeletonContainer(width: 180, height: 24, borderRadius: 4),
                const SizedBox(height: 8),
                // Subtitle Skeleton
                const SkeletonContainer(width: 120, height: 16, borderRadius: 4),
                const SizedBox(height: 24),
                // Stats Row Skeleton
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(3, (index) => const SkeletonContainer(width: 60, height: 40, borderRadius: 8)),
                ),
                const SizedBox(height: 24),
                // Buttons Skeleton
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Expanded(child: SkeletonContainer(height: 48, borderRadius: 12)),
                      const SizedBox(width: 12),
                      const Expanded(child: SkeletonContainer(height: 48, borderRadius: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum EntranceType { fade, slide, scale }

class _EntranceAnimation extends StatefulWidget {
  final Widget child;
  final int delay;
  final EntranceType type;

  const _EntranceAnimation({
    required this.child,
    required this.delay,
    this.type = EntranceType.slide,
  });

  @override
  State<_EntranceAnimation> createState() => _EntranceAnimationState();
}

class _EntranceAnimationState extends State<_EntranceAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _offset;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.65, curve: Curves.easeOut)),
    );

    _offset = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 1.0, curve: Curves.easeOutQuart)),
    );

    _scale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 1.0, curve: Curves.easeOutBack)),
    );

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: widget.type == EntranceType.scale
          ? ScaleTransition(scale: _scale, child: widget.child)
          : SlideTransition(position: _offset, child: widget.child),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({required this.tabBar, required this.color});

  final TabBar tabBar;
  final Color color;

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: color,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return oldDelegate.color != color || oldDelegate.tabBar != tabBar;
  }
}
