import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../data/global_state.dart';
import '../services/reviews_service.dart';
import '../services/buyer_behavior_service.dart';
import '../widgets/animated_favorite_button.dart';
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
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final buyer = widget.buyer;
    final buyerId = (buyer['id'] ?? 'BUY-88291').toString();
    final buyerName = (buyer['name'] ?? 'Comprador').toString();
    final buyerAvatar = buyer['avatar'] as String?;
    final location = (buyer['location'] ?? 'Ubicación no especificada').toString();
    final distance = (buyer['distance'] ?? 'Cercano').toString();
    final businessType = (buyer['businessType'] ?? 'Comprador Mayorista / Detallista').toString();
    final memberSince = (buyer['memberSince'] ?? 'Enero 2023').toString();
    final rating = (buyer['rating'] ?? 4.9).toString();
    final negotiationsCount = buyer['negotiationsCount'] ?? 15;

    // Colores del sistema de diseño Esmeralda
    const primaryGreen = _primaryGreen;
    final bgColor = isDark ? const Color(0xFF0F1713) : const Color(0xFFF7FAF7);
    final cardColor = isDark ? const Color(0xFF16231D) : Colors.white;
    final borderColor = isDark ? const Color(0xFF22382E) : const Color(0xFFE2E8F0);

    // Criterios de reputación directa
    final scores = ReviewsService.getBuyerReputation(buyerId);
    final directReviews = ReviewsService.getDirectReviews(buyerId);

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

            // 2. Métricas Clave de Negociación (Negociaciones y Calificación)
            _buildMetricsRow(
              negotiationsCount: negotiationsCount,
              rating: rating,
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

            // 4. Comentarios de Otros Proveedores
            _buildProviderCommentsSection(
              directReviews: directReviews,
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
                            (buyer['sector'] ?? '').toString().isNotEmpty
                                ? buyer['sector'].toString()
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
                icon: Icons.workspace_premium_rounded,
                text: 'Buen Pagador',
                bgColor: isDark ? const Color(0xFF262012) : const Color(0xFFFEF8E3),
                textColor: const Color(0xFFB45309),
                borderColor: const Color(0xFFF3AF43).withValues(alpha: 0.4),
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
    required Color cardColor,
    required Color borderColor,
    required bool isDark,
    required Color primaryGreen,
  }) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricTile(
            icon: Icons.handshake_outlined,
            iconColor: isDark ? const Color(0xFF89d6b0) : primaryGreen,
            value: '$negotiationsCount',
            label: 'Negociaciones',
            cardColor: cardColor,
            borderColor: borderColor,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricTile(
            icon: Icons.star_rounded,
            iconColor: const Color(0xFFF2A439),
            value: '$rating ★',
            label: 'Calificación',
            cardColor: cardColor,
            borderColor: borderColor,
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricTile({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
    required Color cardColor,
    required Color borderColor,
    required bool isDark,
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: valueColor ?? (isDark ? Colors.white : Colors.black87),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
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

          // 6 Criterios de Evaluación
          _buildCriteriaRow('Comunicación', scores['Comunicación'] ?? 4.9, isDark, primaryGreen),
          _buildCriteriaRow('Puntualidad', scores['Puntualidad'] ?? 4.7, isDark, primaryGreen),
          _buildCriteriaRow('Cumplimiento del acuerdo', scores['Cumplimiento del acuerdo'] ?? (scores['Cumplimiento'] ?? 4.8), isDark, primaryGreen),
          _buildCriteriaRow('Cumplimiento de pago', scores['Cumplimiento de pago'] ?? (scores['Pago'] ?? 4.9), isDark, primaryGreen),
          _buildCriteriaRow('Seriedad en la compra', scores['Seriedad en la compra'] ?? (scores['Trato'] ?? 5.0), isDark, primaryGreen),
          _buildCriteriaRow('Comportamiento general', scores['Comportamiento general'] ?? (scores['Trato'] ?? 4.9), isDark, primaryGreen),
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

  Widget _buildCriteriaRow(String name, double score, bool isDark, Color primaryGreen) {
    final percentage = (score / 5.0).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.5),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.grey[300] : Colors.grey[800],
                ),
              ),
              Text(
                score.toStringAsFixed(1),
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 6,
              backgroundColor: isDark ? Colors.white10 : Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                isDark ? const Color(0xFF10B981) : primaryGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderCommentsSection({
    required List<DirectProfileReview> directReviews,
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
                '(${directReviews.length})',
                style: TextStyle(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.bold),
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
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ),
            )
          else
            ...directReviews.map((rev) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F231D) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: borderColor.withValues(alpha: 0.6)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: primaryGreen.withValues(alpha: 0.15),
                                child: Text(
                                  rev.authorName.isNotEmpty ? rev.authorName[0] : 'P',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: _primaryGreen,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    rev.authorName,
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'Proveedor verificado',
                                    style: TextStyle(fontSize: 9.5, color: Colors.grey[500]),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF8E3),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFFF3AF43)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.star_rounded, size: 12, color: Color(0xFFF2A439)),
                                const SizedBox(width: 2),
                                Text(
                                  rev.averageScore.toStringAsFixed(1),
                                  style: const TextStyle(
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
                      Text(
                        '“${rev.comment}”',
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: isDark ? Colors.grey[300] : Colors.grey[800],
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                )),
        ],
      ),
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
}
