import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProductReviewsModal extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductReviewsModal({super.key, required this.product});

  // Dummy data based on the HTML design
  static const List<Map<String, dynamic>> dummyReviews = [
    {
      'name': 'María Carmen',
      'initials': 'MC',
      'date': 'Hace 2 días',
      'rating': 5,
      'text': '¡Excelente calidad! Los tomates llegaron súper frescos, firmes y con un color rojo intenso perfecto. Ideales para la salsa de esta semana. El empaque era muy cuidadoso, ninguno llegó magullado.',
      'photos': [
        'https://lh3.googleusercontent.com/aida-public/AB6AXuAk40y-DwhzVYC4aH3Ab_K3ftuMM_eO_ChnQ2vA7poNAd-Ol88xMBAihSNk8BbPHHzrWuZXyJp53lPInseqzR68oyLfHNvPaZxKFU2qGUlc2v8naK5poM36lmo59_6auKmUQaU-kqbF35h11A14WdMnUdgjmdWEcC36SxzfGFhEqP9TaVhbXu89Wg7_5rIys_HkJHT99td0cZ3smjT2rIygT6dvXjFnfI8Llg_wwf94RaYafiuMaspaYY-EqGffi_aCF_ZifimxP0U',
        'https://lh3.googleusercontent.com/aida-public/AB6AXuA2Zi-1kfWw_29Mda2e9X9V5jsjUhWoM8w4_BoFjtLeNO6aldK4DuWHM51N_SHK1DkWapcvI3wbPP9lu4beVcs6SccGvtwv6nHSboZsvrc-Zx-ohIy0UM2XqXL9F08GkWukY6ha5bxHJov0eua7KXosqVUVa1b8BsV2NygSDv1gN1FERAjbm_dyVso5k9Rz5PQ_6c7pThasZ3jVacTKzzTHMEqMt7a98Nb4mQeQO5VdwyT9xCYJQQpzgJ1C4Qr8jd1h2HUTqBux1P4'
      ],
      'farmerResponse': {
        'name': 'Finca El Sol (Vendedor)',
        'text': '¡Muchas gracias María! Nos alegra saber que llegaron en perfectas condiciones. Cosechamos justo la mañana del envío para garantizar esa frescura. ¡Esperamos su próximo pedido!'
      }
    },
    {
      'name': 'Juan López',
      'initials': 'JL',
      'date': 'Hace 1 semana',
      'rating': 4,
      'text': 'Muy buen sabor, aunque algunos estaban un poco más verdes de lo que esperaba. Aún así, duraron bastante en casa y maduraron bien.',
    }
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Colors mapping based on the design
    final Color bgColor = isDark ? const Color(0xFF1f2937) : Colors.white; // surface-container-lowest
    final Color headerColor = isDark ? Colors.white : const Color(0xFF181d1a); // on-surface
    final Color subtitleColor = isDark ? Colors.grey[400]! : const Color(0xFF3f4943); // on-surface-variant
    final Color primaryColor = theme.colorScheme.primary; // #00462f
    final Color dividerColor = isDark ? Colors.grey[800]! : const Color(0xFFe6e9e4); // surface-container-high
    final Color avatarBgColor = isDark ? const Color(0xFF2d4a3e) : const Color(0xFFcaead7); // secondary-container
    final Color avatarTextColor = isDark ? Colors.white : const Color(0xFF4e6b5b); // on-secondary-container
    final Color responseBgColor = isDark ? Colors.grey[850]! : const Color(0xFFf1f4f0); // surface-container-low
    const Color starColor = Color(0xFFFFB300);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: dividerColor)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reseñas del Producto',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: headerColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product['name'] ?? 'Producto',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: subtitleColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          ...List.generate(5, (index) {
                            if (index < 4) {
                              return const Icon(Icons.star, color: starColor, size: 20);
                            } else {
                              return const Icon(Icons.star_half, color: starColor, size: 20);
                            }
                          }),
                          const SizedBox(width: 8),
                          Text(
                            '4.8 (124)',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: headerColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: subtitleColor),
                  style: IconButton.styleFrom(
                    backgroundColor: isDark ? Colors.grey[800] : const Color(0xFFf1f4f0),
                  ),
                ),
              ],
            ),
          ),

          // Scrollable Content
          Flexible(
            child: ListView.separated(
              padding: const EdgeInsets.all(24),
              itemCount: dummyReviews.length,
              separatorBuilder: (context, index) => const SizedBox(height: 32),
              itemBuilder: (context, index) {
                final review = dummyReviews[index];
                return _buildReviewItem(
                  context: context,
                  review: review,
                  headerColor: headerColor,
                  subtitleColor: subtitleColor,
                  primaryColor: primaryColor,
                  starColor: starColor,
                  avatarBgColor: avatarBgColor,
                  avatarTextColor: avatarTextColor,
                  responseBgColor: responseBgColor,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem({
    required BuildContext context,
    required Map<String, dynamic> review,
    required Color headerColor,
    required Color subtitleColor,
    required Color primaryColor,
    required Color starColor,
    required Color avatarBgColor,
    required Color avatarTextColor,
    required Color responseBgColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // User info row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: avatarBgColor,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    review['initials'],
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.bold,
                      color: avatarTextColor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review['name'],
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: headerColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: List.generate(5, (starIndex) {
                        final isFilled = starIndex < (review['rating'] as int);
                        return Icon(
                          isFilled ? Icons.star : Icons.star_border,
                          color: starColor,
                          size: 14,
                        );
                      }),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
            Text(
              review['date'],
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: subtitleColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Review text
        Text(
          review['text'],
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: subtitleColor,
            height: 1.5,
          ),
        ),
        
        // Photos
        if (review.containsKey('photos')) ...[
          const SizedBox(height: 16),
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: (review['photos'] as List).length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, photoIndex) {
                final photoUrl = review['photos'][photoIndex];
                return ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: photoUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(color: Colors.grey[200]),
                    errorWidget: (context, url, error) => Container(color: Colors.grey[200], child: const Icon(Icons.error)),
                  ),
                );
              },
            ),
          ),
        ],

        // Farmer Response
        if (review.containsKey('farmerResponse')) ...[
          const SizedBox(height: 16),
          Container(
            margin: const EdgeInsets.only(left: 32),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: responseBgColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.agriculture, color: primaryColor, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      review['farmerResponse']['name'],
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: headerColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  review['farmerResponse']['text'],
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: subtitleColor,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
