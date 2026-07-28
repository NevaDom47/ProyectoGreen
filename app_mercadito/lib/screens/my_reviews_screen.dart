import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';

class MyReviewsScreen extends StatefulWidget {
  const MyReviewsScreen({super.key});

  // Global/Static tracker for pending reviews so the sidebar drawer can access it dynamically!
  static final List<Map<String, dynamic>> pendingReviews = [
    {
      'orderId': 'ORD-4829',
      'productName': 'Tomates Heirloom',
      'vendor': 'Finca La Esperanza',
      'imageUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuCK1u8etbY5cHiRod_Fsz0_cuGTPBYf1Kj3M9WWtxHKJPGQ80EV82hmsmCV_Gt93yIiAAYRrHcpjpcGQvWY6oCOXHF5JcfmhpwXq5fj6OyrK4y_GaFvJgKHtBGGRbV3fH5b06o4tW0WeCL9448PUxQhHSfSX58eVK_lx7JUhms8WnRMbpDqcWul-oB60GyFZHNBDb6ouVvsT47SpGzBpuWhNyUDtZ7iBTFmBGB6DtwzTd28a4GMKjluGv3yihiGBfs1OZehh14Ktak',
      'completedDate': '24 de Mayo, 2026',
      'finalPrice': '\$1.80/kg',
      'quantity': '150 kg',
    },
    {
      'orderId': 'ORD-4712',
      'productName': 'Miel Silvestre',
      'vendor': 'Apicultura Los Pinos',
      'imageUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuCXVjjLbAdq-qPVQ_4K3NOYusCymD1EzqS1kC-Lo2r8QtaXyo5pkWNSGVhL5GRtQdbQGSokSKklmFZQkqOdUI4YyvMbTzXiN4AXEBPr5cPtwmDPhu-Xq-fe5DmDEQ7bb12IupTY6GlguVCGhQguSo9BlaDDC8cklW1Mk-PM8CK-6xz9XhSIfBgoT5YJi9nx55BRZ0yONRnrZSQ4Xft817qS_jLiuOtjEbCKVWGb-EVrUn1Ker8c_Z-DsulYXVud8E41W1UHegQnM4Q',
      'completedDate': '18 de Mayo, 2026',
      'finalPrice': '\$8.50/frasco',
      'quantity': '20 frascos',
    },
    {
      'orderId': 'ORD-4655',
      'productName': 'Queso Curado',
      'vendor': 'Lácteos del Valle',
      'imageUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuDjdenPCC0s2roiOH2l6Sz2N-rAy2Z5-g76EAQ8oY8i6fZ5WyY2RRz3m5HRw-qieLTCWthbVvW_NkOtrz91LyjbwmmFV3VWJCDt0pchBuJrLF59mdAp64Rn-cCXRH2AIoNWH4L9A2VYArB1_irCME483PC-rXFcRaoC0hmqStlNSBMRqPK9gbl78IDP5FVW173bEhD9BhIOUJQeqA2wimkZJkE_AjWeDrXQdWreMOCFy5wZuNYYGotHD0NLXVKdDdHHms4qWYhrVOc',
      'completedDate': '12 de Mayo, 2026',
      'finalPrice': '\$12.00/pieza',
      'quantity': '15 piezas',
    },
  ];

  static int get pendingReviewsCount => pendingReviews.length;

  @override
  State<MyReviewsScreen> createState() => _MyReviewsScreenState();
}

class _MyReviewsScreenState extends State<MyReviewsScreen> {
  int _selectedTabIndex = 0; // 0: Pendientes, 1: Completadas

