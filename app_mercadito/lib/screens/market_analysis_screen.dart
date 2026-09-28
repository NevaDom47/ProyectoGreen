import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/market_news_model.dart';
import '../services/market_news_service.dart';
import '../widgets/infinite_marquee_ticker.dart';

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

  // --- Estado de Noticias ---
  String _selectedNewsCategory = 'Todas';
  String _newsSearchQuery = '';
  final TextEditingController _newsSearchController = TextEditingController();

  // --- Estado de Tendencias ---
  String _selectedTrendFilter = 'Todos'; // 'Todos', 'Alza', 'Baja', 'Sin cambios'

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
    _newsSearchController.dispose();
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
    final bgColor = isDark ? const Color(0xFF0F1C18) : const Color(0xFFF6F8F7);
    final primaryColor = isDark ? const Color(0xFF8BD6B6) : const Color(0xFF016042);
    final primaryContainer = isDark ? const Color(0xFF047857) : const Color(0xFF016042);

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
    final surfaceVariant = isDark ? const Color(0xFF27313E) : const Color(0xFFCCDFD9);
    final surfaceContainerLowest = isDark ? const Color(0xFF192420) : Colors.white;
    final surfaceContainerHigh = isDark ? const Color(0xFF23322B) : const Color(0xFFF1F4F0);
    final onSurface = isDark ? const Color(0xFFEAF1FF) : const Color(0xFF121C28);
    final onSurfaceVariant = isDark ? const Color(0xFFA3A3A3) : const Color(0xFF737373);

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
                        style: GoogleFonts.manrope(
                          fontSize: 12.5,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                          color: isSelected
                              ? const Color(0xFFFFFFFF)
                              : (isDark ? const Color(0xFFA3A3A3) : const Color(0xFF737373)),
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: isDark ? const Color(0xFF047857) : const Color(0xFF016042),
                      backgroundColor: isDark ? const Color(0xFF16251F) : const Color(0xFFF1F4F0),
                      showCheckmark: false,
                      side: BorderSide(
                        color: isSelected
                            ? (isDark ? const Color(0xFF047857) : const Color(0xFF016042))
                            : (isDark ? const Color(0xFF233E33) : const Color(0xFFCCDFD9)),
                        width: 1,
                      ),
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
    final containerBg = isDark ? const Color(0xFF16251F) : const Color(0xFFF1F4F0);
    final containerBorder = isDark ? const Color(0xFF233E33) : const Color(0xFFCCDFD9);
    final selectedBg = isDark ? const Color(0xFF047857) : const Color(0xFF016042);
    final unselectedColor = isDark ? const Color(0xFFA3A3A3) : const Color(0xFF737373);

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: containerBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: containerBorder, width: 1),
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
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: !_isWholesale ? selectedBg : Colors.transparent,
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
                      color: !_isWholesale ? Colors.white : unselectedColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Al Detalle',
                      style: GoogleFonts.manrope(
                        fontWeight: !_isWholesale ? FontWeight.bold : FontWeight.w600,
                        fontSize: 14,
                        color: !_isWholesale ? Colors.white : unselectedColor,
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
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _isWholesale ? selectedBg : Colors.transparent,
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
                      color: _isWholesale ? Colors.white : unselectedColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Al por Mayor',
                      style: GoogleFonts.manrope(
                        fontWeight: _isWholesale ? FontWeight.bold : FontWeight.w600,
                        fontSize: 14,
                        color: _isWholesale ? Colors.white : unselectedColor,
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
    final newsList = MarketNewsService.instance.searchNews(
      _newsSearchQuery,
      category: _selectedNewsCategory,
    );

    final cardBg = isDark ? const Color(0xFF162D25) : Colors.white;
    final cardBorder = isDark ? const Color(0xFF224438) : const Color(0xFFE2E8F0);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Buscador de Noticias
          _buildNewsSearchBar(isDark, primaryColor),

          const SizedBox(height: 14),

          // 3. Filtros por Categoría
          _buildNewsCategoryFilters(isDark, primaryColor),

          const SizedBox(height: 18),

          // 4. Conteo de Noticias y Estado
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Noticias del Sector (${newsList.length})',
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              if (_selectedNewsCategory != 'Todas' || _newsSearchQuery.isNotEmpty)
                InkWell(
                  onTap: () {
                    setState(() {
                      _selectedNewsCategory = 'Todas';
                      _newsSearchQuery = '';
                      _newsSearchController.clear();
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    child: Text(
                      'Restablecer',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // 5. Lista de Noticias
          if (newsList.isEmpty)
            _buildEmptyNewsState(isDark, primaryColor)
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: newsList.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return _buildNewsCard(context, newsList[index], isDark, primaryColor, cardBg, cardBorder);
              },
            ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // --- RADAR DE TENDENCIAS COMERCIALES ---
  Widget _buildMarketTrendsRadar(bool isDark, Color primaryColor, Map<String, dynamic> signals) {
    final topMovingCrops = signals['topMovingCrops'] as List<dynamic>? ?? [];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF0A2B1F), const Color(0xFF064E3B)]
              : [const Color(0xFF003D2A), const Color(0xFF00543B)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_graph_rounded,
                  color: Color(0xFF6EE7B7),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Radar de Tendencias Comerciales',
                      style: GoogleFonts.manrope(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -0.2,
                      ),
                    ),
                    Text(
                      'Evaluación en base a noticias agropecuarias recientes',
                      style: GoogleFonts.manrope(
                        fontSize: 11,
                        color: const Color(0xFFA7F3D0),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Chips horizontales en bucle continuo infinito (de derecha a izquierda)
          InfiniteMarqueeTicker.builder(
            height: 36.0,
            speed: 36.0,
            fadeColor: isDark ? const Color(0xFF073A2B) : const Color(0xFF004330),
            fadeWidth: 16.0,
            itemCount: topMovingCrops.length,
            itemBuilder: (context, index) {
              final item = topMovingCrops[index % topMovingCrops.length];
              final crop = item['crop'] ?? '';
              final direction = item['direction'] ?? 'estable';
              final tag = item['tag'] ?? '';

              Color chipBg;
              Color chipText;
              IconData chipIcon;

              if (direction == 'alza') {
                chipBg = const Color(0xFF065F46);
                chipText = const Color(0xFF6EE7B7);
                chipIcon = Icons.trending_up_rounded;
              } else if (direction == 'baja') {
                chipBg = const Color(0xFF991B1B);
                chipText = const Color(0xFFFCA5A5);
                chipIcon = Icons.trending_down_rounded;
              } else {
                chipBg = const Color(0xFF1E3A8A);
                chipText = const Color(0xFF93C5FD);
                chipIcon = Icons.trending_flat_rounded;
              }

              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      if (direction == 'alza') {
                        _selectedTrendFilter = 'Alza';
                      } else if (direction == 'baja') {
                        _selectedTrendFilter = 'Baja';
                      } else {
                        _selectedTrendFilter = 'Sin cambios';
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: chipBg.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: chipText.withValues(alpha: 0.3),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(chipIcon, color: chipText, size: 14),
                        const SizedBox(width: 5),
                        Text(
                          '$crop: $tag',
                          style: GoogleFonts.manrope(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // --- BUSCADOR DE NOTICIAS ---
  Widget _buildNewsSearchBar(bool isDark, Color primaryColor) {
    final searchBg = isDark ? const Color(0xFF162D25) : Colors.white;
    final searchBorder = isDark ? const Color(0xFF224438) : const Color(0xFFE2E8F0);

    return Container(
      decoration: BoxDecoration(
        color: searchBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: searchBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _newsSearchController,
        style: GoogleFonts.manrope(
          fontSize: 13.5,
          color: isDark ? Colors.white : const Color(0xFF0F172A),
        ),
        onChanged: (val) {
          setState(() {
            _newsSearchQuery = val;
          });
        },
        decoration: InputDecoration(
          hintText: 'Buscar por cultivo, fuente o mercado...',
          hintStyle: GoogleFonts.manrope(
            fontSize: 13,
            color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: primaryColor,
            size: 22,
          ),
          suffixIcon: _newsSearchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 18),
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  onPressed: () {
                    _newsSearchController.clear();
                    setState(() {
                      _newsSearchQuery = '';
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      ),
    );
  }

  // --- FILTROS HORIZONTALES DE CATEGORÍAS ---
  Widget _buildNewsCategoryFilters(bool isDark, Color primaryColor) {
    final categories = ['Todas', 'Frutas', 'Vegetales', 'Granos', 'Comercialización', 'Clima'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: categories.map((cat) {
          final isSelected = _selectedNewsCategory == cat;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedNewsCategory = cat;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark ? const Color(0xFF047857) : const Color(0xFF016042))
                    : (isDark ? const Color(0xFF16251F) : const Color(0xFFF1F4F0)),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? (isDark ? const Color(0xFF047857) : const Color(0xFF016042))
                      : (isDark ? const Color(0xFF233E33) : const Color(0xFFCCDFD9)),
                  width: 1,
                ),
              ),
              child: Text(
                cat,
                style: GoogleFonts.manrope(
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? const Color(0xFFA3A3A3) : const Color(0xFF737373)),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // --- TARJETA DE NOTICIA ---
  Widget _buildNewsCard(
    BuildContext context,
    MarketNewsItem item,
    bool isDark,
    Color primaryColor,
    Color cardBg,
    Color cardBorder,
  ) {
    // Trend Colors
    Color trendBg;
    Color trendColor;
    IconData trendIcon;

    switch (item.trend) {
      case MarketTrendType.up:
        trendBg = isDark ? const Color(0xFF064E3B) : const Color(0xFFDCFCE7);
        trendColor = isDark ? const Color(0xFF6EE7B7) : const Color(0xFF15803D);
        trendIcon = Icons.trending_up_rounded;
        break;
      case MarketTrendType.down:
        trendBg = isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFEE2E2);
        trendColor = isDark ? const Color(0xFFFCA5A5) : const Color(0xFFDC2626);
        trendIcon = Icons.trending_down_rounded;
        break;
      case MarketTrendType.stable:
        trendBg = isDark ? const Color(0xFF0C4A6E) : const Color(0xFFE0F2FE);
        trendColor = isDark ? const Color(0xFF7DD3FC) : const Color(0xFF0284C7);
        trendIcon = Icons.trending_flat_rounded;
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen destacada de la noticia
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: SizedBox(
              height: 150,
              width: double.infinity,
              child: CachedNetworkImage(
                imageUrl: item.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: isDark ? const Color(0xFF1C382C) : const Color(0xFFF1F5F9),
                  child: Center(
                    child: Icon(
                      Icons.image_outlined,
                      size: 32,
                      color: primaryColor.withValues(alpha: 0.3),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: isDark ? const Color(0xFF1C382C) : const Color(0xFFF1F5F9),
                  child: Center(
                    child: Icon(
                      Icons.agriculture_rounded,
                      size: 40,
                      color: primaryColor.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fila de Badges: Categoría + Tendencia Detectada
                Row(
                  children: [
                    // Badge Categoría
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E382E) : const Color(0xFFE9F1EC),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.category,
                        style: GoogleFonts.manrope(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Badge Tendencia
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: trendBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(trendIcon, size: 12, color: trendColor),
                          const SizedBox(width: 4),
                          Text(
                            item.trendImpact,
                            style: GoogleFonts.manrope(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: trendColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Tiempo de lectura
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 13,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${item.readTimeMinutes} min',
                          style: GoogleFonts.manrope(
                            fontSize: 11,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Título de la noticia
                Text(
                  item.title,
                  style: GoogleFonts.manrope(
                    fontSize: 15.5,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    height: 1.3,
                  ),
                ),

                const SizedBox(height: 6),

                // Fuente y fecha
                Row(
                  children: [
                    Icon(
                      Icons.newspaper_rounded,
                      size: 14,
                      color: primaryColor,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      item.sourceName,
                      style: GoogleFonts.manrope(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    Text(
                      ' • ${item.publishedAt}',
                      style: GoogleFonts.manrope(
                        fontSize: 11.5,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Resumen breve
                Text(
                  item.summary,
                  style: GoogleFonts.manrope(
                    fontSize: 12.5,
                    height: 1.45,
                    color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                  ),
                ),

                const SizedBox(height: 12),

                // Caja de Evaluación de Impacto Comercial
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF0F261E)
                        : const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF1A4736)
                          : const Color(0xFFBBF7D0),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.insights_rounded,
                        size: 16,
                        color: Color(0xFF059669),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Impacto estimado en comercialización:',
                              style: GoogleFonts.manrope(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF047857),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              item.commercialAnalysis,
                              style: GoogleFonts.manrope(
                                fontSize: 11.5,
                                height: 1.4,
                                color: isDark ? const Color(0xFFD1FAE5) : const Color(0xFF065F46),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Chips de productos relacionados
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: item.relatedProducts.map((prod) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E382E) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '#$prod',
                        style: GoogleFonts.manrope(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 14),

                // Botones de acción: Enlace a fuente original + Detalles
                Row(
                  children: [
                    // Botón principal: Abrir Fuente Original
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          MarketNewsService.instance.launchSourceUrl(context, item.sourceUrl);
                        },
                        icon: const Icon(Icons.open_in_new_rounded, size: 15),
                        label: Text(
                          'Leer fuente original',
                          style: GoogleFonts.manrope(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Botón secundario: Ver resumen completo
                    OutlinedButton(
                      onPressed: () => _showNewsDetailSheet(context, item, isDark, primaryColor),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primaryColor,
                        side: BorderSide(color: primaryColor.withValues(alpha: 0.3)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Detalles',
                        style: GoogleFonts.manrope(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
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

  // --- MODAL SHEET DE DETALLE DE NOTICIA ---
  void _showNewsDetailSheet(
    BuildContext context,
    MarketNewsItem item,
    bool isDark,
    Color primaryColor,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final sheetBg = isDark ? const Color(0xFF12221C) : Colors.white;

        return Container(
          decoration: BoxDecoration(
            color: sheetBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).padding.bottom + 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Imagen
                SizedBox(
                  height: 180,
                  width: double.infinity,
                  child: CachedNetworkImage(
                    imageUrl: item.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: isDark ? const Color(0xFF1C382C) : const Color(0xFFF1F5F9),
                      child: Center(
                        child: Icon(
                          Icons.image_outlined,
                          size: 36,
                          color: primaryColor.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: isDark ? const Color(0xFF1C382C) : const Color(0xFFF1F5F9),
                      child: Center(
                        child: Icon(
                          Icons.agriculture_rounded,
                          size: 40,
                          color: primaryColor.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Categoría y fuente
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              item.category,
                              style: GoogleFonts.manrope(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                          ),
                          Text(
                            item.publishedAt,
                            style: GoogleFonts.manrope(
                              fontSize: 11.5,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Título
                      Text(
                        item.title,
                        style: GoogleFonts.manrope(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Publicado por: ${item.sourceName}',
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: primaryColor,
                        ),
                      ),

                      const Divider(height: 24),

                      // Sección Resumen
                      Text(
                        'Resumen de la Noticia',
                        style: GoogleFonts.manrope(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.summary,
                        style: GoogleFonts.manrope(
                          fontSize: 13,
                          height: 1.5,
                          color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Sección Impacto Comercial
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0F261E) : const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? const Color(0xFF1A4736) : const Color(0xFFBBF7D0),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.insights_rounded, color: Color(0xFF059669), size: 18),
                                const SizedBox(width: 6),
                                Text(
                                  'Impacto Estimado en Tendencias y Precios',
                                  style: GoogleFonts.manrope(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF047857),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              item.commercialAnalysis,
                              style: GoogleFonts.manrope(
                                fontSize: 12,
                                height: 1.45,
                                color: isDark ? const Color(0xFFD1FAE5) : const Color(0xFF065F46),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Botón para abrir enlace a la fuente
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(ctx).pop();
                            MarketNewsService.instance.launchSourceUrl(context, item.sourceUrl);
                          },
                          icon: const Icon(Icons.open_in_new_rounded, size: 16),
                          label: Text(
                            'Abrir artículo completo en ${item.sourceName}',
                            style: GoogleFonts.manrope(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- ESTADO VACÍO DE NOTICIAS ---
  Widget _buildEmptyNewsState(bool isDark, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.newspaper_rounded,
              size: 42,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No se encontraron noticias',
            style: GoogleFonts.manrope(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Intenta buscar con otros términos o selecciona otra categoría.',
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              fontSize: 12.5,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _selectedNewsCategory = 'Todas';
                _newsSearchQuery = '';
                _newsSearchController.clear();
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: Text(
              'Ver todas las noticias',
              style: GoogleFonts.manrope(
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // --- TAB DE TENDENCIAS PREDICTIVAS (BASADAS EN NOTICIAS DEL MERCADO) ---
  // =========================================================================
  Widget _buildTendenciasTab(bool isDark, Color primaryColor) {
    final trendSignals = MarketNewsService.instance.getMarketTrendSignals();
    final allPredictions = MarketNewsService.instance.getCropTrendPredictions(filter: 'Todos');
    final filteredPredictions = MarketNewsService.instance.getCropTrendPredictions(filter: _selectedTrendFilter);

    final upCount = allPredictions.where((p) => p.direction == 'alza').length;
    final downCount = allPredictions.where((p) => p.direction == 'baja').length;
    final noChangeCount = allPredictions.where((p) => p.direction == 'sin_cambios').length;

    final cardBg = isDark ? const Color(0xFF162D25) : Colors.white;
    final cardBorder = isDark ? const Color(0xFF224438) : const Color(0xFFE2E8F0);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Radar de Tendencias Agropecuarias (Header Visual)
          _buildMarketTrendsRadar(isDark, primaryColor, trendSignals),

          const SizedBox(height: 16),

          // 2. AVISO PREDICTIVO OBLIGATORIO (Metodología, estimación sujeta a equivocaciones y sin cambios)
          _buildPredictiveNoticeCard(isDark, primaryColor),

          const SizedBox(height: 18),

          // 3. Métricas Resumen (Alza / Baja / Sin Cambios)
          _buildTrendKpiRow(isDark, upCount, downCount, noChangeCount),

          const SizedBox(height: 20),

          // 4. Selector de Filtros de Tendencia
          _buildTrendFilterChips(isDark, primaryColor, allPredictions.length, upCount, downCount, noChangeCount),

          const SizedBox(height: 16),

          // 5. Encabezado de la Lista
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Cultivos Evaluados (${filteredPredictions.length})',
                style: GoogleFonts.manrope(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              if (_selectedTrendFilter != 'Todos')
                InkWell(
                  onTap: () {
                    setState(() {
                      _selectedTrendFilter = 'Todos';
                    });
                  },
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    child: Text(
                      'Restablecer',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // 6. Lista de Tarjetas Detalladas por Cultivo
          if (filteredPredictions.isEmpty)
            _buildEmptyTrendsState(isDark, primaryColor)
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredPredictions.length,
              separatorBuilder: (context, index) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                return _buildDetailedTrendCard(
                  context,
                  filteredPredictions[index],
                  isDark,
                  primaryColor,
                  cardBg,
                  cardBorder,
                );
              },
            ),

          const SizedBox(height: 36),
        ],
      ),
    );
  }

  // --- TARJETA DE AVISO PREDICTIVO Y METODOLOGÍA ---
  Widget _buildPredictiveNoticeCard(bool isDark, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF132A20) : const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF204E38) : const Color(0xFFBBF7D0),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1D3E2F) : const Color(0xFFDCFCE7),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.psychology_alt_outlined,
              color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF15803D),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Aviso de Estimación Predictiva',
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: isDark ? 0.25 : 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Orientativo',
                        style: GoogleFonts.manrope(
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          color: isDark ? const Color(0xFFFCD34D) : const Color(0xFFB45309),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  'Este análisis de tendencias se genera a partir de noticias agropecuarias recientes, reportes de cosecha y dinámicas de oferta y demanda. Es un modelo predictivo sujeto a fluctuaciones de mercado y posibles equivocaciones. Si no existen datos suficientes para un cultivo o período, se clasifica automáticamente como "Sin cambios".',
                  style: GoogleFonts.manrope(
                    fontSize: 11.5,
                    height: 1.45,
                    color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- FILA DE RESUMEN KPI ---
  Widget _buildTrendKpiRow(bool isDark, int upCount, int downCount, int noChangeCount) {
    return Row(
      children: [
        Expanded(
          child: _buildKpiCard(
            title: 'Alza',
            count: upCount,
            subtitle: 'Tendencia al alza',
            icon: Icons.trending_up_rounded,
            color: isDark ? const Color(0xFF34D399) : const Color(0xFF16A34A),
            bg: isDark ? const Color(0xFF064E3B).withValues(alpha: 0.4) : const Color(0xFFDCFCE7),
            border: isDark ? const Color(0xFF065F46) : const Color(0xFF86EFAC),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildKpiCard(
            title: 'Baja',
            count: downCount,
            subtitle: 'Presión de oferta',
            icon: Icons.trending_down_rounded,
            color: isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626),
            bg: isDark ? const Color(0xFF7F1D1D).withValues(alpha: 0.35) : const Color(0xFFFEE2E2),
            border: isDark ? const Color(0xFF991B1B) : const Color(0xFFFCA5A5),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildKpiCard(
            title: 'Sin cambios',
            count: noChangeCount,
            subtitle: 'Estable o sin datos',
            icon: Icons.remove_rounded,
            color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF2563EB),
            bg: isDark ? const Color(0xFF1E3A8A).withValues(alpha: 0.35) : const Color(0xFFEFF6FF),
            border: isDark ? const Color(0xFF1D4ED8) : const Color(0xFFBFDBFE),
          ),
        ),
      ],
    );
  }

  Widget _buildKpiCard({
    required String title,
    required int count,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color bg,
    required Color border,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 18),
              Text(
                '$count',
                style: GoogleFonts.manrope(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: GoogleFonts.manrope(
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            subtitle,
            style: GoogleFonts.manrope(
              fontSize: 9.5,
              color: color.withValues(alpha: 0.85),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // --- FILTROS POR TIPO DE TENDENCIA ---
  Widget _buildTrendFilterChips(
    bool isDark,
    Color primaryColor,
    int totalCount,
    int upCount,
    int downCount,
    int noChangeCount,
  ) {
    final filters = [
      {'name': 'Todos', 'count': totalCount},
      {'name': 'Alza', 'count': upCount},
      {'name': 'Baja', 'count': downCount},
      {'name': 'Sin cambios', 'count': noChangeCount},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: filters.map((f) {
          final name = f['name'] as String;
          final count = f['count'] as int;
          final isSelected = _selectedTrendFilter == name;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedTrendFilter = name;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark ? const Color(0xFF047857) : const Color(0xFF016042))
                    : (isDark ? const Color(0xFF16251F) : const Color(0xFFF1F4F0)),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? (isDark ? const Color(0xFF047857) : const Color(0xFF016042))
                      : (isDark ? const Color(0xFF233E33) : const Color(0xFFCCDFD9)),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Text(
                    name,
                    style: GoogleFonts.manrope(
                      fontSize: 12.5,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? const Color(0xFFA3A3A3) : const Color(0xFF737373)),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.25)
                          : (isDark ? const Color(0xFF233E33) : const Color(0xFFE2E8F0)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$count',
                      style: GoogleFonts.manrope(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? Colors.white
                            : (isDark ? const Color(0xFFA7F3D0) : const Color(0xFF334155)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // --- TARJETA DETALLADA DE TENDENCIA POR CULTIVO ---
  Widget _buildDetailedTrendCard(
    BuildContext context,
    CropTrendPrediction item,
    bool isDark,
    Color primaryColor,
    Color cardBg,
    Color cardBorder,
  ) {
    Color trendBg;
    Color trendColor;
    IconData trendIcon;
    String trendLabel;

    switch (item.direction) {
      case 'alza':
        trendBg = isDark ? const Color(0xFF064E3B) : const Color(0xFFDCFCE7);
        trendColor = isDark ? const Color(0xFF6EE7B7) : const Color(0xFF15803D);
        trendIcon = Icons.trending_up_rounded;
        trendLabel = item.percentageTag;
        break;
      case 'baja':
        trendBg = isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFEE2E2);
        trendColor = isDark ? const Color(0xFFFCA5A5) : const Color(0xFFDC2626);
        trendIcon = Icons.trending_down_rounded;
        trendLabel = item.percentageTag;
        break;
      case 'sin_cambios':
      default:
        trendBg = isDark ? const Color(0xFF1E3A8A) : const Color(0xFFEFF6FF);
        trendColor = isDark ? const Color(0xFF93C5FD) : const Color(0xFF2563EB);
        trendIcon = Icons.remove_rounded;
        trendLabel = item.percentageTag;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Cultivo + Badges (Categoría, Tendencia)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            item.cropName,
                            style: GoogleFonts.manrope(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E382E) : const Color(0xFFE9F1EC),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item.category,
                            style: GoogleFonts.manrope(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 11,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Horizonte: ${item.timeHorizon}',
                          style: GoogleFonts.manrope(
                            fontSize: 11,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(
                          Icons.shield_outlined,
                          size: 11,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Certeza: ${item.confidenceLevel}',
                          style: GoogleFonts.manrope(
                            fontSize: 11,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Badge Tendencia
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: trendBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(trendIcon, size: 14, color: trendColor),
                    const SizedBox(width: 4),
                    Text(
                      trendLabel,
                      style: GoogleFonts.manrope(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: trendColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Resumen de la proyección / Análisis
          Text(
            item.forecastSummary,
            style: GoogleFonts.manrope(
              fontSize: 12.5,
              height: 1.45,
              color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155),
            ),
          ),

          const SizedBox(height: 12),

          // Barra inferior con indicador de datos y fuente/enlace
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F231D) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? const Color(0xFF1C382E) : const Color(0xFFE2E8F0),
              ),
            ),
            child: Row(
              children: [
                // Indicador si hay datos o si no hay datos
                Icon(
                  item.hasData ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                  size: 15,
                  color: item.hasData
                      ? (isDark ? const Color(0xFF34D399) : const Color(0xFF16A34A))
                      : (isDark ? Colors.amber[300] : Colors.amber[700]),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    item.hasData
                        ? (item.sourceName != null ? 'Noticia de respaldo: ${item.sourceName}' : 'Datos de noticias activos')
                        : 'Sin datos recientes (Se coloca sin cambios)',
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Si tiene enlace a fuente, botón para abrirlo
                if (item.hasData && item.sourceUrl != null)
                  InkWell(
                    onTap: () {
                      MarketNewsService.instance.launchSourceUrl(context, item.sourceUrl!);
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Ver fuente',
                            style: GoogleFonts.manrope(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(width: 3),
                          Icon(Icons.open_in_new_rounded, size: 12, color: primaryColor),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- ESTADO VACÍO DE TENDENCIAS ---
  Widget _buildEmptyTrendsState(bool isDark, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      child: Column(
        children: [
          Icon(
            Icons.insights_rounded,
            size: 40,
            color: primaryColor.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          Text(
            'Sin proyecciones en este filtro',
            style: GoogleFonts.manrope(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'No se encontraron cultivos con este tipo de tendencia.',
            style: GoogleFonts.manrope(
              fontSize: 12,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _selectedTrendFilter = 'Todos';
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text('Mostrar todos los cultivos'),
          ),
        ],
      ),
    );
  }
}


