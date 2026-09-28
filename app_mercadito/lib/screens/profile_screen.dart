import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import '../data/global_state.dart';
import '../widgets/animated_favorite_button.dart';
import '../services/user_session.dart';
import '../services/reviews_service.dart';
import '../widgets/quality_info_bottom_sheet.dart';
import '../widgets/supplier_quick_view_bottom_sheet.dart';
import 'my_provider_profile_screen.dart';
import 'order_history_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (UserSession.selectedRole == 'proveedor') {
      return const MyProviderProfileScreen();
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final bgColor = isDark ? const Color(0xFF0f231d) : const Color(0xFFf5f8f7);
    final cardColor = isDark ? const Color(0xFF0f172a) : Colors.white; // slate-900 or white

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            children: [
              _buildHeader(context, theme, isDark, cardColor),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                child: Column(
                  children: [
                    _buildProviderReputationSection(context, theme, isDark, cardColor),
                    const SizedBox(height: 32),
                    _buildOrderHistory(context, theme, isDark, cardColor),
                    const SizedBox(height: 32),
                    _buildFavoritesCarousel(context, theme, isDark, cardColor),
                    const SizedBox(height: 32),
                    _buildSettingsMenu(context, theme, isDark, cardColor),
                    const SizedBox(height: 32),
                    _buildContactInfo(theme, isDark),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme, bool isDark, Color cardColor) {
    final avatarUrl = UserSession.profilePictureUrl ??
        (UserSession.selectedRole == 'proveedor'
            ? 'assets/images/Foto Sin perfil Proveedor.png'
            : 'assets/images/Foto sin perfil.png');

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black87),
                onPressed: () => context.pop(),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 16),
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 112,
                height: 112,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3), width: 4),
                ),
                padding: const EdgeInsets.all(4),
                child: ClipOval(
                  child: Image(
                    image: avatarUrl.startsWith('http') || avatarUrl.startsWith('blob:')
                        ? NetworkImage(avatarUrl) as ImageProvider
                        : (avatarUrl.startsWith('assets/')
                            ? AssetImage(avatarUrl) as ImageProvider
                            : (kIsWeb
                                ? NetworkImage(avatarUrl) as ImageProvider
                                : FileImage(File(avatarUrl)) as ImageProvider)),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: cardColor, width: 2),
                ),
                padding: const EdgeInsets.all(6),
                child: const Icon(Icons.verified, color: Colors.white, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            UserSession.fullName ?? 'Juan Pérez',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            UserSession.formattedId,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
          ),
          const SizedBox(height: 8),
          Text(
            'Miembro desde Enero 2023',
            style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600]),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              _buildStatBox('198', 'RESEÑAS', theme, isDark, cardColor),
              const SizedBox(width: 12),
              _buildStatBox('4.5', 'CALIFICACIÓN', theme, isDark, cardColor, isRating: true),
              const SizedBox(width: 12),
              _buildStatBox('15', 'NEGOCIACIONES', theme, isDark, cardColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(String value, String label, ThemeData theme, bool isDark, Color cardColor, {bool isRating = false}) {
    final borderColor = isDark ? Colors.grey[800]! : Colors.grey[200]!;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          children: [
            if (!isRating)
              Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87))
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                  const SizedBox(width: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, size: 12, color: Color(0xFF00C853)),
                      const Icon(Icons.star, size: 12, color: Color(0xFF00C853)),
                      const Icon(Icons.star_half, size: 12, color: Color(0xFF00C853)),
                    ],
                  ),
                ],
              ),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderHistory(BuildContext context, ThemeData theme, bool isDark, Color cardColor) {
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
              onTap: () => context.push('/order-history'),
              child: Text(
                'Ver todo',
                style: const TextStyle(
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
            // Filter only completed and cancelled negotiations
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
            // Always display the last 3 negotiations of the history (newest first)
            final previewOrders = filteredOrders.reversed.take(3).toList();
            return Column(
              children: previewOrders.map((order) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: InteractiveOrderCard(
                    order: order,
                    onProductTap: () => _navigateToProduct(context, order),
                    onProviderTap: () => _navigateToProvider(
                      context,
                      (order['seller'] ?? '').toString(),
                      order,
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
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

  Widget _buildFavoritesCarousel(BuildContext context, ThemeData theme, bool isDark, Color cardColor) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Mis Favoritos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            TextButton(
              onPressed: () => context.push('/favorites'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Ver todos',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 330,
          child: ValueListenableBuilder<List<Map<String, dynamic>>>(
            valueListenable: globalFavorites,
            builder: (context, favoritesList, child) {
              if (favoritesList.isEmpty) {
                return const Center(
                  child: Text(
                    'No hay favoritos aún.',
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }
              // Only display the last 5 added favorites
              final displayedFavorites = favoritesList.reversed.take(5).toList();
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: displayedFavorites.length,
                separatorBuilder: (context, index) => const SizedBox(width: 14),
                itemBuilder: (context, index) {
                  final data = displayedFavorites[index];
                  return _ProfileFavoriteCard(
                    data: data,
                    theme: theme,
                    surfaceColor: cardColor,
                    primaryColor: theme.colorScheme.primary,
                    isDark: isDark,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsMenu(BuildContext context, ThemeData theme, bool isDark, Color cardColor) {
    final borderColor = isDark ? Colors.grey[800]! : Colors.grey[200]!;
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          _buildSettingsTile(
            context,
            'Proveedores seguidos',
            Icons.group,
            theme,
            isDark,
            true,
            enabled: false,
            badgeText: 'Inhabilitado',
          ),
          _buildSettingsTile(context, 'Mis Reseñas', Icons.reviews, theme, isDark, true, onTap: () => context.push('/my-reviews')),
          _buildSettingsTile(context, 'Privacidad del perfil', Icons.lock, theme, isDark, true, onTap: () => context.push('/privacy')),
          _buildSettingsTile(context, 'Configuración de cuenta', Icons.settings, theme, isDark, false, onTap: () => context.push('/account-config')),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context,
    String title,
    IconData icon,
    ThemeData theme,
    bool isDark,
    bool hasBorder, {
    VoidCallback? onTap,
    bool enabled = true,
    String? badgeText,
  }) {
    final textColor = enabled
        ? (isDark ? Colors.white : Colors.black87)
        : (isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8));
    final iconColor = enabled
        ? theme.colorScheme.primary
        : (isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8));

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled
            ? (onTap ?? () {})
            : () {
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.white, size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'La opción de proveedores seguidos está inhabilitada por el momento.',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: const Color(0xFF285E44),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            border: hasBorder ? Border(bottom: BorderSide(color: isDark ? Colors.grey[800]! : Colors.grey[100]!)) : null,
          ),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: textColor),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (badgeText != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF23352B) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isDark ? const Color(0xFF334E40) : const Color(0xFFCBD5E1),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          badgeText,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                enabled ? Icons.chevron_right : Icons.lock_outline_rounded,
                color: enabled ? Colors.grey[400] : (isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                size: enabled ? 24 : 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactInfo(ThemeData theme, bool isDark) {
    final emailText = UserSession.email ?? 'juan.perez@email.com';
    final phoneText = UserSession.phone ?? '+52 (555) 123-4567';
    
    String addressText = 'Ciudad de México, México - Zona Norte';
    if (UserSession.country != null && UserSession.state != null && UserSession.streetAddress != null) {
      addressText = '${UserSession.streetAddress}, ${UserSession.state}, ${UserSession.country}';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Información de contacto', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
          const SizedBox(height: 12),
          _buildContactRow(Icons.mail, emailText, theme),
          const SizedBox(height: 8),
          _buildContactRow(Icons.call, phoneText, theme),
          const SizedBox(height: 8),
          _buildContactRow(Icons.map, addressText, theme),
        ],
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String text, ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 16),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 12, color: Colors.grey))),
      ],
    );
  }

  Widget _buildProviderReputationSection(BuildContext context, ThemeData theme, bool isDark, Color cardColor) {
    const buyerId = 'BUY-88291';
    final scores = ReviewsService.getBuyerReputation(buyerId);
    final borderColor = isDark ? Colors.grey[800]! : Colors.grey[200]!;
    final isProviderViewing = UserSession.selectedRole == 'proveedor';
    final hasReviewed = ReviewsService.hasDirectReview('prov_current', buyerId);

    // Calculate overall buyer reputation average
    double total = 0;
    scores.forEach((_, v) => total += v);
    final avg = scores.isNotEmpty ? (total / scores.length).toStringAsFixed(1) : '4.9';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF016042).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.handshake_rounded, color: Color(0xFF016042), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '¿Cómo lo califican los proveedores?',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Evaluación directa basada en acuerdos y negociaciones',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 11,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF262012) : const Color(0xFFFEF8E3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFF3AF43)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded, size: 15, color: Color(0xFFF2A439)),
                    const SizedBox(width: 4),
                    Text(
                      '$avg ⭐',
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFF2A439),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // The 5 Criteria (Requested specifically by user)
          _buildBuyerScoreBar('Comunicación', scores['Comunicación'] ?? 4.9, isDark),
          _buildBuyerScoreBar('Cumplimiento del acuerdo', scores['Cumplimiento'] ?? 4.8, isDark),
          _buildBuyerScoreBar('Puntualidad en citas y recepción', scores['Puntualidad'] ?? 4.7, isDark),
          _buildBuyerScoreBar('Trato y seriedad', scores['Trato'] ?? 5.0, isDark),
          _buildBuyerScoreBar('Cumplimiento de pago', scores['Pago'] ?? 4.9, isDark),

          // Provider CTA (if a provider views buyer's profile)
          if (isProviderViewing) ...[
            const SizedBox(height: 16),
            if (hasReviewed) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0D281E) : const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Ya enviaste tu reseña de perfil a este comprador (límite: 1 reseña por contraparte).',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF065F46),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.push('/direct-profile-review', extra: {
                      'targetType': 'buyer',
                      'targetRole': 'comprador',
                      'targetId': buyerId,
                      'targetName': UserSession.fullName ?? 'Juan Pérez',
                      'targetAvatar': UserSession.profilePictureUrl ?? '',
                    });
                  },
                  icon: const Icon(Icons.rate_review_rounded, size: 18, color: Colors.white),
                  label: const Text(
                    'Calificar Comprador',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF016042),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildBuyerScoreBar(String label, double score, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            flex: 6,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.grey[300] : Colors.grey[700],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 4,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: score / 5.0,
                minHeight: 7,
                backgroundColor: isDark ? Colors.white12 : Colors.grey[200],
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF016042)),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 26,
            child: Text(
              score.toStringAsFixed(1),
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 12,
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
}

class _ProfileFavoriteCard extends StatefulWidget {
  final Map<String, dynamic> data;
  final ThemeData theme;
  final Color surfaceColor;
  final Color primaryColor;
  final bool isDark;

  const _ProfileFavoriteCard({
    required this.data,
    required this.theme,
    required this.surfaceColor,
    required this.primaryColor,
    required this.isDark,
  });

  @override
  State<_ProfileFavoriteCard> createState() => _ProfileFavoriteCardState();
}

class _ProfileFavoriteCardState extends State<_ProfileFavoriteCard> {
  late String _currentMode;

  @override
  void initState() {
    super.initState();
    final salesMode = widget.data['salesMode'] ?? 'both';
    _currentMode = salesMode == 'wholesale_only' ? 'wholesale' : 'retail';
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

  Widget _buildProductImage(String? src) {
    final imgSrc = (src != null && src.isNotEmpty) ? src : 'https://via.placeholder.com/400';
    if (imgSrc.startsWith('assets/')) {
      return Image.asset(
        imgSrc,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[200]),
      );
    }
    return Image.network(
      imgSrc,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[200]),
    );
  }

  Widget? _buildSalesModeBadge(String? salesMode) {
    if (salesMode == null) return null;

    if (salesMode == 'both') {
      final bool isRetailSelected = _currentMode == 'retail';
      final bool isWholesaleSelected = _currentMode == 'wholesale';

      return Container(
        padding: const EdgeInsets.all(1.5),
        decoration: BoxDecoration(
          color: widget.isDark ? const Color(0xFF111827) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: widget.isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
            width: 0.8,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (_currentMode != 'retail') {
                    setState(() => _currentMode = 'retail');
                  }
                },
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 2.5),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isRetailSelected
                        ? (widget.isDark ? const Color(0xFF047857) : const Color(0xFF059669))
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Text(
                      'Detalle',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        color: isRetailSelected
                            ? Colors.white
                            : (widget.isDark ? Colors.grey[400] : Colors.grey[600]),
                        fontSize: 9.5,
                        fontWeight: isRetailSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 2),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (_currentMode != 'wholesale') {
                    setState(() => _currentMode = 'wholesale');
                  }
                },
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 2.5),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isWholesaleSelected
                        ? (widget.isDark ? const Color(0xFF0284C7) : const Color(0xFF0369A1))
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Text(
                      'Por Mayor',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        color: isWholesaleSelected
                            ? Colors.white
                            : (widget.isDark ? Colors.grey[400] : Colors.grey[600]),
                        fontSize: 9.5,
                        fontWeight: isWholesaleSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final bool isRetailOnly = salesMode == 'retail_only' || salesMode == 'retail';
    final String label = isRetailOnly ? 'Solo al Detalle' : 'Solo por Mayor';
    final IconData icon = isRetailOnly ? Icons.shopping_bag_outlined : Icons.inventory_2_outlined;

    final Color bgColor = isRetailOnly
        ? (widget.isDark ? const Color(0xFF064E3B).withValues(alpha: 0.35) : const Color(0xFFECFDF5))
        : (widget.isDark ? const Color(0xFF075985).withValues(alpha: 0.35) : const Color(0xFFF0F9FF));
    final Color borderColor = isRetailOnly
        ? (widget.isDark ? const Color(0xFF059669).withValues(alpha: 0.4) : const Color(0xFFA7F3D0))
        : (widget.isDark ? const Color(0xFF0284C7).withValues(alpha: 0.4) : const Color(0xFFBAE6FD));
    final Color textColor = isRetailOnly
        ? (widget.isDark ? const Color(0xFF6EE7B7) : const Color(0xFF047857))
        : (widget.isDark ? const Color(0xFF7DD3FC) : const Color(0xFF0369A1));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: borderColor, width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: textColor),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.1,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String productName = widget.data['name'] ?? '';
    final String qualityStr = (widget.data['quality'] ?? widget.data['badge'] ?? 'Primera Calidad').toString();
    final String lowerQuality = qualityStr.toLowerCase();
    Color badgeColor = widget.primaryColor;
    if (lowerQuality.contains('segunda')) {
      badgeColor = const Color(0xFFFF8A5B);
    } else if (lowerQuality.contains('tercera')) {
      badgeColor = Colors.red[400]!;
    }

    final salesMode = widget.data['salesMode'] ?? 'both';
    final currentMode = (salesMode == 'both')
        ? _currentMode
        : (salesMode == 'wholesale_only' ? 'wholesale' : 'retail');
    final bool isWholesale = currentMode == 'wholesale';

    final String displayPrice = isWholesale
        ? (widget.data['wholesalePrice'] ?? widget.data['price'] ?? r'$16.50')
        : (widget.data['price'] ?? r'$22.50');

    final String displayUnitText;
    if (isWholesale) {
      displayUnitText = widget.data['wholesaleMin'] != null
          ? 'por mayor (${widget.data['wholesaleMin'].toString().toLowerCase()})'
          : 'por mayor';
    } else {
      final u = (widget.data['unit'] ?? 'kilo').toString().toLowerCase().trim();
      displayUnitText = u.startsWith('por ') ? u : 'por $u';
    }

    final salesBadge = _buildSalesModeBadge(salesMode);

    final itemForDetail = {
      ...widget.data,
      'salesMode': salesMode,
      'saleType': isWholesale ? 'mayor' : 'detalle',
      'selectedMode': currentMode,
    };

    final String supplierStr = widget.data['supplier'] ?? 'Don Pedro H.';
    final String locationStr = widget.data['location'] ?? 'Tecomán, Colima';
    final String? discount = widget.data['discount'];

    return GestureDetector(
      onTap: () => context.push('/product_detail', extra: itemForDetail),
      child: Container(
        width: 205,
        decoration: BoxDecoration(
          color: widget.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.isDark ? Colors.grey[800]! : const Color(0xFFE2E8F0),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: widget.isDark ? 0.2 : 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Top Image Stack
            Stack(
              children: [
                SizedBox(
                  height: 105,
                  width: double.infinity,
                  child: _buildProductImage(widget.data['image'] ?? widget.data['img']),
                ),
                // Top-Left Discount Pill
                if (discount != null && discount.isNotEmpty)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.bolt, color: Colors.amber, size: 11),
                          const SizedBox(width: 2),
                          Text(
                            discount,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                // Top-Right Floating Heart Button
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: AnimatedFavoriteButton(
                      isFavorite: true,
                      size: 16,
                      onTap: () {
                        toggleFavorite(widget.data);
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Eliminado de favoritos: $productName'),
                            backgroundColor: Colors.red[600],
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // Bottom-Right Verified Badge
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(3.5),
                    decoration: BoxDecoration(
                      color: widget.primaryColor,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 3),
                      ],
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

            // 2. Card Content Body
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      productName,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        height: 1.15,
                        color: widget.isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 1),
                    // SKU
                    Text(
                      'SKU: ${_getProductSku(widget.data)}',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 8.5,
                        fontWeight: FontWeight.w500,
                        color: widget.isDark ? Colors.grey.shade400 : const Color(0xFF94A3B8),
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Sales Mode Switcher [ Detalle | Por Mayor ]
                    if (salesBadge != null) ...[
                      salesBadge,
                      const SizedBox(height: 4),
                    ],

                    // Metadata Row 1: CALIDAD
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => QualityInfoBottomSheet(quality: qualityStr),
                        );
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Row(
                        children: [
                          Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: badgeColor.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.workspace_premium, color: badgeColor, size: 11),
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'CALIDAD',
                                  style: TextStyle(
                                    fontSize: 7.5,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                    letterSpacing: 0.3,
                                    height: 1.0,
                                  ),
                                ),
                                Text(
                                  qualityStr.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: badgeColor,
                                    height: 1.1,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 3),

                    // Metadata Row 2: PROVEEDOR
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => SupplierQuickViewBottomSheet(supplierData: widget.data),
                        );
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Row(
                        children: [
                          Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: widget.primaryColor.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.local_florist, color: widget.primaryColor, size: 11),
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'PROVEEDOR',
                                  style: TextStyle(
                                    fontSize: 7.5,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                    letterSpacing: 0.3,
                                    height: 1.0,
                                  ),
                                ),
                                Text(
                                  supplierStr,
                                  style: const TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    height: 1.1,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 3),

                    // Metadata Row 3: UBICACIÓN
                    Row(
                      children: [
                        Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: widget.isDark ? Colors.grey[800] : Colors.grey[200],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.location_on,
                            color: widget.isDark ? Colors.grey[300] : Colors.grey[700],
                            size: 11,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'UBICACIÓN',
                                style: TextStyle(
                                  fontSize: 7.5,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                  letterSpacing: 0.3,
                                  height: 1.0,
                                ),
                              ),
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      locationStr,
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: widget.isDark ? Colors.grey[300] : Colors.grey[700],
                                        height: 1.1,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '• A ${widget.data['distance'] != null ? widget.data['distance'].toString() : '4.2'} km',
                                    style: TextStyle(
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.bold,
                                      color: widget.isDark ? const Color(0xFF6EE7B7) : const Color(0xFF059669),
                                      height: 1.1,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    // Price & Unit
                    SizedBox(
                      width: double.infinity,
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: displayPrice,
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w900,
                                color: isWholesale
                                    ? (widget.isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7))
                                    : widget.primaryColor,
                              ),
                            ),
                            TextSpan(
                              text: ' / $displayUnitText',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                                color: widget.isDark ? Colors.grey[400] : const Color(0xFF64748B),
                                letterSpacing: 0.1,
                              ),
                            ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 5),

                    // Action Button
                    ValueListenableBuilder<List<Map<String, dynamic>>>(
                      valueListenable: globalCart,
                      builder: (context, cart, child) {
                        final bool inCart = isInCart(itemForDetail);
                        return SizedBox(
                          width: double.infinity,
                          height: 30,
                          child: ElevatedButton.icon(
                            onPressed: inCart
                                ? null
                                : () {
                                    addToCart(itemForDetail);
                                    ScaffoldMessenger.of(context).clearSnackBars();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          children: [
                                            const Icon(Icons.shopping_cart_checkout, color: Colors.white, size: 20),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                'Agregado al carrito: $productName',
                                                style: const TextStyle(fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                          ],
                                        ),
                                        backgroundColor: const Color(0xFF016142),
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  },
                            icon: Icon(inCart ? Icons.check : Icons.shopping_cart_outlined, size: 12),
                            label: Text(
                              inCart ? 'EN EL CARRITO' : 'AGREGAR AL CARRITO',
                              style: const TextStyle(
                                fontSize: 8.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: widget.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              disabledBackgroundColor: widget.isDark ? Colors.grey[800] : Colors.grey[300],
                              disabledForegroundColor: widget.isDark ? Colors.grey[500] : Colors.grey[600],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                          ),
                        );
                      },
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
