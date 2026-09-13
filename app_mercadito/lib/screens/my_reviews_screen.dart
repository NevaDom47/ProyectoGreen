import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import '../theme/app_theme.dart';

class MyReviewsScreen extends StatefulWidget {
  const MyReviewsScreen({super.key});

  // Global/Static tracker for pending reviews so other screens or drawer can access it dynamically
  static final List<Map<String, dynamic>> pendingReviews = [
    {
      'orderId': 'ORD-4829',
      'negotiationId': 'NEG-2026-894',
      'productName': 'Tomates Heirloom',
      'vendor': 'Finca La Esperanza',
      'vendorVerified': true,
      'imageUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuCK1u8etbY5cHiRod_Fsz0_cuGTPBYf1Kj3M9WWtxHKJPGQ80EV82hmsmCV_Gt93yIiAAYRrHcpjpcGQvWY6oCOXHF5JcfmhpwXq5fj6OyrK4y_GaFvJgKHtBGGRbV3fH5b06o4tW0WeCL9448PUxQhHSfSX58eVK_lx7JUhms8WnRMbpDqcWul-oB60GyFZHNBDb6ouVvsT47SpGzBpuWhNyUDtZ7iBTFmBGB6DtwzTd28a4GMKjluGv3yihiGBfs1OZehh14Ktak',
      'completedDate': '24 de Mayo, 2026',
      'finalPrice': '\$1.80/kg',
      'originalPrice': '\$2.20/kg',
      'quantity': '150 kg',
      'totalAmount': '\$270.00',
      'savings': '\$60.00',
      'deliveryMethod': 'Entrega directa en bodega',
      'paymentTerms': 'Contra entrega • Factura aprobada',
    },
    {
      'orderId': 'ORD-4712',
      'negotiationId': 'NEG-2026-751',
      'productName': 'Miel Silvestre',
      'vendor': 'Apicultura Los Pinos',
      'vendorVerified': true,
      'imageUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuCXVjjLbAdq-qPVQ_4K3NOYusCymD1EzqS1kC-Lo2r8QtaXyo5pkWNSGVhL5GRtQdbQGSokSKklmFZQkqOdUI4YyvMbTzXiN4AXEBPr5cPtwmDPhu-Xq-fe5DmDEQ7bb12IupTY6GlguVCGhQguSo9BlaDDC8cklW1Mk-PM8CK-6xz9XhSIfBgoT5YJi9nx55BRZ0yONRnrZSQ4Xft817qS_jLiuOtjEbCKVWGb-EVrUn1Ker8c_Z-DsulYXVud8E41W1UHegQnM4Q',
      'completedDate': '18 de Mayo, 2026',
      'finalPrice': '\$8.50/frasco',
      'originalPrice': '\$10.00/frasco',
      'quantity': '20 frascos',
      'totalAmount': '\$170.00',
      'savings': '\$30.00',
      'deliveryMethod': 'Envío asegurado en cajas especiales',
      'paymentTerms': 'Transferencia bancaria previa',
    },
    {
      'orderId': 'ORD-4655',
      'negotiationId': 'NEG-2026-620',
      'productName': 'Queso Curado',
      'vendor': 'Lácteos del Valle',
      'vendorVerified': true,
      'imageUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuDjdenPCC0s2roiOH2l6Sz2N-rAy2Z5-g76EAQ8oY8i6fZ5WyY2RRz3m5HRw-qieLTCWthbVvW_NkOtrz91LyjbwmmFV3VWJCDt0pchBuJrLF59mdAp64Rn-cCXRH2AIoNWH4L9A2VYArB1_irCME483PC-rXFcRaoC0hmqStlNSBMRqPK9gbl78IDP5FVW173bEhD9BhIOUJQeqA2wimkZJkE_AjWeDrXQdWreMOCFy5wZuNYYGotHD0NLXVKdDdHHms4qWYhrVOc',
      'completedDate': '12 de Mayo, 2026',
      'finalPrice': '\$12.00/pieza',
      'originalPrice': '\$14.50/pieza',
      'quantity': '15 piezas',
      'totalAmount': '\$180.00',
      'savings': '\$37.50',
      'deliveryMethod': 'Cadena de frío controlada',
      'paymentTerms': 'Crédito a 15 días tras recepción',
    },
  ];

  static int get pendingReviewsCount => pendingReviews.length;

  @override
  State<MyReviewsScreen> createState() => _MyReviewsScreenState();
}

