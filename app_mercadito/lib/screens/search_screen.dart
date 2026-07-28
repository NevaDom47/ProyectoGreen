import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/global_state.dart';
import '../widgets/supplier_quick_view_bottom_sheet.dart';
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
  List<String> _searchHistory = [];
  bool _isLoading = true;

  final Map<String, String> _selectedUnits = {};

  final List<Map<String, dynamic>> _allProducts = [
    {
      'title': 'Tomate Saladette',
      'provider': 'Granja El Sol',
      'location': 'Valle de Santiago, GTO',
      'price': '28.50',
      'unit': 'KG',
      'available_units': ['KG', 'LB', 'SACO'],
      'quality': '1ra Calidad',
      'category': 'Frutas y Verduras',
      'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuDF4fUzPGSX592_YU4gqZe1p3VUwRebja4WL0DnDH5yTSAYkaRTrfuZinxjIuia7OxOMEmPomP57T7lYPKBOGOcXDZu4blV8E0vEouSIkR19xu4nV9rovZdEsh0VWKzl-nHf4oqtXfslTT9n5tRw5qiIw5nwCTt106Syb5tyTGhM2mdBmPqvoM4EKK7wP7Ha6ZcidD1by61ld-itwhNlFPnaJQKJOC-1FJ6s2wsjzHxKYeMuFgaLZ-iMHtz5IFBpPZdVa-ZeShjYbE'
    },
    {
      'title': 'Tomate Bola Orgánico',
      'provider': 'Huertos San Juan',
      'location': 'Irapuato, GTO',
      'price': '35.00',
      'unit': 'KG',
      'available_units': ['KG', 'LB'],
      'quality': '1ra Calidad',
      'category': 'Frutas y Verduras',
      'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuBpkgELbOrgnfZCX2ldQAJntDk7MuvNzM2xj3ZX-s4hk6IEkRxT-JL21rrYl0wylUNhx6ss5tQZRgA-ez-zFDASz8N8vgHjeW2WOMuST9XT-TJ4kW4pnn_Ehc9qdjoobIZGbV2QsRsF2X6ZWKyht57UvloZOBtS1P1T9LuhL5_erze1q1BEaK7Go9ox0J6pBGX9OY6POaJ76vtgX8--SU6-LvdIQUtJHtKja8tfJH9dwUOexlUhPQ5SqBpdJ7O9w-LElo_r3a9IzeA'
    },
    {
      'title': 'Maíz Blanco',
      'provider': 'Agropecuaria del Bajío',
      'location': 'Celaya, GTO',
      'price': '850.00',
      'unit': 'SACO',
      'available_units': ['SACO', 'KG'],
      'quality': '2da Calidad',
      'category': 'Cereales y Granos',
      'image': 'https://storage.googleapis.com/a1aa/image/RjWzE83BfT1lI6I5qB1a3mQe6qQ7Gf11zVqA1Wq8zN4f20HnA.jpg'
    },
    {
      'title': 'Frijol Flor de Mayo',
      'provider': 'Semillas y Granos',
      'location': 'Salamanca, GTO',
      'price': '45.00',
      'unit': 'KG',
      'available_units': ['KG', 'LB', 'SACO'],
      'quality': '1ra Calidad',
      'category': 'Cereales y Granos',
      'image': 'https://storage.googleapis.com/a1aa/image/eF3K8qZ21LqV1JvH4D2nN8gX7tY9bP4wT3kR5mS2eM1aP9pI.jpg' 
    },
    {
      'title': 'Alimento para Cerdos',
      'provider': 'Nutrición Animal',
      'location': 'León, GTO',
      'price': '520.00',
      'unit': 'SACO',
      'available_units': ['SACO', 'KG'],
      'quality': '3ra Calidad',
      'category': 'Alimento Animal',
      'image': 'https://storage.googleapis.com/a1aa/image/M3bT1aY4qP2nK8gX7tY9bP4wT3kR5mS2eM1aP9pIeF3K8qZ21.jpg'
    },
    {
      'title': 'Semilla de Sorgo',
      'provider': 'Semillas del Centro',
      'location': 'Irapuato, GTO',
      'price': '1200.00',
      'unit': 'SACO',
      'available_units': ['SACO', 'KG'],
      'quality': '1ra Calidad',
      'category': 'Semillas',
      'image': 'https://storage.googleapis.com/a1aa/image/Y4qP2nK8gX7tY9bP4wT3kR5mS2eM1aP9pIeF3K8qZ21M3bT1a.jpg'
    },
    {
      'title': 'Queso Fresco',
      'provider': 'Lácteos La Vaca',
      'location': 'Silao, GTO',
      'price': '85.00',
      'unit': 'KG',
      'available_units': ['KG', 'LB'],
      'quality': '2da Calidad',
      'category': 'Lácteos',
      'image': 'https://storage.googleapis.com/a1aa/image/7tY9bP4wT3kR5mS2eM1aP9pIeF3K8qZ21M3bT1aY4qP2nK8gX.jpg'
    },
    {
      'title': 'Huevo Blanco',
      'provider': 'Avícola San José',
      'location': 'Abasolo, GTO',
      'price': '38.00',
      'unit': 'CAJA',
      'available_units': ['CAJA', 'DOCENA'],
      'quality': '1ra Calidad',
      'category': 'Huevos',
      'image': 'https://storage.googleapis.com/a1aa/image/wT3kR5mS2eM1aP9pIeF3K8qZ21M3bT1aY4qP2nK8gX7tY9bP4.jpg'
    },
    {
      'title': 'Carne de Res Molida',
      'provider': 'Carnicería El Torito',
      'location': 'Pénjamo, GTO',
      'price': '140.00',
      'unit': 'KG',
      'available_units': ['KG', 'LB'],
      'quality': '1ra Calidad',
      'category': 'Carnes y Embutidos',
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

  List<Map<String, dynamic>> get _filteredProducts {
    return _allProducts.where((p) {
      if (_activeCategory.isNotEmpty && p['category'] != _activeCategory && _activeCategory != 'Todos') return false;
      
      if (_activeQuery.isNotEmpty) {
        if (!p['title'].toString().toLowerCase().contains(_activeQuery) && !p['provider'].toString().toLowerCase().contains(_activeQuery)) {
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
                                color: isSelected ? theme.colorScheme.primary : Colors.grey.withOpacity(0.2),
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
                  side: BorderSide(color: Colors.grey.withOpacity(0.3)),
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
                          color: isSelected ? theme.colorScheme.primary.withOpacity(0.1) : surfaceColor,
                          shape: BoxShape.circle,
                          border: isSelected ? Border.all(color: theme.colorScheme.primary, width: 2) : null,
                          boxShadow: [
                            if (!isSelected)
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
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

  Widget _buildSearchProductCard(Map<String, dynamic> p, ThemeData theme, Color surfaceColor, bool isDark) {
    Color qualityColor = theme.colorScheme.primary;
    if (p['quality'] == '2da Calidad') {
      qualityColor = const Color(0xFFE2725B); // Mamey
    } else if (p['quality'] == '3ra Calidad') {
      qualityColor = Colors.red;
    }

    final List<String> availableUnits = List<String>.from(p['available_units'] ?? [p['unit']]);
    final selectedUnit = _selectedUnits[p['title']] ?? availableUnits.first;
    
    // Calculate display price
    double basePrice = double.tryParse(p['price'].toString()) ?? 0.0;
    double displayPrice = basePrice;
    if (selectedUnit != p['unit']) {
      if (selectedUnit == 'LB' && p['unit'] == 'KG') displayPrice = basePrice * 0.45;
      else if (selectedUnit == 'KG' && p['unit'] == 'SACO') displayPrice = basePrice / 50;
      else if (selectedUnit == 'SACO' && p['unit'] == 'KG') displayPrice = basePrice * 50;
      else if (selectedUnit == 'CAJA' && p['unit'] == 'DOCENA') displayPrice = basePrice * 2.5;
      else if (selectedUnit == 'DOCENA' && p['unit'] == 'CAJA') displayPrice = basePrice / 2.5;
      else displayPrice = basePrice * 1.5; // fallback
    }

    return GestureDetector(
      onTap: () => context.push('/product_detail', extra: p),
      child: Container(
        height: 150, // Slightly taller to fit the new row
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image section
            SizedBox(
              width: 120,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                    child: Image.network(
                      p['image'] as String,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.image_not_supported, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                  // Favorite Button
                  Positioned(
                    top: 8,
                    left: 8,
                    child: ValueListenableBuilder<List<Map<String, dynamic>>>(
                      valueListenable: globalFavorites,
                      builder: (context, favorites, child) {
                        final isFav = isFavorite(p['title'] as String);

                          return AnimatedFavoriteButton(
                            isFavorite: isFav,
                            size: 18,
                            backgroundColor: Colors.white.withOpacity(0.8),
                            onTap: () {
                              final productForFav = {
                                'id': p['id'],
                                'name': p['title'],
                                'category': p['category'],
                                'supplier': p['provider'],
                                'price': '\$${displayPrice.toStringAsFixed(2)}',
                                'unit': 'por ${selectedUnit.toLowerCase()}',
                                'quality': p['quality'],
                                'image': p['image'],
                              };
                              toggleFavorite(productForFav);
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
            
            // Info section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p['title'] as String,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) => SupplierQuickViewBottomSheet(
                                supplierData: {
                                  'name': p['provider'],
                                  'isVerified': true,
                                },
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              Icon(Icons.storefront, size: 14, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text(
                                p['provider'] as String,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[700],
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(Icons.verified, size: 12, color: theme.colorScheme.primary),
                            ],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 12, color: Colors.grey[500]),
                            const SizedBox(width: 4),
                            Text(
                              p['location'] as String,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // NEW ROW for Sales Type and Quality
                        Row(
                          children: [
                            PopupMenuButton<String>(
                              initialValue: selectedUnit,
                              padding: EdgeInsets.zero,
                              onSelected: (String newValue) {
                                setState(() {
                                  _selectedUnits[p['title'] as String] = newValue;
                                });
                              },
                              itemBuilder: (context) => availableUnits.map((u) => PopupMenuItem(
                                value: u,
                                child: Text('Venta por: $u', style: const TextStyle(fontSize: 12)),
                              )).toList(),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.grey[800] : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Venta por: $selectedUnit',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? Colors.grey[300] : Colors.grey[800],
                                      ),
                                    ),
                                    Icon(Icons.arrow_drop_down, size: 12, color: isDark ? Colors.grey[300] : Colors.grey[800]),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.grey[800] : Colors.white,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: qualityColor),
                              ),
                              child: Text(
                                (p['quality'] as String).toUpperCase(),
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: qualityColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '\$${displayPrice.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            Text(
                              '/${selectedUnit.toLowerCase()}',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            final cartItem = {
                              'name': p['title'],
                              'supplier': p['provider'],
                              'price': '\$${displayPrice.toStringAsFixed(2)}',
                              'unit': selectedUnit,
                              'available_units': availableUnits,
                              'quality': p['quality'],
                              'image': p['image'],
                            };
                            addToCart(cartItem);
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Añadido al carrito', style: TextStyle(fontWeight: FontWeight.bold)),
                                backgroundColor: const Color(0xFF016142),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: isDark ? Colors.grey[800] : const Color(0xFFf1f4f0),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.add, size: 18, color: theme.colorScheme.primary),
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
