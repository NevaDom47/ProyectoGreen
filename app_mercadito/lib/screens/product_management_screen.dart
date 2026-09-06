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
  String _selectedQuality = 'Todas'; // 'Todas', 'Primera Calidad', 'Segunda Calidad', 'Tercera Calidad'

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

  final List<String> _qualityFilters = [
    'Todas',
    'Primera Calidad',
    'Segunda Calidad',
    'Tercera Calidad',
  ];

  // Initial Product Catalog
  final List<Map<String, dynamic>> _products = [
    {
      'id': 'PROD-101',
      'sku': 'HOR-TOM-01',
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
      'unitConfigs': [
        {'unit': 'LB', 'saleType': 'detalle', 'priceRetail': 28.50, 'isDefault': true},
        {'unit': 'KG', 'saleType': 'detalle', 'priceRetail': 62.80, 'isDefault': false},
        {'unit': 'Caja', 'saleType': 'detalle', 'priceRetail': 250.00, 'isDefault': false},
        {'unit': 'LB', 'saleType': 'mayor', 'priceWholesale': 22.00, 'wholesaleMin': '10 LB', 'isDefault': true},
        {'unit': 'Caja', 'saleType': 'mayor', 'priceWholesale': 190.00, 'wholesaleMin': '5 Cajas', 'isDefault': false},
      ],
      'img':
          'https://lh3.googleusercontent.com/aida/AEtjO1WJPFi5I7ZN-mHEOmgqdgmYQxGUivEKgUceqV8OcdNcWwowkcPmSiJrAgNG82XtSgoX-uePPMYN8BGd4CqtyuTb_DWJcL1N9EY-Zb9pw67Sxhks3OGyC9hadvAaJOIk0gudu0Hrum9DHf9E_MsgiO4Vq3RUl5yWwKlvGxQyVEZbHKV44heVYLB-SuP2c9B2EN7Wg5gaYaoj991-EEiBhW8g_oE8djsBWnAcvDzTbTF6XMHOPxANhCnCOzg',
    },
    {
      'id': 'PROD-102',
      'sku': 'CIT-LIM-08',
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
      'unitConfigs': [
        {'unit': 'LB', 'saleType': 'detalle', 'priceRetail': 35.00, 'isDefault': true},
        {'unit': 'Docena', 'saleType': 'detalle', 'priceRetail': 25.00, 'isDefault': false},
        {'unit': 'LB', 'saleType': 'mayor', 'priceWholesale': 28.00, 'wholesaleMin': '15 LB', 'isDefault': true},
        {'unit': 'Caja', 'saleType': 'mayor', 'priceWholesale': 220.00, 'wholesaleMin': '4 Cajas', 'isDefault': false},
      ],
      'img':
          'https://lh3.googleusercontent.com/aida/AEtjO1UDV4xCp1jhcb-egx-ZZs69cRSVWsKFPJbDs5xkG824bImlFddNkfuvUFIAC88rGP-Jp55kQWHiB6FW4SZ-rGaW3DRUqEb_HGtLYuz_FY2tPb8WIlbkWcpwzJ63EaoWFM7aHlX7Yo4NHJwGoOhgT8c5mYeCEQrxmB6-1sLYMwOHSJ45nrpaVqu_awDl5Mff3RLV2UrekFhLE5QIrW-yBLh86eqpu71Aolq3nXys9zWAHQ6cGCpwX9EecgI',
    },
    {
      'id': 'PROD-103',
      'sku': 'FRU-AGU-12',
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
      'unitConfigs': [
        {'unit': 'KG', 'saleType': 'mayor', 'priceWholesale': 38.00, 'wholesaleMin': '10 KG', 'isDefault': true},
        {'unit': 'Caja', 'saleType': 'mayor', 'priceWholesale': 320.00, 'wholesaleMin': '3 Cajas', 'isDefault': false},
      ],
      'img':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCx_eRxHSK6aT1dCBg3UZ21drqrz2a64dmGPr8oTG0AwxQg0tDHVh4AtgkqDL9nFU3WpSX7wpX-mqCzxe8EVd07TtoyRnGyMKSGzfqVdkh_j7V_WDyzIsqHtCn4ZTDR6b7aC1H3c0x9tVl_JkgdHXVc331TsEehHQuMybFAM2rM-_9QQlVy3Su13zKGeSWfPfrF5gFM-iyyAGPQc-_F_W34y3Acj64mtVxWzV11ufTeMWIzML5WRRVceAYqKkB1F4P_yYDKiV2M4QA',
    },
    {
      'id': 'PROD-104',
      'sku': 'TUB-PAP-14',
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
      'unitConfigs': [
        {'unit': 'KG', 'saleType': 'detalle', 'priceRetail': 18.00, 'isDefault': true},
        {'unit': 'LB', 'saleType': 'detalle', 'priceRetail': 8.50, 'isDefault': false},
        {'unit': 'Saco', 'saleType': 'detalle', 'priceRetail': 320.00, 'isDefault': false},
      ],
      'img': 'assets/images/PapaGemini.png',
    },
    {
      'id': 'PROD-105',
      'sku': 'RAI-ZAN-03',
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
      'unitConfigs': [
        {'unit': 'KG', 'saleType': 'detalle', 'priceRetail': 12.50, 'isDefault': true},
        {'unit': 'LB', 'saleType': 'detalle', 'priceRetail': 6.00, 'isDefault': false},
        {'unit': 'KG', 'saleType': 'mayor', 'priceWholesale': 9.80, 'wholesaleMin': '15 KG', 'isDefault': true},
        {'unit': 'Saco', 'saleType': 'mayor', 'priceWholesale': 140.00, 'wholesaleMin': '3 Sacos', 'isDefault': false},
      ],
      'img': 'assets/images/ZanahoriaGemini.png',
    },
    {
      'id': 'PROD-106',
      'sku': 'FRU-FRE-09',
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
      'unitConfigs': [
        {'unit': 'KG', 'saleType': 'detalle', 'priceRetail': 45.00, 'isDefault': true},
        {'unit': 'LB', 'saleType': 'detalle', 'priceRetail': 22.00, 'isDefault': false},
        {'unit': 'Caja', 'saleType': 'detalle', 'priceRetail': 160.00, 'isDefault': false},
      ],
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
            return SafeArea(
              child: SingleChildScrollView(
                child: Padding(
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
                                _selectedQuality = 'Todas';
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
                          IconData typeIcon;
                          if (type == 'Al por mayor') {
                            typeIcon = Icons.inventory_2_outlined;
                          } else if (type == 'Al detalle') {
                            typeIcon = Icons.shopping_basket_outlined;
                          } else {
                            typeIcon = Icons.apps;
                          }

                          return GestureDetector(
                            onTap: () {
                              setSheetState(() => _selectedSaleType = type);
                              setState(() {});
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                                  Icon(
                                    typeIcon,
                                    size: 15,
                                    color: isSel ? chipSelectedText : chipUnselectedText,
                                  ),
                                  const SizedBox(width: 6),
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

                      // Section 2: Disponibilidad
                      const Text(
                        'Disponibilidad',
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
                        children: _availabilityFilters.map((avail) {
                          final isSel = _selectedAvailability == avail;
                          IconData availIcon;
                          Color unselIconColor = chipUnselectedText;
                          if (avail == 'Disponibles') {
                            availIcon = Icons.check_circle_outline;
                            unselIconColor = const Color(0xFF059669);
                          } else if (avail == 'Agotados') {
                            availIcon = Icons.block;
                            unselIconColor = const Color(0xFFE53935);
                          } else {
                            availIcon = Icons.apps;
                          }

                          return GestureDetector(
                            onTap: () {
                              setSheetState(() => _selectedAvailability = avail);
                              setState(() {});
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                                  Icon(
                                    availIcon,
                                    size: 15,
                                    color: isSel ? chipSelectedText : unselIconColor,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    avail,
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

                      // Section 3: Calidad
                      const Text(
                        'Calidad',
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
                        children: _qualityFilters.map((quality) {
                          final isSel = _selectedQuality == quality;
                          IconData qualIcon;
                          Color unselColor = chipUnselectedText;
                          if (quality.toLowerCase().contains('primera')) {
                            qualIcon = Icons.workspace_premium;
                            unselColor = const Color(0xFF016042);
                          } else if (quality.toLowerCase().contains('segunda')) {
                            qualIcon = Icons.workspace_premium_outlined;
                            unselColor = const Color(0xFFFF9A04);
                          } else if (quality.toLowerCase().contains('tercera')) {
                            qualIcon = Icons.eco_outlined;
                            unselColor = const Color(0xFFF44336);
                          } else {
                            qualIcon = Icons.apps;
                          }

                          return GestureDetector(
                            onTap: () {
                              setSheetState(() => _selectedQuality = quality);
                              setState(() {});
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                                  Icon(
                                    qualIcon,
                                    size: 15,
                                    color: isSel ? chipSelectedText : unselColor,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    quality,
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
                ),
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
    final saleType = (product['saleType'] ?? 'ambos').toString().toLowerCase();
    final bool hasRetail = saleType != 'mayor';
    final bool hasWholesale = saleType != 'detalle';

    final String defaultPrimaryUnit = (product['unit'] ?? 'LB').toString();
    final double defaultRetailPrice = (product['priceNum'] ?? 0.0).toDouble();
    final double defaultWholesalePrice = (product['wholesalePriceNum'] ?? 0.0).toDouble();
    final String defaultWholesaleMin = (product['wholesaleMin'] ?? '10 $defaultPrimaryUnit').toString();

    // Parse configured units from product['unitConfigs']
    final List rawConfigs = (product['unitConfigs'] is List) ? (product['unitConfigs'] as List) : [];
    final List<Map<String, dynamic>> retailConfigs = [];
    final List<Map<String, dynamic>> wholesaleConfigs = [];

    for (final c in rawConfigs) {
      if (c is Map) {
        final map = Map<String, dynamic>.from(c);
        final t = (map['saleType'] ?? 'detalle').toString().toLowerCase();
        if (t == 'detalle' || t == 'ambos') {
          retailConfigs.add(map);
        }
        if (t == 'mayor' || t == 'ambos') {
          wholesaleConfigs.add(map);
        }
      }
    }

    if (retailConfigs.isEmpty && hasRetail) {
      retailConfigs.add({
        'unit': defaultPrimaryUnit,
        'priceRetail': defaultRetailPrice,
        'isDefault': true,
      });
    }

    if (wholesaleConfigs.isEmpty && hasWholesale) {
      wholesaleConfigs.add({
        'unit': defaultPrimaryUnit,
        'priceWholesale': defaultWholesalePrice,
        'wholesaleMin': defaultWholesaleMin,
        'isDefault': true,
      });
    }

    // Determine fixed default unit for retail (set in full edit; preserved here)
    final Map<String, dynamic> defaultRetailEntry = retailConfigs.firstWhere(
      (c) => c['isDefault'] == true,
      orElse: () => retailConfigs.firstWhere(
        (c) => c['unit'] == defaultPrimaryUnit,
        orElse: () => retailConfigs.first,
      ),
    );
    final String defaultRetailUnit = defaultRetailEntry['unit']?.toString() ?? defaultPrimaryUnit;

    // Determine fixed default unit for wholesale (set in full edit; preserved here)
    final Map<String, dynamic> defaultWholesaleEntry = wholesaleConfigs.firstWhere(
      (c) => c['isDefault'] == true,
      orElse: () => wholesaleConfigs.firstWhere(
        (c) => c['unit'] == defaultPrimaryUnit,
        orElse: () => wholesaleConfigs.first,
      ),
    );
    final String defaultWholesaleUnit = defaultWholesaleEntry['unit']?.toString() ?? defaultPrimaryUnit;

    final List<String> availableRetailUnits = retailConfigs.map((c) => c['unit'].toString()).toSet().toList();
    final List<String> availableWholesaleUnits = wholesaleConfigs.map((c) => c['unit'].toString()).toSet().toList();

    // Start with the default unit in view for editing
    String selectedRetailUnit = availableRetailUnits.contains(defaultRetailUnit)
        ? defaultRetailUnit
        : (availableRetailUnits.isNotEmpty ? availableRetailUnits.first : defaultPrimaryUnit);
    String selectedWholesaleUnit = availableWholesaleUnits.contains(defaultWholesaleUnit)
        ? defaultWholesaleUnit
        : (availableWholesaleUnits.isNotEmpty ? availableWholesaleUnits.first : defaultPrimaryUnit);

    final Map<String, double> retailPrices = {};
    for (final c in retailConfigs) {
      final u = c['unit'].toString();
      final p = (c['priceRetail'] != null)
          ? (c['priceRetail'] as num).toDouble()
          : (c['priceNum'] != null ? (c['priceNum'] as num).toDouble() : defaultRetailPrice);
      retailPrices[u] = p;
    }
    if (!retailPrices.containsKey(selectedRetailUnit)) {
      retailPrices[selectedRetailUnit] = defaultRetailPrice;
    }

    final Map<String, double> wholesalePrices = {};
    final Map<String, String> wholesaleMins = {};
    for (final c in wholesaleConfigs) {
      final u = c['unit'].toString();
      final p = (c['priceWholesale'] != null)
          ? (c['priceWholesale'] as num).toDouble()
          : (c['wholesalePriceNum'] != null ? (c['wholesalePriceNum'] as num).toDouble() : defaultWholesalePrice);
      wholesalePrices[u] = p;
      final m = c['wholesaleMin']?.toString() ?? '10 $u';
      wholesaleMins[u] = m.contains(u) ? m : '$m $u';
    }
    if (!wholesalePrices.containsKey(selectedWholesaleUnit)) {
      wholesalePrices[selectedWholesaleUnit] = defaultWholesalePrice;
      wholesaleMins[selectedWholesaleUnit] = defaultWholesaleMin;
    }

    final priceCtrl = TextEditingController(
      text: (retailPrices[selectedRetailUnit] ?? defaultRetailPrice).toStringAsFixed(2),
    );
    final wholesaleCtrl = TextEditingController(
      text: (wholesalePrices[selectedWholesaleUnit] ?? defaultWholesalePrice).toStringAsFixed(2),
    );

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => StatefulBuilder(
        builder: (modalCtx, setDialogState) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final dialogBg = isDark ? const Color(0xFF16211C) : surfaceColor;
          final cardBg = isDark ? const Color(0xFF1E2D27) : surfaceLow;
          final int currentStock = product['stock'] ?? 0;

          // Status determination
          Color statusBg;
          Color statusText;
          String statusLabel;
          if (currentStock == 0) {
            statusBg = const Color(0xFFFFEBEE);
            statusText = const Color(0xFFEF5350);
            statusLabel = 'Agotado';
          } else if (currentStock <= 15) {
            statusBg = const Color(0xFFFFF4E5);
            statusText = const Color(0xFFFF9A04);
            statusLabel = 'Bajo Stock';
          } else {
            statusBg = const Color(0xFFDCE9E5);
            statusText = const Color(0xFF016042);
            statusLabel = 'Disponible';
          }

          return Dialog(
            backgroundColor: dialogBg,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: Icon, Title and Close Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(7),
                                decoration: BoxDecoration(
                                  color: primaryColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.tune_rounded, color: primaryColor, size: 20),
                              ),
                              const SizedBox(width: 10),
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Edición Rápida',
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: primaryColor,
                                    ),
                                  ),
                                  Text(
                                    'Ajuste inmediato de precios por unidad',
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 10.5,
                                      color: onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: onSurfaceVariant, size: 20),
                            onPressed: () => Navigator.of(ctx).pop(),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Selected Product Preview Banner
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: outlineColor),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: SizedBox(
                                width: 50,
                                height: 50,
                                child: _buildImage(product['img'] ?? ''),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product['name'] ?? 'Producto',
                                    style: const TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: onSurface,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 1),
                                  Text(
                                    'SKU: ${product['sku'] ?? product['id'] ?? ''}',
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w500,
                                      color: isDark ? Colors.grey.shade400 : const Color(0xFF94A3B8),
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Wrap(
                                    spacing: 4,
                                    runSpacing: 4,
                                    children: [
                                      if (product['category'] != null)
                                        _buildCategoryBadge(product['category']),
                                      if (product['badge'] != null)
                                        _buildQualityBadge(product['badge']),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: statusBg,
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                        child: Text(
                                          statusLabel,
                                          style: TextStyle(
                                            fontFamily: 'Plus Jakarta Sans',
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.bold,
                                            color: statusText,
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
                      const SizedBox(height: 16),

                      // ==========================================
                      // 1. SECCIÓN DE PRECIOS Y FORMAS DE VENTA
                      // ==========================================
                      const Row(
                        children: [
                          Icon(Icons.sell_outlined, size: 14, color: primaryColor),
                          SizedBox(width: 6),
                          Text(
                            'PRECIOS Y FORMAS DE VENTA',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: primaryColor,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Bloque Precio al Detalle
                      if (hasRetail) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: badgeRetailBg.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: badgeRetailBg.withValues(alpha: 0.25), width: 1.2),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(Icons.shopping_bag_outlined, size: 16, color: badgeRetailBg),
                                      SizedBox(width: 6),
                                      Text(
                                        'Precio al Detalle',
                                        style: TextStyle(
                                          fontFamily: 'Plus Jakarta Sans',
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.bold,
                                          color: badgeRetailBg,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: badgeRetailBg,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      '🛍️ Detalle',
                                      style: TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: priceCtrl,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                onChanged: (txt) {
                                  retailPrices[selectedRetailUnit] = double.tryParse(txt) ?? 0.0;
                                  setDialogState(() {});
                                },
                                style: const TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                  color: badgeRetailBg,
                                ),
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.attach_money, color: badgeRetailBg, size: 18),
                                  suffixIcon: PopupMenuButton<String>(
                                    tooltip: 'Seleccionar unidad para editar precio',
                                    offset: const Offset(0, 42),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    color: dialogBg,
                                    elevation: 4,
                                    initialValue: selectedRetailUnit,
                                    onSelected: (newUnit) {
                                      final currentVal = double.tryParse(priceCtrl.text) ?? retailPrices[selectedRetailUnit] ?? defaultRetailPrice;
                                      retailPrices[selectedRetailUnit] = currentVal;
                                      selectedRetailUnit = newUnit;
                                      priceCtrl.text = (retailPrices[newUnit] ?? currentVal).toStringAsFixed(2);
                                      setDialogState(() {});
                                    },
                                    itemBuilder: (context) {
                                      return availableRetailUnits.map((u) {
                                        final isEditing = u == selectedRetailUnit;
                                        final isDef = u == defaultRetailUnit;
                                        final p = retailPrices[u] ?? 0.0;
                                        return PopupMenuItem<String>(
                                          value: u,
                                          height: 38,
                                          child: Row(
                                            children: [
                                              Icon(
                                                isEditing ? Icons.edit_note_rounded : Icons.radio_button_off,
                                                size: 16,
                                                color: isEditing ? badgeRetailBg : onSurfaceVariant.withValues(alpha: 0.5),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                u,
                                                style: TextStyle(
                                                  fontFamily: 'Plus Jakarta Sans',
                                                  fontWeight: isEditing ? FontWeight.w800 : FontWeight.w600,
                                                  fontSize: 13,
                                                  color: isEditing ? badgeRetailBg : onSurface,
                                                ),
                                              ),
                                              if (isDef) ...[
                                                const SizedBox(width: 6),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                                  decoration: BoxDecoration(
                                                    color: badgeRetailBg.withValues(alpha: 0.1),
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: const Text(
                                                    'Principal',
                                                    style: TextStyle(
                                                      fontFamily: 'Plus Jakarta Sans',
                                                      fontSize: 8.5,
                                                      fontWeight: FontWeight.bold,
                                                      color: badgeRetailBg,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                              const Spacer(),
                                              Text(
                                                '\$${p.toStringAsFixed(2)}',
                                                style: const TextStyle(
                                                  fontFamily: 'Plus Jakarta Sans',
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 11,
                                                  color: onSurfaceVariant,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList();
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: badgeRetailBg.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: badgeRetailBg.withValues(alpha: 0.3)),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            '/ $selectedRetailUnit',
                                            style: const TextStyle(
                                              fontFamily: 'Plus Jakarta Sans',
                                              fontWeight: FontWeight.w800,
                                              fontSize: 12.5,
                                              color: badgeRetailBg,
                                            ),
                                          ),
                                          const SizedBox(width: 2),
                                          const Icon(Icons.arrow_drop_down_rounded, color: badgeRetailBg, size: 20),
                                        ],
                                      ),
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: surfaceColor,
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: badgeRetailBg.withValues(alpha: 0.3)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: badgeRetailBg.withValues(alpha: 0.3)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(color: badgeRetailBg, width: 1.6),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Quick Delta Chips Detalle
                              Wrap(
                                spacing: 6,
                                children: [
                                  _buildDeltaChip('-\$1.00', () {
                                    final val = (double.tryParse(priceCtrl.text) ?? 0.0) - 1.0;
                                    priceCtrl.text = (val > 0 ? val : 0.0).toStringAsFixed(2);
                                    retailPrices[selectedRetailUnit] = double.tryParse(priceCtrl.text) ?? 0.0;
                                    setDialogState(() {});
                                  }, isNegative: true),
                                  _buildDeltaChip('+\$0.50', () {
                                    final val = (double.tryParse(priceCtrl.text) ?? 0.0) + 0.50;
                                    priceCtrl.text = val.toStringAsFixed(2);
                                    retailPrices[selectedRetailUnit] = val;
                                    setDialogState(() {});
                                  }),
                                  _buildDeltaChip('+\$1.00', () {
                                    final val = (double.tryParse(priceCtrl.text) ?? 0.0) + 1.0;
                                    priceCtrl.text = val.toStringAsFixed(2);
                                    retailPrices[selectedRetailUnit] = val;
                                    setDialogState(() {});
                                  }),
                                  _buildDeltaChip('+\$5.00', () {
                                    final val = (double.tryParse(priceCtrl.text) ?? 0.0) + 5.0;
                                    priceCtrl.text = val.toStringAsFixed(2);
                                    retailPrices[selectedRetailUnit] = val;
                                    setDialogState(() {});
                                  }),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],

                      // Bloque Precio al Por Mayor
                      if (hasWholesale) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: badgeWholesaleBg.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: badgeWholesaleBg.withValues(alpha: 0.25), width: 1.2),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.inventory_2_outlined, size: 16, color: badgeWholesaleBg),
                                      const SizedBox(width: 6),
                                      const Text(
                                        'Precio al Por Mayor',
                                        style: TextStyle(
                                          fontFamily: 'Plus Jakarta Sans',
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.bold,
                                          color: badgeWholesaleBg,
                                        ),
                                      ),
                                      if ((wholesaleMins[selectedWholesaleUnit] ?? '').isNotEmpty) ...[
                                        const SizedBox(width: 6),
                                        Text(
                                          '(${wholesaleMins[selectedWholesaleUnit]})',
                                          style: const TextStyle(
                                            fontFamily: 'Plus Jakarta Sans',
                                            fontSize: 10,
                                            color: onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: badgeWholesaleBg,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      '📦 Por Mayor',
                                      style: TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: wholesaleCtrl,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                onChanged: (txt) {
                                  wholesalePrices[selectedWholesaleUnit] = double.tryParse(txt) ?? 0.0;
                                  setDialogState(() {});
                                },
                                style: const TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                  color: badgeWholesaleBg,
                                ),
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.attach_money, color: badgeWholesaleBg, size: 18),
                                  suffixIcon: PopupMenuButton<String>(
                                    tooltip: 'Seleccionar unidad para editar precio',
                                    offset: const Offset(0, 42),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    color: dialogBg,
                                    elevation: 4,
                                    initialValue: selectedWholesaleUnit,
                                    onSelected: (newUnit) {
                                      final currentVal = double.tryParse(wholesaleCtrl.text) ?? wholesalePrices[selectedWholesaleUnit] ?? defaultWholesalePrice;
                                      wholesalePrices[selectedWholesaleUnit] = currentVal;
                                      selectedWholesaleUnit = newUnit;
                                      wholesaleCtrl.text = (wholesalePrices[newUnit] ?? currentVal).toStringAsFixed(2);
                                      setDialogState(() {});
                                    },
                                    itemBuilder: (context) {
                                      return availableWholesaleUnits.map((u) {
                                        final isEditing = u == selectedWholesaleUnit;
                                        final isDef = u == defaultWholesaleUnit;
                                        final p = wholesalePrices[u] ?? 0.0;
                                        final minVol = wholesaleMins[u] ?? '';
                                        return PopupMenuItem<String>(
                                          value: u,
                                          height: 38,
                                          child: Row(
                                            children: [
                                              Icon(
                                                isEditing ? Icons.edit_note_rounded : Icons.radio_button_off,
                                                size: 16,
                                                color: isEditing ? badgeWholesaleBg : onSurfaceVariant.withValues(alpha: 0.5),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                u,
                                                style: TextStyle(
                                                  fontFamily: 'Plus Jakarta Sans',
                                                  fontWeight: isEditing ? FontWeight.w800 : FontWeight.w600,
                                                  fontSize: 13,
                                                  color: isEditing ? badgeWholesaleBg : onSurface,
                                                ),
                                              ),
                                              if (isDef) ...[
                                                const SizedBox(width: 6),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                                  decoration: BoxDecoration(
                                                    color: badgeWholesaleBg.withValues(alpha: 0.1),
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: const Text(
                                                    'Principal',
                                                    style: TextStyle(
                                                      fontFamily: 'Plus Jakarta Sans',
                                                      fontSize: 8.5,
                                                      fontWeight: FontWeight.bold,
                                                      color: badgeWholesaleBg,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                              if (minVol.isNotEmpty) ...[
                                                const SizedBox(width: 6),
                                                Text(
                                                  '($minVol)',
                                                  style: const TextStyle(
                                                    fontFamily: 'Plus Jakarta Sans',
                                                    fontSize: 10,
                                                    color: onSurfaceVariant,
                                                  ),
                                                ),
                                              ],
                                              const Spacer(),
                                              Text(
                                                '\$${p.toStringAsFixed(2)}',
                                                style: const TextStyle(
                                                  fontFamily: 'Plus Jakarta Sans',
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 11,
                                                  color: onSurfaceVariant,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList();
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: badgeWholesaleBg.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: badgeWholesaleBg.withValues(alpha: 0.3)),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            '/ $selectedWholesaleUnit',
                                            style: const TextStyle(
                                              fontFamily: 'Plus Jakarta Sans',
                                              fontWeight: FontWeight.w800,
                                              fontSize: 12.5,
                                              color: badgeWholesaleBg,
                                            ),
                                          ),
                                          const SizedBox(width: 2),
                                          const Icon(Icons.arrow_drop_down_rounded, color: badgeWholesaleBg, size: 20),
                                        ],
                                      ),
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: surfaceColor,
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: badgeWholesaleBg.withValues(alpha: 0.3)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: badgeWholesaleBg.withValues(alpha: 0.3)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(color: badgeWholesaleBg, width: 1.6),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Quick Delta Chips Mayor (+0.50 added as requested)
                              Wrap(
                                spacing: 6,
                                children: [
                                  _buildDeltaChip('-\$1.00', () {
                                    final val = (double.tryParse(wholesaleCtrl.text) ?? 0.0) - 1.0;
                                    wholesaleCtrl.text = (val > 0 ? val : 0.0).toStringAsFixed(2);
                                    wholesalePrices[selectedWholesaleUnit] = double.tryParse(wholesaleCtrl.text) ?? 0.0;
                                    setDialogState(() {});
                                  }, isNegative: true),
                                  _buildDeltaChip('+\$0.50', () {
                                    final val = (double.tryParse(wholesaleCtrl.text) ?? 0.0) + 0.50;
                                    wholesaleCtrl.text = val.toStringAsFixed(2);
                                    wholesalePrices[selectedWholesaleUnit] = val;
                                    setDialogState(() {});
                                  }),
                                  _buildDeltaChip('+\$1.00', () {
                                    final val = (double.tryParse(wholesaleCtrl.text) ?? 0.0) + 1.0;
                                    wholesaleCtrl.text = val.toStringAsFixed(2);
                                    wholesalePrices[selectedWholesaleUnit] = val;
                                    setDialogState(() {});
                                  }),
                                  _buildDeltaChip('+\$2.00', () {
                                    final val = (double.tryParse(wholesaleCtrl.text) ?? 0.0) + 2.0;
                                    wholesaleCtrl.text = val.toStringAsFixed(2);
                                    wholesalePrices[selectedWholesaleUnit] = val;
                                    setDialogState(() {});
                                  }),
                                  _buildDeltaChip('+\$5.00', () {
                                    final val = (double.tryParse(wholesaleCtrl.text) ?? 0.0) + 5.0;
                                    wholesaleCtrl.text = val.toStringAsFixed(2);
                                    wholesalePrices[selectedWholesaleUnit] = val;
                                    setDialogState(() {});
                                  }),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],

                      const SizedBox(height: 6),

                      // ==========================================
                      // 2. SECCIÓN DE INVENTARIO (EN DESARROLLO)
                      // ==========================================
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.layers_outlined, size: 14, color: onSurfaceVariant),
                              SizedBox(width: 6),
                              Text(
                                'CONTROL DE INVENTARIO',
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  color: onSurfaceVariant,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF4E5),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFFFF9A04)),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.construction_rounded, size: 12, color: Color(0xFFC05621)),
                                SizedBox(width: 4),
                                Text(
                                  'EN DESARROLLO',
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFFC05621),
                                    letterSpacing: 0.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      Stack(
                        children: [
                          Opacity(
                            opacity: 0.42,
                            child: AbsorbPointer(
                              absorbing: true,
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: cardBg,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: outlineColor),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            color: surfaceColor,
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(color: outlineColor),
                                          ),
                                          child: const Icon(Icons.remove, color: onSurfaceVariant, size: 20),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Container(
                                            height: 44,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: surfaceColor,
                                              borderRadius: BorderRadius.circular(10),
                                              border: Border.all(color: outlineColor),
                                            ),
                                            child: Text(
                                              '${product['stock'] ?? 0} $defaultPrimaryUnit',
                                              style: const TextStyle(
                                                fontFamily: 'Plus Jakarta Sans',
                                                fontSize: 18,
                                                fontWeight: FontWeight.w800,
                                                color: onSurfaceVariant,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            color: onSurfaceVariant.withValues(alpha: 0.2),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: const Icon(Icons.add, color: onSurfaceVariant, size: 20),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        _buildStockPresetChip('+5', () {}),
                                        _buildStockPresetChip('+10', () {}),
                                        _buildStockPresetChip('+25', () {}),
                                        _buildStockPresetChip('+50', () {}),
                                        _buildStockPresetChip('Agotado', () {}),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                decoration: BoxDecoration(
                                  color: dialogBg.withValues(alpha: 0.95),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: const Color(0xFFFF9A04).withValues(alpha: 0.6)),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x18000000),
                                      blurRadius: 8,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.lock_outline_rounded, size: 14, color: Color(0xFFC05621)),
                                    SizedBox(width: 6),
                                    Text(
                                      'Función de inventario en desarrollo',
                                      style: TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFFC05621),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // ==========================================
                      // 3. ACTION BUTTONS
                      // ==========================================
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: SizedBox(
                              height: 46,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: onSurfaceVariant,
                                  side: const BorderSide(color: outlineColor),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                onPressed: () => Navigator.of(ctx).pop(),
                                child: const Text(
                                  'CANCELAR',
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 3,
                            child: SizedBox(
                              height: 46,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  foregroundColor: Colors.white,
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                onPressed: () {
                                  // Sync current text field values
                                  if (hasRetail) {
                                    final finalRet = double.tryParse(priceCtrl.text) ?? retailPrices[selectedRetailUnit] ?? 0.0;
                                    retailPrices[selectedRetailUnit] = finalRet;
                                  }
                                  if (hasWholesale) {
                                    final finalWhl = double.tryParse(wholesaleCtrl.text) ?? wholesalePrices[selectedWholesaleUnit] ?? 0.0;
                                    wholesalePrices[selectedWholesaleUnit] = finalWhl;
                                  }

                                  setState(() {
                                    // 1. Update unitConfigs inside product ONLY with new prices (DO NOT alter isDefault)
                                    if (product['unitConfigs'] is List) {
                                      final List configs = product['unitConfigs'] as List;
                                      for (int i = 0; i < configs.length; i++) {
                                        final c = configs[i];
                                        if (c is Map) {
                                          final u = c['unit']?.toString();
                                          final type = (c['saleType'] ?? 'detalle').toString().toLowerCase();
                                          if ((type == 'detalle' || type == 'ambos') && retailPrices.containsKey(u)) {
                                            c['priceRetail'] = retailPrices[u];
                                            c['priceRetailStr'] = '\$${retailPrices[u]!.toStringAsFixed(2)}';
                                            // isDefault remains untouched!
                                          }
                                          if ((type == 'mayor' || type == 'ambos') && wholesalePrices.containsKey(u)) {
                                            c['priceWholesale'] = wholesalePrices[u];
                                            c['priceWholesaleStr'] = '\$${wholesalePrices[u]!.toStringAsFixed(2)}';
                                            // isDefault remains untouched!
                                          }
                                        }
                                      }
                                    }

                                    // 2. Update main display price according to the DEFAULT unit
                                    if (hasRetail) {
                                      final defaultRetVal = retailPrices[defaultRetailUnit] ?? product['priceNum'] ?? 0.0;
                                      product['priceNum'] = defaultRetVal;
                                      product['price'] = '\$${defaultRetVal.toStringAsFixed(2)}';
                                      product['unit'] = defaultRetailUnit;
                                    }
                                    if (hasWholesale) {
                                      final defaultWhlVal = wholesalePrices[defaultWholesaleUnit] ?? product['wholesalePriceNum'] ?? 0.0;
                                      product['wholesalePriceNum'] = defaultWhlVal;
                                      product['wholesalePrice'] = '\$${defaultWhlVal.toStringAsFixed(2)}';
                                      if (!hasRetail) {
                                        product['unit'] = defaultWholesaleUnit;
                                      }
                                      if (wholesaleMins.containsKey(defaultWholesaleUnit)) {
                                        product['wholesaleMin'] = wholesaleMins[defaultWholesaleUnit];
                                      }
                                    }
                                  });

                                  Navigator.of(ctx).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              '✓ Precios de ${product['name']} actualizados con éxito',
                                              style: const TextStyle(
                                                fontFamily: 'Plus Jakarta Sans',
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      backgroundColor: primaryColor,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      duration: const Duration(seconds: 3),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.check_rounded, size: 18),
                                label: const Text(
                                  'GUARDAR CAMBIOS',
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDeltaChip(String label, VoidCallback onTap, {bool isNegative = false}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: BoxDecoration(
            color: isNegative ? const Color(0xFFFFEBEE) : surfaceColor,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isNegative ? const Color(0xFFEF5350).withValues(alpha: 0.5) : outlineColor,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
              color: isNegative ? const Color(0xFFC62828) : primaryColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStockPresetChip(String label, VoidCallback onTap, {bool isDestructive = false}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3.5),
          decoration: BoxDecoration(
            color: isDestructive ? const Color(0xFFFFEBEE) : surfaceColor,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isDestructive ? const Color(0xFFEF5350) : outlineColor,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isDestructive ? const Color(0xFFC62828) : primaryColor,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF101915) : backgroundColor;
    final cardColor = isDark ? const Color(0xFF1A2420) : surfaceColor;

    final hasActiveFilter = _selectedSaleType != 'Todos' ||
        _selectedAvailability != 'Todos' ||
        _selectedQuality != 'Todas' ||
        _selectedCategory != 'Todos';

    // Filter products
    final filtered = _products.where((p) {
      final name = (p['name'] ?? '').toString().toLowerCase();
      final cat = (p['category'] ?? '').toString().toLowerCase();
      final status = (p['status'] ?? 'Disponible').toString();
      final isAgotado = status.toLowerCase() == 'agotado';
      final badge = (p['badge'] ?? '').toString().toLowerCase();

      final sku = (p['sku'] ?? p['id'] ?? '').toString().toLowerCase();

      final matchesQuery = _searchQuery.isEmpty ||
          name.contains(_searchQuery) ||
          cat.contains(_searchQuery) ||
          sku.contains(_searchQuery);

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

      // Quality filter ('Todas', 'Primera Calidad', 'Segunda Calidad', 'Tercera Calidad')
      bool matchesQuality = true;
      if (_selectedQuality == 'Primera Calidad') {
        matchesQuality = badge.contains('primera') || badge.contains('orgánico');
      } else if (_selectedQuality == 'Segunda Calidad') {
        matchesQuality = badge.contains('segunda');
      } else if (_selectedQuality == 'Tercera Calidad') {
        matchesQuality = badge.contains('tercera');
      }

      return matchesQuery &&
          matchesCategory &&
          matchesAvailability &&
          matchesSaleType &&
          matchesQuality;
    }).toList();

    final totalCount = _products.length;
    final availableCount = _products
        .where((p) => (p['status'] ?? '').toString().toLowerCase() != 'agotado')
        .length;
    final outOfStockCount = _products
        .where((p) => (p['status'] ?? '').toString().toLowerCase() == 'agotado')
        .length;

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

                  // Inventory Summary Metric Cards (Registrados, Disponibles, Agotados)
                  Row(
                    children: [
                      Expanded(
                        child: _buildInventoryStatCard(
                          label: 'Registrados',
                          count: totalCount,
                          icon: Icons.inventory_2_outlined,
                          color: primaryColor,
                          bgColor: isDark ? const Color(0xFF1E2822) : const Color(0xFFF1F6F3),
                          borderColor: isDark ? const Color(0xFF2C3C34) : const Color(0xFFD3E2DA),
                          isSelected: _selectedAvailability == 'Todos',
                          onTap: () {
                            setState(() => _selectedAvailability = 'Todos');
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildInventoryStatCard(
                          label: 'Disponibles',
                          count: availableCount,
                          icon: Icons.check_circle_outline,
                          color: const Color(0xFF059669),
                          bgColor: isDark ? const Color(0xFF152A20) : const Color(0xFFEDFAF3),
                          borderColor: isDark ? const Color(0xFF1F4835) : const Color(0xFFA7F3D0),
                          isSelected: _selectedAvailability == 'Disponibles',
                          onTap: () {
                            setState(() {
                              _selectedAvailability =
                                  _selectedAvailability == 'Disponibles'
                                      ? 'Todos'
                                      : 'Disponibles';
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildInventoryStatCard(
                          label: 'Agotados',
                          count: outOfStockCount,
                          icon: Icons.block,
                          color: const Color(0xFFDC2626),
                          bgColor: isDark ? const Color(0xFF2B1D1D) : const Color(0xFFFEF2F2),
                          borderColor: isDark ? const Color(0xFF4C2A2A) : const Color(0xFFFECACA),
                          isSelected: _selectedAvailability == 'Agotados',
                          onTap: () {
                            setState(() {
                              _selectedAvailability =
                                  _selectedAvailability == 'Agotados'
                                      ? 'Todos'
                                      : 'Agotados';
                            });
                          },
                        ),
                      ),
                    ],
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
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
                                  const SizedBox(height: 2),
                                  Text(
                                    'SKU: ${product['sku'] ?? product['id'] ?? ''}',
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w500,
                                      color: isAgotado
                                          ? (isDark ? Colors.white24 : const Color(0xFF9E9E9E))
                                          : (isDark ? Colors.grey.shade400 : const Color(0xFF94A3B8)),
                                      letterSpacing: 0.2,
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

  Widget _buildInventoryStatCard({
    required String label,
    required int count,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required Color borderColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : borderColor,
              width: isSelected ? 1.8 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.18),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 15, color: color),
                  const SizedBox(width: 5),
                  Text(
                    '$count',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected ? color : onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
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
