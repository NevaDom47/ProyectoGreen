import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/global_state.dart';
import '../widgets/animated_discount_badge.dart';
import '../widgets/animated_favorite_button.dart';
import '../widgets/product_reviews_modal.dart';
import '../widgets/quality_info_bottom_sheet.dart';
import 'product_detail_screen.dart';

class QualityProductsScreen extends StatefulWidget {
  final String quality;
  final Map<String, dynamic>? provider;
  final List<Map<String, dynamic>>? products;

  const QualityProductsScreen({
    super.key,
    required this.quality,
    this.provider,
    this.products,
  });

  @override
  State<QualityProductsScreen> createState() => _QualityProductsScreenState();
}

class _QualityProductsScreenState extends State<QualityProductsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Map<String, String> _selectedProductModes = {};
  
  String _selectedSalesFilter = 'todos'; // 'todos', 'retail', 'wholesale'
  String _selectedCategoryFilter = 'todos'; // 'todos', 'frutas', 'hortalizas', 'ofertas'
  String _selectedSort = 'default'; // 'default', 'price_asc', 'price_desc'
  String _searchQuery = '';

  late List<Map<String, dynamic>> _catalog;

  @override
  void initState() {
    super.initState();
    _initCatalog();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _initCatalog() {
    final cleanQuality = _normalizeQuality(widget.quality);

    if (widget.products != null && widget.products!.isNotEmpty) {
      _catalog = List<Map<String, dynamic>>.from(widget.products!);
      // If less than 4 products, enrich with complementary items of the same tier
      if (_catalog.length < 4) {
        final extras = _getDefaultProductsForTier(cleanQuality)
            .where((p) => !_catalog.any((existing) => (existing['title'] ?? existing['name']) == (p['title'] ?? p['name'])))
            .toList();
        _catalog.addAll(extras);
      }
    } else {
      _catalog = _getDefaultProductsForTier(cleanQuality);
    }
  }

  String _normalizeQuality(String raw) {
    final upper = raw.toUpperCase();
    if (upper.contains('PRIMERA')) return 'PRIMERA';
    if (upper.contains('SEGUNDA')) return 'SEGUNDA';
    if (upper.contains('TERCERA')) return 'TERCERA';
    return 'PRIMERA';
  }

  List<Map<String, dynamic>> _getDefaultProductsForTier(String tier) {
    if (tier == 'SEGUNDA') {
      return [
        {
          'title': 'Fresa Mediana',
          'price': '5.500',
          'unit': 'lb',
          'wholesalePrice': '4.200',
          'wholesaleMin': 'Caja 10 lb',
          'salesMode': 'both',
          'sku': 'FRU-FRE-05',
          'category': 'frutas',
          'tags': ['Frutas', 'Ahorro'],
          'rating': '4.6',
          'reviewsCount': 52,
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
          'category': 'hortalizas',
          'tags': ['Hortalizas', 'Fresco'],
          'rating': '4.5',
          'reviewsCount': 41,
          'quality': 'Segunda Calidad',
          'image': 'https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?q=80&w=300&auto=format&fit=crop',
        },
        {
          'title': 'Tomate Calibre Mixto',
          'price': '1.500',
          'unit': 'lb',
          'wholesalePrice': '1.100',
          'wholesaleMin': 'Caja 20 lb',
          'salesMode': 'both',
          'sku': 'HOR-TOM-11',
          'category': 'hortalizas',
          'tags': ['Hortalizas', 'Fresco'],
          'rating': '4.6',
          'reviewsCount': 37,
          'quality': 'Segunda Calidad',
          'image': 'https://images.unsplash.com/photo-1592924357228-91a4daadc239?q=80&w=300&auto=format&fit=crop',
        },
        {
          'title': 'Papas con Variación',
          'price': '1.800',
          'unit': 'kg',
          'wholesalePrice': '1.300',
          'wholesaleMin': 'Saco 40 kg',
          'salesMode': 'wholesale_only',
          'sku': 'TUB-PAP-12',
          'category': 'hortalizas',
          'tags': ['Hortalizas', 'Por Mayor'],
          'rating': '4.7',
          'reviewsCount': 29,
          'quality': 'Segunda Calidad',
          'image': 'assets/images/PapaGemini.png',
        },
      ];
    } else if (tier == 'TERCERA') {
      return [
        {
          'title': 'Hortalizas para Caldo',
          'price': '2.000',
          'unit': 'atado',
          'wholesalePrice': '1.400',
          'wholesaleMin': 'Atado x10',
          'salesMode': 'both',
          'sku': 'HOR-CAL-07',
          'category': 'hortalizas',
          'tags': ['Hortalizas', 'Cocina'],
          'rating': '4.4',
          'reviewsCount': 38,
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
          'category': 'hortalizas',
          'tags': ['Hortalizas', 'Oferta'],
          'rating': '4.5',
          'reviewsCount': 45,
          'quality': 'Tercera Calidad',
          'image': 'https://images.unsplash.com/photo-1518977676601-b53f82aba655?q=80&w=300&auto=format&fit=crop',
        },
        {
          'title': 'Frutas Maduras para Jugo',
          'price': '1.800',
          'unit': 'kg',
          'wholesalePrice': '1.200',
          'wholesaleMin': 'Caja 15 kg',
          'salesMode': 'both',
          'sku': 'FRU-JUG-13',
          'category': 'frutas',
          'tags': ['Frutas', 'Cocina'],
          'rating': '4.5',
          'reviewsCount': 31,
          'quality': 'Tercera Calidad',
          'image': 'https://images.unsplash.com/photo-1619566636858-adf3ef46400b?q=80&w=300&auto=format&fit=crop',
        },
      ];
    }

    // Default: PRIMERA
    return [
      {
        'title': 'Fresas Extra',
        'price': '8.500',
        'oldPrice': '10.000',
        'unit': 'lb',
        'wholesalePrice': '6.800',
        'wholesaleMin': 'Caja 10 lb',
        'salesMode': 'both',
        'sku': 'FRU-FRE-01',
        'category': 'frutas',
        'tags': ['Frutas', 'Oferta'],
        'rating': '4.8',
        'reviewsCount': 128,
        'discount': '-15%',
        'quality': 'Primera Calidad',
        'image': 'https://images.unsplash.com/photo-1464965911861-746a04b4bca6?q=80&w=300&auto=format&fit=crop',
      },
      {
        'title': 'Zanahoria Orgánica',
        'price': '3.200',
        'unit': 'kg',
        'wholesalePrice': '2.400',
        'wholesaleMin': 'Bulto 25 kg',
        'salesMode': 'both',
        'sku': 'RAI-ZAN-02',
        'category': 'hortalizas',
        'tags': ['Hortalizas', 'Orgánico'],
        'rating': '4.9',
        'reviewsCount': 94,
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
        'category': 'hortalizas',
        'tags': ['Hortalizas', 'Fresco'],
        'rating': '4.7',
        'reviewsCount': 76,
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
        'category': 'hortalizas',
        'tags': ['Hortalizas', 'Hidropónico'],
        'rating': '4.8',
        'reviewsCount': 64,
        'quality': 'Primera Calidad',
        'image': 'https://images.unsplash.com/photo-1622206151226-18ca2c9ab4a1?q=80&w=300&auto=format&fit=crop',
      },
      {
        'title': 'Aguacate Hass Extra',
        'price': '4.800',
        'unit': 'kg',
        'wholesalePrice': '3.900',
        'wholesaleMin': 'Malla 10 kg',
        'salesMode': 'both',
        'sku': 'FRU-AGU-09',
        'category': 'frutas',
        'tags': ['Frutas', 'Exportación'],
        'rating': '4.9',
        'reviewsCount': 112,
        'quality': 'Primera Calidad',
        'image': 'https://images.unsplash.com/photo-1523049673857-eb18f1d7b578?q=80&w=300&auto=format&fit=crop',
      },
      {
        'title': 'Manzanas Royal Gala',
        'price': '3.900',
        'unit': 'kg',
        'wholesalePrice': '3.100',
        'wholesaleMin': 'Caja 18 kg',
        'salesMode': 'retail_only',
        'sku': 'FRU-MAN-10',
        'category': 'frutas',
        'tags': ['Frutas', 'Importada'],
        'rating': '4.8',
        'reviewsCount': 89,
        'quality': 'Primera Calidad',
        'image': 'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?q=80&w=300&auto=format&fit=crop',
      },
    ];
  }

  Map<String, dynamic> _getTierMeta(String tier) {
    if (tier == 'SEGUNDA') {
      return {
        'title': 'Segunda Calidad',
        'tagline': 'Mismo sabor y frescura a precio accesible',
        'description': 'Productos frescos con pequeñas variaciones estéticas o calibre no uniforme que conservan el 100% de su valor nutricional y sabor natural.',
        'standards': [
          {'icon': Icons.restaurant_rounded, 'label': 'Sabor Auténtico'},
          {'icon': Icons.savings_outlined, 'label': 'Ahorro Garantizado'},
          {'icon': Icons.agriculture_outlined, 'label': 'Directo de Finca'},
          {'icon': Icons.recycling_rounded, 'label': 'Desperdicio Cero'},
        ],
        'primaryColor': const Color(0xFFF09065),
        'lightBg': const Color(0xFFFEFBF6),
        'darkBg': const Color(0xFF261E0E),
        'borderColor': const Color(0xFFFCEFE8),
        'darkBorderColor': const Color(0xFF6B4E17),
        'icon': Icons.eco_rounded,
        'badgeText': 'SEGUNDA',
      };
    } else if (tier == 'TERCERA') {
      return {
        'title': 'Tercera Calidad',
        'tagline': 'Ideal para preparaciones, jugos y salsas',
        'description': 'Alimentos en punto óptimo de madurez o descartes visuales ideales para consumo inmediato o procesamiento gastronómico al menor costo.',
        'standards': [
          {'icon': Icons.soup_kitchen_rounded, 'label': 'Ideal Cocina'},
          {'icon': Icons.sell_outlined, 'label': 'Liquidación'},
          {'icon': Icons.bolt_rounded, 'label': 'Consumo Rápido'},
          {'icon': Icons.eco_outlined, 'label': 'Sostenible'},
        ],
        'primaryColor': const Color(0xFFDC2626),
        'lightBg': const Color(0xFFFEF2F2),
        'darkBg': const Color(0xFF281113),
        'borderColor': const Color(0xFFFECACA),
        'darkBorderColor': const Color(0xFF6E2328),
        'icon': Icons.warning_amber_rounded,
        'badgeText': 'TERCERA',
      };
    }

    // Default: PRIMERA
    return {
      'title': 'Primera Calidad',
      'tagline': 'Selección Premium de Exportación',
      'description': 'Productos cosechados a mano bajo los estándares más estrictos: calibre uniforme, sin imperfecciones y máxima frescura garantizada del campo a tu mesa.',
      'standards': [
        {'icon': Icons.workspace_premium_rounded, 'label': 'Calibre A+'},
        {'icon': Icons.wb_sunny_outlined, 'label': 'Cosecha Hoy'},
        {'icon': Icons.eco_rounded, 'label': '100% Frescura'},
        {'icon': Icons.verified_user_outlined, 'label': 'Trazable'},
      ],
      'primaryColor': const Color(0xFF285E44),
      'lightBg': const Color(0xFFEAF5EE),
      'darkBg': const Color(0xFF0D251B),
      'borderColor': const Color(0xFFA5D6A7),
      'darkBorderColor': const Color(0xFF1B4D39),
      'icon': Icons.workspace_premium_rounded,
      'badgeText': 'PRIMERA',
    };
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

  List<Map<String, dynamic>> get _filteredProducts {
    return _catalog.where((item) {
      final name = (item['title'] ?? item['name'] ?? '').toString().toLowerCase();
      final sku = _getProductSku(item).toLowerCase();
      final cleanSkuNoHyphen = sku.replaceAll('-', '');
      final q = _searchQuery.trim().toLowerCase();
      final qNoHyphen = q.replaceAll('-', '');

      // 1. Search Query Filter (Matches Name or SKU)
      if (q.isNotEmpty) {
        final matchesName = name.contains(q);
        final matchesSku = sku.contains(q) || cleanSkuNoHyphen.contains(qNoHyphen);
        if (!matchesName && !matchesSku) return false;
      }

      // 2. Sales Mode Filter
      final salesMode = (item['salesMode'] ?? 'both').toString();
      if (_selectedSalesFilter == 'retail') {
        if (salesMode == 'wholesale_only') return false;
      } else if (_selectedSalesFilter == 'wholesale') {
        if (salesMode == 'retail_only') return false;
      }

      // 3. Category Filter
      if (_selectedCategoryFilter != 'todos') {
        if (_selectedCategoryFilter == 'ofertas') {
          if (item['discount'] == null) return false;
        } else {
          final cat = (item['category'] ?? '').toString().toLowerCase();
          if (!cat.contains(_selectedCategoryFilter)) return false;
        }
      }

      return true;
    }).toList()
      ..sort((a, b) {
        if (_selectedSort == 'price_asc' || _selectedSort == 'price_desc') {
          final double priceA = _parsePrice(a['price']);
          final double priceB = _parsePrice(b['price']);
          return _selectedSort == 'price_asc'
              ? priceA.compareTo(priceB)
              : priceB.compareTo(priceA);
        }
        return 0;
      });
  }

  double _parsePrice(dynamic raw) {
    if (raw == null) return 0;
    final str = raw.toString().replaceAll('\$', '').replaceAll('.', '').replaceAll(',', '.').trim();
    return double.tryParse(str) ?? 0;
  }

  String _formatUnit(String unit) {
    if (unit.contains('por')) return unit;
    return 'por $unit';
  }

  void _openProductDetail(BuildContext context, Map<String, dynamic> itemForDetail) {
    final router = GoRouter.maybeOf(context);
    if (router != null) {
      context.push('/product_detail', extra: itemForDetail);
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ProductDetailScreen(product: itemForDetail),
        ),
      );
    }
  }

  void _handleAddToCart(BuildContext context, Map<String, dynamic> item) {
    final name = (item['title'] ?? item['name'] ?? '').toString();
    final currentMode = _selectedProductModes[name] ?? 'retail';
    final isWholesale = currentMode == 'wholesale';
    final providerName = widget.provider?['name'] ?? 'Huerta Los Arcos';

    final cartItem = Map<String, dynamic>.from(item);
    cartItem['name'] = name;
    cartItem['selectedMode'] = isWholesale ? 'wholesale' : 'retail';
    cartItem['saleType'] = isWholesale ? 'Por Mayor' : 'Al Detalle';
    cartItem['isWholesale'] = isWholesale;
    cartItem['price'] = isWholesale
        ? (item['wholesalePrice'] ?? item['price'])
        : item['price'];
    cartItem['provider'] = providerName;
    cartItem['supplier'] = providerName;

    addToCart(cartItem);

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.shopping_cart_checkout, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '¡${item['title'] ?? item['name']} agregado al carrito!',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF285E44),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cleanQuality = _normalizeQuality(widget.quality);
    final tierMeta = _getTierMeta(cleanQuality);
    final Color tierColor = tierMeta['primaryColor'];
    final Color surfaceColor = isDark ? const Color(0xFF14181F) : Colors.white;
    final Color borderColor = isDark ? const Color(0xFF262D38) : const Color(0xFFE2E8F0);
    final String providerName = widget.provider?['name'] ?? 'Huerta Los Arcos';

    final products = _filteredProducts;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1914) : const Color(0xFFF7FAF7),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0F231D) : Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tierMeta['title'],
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            Text(
              providerName,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline_rounded, color: tierColor),
            tooltip: 'Ver estándares de calidad',
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => QualityInfoBottomSheet(quality: cleanQuality),
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // 1. Educational Quality Banner
          SliverToBoxAdapter(
            child: _buildEducationalBanner(context, isDark, tierMeta, cleanQuality),
          ),

          // 2. Search and Filter Bar
          SliverToBoxAdapter(
            child: _buildSearchAndFilters(context, isDark, tierColor, surfaceColor, borderColor, products.length),
          ),

          // 3. Products Grid or Empty State
          if (products.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _buildEmptyState(context, isDark, tierColor),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 12,
                  mainAxisExtent: 352,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = products[index];
                    return _buildProductCard(context, theme, surfaceColor, borderColor, isDark, tierColor, item);
                  },
                  childCount: products.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEducationalBanner(
    BuildContext context,
    bool isDark,
    Map<String, dynamic> tierMeta,
    String cleanQuality,
  ) {
    final Color primaryColor = isDark && cleanQuality.toUpperCase().contains('SEGUNDA')
        ? const Color(0xFFF19D37)
        : tierMeta['primaryColor'];
    final Color bgColor = isDark ? tierMeta['darkBg'] : tierMeta['lightBg'];
    final Color borderColor = isDark ? tierMeta['darkBorderColor'] : tierMeta['borderColor'];
    final List<Map<String, dynamic>> standards = tierMeta['standards'];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: isDark ? 0.2 : 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: isDark ? 0.3 : 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(tierMeta['icon'], color: primaryColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            tierMeta['title'].toString().toUpperCase(),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                              color: primaryColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            tierMeta['badgeText'],
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tierMeta['tagline'],
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.grey[300] : const Color(0xFF334155),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            tierMeta['description'],
            style: TextStyle(
              fontSize: 12,
              height: 1.45,
              color: isDark ? Colors.grey[300] : const Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 12),
          // Standards Pill Badges
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: standards.map((s) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: borderColor.withValues(alpha: 0.8),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(s['icon'] as IconData, size: 12, color: primaryColor),
                    const SizedBox(width: 4),
                    Text(
                      s['label'].toString(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.grey[200] : const Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters(
    BuildContext context,
    bool isDark,
    Color tierColor,
    Color surfaceColor,
    Color borderColor,
    int count,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Box with SKU hint
          Container(
            height: 46,
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
              style: TextStyle(fontSize: 13, color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                hintText: 'Buscar por nombre o código SKU (ej. FRU-FRE)...',
                hintStyle: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey[500] : Colors.grey[400],
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  size: 20,
                  color: isDark ? Colors.grey[400] : const Color(0xFF285E44),
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Filters Scroll
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'Todos',
                  isSelected: _selectedSalesFilter == 'todos' && _selectedCategoryFilter == 'todos',
                  onTap: () {
                    setState(() {
                      _selectedSalesFilter = 'todos';
                      _selectedCategoryFilter = 'todos';
                    });
                  },
                ),
                const SizedBox(width: 6),
                _buildFilterChip(
                  label: 'Al Detalle',
                  icon: Icons.shopping_bag_outlined,
                  isSelected: _selectedSalesFilter == 'retail',
                  onTap: () {
                    setState(() {
                      _selectedSalesFilter = _selectedSalesFilter == 'retail' ? 'todos' : 'retail';
                    });
                  },
                ),
                const SizedBox(width: 6),
                _buildFilterChip(
                  label: 'Por Mayor',
                  icon: Icons.inventory_2_outlined,
                  isSelected: _selectedSalesFilter == 'wholesale',
                  onTap: () {
                    setState(() {
                      _selectedSalesFilter = _selectedSalesFilter == 'wholesale' ? 'todos' : 'wholesale';
                    });
                  },
                ),
                const SizedBox(width: 6),
                _buildFilterChip(
                  label: 'Frutas',
                  isSelected: _selectedCategoryFilter == 'frutas',
                  onTap: () {
                    setState(() {
                      _selectedCategoryFilter = _selectedCategoryFilter == 'frutas' ? 'todos' : 'frutas';
                    });
                  },
                ),
                const SizedBox(width: 6),
                _buildFilterChip(
                  label: 'Hortalizas',
                  isSelected: _selectedCategoryFilter == 'hortalizas',
                  onTap: () {
                    setState(() {
                      _selectedCategoryFilter = _selectedCategoryFilter == 'hortalizas' ? 'todos' : 'hortalizas';
                    });
                  },
                ),
                const SizedBox(width: 6),
                _buildFilterChip(
                  label: 'En Oferta',
                  icon: Icons.local_offer_outlined,
                  isSelected: _selectedCategoryFilter == 'ofertas',
                  onTap: () {
                    setState(() {
                      _selectedCategoryFilter = _selectedCategoryFilter == 'ofertas' ? 'todos' : 'ofertas';
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Results counter and Sort Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '$count ${count == 1 ? 'producto' : 'productos'}',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (_selectedSort == 'default') {
                      _selectedSort = 'price_asc';
                    } else if (_selectedSort == 'price_asc') {
                      _selectedSort = 'price_desc';
                    } else {
                      _selectedSort = 'default';
                    }
                  });
                },
                behavior: HitTestBehavior.opaque,
                child: Row(
                  children: [
                    Icon(
                      Icons.swap_vert_rounded,
                      size: 16,
                      color: _selectedSort != 'default' ? const Color(0xFF285E44) : Colors.grey,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      _selectedSort == 'price_asc'
                          ? 'Menor precio'
                          : (_selectedSort == 'price_desc' ? 'Mayor precio' : 'Ordenar'),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: _selectedSort != 'default' ? const Color(0xFF285E44) : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF285E44)
              : (isDark ? const Color(0xFF162B21) : const Color(0xFFEEF3EE)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF285E44)
                : (isDark ? const Color(0xFF2E4E41) : const Color(0xFFD4DFD4)),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 12,
                color: isSelected ? Colors.white : (isDark ? Colors.grey[300] : const Color(0xFF285E44)),
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? Colors.white : (isDark ? Colors.grey[300] : const Color(0xFF334155)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _getProductTags(Map<String, dynamic> data) {
    final rawTags = data['tags'];
    if (rawTags is List && rawTags.isNotEmpty) {
      return rawTags.map((e) => e.toString()).toList();
    }
    final List<String> tags = [];
    final cat = data['category']?.toString().trim() ?? '';
    if (cat.isNotEmpty) {
      tags.add(cat[0].toUpperCase() + cat.substring(1));
    }
    if (data['discount'] != null && data['discount'].toString().isNotEmpty) {
      tags.add('Oferta');
    }
    return tags;
  }

  String _formatUnitUpper(String unit) {
    final raw = unit.replaceAll('/', '').trim().toLowerCase();
    switch (raw) {
      case 'lb':
      case 'libra':
      case 'por libra':
        return 'POR LIBRA';
      case 'kg':
      case 'kilo':
      case 'por kilo':
        return 'POR KILO';
      case 'unidad':
      case 'por unidad':
        return 'POR UNIDAD';
      case 'atado':
      case 'por atado':
        return 'POR ATADO';
      case 'caja':
      case 'por caja':
        return 'POR CAJA';
      case 'saco':
      case 'sacos':
      case 'por saco':
        return 'POR SACO';
      default:
        if (raw.isEmpty) return 'POR UNIDAD';
        return raw.startsWith('por ') ? raw.toUpperCase() : 'POR ${raw.toUpperCase()}';
    }
  }

  Widget _buildDiscountPill(String discount) {
    final isTestBinding = WidgetsBinding.instance.runtimeType.toString().contains('Test');
    if (!isTestBinding) {
      return AnimatedDiscountBadge(discountText: discount);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFD9312).withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.85),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.bolt, color: Colors.white, size: 13),
          const SizedBox(width: 3),
          Text(
            discount,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(
    BuildContext context,
    ThemeData theme,
    Color surfaceColor,
    Color borderColor,
    bool isDark,
    Color tierColor,
    Map<String, dynamic> item,
  ) {
    final String productName = (item['title'] ?? item['name'] ?? '').toString();
    final String sku = _getProductSku(item);
    final String qualityStr = (item['quality'] ?? widget.quality).toString();
    final String cleanQuality = _normalizeQuality(qualityStr);
    final Color qualityBadgeColor = cleanQuality == 'SEGUNDA'
        ? (isDark ? const Color(0xFFF19D37) : const Color(0xFFFF8A5B))
        : (cleanQuality == 'TERCERA'
            ? (isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626))
            : (isDark ? const Color(0xFF34D399) : tierColor));

    final salesMode = (item['salesMode'] ?? 'both').toString();
    final currentMode = (salesMode == 'both')
        ? (_selectedProductModes[productName] ?? 'retail')
        : (salesMode == 'wholesale_only' ? 'wholesale' : 'retail');
    final bool isWholesale = currentMode == 'wholesale';

    final String retailRawPrice = (item['price'] ?? '22.50').toString();
    final String retailPriceFormatted =
        retailRawPrice.startsWith('\$') ? retailRawPrice : '\$$retailRawPrice';
    final String wholesaleRawPrice = (item['wholesalePrice'] ?? retailRawPrice).toString();
    final String wholesalePriceFormatted =
        wholesaleRawPrice.startsWith('\$') ? wholesaleRawPrice : '\$$wholesaleRawPrice';

    final String displayPriceFormatted =
        isWholesale ? wholesalePriceFormatted : retailPriceFormatted;

    final String? rawOldPrice = isWholesale
        ? (item['wholesaleOldPrice'] ?? item['oldPrice'])?.toString()
        : item['oldPrice']?.toString();
    final String? displayOldPriceFormatted = (rawOldPrice != null && rawOldPrice.isNotEmpty)
        ? (rawOldPrice.startsWith('\$') ? rawOldPrice : '\$$rawOldPrice')
        : null;

    final String rawUnit = (item['unit'] ?? 'lb').toString().replaceAll('/', '').trim();
    final String displayUnitUpper = _formatUnitUpper(rawUnit);

    final tags = _getProductTags(item);
    final String ratingStr = (item['rating'] ?? '4.8').toString();
    final String reviewsCount = (item['reviewsCount'] ?? 128).toString();
    final String providerName = widget.provider?['name'] ?? 'Huerta Los Arcos';
    final String providerLocation =
        (widget.provider?['sector'] ?? widget.provider?['location'] ?? 'Sector San Pedro').toString();

    final itemForDetail = {
      ...item,
      'name': productName,
      'title': productName,
      'price': retailPriceFormatted,
      'wholesalePrice': wholesalePriceFormatted,
      'unit': isWholesale
          ? (item['wholesaleMin']?.toString() ?? 'Por Mayor')
          : _formatUnit(rawUnit),
      'image': item['image'] ?? item['img'],
      'img': item['image'] ?? item['img'],
      'quality': qualityStr,
      'badge': qualityStr.toUpperCase(),
      'sku': sku,
      'rating': ratingStr,
      'tags': tags,
      'salesMode': salesMode,
      'saleType': isWholesale ? 'mayor' : 'detalle',
      'selectedMode': currentMode,
      'supplier': providerName,
      'location': providerLocation,
    };

    final String? discount = item['discount']?.toString();

    return GestureDetector(
      onTap: () => _openProductDetail(context, itemForDetail),
      child: Container(
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor, width: 1.0),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Product Image & Badges (homologado con Home)
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(17)),
                  child: SizedBox(
                    height: 105,
                    width: double.infinity,
                    child: _buildProductImage(item['image'] ?? item['img']),
                  ),
                ),
                if (discount != null && discount.isNotEmpty)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: _buildDiscountPill(discount),
                  ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: ValueListenableBuilder<List<Map<String, dynamic>>>(
                    valueListenable: globalFavorites,
                    builder: (context, favs, child) {
                      final bool fav = isFavorite(productName);
                      return AnimatedFavoriteButton(
                        isFavorite: fav,
                        size: 16,
                        backgroundColor: isDark
                            ? const Color(0xFF1E293B).withValues(alpha: 0.9)
                            : Colors.white.withValues(alpha: 0.9),
                        onTap: () {
                          toggleFavorite(itemForDetail);
                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                fav
                                    ? 'Eliminado de favoritos: $productName'
                                    : 'Agregado a favoritos: $productName',
                              ),
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
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF016042),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 4),
                      ],
                    ),
                    child: const Icon(
                      Icons.verified,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
              ],
            ),

            // 2. Card Content Body (homologado con Imagen 2 / Home)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title + SKU on left | Old Price + Price + Unit on right
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                productName,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? const Color(0xFFF3F4F6) : Colors.black,
                                  height: 1.15,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'SKU: $sku',
                                style: TextStyle(
                                  fontFamily: 'Manrope',
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? const Color(0xFF6B7280) : const Color(0xFF94A3B8),
                                  letterSpacing: 0.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (displayOldPriceFormatted != null)
                              Text(
                                displayOldPriceFormatted,
                                style: TextStyle(
                                  color: isDark ? const Color(0xFF6B7280) : Colors.grey,
                                  fontSize: 9.5,
                                  decoration: TextDecoration.lineThrough,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              transitionBuilder: (child, animation) =>
                                  FadeTransition(opacity: animation, child: child),
                              child: FittedBox(
                                key: ValueKey<String>(displayPriceFormatted),
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerRight,
                                child: Text(
                                  displayPriceFormatted,
                                  maxLines: 1,
                                  softWrap: false,
                                  style: TextStyle(
                                    color: isWholesale
                                        ? const Color(0xFF0284C7)
                                        : (isDark
                                            ? const Color(0xFFF3F4F6)
                                            : theme.colorScheme.primary),
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w900,
                                    height: 1.1,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 2),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: Column(
                                key: ValueKey<String>(
                                  isWholesale
                                      ? 'wholesale_${item['wholesaleMin']}'
                                      : 'retail_$rawUnit',
                                ),
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  if (isWholesale) ...[
                                    Text(
                                      'POR MAYOR',
                                      style: TextStyle(
                                        fontSize: 7.5,
                                        fontWeight: FontWeight.w800,
                                        color: isDark
                                            ? const Color(0xFF38BDF8)
                                            : const Color(0xFF0284C7),
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                    if (item['wholesaleMin'] != null)
                                      Text(
                                        '(${item['wholesaleMin']})',
                                        style: TextStyle(
                                          fontSize: 6.5,
                                          fontWeight: FontWeight.w700,
                                          color: (isDark
                                                  ? const Color(0xFF38BDF8)
                                                  : const Color(0xFF0284C7))
                                              .withValues(alpha: 0.85),
                                          letterSpacing: 0.1,
                                        ),
                                      ),
                                  ] else ...[
                                    Text(
                                      displayUnitUpper,
                                      style: TextStyle(
                                        fontSize: 7.5,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[600],
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Sales Mode Switcher [ Detalle | Por Mayor ]
                    _buildSalesModeSwitcher(salesMode, productName, isDark),

                    // Category / Offer Tags
                    if (tags.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: tags.take(2).map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0x2410B981)
                                  : theme.colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: isDark
                                    ? const Color(0x4D10B981)
                                    : theme.colorScheme.primary.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              tag,
                              style: TextStyle(
                                color: isDark
                                    ? const Color(0xFF34D399)
                                    : theme.colorScheme.primary,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                    const SizedBox(height: 5),

                    // Rating & Reviews Row
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => ProductReviewsModal(product: itemForDetail),
                        );
                      },
                      behavior: HitTestBehavior.opaque,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, color: Colors.orange, size: 13),
                            const SizedBox(width: 4),
                            Text(
                              ratingStr,
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '($reviewsCount reseñas)',
                              style: const TextStyle(
                                fontSize: 9,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    Divider(
                      color: isDark ? const Color(0xFF262D38) : const Color(0xFFE0E3DF),
                      thickness: 0.8,
                      height: 12,
                    ),

                    // Quality Metadata Row
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
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: qualityBadgeColor.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.workspace_premium, color: qualityBadgeColor, size: 14),
                          ),
                          const SizedBox(width: 8),
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
                                    letterSpacing: 0.4,
                                    height: 1.05,
                                  ),
                                ),
                                Text(
                                  qualityStr.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    color: qualityBadgeColor,
                                    height: 1.15,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Agregar al carrito Button
                    SizedBox(
                      width: double.infinity,
                      height: 34,
                      child: ElevatedButton.icon(
                        onPressed: () => _handleAddToCart(context, item),
                        icon: const Icon(Icons.shopping_cart_outlined, size: 15),
                        label: const Text(
                          'Agregar al carrito',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark
                              ? const Color(0xFF10B981)
                              : const Color(0xFF047857),
                          foregroundColor: isDark
                              ? const Color(0xFF06281E)
                              : Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
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

  Widget _buildSalesModeOption({
    required String label,
    required IconData icon,
    required bool isSelected,
    required Color activeLightColor,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0x2410B981) : activeLightColor)
              : (isDark ? const Color(0xFF1C222B) : Colors.transparent),
          borderRadius: BorderRadius.circular(6),
          border: isDark
              ? Border.all(
                  color: isSelected ? const Color(0x4D10B981) : const Color(0xFF2E3744),
                  width: 0.8,
                )
              : null,
          boxShadow: isSelected && !isDark
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 11,
              color: isSelected
                  ? (isDark ? const Color(0xFF34D399) : Colors.white)
                  : (isDark ? const Color(0xFFD1D5DB) : Colors.grey[600]),
            ),
            const SizedBox(width: 3),
            Text(
              label,
              style: GoogleFonts.inter(
                color: isSelected
                    ? (isDark ? const Color(0xFF34D399) : Colors.white)
                    : (isDark ? const Color(0xFFD1D5DB) : Colors.grey[600]),
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesModeSwitcher(dynamic salesMode, String productName, bool isDark) {
    if (salesMode == 'both') {
      final currentMode = _selectedProductModes[productName] ?? 'retail';
      final bool isRetailSelected = currentMode == 'retail';
      final bool isWholesaleSelected = currentMode == 'wholesale';

      return Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF14181F) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark ? const Color(0xFF262D38) : const Color(0xFFE5E7EB),
            width: 0.8,
          ),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSalesModeOption(
                label: 'Detalle',
                icon: Icons.shopping_bag_outlined,
                isSelected: isRetailSelected,
                activeLightColor: const Color(0xFF059669),
                isDark: isDark,
                onTap: () {
                  setState(() {
                    _selectedProductModes[productName] = 'retail';
                  });
                },
              ),
              const SizedBox(width: 2),
              _buildSalesModeOption(
                label: 'Por Mayor',
                icon: Icons.inventory_2_outlined,
                isSelected: isWholesaleSelected,
                activeLightColor: const Color(0xFF0369A1),
                isDark: isDark,
                onTap: () {
                  setState(() {
                    _selectedProductModes[productName] = 'wholesale';
                  });
                },
              ),
            ],
          ),
        ),
      );
    }

    final bool isRetailOnly = salesMode == 'retail_only' || salesMode == 'retail';
    final String label = isRetailOnly ? 'Solo al Detalle' : 'Solo por Mayor';
    final IconData icon = isRetailOnly ? Icons.shopping_bag_outlined : Icons.inventory_2_outlined;

    final Color bgColor = isRetailOnly
        ? (isDark ? const Color(0x2410B981) : const Color(0xFFECFDF5))
        : (isDark ? const Color(0xFF1C222B) : const Color(0xFFF0F9FF));
    final Color borderColor = isRetailOnly
        ? (isDark ? const Color(0x4D10B981) : const Color(0xFFA7F3D0))
        : (isDark ? const Color(0xFF2E3744) : const Color(0xFFBAE6FD));
    final Color textColor = isRetailOnly
        ? (isDark ? const Color(0xFF34D399) : const Color(0xFF047857))
        : (isDark ? const Color(0xFFD1D5DB) : const Color(0xFF0369A1));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderColor, width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: textColor),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: GoogleFonts.inter(
                color: textColor,
                fontSize: 10,
                fontWeight: FontWeight.w600,
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

  Widget _buildProductImage(String? src) {
    final imgSrc = (src != null && src.isNotEmpty) ? src : 'https://via.placeholder.com/300';
    if (imgSrc.startsWith('assets/')) {
      return Image.asset(
        imgSrc,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[200]),
      );
    }
    return Image.network(
      imgSrc,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[200]),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark, Color tierColor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: tierColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.search_off_rounded, size: 36, color: tierColor),
            ),
            const SizedBox(height: 16),
            Text(
              'No se encontraron productos',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Prueba buscando por otro término o código SKU (ej. FRU-FRE, RAI-ZAN, HOR-TOM).',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                  _selectedSalesFilter = 'todos';
                  _selectedCategoryFilter = 'todos';
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF285E44),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Restablecer Búsqueda', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