class _MyReviewsScreenState extends State<MyReviewsScreen> {
  int _selectedTabIndex = 0; // 0: Pendientes, 1: Completadas
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Completed reviews state
  final List<Map<String, dynamic>> _completedReviews = [
    {
      'orderId': 'ORD-4510',
      'negotiationId': 'NEG-2026-512',
      'productName': 'Cesta de Verduras Mixtas',
      'vendor': 'Huerta San Miguel',
      'vendorVerified': true,
      'timeAgo': 'Hace 2 semanas',
      'completedDate': '10 de Mayo, 2026',
      'finalPrice': '\$25.00/cesta',
      'originalPrice': '\$30.00/cesta',
      'quantity': '2 cestas',
      'totalAmount': '\$50.00',
      'rating': 5,
      'tags': ['Excelente calidad', 'Frescura garantizada', 'Empaque cuidadoso'],
      'comment': 'Excelente calidad, todo muy fresco. Los pimientos estaban espectaculares y el empaque muy cuidadoso.',
      'productImageUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuCK1u8etbY5cHiRod_Fsz0_cuGTPBYf1Kj3M9WWtxHKJPGQ80EV82hmsmCV_Gt93yIiAAYRrHcpjpcGQvWY6oCOXHF5JcfmhpwXq5fj6OyrK4y_GaFvJgKHtBGGRbV3fH5b06o4tW0WeCL9448PUxQhHSfSX58eVK_lx7JUhms8WnRMbpDqcWul-oB60GyFZHNBDb6ouVvsT47SpGzBpuWhNyUDtZ7iBTFmBGB6DtwzTd28a4GMKjluGv3yihiGBfs1OZehh14Ktak',
      'userPhotoUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuDkExJjnogapAzYJSb7dQcgEWoBPwi2xrSMgswCUDDdVdRIXBZrVUKFDHMFPh8uh9DUS0PoOVg9IrZX3QGXegq2vzNujlg8qkX9oTAilz4-qbfjAC8xvPkNtl_X5ZFNpvFUAB6cbjL0rQECyadtUul-xcUGi73dT-_8e1Rr3QDvasFOTid1uiY8_3qwe0DHWwWnt-yKwa_USTLTgTbZYGYoRW7zLXOSazPfHD2Ouw_9Onw8CMHvzMiClYcBiFiabXucIHwkS4Ts75c',
      'producerReply': '¡Muchas gracias por tu comentario! Nos alegra mucho saber que disfrutaste la frescura de nuestra cosecha. Trabajamos con mucho cariño para que cada empaque llegue perfecto a tu mesa. - Huerta San Miguel',
    },
    {
      'orderId': 'ORD-4402',
      'negotiationId': 'NEG-2026-440',
      'productName': 'Aceite de Oliva Virgen Extra',
      'vendor': 'Olivar Los Cerezos',
      'vendorVerified': true,
      'timeAgo': 'Hace 1 mes',
      'completedDate': '28 de Abril, 2026',
      'finalPrice': '\$14.00/botella',
      'originalPrice': '\$16.50/botella',
      'quantity': '5 botellas',
      'totalAmount': '\$70.00',
      'rating': 4,
      'tags': ['Buen sabor', 'Puntualidad'],
      'comment': 'Muy buen sabor, intenso y con toques frutales. Ideal para ensaladas.',
      'productImageUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuCXVjjLbAdq-qPVQ_4K3NOYusCymD1EzqS1kC-Lo2r8QtaXyo5pkWNSGVhL5GRtQdbQGSokSKklmFZQkqOdUI4YyvMbTzXiN4AXEBPr5cPtwmDPhu-Xq-fe5DmDEQ7bb12IupTY6GlguVCGhQguSo9BlaDDC8cklW1Mk-PM8CK-6xz9XhSIfBgoT5YJi9nx55BRZ0yONRnrZSQ4Xft817qS_jLiuOtjEbCKVWGb-EVrUn1Ker8c_Z-DsulYXVud8E41W1UHegQnM4Q',
      'userPhotoUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuDP2SAhDf3xiSDi_M640MlgD1SQS_efXAy3Nge5f61w_PC0JqfPVQnJ_kzRN9OgQrCitc4c0LnJKeKKJHU00mVz4zapAJiBALXB2tF9-vkiIl8iYScPOcNMZwg2qMrHJfOf4och7hchrTrvSDLEMP3wTPctSP4iDgSaaRlygMLAx9hQgab4WuZ3LM2naJkAN4LC7H4CrZZrEyxehsOObIA6mq_8FYKPBB7xwkEQ9p6uL63m30AzftO3X0FNrF6k_45fChAU1ky479Y',
      'producerReply': null,
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredPendingList {
    if (_searchQuery.trim().isEmpty) return MyReviewsScreen.pendingReviews;
    final query = _searchQuery.toLowerCase();
    return MyReviewsScreen.pendingReviews.where((item) {
      final name = (item['productName'] ?? '').toString().toLowerCase();
      final vendor = (item['vendor'] ?? '').toString().toLowerCase();
      final orderId = (item['orderId'] ?? '').toString().toLowerCase();
      return name.contains(query) || vendor.contains(query) || orderId.contains(query);
    }).toList();
  }

  List<Map<String, dynamic>> get _filteredCompletedList {
    if (_searchQuery.trim().isEmpty) return _completedReviews;
    final query = _searchQuery.toLowerCase();
    return _completedReviews.where((item) {
      final name = (item['productName'] ?? '').toString().toLowerCase();
      final vendor = (item['vendor'] ?? '').toString().toLowerCase();
      final orderId = (item['orderId'] ?? '').toString().toLowerCase();
      return name.contains(query) || vendor.contains(query) || orderId.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight;
    final surfaceColor = isDark ? AppTheme.slate800 : Colors.white;
    final onSurfaceColor = isDark ? AppTheme.slate100 : AppTheme.slate900;
    final secondaryTextColor = isDark ? AppTheme.slate400 : AppTheme.slate500;
    final borderColor = isDark ? AppTheme.slate700 : AppTheme.slate200;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: surfaceColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Center(
            child: InkWell(
              onTap: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/home');
                }
              },
              borderRadius: BorderRadius.circular(999),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? AppTheme.slate900 : const Color(0xFFF1F4F0),
                ),
                child: Icon(
                  Icons.arrow_back,
                  color: isDark ? AppTheme.slate200 : AppTheme.primary,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
        title: Text(
          'Mis Reseñas',
          style: GoogleFonts.plusJakartaSans(
            color: onSurfaceColor,
            fontWeight: FontWeight.w700,
            fontSize: 18,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: borderColor,
            height: 1,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Section Banner: Negotiated products waiting for evaluation
              _buildHeroBanner(isDark),
              const SizedBox(height: 16),

              // Segment Switcher (Pendientes / Completadas)
              _buildSegmentSwitcher(isDark, surfaceColor, borderColor, onSurfaceColor),
              const SizedBox(height: 16),

              // Quick Search Bar
              _buildSearchBar(isDark, surfaceColor, borderColor, secondaryTextColor, onSurfaceColor),
              const SizedBox(height: 16),

              // Active Tab Content
              if (_selectedTabIndex == 0)
                _buildPendingTabContent(isDark, surfaceColor, onSurfaceColor, secondaryTextColor, borderColor)
              else
                _buildCompletedTabContent(isDark, surfaceColor, onSurfaceColor, secondaryTextColor, borderColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroBanner(bool isDark) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  const Color(0xFF0F3628),
                  const Color(0xFF092018),
                ]
              : [
                  AppTheme.primary,
                  const Color(0xFF044832),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: isDark ? 0.3 : 0.2),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Subtle decorative shapes
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 20,
            bottom: -40,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Productos Negociados',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 21,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Califica la calidad de los lotes recibidos y el cumplimiento del productor tras el cierre de tus acuerdos.',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white.withValues(alpha: 0.88),
                    fontWeight: FontWeight.w400,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 14),
                // Dynamic counters row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFBBF24),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${MyReviewsScreen.pendingReviews.length} pendientes',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF34D399),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${_completedReviews.length} completadas',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
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
    );
  }

  Widget _buildSegmentSwitcher(
    bool isDark,
    Color surfaceColor,
    Color borderColor,
    Color onSurfaceColor,
  ) {
    final activeBg = isDark ? AppTheme.slate700 : Colors.white;
    final inactiveText = isDark ? AppTheme.slate400 : AppTheme.slate500;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.slate900 : const Color(0xFFE9EFEA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 0.8),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTabIndex = 0),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _selectedTabIndex == 0 ? activeBg : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: _selectedTabIndex == 0
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.pending_actions_rounded,
                      size: 17,
                      color: _selectedTabIndex == 0 ? AppTheme.primaryLight : inactiveText,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Pendientes',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: _selectedTabIndex == 0 ? FontWeight.w700 : FontWeight.w600,
                        fontSize: 13,
                        color: _selectedTabIndex == 0 ? onSurfaceColor : inactiveText,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: _selectedTabIndex == 0
                            ? AppTheme.primary.withValues(alpha: isDark ? 0.35 : 0.12)
                            : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${MyReviewsScreen.pendingReviews.length}',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                          color: _selectedTabIndex == 0 ? AppTheme.primaryLight : inactiveText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTabIndex = 1),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _selectedTabIndex == 1 ? activeBg : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: _selectedTabIndex == 1
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.task_alt_rounded,
                      size: 17,
                      color: _selectedTabIndex == 1 ? AppTheme.primaryLight : inactiveText,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Completadas',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: _selectedTabIndex == 1 ? FontWeight.w700 : FontWeight.w600,
                        fontSize: 13,
                        color: _selectedTabIndex == 1 ? onSurfaceColor : inactiveText,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: _selectedTabIndex == 1
                            ? AppTheme.primary.withValues(alpha: isDark ? 0.35 : 0.12)
                            : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${_completedReviews.length}',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                          color: _selectedTabIndex == 1 ? AppTheme.primaryLight : inactiveText,
                        ),
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

  Widget _buildSearchBar(
    bool isDark,
    Color surfaceColor,
    Color borderColor,
    Color secondaryTextColor,
    Color onSurfaceColor,
  ) {
    final searchBgColor = isDark ? const Color(0xFF1f2937) : const Color(0xFFE5F1EB);

    return Container(
      decoration: BoxDecoration(
        color: searchBgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Row(
        children: [
          Icon(
            Icons.search,
            color: isDark ? const Color(0xFF89D6B0) : AppTheme.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Buscar productos agrícolas...',
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey[500] : Colors.grey[600],
                ),
              ),
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              color: isDark ? const Color(0xFF89D6B0) : AppTheme.primary,
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  _searchQuery = '';
                });
              },
            ),
        ],
      ),
    );
  }

  Widget _buildPendingTabContent(
    bool isDark,
    Color surfaceColor,
    Color onSurfaceColor,
    Color secondaryTextColor,
    Color borderColor,
  ) {
    final list = _filteredPendingList;

    if (list.isEmpty) {
      return _buildEmptyState(
        isDark: isDark,
        icon: Icons.assignment_turned_in_outlined,
        title: _searchQuery.isEmpty ? '¡Todo al día!' : 'Sin coincidencias',
        subtitle: _searchQuery.isEmpty
            ? 'No tienes productos negociados pendientes de reseñar en este momento.'
            : 'No encontramos ningún acuerdo que coincida con "$_searchQuery".',
        secondaryTextColor: secondaryTextColor,
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length,
      separatorBuilder: (context, index) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final item = list[index];
        return _buildPendingNegotiatedCard(
          item,
          isDark,
          surfaceColor,
          onSurfaceColor,
          secondaryTextColor,
          borderColor,
        );
      },
    );
  }

  Widget _buildCompletedTabContent(
    bool isDark,
    Color surfaceColor,
    Color onSurfaceColor,
    Color secondaryTextColor,
    Color borderColor,
  ) {
    final list = _filteredCompletedList;

    if (list.isEmpty) {
      return _buildEmptyState(
        isDark: isDark,
        icon: Icons.rate_review_outlined,
        title: _searchQuery.isEmpty ? 'Aún sin reseñas completadas' : 'Sin coincidencias',
        subtitle: _searchQuery.isEmpty
            ? 'Tus valoraciones y testimonios publicados aparecerán aquí.'
            : 'No encontramos ninguna reseña que coincida con "$_searchQuery".',
        secondaryTextColor: secondaryTextColor,
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length,
      separatorBuilder: (context, index) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final item = list[index];
        return _buildCompletedReviewCard(
          item,
          isDark,
          surfaceColor,
          onSurfaceColor,
          secondaryTextColor,
          borderColor,
        );
      },
    );
  }

  Widget _buildEmptyState({
    required bool isDark,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color secondaryTextColor,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48.0, horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: isDark ? AppTheme.slate800 : const Color(0xFFE8F2EC),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 38,
                color: AppTheme.primaryLight,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: isDark ? AppTheme.slate100 : AppTheme.slate800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: secondaryTextColor,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingNegotiatedCard(
    Map<String, dynamic> item,
    bool isDark,
    Color surfaceColor,
    Color onSurfaceColor,
    Color secondaryTextColor,
    Color borderColor,
  ) {
    final negotiatedPanelBg = isDark ? AppTheme.slate900 : const Color(0xFFF6F8F6);

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Order reference
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              item['orderId'] ?? 'ORD-0000',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: secondaryTextColor,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Main Row: Image + Title + Vendor + Date
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product image
              GestureDetector(
                onTap: () {
                  context.push('/product_detail', extra: {
                    'name': item['productName'],
                    'price': item['finalPrice']?.split('/')?.first ?? '\$1.80',
                    'unit': item['finalPrice']?.split('/')?.last ?? 'kg',
                    'image': item['imageUrl'],
                    'quality': 'Primera',
                    'supplier': item['vendor'],
                    'description': 'Lote fresco adquirido bajo negociación comercial directa.',
                  });
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    item['imageUrl'],
                    width: 84,
                    height: 84,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 84,
                      height: 84,
                      color: isDark ? AppTheme.slate700 : AppTheme.slate200,
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Title and Vendor column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        context.push('/product_detail', extra: {
                          'name': item['productName'],
                          'price': item['finalPrice']?.split('/')?.first ?? '\$1.80',
                          'unit': item['finalPrice']?.split('/')?.last ?? 'kg',
                          'image': item['imageUrl'],
                          'quality': 'Primera',
                          'supplier': item['vendor'],
                          'description': 'Lote fresco adquirido bajo negociación comercial directa.',
                        });
                      },
                      child: Text(
                        item['productName'],
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: onSurfaceColor,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 3),
                    GestureDetector(
                      onTap: () {
                        context.push('/provider', extra: {
                          'name': item['vendor'],
                          'rating': '4.9',
                          'distance': 'A 5 km',
                          'tags': 'Productor Directo • Mercadito Pro',
                          'salesType': 'Por Mayor y Detalle',
                          'img': item['imageUrl'],
                          'banner': item['imageUrl'],
                          'traded': '1,240 productos negociados',
                          'reviews': '120 reseñas de clientes',
                        });
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.storefront_outlined,
                            size: 13,
                            color: isDark ? AppTheme.slate400 : AppTheme.primaryLight,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              item['vendor'],
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDark ? const Color(0xFF89D6B0) : AppTheme.primary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (item['vendorVerified'] == true) ...[
                            const SizedBox(width: 4),
                            const Icon(Icons.verified, size: 13, color: Color(0xFF0284C7)),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 12,
                          color: secondaryTextColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          item['completedDate'] ?? '24 de Mayo, 2026',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Negotiation terms summary ribbon
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: negotiatedPanelBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor.withValues(alpha: 0.7)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildNegotiationMetric(
                    label: 'CANTIDAD',
                    value: item['quantity'] ?? '150 kg',
                    isDark: isDark,
                    textColor: onSurfaceColor,
                    secondaryTextColor: secondaryTextColor,
                  ),
                ),
                Container(
                  width: 1,
                  height: 28,
                  color: borderColor,
                ),
                Expanded(
                  child: _buildNegotiationMetric(
                    label: 'PRECIO PACTADO',
                    value: item['finalPrice'] ?? '\$1.80/kg',
                    originalValue: item['originalPrice'],
                    isDark: isDark,
                    textColor: isDark ? const Color(0xFF89D6B0) : AppTheme.primary,
                    secondaryTextColor: secondaryTextColor,
                  ),
                ),
                Container(
                  width: 1,
                  height: 28,
                  color: borderColor,
                ),
                Expanded(
                  child: _buildNegotiationMetric(
                    label: 'TOTAL ACORDADO',
                    value: item['totalAmount'] ?? '\$270.00',
                    isDark: isDark,
                    textColor: onSurfaceColor,
                    secondaryTextColor: secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Actions: Escribir Reseña & Ver Acuerdo
          Row(
            children: [
              // Details Button
              OutlinedButton.icon(
                onPressed: () => _showAgreementDetailsModal(context, item),
                icon: const Icon(Icons.description_outlined, size: 16),
                label: const Text('Acuerdo'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 42),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  side: BorderSide(color: borderColor),
                  foregroundColor: onSurfaceColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Main CTA Button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showWriteReviewBottomSheet(item),
                  icon: const Icon(Icons.rate_review_outlined, size: 16, color: Colors.white),
                  label: const Text('Escribir Reseña'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 42),
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNegotiationMetric({
    required String label,
    required String value,
    String? originalValue,
    required bool isDark,
    required Color textColor,
    required Color secondaryTextColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            color: secondaryTextColor,
            letterSpacing: 0.5,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
              ),
              if (originalValue != null) ...[
                const SizedBox(width: 4),
                Text(
                  originalValue,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    color: secondaryTextColor,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompletedReviewCard(
    Map<String, dynamic> item,
    bool isDark,
    Color surfaceColor,
    Color onSurfaceColor,
    Color secondaryTextColor,
    Color borderColor,
  ) {
    final commentBubbleBg = isDark ? AppTheme.slate900 : const Color(0xFFF6F8F6);

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Product Image + Title + Rating
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  context.push('/product_detail', extra: {
                    'name': item['productName'],
                    'price': item['finalPrice']?.split('/')?.first ?? '\$1.80',
                    'unit': item['finalPrice']?.split('/')?.last ?? 'kg',
                    'image': item['productImageUrl'],
                    'quality': 'Primera',
                    'supplier': item['vendor'],
                    'description': 'Lote recibido calificado por el comprador.',
                  });
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    item['productImageUrl'],
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 50,
                      height: 50,
                      color: isDark ? AppTheme.slate700 : AppTheme.slate200,
                      child: const Icon(Icons.broken_image, size: 20),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['productName'],
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: onSurfaceColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            item['vendor'],
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark ? const Color(0xFF89D6B0) : AppTheme.primary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 3,
                          height: 3,
                          decoration: BoxDecoration(
                            color: secondaryTextColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          item['timeAgo'] ?? item['completedDate'],
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Stars
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    Icons.star_rounded,
                    size: 17,
                    color: index < (item['rating'] ?? 5)
                        ? const Color(0xFFF59E0B)
                        : (isDark ? Colors.white12 : Colors.black12),
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Negotiation summary chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.slate900 : const Color(0xFFF1F5F2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.handshake_outlined,
                  size: 13,
                  color: isDark ? const Color(0xFF89D6B0) : AppTheme.primary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Negociado: ${item['quantity'] ?? '150 kg'} • ${item['finalPrice'] ?? '\$1.80/kg'}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isDark ? const Color(0xFF89D6B0) : AppTheme.primary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Total: ${item['totalAmount'] ?? '\$270.00'}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Tags if available
          if (item['tags'] != null && (item['tags'] as List).isNotEmpty) ...[
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: (item['tags'] as List).map<Widget>((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.slate700 : const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    tag.toString(),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFF89D6B0) : AppTheme.primary,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
          ],

          // User comment bubble
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: commentBubbleBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor.withValues(alpha: 0.6)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item['userPhotoUrl'] != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item['userPhotoUrl'],
                      width: 54,
                      height: 54,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 54,
                        height: 54,
                        color: isDark ? AppTheme.slate700 : AppTheme.slate200,
                        child: const Icon(Icons.broken_image, size: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    '"${item['comment']}"',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: onSurfaceColor.withValues(alpha: 0.85),
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Producer response
          if (item['producerReply'] != null) ...[
            const SizedBox(height: 8),
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF0D281E).withValues(alpha: 0.7)
                    : const Color(0xFFE8F5EE),
                border: Border(
                  left: BorderSide(
                    color: isDark ? const Color(0xFF1E8262) : AppTheme.primary,
                    width: 3.5,
                  ),
                ),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.reply_rounded,
                        size: 14,
                        color: isDark ? const Color(0xFF89D6B0) : AppTheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'RESPUESTA DEL PRODUCTOR',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: isDark ? const Color(0xFF89D6B0) : AppTheme.primary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item['producerReply']}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: isDark ? AppTheme.slate200 : const Color(0xFF2C4A3C),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showAgreementDetailsModal(BuildContext context, Map<String, dynamic> item) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor = isDark ? AppTheme.slate800 : Colors.white;
    final onSurface = isDark ? AppTheme.slate100 : AppTheme.slate900;
    final secondaryText = isDark ? AppTheme.slate400 : AppTheme.slate500;
    final borderColor = isDark ? AppTheme.slate700 : AppTheme.slate200;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.88,
          ),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : Colors.black12,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Detalles del Acuerdo',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: onSurface,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isDark ? AppTheme.slate700 : AppTheme.slate100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item['orderId'] ?? 'ORD',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: secondaryText,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Product overview row
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          item['imageUrl'],
                          width: 52,
                          height: 52,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 52,
                            height: 52,
                            color: isDark ? AppTheme.slate700 : AppTheme.slate200,
                            child: const Icon(Icons.broken_image, size: 20),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['productName'],
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: onSurface,
                              ),
                            ),
                            Text(
                              'Productor: ${item['vendor']}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                color: isDark ? const Color(0xFF89D6B0) : AppTheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Agreement breakdown
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.slate900 : const Color(0xFFF7FAF8),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      children: [
                        _buildAgreementRow('Volumen Negociado', item['quantity'] ?? '150 kg', onSurface, secondaryText),
                        const Divider(height: 16),
                        _buildAgreementRow('Precio Pactado', item['finalPrice'] ?? '\$1.80', onSurface, secondaryText),
                        if (item['originalPrice'] != null) ...[
                          const Divider(height: 16),
                          _buildAgreementRow('Precio Catálogo', item['originalPrice'], onSurface, secondaryText),
                        ],
                        if (item['savings'] != null) ...[
                          const Divider(height: 16),
                          _buildAgreementRow('Ahorro por Negociación', item['savings'], isDark ? const Color(0xFF89D6B0) : AppTheme.primary, secondaryText, isBold: true),
                        ],
                        const Divider(height: 16),
                        _buildAgreementRow('Monto Total', item['totalAmount'] ?? '\$270.00', onSurface, secondaryText, isBold: true),
                        const Divider(height: 16),
                        _buildAgreementRow('Método de Entrega', item['deliveryMethod'] ?? 'Directa', onSurface, secondaryText),
                        const Divider(height: 16),
                        _buildAgreementRow('Condición de Pago', item['paymentTerms'] ?? 'Contado', onSurface, secondaryText),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Action button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _showWriteReviewBottomSheet(item);
                      },
                      icon: const Icon(Icons.rate_review_outlined, color: Colors.white, size: 18),
                      label: const Text('Escribir Reseña para este Acuerdo'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAgreementRow(String label, String value, Color valueColor, Color labelColor, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: labelColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: valueColor,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  void _showWriteReviewBottomSheet(Map<String, dynamic> item) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Dialog(
            elevation: 0,
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: WriteReviewDialogContent(
              item: item,
              onSubmitted: (rating, comment, tags, photoAttached) {
                // Add simulated item to completed reviews
                setState(() {
                  _completedReviews.insert(0, {
                    'orderId': item['orderId'],
                    'negotiationId': item['negotiationId'],
                    'productName': item['productName'],
                    'vendor': item['vendor'],
                    'vendorVerified': item['vendorVerified'] ?? true,
                    'timeAgo': 'Ahora mismo',
                    'completedDate': item['completedDate'] ?? 'Hoy',
                    'finalPrice': item['finalPrice'] ?? '\$1.80/kg',
                    'originalPrice': item['originalPrice'],
                    'quantity': item['quantity'] ?? '150 kg',
                    'totalAmount': item['totalAmount'] ?? '\$270.00',
                    'rating': rating,
                    'tags': tags,
                    'comment': comment,
                    'productImageUrl': item['imageUrl'],
                    'userPhotoUrl': photoAttached
                        ? 'https://lh3.googleusercontent.com/aida-public/AB6AXuAmMGAtTpTPkjMWwNJsge_OEQkQcXikr1fQs3EOJW2BYd391R1uLWOWTIkZ8cEljuOwkk4YqdaAE82pvoOIhudKNFsD_XX3OL73RZW_WKVXeqRuxjY5ub9SYSyJ34AW6wJxJ7ScNjlu57HMiPKY936qyAOwuEPwk5R_3_agxbB-FTknORFByNpWC7WZi8LYUewfP6H55vJ3FzOI_xvehALO31NPZK7Ce2I3Qk3Qjb_ckJ598nAZXoMaG0P-stXcC9CranJTnBZhg_4'
                        : null,
                    'producerReply': null,
                  });
                  // Remove from pending reviews
                  MyReviewsScreen.pendingReviews.removeWhere((e) => e['orderId'] == item['orderId']);
                });

                // Toast feedback
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle_outline, color: Colors.white),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '¡Reseña publicada con éxito!',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class WriteReviewDialogContent extends StatefulWidget {
  final Map<String, dynamic> item;
  final void Function(int rating, String comment, List<String> tags, bool photoAttached) onSubmitted;

  const WriteReviewDialogContent({
    super.key,
    required this.item,
    required this.onSubmitted,
  });

  @override
  State<WriteReviewDialogContent> createState() => _WriteReviewDialogContentState();
}

class _WriteReviewDialogContentState extends State<WriteReviewDialogContent> {
  int _localRating = 5;
  final _commentController = TextEditingController();
  bool _photoAttached = false;
  final List<String> _selectedTags = [];

  final List<String> _availableTags = [
    'Excelente frescura',
    'Peso exacto',
    'Puntualidad de entrega',
    'Empaque óptimo',
    'Buena comunicación',
    'Trato profesional',
  ];

  @override
  void initState() {
    super.initState();
    _commentController.addListener(_updateCharCount);
  }

  void _updateCharCount() {
    setState(() {});
  }

  @override
  void dispose() {
    _commentController.removeListener(_updateCharCount);
    _commentController.dispose();
    super.dispose();
  }

  String _getRatingFeedback(int rating) {
    switch (rating) {
      case 5:
        return '¡Excelente calidad del lote!';
      case 4:
        return 'Muy buen producto y trato';
      case 3:
        return 'Cumplió lo acordado';
      case 2:
        return 'Detalles a mejorar';
      case 1:
        return 'No satisfecho con el lote';
      default:
        return '';
    }
  }

  void _showPhotoSourceBottomSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppTheme.slate800 : Colors.white;
    final onSurface = isDark ? AppTheme.slate100 : AppTheme.slate900;
    final borderColor = isDark ? AppTheme.slate700 : AppTheme.slate200;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Seleccionar Origen de Foto',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: onSurface,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        setState(() => _photoAttached = true);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: AppTheme.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            content: const Row(
                              children: [
                                Icon(Icons.camera_alt, color: Colors.white),
                                SizedBox(width: 12),
                                Text('Foto tomada con la Cámara'),
                              ],
                            ),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          border: Border.all(color: borderColor),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.camera_alt_outlined, size: 30, color: AppTheme.primary),
                            const SizedBox(height: 8),
                            Text(
                              'Cámara',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        setState(() => _photoAttached = true);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: AppTheme.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            content: const Row(
                              children: [
                                Icon(Icons.photo_library, color: Colors.white),
                                SizedBox(width: 12),
                                Text('Foto cargada desde Biblioteca'),
                              ],
                            ),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          border: Border.all(color: borderColor),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.photo_library_outlined, size: 30, color: AppTheme.primary),
                            const SizedBox(height: 8),
                            Text(
                              'Galería',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: onSurface,
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
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppTheme.slate800 : Colors.white;
    final onSurface = isDark ? AppTheme.slate100 : AppTheme.slate900;
    final secondaryText = isDark ? AppTheme.slate400 : AppTheme.slate500;
    final borderColor = isDark ? AppTheme.slate700 : AppTheme.slate200;
    final inputBg = isDark ? AppTheme.slate900 : const Color(0xFFF7FAF8);

    return Container(
      constraints: const BoxConstraints(maxWidth: 420),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Modal Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: borderColor, width: 0.8)),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    widget.item['imageUrl'],
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 44,
                      height: 44,
                      color: Colors.grey[300],
                      child: const Icon(Icons.broken_image, size: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Calificar Producto',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: onSurface,
                        ),
                      ),
                      Text(
                        '${widget.item['productName']} • ${widget.item['vendor']}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: secondaryText,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.04),
                    ),
                    child: Icon(Icons.close_rounded, size: 18, color: secondaryText),
                  ),
                ),
              ],
            ),
          ),

          // Scrollable Body
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Star Rating Section
                  Center(
                    child: Column(
                      children: [
                        Text(
                          '¿CÓMO CALIFICAS ESTE LOTE?',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w800,
                            fontSize: 10,
                            letterSpacing: 1.2,
                            color: secondaryText,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (index) {
                            final isSelected = index < _localRating;
                            return GestureDetector(
                              onTap: () => setState(() => _localRating = index + 1),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                child: Icon(
                                  isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
                                  size: 40,
                                  color: isSelected ? const Color(0xFFF59E0B) : (isDark ? Colors.white24 : Colors.black12),
                                ),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            '$_localRating.0 ★  ${_getRatingFeedback(_localRating)}',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              color: const Color(0xFFD97706),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Quick Aspect Chips
                  Text(
                    'PUNTOS DESTACADOS',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                      fontSize: 10,
                      letterSpacing: 1.2,
                      color: secondaryText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: _availableTags.map((tag) {
                      final isSelected = _selectedTags.contains(tag);
                      return FilterChip(
                        label: Text(tag),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedTags.add(tag);
                            } else {
                              _selectedTags.remove(tag);
                            }
                          });
                        },
                        labelStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? (isDark ? Colors.white : AppTheme.primary)
                              : onSurface,
                        ),
                        backgroundColor: inputBg,
                        selectedColor: isDark
                            ? const Color(0xFF1E8262).withValues(alpha: 0.4)
                            : const Color(0xFFE8F5E9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: isSelected ? AppTheme.primary : borderColor,
                          ),
                        ),
                        showCheckmark: false,
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Comment Input
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'TU TESTIMONIO',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          fontSize: 10,
                          letterSpacing: 1.2,
                          color: secondaryText,
                        ),
                      ),
                      Text(
                        _commentController.text.length < 8
                            ? 'Mínimo 8 letras (${_commentController.text.length}/8)'
                            : '${_commentController.text.length} caracteres',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                          color: _commentController.text.length < 8
                              ? Colors.redAccent
                              : AppTheme.primaryLight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _commentController,
                    maxLines: 3,
                    style: GoogleFonts.plusJakartaSans(fontSize: 13, color: onSurface),
                    decoration: InputDecoration(
                      hintText: 'Cuéntanos sobre la calidad, el empaque o la puntualidad acordada...',
                      hintStyle: GoogleFonts.plusJakartaSans(fontSize: 12, color: secondaryText),
                      filled: true,
                      fillColor: inputBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Photos Section
                  Text(
                    'FOTO DEL LOTE (OPCIONAL)',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                      fontSize: 10,
                      letterSpacing: 1.2,
                      color: secondaryText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => _showPhotoSourceBottomSheet(context),
                        child: Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            color: inputBg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: borderColor, style: BorderStyle.solid),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo_outlined, size: 22, color: secondaryText),
                              const SizedBox(height: 4),
                              Text(
                                'Adjuntar',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: secondaryText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_photoAttached) ...[
                        const SizedBox(width: 12),
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                'https://lh3.googleusercontent.com/aida-public/AB6AXuAmMGAtTpTPkjMWwNJsge_OEQkQcXikr1fQs3EOJW2BYd391R1uLWOWTIkZ8cEljuOwkk4YqdaAE82pvoOIhudKNFsD_XX3OL73RZW_WKVXeqRuxjY5ub9SYSyJ34AW6wJxJ7ScNjlu57HMiPKY936qyAOwuEPwk5R_3_agxbB-FTknORFByNpWC7WZi8LYUewfP6H55vJ3FzOI_xvehALO31NPZK7Ce2I3Qk3Qjb_ckJ598nAZXoMaG0P-stXcC9CranJTnBZhg_4',
                                width: 68,
                                height: 68,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: -6,
                              right: -6,
                              child: GestureDetector(
                                onTap: () => setState(() => _photoAttached = false),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: isDark ? AppTheme.slate800 : Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: const [
                                      BoxShadow(color: Colors.black26, blurRadius: 4),
                                    ],
                                  ),
                                  child: const Icon(Icons.close, size: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Modal Footer Actions
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: borderColor, width: 0.8)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: borderColor),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      'Cancelar',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: secondaryText,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      final comment = _commentController.text.trim();
                      if (comment.length < 8) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            backgroundColor: Colors.redAccent,
                            content: const Text('Ingresa al menos 8 caracteres en tu reseña.'),
                          ),
                        );
                        return;
                      }

                      widget.onSubmitted(_localRating, comment, _selectedTags, _photoAttached);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      'Publicar Reseña',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
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
}
