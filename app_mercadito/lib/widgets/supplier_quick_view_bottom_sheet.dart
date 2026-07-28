import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SupplierQuickViewBottomSheet extends StatelessWidget {
  final Map<String, dynamic> supplierData;

  const SupplierQuickViewBottomSheet({super.key, required this.supplierData});

  // Dummy featured products based on HTML design
  static const List<Map<String, dynamic>> featuredProducts = [
    {
      'name': 'Maíz Blanco',
      'price': 12,
      'unit': 'kg',
      'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuDmQwv1aTvCJ-qfJfyOZyMCxpz90bwV5XlszqTYsncYlE6MhCQ3kjtz70vSIn1racv5fi1y9-7F3HY85dccCKmMuYaJ-1bhvjAH7K4-3JsDeQKjDU02gTJOtMOD2iktmFztjlLPvKbBH78KmP4ouU5J3Aeo9MV0lSl2_73B2PNWhPzDORgSUwk-AEfdKC-KDlyEEqy8CTrF1EDj_Fy4cShdhVWNMIyE6_kcqQzYcmSN77BvvIiLUHGT5WE4sWXwNKlVotVkwCfUxIA',
    },
    {
      'name': 'Aguacate Hass',
      'price': 45,
      'unit': 'kg',
      'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuBhEr9RHMJwPOJZ4RklPWTnOCW7iZ6NU7v-2JnRL2Y0M2ryaHeuWa2b6SluXxohtIkkogBMWg_GtMnZlTBzsXih64T4qfreQ1Y4OcL6qR5ocx3HJkYC0ssRNn7fVEVwMDtb7Ib6ObxfLpmw2nGqQ3v4i9jP4lXCvwg48HPUfhdh0fDK2ooLxPhevvGCUYnGiis47gNQBHqWVOmWOWHPMRqOU24O0YLZhVZAYkRnsmkgnb6tGmFDEDBYt-0QiBua7qzJ0RL4pjVBGMw',
    },
    {
      'name': 'Tomate Saladet',
      'price': 28,
      'unit': 'kg',
      'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuCZHPoy_U2Qp4yGUDfzMGTMf-v2CYiCreYorvFrVwa290XphD8f7gmwI6d5Hy_xgQXAajrk38LgMCspAITjQzmCWO2hsryNuqyYtQP_NIID4KCEF8MA1ycGb65XwddxAUhuBQMtw-Sz3XV852IwxFvx7PTTG4zh3mF_l7gEBZ7Vcv7cumYJFJ4gwxxWHMb5z32n5dlCf3GdNGCR2h_q2OrLj5a9Bt2Cem0CP7FvoBNM2Cjk_h4QtNssswmWJOhmqQzs5vOhN5EKCoY',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;
    
    final Color bgColor = isDark ? const Color(0xFF1c2c26) : Colors.white;
    final Color surfaceColor = isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFf1f4f0);
    final Color textColor = isDark ? Colors.white : const Color(0xFF181d1a);
    final Color subTextColor = isDark ? Colors.white70 : const Color(0xFF3f4943);

    return Container(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 32),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Background with Close Button
          Container(
            height: 80,
            width: double.infinity,
            decoration: BoxDecoration(
              color: primary.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 16,
                  right: 16,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, size: 20),
                    style: IconButton.styleFrom(
                      backgroundColor: bgColor.withOpacity(0.8),
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.black12,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Profile Image Area (Overlapping)
          Transform.translate(
            offset: const Offset(0, -40),
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: bgColor, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: (supplierData['img'] != null && supplierData['img'].toString().isNotEmpty && supplierData['img'].toString().startsWith('http'))
                            ? CachedNetworkImage(
                                imageUrl: supplierData['img'],
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: isDark ? const Color(0xFF1a2f26) : const Color(0xFFebefea),
                                  child: Icon(Icons.storefront, size: 48, color: isDark ? const Color(0xFF89d6b0) : const Color(0xFF00462f)),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: isDark ? const Color(0xFF1a2f26) : const Color(0xFFebefea),
                                  child: Icon(Icons.storefront, size: 48, color: isDark ? const Color(0xFF89d6b0) : const Color(0xFF00462f)),
                                ),
                              )
                            : (supplierData['image'] != null && supplierData['image'].toString().isNotEmpty && supplierData['image'].toString().startsWith('http'))
                                ? CachedNetworkImage(
                                    imageUrl: supplierData['image'],
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      color: isDark ? const Color(0xFF1a2f26) : const Color(0xFFebefea),
                                      child: Icon(Icons.storefront, size: 48, color: isDark ? const Color(0xFF89d6b0) : const Color(0xFF00462f)),
                                    ),
                                    errorWidget: (context, url, error) => Container(
                                      color: isDark ? const Color(0xFF1a2f26) : const Color(0xFFebefea),
                                      child: Icon(Icons.storefront, size: 48, color: isDark ? const Color(0xFF89d6b0) : const Color(0xFF00462f)),
                                    ),
                                  )
                                : Container(
                                    color: isDark ? const Color(0xFF1a2f26) : const Color(0xFFebefea),
                                    child: Icon(Icons.storefront, size: 48, color: isDark ? const Color(0xFF89d6b0) : const Color(0xFF00462f)),
                                  ),
                      ),
                    ),
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: bgColor, width: 2),
                        ),
                        child: const Icon(Icons.verified, color: Colors.white, size: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Name & Hacienda
                Text(
                  'Ricardo Mendoza',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
                Text(
                  'Hacienda Los Volcanes',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: primary,
                  ),
                ),
                const SizedBox(height: 24),

                // Stats Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatColumn('4.9', 'Rating', Icons.star, Colors.amber, textColor),
                      _buildDivider(),
                      _buildStatColumn('Texcoco, MX', 'Location', Icons.location_on, subTextColor, textColor),
                      _buildDivider(),
                      _buildStatColumn('1.2k', 'Followers', null, null, textColor),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Bio
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'Specialist in premium white corn and organic vegetables. 5 years of experience delivering fresh harvest to your table.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: subTextColor,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Featured Harvest
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'COSECHA DESTACADA',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                          color: isDark ? Colors.white38 : Colors.black38,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 140,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        scrollDirection: Axis.horizontal,
                        itemCount: featuredProducts.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final product = featuredProducts[index];
                          return Container(
                            width: 120,
                            decoration: BoxDecoration(
                              color: surfaceColor,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                  child: CachedNetworkImage(
                                    imageUrl: product['image'],
                                    height: 80,
                                    width: 120,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product['name'],
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: textColor,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: '\$${product['price']} ',
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w900,
                                                color: primary,
                                              ),
                                            ),
                                            TextSpan(
                                              text: '/ ${product['unit']}',
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 9,
                                                color: subTextColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Actions
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: primary),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            'VER PERFIL',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                              letterSpacing: 1.5,
                              color: primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'CONTACTAR',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                              letterSpacing: 1.5,
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
        ],
      ),
    );
  }

  Widget _buildStatColumn(String value, String label, IconData? icon, Color? iconColor, Color textColor) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: iconColor,),
              const SizedBox(width: 4),
            ],
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label.toUpperCase(),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 8,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 20,
      width: 1,
      color: Colors.black.withOpacity(0.05),
    );
  }
}