  // Completed reviews state matching code.html
  final List<Map<String, dynamic>> _completedReviews = [
    {
      'productName': 'Cesta de Verduras Mixtas',
      'vendor': 'Huerta San Miguel',
      'timeAgo': 'Hace 2 semanas',
      'completedDate': '10 de Mayo, 2026',
      'finalPrice': '\$25.00/cesta',
      'quantity': '2 cestas',
      'rating': 5,
      'comment': 'Excelente calidad, todo muy fresco. Los pimientos estaban espectaculares y el empaque muy cuidadoso.',
      'productImageUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuCK1u8etbY5cHiRod_Fsz0_cuGTPBYf1Kj3M9WWtxHKJPGQ80EV82hmsmCV_Gt93yIiAAYRrHcpjpcGQvWY6oCOXHF5JcfmhpwXq5fj6OyrK4y_GaFvJgKHtBGGRbV3fH5b06o4tW0WeCL9448PUxQhHSfSX58eVK_lx7JUhms8WnRMbpDqcWul-oB60GyFZHNBDb6ouVvsT47SpGzBpuWhNyUDtZ7iBTFmBGB6DtwzTd28a4GMKjluGv3yihiGBfs1OZehh14Ktak',
      'userPhotoUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuDkExJjnogapAzYJSb7dQcgEWoBPwi2xrSMgswCUDDdVdRIXBZrVUKFDHMFPh8uh9DUS0PoOVg9IrZX3QGXegq2vzNujlg8qkX9oTAilz4-qbfjAC8xvPkNtl_X5ZFNpvFUAB6cbjL0rQECyadtUul-xcUGi73dT-_8e1Rr3QDvasFOTid1uiY8_3qwe0DHWwWnt-yKwa_USTLTgTbZYGYoRW7zLXOSazPfHD2Ouw_9Onw8CMHvzMiClYcBiFiabXucIHwkS4Ts75c',
      'producerReply': '¡Muchas gracias por tu comentario! Nos alegra mucho saber que disfrutaste la frescura de nuestra cosecha. Trabajamos con mucho cariño para que cada empaque llegue perfecto a tu mesa. - Huerta San Miguel',
    },
    {
      'productName': 'Aceite de Oliva Virgen Extra',
      'vendor': 'Olivar Los Cerezos',
      'timeAgo': 'Hace 1 mes',
      'completedDate': '28 de Abril, 2026',
      'finalPrice': '\$14.00/botella',
      'quantity': '5 botellas',
      'rating': 4,
      'comment': 'Muy buen sabor, intenso y con toques frutales. Ideal para ensaladas.',
      'productImageUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuCXVjjLbAdq-qPVQ_4K3NOYusCymD1EzqS1kC-Lo2r8QtaXyo5pkWNSGVhL5GRtQdbQGSokSKklmFZQkqOdUI4YyvMbTzXiN4AXEBPr5cPtwmDPhu-Xq-fe5DmDEQ7bb12IupTY6GlguVCGhQguSo9BlaDDC8cklW1Mk-PM8CK-6xz9XhSIfBgoT5YJi9nx55BRZ0yONRnrZSQ4Xft817qS_jLiuOtjEbCKVWGb-EVrUn1Ker8c_Z-DsulYXVud8E41W1UHegQnM4Q',
      'userPhotoUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuDP2SAhDf3xiSDi_M640MlgD1SQS_efXAy3Nge5f61w_PC0JqfPVQnJ_kzRN9OgQrCitc4c0LnJKeKKJHU00mVz4zapAJiBALXB2tF9-vkiIl8iYScPOcNMZwg2qMrHJfOf4och7hchrTrvSDLEMP3wTPctSP4iDgSaaRlygMLAx9hQgab4WuZ3LM2naJkAN4LC7H4CrZZrEyxehsOObIA6mq_8FYKPBB7xwkEQ9p6uL63m30AzftO3X0FNrF6k_45fChAU1ky479Y',
      'producerReply': null,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Emerald Harvest Colors
    const primaryGreen = Color(0xFF00462f);
    final bgColor = isDark ? const Color(0xFF0f231d) : const Color(0xFFf7faf5);
    final surfaceColor = isDark ? const Color(0xFF1c2c26) : Colors.white;
    final onSurfaceColor = isDark ? const Color(0xFFeef2ed) : const Color(0xFF181d1a);
    final secondaryTextColor = isDark ? const Color(0xFF89d6b0) : const Color(0xFF486456);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0f231d).withOpacity(0.8) : const Color(0xFFf7faf5),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Container(
          margin: const EdgeInsets.only(left: 12),
          child: Center(
            child: InkWell(
              onTap: () => context.pop(),
              borderRadius: BorderRadius.circular(99),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.02),
                ),
                child: Icon(
                  Icons.arrow_back,
                  color: isDark ? const Color(0xFF89d6b0) : primaryGreen,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
        title: Text(
          'MIS RESEÑAS',
          style: GoogleFonts.plusJakartaSans(
            color: isDark ? const Color(0xFF89d6b0) : primaryGreen,
            fontWeight: FontWeight.w800,
            fontSize: 16,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
            height: 1,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Section Banner
              _buildHeroSection(isDark),
              const SizedBox(height: 20),

              // Custom Segment Switcher
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1c2c26) : const Color(0xFFebefea),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedTabIndex = 0;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _selectedTabIndex == 0
                                ? (isDark ? const Color(0xFF121e1a) : Colors.white)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: _selectedTabIndex == 0
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.pending_actions_outlined,
                                  size: 16,
                                  color: _selectedTabIndex == 0
                                      ? (isDark ? const Color(0xFF89d6b0) : primaryGreen)
                                      : onSurfaceColor.withValues(alpha: 0.6),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Pendientes (${MyReviewsScreen.pendingReviews.length})',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: _selectedTabIndex == 0 ? FontWeight.w800 : FontWeight.w600,
                                    fontSize: 13,
                                    color: _selectedTabIndex == 0
                                        ? (isDark ? const Color(0xFF89d6b0) : primaryGreen)
                                        : onSurfaceColor.withValues(alpha: 0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedTabIndex = 1;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _selectedTabIndex == 1
                                ? (isDark ? const Color(0xFF121e1a) : Colors.white)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: _selectedTabIndex == 1
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.task_alt,
                                  size: 16,
                                  color: _selectedTabIndex == 1
                                      ? (isDark ? const Color(0xFF89d6b0) : primaryGreen)
                                      : onSurfaceColor.withValues(alpha: 0.6),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Completadas (${_completedReviews.length})',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: _selectedTabIndex == 1 ? FontWeight.w800 : FontWeight.w600,
                                    fontSize: 13,
                                    color: _selectedTabIndex == 1
                                        ? (isDark ? const Color(0xFF89d6b0) : primaryGreen)
                                        : onSurfaceColor.withValues(alpha: 0.6),
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
              ),
              const SizedBox(height: 20),

              // Tab views
              if (_selectedTabIndex == 0) ...[
                if (MyReviewsScreen.pendingReviews.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 48.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.rate_review_outlined,
                            size: 48,
                            color: Colors.grey.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '¡Al día! No tienes reseñas pendientes.',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.grey,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: MyReviewsScreen.pendingReviews.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = MyReviewsScreen.pendingReviews[index];
                      return _buildPendingCard(item, isDark, surfaceColor, onSurfaceColor, secondaryTextColor);
                    },
                  ),
              ] else ...[
                if (_completedReviews.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 48.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.star_outline,
                            size: 48,
                            color: Colors.grey.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No tienes reseñas completadas.',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.grey,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _completedReviews.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final item = _completedReviews[index];
                      return _buildCompletedCard(item, isDark, surfaceColor, onSurfaceColor, secondaryTextColor);
                    },
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(bool isDark) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF036042),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00462f).withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Opacity(
              opacity: 0.12,
              child: Container(
                width: 150,
                height: 150,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Colors.white, Colors.transparent],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'EVALÚA. IMPACTA.',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Tu voz construye una comunidad más fuerte y transparente.',
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFFa5f3cb),
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingCard(
    Map<String, dynamic> item,
    bool isDark,
    Color surfaceColor,
    Color onSurfaceColor,
    Color secondaryTextColor,
  ) {
    final primaryGreen = const Color(0xFF00462f);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              context.push('/product_detail', extra: {
                'name': item['productName'],
                'price': item['finalPrice']?.split('/')?.first ?? '\$1.80',
                'unit': item['finalPrice']?.split('/')?.last ?? 'kg',
                'image': item['imageUrl'] ?? item['productImageUrl'],
                'quality': 'Primera',
                'supplier': item['vendor'],
                'description': 'Producto fresco de alta calidad, cosechado con las mejores prácticas agrícolas y seleccionado rigurosamente para garantizar la satisfacción del cliente.',
              });
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                item['imageUrl'],
                width: 90,
                height: 90,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 90,
                  height: 90,
                  color: Colors.grey[350],
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['orderId'],
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: isDark ? const Color(0xFF89d6b0) : const Color(0xFF486456),
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    context.push('/product_detail', extra: {
                      'name': item['productName'],
                      'price': item['finalPrice']?.split('/')?.first ?? '\$1.80',
                      'unit': item['finalPrice']?.split('/')?.last ?? 'kg',
                      'image': item['imageUrl'] ?? item['productImageUrl'],
                      'quality': 'Primera',
                      'supplier': item['vendor'],
                      'description': 'Producto fresco de alta calidad, cosechado con las mejores prácticas agrícolas y seleccionado rigurosamente para garantizar la satisfacción del cliente.',
                    });
                  },
                  child: Text(
                    item['productName'],
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: onSurfaceColor,
                      decoration: TextDecoration.underline,
                      decorationColor: onSurfaceColor.withOpacity(0.3),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 2),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    context.push('/provider', extra: {
                      'name': item['vendor'],
                      'rating': '4.8',
                      'distance': 'A 5 km',
                      'tags': 'Frutas y Verduras Orgánicas',
                      'salesType': 'Al Detalle',
                      'img': 'https://eldinero.com.do/wp-content/uploads/mercados-productos-precios.jpg',
                      'banner': 'https://eldinero.com.do/wp-content/uploads/mercados-productos-precios.jpg',
                      'traded': '1,240 productos negociados',
                      'reviews': '120 reseñas de clientes',
                    });
                  },
                  child: Text(
                    item['vendor'],
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isDark ? const Color(0xFF89d6b0) : const Color(0xFF036042),
                    ),
                  ),
                ),
                
                // Metadata row: Completed Date, Quantity & Final Price
                const SizedBox(height: 6),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 11,
                        color: isDark ? const Color(0xFF89d6b0) : const Color(0xFF486456),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        item['completedDate'] ?? '24 de Mayo, 2026',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Dot separator
                      Container(
                        width: 3,
                        height: 3,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white30 : Colors.black38,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.shopping_bag_outlined,
                        size: 11,
                        color: isDark ? const Color(0xFF89d6b0) : const Color(0xFF486456),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${item['quantity'] ?? '150 kg'} • ${item['finalPrice'] ?? '\$1.80/kg'}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isDark ? const Color(0xFF89d6b0) : primaryGreen,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 32,
                  child: ElevatedButton(
                    onPressed: () => _showWriteReviewBottomSheet(item),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF036042),
                      foregroundColor: const Color(0xFFa5f3cb),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    child: Text(
                      'ESCRIBIR RESEÑA',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
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

  Widget _buildCompletedCard(
    Map<String, dynamic> item,
    bool isDark,
    Color surfaceColor,
    Color onSurfaceColor,
    Color secondaryTextColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1c2c26) : const Color(0xFFebefea),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.15 : 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Product image, title, vendor, stars
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  context.push('/product_detail', extra: {
                    'name': item['productName'],
                    'price': item['finalPrice']?.split('/')?.first ?? '\$1.80',
                    'unit': item['finalPrice']?.split('/')?.last ?? 'kg',
                    'image': item['productImageUrl'],
                    'quality': 'Primera',
                    'supplier': item['vendor'],
                    'description': 'Producto fresco de alta calidad, cosechado con las mejores prácticas agrícolas y seleccionado rigurosamente para garantizar la satisfacción del cliente.',
                  });
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    item['productImageUrl'],
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 48,
                      height: 48,
                      color: Colors.grey[300],
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
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        context.push('/product_detail', extra: {
                          'name': item['productName'],
                          'price': item['finalPrice']?.split('/')?.first ?? '\$1.80',
                          'unit': item['finalPrice']?.split('/')?.last ?? 'kg',
                          'image': item['productImageUrl'],
                          'quality': 'Primera',
                          'supplier': item['vendor'],
                          'description': 'Producto fresco de alta calidad, cosechado con las mejores prácticas agrícolas y seleccionado rigurosamente para garantizar la satisfacción del cliente.',
                        });
                      },
                      child: Text(
                        item['productName'],
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: onSurfaceColor,
                          decoration: TextDecoration.underline,
                          decorationColor: onSurfaceColor.withOpacity(0.3),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            context.push('/provider', extra: {
                              'name': item['vendor'],
                              'rating': '4.8',
                              'distance': 'A 5 km',
                              'tags': 'Frutas y Verduras Orgánicas',
                              'salesType': 'Al Detalle',
                              'img': 'https://eldinero.com.do/wp-content/uploads/mercados-productos-precios.jpg',
                              'banner': 'https://eldinero.com.do/wp-content/uploads/mercados-productos-precios.jpg',
                              'traded': '1,240 productos negociados',
                              'reviews': '120 reseñas de clientes',
                            });
                          },
                          child: Text(
                            item['vendor'],
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isDark ? const Color(0xFF89d6b0) : const Color(0xFF036042),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 3,
                          height: 3,
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white30 : Colors.black38,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          item['completedDate'] ?? item['timeAgo'],
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white70 : Colors.black87,
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
                    Icons.star,
                    size: 14,
                    color: index < item['rating']
                      ? const Color(0xFF036042)
                      : (isDark ? Colors.white12 : Colors.black12),
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Negotiation details ribbon: Quantity & Final Price
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF131e1a).withOpacity(0.5) : Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.shopping_bag_outlined,
                  size: 12,
                  color: isDark ? const Color(0xFF89d6b0) : const Color(0xFF036042),
                ),
                const SizedBox(width: 4),
                Text(
                  'Negociado: ${item['quantity'] ?? '150 kg'}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isDark ? const Color(0xFF89d6b0) : const Color(0xFF036042),
                  ),
                ),
                const Spacer(),
                Text(
                  'Precio Final: ${item['finalPrice'] ?? '\$1.80/kg'}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: isDark ? const Color(0xFF89d6b0) : const Color(0xFF036042),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // User review comment + image row
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF131e1a) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? Colors.white.withOpacity(0.03) : const Color(0xFFbec9c1).withOpacity(0.15),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item['userPhotoUrl'] != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item['userPhotoUrl'],
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 64,
                        height: 64,
                        color: Colors.grey[200],
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
                      color: onSurfaceColor.withOpacity(0.8),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Producer reply
          if (item['producerReply'] != null) ...[
            const SizedBox(height: 8),
            Container(
              margin: const EdgeInsets.only(left: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFcaead7).withOpacity(isDark ? 0.08 : 0.25),
                border: const Border(
                  left: BorderSide(
                    color: Color(0xFF00462f),
                    width: 4,
                  ),
                ),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.reply, size: 14, color: Color(0xFF00462f)),
                      const SizedBox(width: 6),
                      Text(
                        'RESPUESTA DEL PRODUCTOR',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF00462f),
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '"${item['producerReply']}"',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: isDark ? const Color(0xFFcaead7) : const Color(0xFF314c3f),
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

  void _showWriteReviewBottomSheet(Map<String, dynamic> item) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Dialog(
            elevation: 0,
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: WriteReviewDialogContent(
              item: item,
              onSubmitted: (rating, comment, photoAttached) {
                // Add simulated item to completed reviews
                setState(() {
                  _completedReviews.insert(0, {
                    'productName': item['productName'],
                    'vendor': item['vendor'],
                    'timeAgo': 'Ahora mismo',
                    'completedDate': item['completedDate'] ?? 'Ahora mismo',
                    'finalPrice': item['finalPrice'] ?? '\$1.80/kg',
                    'quantity': item['quantity'] ?? '150 kg',
                    'rating': rating,
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

                // Gorgeous Success feedback
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: const Color(0xFF036042),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle_outline, color: Colors.white),
                        const SizedBox(width: 12),
                        Text(
                          '¡Reseña publicada con éxito!',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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
  final void Function(int rating, String comment, bool photoAttached) onSubmitted;

  const WriteReviewDialogContent({
    super.key,
    required this.item,
    required this.onSubmitted,
  });

  @override
  State<WriteReviewDialogContent> createState() => _WriteReviewDialogContentState();
}

class _WriteReviewDialogContentState extends State<WriteReviewDialogContent> {
  int _localRating = 4;
  final _commentController = TextEditingController();
  bool _photoAttached = false; // Se inicia en falso para que el usuario experimente el flujo de agregar foto

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

  void _showPhotoSourceBottomSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFF89d6b0) : const Color(0xFF00462f);
    final surfaceColor = isDark ? const Color(0xFF1c2c26) : Colors.white;
    final onSurface = isDark ? const Color(0xFFeef2ed) : const Color(0xFF181d1a);

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
                width: 40,
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
                        setState(() {
                          _photoAttached = true;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: const Color(0xFF036042),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            content: Row(
                              children: [
                                const Icon(Icons.camera_alt, color: Colors.white),
                                const SizedBox(width: 12),
                                Text(
                                  'Foto tomada con la Cámara',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isDark ? Colors.white10 : Colors.black12,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.camera_alt_outlined, size: 32, color: primaryColor),
                            const SizedBox(height: 8),
                            Text(
                              'Cámara',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
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
                        setState(() {
                          _photoAttached = true;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: const Color(0xFF036042),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            content: Row(
                              children: [
                                const Icon(Icons.photo_library, color: Colors.white),
                                const SizedBox(width: 12),
                                Text(
                                  'Foto cargada desde Biblioteca',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isDark ? Colors.white10 : Colors.black12,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.photo_library_outlined, size: 32, color: primaryColor),
                            const SizedBox(height: 8),
                            Text(
                              'Biblioteca',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
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

    // Palette tokens from Emerald Harvest Design System
    final surfaceContainerLowest = isDark ? const Color(0xFF121e1a) : Colors.white;
    final surfaceContainerLow = isDark ? const Color(0xFF1c2c26) : const Color(0xFFf1f4f0);
    final onSurface = isDark ? const Color(0xFFeef2ed) : const Color(0xFF181d1a);
    final onSurfaceVariant = isDark ? const Color(0xFFbec9c1) : const Color(0xFF3f4943);
    final outlineVariant = isDark ? const Color(0xFF3e4c45) : const Color(0xFFbec9c1);

    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        color: surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFbec9c1).withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Escribir Reseña',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: onSurface,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                        ),
                        child: Icon(
                          Icons.close,
                          size: 18,
                          color: onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        widget.item['imageUrl'],
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 48,
                          height: 48,
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
                            widget.item['productName'],
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.item['vendor'],
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: onSurfaceVariant,
                              fontWeight: FontWeight.w500,
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

          // Body Section (Scrollable if Keyboard visible)
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rating Star Selector
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'TU CALIFICACIÓN',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w800,
                            fontSize: 10,
                            letterSpacing: 2.0,
                            color: onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (index) {
                            final isSelected = index < _localRating;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _localRating = index + 1;
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  transform: Matrix4.diagonal3Values(
                                    isSelected ? 1.05 : 0.95,
                                    isSelected ? 1.05 : 0.95,
                                    1.0,
                                  ),
                                  child: Icon(
                                    isSelected ? Icons.star_rounded : Icons.star_border_rounded,
                                    size: 44,
                                    color: isSelected ? const Color(0xFFFFB300) : outlineVariant,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFB300).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFFFFB300).withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star_rounded, size: 16, color: Color(0xFFFFB300)),
                              const SizedBox(width: 6),
                              Text(
                                '$_localRating.0 / 5.0 puntos',
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                  color: isDark ? const Color(0xFFFFD54F) : const Color(0xFFC49000),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Comment Input
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'TU COMENTARIO',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          fontSize: 10,
                          letterSpacing: 2.0,
                          color: onSurfaceVariant,
                        ),
                      ),
                      Text(
                        _commentController.text.length < 8
                            ? 'Mínimo 8 caracteres (${_commentController.text.length}/8)'
                            : 'Mínimo aceptado (${_commentController.text.length} caracteres)',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                          color: _commentController.text.length < 8
                              ? Colors.redAccent
                              : const Color(0xFF036042),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _commentController,
                    maxLines: 4,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Comparte tu experiencia con este producto...',
                      hintStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: onSurfaceVariant.withValues(alpha: 0.6),
                      ),
                      filled: true,
                      fillColor: surfaceContainerLow,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Add Photos
                  Text(
                    'AÑADIR FOTOS (OPCIONAL)',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                      fontSize: 10,
                      letterSpacing: 2.0,
                      color: onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      // Upload dashed button
                      GestureDetector(
                        onTap: () {
                          _showPhotoSourceBottomSheet(context);
                        },
                        child: CustomPaint(
                          painter: DashedBorderPainter(
                            color: outlineVariant,
                            borderRadius: 12,
                          ),
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: surfaceContainerLow,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_a_photo_outlined,
                                  color: onSurfaceVariant,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Uploaded Preview Card
                      if (_photoAttached)
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFbec9c1).withValues(alpha: 0.5),
                                  width: 1,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(11),
                                child: Image.network(
                                  'https://lh3.googleusercontent.com/aida-public/AB6AXuAmMGAtTpTPkjMWwNJsge_OEQkQcXikr1fQs3EOJW2BYd391R1uLWOWTIkZ8cEljuOwkk4YqdaAE82pvoOIhudKNFsD_XX3OL73RZW_WKVXeqRuxjY5ub9SYSyJ34AW6wJxJ7ScNjlu57HMiPKY936qyAOwuEPwk5R_3_agxbB-FTknORFByNpWC7WZi8LYUewfP6H55vJ3FzOI_xvehALO31NPZK7Ce2I3Qk3Qjb_ckJ598nAZXoMaG0P-stXcC9CranJTnBZhg_4',
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    color: Colors.grey[200],
                                    child: const Icon(Icons.broken_image),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: -4,
                              right: -4,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _photoAttached = false;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF1c2c26).withValues(alpha: 0.9) : Colors.white.withValues(alpha: 0.9),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.1),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.close,
                                    size: 12,
                                    color: onSurface,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Footer Actions Section
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFbec9c1).withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                    child: Text(
                      'Cancelar',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        letterSpacing: 2.0,
                        color: onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final comment = _commentController.text.trim();
                      if (comment.length < 8) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            content: Text(
                              'El comentario es obligatorio (mínimo 8 caracteres).',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                        return;
                      }

                      widget.onSubmitted(_localRating, comment, _photoAttached);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF036042),
                      foregroundColor: const Color(0xFFcaead7),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                    child: Text(
                      'Enviar Reseña',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        letterSpacing: 2.0,
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

class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;
  final double dashLength;
  final double borderRadius;

  DashedBorderPainter({
    required this.color,
    this.strokeWidth = 2,
    this.gap = 4,
    this.dashLength = 6,
    this.borderRadius = 12,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(borderRadius),
      ));

    final dashPath = Path();
    double distance = 0.0;

    for (final pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        dashPath.addPath(
          pathMetric.extractPath(distance, distance + dashLength),
          Offset.zero,
        );
        distance += dashLength + gap;
      }
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

