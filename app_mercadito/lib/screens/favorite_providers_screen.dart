import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../data/global_state.dart';
import '../widgets/animated_favorite_button.dart';

class FavoriteProvidersScreen extends StatefulWidget {
  const FavoriteProvidersScreen({super.key});

  @override
  State<FavoriteProvidersScreen> createState() => _FavoriteProvidersScreenState();
}

class _FavoriteProvidersScreenState extends State<FavoriteProvidersScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildAnimatedItem(Widget child, int index) {
    final animation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Interval((index * 0.1).clamp(0.0, 1.0), 1.0, curve: Curves.easeOutCubic),
    ));
    final fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Interval((index * 0.1).clamp(0.0, 1.0), 1.0, curve: Curves.easeOutCubic),
    ));

    return FadeTransition(
      opacity: fadeAnimation,
      child: SlideTransition(
        position: animation,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Emerald Harvest Design System Tokens
    const primaryGreen = Color(0xFF00462f);
    final bgColor = isDark ? const Color(0xFF0f231d) : const Color(0xFFf7faf5);
    final surfaceColor = isDark ? const Color(0xFF1c2c26) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? const Color(0xFF89d6b0) : primaryGreen),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Proveedores Favoritos',
          style: GoogleFonts.plusJakartaSans(
            color: isDark ? const Color(0xFF89d6b0) : primaryGreen,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: ValueListenableBuilder<List<Map<String, dynamic>>>(
        valueListenable: globalFavoriteProviders,
        builder: (context, favorites, child) {
          final filteredFavorites = favorites.where((p) => 
            p['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase())
          ).toList();

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Filter
                _buildAnimatedItem(_buildSearchBar(isDark, surfaceColor), 0),
                const SizedBox(height: 24),

                if (filteredFavorites.isEmpty)
                  _buildAnimatedItem(
                    _buildEmptyState(isDark),
                    1,
                  )
                else ...[
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredFavorites.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final provider = filteredFavorites[index];
                      return _buildAnimatedItem(
                        _buildProviderCard(context, provider, isDark, surfaceColor),
                        index + 1,
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  // Empty State Context / Recommendation at bottom of list
                  _buildAnimatedItem(
                    _buildRecommendationCard(isDark),
                    filteredFavorites.length + 1,
                  ),
                ],
                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar(bool isDark, Color surfaceColor) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFbec9c1).withValues(alpha: 0.2)),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => setState(() => _searchQuery = val),
        style: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          color: isDark ? Colors.white : Colors.black87,
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search, size: 20, color: isDark ? Colors.white54 : const Color(0xFF3f4943)),
          hintText: 'Buscar en mis favoritos...',
          hintStyle: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: isDark ? Colors.white38 : const Color(0xFF3f4943).withValues(alpha: 0.6),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  static String _formatTo12h(String timeStr) {
    final trimmed = timeStr.trim();
    if (trimmed.isEmpty) return '6:00 PM';
    if (RegExp(r'\b(AM|PM|am|pm)\b').hasMatch(trimmed)) {
      return trimmed.toUpperCase();
    }
    final match = RegExp(r'^(\d{1,2}):(\d{2})').firstMatch(trimmed);
    if (match != null) {
      final hour24 = int.tryParse(match.group(1)!);
      final minute = int.tryParse(match.group(2)!);
      if (hour24 != null && minute != null) {
        final period = hour24 >= 12 ? 'PM' : 'AM';
        var hour12 = hour24 % 12;
        if (hour12 == 0) hour12 = 12;
        final minuteStr = minute.toString().padLeft(2, '0');
        return '$hour12:$minuteStr $period';
      }
    }
    return trimmed;
  }

  Widget _buildProviderImage(String? img, bool isDark) {
    if (img == null || img.trim().isEmpty) {
      return Container(
        height: 180,
        width: double.infinity,
        color: isDark ? const Color(0xFF1a2f26) : const Color(0xFFebefea),
        child: Icon(Icons.storefront, size: 50, color: isDark ? const Color(0xFF89d6b0) : const Color(0xFF285E44)),
      );
    }
    final cleanImg = img.trim();
    if (cleanImg.startsWith('assets/')) {
      return Image.asset(
        cleanImg,
        height: 180,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          height: 180,
          width: double.infinity,
          color: isDark ? const Color(0xFF1a2f26) : const Color(0xFFebefea),
          child: Icon(Icons.storefront, size: 50, color: isDark ? const Color(0xFF89d6b0) : const Color(0xFF285E44)),
        ),
      );
    }
    return Image.network(
      cleanImg,
      height: 180,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        height: 180,
        width: double.infinity,
        color: isDark ? const Color(0xFF1a2f26) : const Color(0xFFebefea),
        child: Icon(Icons.storefront, size: 50, color: isDark ? const Color(0xFF89d6b0) : const Color(0xFF285E44)),
      ),
    );
  }

  Widget _buildProviderCard(BuildContext context, Map<String, dynamic> provider, bool isDark, Color surfaceColor) {
    final theme = Theme.of(context);
    final textColor = isDark ? Colors.white : const Color(0xFF181d1a);
    final isVerified = provider['verified'] == true;
    final isOpen = provider['open'] != false;
    final closeTime = provider['closeTime']?.toString() ?? '18:00';
    final name = provider['name']?.toString() ?? 'Proveedor';
    final rating = provider['rating']?.toString() ?? '4.8';
    final distance = provider['distance']?.toString() ?? 'A 5 km';
    final tags = (provider['tags'] != null && provider['tags'].toString().isNotEmpty)
        ? provider['tags'].toString()
        : 'Frutas y verduras';
    final salesType = provider['salesType']?.toString() ?? 'Al Detalle';
    final level = provider['level']?.toString() ?? 'Nivel 3';
    final traded = provider['traded']?.toString() ?? '1,240 productos negociados';
    final reviews = provider['reviews']?.toString() ?? '120 reseñas de clientes';
    final imgUrl = provider['banner'] ?? provider['img'] ?? provider['image'] ?? provider['imageUrl'] ?? '';

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push('/provider', extra: provider),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner Image with Badges
              Stack(
                children: [
                  _buildProviderImage(imgUrl?.toString(), isDark),
                  
                  // Verified Badge (top-left)
                  if (isVerified)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0f172a).withValues(alpha: 0.9) : Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.verified, color: Colors.blue, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              'VERIFICADO',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Favorite Button (top-right)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.black.withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: AnimatedFavoriteButton(
                        isFavorite: true,
                        size: 20,
                        onTap: () {
                          toggleFavoriteProvider(provider);
                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Eliminado de favoritos: $name',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              backgroundColor: Colors.red[800],
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // Distance Badge (bottom-right of image)
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        distance,
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Content Details
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Provider Name & Rating Pill
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star, color: Colors.orange, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                rating,
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Operational status & 12h close time
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isOpen ? Colors.green : Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isOpen ? 'ABIERTO AHORA' : 'CERRADO',
                          style: GoogleFonts.plusJakartaSans(
                            color: isOpen ? Colors.green : Colors.grey,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (isOpen) ...[
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '• Cierra ${_formatTo12h(closeTime)}',
                              style: GoogleFonts.plusJakartaSans(
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Category, Modality & Level Badges
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          tags,
                          style: GoogleFonts.plusJakartaSans(
                            color: theme.colorScheme.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF16251E) : const Color(0xFFEAF2E8),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark ? const Color(0xFF23352B) : theme.colorScheme.primary.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.sell_outlined,
                                size: 10,
                                color: isDark ? const Color(0xFF8BD8B2) : theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                salesType,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? const Color(0xFF8BD8B2) : theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (level.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF262012) : const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark ? const Color(0xFF624A1D) : const Color(0xFFFCD34D),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.military_tech_rounded,
                                  size: 11,
                                  color: Color(0xFFD97706),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  level,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Traded products
                    Row(
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 14, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            traded,
                            style: GoogleFonts.plusJakartaSans(
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Reviews & Ver perfil CTA
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            reviews,
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => context.push('/provider', extra: provider),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            minimumSize: const Size(0, 36),
                          ),
                          child: Text(
                            'Ver perfil',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
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
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return _buildRecommendationCard(isDark);
  }

  Widget _buildRecommendationCard(bool isDark) {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.02) : const Color(0xFFebefea).withValues(alpha: 0.3), // surface-container/30
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFbec9c1).withValues(alpha: 0.4),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_add_alt_1, size: 48, color: isDark ? Colors.white24 : const Color(0xFF00462f).withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text(
            'Descubre más productores',
            style: GoogleFonts.plusJakartaSans(
              color: isDark ? Colors.white : const Color(0xFF3f4943),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Explora el mercado para encontrar proveedores y agregalos a tus favoritos para acceso rapido.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              color: isDark ? Colors.white54 : const Color(0xFF3f4943).withValues(alpha: 0.7),
              fontSize: 12,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/providers'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF036042), // primary-container
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
              elevation: 0,
            ),
            child: Text(
              'EXPLORAR MERCADO',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w900,
                fontSize: 10,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
