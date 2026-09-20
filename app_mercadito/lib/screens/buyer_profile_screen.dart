import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../data/global_state.dart';
import '../services/reviews_service.dart';
import '../services/buyer_behavior_service.dart';
import '../widgets/animated_favorite_button.dart';
import '../widgets/report_user_bottom_sheet.dart';
import 'direct_profile_review_screen.dart';

const Color _primaryGreen = Color(0xFF016042);

class BuyerProfileScreen extends StatefulWidget {
  final Map<String, dynamic> buyer;

  const BuyerProfileScreen({
    super.key,
    required this.buyer,
  });

  @override
  State<BuyerProfileScreen> createState() => _BuyerProfileScreenState();
}

class _BuyerProfileScreenState extends State<BuyerProfileScreen> {
  int _commentsCurrentPage = 1;
  final Set<String> _expandedReviewIds = <String>{};

  String _formatReviewDate(DateTime dt) {
    const months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    final day = dt.day.toString().padLeft(2, '0');
    final month = months[dt.month - 1];
    final year = dt.year;
    return '$day $month $year';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final buyer = widget.buyer;
    final buyerId = (buyer['id'] ?? 'BUY-88291').toString();
    final buyerName = (buyer['name'] ?? 'Comprador').toString();
    final buyerAvatar = buyer['avatar'] as String?;
    final location = (buyer['location'] ?? 'Ubicación no especificada').toString();
    final sector = (buyer['sector'] ?? '').toString().trim().isNotEmpty
        ? buyer['sector'].toString().trim()
        : (location.contains('•') ? location.split('•').last.trim() : location);
    final distance = (buyer['distance'] ?? 'Cercano').toString();
    final businessType = (buyer['businessType'] ?? 'Comprador Mayorista / Detallista').toString();
    final memberSince = (buyer['memberSince'] ?? 'Enero 2023').toString();
    final rating = (buyer['rating'] ?? 4.9).toString();
    final negotiationsCount = buyer['negotiationsCount'] ?? 15;
    final reviewsCount = (buyer['reviewsCount'] ?? buyer['totalReviews'] ?? 198).toString();

    // Colores del sistema de diseño Esmeralda
    const primaryGreen = _primaryGreen;
    final bgColor = isDark ? const Color(0xFF0F1713) : const Color(0xFFF7FAF7);
    final cardColor = isDark ? const Color(0xFF16231D) : Colors.white;
    final borderColor = isDark ? const Color(0xFF22382E) : const Color(0xFFE2E8F0);

    // Criterios de reputación directa
    final scores = ReviewsService.getBuyerReputation(buyerId);

    // 5. Preferencias de compra calculadas algorítmicamente (mediana, confianza, modalidad, ranking)
    final behaviorProfile = BuyerBehaviorService.instance.calculateProfile(buyerId, fallbackData: buyer);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? const Color(0xFF89d6b0) : primaryGreen),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Perfil de Comprador',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: ValueListenableBuilder<List<Map<String, dynamic>>>(
              valueListenable: globalFavoriteBuyers,
              builder: (context, favorites, _) {
                final isFav = isFavoriteBuyer(buyerId) || isFavoriteBuyer(buyerName);
                return Center(
                  child: AnimatedFavoriteButton(
                    isFavorite: isFav,
                    size: 22,
                    backgroundColor: isDark ? const Color(0xFF16231D) : Colors.white,
                    onTap: () {
                      toggleFavoriteBuyer(buyer);
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: isFav ? const Color(0xFF334155) : primaryGreen,
                          content: Row(
                            children: [
                              Icon(
                                isFav ? Icons.favorite_border_rounded : Icons.favorite_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isFav
                                    ? '$buyerName eliminado de tus compradores favoritos'
                                    : '$buyerName agregado a tus compradores favoritos',
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Tarjeta Principal de Identidad
            _buildHeroIdentityCard(
              context: context,
              buyer: buyer,
              buyerId: buyerId,
              buyerName: buyerName,
              buyerAvatar: buyerAvatar,
              location: location,
              distance: distance,
              businessType: businessType,
              memberSince: memberSince,
              cardColor: cardColor,
              borderColor: borderColor,
              isDark: isDark,
              primaryGreen: primaryGreen,
            ),
            const SizedBox(height: 14),

            // 2. Métricas Clave (Reseñas, Calificación y Negociaciones)
            _buildMetricsRow(
              negotiationsCount: negotiationsCount,
              rating: rating,
              reviewsCount: reviewsCount,
              cardColor: cardColor,
              borderColor: borderColor,
              isDark: isDark,
              primaryGreen: primaryGreen,
            ),
            const SizedBox(height: 16),

            // 3. Sección: ¿Cómo lo califican los proveedores? (Reputación)
            _buildBuyerReputationCard(
              context: context,
              buyerId: buyerId,
              buyerName: buyerName,
              scores: scores,
              rating: rating,
              cardColor: cardColor,
              borderColor: borderColor,
              isDark: isDark,
              primaryGreen: primaryGreen,
            ),
            const SizedBox(height: 16),

            // 4. Comentarios de Proveedores
            _buildProviderCommentsSection(
              buyerId: buyerId,
              cardColor: cardColor,
              borderColor: borderColor,
              isDark: isDark,
              primaryGreen: primaryGreen,
            ),
            const SizedBox(height: 16),

            // 5. Preferencias de Compra y Productos Frecuentes
            _buildPurchasePreferencesCard(
              context: context,
              profile: behaviorProfile,
              cardColor: cardColor,
              borderColor: borderColor,
              isDark: isDark,
              primaryGreen: primaryGreen,
            ),
            const SizedBox(height: 16),

            // 6. Historial de Negociaciones
            _buildOrderHistorySection(
              context: context,
              buyer: widget.buyer,
              cardColor: cardColor,
              borderColor: borderColor,
              isDark: isDark,
              primaryGreen: primaryGreen,
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton.icon(
                onPressed: () {
                  ReportUserBottomSheet.show(
                    context: context,
                    reportedId: buyerId,
                    reportedName: buyerName,
                    reportedRole: 'comprador',
                    reportedAvatar: buyerAvatar ?? '',
                    reportedLocation: sector,
                  );
                },
                icon: const Icon(Icons.report_outlined, size: 16, color: Colors.grey),
                label: const Text(
                  'REPORTAR COMPRADOR',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: Colors.grey,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroIdentityCard({
    required BuildContext context,
    required Map<String, dynamic> buyer,
    required String buyerId,
    required String buyerName,
    required String? buyerAvatar,
    required String location,
    required String distance,
    required String businessType,
    required String memberSince,
    required Color cardColor,
    required Color borderColor,
    required bool isDark,
    required Color primaryGreen,
  }) {
    final rawLevel = buyer['level'] ?? buyer['prestigeLevel'];
    String buyerLevel;
    if (rawLevel != null && rawLevel.toString().trim().isNotEmpty) {
      final lvl = rawLevel.toString().trim();
      buyerLevel = lvl.toLowerCase().startsWith('nivel') ? lvl : 'Nivel $lvl';
    } else {
      final rawNeg = buyer['negotiationsCount'] ?? buyer['negotiations_count'] ?? buyer['dealsCount'] ?? 15;
      final count = int.tryParse(rawNeg.toString()) ?? 15;
      if (count >= 25) {
        buyerLevel = 'Nivel 4';
      } else if (count >= 12) {
        buyerLevel = 'Nivel 3';
      } else if (count >= 5) {
        buyerLevel = 'Nivel 2';
      } else {
        buyerLevel = 'Nivel 1';
      }
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar con badge flotante de verificación
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: primaryGreen.withValues(alpha: 0.25), width: 3),
                      color: primaryGreen.withValues(alpha: 0.1),
                    ),
                    child: ClipOval(
                      child: (buyerAvatar != null && buyerAvatar.isNotEmpty)
                          ? Image.network(
                              buyerAvatar,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(
                                Icons.person,
                                size: 40,
                                color: _primaryGreen,
                              ),
                            )
                          : const Icon(
                              Icons.person,
                              size: 40,
                              color: _primaryGreen,
                            ),
                    ),
                  ),
                  Positioned(
                    bottom: -2,
                    right: -2,
                    child: Container(
                      padding: const EdgeInsets.all(3.5),
                      decoration: BoxDecoration(
                        color: primaryGreen,
                        shape: BoxShape.circle,
                        border: Border.all(color: cardColor, width: 2),
                      ),
                      child: const Icon(Icons.verified, size: 14, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),

              // Nombre, ID, Tipo de negocio
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            buyerName,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF0F231D) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: borderColor),
                          ),
                          child: Text(
                            buyerId.startsWith('#') ? buyerId : '#$buyerId',
                            style: TextStyle(
                              fontFamily: 'Courier',
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isDark ? const Color(0xFF89d6b0) : primaryGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 14, color: isDark ? const Color(0xFF89d6b0) : primaryGreen),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            (buyer['sector'] ?? '').toString().trim().isNotEmpty
                                ? buyer['sector'].toString().trim()
                                : (location.contains('•') ? location.split('•').last.trim() : location),
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.grey[400] : Colors.grey[700],
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
          const SizedBox(height: 14),

          // Badges de Confianza
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _buildTrustPill(
                icon: Icons.verified_user_rounded,
                text: 'Comprador Verificado',
                bgColor: isDark ? const Color(0xFF0F231D) : const Color(0xFFECFDF5),
                textColor: const Color(0xFF065F46),
                borderColor: const Color(0xFF10B981).withValues(alpha: 0.3),
              ),
              _buildTrustPill(
                icon: Icons.military_tech_rounded,
                text: buyerLevel,
                bgColor: isDark ? const Color(0xFF262012) : const Color(0xFFFEF3C7),
                textColor: isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309),
                borderColor: isDark ? const Color(0xFF624A1D) : const Color(0xFFFCD34D),
              ),
              _buildTrustPill(
                icon: Icons.calendar_month_outlined,
                text: 'Cliente desde $memberSince',
                bgColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                textColor: isDark ? Colors.grey[300]! : Colors.grey[700]!,
                borderColor: borderColor,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Botones de Acción para Proveedores
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: primaryGreen,
                        content: Text('Iniciando chat comercial con $buyerName...'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                  label: const Text('Iniciar Chat'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: primaryGreen,
                        content: Text('Generando propuesta de negociación para $buyerName...'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.send_rounded, size: 16),
                  label: const Text('Enviar Oferta'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isDark ? const Color(0xFF89d6b0) : primaryGreen,
                    side: BorderSide(color: isDark ? const Color(0xFF89d6b0) : primaryGreen, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrustPill({
    required IconData icon,
    required String text,
    required Color bgColor,
    required Color textColor,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.5, color: textColor),
          const SizedBox(width: 4.5),
          Text(
            text,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsRow({
    required dynamic negotiationsCount,
    required String rating,
    required String reviewsCount,
    required Color cardColor,
    required Color borderColor,
    required bool isDark,
    required Color primaryGreen,
  }) {
    final theme = Theme.of(context);
    return Row(
      children: [
        _buildStatBox(
          reviewsCount,
          'RESEÑAS',
          theme,
          isDark,
          cardColor,
          borderColor: borderColor,
        ),
        const SizedBox(width: 8),
        _buildStatBox(
          rating,
          'CALIFICACIÓN',
          theme,
          isDark,
          cardColor,
          borderColor: borderColor,
          isRating: true,
        ),
        const SizedBox(width: 8),
        _buildStatBox(
          '$negotiationsCount',
          'NEGOCIACIONES',
          theme,
          isDark,
          cardColor,
          borderColor: borderColor,
          onTap: () => context.push('/order-history', extra: widget.buyer),
        ),
      ],
    );
  }

  Widget _buildStatBox(
    String value,
    String label,
    ThemeData theme,
    bool isDark,
    Color cardColor, {
    Color? borderColor,
    bool isRating = false,
    VoidCallback? onTap,
  }) {
    final border = borderColor ?? (isDark ? Colors.grey[800]! : Colors.grey[200]!);
    final double ratingVal = double.tryParse(value) ?? 4.5;

    final content = Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          if (!isRating)
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(width: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, size: 12, color: Color(0xFF00C853)),
                    const Icon(Icons.star, size: 12, color: Color(0xFF00C853)),
                    Icon(
                      ratingVal >= 4.8 ? Icons.star : Icons.star_half,
                      size: 12,
                      color: const Color(0xFF00C853),
                    ),
                  ],
                ),
              ],
            ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return Expanded(
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: content,
        ),
      );
    }
    return Expanded(child: content);
  }

  Widget _buildBuyerReputationCard({
    required BuildContext context,
    required String buyerId,
    required String buyerName,
    required Map<String, double> scores,
    required String rating,
    required Color cardColor,
    required Color borderColor,
    required bool isDark,
    required Color primaryGreen,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header de Reputación
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: primaryGreen.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.handshake_rounded, color: _primaryGreen, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '¿Cómo lo califican los proveedores?',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          Text(
                            'Evaluación directa basada en acuerdos',
                            style: TextStyle(
                              fontSize: 10.5,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
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
          const SizedBox(height: 14),

          // Banner de Puntuación General
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F231D) : const Color(0xFFE8F6F0),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: primaryGreen.withValues(alpha: 0.15)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        rating,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: isDark ? const Color(0xFF89d6b0) : primaryGreen,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: List.generate(
                                5,
                                (i) => const Icon(Icons.star_rounded, size: 14, color: Color(0xFFF2A439)),
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Comprador ejemplar y confiable',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  '98% satisfacción',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF016042),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 6 Criterios de Evaluación (Misma tipografía y disposición horizontal que en perfil de proveedor)
          _buildCriteriaScoreRow('Comunicación', scores['Comunicación'] ?? 4.9, isDark, primaryGreen),
          _buildCriteriaScoreRow('Puntualidad', scores['Puntualidad'] ?? 4.7, isDark, primaryGreen),
          _buildCriteriaScoreRow('Cumplimiento del acuerdo', scores['Cumplimiento del acuerdo'] ?? (scores['Cumplimiento'] ?? 4.8), isDark, primaryGreen),
          _buildCriteriaScoreRow('Cumplimiento de pago', scores['Cumplimiento de pago'] ?? (scores['Pago'] ?? 4.9), isDark, primaryGreen),
          _buildCriteriaScoreRow('Seriedad en la compra', scores['Seriedad en la compra'] ?? (scores['Trato'] ?? 5.0), isDark, primaryGreen),
          _buildCriteriaScoreRow('Comportamiento general', scores['Comportamiento general'] ?? (scores['Trato'] ?? 4.9), isDark, primaryGreen),
          const SizedBox(height: 14),

          // Botón Calificar Comprador
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => DirectProfileReviewScreen(
                      targetRole: 'comprador',
                      targetId: buyerId,
                      targetName: buyerName,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.rate_review_outlined, size: 16),
              label: const Text('Calificar Comprador'),
              style: OutlinedButton.styleFrom(
                foregroundColor: isDark ? const Color(0xFF89d6b0) : primaryGreen,
                side: BorderSide(color: isDark ? const Color(0xFF89d6b0) : primaryGreen, width: 1.2),
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCriteriaScoreRow(String label, double score, bool isDark, Color primaryGreen) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.5),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 11,
                color: isDark ? Colors.grey[300] : Colors.grey[700],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 4,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: (score / 5.0).clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: isDark ? Colors.white10 : Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  isDark ? const Color(0xFF10B981) : primaryGreen,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 24,
            child: Text(
              score.toStringAsFixed(1),
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderCommentsSection({
    required String buyerId,
    required Color cardColor,
    required Color borderColor,
    required bool isDark,
    required Color primaryGreen,
  }) {
    return ValueListenableBuilder<int>(
      valueListenable: ReviewsService.instance.reviewsRevision,
      builder: (context, revision, child) {
        final directReviews = ReviewsService.instance
            .getDirectReviewsForTarget(buyerId)
            .where((r) => r.comment.trim().isNotEmpty)
            .toList();

        const int pageSize = 5;
        final totalReviews = directReviews.length;
        final totalPages = (totalReviews / pageSize).ceil().clamp(1, 9999);
        final clampedPage = _commentsCurrentPage.clamp(1, totalPages);
        final startIndex = (clampedPage - 1) * pageSize;
        final pageReviews = directReviews.skip(startIndex).take(pageSize).toList();

        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.reviews_outlined, size: 18, color: primaryGreen),
                  const SizedBox(width: 8),
                  Text(
                    'Comentarios de Proveedores',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '($totalReviews)',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (directReviews.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Center(
                    child: Text(
                      'Aún no hay comentarios registrados para este comprador.',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ),
                )
              else ...[
                ...pageReviews.map((rev) {
                  final isExpanded = _expandedReviewIds.contains(rev.id);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F231D) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: borderColor.withValues(alpha: 0.6)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header de la reseña: Avatar, Nombre + Verificado, Fecha, Calificación
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: primaryGreen.withValues(alpha: 0.15),
                              backgroundImage: (rev.authorAvatar != null && rev.authorAvatar!.isNotEmpty)
                                  ? NetworkImage(rev.authorAvatar!)
                                  : null,
                              child: (rev.authorAvatar == null || rev.authorAvatar!.isEmpty)
                                  ? Text(
                                      rev.authorName.isNotEmpty ? rev.authorName[0] : 'P',
                                      style: const TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: _primaryGreen,
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          rev.authorName,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontFamily: 'Plus Jakarta Sans',
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.bold,
                                            color: isDark ? Colors.white : Colors.black87,
                                          ),
                                        ),
                                      ),
                                      if (rev.authorIsVerified) ...[
                                        const SizedBox(width: 4),
                                        const Icon(Icons.verified, size: 14, color: _primaryGreen),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _formatReviewDate(rev.createdAt),
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 10,
                                      color: isDark ? Colors.grey[400] : Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF8E3),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFFF3AF43)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.star_rounded, size: 12, color: Color(0xFFF2A439)),
                                  const SizedBox(width: 2),
                                  Text(
                                    rev.averageScore.toStringAsFixed(1),
                                    style: const TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFF2A439),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Comentario en Plus Jakarta Sans
                        Text(
                          '“${rev.comment}”',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 12,
                            color: isDark ? Colors.grey[300] : Colors.grey[800],
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Botón desplegable para ver desglose de calificación
                        InkWell(
                          onTap: () {
                            setState(() {
                              if (_expandedReviewIds.contains(rev.id)) {
                                _expandedReviewIds.remove(rev.id);
                              } else {
                                _expandedReviewIds.add(rev.id);
                              }
                            });
                          },
                          borderRadius: BorderRadius.circular(6),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  isExpanded ? 'Ocultar desglose' : 'Ver detalle de calificación',
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? const Color(0xFF89d6b0) : primaryGreen,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                                  size: 16,
                                  color: isDark ? const Color(0xFF89d6b0) : primaryGreen,
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Desglose de criterios calificados por este proveedor
                        if (isExpanded && rev.scores.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.black.withValues(alpha: 0.25) : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: borderColor.withValues(alpha: 0.6)),
                            ),
                            child: Column(
                              children: rev.scores.entries.map((entry) {
                                return _buildCriteriaScoreRow(entry.key, entry.value, isDark, primaryGreen);
                              }).toList(),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }),

                // Controles de Paginación (5 comentarios por página)
                if (totalPages > 1) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton.icon(
                        onPressed: clampedPage > 1
                            ? () {
                                setState(() {
                                  _commentsCurrentPage = clampedPage - 1;
                                });
                              }
                            : null,
                        icon: const Icon(Icons.chevron_left_rounded, size: 16),
                        label: const Text(
                          'Anterior',
                          style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 11),
                        ),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 32),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          foregroundColor: isDark ? const Color(0xFF89d6b0) : primaryGreen,
                          side: BorderSide(
                            color: (clampedPage > 1)
                                ? (isDark ? const Color(0xFF89d6b0) : primaryGreen)
                                : Colors.grey.withValues(alpha: 0.3),
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      Text(
                        'Página $clampedPage de $totalPages',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: clampedPage < totalPages
                            ? () {
                                setState(() {
                                  _commentsCurrentPage = clampedPage + 1;
                                });
                              }
                            : null,
                        icon: const Icon(Icons.chevron_right_rounded, size: 16),
                        label: const Text(
                          'Siguiente',
                          style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 11),
                        ),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 32),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          foregroundColor: isDark ? const Color(0xFF89d6b0) : primaryGreen,
                          side: BorderSide(
                            color: (clampedPage < totalPages)
                                ? (isDark ? const Color(0xFF89d6b0) : primaryGreen)
                                : Colors.grey.withValues(alpha: 0.3),
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildPurchasePreferencesCard({
    required BuildContext context,
    required BuyerBehaviorProfile profile,
    required Color cardColor,
    required Color borderColor,
    required bool isDark,
    required Color primaryGreen,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.shopping_bag_outlined, size: 18, color: primaryGreen),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Preferencias de Compra',
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => _showPreferencesInfoModal(context, isDark, primaryGreen),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: primaryGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.info_outline, size: 12, color: primaryGreen),
                      const SizedBox(width: 4),
                      Text(
                        'Lógica de cálculo',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: primaryGreen,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          _buildPrefItem(
            icon: Icons.inventory_2_outlined,
            title: 'Volumen habitual',
            value: profile.volumeDisplay,
            confidencePercent: profile.volumeConfidencePercent,
            confidenceLabel: '${profile.volumeConfidencePercent}% confianza (mediana)',
            isDark: isDark,
            primaryGreen: primaryGreen,
          ),
          const SizedBox(height: 10),
          _buildPrefItem(
            icon: Icons.payments_outlined,
            title: 'Método de pago preferido',
            value: profile.paymentDisplay,
            confidencePercent: profile.paymentConfidencePercent,
            confidenceLabel: '${profile.paymentConfidencePercent}% frecuencia',
            isDark: isDark,
            primaryGreen: primaryGreen,
          ),
          const SizedBox(height: 10),
          _buildPrefItem(
            icon: Icons.storefront_outlined,
            title: 'Modalidad de compra',
            value: profile.purchaseModality,
            confidencePercent: profile.wholesaleIndexPercent,
            confidenceLabel: '${profile.wholesaleIndexPercent}% mayorista',
            isDark: isDark,
            primaryGreen: primaryGreen,
          ),
          const SizedBox(height: 14),

          Text(
            'Productos que suele comprar:',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.grey[300] : Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: profile.frequentProducts
                .map(
                  (prod) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F231D) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle_outline, size: 12, color: primaryGreen),
                        const SizedBox(width: 4),
                        Text(
                          prod,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPrefItem({
    required IconData icon,
    required String title,
    required String value,
    required bool isDark,
    required Color primaryGreen,
    int? confidencePercent,
    String? confidenceLabel,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: primaryGreen),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 10.5, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                    ),
                  ),
                  const SizedBox(width: 6),
                  if (confidencePercent != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0F231D) : const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.25)),
                      ),
                      child: Text(
                        confidenceLabel ?? '$confidencePercent% confianza',
                        style: const TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF065F46),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showPreferencesInfoModal(BuildContext context, bool isDark, Color primaryGreen) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF16231D) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.auto_graph_rounded, color: primaryGreen, size: 22),
                const SizedBox(width: 8),
                Text(
                  'Cálculo de Preferencias de Compra',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Este perfil de comportamiento se actualiza dinámicamente con cada compra completada utilizando la siguiente lógica:',
              style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[300] : Colors.grey[700]),
            ),
            const SizedBox(height: 12),
            _buildInfoBullet('1. Volumen Habitual (Mediana)', 'Calculado con la mediana de compras para no distorsionar el perfil por compras atípicas aisladas.'),
            _buildInfoBullet('2. Método Preferido', 'Determinado por la mayor frecuencia de pago junto a su porcentaje de consistencia.'),
            _buildInfoBullet('3. Modalidad Detalle vs Mayorista', 'Clasificado según el índice de compras que superan el umbral mayorista.'),
            _buildInfoBullet('4. Productos Frecuentes', 'Ranking calculado con atenuación temporal (time decay): las compras recientes tienen mayor peso.'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Entendido', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBullet(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 11.5, color: Colors.grey),
                children: [
                  TextSpan(text: '$title: ', style: const TextStyle(fontWeight: FontWeight.bold, color: _primaryGreen)),
                  TextSpan(text: desc),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderHistorySection({
    required BuildContext context,
    required Map<String, dynamic> buyer,
    required Color cardColor,
    required Color borderColor,
    required bool isDark,
    required Color primaryGreen,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Historial de negociaciones',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => context.push('/order-history', extra: buyer),
              child: const Text(
                'Ver todo',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF016042),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ValueListenableBuilder<List<Map<String, dynamic>>>(
          valueListenable: globalOrders,
          builder: (context, orders, child) {
            final filteredOrders = orders.where((order) {
              final status = (order['status'] ?? '').toString();
              return status == 'Entregado' || status == 'Completado' || status == 'Cancelado';
            }).toList();

            if (filteredOrders.isEmpty) {
              return const SizedBox(
                height: 60,
                child: Center(
                  child: Text(
                    'No hay negociaciones realizadas aún.',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            }

            final previewOrders = filteredOrders.reversed.take(3).toList();
            return Column(
              children: previewOrders.map((order) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: _buildOrderCard(
                    context: context,
                    order: order,
                    isDark: isDark,
                    cardColor: cardColor,
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildOrderCard({
    required BuildContext context,
    required Map<String, dynamic> order,
    required bool isDark,
    required Color cardColor,
  }) {
    final title = (order['title'] ?? '').toString();
    final seller = (order['seller'] ?? '').toString();
    final date = (order['date'] ?? '').toString();
    final status = (order['status'] ?? 'Entregado').toString();
    final imageUrl = (order['imageUrl'] ?? '').toString();
    final quantity = order['quantity']?.toString() ?? '1';
    final unit = (order['unit'] ?? order['quantity_label'] ?? 'unidad').toString();
    final unitPrice = (order['unit_price'] ?? order['final_price'] ?? order['price'] ?? '').toString();
    final totalPrice = (order['total_price'] ?? order['subtotal'] ?? order['price'] ?? '').toString();

    final isCompleted = status == 'Entregado' || status == 'Completado';
    final statusColor = isCompleted ? const Color(0xFF016042) : const Color(0xFFBA1A1A);
    final statusBgColor = isCompleted
        ? const Color(0xFF016042).withValues(alpha: 0.1)
        : const Color(0xFFBA1A1A).withValues(alpha: 0.1);
    final statusLabel = isCompleted ? 'COMPLETADO' : 'CANCELADO';
    final borderColor = isDark ? const Color(0xFF22382E) : const Color(0xFFE2E8F0);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => _navigateToProduct(context, order),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                imageUrl,
                width: 72,
                height: 72,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 72,
                  height: 72,
                  color: isDark ? Colors.white10 : const Color(0xFFF1F4F0),
                  child: const Icon(Icons.image_outlined, color: Colors.grey, size: 28),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _navigateToProduct(context, order),
                        child: Text(
                          title,
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF1E293B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusBgColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        statusLabel,
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: statusColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () => _navigateToProvider(context, seller, order),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.storefront_outlined,
                        size: 13,
                        color: isDark ? const Color(0xFF89d6b0) : const Color(0xFF016042),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          seller,
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? const Color(0xFF89d6b0) : const Color(0xFF016042),
                            decoration: TextDecoration.underline,
                            decorationColor: (isDark ? const Color(0xFF89d6b0) : const Color(0xFF016042)).withValues(alpha: 0.3),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 11,
                      color: isDark ? Colors.grey[500] : const Color(0xFF64748B),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      date,
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 11,
                        color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '•',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.grey[600] : const Color(0xFF94A3B8),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Cant: $quantity $unit',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.grey[300] : const Color(0xFF475569),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      unitPrice.contains('/') ? unitPrice : '$unitPrice / $unit',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Total: ',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 11,
                              color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
                            ),
                          ),
                          TextSpan(
                            text: totalPrice,
                            style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF016042),
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

  void _navigateToProduct(BuildContext context, Map<String, dynamic> order) {
    final isAvailable = order['is_available'] as bool? ?? (order['status'] != 'Cancelado');
    if (!isAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'El producto "${order['title'] ?? 'seleccionado'}" no está disponible actualmente.',
                  style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 13),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF1E293B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    final productData = <String, dynamic>{
      'name': order['title'] ?? 'Producto',
      'title': order['title'] ?? 'Producto',
      'price': order['final_price'] ?? order['unit_price'] ?? order['price'] ?? '\$0.00',
      'img': order['imageUrl'] ?? '',
      'image': order['imageUrl'] ?? '',
      'supplier': order['seller'] ?? 'Proveedor',
      'provider': order['seller'] ?? 'Proveedor',
      'unit': order['unit'] ?? order['quantity_label'] ?? 'por KG',
      'rating': '4.9',
      'badge': 'PRIMERA CALIDAD',
      'salesMode': 'both',
    };

    context.push('/product_detail', extra: productData);
  }

  void _navigateToProvider(BuildContext context, String sellerName, [Map<String, dynamic>? order]) {
    Map<String, dynamic>? match;
    for (var p in globalFavoriteProviders.value) {
      if (p['name'] == sellerName) {
        match = p;
        break;
      }
    }

    final providerData = match ?? <String, dynamic>{
      'name': sellerName,
      'rating': '4.8',
      'sector': 'Sector San Pedro',
      'distance': 'A 5 km',
      'level': 'Nivel 3',
      'verified': true,
      'open': true,
      'sales': '1,240',
      'reviews': '120 reseñas',
      'traded': '1,240 productos negociados',
      'img': order?['imageUrl'] ?? 'https://eldinero.com.do/wp-content/uploads/mercados-productos-precios.jpg',
      'image': order?['imageUrl'] ?? 'https://eldinero.com.do/wp-content/uploads/mercados-productos-precios.jpg',
    };

    context.push('/provider', extra: providerData);
  }
}
