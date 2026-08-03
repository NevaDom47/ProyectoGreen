import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

enum MarketPricesState { normal, loading, noConnection, empty }

class MarketAnalysisScreen extends StatefulWidget {
  const MarketAnalysisScreen({super.key});

  @override
  State<MarketAnalysisScreen> createState() => _MarketAnalysisScreenState();
}

class _MarketAnalysisScreenState extends State<MarketAnalysisScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  MarketPricesState _currentState = MarketPricesState.normal;
  bool _isWholesale = false; // false = Al Detalle (Retail), true = Al por Mayor (Wholesale)
  String _selectedCategory = 'Todos';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _expandedProducts = {'Arroz'}; // Expanded by default for first item

  final List<Map<String, dynamic>> _allProducts = [
    {
      'id': 'arroz',
      'name': 'Arroz',
      'avgPrice': '20.70',
      'unit': 'kg',
      'category': 'Granos',
      'imageUrl': 'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=200',
      'icon': Icons.grain,
      'items': [
        {
          'name': 'Arroz Campo',
          'sku': 'SKU-A01',
          'price': '22.50',
          'prevPrice': '22.037',
          'trend': 2.1,
        },
        {
          'name': 'Arroz Amarillo',
          'sku': 'SKU-A02',
          'price': '18.90',
          'prevPrice': '18.995',
          'trend': -0.5,
        },
      ],
    },
    {
      'id': 'frijol',
      'name': 'Frijol',
      'avgPrice': '35.00',
      'unit': 'kg',
      'category': 'Granos',
      'icon': Icons.grass,
      'items': [
        {
          'name': 'Frijol Negro',
          'sku': 'SKU-F01',
          'price': '35.00',
          'trend': 0.0,
        },
        {
          'name': 'Frijol Flor de Mayo',
          'sku': 'SKU-F02',
          'price': '38.50',
          'trend': 1.8,
        },
      ],
    },
    {
      'id': 'maiz',
      'name': 'Maíz Blanco',
      'avgPrice': '16.50',
      'unit': 'kg',
      'category': 'Granos',
      'icon': Icons.eco,
      'items': [
        {
          'name': 'Maíz Nixtamalero',
          'sku': 'SKU-M01',
          'price': '16.50',
          'trend': -1.2,
        },
      ],
    },
    {
      'id': 'tomate',
      'name': 'Tomate Bola',
      'avgPrice': '24.50',
      'unit': 'kg',
      'category': 'Verduras',
      'imageUrl': 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=200',
      'icon': Icons.local_florist,
      'items': [
        {
          'name': 'Tomate Bola Mayorista',
          'sku': 'SKU-T01',
          'price': '24.50',
          'trend': 2.4,
        },
        {
          'name': 'Tomate Saladette',
          'sku': 'SKU-T02',
          'price': '22.00',
          'trend': 0.8,
        },
      ],
    },
    {
      'id': 'papa',
      'name': 'Papa Blanca',
      'avgPrice': '18.20',
      'unit': 'kg',
      'category': 'Verduras',
      'imageUrl': 'https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=200',
      'icon': Icons.nature,
      'items': [
        {
          'name': 'Papa Alfa Local',
          'sku': 'SKU-P01',
          'price': '18.20',
          'trend': -1.1,
        },
      ],
    },
    {
      'id': 'aguacate',
      'name': 'Aguacate Hass',
      'avgPrice': '72.00',
      'unit': 'kg',
      'category': 'Frutas',
      'imageUrl': 'https://images.unsplash.com/photo-1523049673857-eb18f1d7b578?w=200',
      'icon': Icons.energy_savings_leaf,
      'items': [
        {
          'name': 'Aguacate Hass Exportación',
          'sku': 'SKU-AG01',
          'price': '72.00',
          'trend': 0.0,
        },
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  String _getItemMarketAvgPrice(dynamic rawPrice) {
    final base = double.tryParse(rawPrice?.toString() ?? '0') ?? 0.0;
    // Multipliers:
    // Wholesale avg multiplier = 1.025 (Merca Santo Domingo, Mercado Nuevo, etc.)
    // Retail avg multiplier = 1.30 (Supermercados / Venta al detalle)
    final double multiplier = _isWholesale ? 1.025 : 1.30;
    final avg = base * multiplier;
    return avg.toStringAsFixed(2);
  }

  String _getCategoryAvgPrice(Map<String, dynamic> product) {
    final items = product['items'] as List<dynamic>? ?? [];
    if (items.isEmpty) return product['avgPrice']?.toString() ?? '0.00';
    double sum = 0;
    for (final item in items) {
      final p = item['price'];
      sum += double.tryParse(_getItemMarketAvgPrice(p)) ?? 0.0;
    }
    return (sum / items.length).toStringAsFixed(2);
  }

  double _getItemVariation(Map<String, dynamic> item) {
    if (item['prevPrice'] != null) {
      final currentBase = double.tryParse(item['price']?.toString() ?? '0') ?? 0.0;
      final prevBase = double.tryParse(item['prevPrice']?.toString() ?? '0') ?? 0.0;
      if (prevBase > 0) {
        final double multiplier = _isWholesale ? 1.025 : 1.30;
        final currentAvg = currentBase * multiplier;
        final prevAvg = prevBase * multiplier;
        return ((currentAvg - prevAvg) / prevAvg) * 100;
      }
    }
    return (item['trend'] as num?)?.toDouble() ?? 0.0;
  }

  List<Map<String, dynamic>> get _filteredProducts {
    return _allProducts.where((product) {
      final matchesCategory = _selectedCategory == 'Todos' || product['category'] == _selectedCategory;
      final matchesQuery = _searchQuery.isEmpty ||
          product['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (product['items'] as List).any((item) =>
              item['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
              item['sku'].toString().toLowerCase().contains(_searchQuery.toLowerCase()));
      return matchesCategory && matchesQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Material 3 / Emerald Harvest Color Palette
    final bgColor = isDark ? const Color(0xFF0F1C18) : const Color(0xFFF8F9FF);
    final primaryColor = isDark ? const Color(0xFF8BD6B6) : const Color(0xFF004532);
    final primaryContainer = isDark ? const Color(0xFF065F46) : const Color(0xFF065F46);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: primaryColor),
            onPressed: () => context.pop(),
          ),
        ),
        title: Text(
          'Análisis de Mercado',
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.manrope(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: isDark ? Colors.white : const Color(0xFF121C28),
          ),
        ),
        actions: [
          // Demo State Switcher Menu to easily test all 4 designs/states requested
          PopupMenuButton<MarketPricesState>(
            icon: Icon(Icons.tune, color: primaryColor),
            tooltip: 'Cambiar Estado de Vista',
            onSelected: (MarketPricesState state) {
              setState(() {
                _currentState = state;
              });
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: MarketPricesState.normal,
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline, color: Colors.green, size: 20),
                    SizedBox(width: 8),
                    Text('Estado Normal'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: MarketPricesState.loading,
                child: Row(
                  children: [
                    Icon(Icons.hourglass_top, color: Colors.amber, size: 20),
                    SizedBox(width: 8),
                    Text('Estado Cargando'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: MarketPricesState.noConnection,
                child: Row(
                  children: [
                    Icon(Icons.wifi_off, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text('Estado Sin Conexión'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: MarketPricesState.empty,
                child: Row(
                  children: [
                    Icon(Icons.search_off, color: Colors.grey, size: 20),
                    SizedBox(width: 8),
                    Text('Estado Vacío (No Encontrado)'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Column(
            children: [
              TabBar(
                controller: _tabController,
                labelColor: primaryColor,
                unselectedLabelColor: isDark ? Colors.grey[400] : const Color(0xFF6F7973),
                indicatorColor: primaryColor,
                indicatorWeight: 3,
                labelStyle: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 14),
                unselectedLabelStyle: GoogleFonts.manrope(fontWeight: FontWeight.w600, fontSize: 14),
                tabs: const [
                  Tab(text: 'Precios'),
                  Tab(text: 'Noticias'),
                  Tab(text: 'Tendencias'),
                ],
              ),
              Divider(height: 1, color: primaryColor.withValues(alpha: 0.1)),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPricesTab(isDark, primaryColor, primaryContainer),
          _buildNoticiasTab(isDark, primaryColor),
          _buildTendenciasTab(isDark, primaryColor),
        ],
      ),
    );
  }

  Widget _buildPricesTab(bool isDark, Color primaryColor, Color primaryContainer) {
    final surfaceVariant = isDark ? const Color(0xFF27313E) : const Color(0xFFD9E3F4);
    final surfaceContainerLowest = isDark ? const Color(0xFF192420) : Colors.white;
    final surfaceContainerHigh = isDark ? const Color(0xFF23322B) : const Color(0xFFDFE9FA);
    final onSurface = isDark ? const Color(0xFFEAF1FF) : const Color(0xFF121C28);
    final onSurfaceVariant = isDark ? const Color(0xFF90A397) : const Color(0xFF3F4944);

    final filtered = _filteredProducts;
    final effectiveState = (_currentState == MarketPricesState.normal && filtered.isEmpty)
        ? MarketPricesState.empty
        : _currentState;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Text(
            'Precios de Mercado',
            style: GoogleFonts.manrope(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Consulta las tendencias y variaciones de precios actuales.',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),

          // Search Bar
          Opacity(
            opacity: effectiveState == MarketPricesState.loading ? 0.5 : 1.0,
            child: Container(
              decoration: BoxDecoration(
                color: surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: surfaceVariant),
              ),
              child: TextField(
                controller: _searchController,
                enabled: effectiveState != MarketPricesState.loading,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                style: GoogleFonts.inter(fontSize: 14, color: onSurface),
                decoration: InputDecoration(
                  hintText: 'Buscar productos...',
                  hintStyle: GoogleFonts.inter(color: onSurfaceVariant, fontSize: 14),
                  prefixIcon: Icon(Icons.search, color: onSurfaceVariant, size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, size: 18, color: onSurfaceVariant),
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
          ),
          const SizedBox(height: 16),

          // Price Type Switcher (Segmented Control: Al Detalle vs Al por Mayor)
          Opacity(
            opacity: effectiveState == MarketPricesState.loading ? 0.5 : 1.0,
            child: Column(
              children: [
                _buildPriceTypeSegmentedControl(
                  isDark,
                  primaryColor,
                  primaryContainer,
                  surfaceContainerHigh,
                  onSurfaceVariant,
                  surfaceContainerLowest,
                  surfaceVariant,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      _isWholesale ? Icons.inventory_2_outlined : Icons.shopping_bag_outlined,
                      size: 14,
                      color: primaryColor,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _isWholesale
                            ? 'Precios promedio de venta al por mayor (Mercados Centrales)'
                            : 'Precios promedio de venta al detalle (Supermercados y tiendas)',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Category Chips
          Opacity(
            opacity: effectiveState == MarketPricesState.loading ? 0.5 : 1.0,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['Todos', 'Granos', 'Frutas', 'Verduras'].map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(
                        cat,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : onSurfaceVariant,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: primaryContainer,
                      backgroundColor: surfaceContainerHigh,
                      showCheckmark: false,
                      side: BorderSide.none,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      onSelected: effectiveState == MarketPricesState.loading
                          ? null
                          : (selected) {
                              if (selected) {
                                setState(() {
                                  _selectedCategory = cat;
                                });
                              }
                            },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Dynamic State Body
          switch (effectiveState) {
            MarketPricesState.normal => _buildProductList(filtered, isDark, primaryColor, surfaceContainerLowest, surfaceVariant, onSurface, onSurfaceVariant),
            MarketPricesState.loading => _buildLoadingSkeleton(isDark, surfaceContainerLowest, surfaceVariant, primaryContainer),
            MarketPricesState.noConnection => _buildNoConnectionState(primaryColor, onSurface, onSurfaceVariant),
            MarketPricesState.empty => _buildEmptyState(primaryColor, onSurface, onSurfaceVariant),
          },

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildPriceTypeSegmentedControl(
    bool isDark,
    Color primaryColor,
    Color primaryContainer,
    Color surfaceContainerHigh,
    Color onSurfaceVariant,
    Color surfaceContainerLowest,
    Color surfaceVariant,
  ) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B2822) : const Color(0xFFEBF1FA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: surfaceVariant),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (_isWholesale) {
                  setState(() {
                    _isWholesale = false;
                  });
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: !_isWholesale
                      ? (isDark ? primaryContainer : primaryColor)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: !_isWholesale
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_bag_outlined,
                      size: 18,
                      color: !_isWholesale ? Colors.white : onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Al Detalle',
                      style: GoogleFonts.manrope(
                        fontWeight: !_isWholesale ? FontWeight.bold : FontWeight.w600,
                        fontSize: 14,
                        color: !_isWholesale ? Colors.white : onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (!_isWholesale) {
                  setState(() {
                    _isWholesale = true;
                  });
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _isWholesale
                      ? (isDark ? primaryContainer : primaryColor)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: _isWholesale
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 18,
                      color: _isWholesale ? Colors.white : onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Al por Mayor',
                      style: GoogleFonts.manrope(
                        fontWeight: _isWholesale ? FontWeight.bold : FontWeight.w600,
                        fontSize: 14,
                        color: _isWholesale ? Colors.white : onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- 1. SUCCESS / NORMAL PRODUCT LIST ---
  Widget _buildProductList(
    List<Map<String, dynamic>> products,
    bool isDark,
    Color primaryColor,
    Color surfaceContainerLowest,
    Color surfaceVariant,
    Color onSurface,
    Color onSurfaceVariant,
  ) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final product = products[index];
        final productId = product['id'] as String;
        final isExpanded = _expandedProducts.contains(productId);
        final items = product['items'] as List;

        return Container(
          decoration: BoxDecoration(
            color: surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: surfaceVariant),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              // Header Card Toggle
              InkWell(
                onTap: () {
                  setState(() {
                    if (isExpanded) {
                      _expandedProducts.remove(productId);
                    } else {
                      _expandedProducts.add(productId);
                    }
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      // Product Image or Icon Fallback
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: product['imageUrl'] != null
                              ? Image.network(
                                  product['imageUrl'],
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Icon(product['icon'] as IconData, color: primaryColor),
                                )
                              : Icon(product['icon'] as IconData, color: primaryColor),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Name & Avg Price
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product['name'],
                              style: GoogleFonts.manrope(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: onSurface,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _isWholesale
                                  ? 'Venta Promedio al Por Mayor \$${_getCategoryAvgPrice(product)}'
                                  : 'Venta Promedio al Detalle \$${_getCategoryAvgPrice(product)}',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: onSurfaceVariant,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),

              // Expanded Sub-items
              if (isExpanded)
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF141F1B) : const Color(0xFFF8F9FF),
                    border: Border(top: BorderSide(color: surfaceVariant)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    children: items.map<Widget>((item) {
                      final double trend = _getItemVariation(item);
                      final isPositive = trend > 0;
                      final isNegative = trend < 0;
                      final trendColor = isPositive
                          ? const Color(0xFF16A34A)
                          : (isNegative ? const Color(0xFFBA1A1A) : onSurfaceVariant);

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['name'],
                                    style: GoogleFonts.inter(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: onSurface,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        item['sku'],
                                        style: GoogleFonts.jetBrainsMono(
                                          fontSize: 12,
                                          color: onSurfaceVariant,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(width: 8),
                                      Builder(
                                         builder: (context) {
                                           final String salesMode = item['salesMode']?.toString() ?? 'both';
                                           final bool isRetailOnly = salesMode == 'retail_only' || salesMode == 'retail';
                                           final bool isWholesaleOnly = salesMode == 'wholesale_only' || salesMode == 'wholesale';

                                           final String badgeText = isRetailOnly
                                               ? 'SOLO DETALLE'
                                               : (isWholesaleOnly ? 'SOLO MAYOR' : (_isWholesale ? 'MAYOR' : 'DETALLE'));

                                           final Color badgeBg = isRetailOnly
                                               ? (isDark ? const Color(0xFF064E3B).withValues(alpha: 0.35) : const Color(0xFFECFDF5))
                                               : (isWholesaleOnly
                                                   ? (isDark ? const Color(0xFF075985).withValues(alpha: 0.35) : const Color(0xFFF0F9FF))
                                                   : (_isWholesale
                                                       ? (isDark ? const Color(0xFF00415F) : const Color(0xFFE0F2FE))
                                                       : (isDark ? const Color(0xFF065F46) : const Color(0xFFDCFCE7))));

                                           final Color badgeTextColor = isRetailOnly
                                               ? (isDark ? const Color(0xFF6EE7B7) : const Color(0xFF047857))
                                               : (isWholesaleOnly
                                                   ? (isDark ? const Color(0xFF7DD3FC) : const Color(0xFF0369A1))
                                                   : (_isWholesale
                                                       ? (isDark ? const Color(0xFF7DD3FC) : const Color(0xFF0369A1))
                                                       : (isDark ? const Color(0xFF8BD6B6) : const Color(0xFF15803D))));

                                           return Container(
                                             padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                             decoration: BoxDecoration(
                                               color: badgeBg,
                                               borderRadius: BorderRadius.circular(4),
                                               border: (isRetailOnly || isWholesaleOnly)
                                                   ? Border.all(
                                                       color: isRetailOnly
                                                           ? (isDark ? const Color(0xFF059669).withValues(alpha: 0.4) : const Color(0xFFA7F3D0))
                                                           : (isDark ? const Color(0xFF0284C7).withValues(alpha: 0.4) : const Color(0xFFBAE6FD)),
                                                       width: 0.8,
                                                     )
                                                   : null,
                                             ),
                                             child: Text(
                                               badgeText,
                                               style: GoogleFonts.jetBrainsMono(
                                                 fontSize: 9,
                                                 fontWeight: FontWeight.bold,
                                                 color: badgeTextColor,
                                               ),
                                             ),
                                           );
                                         },
                                       ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        style: GoogleFonts.manrope(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: primaryColor,
                                        ),
                                        children: [
                                          TextSpan(text: '\$${_getItemMarketAvgPrice(item['price'])}'),
                                          TextSpan(
                                            text: '/${product['unit']}',
                                            style: GoogleFonts.inter(
                                              fontSize: 11,
                                              fontWeight: FontWeight.normal,
                                              color: onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Icon(
                                          isPositive
                                              ? Icons.trending_up
                                              : (isNegative ? Icons.trending_down : Icons.horizontal_rule),
                                          size: 14,
                                          color: trendColor,
                                        ),
                                        const SizedBox(width: 2),
                                        Text(
                                          '${isPositive ? '+' : ''}${trend.toStringAsFixed(1)}%',
                                          style: GoogleFonts.jetBrainsMono(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: trendColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.storefront, size: 20),
                                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                                  padding: EdgeInsets.zero,
                                  style: IconButton.styleFrom(
                                    backgroundColor: isDark
                                        ? const Color(0xFF23322B)
                                        : const Color(0xFFDFE9FA),
                                    foregroundColor: primaryColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: () {
                                    context.push(
                                      '/market-price-detail',
                                      extra: {
                                        'item': item,
                                        'product': product,
                                        'isWholesale': _isWholesale,
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // --- 2. LOADING STATE (SKELETON) ---
  Widget _buildLoadingSkeleton(bool isDark, Color surfaceContainerLowest, Color surfaceVariant, Color primaryContainer) {
    return Column(
      children: [
        // Skeleton Card 1 (Expanded Style)
        Container(
          decoration: BoxDecoration(
            color: surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: surfaceVariant),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: primaryContainer.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 100,
                            height: 18,
                            decoration: BoxDecoration(
                              color: primaryContainer.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: 140,
                            height: 14,
                            decoration: BoxDecoration(
                              color: primaryContainer.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: primaryContainer.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF141F1B) : const Color(0xFFF8F9FF),
                  border: Border(top: BorderSide(color: surfaceVariant)),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: List.generate(2, (index) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 110,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: primaryContainer.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                width: 60,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: primaryContainer.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 60,
                              height: 20,
                              decoration: BoxDecoration(
                                color: primaryContainer.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: primaryContainer.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Skeleton Card 2 (Collapsed Style)
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: surfaceVariant),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: primaryContainer.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 90,
                      height: 18,
                      decoration: BoxDecoration(
                        color: primaryContainer.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 120,
                      height: 14,
                      decoration: BoxDecoration(
                        color: primaryContainer.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: primaryContainer.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- 3. NO CONNECTION STATE ---
  Widget _buildNoConnectionState(Color primaryColor, Color onSurface, Color onSurfaceVariant) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: const BoxDecoration(
              color: Color(0xFFFFDAD6), // error-container
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.signal_wifi_off_rounded,
              size: 48,
              color: Color(0xFFBA1A1A), // error
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Error de conexión',
            style: GoogleFonts.manrope(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'No pudimos sincronizar los precios en vivo. Por favor, verifica tu conexión a internet.',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _currentState = MarketPricesState.loading;
              });
              Future.delayed(const Duration(seconds: 1), () {
                if (mounted) {
                  setState(() {
                    _currentState = MarketPricesState.normal;
                  });
                }
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 0,
            ),
            child: Text(
              'Intentar de nuevo',
              style: GoogleFonts.jetBrainsMono(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- 4. EMPTY / NOT FOUND STATE ---
  Widget _buildEmptyState(Color primaryColor, Color onSurface, Color onSurfaceVariant) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.energy_savings_leaf,
              size: 48,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No hay datos disponibles',
            style: GoogleFonts.manrope(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'No se encontraron productos que coincidan con "$_searchQuery".'
                : 'No se encontraron variaciones de precios para esta categoría en este momento.',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              _searchController.clear();
              setState(() {
                _searchQuery = '';
                _selectedCategory = 'Todos';
                _currentState = MarketPricesState.normal;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 0,
            ),
            child: Text(
              'Reintentar',
              style: GoogleFonts.jetBrainsMono(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- NOTICIAS & TENDENCIAS TABS ---
  Widget _buildNoticiasTab(bool isDark, Color primaryColor) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Text('Noticias de Mercado'),
      ),
    );
  }

  Widget _buildTendenciasTab(bool isDark, Color primaryColor) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Text('Tendencias de Mercado'),
      ),
    );
  }
}

