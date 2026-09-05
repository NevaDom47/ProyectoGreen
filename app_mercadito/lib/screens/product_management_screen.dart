import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'add_product_screen.dart';

class ProductManagementScreen extends StatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  State<ProductManagementScreen> createState() =>
      _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  // Emerald Harvest Color Palette
  static const Color primaryColor = Color(0xFF00462F);
  static const Color backgroundColor = Color(0xFFF7FAF5);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF181D1A);
  static const Color onSurfaceVariant = Color(0xFF486456);
  static const Color outlineColor = Color(0x33BEC9C1);
  static const Color surfaceLow = Color(0xFFF1F4F0);

  // Chip Custom Colors
  static const Color chipSelectedBg = Color(0xFF016042);
  static const Color chipSelectedText = Color(0xFFFFFFFF);
  static const Color chipSelectedBorder = Color(0xFF016042);

  static const Color chipUnselectedBg = Color(0xFFF1F4F0);
  static const Color chipUnselectedText = Color(0xFF737373);
  static const Color chipUnselectedBorder = Color(0xFFCCDFD9);

  // Badge Tag Colors for Sale Modes
  // Etiqueta al detalle: BackGround #059669, Letras #F1F9F7, Bordes #059669
  static const Color badgeRetailBg = Color(0xFF059669);
  static const Color badgeRetailText = Color(0xFFF1F9F7);
  static const Color badgeRetailBorder = Color(0xFF059669);

  // Etiqueta Por Mayor: Background #0369A1, Letras #EDF4F8, Bordes #0369A1
  static const Color badgeWholesaleBg = Color(0xFF0369A1);
  static const Color badgeWholesaleText = Color(0xFFEDF4F8);
  static const Color badgeWholesaleBorder = Color(0xFF0369A1);

  // Quality Badges
  // Primera calidad: BackGround #DCE9E5 Letras #016042
  static const Color qualityFirstBg = Color(0xFFDCE9E5);
  static const Color qualityFirstText = Color(0xFF016042);
  static const Color qualityFirstBorder = Color(0xFFDCE9E5);

  // Segunda Calidad: BackGround #FFF4E5 Letras #FF9A04
  static const Color qualitySecondBg = Color(0xFFFFF4E5);
  static const Color qualitySecondText = Color(0xFFFF9A04);
  static const Color qualitySecondBorder = Color(0xFFFFF4E5);

  // Tercera Calidad: BackGround #FDEDED Letras #F44336
  static const Color qualityThirdBg = Color(0xFFFDEDED);
  static const Color qualityThirdText = Color(0xFFF44336);
  static const Color qualityThirdBorder = Color(0xFFFDEDED);

  // Category Badge Tag
  // Categoria Etiquetas: BackGround #EAF2E8 Letras #016042 Bordes #BBD5C7
  static const Color badgeCategoryBg = Color(0xFFEAF2E8);
  static const Color badgeCategoryText = Color(0xFF016042);
  static const Color badgeCategoryBorder = Color(0xFFBBD5C7);

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'Todos';
  String _selectedSaleType = 'Todos'; // 'Todos', 'Al por mayor', 'Al detalle'
  String _selectedAvailability = 'Todos'; // 'Todos', 'Disponibles', 'Agotados'
  String _selectedStatus = 'Todos'; // 'Todos', 'Disponible', 'Bajo Stock', 'Agotado'

  final List<String> _categories = [
    'Todos',
    'Hortalizas',
    'Frutas',
    'Cítricos',
    'Tubérculos',
    'Raíces',
    'Legumbres',
  ];

  final List<String> _availabilityFilters = [
    'Todos',
    'Disponibles',
    'Agotados',
  ];

  final List<String> _saleTypes = [
    'Todos',
    'Al por mayor',
    'Al detalle',
  ];

  // Initial Product Catalog
  final List<Map<String, dynamic>> _products = [
    {
      'id': 'PROD-101',
      'name': 'Tomate Saladette',
      'category': 'Hortalizas',
      'badge': 'Primera Calidad',
      'saleType': 'ambos', // 'ambos', 'mayor', 'detalle'
      'price': '\$28.50',
      'priceNum': 28.50,
      'wholesalePrice': '\$22.00',
      'wholesalePriceNum': 22.00,
      'wholesaleMin': '10 LB',
      'unit': 'LB',
      'stock': 120,
      'status': 'Disponible',
      'createdAt': '28 Ago 2026',
      'img':
          'https://lh3.googleusercontent.com/aida/AEtjO1WJPFi5I7ZN-mHEOmgqdgmYQxGUivEKgUceqV8OcdNcWwowkcPmSiJrAgNG82XtSgoX-uePPMYN8BGd4CqtyuTb_DWJcL1N9EY-Zb9pw67Sxhks3OGyC9hadvAaJOIk0gudu0Hrum9DHf9E_MsgiO4Vq3RUl5yWwKlvGxQyVEZbHKV44heVYLB-SuP2c9B2EN7Wg5gaYaoj991-EEiBhW8g_oE8djsBWnAcvDzTbTF6XMHOPxANhCnCOzg',
    },
    {
      'id': 'PROD-102',
      'name': 'Limón Colima',
      'category': 'Cítricos',
      'badge': 'Primera Calidad',
      'saleType': 'ambos',
      'price': '\$35.00',
      'priceNum': 35.00,
      'wholesalePrice': '\$28.00',
      'wholesalePriceNum': 28.00,
      'wholesaleMin': '15 LB',
      'unit': 'LB',
      'stock': 85,
      'status': 'Disponible',
      'createdAt': '27 Ago 2026',
      'img':
          'https://lh3.googleusercontent.com/aida/AEtjO1UDV4xCp1jhcb-egx-ZZs69cRSVWsKFPJbDs5xkG824bImlFddNkfuvUFIAC88rGP-Jp55kQWHiB6FW4SZ-rGaW3DRUqEb_HGtLYuz_FY2tPb8WIlbkWcpwzJ63EaoWFM7aHlX7Yo4NHJwGoOhgT8c5mYeCEQrxmB6-1sLYMwOHSJ45nrpaVqu_awDl5Mff3RLV2UrekFhLE5QIrW-yBLh86eqpu71Aolq3nXys9zWAHQ6cGCpwX9EecgI',
    },
    {
      'id': 'PROD-103',
      'name': 'Aguacate Hass',
      'category': 'Frutas',
      'badge': 'Primera Calidad',
      'saleType': 'mayor',
      'price': '\$48.00',
      'priceNum': 48.00,
      'wholesalePrice': '\$38.00',
      'wholesalePriceNum': 38.00,
      'wholesaleMin': '10 KG',
      'unit': 'KG',
      'stock': 45,
      'status': 'Disponible',
      'createdAt': '25 Ago 2026',
      'img':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCx_eRxHSK6aT1dCBg3UZ21drqrz2a64dmGPr8oTG0AwxQg0tDHVh4AtgkqDL9nFU3WpSX7wpX-mqCzxe8EVd07TtoyRnGyMKSGzfqVdkh_j7V_WDyzIsqHtCn4ZTDR6b7aC1H3c0x9tVl_JkgdHXVc331TsEehHQuMybFAM2rM-_9QQlVy3Su13zKGeSWfPfrF5gFM-iyyAGPQc-_F_W34y3Acj64mtVxWzV11ufTeMWIzML5WRRVceAYqKkB1F4P_yYDKiV2M4QA',
    },
    {
      'id': 'PROD-104',
      'name': 'Papa Blanca Alpha',
      'category': 'Tubérculos',
      'badge': 'Segunda Calidad',
      'saleType': 'detalle',
      'price': '\$18.00',
      'priceNum': 18.00,
      'wholesalePrice': '\$14.50',
      'wholesalePriceNum': 14.50,
      'wholesaleMin': '20 KG',
      'unit': 'KG',
      'stock': 12,
      'status': 'Bajo Stock',
      'createdAt': '22 Ago 2026',
      'img': 'assets/images/PapaGemini.png',
    },
    {
      'id': 'PROD-105',
      'name': 'Zanahoria Orgánica',
      'category': 'Raíces',
      'badge': 'Primera Calidad',
      'saleType': 'ambos',
      'price': '\$12.50',
      'priceNum': 12.50,
      'wholesalePrice': '\$9.80',
      'wholesalePriceNum': 9.80,
      'wholesaleMin': '15 KG',
      'unit': 'KG',
      'stock': 0,
      'status': 'Agotado',
      'createdAt': '20 Ago 2026',
      'img': 'assets/images/ZanahoriaGemini.png',
    },
    {
      'id': 'PROD-106',
      'name': 'Fresas de Campo Extras',
      'category': 'Frutas',
      'badge': 'Primera Calidad',
      'saleType': 'detalle',
      'price': '\$45.00',
      'priceNum': 45.00,
      'wholesalePrice': '\$36.00',
      'wholesalePriceNum': 36.00,
      'wholesaleMin': '10 KG',
      'unit': 'KG',
      'stock': 65,
      'status': 'Disponible',
      'createdAt': '18 Ago 2026',
      'img':
          'https://raw.githubusercontent.com/NevaDom47/imagenes/refs/heads/main/20250620_1233_Fresas%20en%20Fondo%20Rosado_simple_compose_01jy72ypjmeccafrqb33rfm1q8.png',
    },
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      if (mounted) {
        setState(() {
          _searchQuery = _searchController.text.trim().toLowerCase();
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (bottomSheetCtx, setSheetState) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Reset row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.tune, color: primaryColor, size: 22),
                          SizedBox(width: 8),
                          Text(
                            'Filtros Avanzados',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          setSheetState(() {
                            _selectedSaleType = 'Todos';
                            _selectedCategory = 'Todos';
                            _selectedAvailability = 'Todos';
                            _selectedStatus = 'Todos';
                          });
                          setState(() {});
                        },
                        child: const Text(
                          'Limpiar',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontWeight: FontWeight.bold,
                            color: onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 10),

                  // Section 1: Modalidad de Venta (Al por mayor / Al detalle / Todos)
                  const Text(
                    'Tipo de Venta',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _saleTypes.map((type) {
                      final isSel = _selectedSaleType == type;
                      return GestureDetector(
                        onTap: () {
                          setSheetState(() => _selectedSaleType = type);
                          setState(() {});
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSel ? chipSelectedBg : chipUnselectedBg,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSel ? chipSelectedBorder : chipUnselectedBorder,
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isSel) ...[
                                const Icon(
                                  Icons.check,
                                  size: 14,
                                  color: chipSelectedText,
                                ),
                                const SizedBox(width: 4),
                              ],
                              Text(
                                type,
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 12,
                                  fontWeight: isSel ? FontWeight.bold : FontWeight.w600,
                                  color: isSel ? chipSelectedText : chipUnselectedText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Section 2: Estado de Stock
                  const Text(
                    'Disponibilidad de Inventario',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ['Todos', 'Disponible', 'Agotado'].map((status) {
                      final isSel = _selectedStatus == status;
                      return GestureDetector(
                        onTap: () {
                          setSheetState(() => _selectedStatus = status);
                          setState(() {});
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSel ? chipSelectedBg : chipUnselectedBg,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSel ? chipSelectedBorder : chipUnselectedBorder,
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isSel) ...[
                                const Icon(
                                  Icons.check,
                                  size: 14,
                                  color: chipSelectedText,
                                ),
                                const SizedBox(width: 4),
                              ],
                              Text(
                                status,
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 12,
                                  fontWeight: isSel ? FontWeight.bold : FontWeight.w600,
                                  color: isSel ? chipSelectedText : chipUnselectedText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Apply button
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text(
                        'APLICAR FILTROS',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showAddProductDialog() async {
    final newProduct = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (_) => const AddProductScreen(),
      ),
    );

    if (newProduct != null) {
      setState(() {
        _products.insert(0, newProduct);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('✓ Producto "${newProduct['name']}" agregado con éxito'),
                ),
              ],
            ),
            backgroundColor: primaryColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  Future<void> _editProductFull(Map<String, dynamic> product) async {
    final updatedProduct = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (_) => AddProductScreen(initialProduct: product),
      ),
    );

    if (updatedProduct != null) {
      setState(() {
        final index = _products.indexWhere((p) => p['id'] == product['id']);
        if (index != -1) {
          _products[index] = updatedProduct;
        }
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('✓ "${updatedProduct['name']}" actualizado con éxito'),
                ),
              ],
            ),
            backgroundColor: primaryColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  void _editProductPriceDialog(Map<String, dynamic> product) {
    final priceCtrl = TextEditingController(
      text: (product['priceNum'] ?? 0.0).toStringAsFixed(2),
    );
    final wholesaleCtrl = TextEditingController(
      text: (product['wholesalePriceNum'] ?? 0.0).toStringAsFixed(2),
    );
    final stockCtrl = TextEditingController(
      text: (product['stock'] ?? 0).toString(),
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Editar ${product['name']}',
          style: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: priceCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Precio Menudeo (\$) ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: wholesaleCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Precio Mayoreo (\$) ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: stockCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Stock',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              final newPrice = double.tryParse(priceCtrl.text) ?? product['priceNum'] ?? 0.0;
              final newWholesale = double.tryParse(wholesaleCtrl.text) ?? product['wholesalePriceNum'] ?? 0.0;
              final newStock = int.tryParse(stockCtrl.text) ?? product['stock'] ?? 0;

              setState(() {
                product['priceNum'] = newPrice;
                product['price'] = '\$${newPrice.toStringAsFixed(2)}';
                product['wholesalePriceNum'] = newWholesale;
                product['wholesalePrice'] = '\$${newWholesale.toStringAsFixed(2)}';
                product['stock'] = newStock;
                product['status'] = newStock > 0 ? 'Disponible' : 'Agotado';
              });

              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('✓ ${product['name']} actualizado')),
              );
            },
            child: const Text('GUARDAR'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF101915) : backgroundColor;
    final cardColor = isDark ? const Color(0xFF1A2420) : surfaceColor;

    final hasActiveFilter = _selectedSaleType != 'Todos' ||
        _selectedStatus != 'Todos' ||
        _selectedAvailability != 'Todos' ||
        _selectedCategory != 'Todos';

    // Filter products
    final filtered = _products.where((p) {
      final name = (p['name'] ?? '').toString().toLowerCase();
      final cat = (p['category'] ?? '').toString().toLowerCase();
      final status = (p['status'] ?? 'Disponible').toString();
      final isAgotado = status.toLowerCase() == 'agotado';

      final matchesQuery = _searchQuery.isEmpty ||
          name.contains(_searchQuery) ||
          cat.contains(_searchQuery);

      final matchesCategory = _selectedCategory == 'Todos' ||
          cat == _selectedCategory.toLowerCase();

      // Availability filter ('Todos', 'Disponibles', 'Agotados')
      bool matchesAvailability = true;
      if (_selectedAvailability == 'Disponibles') {
        matchesAvailability = !isAgotado;
      } else if (_selectedAvailability == 'Agotados') {
        matchesAvailability = isAgotado;
      }

      // Sale type filter (Al por mayor / Al detalle / Todos)
      final saleType = (p['saleType'] ?? 'ambos').toString().toLowerCase();
      bool matchesSaleType = true;
      if (_selectedSaleType == 'Al por mayor') {
        matchesSaleType = saleType == 'mayor' || saleType == 'ambos';
      } else if (_selectedSaleType == 'Al detalle') {
        matchesSaleType = saleType == 'detalle' || saleType == 'ambos';
      }

      // Status filter
      final matchesStatus = _selectedStatus == 'Todos' ||
          status.toLowerCase() == _selectedStatus.toLowerCase();

      return matchesQuery &&
          matchesCategory &&
          matchesAvailability &&
          matchesSaleType &&
          matchesStatus;
    }).toList();

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        title: const Text(
          'Gestión de Productos',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: primaryColor,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section with Title and "+ AGREGAR PRODUCTO" Button
            Container(
              color: cardColor,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Productos',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontWeight: FontWeight.w800,
                              fontSize: 24,
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Administra los productos de tu mercado',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 13,
                              color: isDark ? Colors.white70 : onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // "+ AGREGAR PRODUCTO" Pill Button
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      elevation: 1,
                    ),
                    onPressed: _showAddProductDialog,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text(
                      'AGREGAR PRODUCTO',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Search Box Row with Advanced Filter Button on the right
                  Row(
                    children: [
                      // Search TextField
                      Expanded(
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF26302B) : surfaceLow,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: TextField(
                            controller: _searchController,
                            style: const TextStyle(fontSize: 13),
                            decoration: InputDecoration(
                              hintText: 'Buscar producto o categoría...',
                              hintStyle: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.white38 : onSurfaceVariant,
                              ),
                              prefixIcon: const Icon(
                                Icons.search,
                                size: 18,
                                color: onSurfaceVariant,
                              ),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(
                                        Icons.close,
                                        size: 16,
                                        color: onSurfaceVariant,
                                      ),
                                      onPressed: () => _searchController.clear(),
                                    )
                                  : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Filter Button (Next to Search Bar)
                      InkWell(
                        onTap: _showFilterBottomSheet,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            color: hasActiveFilter
                                ? primaryColor
                                : (isDark ? const Color(0xFF26302B) : surfaceLow),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: hasActiveFilter ? primaryColor : outlineColor,
                            ),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Icon(
                                Icons.tune,
                                size: 20,
                                color: hasActiveFilter
                                    ? Colors.white
                                    : onSurfaceVariant,
                              ),
                              if (hasActiveFilter)
                                Positioned(
                                  top: 6,
                                  right: 6,
                                  child: Container(
                                    width: 7,
                                    height: 7,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFF2A900),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Category Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _categories.map((cat) {
                        final isSel = _selectedCategory == cat;
                        final count = cat == 'Todos'
                            ? _products.length
                            : _products
                                .where((p) =>
                                    (p['category'] ?? '').toString().toLowerCase() ==
                                    cat.toLowerCase())
                                .length;

                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedCategory = cat),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: isSel
                                    ? chipSelectedBg
                                    : (isDark ? const Color(0xFF26302B) : chipUnselectedBg),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSel ? chipSelectedBorder : chipUnselectedBorder,
                                ),
                              ),
                              child: Text(
                                '$cat ($count)',
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 11,
                                  fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                                  color: isSel
                                      ? chipSelectedText
                                      : (isDark ? Colors.white70 : chipUnselectedText),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Sales Mode Quick Segment ("Todos", "Al por mayor", "Al detalle")
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Text(
                          'Tipo de venta: ',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white60 : onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 4),
                        ..._saleTypes.map((type) {
                          final isSel = _selectedSaleType == type;
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedSaleType = type),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 9,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isSel
                                      ? chipSelectedBg
                                      : (isDark ? const Color(0xFF26302B) : chipUnselectedBg),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: isSel ? chipSelectedBorder : chipUnselectedBorder,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      type == 'Al por mayor'
                                          ? Icons.inventory_2_outlined
                                          : (type == 'Al detalle'
                                              ? Icons.shopping_basket_outlined
                                              : Icons.apps),
                                      size: 12,
                                      color: isSel ? chipSelectedText : chipUnselectedText,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      type,
                                      style: TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: 10,
                                        fontWeight: isSel
                                            ? FontWeight.bold
                                            : FontWeight.w600,
                                        color: isSel
                                            ? chipSelectedText
                                            : (isDark ? Colors.white70 : chipUnselectedText),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Availability Quick Segment ("Todos", "Disponibles", "Agotados")
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Text(
                          'Disponibilidad: ',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white60 : onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 4),
                        ..._availabilityFilters.map((avail) {
                          final isSel = _selectedAvailability == avail;
                          int count = 0;
                          if (avail == 'Todos') {
                            count = _products.length;
                          } else if (avail == 'Disponibles') {
                            count = _products.where((p) => (p['status'] ?? '').toString().toLowerCase() != 'agotado').length;
                          } else if (avail == 'Agotados') {
                            count = _products.where((p) => (p['status'] ?? '').toString().toLowerCase() == 'agotado').length;
                          }

                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedAvailability = avail),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 9,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isSel
                                      ? chipSelectedBg
                                      : (isDark ? const Color(0xFF26302B) : chipUnselectedBg),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: isSel ? chipSelectedBorder : chipUnselectedBorder,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (avail == 'Todos')
                                      Icon(
                                        Icons.apps,
                                        size: 12,
                                        color: isSel ? chipSelectedText : chipUnselectedText,
                                      ),
                                    if (avail == 'Disponibles')
                                      Icon(
                                        Icons.check_circle_outline,
                                        size: 12,
                                        color: isSel ? chipSelectedText : const Color(0xFF059669),
                                      ),
                                    if (avail == 'Agotados')
                                      Icon(
                                        Icons.block,
                                        size: 12,
                                        color: isSel ? chipSelectedText : const Color(0xFFE53935),
                                      ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '$avail ($count)',
                                      style: TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: 10,
                                        fontWeight: isSel
                                            ? FontWeight.bold
                                            : FontWeight.w600,
                                        color: isSel
                                            ? chipSelectedText
                                            : (isDark ? Colors.white70 : chipUnselectedText),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE5E7EB)),

            // Product Cards List
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.inventory_2_outlined,
                            size: 48,
                            color: onSurfaceVariant,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No se encontraron productos',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: isDark ? Colors.white70 : onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Prueba cambiando la modalidad o los filtros de búsqueda',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 12,
                              color: isDark ? Colors.white38 : onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final product = filtered[index];
                        return _buildProductCard(product, cardColor, isDark);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // Product Card matching Emerald Harvest design with Inactive / Sold out styling
  Widget _buildProductCard(
    Map<String, dynamic> product,
    Color cardColor,
    bool isDark,
  ) {
    final name = product['name']?.toString() ?? 'Producto';
    final category = product['category']?.toString() ?? '';
    final badge = product['badge']?.toString() ?? 'Primera Calidad';
    final price = product['price']?.toString() ?? '\$0.00';
    final wholesalePrice = product['wholesalePrice']?.toString() ?? '';
    final wholesaleMin = product['wholesaleMin']?.toString() ?? '';
    final unit = product['unit']?.toString() ?? 'LB';
    final imgUrl = product['img']?.toString() ?? '';
    final status = product['status']?.toString() ?? 'Disponible';
    final saleType = product['saleType']?.toString() ?? 'ambos';
    final isAgotado = status.toLowerCase() == 'agotado';

    // Inactive visual tokens for Sold Out products
    final cardBg = isAgotado
        ? (isDark ? const Color(0xFF1E1F21) : const Color(0xFFF9FAFA))
        : cardColor;
    final cardBorderColor = isAgotado
        ? (isDark ? const Color(0x33E53935) : const Color(0xFFE5E7EB))
        : outlineColor;
    final titleColor = isAgotado
        ? (isDark ? Colors.white38 : const Color(0xFF8A928D))
        : (isDark ? Colors.white : onSurface);
    final priceColor = isAgotado
        ? (isDark ? Colors.white38 : const Color(0xFF75857C))
        : primaryColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: cardBorderColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isAgotado ? Colors.transparent : const Color(0x0A000000),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Image Wrapper with Opacity/Grayscale effect when Agotado
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 80,
                      height: 80,
                      color: surfaceLow,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Opacity(
                            opacity: isAgotado ? 0.38 : 1.0,
                            child: ColorFiltered(
                              colorFilter: isAgotado
                                  ? const ColorFilter.matrix(<double>[
                                      0.2126, 0.7152, 0.0722, 0, 0,
                                      0.2126, 0.7152, 0.0722, 0, 0,
                                      0.2126, 0.7152, 0.0722, 0, 0,
                                      0, 0, 0, 1, 0,
                                    ])
                                  : const ColorFilter.mode(
                                      Colors.transparent,
                                      BlendMode.dst,
                                    ),
                              child: _buildImage(imgUrl),
                            ),
                          ),
                          if (isAgotado)
                            Container(
                              color: const Color(0x33000000),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.block,
                                color: Color(0xFFD32F2F),
                                size: 28,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Content Area
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Top row: Title and 3-dots Menu
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      name,
                                      style: TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: titleColor,
                                        decoration: isAgotado
                                            ? TextDecoration.lineThrough
                                            : TextDecoration.none,
                                        decorationColor: const Color(0xFFB0BEC5),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuButton<String>(
                              icon: const Icon(
                                Icons.more_vert,
                                size: 20,
                                color: onSurfaceVariant,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onSelected: (val) {
                                if (val == 'edit_full') {
                                  _editProductFull(product);
                                } else if (val == 'edit_quick') {
                                  _editProductPriceDialog(product);
                                } else if (val == 'status') {
                                  setState(() {
                                    product['status'] =
                                        isAgotado ? 'Disponible' : 'Agotado';
                                  });
                                } else if (val == 'delete') {
                                  setState(() {
                                    _products.removeWhere(
                                        (p) => p['id'] == product['id']);
                                  });
                                }
                              },
                              itemBuilder: (ctx) => [
                                const PopupMenuItem(
                                  value: 'edit_full',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit_note_outlined, size: 18, color: primaryColor),
                                      SizedBox(width: 8),
                                      Text('Editar Información Completa'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'edit_quick',
                                  child: Row(
                                    children: [
                                      Icon(Icons.tune_outlined, size: 18, color: primaryColor),
                                      SizedBox(width: 8),
                                      Text('Edición Rápida (Precio / Stock)'),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'status',
                                  child: Row(
                                    children: [
                                      Icon(
                                        isAgotado
                                            ? Icons.check_circle_outline
                                            : Icons.block,
                                        size: 18,
                                        color: isAgotado
                                            ? Colors.green
                                            : Colors.orange,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(isAgotado
                                          ? 'Marcar Disponible'
                                          : 'Marcar Agotado'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete_outline, size: 18, color: Colors.red),
                                      SizedBox(width: 8),
                                      Text('Eliminar', style: TextStyle(color: Colors.red)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),

                        // Quality Badge, Category Badge, Sale Mode Tags & Status Row
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            if (isAgotado)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 2.5,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFEBEE),
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                    color: const Color(0xFFEF5350),
                                    width: 0.8,
                                  ),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.cancel_outlined,
                                      size: 11,
                                      color: Color(0xFFC62828),
                                    ),
                                    SizedBox(width: 3),
                                    Text(
                                      'AGOTADO / NO DISPONIBLE',
                                      style: TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFFC62828),
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else ...[
                              if (category.isNotEmpty) _buildCategoryBadge(category),
                              _buildQualityBadge(badge),
                              if (saleType == 'detalle' || saleType == 'ambos')
                                _buildModeTag(
                                  label: 'Detalle',
                                  icon: Icons.shopping_basket_outlined,
                                  bgColor: badgeRetailBg,
                                  textColor: badgeRetailText,
                                  borderColor: badgeRetailBorder,
                                ),
                              if (saleType == 'mayor' || saleType == 'ambos')
                                _buildModeTag(
                                  label: 'Por Mayor',
                                  icon: Icons.inventory_2_outlined,
                                  bgColor: badgeWholesaleBg,
                                  textColor: badgeWholesaleText,
                                  borderColor: badgeWholesaleBorder,
                                ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Price, Unit and Creation Date Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  price,
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontWeight: FontWeight.w800,
                                    fontSize: 20,
                                    color: priceColor,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  ' / $unit',
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white38 : const Color(0xFF8A928D),
                                  ),
                                ),
                                if (wholesalePrice.isNotEmpty && saleType != 'detalle' && !isAgotado) ...[
                                  const SizedBox(width: 6),
                                  Text(
                                    'Por Mayor: $wholesalePrice ($wholesaleMin)',
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white54 : onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            if (product['createdAt'] != null)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.calendar_today_outlined,
                                    size: 10,
                                    color: isDark ? Colors.white38 : const Color(0xFF9E9E9E),
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    product['createdAt'].toString(),
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w500,
                                      color: isDark ? Colors.white38 : const Color(0xFF9E9E9E),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (isAgotado)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF5350),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'INACTIVO',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBadge(String category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        color: badgeCategoryBg,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: badgeCategoryBorder, width: 0.8),
      ),
      child: Text(
        category,
        style: const TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: badgeCategoryText,
        ),
      ),
    );
  }

  Widget _buildQualityBadge(String badge) {
    Color bg = qualityFirstBg;
    Color text = qualityFirstText;
    Color border = qualityFirstBorder;

    final lower = badge.toLowerCase();
    if (lower.contains('segunda')) {
      bg = qualitySecondBg;
      text = qualitySecondText;
      border = qualitySecondBorder;
    } else if (lower.contains('tercera')) {
      bg = qualityThirdBg;
      text = qualityThirdText;
      border = qualityThirdBorder;
    } else if (lower.contains('primera') || lower.contains('orgánico')) {
      bg = qualityFirstBg;
      text = qualityFirstText;
      border = qualityFirstBorder;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: border, width: 0.8),
      ),
      child: Text(
        badge,
        style: TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: text,
        ),
      ),
    );
  }

  Widget _buildModeTag({
    required String label,
    required IconData icon,
    required Color bgColor,
    required Color textColor,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: borderColor, width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: textColor),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String url) {
    if (url.isEmpty) {
      return const Icon(Icons.eco, color: primaryColor, size: 36);
    }
    if (url.startsWith('http')) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (ctx, err, stack) =>
            const Icon(Icons.eco, color: primaryColor, size: 36),
      );
    }
    return Image.asset(
      url,
      fit: BoxFit.cover,
      errorBuilder: (ctx, err, stack) =>
          const Icon(Icons.eco, color: primaryColor, size: 36),
    );
  }
}
