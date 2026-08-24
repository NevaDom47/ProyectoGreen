import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/global_state.dart';
import '../widgets/animated_discount_badge.dart';
import '../widgets/animated_favorite_button.dart';
import '../widgets/quality_info_bottom_sheet.dart';
import '../widgets/supplier_quick_view_bottom_sheet.dart';

class FlashOffersScreen extends StatefulWidget {
  const FlashOffersScreen({super.key});

  @override
  State<FlashOffersScreen> createState() => _FlashOffersScreenState();
}

class _FlashOffersScreenState extends State<FlashOffersScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedDiscountFilter = 'Todos';
  String _selectedCategoryFilter = 'Todos';

  // Track sales mode per product ('retail' or 'wholesale')
  final Map<String, String> _selectedProductModes = {};

  // Animation controller for screen entrance
  late AnimationController _entranceController;

  @override
  void initState() {
    super.initState();
    startGlobalFlashTimer();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _entranceController.forward();

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredOffers {
    return globalFlashOffers.value.where((offer) {
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();

        final name = (offer['name'] ?? '').toString().toLowerCase();
        final category = (offer['category'] ?? '').toString().toLowerCase();
        final supplier = (offer['supplier'] ?? '').toString().toLowerCase();
        final location = (offer['location'] ?? '').toString().toLowerCase();
        final badge = (offer['badge'] ?? '').toString().toLowerCase();
        final price = (offer['price'] ?? '').toString().toLowerCase();
        final oldPrice = (offer['oldPrice'] ?? '').toString().toLowerCase();
        final wholesalePrice = (offer['wholesalePrice'] ?? '').toString().toLowerCase();
        final discount = (offer['discount'] ?? '').toString().toLowerCase();
        final tags = (offer['tags'] as List? ?? []).map((t) => t.toString().toLowerCase()).join(' ');

        final fullSearchableContent = '$name $category $supplier $location $badge $price $oldPrice $wholesalePrice $discount $tags';

        if (!fullSearchableContent.contains(query)) {
          return false;
        }
      }

      // Discount filter evaluation
      if (_selectedDiscountFilter == '50% OFF') {
        if ((offer['discountNumber'] as int? ?? 0) < 50) return false;
      } else if (_selectedDiscountFilter == '30% OFF') {
        if ((offer['discountNumber'] as int? ?? 0) < 30) return false;
      } else if (_selectedDiscountFilter == '25% OFF') {
        if ((offer['discountNumber'] as int? ?? 0) < 25) return false;
      } else if (_selectedDiscountFilter == '10% OFF') {
        if ((offer['discountNumber'] as int? ?? 0) < 10) return false;
      }

      // Category filter evaluation
      if (_selectedCategoryFilter != 'Todos') {
        final filterLower = _selectedCategoryFilter.toLowerCase();
        final categoryLower = (offer['category'] ?? '').toString().toLowerCase();
        final badgeLower = (offer['badge'] ?? '').toString().toLowerCase();
        final tagsList = (offer['tags'] as List? ?? []).map((t) => t.toString().toLowerCase()).toList();

        final matchesCategory = categoryLower.contains(filterLower) ||
            badgeLower.contains(filterLower) ||
            tagsList.any((t) => t.contains(filterLower));

        if (!matchesCategory) return false;
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8F9FF);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: isDark ? Colors.white : const Color(0xFF064E3B),
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Ofertas Relámpago',
          style: GoogleFonts.manrope(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : const Color(0xFF064E3B),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search & Filter Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                children: [
                  // Search Input Bar (Matches Precios de Mercado search bar style)
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1F2937) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF374151)
                            : const Color(0xFFD9E3F4),
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: isDark ? Colors.white : const Color(0xFF121C28),
                      ),
                      decoration: InputDecoration(
                        hintText: 'Buscar productos...',
                        hintStyle: GoogleFonts.inter(
                          color: isDark
                              ? const Color(0xFF9CA3AF)
                              : const Color(0xFF6F7973),
                          fontSize: 14,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: isDark
                              ? const Color(0xFF9CA3AF)
                              : const Color(0xFF3F4944),
                          size: 20,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.clear,
                                  size: 18,
                                  color: isDark
                                      ? const Color(0xFF9CA3AF)
                                      : const Color(0xFF3F4944),
                                ),
                                onPressed: () => _searchController.clear(),
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Row 1: Descuentos Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _buildFilterChip('Todos', isDark, filterType: 'discount'),
                        _buildFilterChip(
                          '50% OFF',
                          isDark,
                          filterType: 'discount',
                          icon: Icons.bolt,
                          iconColor: Colors.amber,
                        ),
                        _buildFilterChip(
                          '30% OFF',
                          isDark,
                          filterType: 'discount',
                          icon: Icons.bolt,
                          iconColor: Colors.orange,
                        ),
                        _buildFilterChip('25% OFF', isDark, filterType: 'discount'),
                        _buildFilterChip('10% OFF', isDark, filterType: 'discount'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Row 2: Categorías de Productos Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _buildFilterChip('Todos', isDark, filterType: 'category'),
                        _buildFilterChip(
                          'Frutas',
                          isDark,
                          filterType: 'category',
                          icon: Icons.apple,
                          iconColor: Colors.redAccent,
                        ),
                        _buildFilterChip(
                          'Tubérculos',
                          isDark,
                          filterType: 'category',
                          icon: Icons.grid_view,
                          iconColor: Colors.amber[800],
                        ),
                        _buildFilterChip(
                          'Raíces',
                          isDark,
                          filterType: 'category',
                          icon: Icons.eco,
                          iconColor: Colors.green,
                        ),
                        _buildFilterChip(
                          'Hortalizas',
                          isDark,
                          filterType: 'category',
                          icon: Icons.grass,
                          iconColor: const Color(0xFF059669),
                        ),
                        _buildFilterChip(
                          'Cítricos',
                          isDark,
                          filterType: 'category',
                          icon: Icons.brightness_5,
                          iconColor: Colors.lime[700],
                        ),
                        _buildFilterChip(
                          'Orgánico',
                          isDark,
                          filterType: 'category',
                          icon: Icons.verified,
                          iconColor: const Color(0xFF047857),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Product Grid View (2 products per row)
            Expanded(
              child: ValueListenableBuilder<List<Map<String, dynamic>>>(
                valueListenable: globalFlashOffers,
                builder: (context, offers, child) {
                  final filteredList = _filteredOffers;
                  if (filteredList.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: isDark ? Colors.grey[600] : Colors.grey[400],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No se encontraron ofertas',
                            style: GoogleFonts.manrope(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? Colors.grey[300]
                                  : Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Intenta con otro término de búsqueda o filtro',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? Colors.grey[500]
                                  : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(14, 8, 14, 20),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.60,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final offer = filteredList[index];
                      return _buildOfferCard(offer, isDark, theme);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    bool isDark, {
    required String filterType,
    IconData? icon,
    Color? iconColor,
  }) {
    final isSelected = filterType == 'discount'
        ? _selectedDiscountFilter == label
        : _selectedCategoryFilter == label;
    final activeBg = const Color(0xFF047857);
    final inactiveBg = isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFFEBF1FA);

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: GestureDetector(
        key: ValueKey('chip_gesture_${filterType}_$label'),
        onTap: () {
          setState(() {
            if (filterType == 'discount') {
              _selectedDiscountFilter = label;
            } else {
              _selectedCategoryFilter = label;
            }
          });
        },
        child: Container(
          key: ValueKey('chip_container_${filterType}_${label}_$isSelected'),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? activeBg : inactiveBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF059669)
                  : (isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFCBD5E1)),
              width: 0.8,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 13,
                  color: isSelected
                      ? Colors.white
                      : (iconColor ?? Colors.amber),
                ),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : (isDark
                            ? const Color(0xFF9CA3AF)
                            : const Color(0xFF3F4944)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showExpiredOfferBottomSheet(BuildContext context, Map<String, dynamic> data) {
    final supplierName = data['supplier'] ?? 'el proveedor';
    final productName = data['name'] ?? 'este producto';
    final regularPrice = data['oldPrice'] ?? data['wholesaleOldPrice'] ?? '\$22.50';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 85),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.timer_off_outlined, color: Colors.amber, size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              '¡Oferta Relámpago Finalizada!',
              style: GoogleFonts.manrope(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'El tiempo de descuento para $productName ha concluido. El precio regular actual es $regularPrice.',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.grey[300] : Colors.grey[600],
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF047857).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF047857).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.handshake_outlined, color: Color(0xFF047857), size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '¡Aún puedes tratar de convencer a $supplierName iniciando un chat directo!',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF047857),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF047857),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.chat_bubble_outline),
                label: Text(
                  'Iniciar Chat con $supplierName',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  context.push('/chat', extra: {
                    'name': supplierName,
                    'product': productName,
                    'initialMessage': 'Hola $supplierName, vi que la oferta relámpago de $productName acaba de terminar. ¿Será posible conseguir un precio especial?',
                  });
                },
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.push('/product_detail', extra: data);
                },
                child: Text(
                  'Ver detalle al precio regular',
                  style: TextStyle(
                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfferCard(
    Map<String, dynamic> data,
    bool isDark,
    ThemeData theme,
  ) {
    final name = data['name'] as String;
    final int secondsRemaining = data['secondsRemaining'] as int? ?? 0;
    final bool isExpired = secondsRemaining <= 0;

    final String badge = (data['badge'] ?? 'Primera Calidad').toString();
    Color badgeColor = theme.colorScheme.primary;
    final lowerBadge = badge.toLowerCase();
    if (lowerBadge.contains('segunda')) {
      badgeColor = const Color(0xFFFF8A5B);
    } else if (lowerBadge.contains('tercera')) {
      badgeColor = Colors.red[500]!;
    }

    final salesMode = data['salesMode'] ?? 'retail_only';
    final currentMode = (salesMode == 'both')
        ? (_selectedProductModes[name] ?? 'retail')
        : (salesMode == 'wholesale_only' ? 'wholesale' : 'retail');

    final bool isWholesale = currentMode == 'wholesale';

    final String displayPrice = isExpired
        ? (isWholesale
            ? (data['wholesaleOldPrice'] ?? data['oldPrice'] ?? '\$17.50')
            : (data['oldPrice'] ?? '\$22.50'))
        : (isWholesale
            ? (data['wholesalePrice'] ?? data['price'] ?? '\$14.50')
            : (data['price'] ?? '\$18.00'));

    final String? displayOldPrice = isExpired
        ? null
        : (isWholesale
            ? (data['wholesaleOldPrice'] ?? data['oldPrice'])
            : data['oldPrice']);

    return GestureDetector(
      key: ValueKey('card_gesture_$name'),
      onTap: () {
        if (isExpired) {
          _showExpiredOfferBottomSheet(context, data);
        } else {
          context.push('/product_detail', extra: data);
        }
      },
      child: Container(
        key: ValueKey('card_container_$name'),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Image Stack
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(19),
                  ),
                  child: Builder(
                    builder: (context) {
                      final imgSrc = data['img']!.toString();
                      if (imgSrc.startsWith('assets/')) {
                        return Image.asset(
                          imgSrc,
                          height: 115,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) =>
                              Container(height: 115, color: Colors.grey[300]),
                        );
                      }
                      return Image.network(
                        imgSrc,
                        height: 115,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) =>
                            Container(height: 115, color: Colors.grey[300]),
                      );
                    },
                  ),
                ),

                // Top-Left Animated Discount Badge (#FD9312)
                if (data['discount'] != null)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: AnimatedDiscountBadge(
                      discountText: data['discount']!,
                      isExpired: isExpired,
                    ),
                  ),

                // Top-Right Favorite Button
                Positioned(
                  top: 10,
                  right: 10,
                  child: ValueListenableBuilder<List<Map<String, dynamic>>>(
                    valueListenable: globalFavorites,
                    builder: (context, favoritesList, child) {
                      final bool isFav = isFavorite(data['name']!);
                      return AnimatedFavoriteButton(
                        isFavorite: isFav,
                        onTap: () {
                          toggleFavorite(data);
                          final snackBar = SnackBar(
                            content: Row(
                              children: [
                                Icon(
                                  !isFav ? Icons.favorite : Icons.heart_broken,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    !isFav
                                        ? 'Añadido a favoritos'
                                        : 'Eliminado de favoritos',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: !isFav
                                ? const Color(0xFF047857)
                                : Colors.red.shade400,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            duration: const Duration(seconds: 2),
                          );
                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        },
                      );
                    },
                  ),
                ),

                // Bottom-Right Verified Badge
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF047857),
                      borderRadius: BorderRadius.circular(7),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 4),
                      ],
                    ),
                    child: const Icon(
                      Icons.verified,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),

            // Card Body Content (No Expanded or SingleChildScrollView to ensure solid layout bounds)
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + Price Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF0F172A),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),

                            // Sales Mode Switcher [ Detalle | Por Mayor ]
                            _buildCardSalesModeBadge(salesMode, name, isDark),
                            const SizedBox(height: 4),

                            // Rating & Reviews
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.orange,
                                  size: 13,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  data['rating'] ?? '4.8',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  '(128)',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),

                      // Price Column
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (displayOldPrice != null)
                            Text(
                              displayOldPrice,
                              style: GoogleFonts.inter(
                                color: Colors.grey,
                                fontSize: 10,
                                decoration: TextDecoration.lineThrough,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          Text(
                            displayPrice,
                            style: GoogleFonts.inter(
                              color: isWholesale
                                  ? const Color(0xFF047857)
                                  : const Color(0xFF047857),
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                isWholesale ? 'POR MAYOR' : 'POR KILO',
                                style: GoogleFonts.inter(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: isWholesale
                                      ? const Color(0xFF047857)
                                      : Colors.grey[600],
                                ),
                              ),
                              if (isWholesale && data['wholesaleMin'] != null)
                                Text(
                                  '(${data['wholesaleMin']})',
                                  style: GoogleFonts.inter(
                                    fontSize: 7,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF047857).withValues(alpha: 0.85),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),
                  const Divider(
                    color: Color(0xFFE0E3DF),
                    thickness: 0.8,
                    height: 1,
                  ),
                  const SizedBox(height: 6),

                  // CALIDAD Row
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) =>
                            QualityInfoBottomSheet(quality: badge),
                      );
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: badgeColor.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.workspace_premium,
                            color: badgeColor,
                            size: 13,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'CALIDAD',
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              Text(
                                badge.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: badgeColor,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),

                  // PROVEEDOR Row
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) =>
                            SupplierQuickViewBottomSheet(supplierData: data),
                      );
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF047857,
                            ).withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.local_florist,
                            color: Color(0xFF047857),
                            size: 13,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'PROVEEDOR',
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              Text(
                                data['supplier'] ?? 'Don Pedro H.',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),

                  // UBICACIÓN Row
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.grey,
                          size: 13,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'UBICACIÓN',
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                                letterSpacing: 0.3,
                              ),
                            ),
                            Text(
                              data['location'] ?? 'Tecomán, Colima',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Bottom Individual Countdown Clock (Reloj_OfertaRelampago style)
                  _buildCardCountdownBanner(
                    data['secondsRemaining'] as int? ?? 0,
                    isDark,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardCountdownBanner(int totalSeconds, bool isDark) {
    if (totalSeconds <= 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF334155).withValues(alpha: 0.4)
              : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark
                ? const Color(0xFF475569)
                : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.timer_off_outlined,
              color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF64748B),
              size: 13,
            ),
            const SizedBox(width: 4),
            Text(
              'OFERTA FINALIZADA',
              style: GoogleFonts.inter(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF64748B),
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      );
    }

    final hours = (totalSeconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((totalSeconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF064E3B).withValues(alpha: 0.25)
            : const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark
              ? const Color(0xFF064E3B).withValues(alpha: 0.5)
              : const Color(0xFFD1FAE5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.schedule,
            color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF047857),
            size: 13,
          ),
          const SizedBox(width: 4),
          Text(
            'Termina en:',
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF3F4944),
            ),
          ),
          const SizedBox(width: 5),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSmallTimeUnitBox(hours, isDark),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Text(
                  ':',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? const Color(0xFF9CA3AF)
                        : const Color(0xFF3F4944),
                  ),
                ),
              ),
              _buildSmallTimeUnitBox(minutes, isDark),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Text(
                  ':',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? const Color(0xFF9CA3AF)
                        : const Color(0xFF3F4944),
                  ),
                ),
              ),
              _buildSmallTimeUnitBox(seconds, isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallTimeUnitBox(String value, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: isDark
              ? const Color(0xFF064E3B).withValues(alpha: 0.6)
              : const Color(0xFFD1FAE5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        value,
        style: GoogleFonts.jetBrainsMono(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF047857),
        ),
      ),
    );
  }

  Widget _buildCardSalesModeBadge(
    String salesMode,
    String productName,
    bool isDark,
  ) {
    if (salesMode == 'both') {
      final currentMode = _selectedProductModes[productName] ?? 'retail';
      final bool isRetailSelected = currentMode == 'retail';
      final bool isWholesaleSelected = currentMode == 'wholesale';

      return Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            width: 0.8,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              key: ValueKey('btn_retail_$productName'),
              onTap: () {
                setState(() {
                  _selectedProductModes[productName] = 'retail';
                });
              },
              child: Container(
                key: ValueKey('cont_retail_${productName}_$isRetailSelected'),
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: isRetailSelected
                      ? (isDark
                            ? const Color(0xFF047857)
                            : const Color(0xFF059669))
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Detalle',
                  style: GoogleFonts.inter(
                    color: isRetailSelected
                        ? Colors.white
                        : (isDark ? Colors.grey[400] : Colors.grey[600]),
                    fontSize: 9,
                    fontWeight: isRetailSelected
                        ? FontWeight.bold
                        : FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 2),
            GestureDetector(
              key: ValueKey('btn_wholesale_$productName'),
              onTap: () {
                setState(() {
                  _selectedProductModes[productName] = 'wholesale';
                });
              },
              child: Container(
                key: ValueKey(
                  'cont_wholesale_${productName}_$isWholesaleSelected',
                ),
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: isWholesaleSelected
                      ? (isDark
                            ? const Color(0xFF047857)
                            : const Color(0xFF065F46))
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Por Mayor',
                  style: GoogleFonts.inter(
                    color: isWholesaleSelected
                        ? Colors.white
                        : (isDark ? Colors.grey[400] : Colors.grey[600]),
                    fontSize: 9,
                    fontWeight: isWholesaleSelected
                        ? FontWeight.bold
                        : FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final bool isRetail = salesMode == 'retail_only' || salesMode == 'retail';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isRetail
            ? (isDark
                  ? const Color(0xFF064E3B).withValues(alpha: 0.4)
                  : const Color(0xFFECFDF5))
            : (isDark
                  ? const Color(0xFF064E3B).withValues(alpha: 0.4)
                  : const Color(0xFFECFDF5)),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isRetail
              ? (isDark
                    ? const Color(0xFF059669).withValues(alpha: 0.5)
                    : const Color(0xFFA7F3D0))
              : (isDark
                    ? const Color(0xFF059669).withValues(alpha: 0.5)
                    : const Color(0xFFA7F3D0)),
          width: 0.8,
        ),
      ),
      child: Text(
        isRetail ? 'Solo al Detalle' : 'Solo por Mayor',
        style: GoogleFonts.inter(
          color: isRetail
              ? (isDark ? const Color(0xFF6EE7B7) : const Color(0xFF047857))
              : (isDark ? const Color(0xFF7DD3FC) : const Color(0xFF0369A1)),
          fontSize: 9,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
