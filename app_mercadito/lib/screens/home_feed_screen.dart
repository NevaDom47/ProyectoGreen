import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'my_reviews_screen.dart';
import '../widgets/location_selector_modal.dart';
import '../data/global_state.dart';
import '../widgets/animated_discount_badge.dart';
import '../widgets/animated_favorite_button.dart';
import '../widgets/product_reviews_modal.dart';
import '../widgets/quality_info_bottom_sheet.dart';
import '../widgets/supplier_quick_view_bottom_sheet.dart';
import '../widgets/skeleton_loading.dart';
import '../services/user_session.dart';

class HomeFeedScreen extends StatefulWidget {
  const HomeFeedScreen({super.key});

  @override
  State<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen> {
  String _currentLocation = 'Distrito Nacional, DO';
  bool _isLoading = true;
  final Map<String, String> _selectedProductModes = {};

  final List<Map<String, dynamic>> _groceryEssentials = [
    {
      'name': 'DOÑA GALLINA Caldo 6ud (131) (AP)',
      'price': 'RD\$48.00',
      'rawPrice': 48.0,
      'wholesalePrice': 'RD\$38.00',
      'wholesaleRawPrice': 38.0,
      'oldPrice': 'RD\$56.00',
      'unit': '6ud',
      'unitText': 'POR CAJA',
      'wholesaleUnitText': 'POR BULTO (24)',
      'available_units': ['6ud', '12ud', 'Caja'],
      'quality': 'Primera Calidad',
      'badge': 'PRIMERA CALIDAD',
      'rating': '4.8',
      'supplier': 'Hipermercados Olé',
      'location': 'Villa Mella, Santo Domingo',
      'category': 'Abarrotes',
      'tags': ['Condimentos', 'Oferta'],
      'salesMode': 'both',
      'img':
          'https://raw.githubusercontent.com/NevaDom47/imagenes/refs/heads/main/20250603_1549_Variedad%20de%20Aj%C3%ADes_simple_compose_01jwvncbmqfpvb7qv6rs3vh22x.png',
      'icon': Icons.soup_kitchen,
    },
    {
      'name': 'Chuleta Ahumada Especial Lb',
      'price': 'RD\$124.00',
      'rawPrice': 124.0,
      'wholesalePrice': 'RD\$105.00',
      'wholesaleRawPrice': 105.0,
      'oldPrice': 'RD\$145.00',
      'unit': 'lb',
      'unitText': 'POR LIBRA',
      'wholesaleUnitText': 'POR CAJA 50LB',
      'available_units': ['lb', 'kg'],
      'quality': 'Primera Calidad',
      'badge': 'PRIMERA CALIDAD',
      'rating': '4.9',
      'supplier': 'Hipermercados Olé',
      'location': 'Villa Mella, Santo Domingo',
      'category': 'Carnes',
      'tags': ['Carnes', 'Fresco'],
      'salesMode': 'both',
      'img':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBXcsVfAn4SXFQcHddnB5qMtM4renFwAuqO-lGdtcJtIIEmGl9tMDsFQiPgu60XnCWVebJO7iP0Ibk5dtJIqrh9Aanp9rZWGv7faUFsthP816CnkwG06d3lv6JAtK1L0AlnAz_e_RO8MTnW4_KInOanUlNL5k2AshcmFlzprpJxW1x81-1wvtFdgqmQ27XRJXCS6DLiTryvA9pgF60utXXNGEKTfgzyHZfbGio0iMIq4G_RBnQepN2i0vJ1-mywwHJNnmaXt1UMSH8',
      'icon': Icons.kebab_dining,
    },
    {
      'name': 'Papa Blanca Alpha Premium',
      'price': 'RD\$85.00',
      'rawPrice': 85.0,
      'wholesalePrice': 'RD\$65.00',
      'wholesaleRawPrice': 65.0,
      'oldPrice': 'RD\$95.00',
      'unit': 'kg',
      'unitText': 'POR KILO',
      'wholesaleUnitText': 'POR SACO 50KG',
      'available_units': ['kg', 'lb', 'saco'],
      'quality': 'Primera Calidad',
      'badge': 'PRIMERA CALIDAD',
      'rating': '4.8',
      'supplier': 'Hipermercados Olé',
      'location': 'Villa Mella, Santo Domingo',
      'category': 'Tubérculos',
      'tags': ['Tubérculos', 'Oferta'],
      'salesMode': 'both',
      'img':
          'https://raw.githubusercontent.com/NevaDom47/imagenes/refs/heads/main/20250603_1556_Sacos%20de%20Papas_simple_compose_01jwvnskaee6evykbzreq6j8wm.png',
      'icon': Icons.grass,
    },
    {
      'name': 'MARIA Tortillas de Trigo 10ud 9oz',
      'price': 'RD\$73.00',
      'rawPrice': 73.0,
      'wholesalePrice': 'RD\$58.00',
      'wholesaleRawPrice': 58.0,
      'oldPrice': 'RD\$88.00',
      'unit': '10ud',
      'unitText': 'POR PAQUETE',
      'wholesaleUnitText': 'POR CAJA (12)',
      'available_units': ['10ud', '20ud'],
      'quality': 'Primera Calidad',
      'badge': 'PRIMERA CALIDAD',
      'rating': '4.7',
      'supplier': 'Hipermercados Olé',
      'location': 'Villa Mella, Santo Domingo',
      'category': 'Panadería',
      'tags': ['Panadería', 'Oferta'],
      'salesMode': 'both',
      'img':
          'https://raw.githubusercontent.com/NevaDom47/imagenes/refs/heads/main/20250603_1515_Pl%C3%A1tano%20sobre%20Fondo%20Verde_simple_compose_01jwvkfvz0etrr0gg640b8nxwd.png',
      'icon': Icons.breakfast_dining,
    },
    {
      'name': 'Arroz Premium La Garza 5 Lb',
      'price': 'RD\$215.00',
      'rawPrice': 215.0,
      'wholesalePrice': 'RD\$185.00',
      'wholesaleRawPrice': 185.0,
      'oldPrice': 'RD\$240.00',
      'unit': '5 Lb',
      'unitText': 'POR FUNDA',
      'wholesaleUnitText': 'POR FARDO (10)',
      'available_units': ['5 Lb', '10 Lb', 'Saco 100 Lb'],
      'quality': 'Primera Calidad',
      'badge': 'PRIMERA CALIDAD',
      'rating': '4.9',
      'supplier': 'Hipermercados Olé',
      'location': 'Villa Mella, Santo Domingo',
      'category': 'Granos',
      'tags': ['Granos', 'Popular'],
      'salesMode': 'both',
      'img':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCN-hVTSx1rNbAD9eHpKDImU8vYJNZFoITfQVx73EZIsla3sFfOoX1WKcFfcivkoGD6cfKSKUvwKe2quKBgEgLxJFpQkv0inpNh-tvY1FVwe61aMojskS1J6eWlmYdoEFeaMUrxyGhzKBbn_rAkmvNeu9kgAeCVKeg4IZmh1p7gEOG8Ww0k6j5HLcgnH5larlnuSK9k2mF0Lw782V2ktGYYAR6k1m1pN-ffQWT0y4L2ZJRKh-QiDe1Wr-XvoTyrT8hhyTgO0PSlWBE',
      'icon': Icons.rice_bowl,
    },
    {
      'name': 'Aceite Vegetal Crisol 64 Oz',
      'price': 'RD\$189.00',
      'rawPrice': 189.0,
      'wholesalePrice': 'RD\$160.00',
      'wholesaleRawPrice': 160.0,
      'oldPrice': 'RD\$210.00',
      'unit': '64 Oz',
      'unitText': 'POR BOTELLA',
      'wholesaleUnitText': 'POR CAJA (8)',
      'available_units': ['64 Oz', '128 Oz'],
      'quality': 'Primera Calidad',
      'badge': 'PRIMERA CALIDAD',
      'rating': '4.8',
      'supplier': 'Hipermercados Olé',
      'location': 'Villa Mella, Santo Domingo',
      'category': 'Aceites',
      'tags': ['Aceites', 'Oferta'],
      'salesMode': 'both',
      'img':
          'https://raw.githubusercontent.com/NevaDom47/imagenes/refs/heads/main/20250603_1524_Tomate%20Fresco%20Expuesto_simple_compose_01jwvkz8qsfxdazzgv3zd2wnv0.png',
      'icon': Icons.opacity,
    },
  ];

  @override
  void initState() {
    super.initState();
    startGlobalFlashTimer();
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
    stopGlobalFlashTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Custom colors from the specific design if different
    final bgColor = isDark ? const Color(0xFF0f231d) : const Color(0xFFf5f8f7);
    final surfaceColor = isDark
        ? const Color(0xFF1f2937)
        : Colors.white; // approx slate-800
    final searchBgColor = isDark
        ? const Color(0xFF1f2937)
        : const Color(0xFFE5F1EB);

    return Scaffold(
      backgroundColor: bgColor,
      drawer: _buildDrawer(context, isDark, theme.colorScheme.primary),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, searchBgColor, isDark),
              const SizedBox(height: 12),
              _buildMarketTicker(surfaceColor, isDark),
              const SizedBox(height: 24),
              _buildAnalysisBanner(theme),
              const SizedBox(height: 32),
              _buildNearbySuppliers(theme, surfaceColor, isDark),
              const SizedBox(height: 32),
              _buildFlashOffers(theme, surfaceColor, isDark),
              const SizedBox(height: 32),
              _buildGroceryEssentials(theme, surfaceColor, isDark),
              const SizedBox(height: 32),
              _buildMostTraded(theme, surfaceColor, isDark),
              const SizedBox(height: 32),
              _buildForYou(theme, surfaceColor, isDark),
              const SizedBox(height: 100), // padding for custom bottom bar
            ],
          ),
        ),
      ),
      extendBody: true,
    );
  }

  Widget _buildHeader(BuildContext context, Color searchBgColor, bool isDark) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        children: [
          // Top Row: Menu, Logo, Notifications, Chat
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Builder(
                    builder: (BuildContext context) {
                      return IconButton(
                        icon: const Icon(Icons.menu),
                        onPressed: () {
                          Scaffold.of(context).openDrawer();
                        },
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Mercadito',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: searchBgColor,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.notifications_none,
                            color: theme.colorScheme.primary,
                          ),
                          onPressed: () => context.push('/notifications'),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 10, right: 10),
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: searchBgColor,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.person_outline,
                        color: theme.colorScheme.primary,
                      ),
                      onPressed: () => context.push('/profile'),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Location and Providers Button
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final selected = await showLocationSelector(context);
                    if (selected != null) {
                      setState(() {
                        _currentLocation = selected;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: searchBgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: isDark ? Colors.grey[400] : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _currentLocation,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? Colors.grey[300]
                                  : Colors.grey[700],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          size: 16,
                          color: isDark ? Colors.grey[400] : Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => context.push('/providers'),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.search, size: 16, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          'Proveedores',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: searchBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            child: Row(
              children: [
                Icon(Icons.search, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    readOnly: true,
                    onTap: () => context.push('/search'),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      hintText: 'Buscar productos agrícolas...',
                      fillColor: Colors.transparent,
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

  Widget _buildMarketTicker(Color surfaceColor, bool isDark) {
    return MarketTickerWidget(surfaceColor: surfaceColor, isDark: isDark);
  }

  Widget _buildAnalysisBanner(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Análisis de Mercado',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 200,
                  child: Text(
                    'Tendencias de cosecha y pronósticos de precios para el próximo trimestre.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.push('/market-analysis'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: theme.colorScheme.primary,
                    minimumSize: const Size(120, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: const Text(
                    'Ver Reporte',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
            Positioned(
              right: -20,
              bottom: -40,
              child: Icon(
                Icons.bar_chart,
                size: 140,
                color: Colors.white.withValues(alpha: 0.2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNearbySuppliers(
    ThemeData theme,
    Color surfaceColor,
    bool isDark,
  ) {
    final suppliers = [
      {
        'name': 'Ricardo M.',
        'url':
            'https://lh3.googleusercontent.com/aida-public/AB6AXuChaDfC6mw2tpKWw0YFxHzZt6BfxnJPY3d73IfpXMbl9HeSHm7SoOTDWMHsmHiy8C6RxdekQPP8qY-BaYExTICwM4C19rXv_etCTMNRHRQu_tkShzpmO033_1phP9kv9Tq7bg9Sn53b0UG2Iiok0-igbaDGD2aa_IIflUh9uioG-Ip92UnR740j5lNNwTZufCgxfo7POjzOwy2AL-uUMrY9JDML2P4B9WRyksILjFK9yJYUprkJ6TxT-qwnhYz9Y6x-H2d3Xf-0QGU',
        'verified': true,
      },
      {
        'name': 'Elena G.',
        'url':
            'https://lh3.googleusercontent.com/aida-public/AB6AXuDA08Phs1_RYQ5rPknb8I5SM_TqS1ncSGl0M9Rh2HPkK7_kq8GLAD8pN4Hnm1uW9nD4ufN5qB-Gar75NM6f9hHlnBin-CeQQvUG4gNBbVzb5Cq0tg-3ylPb804yPeXsgmf8D9wNrU-gFQK8JhbtA3SBZshFhBQFMuCFauvjCDykPl4fCKBiWvxbETlpjR1rXy4tfBQ6cqbIucFEA_x1nQHEDDZ31YEERCJSDsemGVufhdIKdWozygkrqyrtfNUEB_4nHa5Kjehjm8A',
        'verified': false,
      },
      {
        'name': 'Samuel P.',
        'url':
            'https://lh3.googleusercontent.com/aida-public/AB6AXuDmnB3zEA-jMklOfYpuvp664-Drza8YXnWDGsSM7oi4Kuk1LNF9GnT51DGiuRvYdEhru42AThFqcEAXe7BQxYcVCFE-PX9wYn7OYTStqi6Lyg6xlVKs9SV_4YM6rARBT79qLkwbF2KCEoBqg7alHiGexxD4yZndZ9yrPzypPAs_1dTVQAc0L01a1OPLquvenOfJOnUFgudHS139zS-Tx9kU1VDZMno9BeUjFXHUbKdoRL3SUZZ5KzfT4-94_Tr2a8sm0EmwLWrlFeg',
        'verified': false,
      },
      {
        'name': 'Lucía R.',
        'url':
            'https://lh3.googleusercontent.com/aida-public/AB6AXuBMK_EiApp5qkjHio277q6kwkoMvzDassxK1XfqjRTVe96VSotCSL93SB9OkZ2j9H-J31zXFdwwrkP8kJH8C6uoRsRlQVcun4UYJ85x6lEved6xfXkQuOGUtHc3wxIivlMeu6S3XqUSLCNKd9w1dyuNWIl-PfFjEJole6ui-35xc5s5uFYxxaVxfj0hhRnGqFlXj7t55i0_QWr4ejgqS9ipQ-pwZRueVNTKimU3xbYCjyztYQtZpoEZ74xZYrUOV31lFKFYYRFVbZg',
        'verified': false,
      },
      {
        'name': 'Martín L.',
        'url':
            'https://lh3.googleusercontent.com/aida-public/AB6AXuC5yYBOl6gRU60ro0G8b-arkhMDMmZe0Ysrnt6vi8wS8uLW0Gr5vd1RH-i2LZNm-w79Q6uI-t9QtCRs5fNRr0g5F6c4bEeOF2tkVa7PkHCyQCpEzQFbC7zcwaRnYmilu5GYjgNIVCKGBbQBHO6p1HG-8I3RUDzE62mBw_yXuDJiRE3p3-3nhlKuGMxFDOGPBpE8aCdO6JF-R9FEXZOeBk9FntU7OPBr38cItVNiY8TOTA4--fOR9lTZLlla4gD7iR6AnpQx1O-ahcI',
        'verified': false,
      },
    ];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Proveedores Cercanos',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                'Ver todos',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: _isLoading ? 5 : suppliers.length,
            separatorBuilder: (_, _) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              if (_isLoading) {
                return SkeletonShimmer(
                  child: SizedBox(
                    width: 70,
                    child: Column(
                      children: const [
                        SkeletonContainer(
                          width: 64,
                          height: 64,
                          shape: BoxShape.circle,
                        ),
                        SizedBox(height: 8),
                        SkeletonText(width: 50, height: 11),
                      ],
                    ),
                  ),
                );
              }
              final s = suppliers[index];
              return SizedBox(
                width: 70,
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.colorScheme.primary,
                              width: 2,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: Image.network(
                              s['url'] as String,
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, s) =>
                                  const Icon(Icons.person),
                            ),
                          ),
                        ),
                        if (s['verified'] as bool)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.verified,
                                color: Colors.white,
                                size: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      s['name'] as String,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget? _buildSalesModeBadge(
    String? salesMode,
    ThemeData theme,
    bool isDark, {
    String? productName,
  }) {
    if (salesMode == null) {
      return null;
    }

    if (salesMode == 'both' && productName != null) {
      final currentMode = _selectedProductModes[productName] ?? 'retail';
      final bool isRetailSelected = currentMode == 'retail';
      final bool isWholesaleSelected = currentMode == 'wholesale';

      return Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF111827) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
            width: 0.8,
          ),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
              onTap: () {
                setState(() {
                  _selectedProductModes[productName] = 'retail';
                });
              },
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: isRetailSelected
                      ? (isDark
                            ? const Color(0xFF047857)
                            : const Color(0xFF059669))
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: isRetailSelected
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
                      Icons.shopping_bag_outlined,
                      size: 11,
                      color: isRetailSelected
                          ? Colors.white
                          : (isDark ? Colors.grey[400] : Colors.grey[600]),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      'Detalle',
                      style: GoogleFonts.inter(
                        color: isRetailSelected
                            ? Colors.white
                            : (isDark ? Colors.grey[400] : Colors.grey[600]),
                        fontSize: 10,
                        fontWeight: isRetailSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 2),
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedProductModes[productName] = 'wholesale';
                });
              },
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: isWholesaleSelected
                      ? (isDark
                            ? const Color(0xFF0284C7)
                            : const Color(0xFF0369A1))
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: isWholesaleSelected
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
                      Icons.inventory_2_outlined,
                      size: 11,
                      color: isWholesaleSelected
                          ? Colors.white
                          : (isDark ? Colors.grey[400] : Colors.grey[600]),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      'Por Mayor',
                      style: GoogleFonts.inter(
                        color: isWholesaleSelected
                            ? Colors.white
                            : (isDark ? Colors.grey[400] : Colors.grey[600]),
                        fontSize: 10,
                        fontWeight: isWholesaleSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
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

    final bool isRetailOnly =
        salesMode == 'retail_only' || salesMode == 'retail';
    final String label = isRetailOnly ? 'Solo al Detalle' : 'Solo por Mayor';
    final IconData icon = isRetailOnly
        ? Icons.shopping_bag_outlined
        : Icons.inventory_2_outlined;

    final Color bgColor = isRetailOnly
        ? (isDark
              ? const Color(0xFF064E3B).withValues(alpha: 0.35)
              : const Color(0xFFECFDF5))
        : (isDark
              ? const Color(0xFF075985).withValues(alpha: 0.35)
              : const Color(0xFFF0F9FF));
    final Color borderColor = isRetailOnly
        ? (isDark
              ? const Color(0xFF059669).withValues(alpha: 0.4)
              : const Color(0xFFA7F3D0))
        : (isDark
              ? const Color(0xFF0284C7).withValues(alpha: 0.4)
              : const Color(0xFFBAE6FD));
    final Color textColor = isRetailOnly
        ? (isDark ? const Color(0xFF6EE7B7) : const Color(0xFF047857))
        : (isDark ? const Color(0xFF7DD3FC) : const Color(0xFF0369A1));

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
          Text(
            label,
            style: GoogleFonts.inter(
              color: textColor,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
            ),
          ),
        ],
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

  String _getProductSku(Map<String, dynamic> item) {
    if (item['sku'] != null && item['sku'].toString().trim().isNotEmpty) {
      return item['sku'].toString().trim();
    }
    final name = (item['name'] ?? 'PROD').toString().replaceAll(' ', '').toUpperCase();
    final nameCode = name.length >= 3 ? name.substring(0, 3) : name.padRight(3, 'X');
    final cat = (item['category'] ?? 'GEN').toString().replaceAll(' ', '').toUpperCase();
    final catCode = cat.length >= 3 ? cat.substring(0, 3) : cat.padRight(3, 'X');
    return '$catCode-$nameCode-01';
  }

  Widget _buildVariantCard(
    BuildContext context,
    ThemeData theme,
    Map<String, dynamic> data,
    bool isDark, {
    bool showCartButton = false,
    bool showBottomCartButton = false,
    bool showSupplier = true,
    bool showLocation = true,
    bool isCompact = false,
  }) {
    final double cardWidth = isCompact ? 220.0 : 280.0;
    final double imageHeight = isCompact ? 120.0 : 180.0;
    final double cardRadius = isCompact ? 18.0 : 24.0;
    final EdgeInsets contentPadding = isCompact
        ? const EdgeInsets.symmetric(horizontal: 12, vertical: 10)
        : const EdgeInsets.symmetric(horizontal: 16, vertical: 14);

    final String badge = (data['badge'] ?? 'Primera Calidad').toString();
    Color badgeColor = theme.colorScheme.primary;
    final lowerBadge = badge.toLowerCase();
    if (lowerBadge.contains('segunda')) {
      badgeColor = const Color(0xFFFF8A5B); // Mamey
    } else if (lowerBadge.contains('tercera')) {
      badgeColor = Colors.red[500]!;
    }

    final productName = data['name'] ?? '';
    final int secondsRemaining = data['secondsRemaining'] as int? ?? 999999;
    final bool isExpired = secondsRemaining <= 0;

    final salesMode = data['salesMode'] ?? 'retail_only';
    final currentMode = (salesMode == 'both')
        ? (_selectedProductModes[productName] ?? 'retail')
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
      onTap: () {
        if (isExpired) {
          _showExpiredOfferBottomSheet(context, data);
        } else {
          context.push('/product_detail', extra: data);
        }
      },
      child: Container(
        width: cardWidth,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1f2937) : Colors.white,
          borderRadius: BorderRadius.circular(cardRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(cardRadius),
                  ),
                  child: Builder(
                    builder: (context) {
                      final imgSrc = data['img']!.toString();
                      if (imgSrc.startsWith('assets/')) {
                        return Image.asset(
                          imgSrc,
                          height: imageHeight,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) =>
                              Container(height: imageHeight, color: Colors.grey[300]),
                        );
                      }
                      return Image.network(
                        imgSrc,
                        height: imageHeight,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) =>
                            Container(height: imageHeight, color: Colors.grey[300]),
                      );
                    },
                  ),
                ),
                if (data['discount'] != null)
                  Positioned(
                    top: isCompact ? 10 : 16,
                    left: isCompact ? 10 : 16,
                    child: AnimatedDiscountBadge(
                      discountText: data['discount'].toString(),
                      isExpired: isExpired,
                    ),
                  ),
                Positioned(
                  top: isCompact ? 10 : 16,
                  right: isCompact ? 10 : 16,
                  child: ValueListenableBuilder<List<Map<String, dynamic>>>(
                    valueListenable: globalFavorites,
                    builder: (context, favoritesList, child) {
                      final bool isFav = isFavorite(data['name']?.toString() ?? '');
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
                                ? const Color(0xFF016142)
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
                Positioned(
                  bottom: isCompact ? 8 : 12,
                  right: isCompact ? 10 : 16,
                  child: showCartButton
                      ? Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              final cartItem = {
                                ...data,
                                'price': isWholesale
                                    ? (data['wholesalePrice'] ?? data['price'])
                                    : data['price'],
                                'rawPrice': isWholesale
                                    ? (data['wholesaleRawPrice'] ?? data['rawPrice'])
                                    : data['rawPrice'],
                                'saleType':
                                    isWholesale ? 'Por Mayor' : 'Al Detalle',
                                'isWholesale': isWholesale,
                                'supplier':
                                    data['supplier'] ?? 'Hipermercados Olé',
                              };
                              addToCart(cartItem);
                              ScaffoldMessenger.of(context).clearSnackBars();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      const Icon(
                                        Icons.shopping_cart,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          'Añadido al carrito ($productName)',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: const Color(0xFF016142),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              width: isCompact ? 34 : 38,
                              height: isCompact ? 34 : 38,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF064E3B).withValues(alpha: 0.6)
                                    : const Color(0xFFDFF0E8),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isDark
                                      ? const Color(0xFF059669).withValues(alpha: 0.7)
                                      : const Color(0xFF88C8A8),
                                  width: 1.2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.15),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.shopping_cart_outlined,
                                  size: isCompact ? 18 : 20,
                                  color: isDark
                                      ? const Color(0xFF6EE7B7)
                                      : const Color(0xFF1B4D3E),
                                ),
                              ),
                            ),
                          ),
                        )
                      : Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: const [
                              BoxShadow(color: Colors.black26, blurRadius: 4),
                            ],
                          ),
                          child: const Icon(
                            Icons.verified,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                ),
                if (data.containsKey('overlayText') &&
                    data['overlayText'] != null)
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.trending_up,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            data['overlayText']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: contentPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['name']?.toString() ?? '',
                              style: TextStyle(
                                fontSize: isCompact ? 13.5 : 17,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'SKU: ${_getProductSku(data)}',
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: isCompact ? 8.5 : 9.5,
                                fontWeight: FontWeight.w500,
                                color: isDark ? Colors.grey.shade400 : const Color(0xFF94A3B8),
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (displayOldPrice != null)
                            Text(
                              displayOldPrice,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: isCompact ? 9.5 : 11,
                                decoration: TextDecoration.lineThrough,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            transitionBuilder: (child, animation) =>
                                FadeTransition(
                                  opacity: animation,
                                  child: child,
                                ),
                            child: FittedBox(
                              key: ValueKey<String>(displayPrice),
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerRight,
                              child: Text(
                                displayPrice,
                                maxLines: 1,
                                softWrap: false,
                                style: TextStyle(
                                  color: isWholesale
                                      ? const Color(0xFF0284C7)
                                      : theme.colorScheme.primary,
                                  fontSize: isCompact ? 16.5 : 20,
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
                                    ? 'wholesale_${data['wholesaleMin']}'
                                    : 'retail',
                              ),
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                if (isWholesale) ...[
                                  Text(
                                    data['wholesaleUnitText']?.toString() ?? 'POR MAYOR',
                                    style: TextStyle(
                                      fontSize: isCompact ? 7.5 : 8,
                                      fontWeight: FontWeight.w800,
                                      color: isDark
                                          ? const Color(0xFF38BDF8)
                                          : const Color(0xFF0284C7),
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                  if (data['wholesaleMin'] != null)
                                    Text(
                                      '(${data['wholesaleMin']})',
                                      style: TextStyle(
                                        fontSize: isCompact ? 6.5 : 7,
                                        fontWeight: FontWeight.w700,
                                        color:
                                            (isDark
                                                    ? const Color(0xFF38BDF8)
                                                    : const Color(0xFF0284C7))
                                                .withValues(alpha: 0.85),
                                        letterSpacing: 0.1,
                                      ),
                                    ),
                                ] else ...[
                                  Text(
                                    data['unitText']?.toString() ?? 'POR KILO',
                                    style: TextStyle(
                                      fontSize: isCompact ? 7.5 : 8,
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
                  SizedBox(height: isCompact ? 6 : 8),
                  Builder(
                    builder: (context) {
                      final salesBadge = _buildSalesModeBadge(
                        data['salesMode'],
                        theme,
                        isDark,
                        productName: productName,
                      );
                      final hasTags =
                          data['tags'] != null &&
                          (data['tags'] as List).isNotEmpty;
                      if (!hasTags && salesBadge == null) {
                        return const SizedBox.shrink();
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              ...salesBadge != null
                                  ? [salesBadge]
                                  : <Widget>[],
                              if (hasTags)
                                ...(data['tags'] as List).map((tag) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                        color: theme.colorScheme.primary
                                            .withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: Text(
                                      tag.toString(),
                                      style: TextStyle(
                                        color: isDark
                                            ? const Color(0xFF6ee7b7)
                                            : theme.colorScheme.primary,
                                        fontSize: isCompact ? 9 : 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                }),
                            ],
                          ),
                          SizedBox(height: isCompact ? 4 : 6),
                        ],
                      );
                    },
                  ),
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) =>
                            ProductReviewsModal(product: data),
                      );
                    },
                    behavior: HitTestBehavior.opaque,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star,
                            color: Colors.orange,
                            size: isCompact ? 13 : 15,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            data['rating']?.toString() ?? '4.8',
                            style: TextStyle(
                              fontSize: isCompact ? 11.5 : 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(128 reseñas)',
                            style: TextStyle(
                              fontSize: isCompact ? 9 : 10,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: isCompact ? 8 : 12),
                  const Divider(color: Color(0xFFE0E3DF), thickness: 0.8),
                  SizedBox(height: isCompact ? 8 : 12),
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
                          width: isCompact ? 28 : 32,
                          height: isCompact ? 28 : 32,
                          decoration: BoxDecoration(
                            color: badgeColor.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.workspace_premium,
                            color: badgeColor,
                            size: isCompact ? 14 : 16,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'CALIDAD',
                                style: TextStyle(
                                  fontSize: isCompact ? 8 : 9,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Text(
                                badge.toUpperCase(),
                                style: TextStyle(
                                  fontSize: isCompact ? 10.5 : 12,
                                  fontWeight: FontWeight.w900,
                                  color: badgeColor,
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
                  // PROVEEDOR Row (conditionally displayed)
                  if (showSupplier) ...[
                    SizedBox(height: isCompact ? 8 : 12),
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
                            width: isCompact ? 28 : 32,
                            height: isCompact ? 28 : 32,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.15,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.local_florist,
                              color: theme.colorScheme.primary,
                              size: isCompact ? 14 : 16,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'PROVEEDOR',
                                  style: TextStyle(
                                    fontSize: isCompact ? 8 : 9,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                Text(
                                  data['supplier'] ?? 'Granja El Sol',
                                  style: TextStyle(
                                    fontSize: isCompact ? 11.5 : 13,
                                    fontWeight: FontWeight.bold,
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
                  ],
                  // UBICACIÓN Row (conditionally displayed)
                  if (showLocation) ...[
                    SizedBox(height: isCompact ? 8 : 12),
                    Row(
                      children: [
                        Container(
                          width: isCompact ? 28 : 32,
                          height: isCompact ? 28 : 32,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.location_on,
                            color: Colors.grey,
                            size: isCompact ? 14 : 16,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'UBICACIÓN',
                                style: TextStyle(
                                  fontSize: isCompact ? 8 : 9,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Text(
                                data['location'] ?? 'Valle de Santiago, GTO',
                                style: TextStyle(
                                  fontSize: isCompact ? 11.5 : 13,
                                  color: Colors.grey,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (showBottomCartButton) ...[
                    SizedBox(height: isCompact ? 10 : 14),
                    SizedBox(
                      width: double.infinity,
                      height: isCompact ? 36 : 40,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          final cartItem = {
                            ...data,
                            'price': isWholesale
                                ? (data['wholesalePrice'] ?? data['price'])
                                : data['price'],
                            'rawPrice': isWholesale
                                ? (data['wholesaleRawPrice'] ?? data['rawPrice'])
                                : data['rawPrice'],
                            'saleType':
                                isWholesale ? 'Por Mayor' : 'Al Detalle',
                            'isWholesale': isWholesale,
                            'supplier':
                                data['supplier'] ?? 'Hipermercados Olé',
                          };
                          addToCart(cartItem);
                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(
                                    Icons.shopping_cart,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Añadido al carrito ($productName)',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              backgroundColor: const Color(0xFF016142),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.shopping_cart_outlined,
                          size: 16,
                        ),
                        label: const Text(
                          'Agregar al carrito',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF047857),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                  if (data['secondsRemaining'] != null) ...[
                    SizedBox(height: isCompact ? 8 : 12),
                    _buildCardCountdownBanner(
                      data['secondsRemaining'] as int,
                      isDark,
                    ),
                  ],
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
      child: FittedBox(
        fit: BoxFit.scaleDown,
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

  Widget _buildFlashOffers(ThemeData theme, Color surfaceColor, bool isDark) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.bolt, color: Colors.orange),
                  SizedBox(width: 8),
                  Text(
                    'Ofertas Relámpago',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => context.push('/flash-offers'),
                child: Text(
                  'Ver todo',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 600,
          child: ValueListenableBuilder<List<Map<String, dynamic>>>(
            valueListenable: globalFlashOffers,
            builder: (context, flashList, child) {
              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _isLoading ? 3 : flashList.length,
                separatorBuilder: (_, _) => const SizedBox(width: 24),
                itemBuilder: (context, index) {
                  if (_isLoading) {
                    return const SkeletonProductCard();
                  }
                  return _buildVariantCard(
                    context,
                    theme,
                    flashList[index],
                    isDark,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGroceryEssentials(
    ThemeData theme,
    Color surfaceColor,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // Store circular logo
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFCE1126),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFCE1126).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Olé',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          height: 1.0,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        'hipermercados',
                        style: GoogleFonts.poppins(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 5,
                          fontWeight: FontWeight.w600,
                          height: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Section Title and Store Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Proveedor destacado',
                      style: GoogleFonts.manrope(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF111827),
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'De Hipermercados Olé Villa Mella 🛒',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.grey[400] : const Color(0xFF6B7280),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Arrow forward button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => context.push('/search'),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF3F4F6),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
                        width: 0.8,
                      ),
                    ),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      size: 18,
                      color: isDark ? Colors.grey[300] : const Color(0xFF374151),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 410,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: _isLoading ? 3 : _groceryEssentials.length,
            separatorBuilder: (_, _) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              if (_isLoading) {
                return const SkeletonProductCard(width: 220, height: 410);
              }
              return _buildVariantCard(
                context,
                theme,
                _groceryEssentials[index],
                isDark,
                showCartButton: false,
                showBottomCartButton: true,
                showSupplier: false,
                showLocation: false,
                isCompact: true,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMostTraded(ThemeData theme, Color surfaceColor, bool isDark) {
    final traded = [
      {
        'name': 'Café de Altura',
        'sku': 'BEB-CAF-01',
        'overlayText': '85 negociados',
        'price': '\$85.00',
        'rating': '4.7',
        'badge': 'PRIMERA CALIDAD',
        'supplier': 'Coop. Veracruz',
        'location': 'Coatepec, Veracruz',
        'img':
            'https://lh3.googleusercontent.com/aida-public/AB6AXuCN-hVTSx1rNbAD9eHpKDImU8vYJNZFoITfQVx73EZIsla3sFfOoX1WKcFfcivkoGD6cfKSKUvwKe2quKBgEgLxJFpQkv0inpNh-tvY1FVwe61aMojskS1J6eWlmYdoEFeaMUrxyGhzKBbn_rAkmvNeu9kgAeCVKeg4IZmh1p7gEOG8Ww0k6j5HLcgnH5larlnuSK9k2mF0Lw782V2ktGYYAR6k1m1pN-ffQWT0y4L2ZJRKh-QiDe1Wr-XvoTyrT8hhyTgO0PSlWBE',
      },
      {
        'name': 'Aguacate Hass',
        'sku': 'VER-AGU-02',
        'overlayText': '42 negociados',
        'price': '\$45.00',
        'rating': '5.0',
        'badge': 'PRIMERA CALIDAD',
        'supplier': 'Huasca Farms',
        'location': 'Uruapan, Michoacán',
        'img':
            'https://lh3.googleusercontent.com/aida-public/AB6AXuCoJ0D5DucqLAya_-YteH6-8cB0lbCiusShRQ5J7CpVWmeRZq_Dunwko3RtZ6MnlwVNNLu9qIMiXPC02Jr1-ZLXltcDkkQ0pqh4QKIExzuuQRRqrcXdHQcZxH33bpROQ5o-f2IBOsbqiL6lAuXMgnbrH4_kJmNK6b8kKf_2pM4dzh8AtsiiLNaiDX88Fe0OoRYiKx2-omyEvAoG4YwfLUNLxG5W4A6kcm0dv08LBcwmXpObjY9s4lgDuy3fpuu-_bUGZXDeZUcnKro',
      },
      {
        'name': 'Chinola Fresca (Maracuyá)',
        'sku': 'FRU-CHI-03',
        'overlayText': '112 negociados',
        'price': '\$55.00',
        'rating': '4.8',
        'badge': 'SEGUNDA CALIDAD',
        'supplier': 'Frutas Tropicales',
        'location': 'Tecomán, Colima',
        'img':
            'https://raw.githubusercontent.com/NevaDom47/imagenes/refs/heads/main/20250603_1528_Chinola%20Fresca%20Display_simple_compose_01jwvm7bwxeygt5bww6jkthp81.png',
      },
      {
        'name': 'Tomate Bola Rojo',
        'sku': 'HOR-TOM-04',
        'overlayText': '38 negociados',
        'price': '\$22.00',
        'rating': '4.5',
        'badge': 'TERCERA CALIDAD',
        'supplier': 'Invernaderos SLP',
        'location': 'San Luis Potosí',
        'img':
            'https://raw.githubusercontent.com/NevaDom47/imagenes/refs/heads/main/20250603_1524_Tomate%20Fresco%20Expuesto_simple_compose_01jwvkz8qsfxdazzgv3zd2wnv0.png',
      },
      {
        'name': 'Plátano Macho Especial',
        'sku': 'FRU-PLA-05',
        'overlayText': '56 negociados',
        'price': '\$16.50',
        'rating': '4.9',
        'badge': 'PRIMERA CALIDAD',
        'supplier': 'Plataneros del Sureste',
        'location': 'Teapa, Tabasco',
        'img':
            'https://raw.githubusercontent.com/NevaDom47/imagenes/refs/heads/main/20250603_1515_Pl%C3%A1tano%20sobre%20Fondo%20Verde_simple_compose_01jwvkfvz0etrr0gg640b8nxwd.png',
      },
    ];
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.handshake, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  const Text(
                    'Más Negociados',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Text(
                'Ver todo',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 560,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: _isLoading ? 3 : traded.length,
            separatorBuilder: (_, _) => const SizedBox(width: 24),
            itemBuilder: (context, index) {
              if (_isLoading) {
                return const SkeletonProductCard();
              }
              return _buildVariantCard(context, theme, traded[index], isDark);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildForYou(ThemeData theme, Color surfaceColor, bool isDark) {
    final List<Map<String, dynamic>> forYouItems = [
      {
        'name': 'Jitomate Saladet',
        'sku': 'HOR-JIT-01',
        'badge': 'Primera Calidad',
        'price': '\$22.00/kg',
        'wholesalePrice': '\$16.50/kg',
        'wholesaleMin': 'Caja 20kg',
        'salesMode': 'both',
        'supplier': 'Hacienda San Miguel',
        'location': 'Rancho San José, Querétaro',
        'rating': '4.6 (120)',
        'tags': ['Hortalizas', 'Orgánico'],
        'img':
            'https://lh3.googleusercontent.com/aida-public/AB6AXuBXcsVfAn4SXFQcHddnB5qMtM4renFwAuqO-lGdtcJtIIEmGl9tMDsFQiPgu60XnCWVebJO7iP0Ibk5dtJIqrh9Aanp9rZWGv7faUFsthP816CnkwG06d3lv6JAtK1L0AlnAz_e_RO8MTnW4_KInOanUlNL5k2AshcmFlzprpJxW1x81-1wvtFdgqmQ27XRJXCS6DLiTryvA9pgF60utXXNGEKTfgzyHZfbGio0iMIq4G_RBnQepN2i0vJ1-mywwHJNnmaXt1UMSH8',
      },
      {
        'name': 'Lechuga Francesa',
        'sku': 'HOR-LEC-02',
        'badge': 'Segunda Calidad',
        'price': '\$15.00/pza',
        'wholesalePrice': '\$10.50/pza',
        'wholesaleMin': 'Caja 24 pzas',
        'salesMode': 'both',
        'supplier': 'El Huerto Verde',
        'location': 'Valle Verde, Puebla',
        'rating': '4.8 (85)',
        'tags': ['Local', 'Hidropónico'],
        'img':
            'https://lh3.googleusercontent.com/aida-public/AB6AXuC8i3bYgCoFml8RIwzz2s32HSkKDvOTWEnX-bo6gt_9o4zdC9d3U0ZglOr_m6EMoKc6Oz2ryDTAoXTbMceJxM4huBHJNMRIBp_rkwcL972T0U0FipN8bSOaMvmlsOxI7peoA4M2Uq1zmuTbYTdHFlAe_A_VA3kLfbMf3thYxRRP7gU3H79Xu6gqxI8wfQqLd59xQyc9evPxWOYoH-ufQjjtXka1i6Bn6dDixAquahUTLyExdeosV0TZReH-nBZgtW2Wf1EEcK2VGiY',
      },
      {
        'name': 'Fresas Orgánicas Extras',
        'sku': 'FRU-FRE-03',
        'badge': 'Primera Calidad',
        'price': '\$45.00/kg',
        'wholesalePrice': '\$36.00/kg',
        'wholesaleMin': 'Caja 10kg',
        'salesMode': 'both',
        'supplier': 'AgroFresas',
        'location': 'Zamora, Michoacán',
        'rating': '4.9 (240)',
        'tags': ['Frutas', 'Orgánico'],
        'img':
            'https://raw.githubusercontent.com/NevaDom47/imagenes/refs/heads/main/20250620_1233_Fresas%20en%20Fondo%20Rosado_simple_compose_01jy72ypjmeccafrqb33rfm1q8.png',
      },
      {
        'name': 'Ajíes Variados Mix',
        'sku': 'HOR-AJI-04',
        'badge': 'Tercera Calidad',
        'price': '\$38.00/kg',
        'wholesalePrice': '\$28.50/kg',
        'wholesaleMin': 'Saco 15kg',
        'salesMode': 'both',
        'supplier': 'Picantes del Sur',
        'location': 'Mérida, Yucatán',
        'rating': '4.9 (98)',
        'tags': ['Hortalizas', 'Picante'],
        'img':
            'https://raw.githubusercontent.com/NevaDom47/imagenes/refs/heads/main/20250603_1549_Variedad%20de%20Aj%C3%ADes_simple_compose_01jwvncbmqfpvb7qv6rs3vh22x.png',
      },
      {
        'name': 'Plátano Verde Tabasco',
        'sku': 'FRU-PLA-05',
        'badge': 'Primera Calidad',
        'price': '\$15.00/kg',
        'wholesalePrice': '\$11.00/kg',
        'wholesaleMin': 'Caja 18kg',
        'salesMode': 'both',
        'supplier': 'Frutales del Sureste',
        'location': 'Teapa, Tabasco',
        'rating': '4.5 (80)',
        'tags': ['Frutas', 'Local'],
        'img':
            'https://raw.githubusercontent.com/NevaDom47/imagenes/refs/heads/main/20250603_1515_Pl%C3%A1tano%20sobre%20Fondo%20Verde_simple_compose_01jwvkfvz0etrr0gg640b8nxwd.png',
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.person_outline, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  const Text(
                    'Para Ti',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Text(
                'Ver todo',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            Column(
              children: List.generate(
                3,
                (index) => const Padding(
                  padding: EdgeInsets.only(bottom: 16.0),
                  child: SkeletonSearchProductCard(),
                ),
              ),
            )
          else
            Column(
              children: forYouItems.map((item) {
                final String productName = item['name'] as String;
                final String badge = (item['badge'] ?? 'Primera Calidad')
                    .toString();
                Color badgeColor = theme.colorScheme.primary;
                final lowerBadge = badge.toLowerCase();
                if (lowerBadge.contains('segunda')) {
                  badgeColor = const Color(0xFFFF8A5B); // Mamey
                } else if (lowerBadge.contains('tercera')) {
                  badgeColor = Colors.red[400]!;
                }

                final salesMode = item['salesMode'] ?? 'both';
                final currentMode = (salesMode == 'both')
                    ? (_selectedProductModes[productName] ?? 'retail')
                    : (salesMode == 'wholesale_only' ? 'wholesale' : 'retail');
                final bool isWholesale = currentMode == 'wholesale';

                final String displayPrice = isWholesale
                    ? (item['wholesalePrice'] ?? item['price'] as String)
                    : (item['price'] as String);

                final salesBadge = _buildSalesModeBadge(
                  salesMode,
                  theme,
                  isDark,
                  productName: productName,
                );

                final itemForDetail = {
                  ...item,
                  'salesMode': salesMode,
                  'saleType': isWholesale ? 'mayor' : 'detalle',
                  'selectedMode': currentMode,
                };

                return GestureDetector(
                  onTap: () => context.push('/product_detail', extra: itemForDetail),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            item['img'] as String,
                            width: 96,
                            height: 104,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => Container(
                              width: 96,
                              height: 104,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['name'] as String,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'SKU: ${_getProductSku(item)}',
                                          style: TextStyle(
                                            fontFamily: 'Manrope',
                                            fontSize: 9.0,
                                            fontWeight: FontWeight.w500,
                                            color: isDark
                                                ? Colors.grey.shade400
                                                : const Color(0xFF94A3B8),
                                            letterSpacing: 0.2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: badgeColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      badge,
                                      style: TextStyle(
                                        color: badgeColor,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (salesBadge != null) ...[
                                const SizedBox(height: 6),
                                salesBadge,
                              ],
                              const SizedBox(height: 6),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 200),
                                    child: Text(
                                      displayPrice,
                                      key: ValueKey<String>(displayPrice),
                                      style: TextStyle(
                                        color: isWholesale
                                            ? (isDark
                                                ? const Color(0xFF38BDF8)
                                                : const Color(0xFF0284C7))
                                            : theme.colorScheme.primary,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  if (isWholesale &&
                                      item['wholesaleMin'] != null) ...[
                                    const SizedBox(width: 4),
                                    Text(
                                      '(${item['wholesaleMin']})',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w600,
                                        color: isDark
                                            ? const Color(0xFF7DD3FC)
                                            : const Color(0xFF0284C7),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              if (item['tags'] != null &&
                                  (item['tags'] as List).isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 4,
                                  runSpacing: 4,
                                  children: (item['tags'] as List).map((tag) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary
                                            .withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        tag.toString(),
                                        style: TextStyle(
                                          color: isDark
                                              ? const Color(0xFF6ee7b7)
                                              : theme.colorScheme.primary,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.local_florist,
                                    size: 12,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    item['supplier'] as String,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    size: 12,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    item['location'] as String,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        color: Colors.orange,
                                        size: 12,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        item['rating'] as String,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  ValueListenableBuilder<
                                    List<Map<String, dynamic>>
                                  >(
                                    valueListenable: globalFavorites,
                                    builder: (context, favorites, child) {
                                      final isFav = isFavorite(
                                        item['name'] as String,
                                      );
                                      return AnimatedFavoriteButton(
                                        isFavorite: isFav,
                                        size: 16,
                                        onTap: () {
                                          toggleFavorite(item);
                                          ScaffoldMessenger.of(
                                            context,
                                          ).clearSnackBars();
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Row(
                                                children: [
                                                  Icon(
                                                    isFav
                                                        ? Icons.heart_broken
                                                        : Icons.favorite,
                                                    color: Colors.white,
                                                    size: 20,
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Text(
                                                    isFav
                                                        ? 'Eliminado de favoritos'
                                                        : 'Agregado a favoritos',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              backgroundColor: isFav
                                                  ? Colors.red.shade400
                                                  : const Color(0xFF016142),
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              duration: const Duration(
                                                seconds: 2,
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
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
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, bool isDark, Color primaryColor) {
    final bgColor = isDark
        ? const Color(0xFF022c22)
        : const Color(0xFFecfdf5); // emerald-950 and emerald-50
    final textHeaderColor = isDark
        ? const Color(0xFFecfdf5)
        : const Color(0xFF064e3b); // emerald-50 and emerald-900
    final subtextColor = isDark
        ? const Color(0xFFd1fae5).withValues(alpha: 0.6)
        : const Color(
            0xFF065f46,
          ).withValues(alpha: 0.6); // emerald-100/60 and emerald-800/60
    final dividerColor = isDark
        ? const Color(0xFF065f46).withValues(alpha: 0.2)
        : const Color(
            0xFFd1fae5,
          ).withValues(alpha: 0.2); // emerald-800/20 and emerald-100/20

    // Normal items
    final itemTextColor = isDark
        ? const Color(0xFFd1fae5).withValues(alpha: 0.7)
        : const Color(0xFF065f46).withValues(alpha: 0.7);
    final itemHoverBg = isDark
        ? const Color(0xFF065f46).withValues(alpha: 0.5)
        : const Color(0xFFd1fae5).withValues(alpha: 0.5);

    // Logout
    final logoutColor = isDark
        ? const Color(0xFFffdad6).withValues(alpha: 0.8)
        : const Color(0xFFba1a1a).withValues(alpha: 0.8);

    final avatarUrl =
        UserSession.profilePictureUrl ??
        (UserSession.selectedRole == 'proveedor'
            ? 'assets/images/Foto Sin perfil Proveedor.png'
            : 'assets/images/Foto sin perfil.png');

    return Drawer(
      backgroundColor: bgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Profile Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: primaryColor, width: 2),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: CircleAvatar(
                            backgroundColor: Colors.transparent,
                            backgroundImage:
                                avatarUrl.startsWith('http') ||
                                    avatarUrl.startsWith('blob:')
                                ? NetworkImage(avatarUrl) as ImageProvider
                                : (avatarUrl.startsWith('assets/')
                                      ? AssetImage(avatarUrl) as ImageProvider
                                      : (kIsWeb
                                            ? NetworkImage(avatarUrl)
                                                  as ImageProvider
                                            : FileImage(File(avatarUrl))
                                                  as ImageProvider)),
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: primaryColor,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(2),
                        child: const Icon(
                          Icons.verified,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    UserSession.fullName ?? 'Juan Pérez',
                    style: TextStyle(
                      color: textHeaderColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        UserSession.selectedRole == 'comprador'
                            ? 'ID: #BUY-88291'
                            : 'ID: #SELL-9942',
                        style: TextStyle(
                          color: subtextColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFa5f3cb),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'MIEMBRO PREMIUM',
                      style: TextStyle(
                        color: Color(0xFF002114),
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                children: [
                  _buildDrawerItem(
                    'Tareas',
                    Icons.assignment_outlined,
                    itemTextColor,
                    itemHoverBg,
                    false,
                    onTap: () {
                      context.pop();
                      context.push('/tasks');
                    },
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(
                          0xFFF20C0E,
                        ), // Red color for badge #F20C0E
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        '5',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  _buildDrawerItem(
                    'Negociaciones',
                    Icons.handshake,
                    itemTextColor,
                    itemHoverBg,
                    false,
                    onTap: () {
                      context.pop();
                      context.push('/negotiations');
                    },
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF20C0E),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        '3',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  _buildDrawerItem(
                    'Reseñas',
                    Icons.rate_review_outlined,
                    itemTextColor,
                    itemHoverBg,
                    false,
                    onTap: () {
                      context.pop();
                      context.push('/my-reviews');
                    },
                    trailing: MyReviewsScreen.pendingReviewsCount > 0
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF20C0E),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${MyReviewsScreen.pendingReviewsCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : null,
                  ),
                  _buildDrawerItem(
                    'Cupones',
                    Icons.confirmation_number,
                    itemTextColor,
                    itemHoverBg,
                    false,
                    onTap: () {
                      context.pop();
                      context.push('/coupons');
                    },
                  ),
                  _buildDrawerItem(
                    'Productos favoritos',
                    Icons.favorite_rounded,
                    itemTextColor,
                    itemHoverBg,
                    false,
                    onTap: () {
                      context.pop();
                      context.push('/favorites');
                    },
                  ),
                  _buildDrawerItem(
                    'Proveedores favoritos',
                    Icons.favorite,
                    itemTextColor,
                    itemHoverBg,
                    false,
                    onTap: () {
                      context.pop();
                      context.push('/favorite-providers');
                    },
                  ),
                  _buildDrawerItem(
                    'Gestor de Ofertas',
                    Icons.bolt,
                    itemTextColor,
                    itemHoverBg,
                    false,
                    onTap: () {
                      context.pop();
                      context.push('/flash-offers-manager');
                    },
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF004532),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'GESTIÓN',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  _buildDrawerItem(
                    'Gestion Producto',
                    Icons.inventory_2_outlined,
                    itemTextColor,
                    itemHoverBg,
                    false,
                    onTap: () {
                      context.pop();
                      context.push('/product-management');
                    },
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF004532),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'CATÁLOGO',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  _buildDrawerItem(
                    'Dashboard',
                    Icons.dashboard,
                    itemTextColor,
                    itemHoverBg,
                    false,
                    onTap: () {
                      context.pop();
                      context.push('/dashboard');
                    },
                  ),
                  Divider(color: dividerColor, height: 32),
                  _buildDrawerItem(
                    'Configuración',
                    Icons.settings,
                    itemTextColor,
                    itemHoverBg,
                    false,
                    onTap: () {
                      context.pop(); // dismiss drawer
                      context.push('/settings');
                    },
                  ),
                  _buildDrawerItem(
                    'Políticas legales',
                    Icons.policy,
                    itemTextColor,
                    itemHoverBg,
                    false,
                    onTap: () {
                      context.pop(); // dismiss drawer
                      context.push('/legal-policies');
                    },
                  ),
                  _buildDrawerItem(
                    'Ayuda',
                    Icons.help,
                    itemTextColor,
                    itemHoverBg,
                    false,
                    onTap: () {
                      context.pop(); // dismiss drawer
                      context.push('/help');
                    },
                  ),
                  Divider(color: dividerColor, height: 32),
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    leading: Icon(Icons.logout, color: logoutColor, size: 20),
                    title: Text(
                      'Cerrar sesión',
                      style: TextStyle(
                        color: logoutColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    onTap: () {
                      context.go('/login');
                    },
                  ),
                ],
              ),
            ),

            // Footer
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Emerald Harvest',
                    style: TextStyle(
                      color: textHeaderColor.withValues(alpha: 0.4),
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'v2.4.0 • El Mercadito',
                    style: TextStyle(
                      color: subtextColor.withValues(alpha: 0.6),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    String title,
    IconData icon,
    Color textColor,
    Color bgSelectedColor,
    bool isSelected, {
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        selected: isSelected,
        selectedTileColor: bgSelectedColor,
        leading: Icon(icon, color: textColor, size: 20),
        title: Text(
          title,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
        trailing: trailing,
        onTap: onTap ?? () {},
      ),
    );
  }
}

class MarketTickerWidget extends StatefulWidget {
  final Color surfaceColor;
  final bool isDark;

  const MarketTickerWidget({
    super.key,
    required this.surfaceColor,
    required this.isDark,
  });

  @override
  State<MarketTickerWidget> createState() => _MarketTickerWidgetState();
}

class _MarketTickerWidgetState extends State<MarketTickerWidget> {
  late final ScrollController _scrollController;
  Timer? _timer;

  final items = [
    {
      'market': 'CEDA CDMX',
      'name': 'Maíz Blanco',
      'price': '\$320.50',
      'change': '+2.1%',
      'up': true,
    },
    {
      'market': 'Abastos MTY',
      'name': 'Trigo Harinero',
      'price': '\$285.20',
      'change': '-0.5%',
      'up': false,
    },
    {
      'market': 'CEDA Puebla',
      'name': 'Soya',
      'price': '\$410.00',
      'change': '+1.2%',
      'up': true,
    },
    {
      'market': 'Mercado GDL',
      'name': 'Frijol Negro',
      'price': '\$390.00',
      'change': '+0.8%',
      'up': true,
    },
    {
      'market': 'CEDA CDMX',
      'name': 'Sorgo',
      'price': '\$185.30',
      'change': '-1.2%',
      'up': false,
    },
    {
      'market': 'San Juan',
      'name': 'Garbanzo',
      'price': '\$450.00',
      'change': '+3.5%',
      'up': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startMarquee();
    });
  }

  void _startMarquee() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 20), (timer) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.offset + 1.0);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 104,
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification notification) {
          if (notification is ScrollStartNotification &&
              notification.dragDetails != null) {
            _timer?.cancel();
          } else if (notification is ScrollEndNotification) {
            _startMarquee();
          }
          return false;
        },
        child: ListView.builder(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            final item = items[index % items.length];
            final isUp = item['up'] as bool;
            return Container(
              width: 140,
              margin: const EdgeInsets.only(left: 16, right: 0),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: widget.surfaceColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: widget.isDark ? Colors.grey[800]! : Colors.grey[200]!,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    (item['name'] as String),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    (item['market'] as String).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      letterSpacing: 0.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['price'] as String,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        isUp ? Icons.trending_up : Icons.trending_down,
                        size: 12,
                        color: isUp ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        item['change'] as String,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isUp ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
