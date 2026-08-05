import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/global_state.dart';
import '../widgets/animated_favorite_button.dart';
import '../widgets/product_reviews_modal.dart';
import '../widgets/quality_info_bottom_sheet.dart';
import '../widgets/supplier_quick_view_bottom_sheet.dart';

class FlashOffersScreen extends StatefulWidget {
  const FlashOffersScreen({super.key});

  @override
  State<FlashOffersScreen> createState() => _FlashOffersScreenState();
}

class _FlashOffersScreenState extends State<FlashOffersScreen> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'Todos';

  // Selection state for multi-add to cart
  final Set<String> _selectedProductNames = {};

  // Track sales mode per product ('retail' or 'wholesale')
  final Map<String, String> _selectedProductModes = {};

  // Timer simulation for countdown
  late Timer _timer;
  int _secondsRemaining = 16092; // ~4h 28m 12s

  // Animation controller for screen entrance
  late AnimationController _entranceController;

  final List<Map<String, dynamic>> _allOffers = [
    {
      'name': 'Papa Blanca Alpha',
      'category': 'Tubérculos',
      'discount': '-20%',
      'discountNumber': 20,
      'price': '\$18.00',
      'oldPrice': '\$22.50',
      'wholesalePrice': '\$14.50',
      'wholesaleOldPrice': '\$17.50',
      'wholesaleMin': 'MIN. 20 KG',
      'rating': '4.8',
      'badge': 'PRIMERA CALIDAD',
      'supplier': 'Don Pedro H.',
      'location': 'Tecomán, Colima',
      'tags': ['Tubérculos', 'Oferta'],
      'salesMode': 'both',
      'img': 'assets/images/PapaGemini.png'
    },
    {
      'name': 'Zanahoria Orgánica',
      'category': 'Raíces',
      'discount': '-22%',
      'discountNumber': 22,
      'price': '\$12.50',
      'oldPrice': '\$16.00',
      'wholesalePrice': '\$9.80',
      'wholesaleOldPrice': '\$12.50',
      'wholesaleMin': 'MIN. 15 KG',
      'rating': '4.9',
      'badge': 'TERCERA CALIDAD',
      'supplier': 'Granja Sol',
      'location': 'Valle Verde, Puebla',
      'tags': ['Raíces', 'Orgánico'],
      'salesMode': 'both',
      'img': 'assets/images/ZanahoriaGemini.png'
    },
    {
      'name': 'Tomate Cherry Orgánico',
      'category': 'Hortalizas',
      'discount': '-30%',
      'discountNumber': 30,
      'price': '\$12.50',
      'oldPrice': '\$17.85',
      'wholesalePrice': '\$9.50',
      'wholesaleOldPrice': '\$13.50',
      'wholesaleMin': 'MIN. 10 KG',
      'rating': '4.9',
      'badge': 'PRIMERA CALIDAD',
      'supplier': 'Invernaderos SLP',
      'location': 'San Luis Potosí',
      'tags': ['Hortalizas', 'Orgánico'],
      'salesMode': 'both',
      'img': 'https://lh3.googleusercontent.com/aida-public/AB6AXuBXcsVfAn4SXFQcHddnB5qMtM4renFwAuqO-lGdtcJtIIEmGl9tMDsFQiPgu60XnCWVebJO7iP0Ibk5dtJIqrh9Aanp9rZWGv7faUFsthP816CnkwG06d3lv6JAtK1L0AlnAz_e_RO8MTnW4_KInOanUlNL5k2AshcmFlzprpJxW1x81-1wvtFdgqmQ27XRJXCS6DLiTryvA9pgF60utXXNGEKTfgzyHZfbGio0iMIq4G_RBnQepN2i0vJ1-mywwHJNnmaXt1UMSH8'
    },
    {
      'name': 'Zanahoria Nantesa Lavada',
      'category': 'Raíces',
      'discount': '-50%',
      'discountNumber': 50,
      'price': '\$15.00',
      'oldPrice': '\$30.00',
      'wholesalePrice': '\$11.00',
      'wholesaleOldPrice': '\$22.00',
      'wholesaleMin': 'MIN. 20 KG',
      'rating': '4.8',
      'badge': 'PRIMERA CALIDAD',
      'supplier': 'Granja Sol',
      'location': 'Valle Verde, Puebla',
      'tags': ['Raíces', 'Lavada'],
      'salesMode': 'both',
      'img': 'https://lh3.googleusercontent.com/aida-public/AB6AXuC8i3bYgCoFml8RIwzz2s32HSkKDvOTWEnX-bo6gt_9o4zdC9d3U0ZglOr_m6EMoKc6Oz2ryDTAoXTbMceJxM4huBHJNMRIBp_rkwcL972T0U0FipN8bSOaMvmlsOxI7peoA4M2Uq1zmuTbYTdHFlAe_A_VA3kLfbMf3thYxRRP7gU3H79Xu6gqxI8wfQqLd59xQyc9evPxWOYoH-ufQjjtXka1i6Bn6dDixAquahUTLyExdeosV0TZReH-nBZgtW2Wf1EEcK2VGiY'
    },
    {
      'name': 'Limón Sutil Primera',
      'category': 'Cítricos',
      'discount': '-25%',
      'discountNumber': 25,
      'price': '\$8.90',
      'oldPrice': '\$11.90',
      'wholesalePrice': '\$6.50',
      'wholesaleOldPrice': '\$9.20',
      'wholesaleMin': 'MIN. 15 KG',
      'rating': '4.7',
      'badge': 'PRIMERA CALIDAD',
      'supplier': 'Cítricos del Pacífico',
      'location': 'Manzanillo, Colima',
      'tags': ['Cítricos', 'Fresco'],
      'salesMode': 'both',
      'img': 'https://lh3.googleusercontent.com/aida-public/AB6AXuCoJ0D5DucqLAya_-YteH6-8cB0lbCiusShRQ5J7CpVWmeRZq_Dunwko3RtZ6MnlwVNNLu9qIMiXPC02Jr1-ZLXltcDkkQ0pqh4QKIExzuuQRRqrcXdHQcZxH33bpROQ5o-f2IBOsbqiL6lAuXMgnbrH4_kJmNK6b8kKf_2pM4dzh8AtsiiLNaiDX88Fe0OoRYiKx2-omyEvAoG4YwfLUNLxG5W4A6kcm0dv08LBcwmXpObjY9s4lgDuy3fpuu-_bUGZXDeZUcnKro'
    },
    {
      'name': 'Fresas de Campo Extras',
      'category': 'Frutas',
      'discount': '-25%',
      'discountNumber': 25,
      'price': '\$45.00',
      'oldPrice': '\$60.00',
      'wholesalePrice': '\$36.00',
      'wholesaleOldPrice': '\$48.00',
      'wholesaleMin': 'MIN. 10 KG',
      'rating': '4.9',
      'badge': 'PRIMERA CALIDAD',
      'supplier': 'AgroFresas',
      'location': 'Zamora, Michoacán',
      'tags': ['Frutas', 'Frescas'],
      'salesMode': 'both',
      'img': 'https://raw.githubusercontent.com/NevaDom47/imagenes/refs/heads/main/20250620_1233_Fresas%20en%20Fondo%20Rosado_simple_compose_01jy72ypjmeccafrqb33rfm1q8.png'
    },
    {
      'name': 'Saco de Papas Blancas',
      'category': 'Tubérculos',
      'discount': '-12%',
      'discountNumber': 12,
      'price': '\$280.00',
      'oldPrice': '\$320.00',
      'wholesalePrice': '\$250.00',
      'wholesaleOldPrice': '\$300.00',
      'wholesaleMin': 'MIN. 2 SACOS',
      'rating': '4.6',
      'badge': 'SEGUNDA CALIDAD',
      'supplier': 'Hermanos Ruiz',
      'location': 'Galeana, Nuevo León',
      'tags': ['Tubérculos'],
      'salesMode': 'wholesale_only',
      'img': 'https://raw.githubusercontent.com/NevaDom47/imagenes/refs/heads/main/20250603_1556_Sacos%20de%20Papas_simple_compose_01jwvnskaee6evykbzreq6j8wm.png'
    },
    {
      'name': 'Mix de Ajíes Frescos',
      'category': 'Hortalizas',
      'discount': '-22%',
      'discountNumber': 22,
      'price': '\$35.00',
      'oldPrice': '\$45.00',
      'wholesalePrice': '\$28.00',
      'wholesaleOldPrice': '\$36.00',
      'wholesaleMin': 'MIN. 10 KG',
      'rating': '4.7',
      'badge': 'PRIMERA CALIDAD',
      'supplier': 'Picantes del Sur',
      'location': 'Oaxaca, Oaxaca',
      'tags': ['Hortalizas', 'Mix'],
      'salesMode': 'both',
      'img': 'https://raw.githubusercontent.com/NevaDom47/imagenes/refs/heads/main/20250603_1549_Variedad%20de%20Aj%C3%ADes_simple_compose_01jwvncbmqfpvb7qv6rs3vh22x.png'
    },
  ];

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _entranceController.forward();

    // Start timer for offer countdown
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_secondsRemaining > 0) {
            _secondsRemaining--;
          }
        });
      }
    });

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _entranceController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  String _formatCountdown(int totalSeconds) {
    final hours = (totalSeconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((totalSeconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '${hours}h ${minutes}m ${seconds}s';
  }

  List<Map<String, dynamic>> get _filteredOffers {
    return _allOffers.where((offer) {
      final nameMatches = offer['name'].toString().toLowerCase().contains(_searchQuery);
      final categoryMatches = offer['category'].toString().toLowerCase().contains(_searchQuery) ||
          (offer['tags'] as List).any((t) => t.toString().toLowerCase().contains(_searchQuery));

      final matchesQuery = _searchQuery.isEmpty || nameMatches || categoryMatches;

      if (!matchesQuery) return false;

      if (_selectedFilter == '50% OFF') {
        return (offer['discountNumber'] as int) >= 50;
      } else if (_selectedFilter == '30% OFF') {
        return (offer['discountNumber'] as int) >= 30;
      } else if (_selectedFilter == '25% OFF') {
        return (offer['discountNumber'] as int) >= 25;
      } else if (_selectedFilter == '10% OFF') {
        return (offer['discountNumber'] as int) >= 10;
      } else if (_selectedFilter != 'Todos') {
        return offer['category'] == _selectedFilter || (offer['tags'] as List).contains(_selectedFilter);
      }

      return true;
    }).toList();
  }

  double get _calculatedTotalEstimate {
    double total = 0.0;
    for (final offer in _allOffers) {
      final name = offer['name'] as String;
      if (_selectedProductNames.contains(name)) {
        final mode = _selectedProductModes[name] ?? 'retail';
        final isWholesale = mode == 'wholesale';
        final priceStr = isWholesale
            ? (offer['wholesalePrice'] ?? offer['price']).toString().replaceAll('\$', '')
            : (offer['price']).toString().replaceAll('\$', '');
        total += double.tryParse(priceStr) ?? 0.0;
      }
    }
    return total;
  }

  void _toggleProductSelection(String name) {
    setState(() {
      if (_selectedProductNames.contains(name)) {
        _selectedProductNames.remove(name);
      } else {
        _selectedProductNames.add(name);
      }
    });
  }

  void _addSelectedToCart() {
    if (_selectedProductNames.isEmpty) return;

    int addedCount = 0;
    for (final offer in _allOffers) {
      final name = offer['name'] as String;
      if (_selectedProductNames.contains(name)) {
        final mode = _selectedProductModes[name] ?? 'retail';
        final isWholesale = mode == 'wholesale';

        // Prepare item payload for globalCart
        final productPayload = Map<String, dynamic>.from(offer);
        if (isWholesale && offer['wholesalePrice'] != null) {
          productPayload['price'] = offer['wholesalePrice'];
          productPayload['unit'] = offer['wholesaleMin'] ?? 'SACO';
        }

        addToCart(productPayload);
        addedCount++;
      }
    }

    setState(() {
      _selectedProductNames.clear();
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '$addedCount producto${addedCount > 1 ? 's' : ''} añadido${addedCount > 1 ? 's' : ''} al carrito',
                style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF047857),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'VER CARRITO',
          textColor: const Color(0xFFA7F3D0),
          onPressed: () => context.push('/cart'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8F9FF);
    final cardBgColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final primaryColor = const Color(0xFF065F46);

    final filteredList = _filteredOffers;
    final selectedCount = _selectedProductNames.length;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 20, color: isDark ? Colors.white : const Color(0xFF064E3B)),
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
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // New Countdown Banner (Reloj_OfertaRelampago design)
                Builder(builder: (context) {
                  final hours = (_secondsRemaining ~/ 3600).toString().padLeft(2, '0');
                  final minutes = ((_secondsRemaining % 3600) ~/ 60).toString().padLeft(2, '0');
                  final seconds = (_secondsRemaining % 60).toString().padLeft(2, '0');

                  return Container(
                    margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF064E3B).withValues(alpha: 0.25)
                          : const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF064E3B).withValues(alpha: 0.5)
                            : const Color(0xFFD1FAE5),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.schedule,
                          color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF047857),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'La oferta termina en:',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF3F4944),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildTimeUnitBox(hours, isDark),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 3),
                              child: Text(
                                ':',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF3F4944),
                                ),
                              ),
                            ),
                            _buildTimeUnitBox(minutes, isDark),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 3),
                              child: Text(
                                ':',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF3F4944),
                                ),
                              ),
                            ),
                            _buildTimeUnitBox(seconds, isDark),
                          ],
                        ),
                      ],
                    ),
                  );
                }),

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
                            color: isDark ? const Color(0xFF374151) : const Color(0xFFD9E3F4),
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
                              color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6F7973),
                              fontSize: 14,
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF3F4944),
                              size: 20,
                            ),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: Icon(
                                      Icons.clear,
                                      size: 18,
                                      color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF3F4944),
                                    ),
                                    onPressed: () => _searchController.clear(),
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Filter Chips Row
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: [
                            _buildFilterChip('Todos', isDark),
                            _buildFilterChip('50% OFF', isDark, icon: Icons.bolt, iconColor: Colors.amber),
                            _buildFilterChip('30% OFF', isDark, icon: Icons.local_fire_department, iconColor: Colors.orange),
                            _buildFilterChip('25% OFF', isDark),
                            _buildFilterChip('10% OFF', isDark),
                            _buildFilterChip('Tubérculos', isDark),
                            _buildFilterChip('Hortalizas', isDark),
                            _buildFilterChip('Raíces', isDark),
                            _buildFilterChip('Frutas', isDark),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Product Grid View (2 products per row)
                Expanded(
                  child: filteredList.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off, size: 64, color: isDark ? Colors.grey[600] : Colors.grey[400]),
                              const SizedBox(height: 12),
                              Text(
                                'No se encontraron ofertas',
                                style: GoogleFonts.manrope(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.grey[300] : Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Intenta con otro término de búsqueda o filtro',
                                style: TextStyle(fontSize: 13, color: isDark ? Colors.grey[500] : Colors.grey[600]),
                              ),
                            ],
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.fromLTRB(14, 8, 14, 110),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.45,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: filteredList.length,
                          itemBuilder: (context, index) {
                            final offer = filteredList[index];
                            return _buildOfferCard(offer, isDark, theme);
                          },
                        ),
                ),
              ],
            ),
          ),

          // Sticky Bottom Multi-Select Action Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              offset: selectedCount > 0 ? Offset.zero : const Offset(0, 1.2),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 250),
                opacity: selectedCount > 0 ? 1.0 : 0.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 16,
                        offset: const Offset(0, -4),
                      ),
                    ],
                    border: Border(
                      top: BorderSide(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: const BoxDecoration(
                          color: Color(0xFF064E3B),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '$selectedCount',
                            style: GoogleFonts.manrope(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$selectedCount producto${selectedCount > 1 ? 's' : ''} seleccionado${selectedCount > 1 ? 's' : ''}',
                              style: GoogleFonts.manrope(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                              ),
                            ),
                            Text(
                              'Total est: \$${_calculatedTotalEstimate.toStringAsFixed(2)}',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF059669),
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _addSelectedToCart,
                        icon: const Icon(Icons.shopping_cart_checkout, size: 18),
                        label: Text(
                          'Añadir al Carrito',
                          style: GoogleFonts.manrope(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF047857),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
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
    );
  }

  Widget _buildFilterChip(String label, bool isDark, {IconData? icon, Color? iconColor}) {
    final isSelected = _selectedFilter == label;
    final activeBg = const Color(0xFF047857);
    final inactiveBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFEBF1FA);

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: GestureDetector(
        key: ValueKey('chip_gesture_$label'),
        onTap: () {
          setState(() {
            _selectedFilter = label;
          });
        },
        child: Container(
          key: ValueKey('chip_container_${label}_$isSelected'),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? activeBg : inactiveBg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 14, color: isSelected ? Colors.white : (iconColor ?? Colors.amber)),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? const Color(0xFF9CA3AF) : const Color(0xFF3F4944)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeUnitBox(String value, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isDark
              ? const Color(0xFF064E3B).withValues(alpha: 0.6)
              : const Color(0xFFD1FAE5),
          width: 1,
        ),
      ),
      child: Text(
        value,
        style: GoogleFonts.jetBrainsMono(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF047857),
        ),
      ),
    );
  }

  Widget _buildOfferCard(Map<String, dynamic> data, bool isDark, ThemeData theme) {
    final name = data['name'] as String;
    final isSelected = _selectedProductNames.contains(name);

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

    final String displayPrice = isWholesale
        ? (data['wholesalePrice'] ?? data['price'] ?? '\$14.50')
        : (data['price'] ?? '\$18.00');

    final String? displayOldPrice = isWholesale
        ? (data['wholesaleOldPrice'] ?? data['oldPrice'])
        : data['oldPrice'];

    return GestureDetector(
      key: ValueKey('card_gesture_$name'),
      onTap: () => _toggleProductSelection(name),
      child: Container(
        key: ValueKey('card_container_${name}_$isSelected'),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF047857)
                : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
            width: isSelected ? 2.2 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0xFF047857).withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: isSelected ? 12 : 6,
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
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
                  child: Builder(builder: (context) {
                    final imgSrc = data['img']!.toString();
                    if (imgSrc.startsWith('assets/')) {
                      return Image.asset(
                        imgSrc,
                        height: 140,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(height: 140, color: Colors.grey[300]),
                      );
                    }
                    return Image.network(
                      imgSrc,
                      height: 140,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(height: 140, color: Colors.grey[300]),
                    );
                  }),
                ),

                // Top-Left Discount Badge
                if (data['discount'] != null)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDC2626),
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                      ),
                      child: Text(
                        data['discount']!,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),

                // Top-Right Custom Checkbox (Replaces Favorite Button)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF047857) : Colors.white.withValues(alpha: 0.92),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? const Color(0xFF047857) : Colors.grey[400]!,
                        width: 1.8,
                      ),
                      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 18)
                        : null,
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
                      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                    ),
                    child: const Icon(Icons.verified, color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),

            // Card Body Content
            Padding(
              padding: const EdgeInsets.all(10),
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
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
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
                                const Icon(Icons.star, color: Colors.orange, size: 13),
                                const SizedBox(width: 3),
                                Text(
                                  data['rating'] ?? '4.8',
                                  style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  '(128)',
                                  style: GoogleFonts.inter(fontSize: 10, color: Colors.grey[500]),
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
                              color: isWholesale ? const Color(0xFF0284C7) : const Color(0xFF047857),
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
                                  color: isWholesale ? const Color(0xFF0284C7) : Colors.grey[600],
                                ),
                              ),
                              if (isWholesale && data['wholesaleMin'] != null)
                                Text(
                                  '(${data['wholesaleMin']})',
                                  style: GoogleFonts.inter(
                                    fontSize: 7,
                                    fontWeight: FontWeight.w700,
                                    color: (isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7)).withValues(alpha: 0.85),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),
                  const Divider(color: Color(0xFFE0E3DF), thickness: 0.8, height: 1),
                  const SizedBox(height: 8),

                  // CALIDAD Row
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => QualityInfoBottomSheet(quality: badge),
                      );
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      children: [
                        Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: badgeColor.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.workspace_premium, color: badgeColor, size: 14),
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
                  const SizedBox(height: 6),

                  // PROVEEDOR Row
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
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: const Color(0xFF047857).withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.local_florist, color: Color(0xFF047857), size: 14),
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
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),

                  // UBICACIÓN Row
                  Row(
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.location_on, color: Colors.grey, size: 14),
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
                              style: const TextStyle(fontSize: 10, color: Colors.grey),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
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
    );
  }

  Widget _buildCardSalesModeBadge(String salesMode, String productName, bool isDark) {
    if (salesMode == 'both') {
      final currentMode = _selectedProductModes[productName] ?? 'retail';
      final bool isRetailSelected = currentMode == 'retail';
      final bool isWholesaleSelected = currentMode == 'wholesale';

      return Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0), width: 0.8),
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
                      ? (isDark ? const Color(0xFF047857) : const Color(0xFF059669))
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Detalle',
                  style: GoogleFonts.inter(
                    color: isRetailSelected ? Colors.white : (isDark ? Colors.grey[400] : Colors.grey[600]),
                    fontSize: 9,
                    fontWeight: isRetailSelected ? FontWeight.bold : FontWeight.w500,
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
                key: ValueKey('cont_wholesale_${productName}_$isWholesaleSelected'),
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: isWholesaleSelected
                      ? (isDark ? const Color(0xFF0284C7) : const Color(0xFF0369A1))
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Por Mayor',
                  style: GoogleFonts.inter(
                    color: isWholesaleSelected ? Colors.white : (isDark ? Colors.grey[400] : Colors.grey[600]),
                    fontSize: 9,
                    fontWeight: isWholesaleSelected ? FontWeight.bold : FontWeight.w500,
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
            ? (isDark ? const Color(0xFF064E3B).withValues(alpha: 0.4) : const Color(0xFFECFDF5))
            : (isDark ? const Color(0xFF075985).withValues(alpha: 0.4) : const Color(0xFFF0F9FF)),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isRetail
              ? (isDark ? const Color(0xFF059669).withValues(alpha: 0.5) : const Color(0xFFA7F3D0))
              : (isDark ? const Color(0xFF0284C7).withValues(alpha: 0.5) : const Color(0xFFBAE6FD)),
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
