import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/global_state.dart';
import '../widgets/animated_favorite_button.dart';
import '../widgets/skeleton_loading.dart';

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

  List<Map<String, dynamic>> _getFilteredProducts(List<Map<String, dynamic>> allFavorites) {
    return allFavorites.where((product) {
      final matchesCategory = _selectedCategory == 'Todos' || product['category'] == _selectedCategory;
      final matchesQuality = _selectedQuality == 'Todas' || product['quality'] == _selectedQuality;
      final matchesSearch = product['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
                            product['supplier'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
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
                      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 120),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        mainAxisExtent: 320,
                      ),
                      itemCount: 4,
                      itemBuilder: (context, index) {
                        return const SkeletonProductCard(width: double.infinity, height: 320);
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
                    padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 120),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      mainAxisExtent: 320, // Fixed height to fit image, texts, tags and button securely
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

  Widget _buildProductCard({
    required BuildContext context,
    required ThemeData theme,
    required Color surfaceColor,
    required Color primaryColor,
    required bool isDark,
    required Map<String, dynamic> data,
  }) {
    final String badgeStr = (data['quality'] ?? '').toString().toUpperCase();
    final String lowerBadge = badgeStr.toLowerCase();
    Color badgeColor = primaryColor;
    if (lowerBadge.contains('segunda')) {
      badgeColor = Colors.amber[700]!;
    } else if (lowerBadge.contains('tercera')) {
      badgeColor = Colors.red[400]!;
    }

    return GestureDetector(
      onTap: () => context.push('/product_detail', extra: data),
      child: Container(
        decoration: BoxDecoration(
        color: isDark ? primaryColor.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryColor.withValues(alpha: 0.05)),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  data['image'],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[200]),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: AnimatedFavoriteButton(
                  isFavorite: true,
                  size: 18,
                  onTap: () {
                    toggleFavorite(data);
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Eliminado de favoritos'),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (data['quality'] != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        badgeStr,
                        style: TextStyle(
                          color: badgeColor,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  Text(
                    data['name'],
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (data['tags'] != null && (data['tags'] as List).isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: (data['tags'] as List).map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            tag.toString(),
                            style: TextStyle(
                              color: primaryColor,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                data['supplier'],
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: primaryColor.withValues(alpha: 0.7),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.verified, size: 12, color: primaryColor),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, color: Colors.orange, size: 10),
                            const SizedBox(width: 2),
                            Text(
                              data['rating'],
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    data['price'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  Text(
                    data['unit'],
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Builder(
                    builder: (btnContext) {
                      return SizedBox(
                        width: double.infinity,
                        child: ValueListenableBuilder<List<Map<String, dynamic>>>(
                          valueListenable: globalCart,
                          builder: (context, cart, child) {
                            final bool inCart = isInCart(data);
                            return ElevatedButton.icon(
                              onPressed: inCart ? null : () {
                                _runFlyToCartAnimation(btnContext, data);
                              },
                              icon: Icon(inCart ? Icons.check : Icons.shopping_cart, size: 14),
                              label: Text(inCart ? 'Ya en carrito' : 'Agregar', style: const TextStyle(fontSize: 12)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: Colors.grey.shade300,
                                disabledForegroundColor: Colors.grey.shade600,
                                minimumSize: const Size(0, 36),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: inCart ? 0 : 2,
                                shadowColor: primaryColor.withValues(alpha: 0.4),
                              ),
                            );
                          }
                        ),
                      );
                    }
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ));
  }
}
