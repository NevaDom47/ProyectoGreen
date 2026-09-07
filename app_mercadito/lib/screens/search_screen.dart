import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/global_state.dart';
import '../widgets/supplier_quick_view_bottom_sheet.dart';
import '../widgets/quality_info_bottom_sheet.dart';
import '../widgets/skeleton_loading.dart';
import '../widgets/animated_favorite_button.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _activeFilter = 'Todos';
  String _activeCategory = 'Frutas y Verduras';
  String _activeQuery = '';
  final List<String> _searchHistory = [];
  bool _isLoading = true;

  final Map<String, String> _selectedUnits = {};
  final Map<String, String> _selectedProductModes = {};

  final List<Map<String, dynamic>> _allProducts = [
    {
      'title': 'Papa Blanca Alpha',
      'sku': 'TUB-PAP-01',
      'provider': 'Don Pedro H.',
      'location': 'Tecomán, Colima',
      'price': '22.50',
      'oldPrice': '26.00',
      'wholesalePrice': '18.00',
      'wholesaleOldPrice': '22.50',
      'wholesaleMin': 'MIN. 20 KG',
      'unit': 'KG',
      'available_units': ['KG', 'LB', 'SACO'],
      'quality': '1ra Calidad',
      'category': 'Frutas y Verduras',
      'rating': '4.8',
      'reviewCount': '128',
      'tags': ['Tubérculos', 'Oferta'],
      'salesMode': 'both',
      'image': 'assets/images/PapaGemini.png',
    },
    {
      'title': 'Tomate Saladette',
      'sku': 'FRU-TOM-01',
      'provider': 'Granja El Sol',
      'location': 'Valle de Santiago, GTO',
      'price': '28.50',
      'oldPrice': '32.00',
      'wholesalePrice': '22.50',
      'wholesaleOldPrice': '28.00',
      'wholesaleMin': 'MIN. 15 KG',
      'unit': 'KG',
      'available_units': ['KG', 'LB', 'SACO'],
      'quality': '1ra Calidad',
      'category': 'Frutas y Verduras',
      'rating': '4.8',
      'reviewCount': '95',
      'tags': ['Frutas y Verduras', 'Oferta'],
      'salesMode': 'both',
      'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuDF4fUzPGSX592_YU4gqZe1p3VUwRebja4WL0DnDH5yTSAYkaRTrfuZinxjIuia7OxOMEmPomP57T7lYPKBOGOcXDZu4blV8E0vEouSIkR19xu4nV9rovZdEsh0VWKzl-nHf4oqtXfslTT9n5tRw5qiIw5nwCTt106Syb5tyTGhM2mdBmPqvoM4EKK7wP7Ha6ZcidD1by61ld-itwhNlFPnaJQKJOC-1FJ6s2wsjzHxKYeMuFgaLZ-iMHtz5IFBpPZdVa-ZeShjYbE'
    },
    {
      'title': 'Tomate Bola Orgánico',
      'sku': 'FRU-TBO-02',
      'provider': 'Huertos San Juan',
      'location': 'Irapuato, GTO',
      'price': '35.00',
      'oldPrice': '40.00',
      'wholesalePrice': '29.00',
      'wholesaleOldPrice': '35.00',
      'wholesaleMin': 'MIN. 10 KG',
      'unit': 'KG',
      'available_units': ['KG', 'LB'],
      'quality': '1ra Calidad',
      'category': 'Frutas y Verduras',
      'rating': '4.9',
      'reviewCount': '64',
      'tags': ['Orgánico', 'Fresco'],
      'salesMode': 'retail_only',
      'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuBpkgELbOrgnfZCX2ldQAJntDk7MuvNzM2xj3ZX-s4hk6IEkRxT-JL21rrYl0wylUNhx6ss5tQZRgA-ez-zFDASz8N8vgHjeW2WOMuST9XT-TJ4kW4pnn_Ehc9qdjoobIZGbV2QsRsF2X6ZWKyht57UvloZOBtS1P1T9LuhL5_erze1q1BEaK7Go9ox0J6pBGX9OY6POaJ76vtgX8--SU6-LvdIQUtJHtKja8tfJH9dwUOexlUhPQ5SqBpdJ7O9w-LElo_r3a9IzeA'
    },
    {
      'title': 'Maíz Blanco',
      'sku': 'CER-MAI-01',
      'provider': 'Agropecuaria del Bajío',
      'location': 'Celaya, GTO',
      'price': '850.00',
      'oldPrice': '920.00',
      'wholesalePrice': '780.00',
      'wholesaleMin': 'MIN. 5 SACOS',
      'unit': 'SACO',
      'available_units': ['SACO', 'KG'],
      'quality': '2da Calidad',
      'category': 'Cereales y Granos',
      'rating': '4.7',
      'reviewCount': '42',
      'tags': ['Granos', 'Mayorista'],
      'salesMode': 'wholesale_only',
      'image': 'https://storage.googleapis.com/a1aa/image/RjWzE83BfT1lI6I5qB1a3mQe6qQ7Gf11zVqA1Wq8zN4f20HnA.jpg'
    },
    {
      'title': 'Frijol Flor de Mayo',
      'sku': 'CER-FRI-02',
      'provider': 'Semillas y Granos',
      'location': 'Salamanca, GTO',
      'price': '45.00',
      'oldPrice': '50.00',
      'wholesalePrice': '38.00',
      'wholesaleMin': 'MIN. 25 KG',
      'unit': 'KG',
      'available_units': ['KG', 'LB', 'SACO'],
      'quality': '1ra Calidad',
      'category': 'Cereales y Granos',
      'rating': '4.8',
      'reviewCount': '88',
      'tags': ['Cereales', 'Calidad'],
      'salesMode': 'both',
      'image': 'https://storage.googleapis.com/a1aa/image/eF3K8qZ21LqV1JvH4D2nN8gX7tY9bP4wT3kR5mS2eM1aP9pI.jpg' 
    },
    {
      'title': 'Alimento para Cerdos',
      'sku': 'ALI-CER-01',
      'provider': 'Nutrición Animal',
      'location': 'León, GTO',
      'price': '520.00',
      'oldPrice': '560.00',
      'wholesalePrice': '470.00',
      'wholesaleMin': 'MIN. 3 SACOS',
      'unit': 'SACO',
      'available_units': ['SACO', 'KG'],
      'quality': '3ra Calidad',
      'category': 'Alimento Animal',
      'rating': '4.5',
      'reviewCount': '31',
      'tags': ['Nutrición', 'Granja'],
      'salesMode': 'both',
      'image': 'https://storage.googleapis.com/a1aa/image/M3bT1aY4qP2nK8gX7tY9bP4wT3kR5mS2eM1aP9pIeF3K8qZ21.jpg'
    },
    {
      'title': 'Semilla de Sorgo',
      'sku': 'SEM-SOR-01',
      'provider': 'Semillas del Centro',
      'location': 'Irapuato, GTO',
      'price': '1200.00',
      'oldPrice': '1350.00',
      'wholesalePrice': '1080.00',
      'wholesaleMin': 'MIN. 2 SACOS',
      'unit': 'SACO',
      'available_units': ['SACO', 'KG'],
      'quality': '1ra Calidad',
      'category': 'Semillas',
      'rating': '4.9',
      'reviewCount': '53',
      'tags': ['Semillas', 'Certificado'],
      'salesMode': 'both',
      'image': 'https://storage.googleapis.com/a1aa/image/Y4qP2nK8gX7tY9bP4wT3kR5mS2eM1aP9pIeF3K8qZ21M3bT1a.jpg'
    },
    {
      'title': 'Queso Fresco',
      'sku': 'LAC-QUE-01',
      'provider': 'Lácteos La Vaca',
      'location': 'Silao, GTO',
      'price': '85.00',
      'oldPrice': '95.00',
      'wholesalePrice': '72.00',
      'wholesaleMin': 'MIN. 10 KG',
      'unit': 'KG',
      'available_units': ['KG', 'LB'],
      'quality': '2da Calidad',
      'category': 'Lácteos',
      'rating': '4.6',
      'reviewCount': '77',
      'tags': ['Lácteos', 'Artesanal'],
      'salesMode': 'both',
      'image': 'https://storage.googleapis.com/a1aa/image/7tY9bP4wT3kR5mS2eM1aP9pIeF3K8qZ21M3bT1aY4qP2nK8gX.jpg'
    },
    {
      'title': 'Huevo Blanco',
      'sku': 'HUE-BLA-01',
      'provider': 'Avícola San José',
      'location': 'Abasolo, GTO',
      'price': '38.00',
      'oldPrice': '42.00',
      'wholesalePrice': '32.00',
      'wholesaleMin': 'MIN. 5 CAJAS',
      'unit': 'CAJA',
      'available_units': ['CAJA', 'DOCENA'],
      'quality': '1ra Calidad',
      'category': 'Huevos',
      'rating': '4.9',
      'reviewCount': '112',
      'tags': ['Huevos', 'Fresco'],
      'salesMode': 'both',
      'image': 'https://storage.googleapis.com/a1aa/image/wT3kR5mS2eM1aP9pIeF3K8qZ21M3bT1aY4qP2nK8gX7tY9bP4.jpg'
    },
    {
      'title': 'Carne de Res Molida',
      'sku': 'CAR-RES-01',
      'provider': 'Carnicería El Torito',
      'location': 'Pénjamo, GTO',
      'price': '140.00',
      'oldPrice': '155.00',
      'wholesalePrice': '120.00',
      'wholesaleMin': 'MIN. 10 KG',
      'unit': 'KG',
      'available_units': ['KG', 'LB'],
      'quality': '1ra Calidad',
      'category': 'Carnes y Embutidos',
      'rating': '4.8',
      'reviewCount': '90',
      'tags': ['Carnes', 'Corte Fresco'],
      'salesMode': 'both',
      'image': 'https://storage.googleapis.com/a1aa/image/P9pIeF3K8qZ21M3bT1aY4qP2nK8gX7tY9bP4wT3kR5mS2eM1a.jpg'
    },
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {});
    });
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
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _performSearch(String term) {
    setState(() {
      _isLoading = true;
      _activeQuery = term.trim().toLowerCase();
      if (term.trim().isNotEmpty) {
        if (!_searchHistory.contains(term.trim())) {
          _searchHistory.insert(0, term.trim());
          if (_searchHistory.length > 5) {
            _searchHistory.removeLast();
          }
        }
      }
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  String _getProductSku(Map<String, dynamic> item) {
    if (item['sku'] != null && item['sku'].toString().trim().isNotEmpty) {
      return item['sku'].toString().trim();
    }
    final name = (item['title'] ?? item['name'] ?? 'PROD').toString().replaceAll(' ', '').toUpperCase();
    final nameCode = name.length >= 3 ? name.substring(0, 3) : name.padRight(3, 'X');
    final cat = (item['category'] ?? 'GEN').toString().replaceAll(' ', '').toUpperCase();
    final catCode = cat.length >= 3 ? cat.substring(0, 3) : cat.padRight(3, 'X');
    return '$catCode-$nameCode-01';
  }

  List<Map<String, dynamic>> get _filteredProducts {
    return _allProducts.where((p) {
      if (_activeCategory.isNotEmpty && p['category'] != _activeCategory && _activeCategory != 'Todos') return false;
      
      if (_activeQuery.isNotEmpty) {
        final sku = (p['sku'] ?? _getProductSku(p)).toString().toLowerCase();
        if (!p['title'].toString().toLowerCase().contains(_activeQuery) &&
            !p['provider'].toString().toLowerCase().contains(_activeQuery) &&
            !sku.contains(_activeQuery)) {
          return false;
        }
      }

      if (_activeFilter != 'Todos' && _activeFilter != 'Cerca de Mi') {
        if (p['quality'] != _activeFilter) return false;
      }
      
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final bgColor = isDark ? const Color(0xFF0f231d) : const Color(0xFFf7faf5);
    final surfaceColor = isDark ? const Color(0xFF1a2f26) : Colors.white;
    final searchBgColor = isDark ? const Color(0xFF1f2937) : const Color(0xFFE5F1EB);
    
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Header
            Container(
              color: bgColor,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: theme.colorScheme.primary),
                        onPressed: () => context.pop(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: searchBgColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                          child: Row(
                            children: [
                              Icon(Icons.search, color: theme.colorScheme.primary, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  focusNode: _searchFocusNode,
                                  autofocus: true,
                                  onSubmitted: _performSearch,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Buscar productos agrícolas...',
                                    hintStyle: TextStyle(fontSize: 14, color: isDark ? Colors.grey[500] : Colors.grey[600]),
                                  ),
                                  style: TextStyle(fontSize: 14, color: isDark ? Colors.white : Colors.black87),
                                ),
                              ),
                              if (_searchController.text.isNotEmpty)
                                IconButton(
                                  icon: const Icon(Icons.close, size: 20),
                                  color: theme.colorScheme.primary,
                                  onPressed: () {
                                    setState(() {
                                      _searchController.clear();
                                    });
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Filters
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['Todos', 'Cerca de Mi', '1ra Calidad', '2da Calidad', '3ra Calidad'].map((filter) {
                        final isSelected = _activeFilter == filter;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(
                              filter,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                                color: isSelected ? Colors.white : (isDark ? Colors.grey[300] : Colors.black87),
                              ),
                            ),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _activeFilter = filter;
                                });
                              }
                            },
                            selectedColor: theme.colorScheme.primary,
                            backgroundColor: surfaceColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: isSelected ? theme.colorScheme.primary : Colors.grey.withValues(alpha: 0.2),
                              ),
                            ),
                            showCheckmark: false,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  _buildSearchHistory(),
                  _buildCategoriesSection(theme, surfaceColor, isDark),
                  const SizedBox(height: 24),
                  _buildProductsSection(theme, surfaceColor, isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHistory() {
    if (_searchHistory.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Búsquedas recientes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey[600])),
              TextButton(
                onPressed: () {
                  setState(() { _searchHistory.clear(); });
                },
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Borrar', style: TextStyle(fontSize: 12)),
              )
            ],
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: _searchHistory.map((term) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ActionChip(
                  label: Text(term, style: const TextStyle(fontSize: 12)),
                  backgroundColor: Colors.transparent,
                  side: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  onPressed: () {
                    _searchController.text = term;
                    _searchFocusNode.unfocus();
                    _performSearch(term);
                  },
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildCategoriesSection(ThemeData theme, Color surfaceColor, bool isDark) {
    final categories = [
      {'name': 'Todos', 'icon': Icons.apps},
      {'name': 'Frutas y Verduras', 'icon': Icons.eco},
      {'name': 'Cereales y Granos', 'icon': Icons.grass},
      {'name': 'Alimento Animal', 'icon': Icons.pets},
      {'name': 'Semillas', 'icon': Icons.spa},
      {'name': 'Lácteos', 'icon': Icons.water_drop},
      {'name': 'Huevos', 'icon': Icons.egg},
      {'name': 'Carnes y Embutidos', 'icon': Icons.set_meal},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Categorías principales',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              final isSelected = _activeCategory == cat['name'];
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _activeCategory = cat['name'] as String;
                  });
                },
                child: Container(
                  width: 80,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.1) : surfaceColor,
                          shape: BoxShape.circle,
                          border: isSelected ? Border.all(color: theme.colorScheme.primary, width: 2) : null,
                          boxShadow: [
                            if (!isSelected)
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                          ],
                        ),
                        child: Icon(
                          cat['icon'] as IconData,
                          color: isSelected ? theme.colorScheme.primary : Colors.grey[600],
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        cat['name'] as String,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
                          height: 1.1,
                          color: isSelected 
                              ? theme.colorScheme.primary 
                              : (isDark ? Colors.grey[300] : Colors.grey[800]),
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
    );
  }

  Widget _buildProductsSection(ThemeData theme, Color surfaceColor, bool isDark) {
    final products = _filteredProducts;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Productos',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '${products.length} resultados',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (_isLoading)
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 4,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return const SkeletonSearchProductCard();
            },
          )
        else if (products.isEmpty)
          const Padding(
            padding: EdgeInsets.all(32.0),
            child: Center(
              child: Text(
                'No se encontraron productos.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: products.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final p = products[index];
              return _buildSearchProductCard(p, theme, surfaceColor, isDark);
            },
          ),
      ],
    );
  }

  Widget _buildProductImage(String? src) {
    final imgSrc = (src != null && src.isNotEmpty) ? src : 'https://via.placeholder.com/400';
    if (imgSrc.startsWith('assets/')) {
      return Image.asset(
        imgSrc,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey[200],
          child: const Center(child: Icon(Icons.image_not_supported, size: 20, color: Colors.grey)),
        ),
      );
    }
    return Image.network(
      imgSrc,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        color: Colors.grey[200],
        child: const Center(child: Icon(Icons.image_not_supported, size: 20, color: Colors.grey)),
      ),
    );
  }

  Widget _buildSalesModeIndicator(Map<String, dynamic> p, ThemeData theme, bool isDark, String productTitle) {
    final String salesMode = (p['salesMode'] ?? p['saleType'] ?? 'both').toString().toLowerCase();

    if (salesMode == 'both' || salesMode == 'ambos') {
      final currentMode = _selectedProductModes[productTitle] ?? 'retail';
      final bool isRetail = currentMode == 'retail';
      final bool isWholesale = currentMode == 'wholesale';

      return Container(
        height: 22,
        padding: const EdgeInsets.all(1.5),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
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
              onTap: () {
                setState(() {
                  _selectedProductModes[productTitle] = 'retail';
                });
              },
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                decoration: BoxDecoration(
                  color: isRetail
                      ? (isDark ? const Color(0xFF047857) : const Color(0xFF059669))
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Detalle',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 8.5,
                    fontWeight: isRetail ? FontWeight.w800 : FontWeight.w600,
                    color: isRetail
                        ? Colors.white
                        : (isDark ? Colors.grey[400] : Colors.grey[600]),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 1),
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedProductModes[productTitle] = 'wholesale';
                });
              },
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                decoration: BoxDecoration(
                  color: isWholesale
                      ? (isDark ? const Color(0xFF0284C7) : const Color(0xFF0369A1))
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Por Mayor',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 8.5,
                    fontWeight: isWholesale ? FontWeight.w800 : FontWeight.w600,
                    color: isWholesale
                        ? Colors.white
                        : (isDark ? Colors.grey[400] : Colors.grey[600]),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final bool isWholesaleOnly = salesMode.contains('wholesale') || salesMode.contains('mayor');
    final String label = isWholesaleOnly ? 'Al Por Mayor' : 'Al Detalle';
    final IconData icon = isWholesaleOnly ? Icons.storefront_outlined : Icons.shopping_bag_outlined;
    final Color badgeColor = isWholesaleOnly ? const Color(0xFF0284C7) : const Color(0xFF059669);

    return Container(
      height: 22,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: badgeColor.withValues(alpha: 0.35),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: badgeColor),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 8.5,
              fontWeight: FontWeight.w700,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchProductCard(Map<String, dynamic> p, ThemeData theme, Color surfaceColor, bool isDark) {
    final String productTitle = (p['title'] ?? p['name'] ?? '').toString();
    final String providerStr = (p['provider'] ?? p['supplier'] ?? 'Granja El Sol').toString();
    final String locationStr = (p['location'] ?? 'Valle de Santiago, GTO').toString();
    final String qualityStr = (p['quality'] ?? p['badge'] ?? '1ra Calidad').toString();
    final String imgSrc = (p['image'] ?? p['img'] ?? '').toString();

    Color qualityColor = theme.colorScheme.primary;
    final lowerQuality = qualityStr.toLowerCase();
    String displayQuality = qualityStr.toUpperCase();
    if (lowerQuality.contains('1ra') || lowerQuality.contains('primera')) {
      displayQuality = 'PRIMERA CALIDAD';
    } else if (lowerQuality.contains('2da') || lowerQuality.contains('segunda')) {
      displayQuality = 'SEGUNDA CALIDAD';
      qualityColor = const Color(0xFFE2725B); // Mamey
    } else if (lowerQuality.contains('3ra') || lowerQuality.contains('tercera')) {
      displayQuality = 'TERCERA CALIDAD';
      qualityColor = Colors.red;
    }

    final String salesMode = (p['salesMode'] ?? p['saleType'] ?? 'both').toString().toLowerCase();
    final String defaultMode = (salesMode.contains('wholesale') || salesMode.contains('mayor')) ? 'wholesale' : 'retail';
    final String currentMode = _selectedProductModes[productTitle] ?? defaultMode;
    final bool isWholesale = currentMode == 'wholesale';

    final List<String> availableUnits = List<String>.from(p['available_units'] ?? [p['unit'] ?? 'KG']);
    final selectedUnit = _selectedUnits[productTitle] ?? availableUnits.first;

    // Calculate display price based on mode
    double basePrice = isWholesale
        ? (double.tryParse((p['wholesalePrice'] ?? p['price'] ?? '0').toString().replaceAll('\$', '')) ?? 0.0)
        : (double.tryParse((p['price'] ?? '0').toString().replaceAll('\$', '')) ?? 0.0);
    double displayPrice = basePrice;
    if (selectedUnit != p['unit']) {
      if (selectedUnit == 'LB' && p['unit'] == 'KG') {
        displayPrice = basePrice * 0.45;
      } else if (selectedUnit == 'KG' && p['unit'] == 'SACO') {
        displayPrice = basePrice / 50;
      } else if (selectedUnit == 'SACO' && p['unit'] == 'KG') {
        displayPrice = basePrice * 50;
      } else if (selectedUnit == 'CAJA' && p['unit'] == 'DOCENA') {
        displayPrice = basePrice * 2.5;
      } else if (selectedUnit == 'DOCENA' && p['unit'] == 'CAJA') {
        displayPrice = basePrice / 2.5;
      } else {
        displayPrice = basePrice * 1.5;
      }
    }

    return GestureDetector(
      onTap: () {
        final itemForDetail = {
          ...p,
          'salesMode': salesMode,
          'selectedMode': currentMode,
          'saleType': isWholesale ? 'mayor' : 'detalle',
          'selectedUnit': selectedUnit,
        };
        context.push('/product_detail', extra: itemForDetail);
      },
      child: Container(
        height: 176,
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left Image Section
            SizedBox(
              width: 122,
              height: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                    child: _buildProductImage(imgSrc),
                  ),
                  // Favorite Button
                  Positioned(
                    top: 8,
                    left: 8,
                    child: ValueListenableBuilder<List<Map<String, dynamic>>>(
                      valueListenable: globalFavorites,
                      builder: (context, favorites, child) {
                        final isFav = isFavorite(productTitle);
                        return AnimatedFavoriteButton(
                          isFavorite: isFav,
                          size: 16,
                          backgroundColor: Colors.white.withValues(alpha: 0.85),
                          onTap: () {
                            final productForFav = {
                              'id': p['id'],
                              'name': productTitle,
                              'title': productTitle,
                              'sku': p['sku'] ?? _getProductSku(p),
                              'category': p['category'],
                              'supplier': providerStr,
                              'provider': providerStr,
                              'price': '\$${displayPrice.toStringAsFixed(2)}',
                              'unit': 'por ${selectedUnit.toLowerCase()}',
                              'quality': qualityStr,
                              'isWholesale': isWholesale,
                              'saleType': isWholesale ? 'mayor' : 'detalle',
                              'image': imgSrc,
                            };
                            toggleFavorite(productForFav);
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    Icon(isFav ? Icons.heart_broken : Icons.favorite, color: Colors.white, size: 18),
                                    const SizedBox(width: 10),
                                    Text(
                                      isFav ? 'Eliminado de favoritos' : 'Agregado a favoritos',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                  ],
                                ),
                                backgroundColor: isFav ? Colors.red.shade400 : const Color(0xFF016142),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Right Info Section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product Title & Sales Mode Indicator
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    productTitle,
                                    style: TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                                      height: 1.15,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 1.5),
                                  Text(
                                    'SKU: ${p['sku'] ?? _getProductSku(p)}',
                                    style: TextStyle(
                                      fontFamily: 'Manrope',
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.w500,
                                      color: isDark ? Colors.grey.shade400 : const Color(0xFF94A3B8),
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 4),
                            _buildSalesModeIndicator(p, theme, isDark, productTitle),
                          ],
                        ),
                        const SizedBox(height: 4),

                        // CALIDAD Row
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
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: qualityColor.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.workspace_premium,
                                  color: qualityColor,
                                  size: 13,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('CALIDAD', style: TextStyle(fontSize: 7.5, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.4)),
                                  Text(displayQuality, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: qualityColor, height: 1.1)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),

                        // PROVEEDOR Row
                        GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) => SupplierQuickViewBottomSheet(
                                supplierData: {
                                  'name': providerStr,
                                  'supplier': providerStr,
                                  'location': locationStr,
                                  'isVerified': true,
                                },
                              ),
                            );
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Row(
                            children: [
                              Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.local_florist, color: theme.colorScheme.primary, size: 13),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('PROVEEDOR', style: TextStyle(fontSize: 7.5, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.4)),
                                    Text(providerStr, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1E293B), height: 1.1), overflow: TextOverflow.ellipsis),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),

                        // UBICACIÃ“N Row
                        Row(
                          children: [
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: isDark ? Colors.grey[800] : const Color(0xFFF1F5F9),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.location_on,
                                color: Colors.grey[500],
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
                                      fontSize: 7.5,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey,
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                  Text(
                                    locationStr,
                                    style: TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w500,
                                      color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
                                      height: 1.1,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Bottom Row: Unit Selector, Price, and Cart Icon Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              // Price on the left
                              Flexible(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: [
                                      Text(
                                        '\$${displayPrice.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontSize: 16.5,
                                          fontWeight: FontWeight.w900,
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                      Text(
                                        '/${selectedUnit.toLowerCase()}',
                                        style: TextStyle(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              // Styled Unit Selector Chip on the right
                              PopupMenuButton<String>(
                                initialValue: selectedUnit,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 4,
                                onSelected: (String newValue) {
                                  setState(() {
                                    _selectedUnits[productTitle] = newValue;
                                  });
                                },
                                itemBuilder: (context) => availableUnits.map((u) {
                                  final isCurrent = u == selectedUnit;
                                  return PopupMenuItem(
                                    value: u,
                                    height: 36,
                                    child: Row(
                                      children: [
                                        Icon(
                                          isCurrent ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
                                          size: 14,
                                          color: isCurrent ? theme.colorScheme.primary : Colors.grey[400],
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Venta por: $u',
                                          style: TextStyle(
                                            fontFamily: 'Manrope',
                                            fontSize: 12,
                                            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                                            color: isCurrent ? theme.colorScheme.primary : (isDark ? Colors.white : Colors.black87),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary.withValues(alpha: isDark ? 0.15 : 0.08),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: theme.colorScheme.primary.withValues(alpha: isDark ? 0.35 : 0.22),
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Venta por: $selectedUnit',
                                        style: TextStyle(
                                          fontFamily: 'Manrope',
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                          color: isDark ? Colors.grey[200] : const Color(0xFF0F172A),
                                        ),
                                      ),
                                      const SizedBox(width: 2),
                                      Icon(Icons.keyboard_arrow_down_rounded, size: 13, color: theme.colorScheme.primary),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        // Cart icon button on the right lateral
                        GestureDetector(
                          onTap: () {
                            final cartItem = {
                              'name': productTitle,
                              'supplier': providerStr,
                              'price': '\$${displayPrice.toStringAsFixed(2)}',
                              'unit': selectedUnit,
                              'available_units': availableUnits,
                              'quality': qualityStr,
                              'isWholesale': isWholesale,
                              'saleType': isWholesale ? 'Por Mayor' : 'Al Detalle',
                              'image': imgSrc,
                            };
                            addToCart(cartItem);
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(Icons.shopping_cart, color: Colors.white, size: 18),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        'Añadido al carrito ($productTitle)',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                backgroundColor: const Color(0xFF016142),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: theme.colorScheme.primary.withValues(alpha: 0.35),
                                width: 0.9,
                              ),
                            ),
                            child: Icon(Icons.shopping_cart_outlined, color: theme.colorScheme.primary, size: 15),
                          ),
                        ),
                      ],
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
