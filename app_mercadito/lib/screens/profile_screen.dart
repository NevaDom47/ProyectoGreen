import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import '../data/global_state.dart';
import '../widgets/animated_favorite_button.dart';
import '../services/user_session.dart';
import 'my_provider_profile_screen.dart';

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
    final userRole = UserSession.selectedRole ?? 'comprador';

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
              TextButton.icon(
                icon: const Icon(Icons.report, color: Colors.red, size: 20),
                label: const Text('Reportar', style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  backgroundColor: Colors.red.withValues(alpha: 0.1),
                ),
                onPressed: () {},
              ),
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
            UserSession.selectedRole == 'comprador' ? 'ID: #BUY-88291' : 'ID: #SELL-9942',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
          ),
          const SizedBox(height: 8),
          // Premium Dynamic Role Chip Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  userRole == 'comprador' ? Icons.shopping_basket : Icons.agriculture,
                  size: 14,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  userRole == 'proveedor' ? 'PROVEEDOR / NEGOCIANTE' : 'COMPRADOR',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
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
            Text(
              'Historial de negociaciones',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            GestureDetector(
              onTap: () => context.push('/order-history'),
              child: Text(
                'Ver todo',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ValueListenableBuilder<List<Map<String, dynamic>>>(
          valueListenable: globalOrders,
          builder: (context, orders, child) {
            if (orders.isEmpty) {
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
            final previewOrders = orders.reversed.take(3).toList();
            return Column(
              children: previewOrders.map((order) {
                final String status = order['status'] ?? 'Entregado';
                Color statusColor = theme.colorScheme.primary;
                if (status == 'En camino') {
                  statusColor = Colors.orange;
                } else if (status == 'Cancelado') {
                  statusColor = const Color(0xFFba1a1a);
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: _buildOrderCard(
                    title: order['title'] ?? '',
                    price: order['final_price'] ?? order['price'] ?? '',
                    seller: order['seller'] ?? '',
                    date: order['date'] ?? '',
                    status: status,
                    statusColor: statusColor,
                    imageUrl: order['imageUrl'] ?? 'https://via.placeholder.com/150',
                    quantity: order['quantity_label'] ?? '1 unidad',
                    isDark: isDark,
                    cardColor: cardColor,
                  ),
                );
              }).toList(),
            );
          }
        ),
      ],
    );
  }

  Widget _buildOrderCard({
    required String title,
    required String price,
    required String seller,
    required String date,
    required String status,
    required Color statusColor,
    required String imageUrl,
    required String quantity,
    required bool isDark,
    required Color cardColor,
  }) {
    final borderColor = isDark ? Colors.grey[800]! : Colors.grey[200]!;

    // Dynamic map labels
    String badgeLabel = status;
    if (status == 'Entregado') {
      badgeLabel = 'Completado';
    } else if (status == 'En camino') {
      badgeLabel = 'Pendiente';
    } else if (status == 'Cancelado') {
      badgeLabel = 'Cancelado';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 1. Imagen del producto
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              imageUrl,
              width: 64,
              height: 64,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 64,
                height: 64,
                color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.04),
                child: const Icon(
                  Icons.image_outlined,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // 2. Info details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre del producto
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Precio final negociado
                    Text(
                      price,
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF00462f),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Nombre de proveedor
                Row(
                  children: [
                    Icon(
                      Icons.storefront_outlined,
                      size: 12,
                      color: isDark ? Colors.grey[400] : const Color(0xFF486456),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Negociado con: $seller',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.grey[400] : const Color(0xFF486456),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Fecha y cantidad negociada
                    Text(
                      '$date • Cant: $quantity',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 10,
                        color: isDark ? Colors.grey[500] : Colors.grey[400],
                      ),
                    ),
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        badgeLabel.toUpperCase(),
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesCarousel(BuildContext context, ThemeData theme, bool isDark, Color cardColor) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Mis Favoritos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
            TextButton(
              onPressed: () => context.go('/favorites'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text('Explorar', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 320,
          child: ValueListenableBuilder<List<Map<String, dynamic>>>(
            valueListenable: globalFavorites,
            builder: (context, favoritesList, child) {
              if (favoritesList.isEmpty) {
                return const Center(child: Text('No hay favoritos aún.', style: TextStyle(color: Colors.grey)));
              }
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: favoritesList.length,
                separatorBuilder: (context, index) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final data = favoritesList[index];
                  return GestureDetector(
                    onTap: () => context.push('/product_detail', extra: data),
                    child: _buildProductCard(
                      context: context,
                      theme: theme,
                      surfaceColor: cardColor,
                      primaryColor: theme.colorScheme.primary,
                      isDark: isDark,
                      data: data,
                    ),
                  );
                },
              );
            }
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard({
    required BuildContext context,
    required ThemeData theme,
    required Color surfaceColor,
    required Color primaryColor,
    required bool isDark,
    required Map<String, dynamic> data,
  }) {
    final String badgeStr = (data['quality'] ?? '').toString().toUpperCase();
    final String lowerBadge = badgeStr.toLowerCase();
    Color badgeColor = primaryColor;
    if (lowerBadge.contains('segunda')) {
      badgeColor = Colors.amber[700]!;
    } else if (lowerBadge.contains('tercera')) {
      badgeColor = Colors.red[400]!;
    }

    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: isDark ? primaryColor.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryColor.withOpacity(0.05)),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 110,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(data['image'] ?? data['img'] ?? 'https://via.placeholder.com/150'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: AnimatedFavoriteButton(
                  isFavorite: true,
                  size: 18,
                  onTap: () {
                    toggleFavorite(data);
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Eliminado de favoritos'),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (data['quality'] != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: badgeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        badgeStr,
                        style: TextStyle(
                          color: badgeColor,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  Text(
                    data['name'] ?? '',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (data['tags'] != null && (data['tags'] as List).isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: (data['tags'] as List).map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            tag.toString(),
                            style: TextStyle(
                              color: primaryColor,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                data['supplier'] ?? '',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: primaryColor.withOpacity(0.7),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.verified, size: 12, color: primaryColor),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 10),
                            const SizedBox(width: 2),
                            Text(
                              data['rating'] ?? '5.0',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    data['price'] ?? '',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  Text(
                    data['unit'] ?? 'unidad',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ValueListenableBuilder<List<Map<String, dynamic>>>(
                      valueListenable: globalCart,
                      builder: (context, cart, child) {
                        final bool inCart = isInCart(data);
                        return ElevatedButton.icon(
                          onPressed: inCart ? null : () {
                            addToCart(data);
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(Icons.shopping_cart_checkout, color: Colors.white, size: 20),
                                    const SizedBox(width: 12),
                                    const Expanded(child: Text('Agregado al carrito', style: TextStyle(fontWeight: FontWeight.bold))),
                                  ],
                                ),
                                backgroundColor: const Color(0xFF016142),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          icon: Icon(inCart ? Icons.check : Icons.shopping_cart, size: 14),
                          label: Text(inCart ? 'Ya en carrito' : 'Agregar', style: const TextStyle(fontSize: 12)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey.shade300,
                            disabledForegroundColor: Colors.grey.shade600,
                            minimumSize: const Size(0, 36),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: inCart ? 0 : 2,
                            shadowColor: primaryColor.withOpacity(0.4),
                          ),
                        );
                      }
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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
          _buildSettingsTile('Vendedores seguidos', Icons.group, theme, isDark, true, onTap: () => context.push('/followed-sellers')),
          _buildSettingsTile('Mis Reseñas', Icons.reviews, theme, isDark, true, onTap: () => context.push('/my-reviews')),
          _buildSettingsTile('Privacidad del perfil', Icons.lock, theme, isDark, true, onTap: () => context.push('/privacy')),
          _buildSettingsTile('Configuración de cuenta', Icons.settings, theme, isDark, false, onTap: () => context.push('/account-config')),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(String title, IconData icon, ThemeData theme, bool isDark, bool hasBorder, {VoidCallback? onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap ?? () {},
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            border: hasBorder ? Border(bottom: BorderSide(color: isDark ? Colors.grey[800]! : Colors.grey[100]!)) : null,
          ),
          child: Row(
            children: [
              Icon(icon, color: theme.colorScheme.primary, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: isDark ? Colors.white : Colors.black87)),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
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
}
