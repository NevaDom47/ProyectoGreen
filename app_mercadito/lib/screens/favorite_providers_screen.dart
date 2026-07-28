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
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFbec9c1).withOpacity(0.2)),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
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
            color: isDark ? Colors.white38 : const Color(0xFF3f4943).withOpacity(0.6),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildProviderCard(BuildContext context, Map<String, dynamic> provider, bool isDark, Color surfaceColor) {
    final textColor = isDark ? Colors.white : const Color(0xFF181d1a);
    final secondaryTextColor = isDark ? Colors.grey[400] : const Color(0xFF3f4943);
    final isVerified = provider['verified'] ?? true;
    final primaryGreen = isDark ? const Color(0xFF89d6b0) : const Color(0xFF00462f);

    // Default mock data for testing UI based on the new design
    final List<String> tags = provider['tags'] != null && provider['tags'].toString().isNotEmpty
        ? provider['tags'].toString().split(', ')
        : ['Verduras', 'Hortalizas'];

    return GestureDetector(
      onTap: () => context.push('/provider', extra: provider),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.transparent),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar with verified badge
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1c2c26) : const Color(0xFFebefea),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF036042), width: 1.5),
                    image: (provider['img']?.toString().isNotEmpty == true || provider['image']?.toString().isNotEmpty == true)
                        ? DecorationImage(
                            image: NetworkImage(provider['img'] ?? provider['image'] ?? ''),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: (provider['img']?.toString().isNotEmpty != true && provider['image']?.toString().isNotEmpty != true)
                      ? Icon(Icons.store, size: 40, color: isDark ? Colors.white54 : const Color(0xFF3f4943))
                      : null,
                ),
                if (isVerified)
                  Positioned(
                    bottom: -2,
                    right: -2,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00462f),
                        shape: BoxShape.circle,
                        border: Border.all(color: surfaceColor, width: 2),
                      ),
                      child: const Icon(Icons.verified, size: 14, color: Colors.white),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              provider['name'] ?? '',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: textColor,
                                height: 1.1,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.star, size: 14, color: Colors.amber),
                                const SizedBox(width: 2),
                                Text(
                                  provider['rating'] ?? '4.9',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '(128 reseñas)',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: secondaryTextColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      // Favorite Button
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.8),
                          shape: BoxShape.circle,
                          boxShadow: [
                            if (!isDark)
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
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
                                content: const Text('Eliminado de favoritos', style: TextStyle(fontWeight: FontWeight.bold)),
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 14, color: secondaryTextColor),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          provider['distance'] ?? 'Texcoco, Edo. de México',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: secondaryTextColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: tags.take(3).map((tag) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFebefea),
                        border: Border.all(color: isDark ? Colors.white24 : const Color(0xFFbec9c1)),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        tag,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark ? const Color(0xFF89d6b0) : const Color(0xFF036042),
                          letterSpacing: 0.2,
                        ),
                      ),
                    )).toList(),
                  ),
                ],
              ),
            ),
          ],
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
        color: isDark ? Colors.white.withOpacity(0.02) : const Color(0xFFebefea).withOpacity(0.3), // surface-container/30
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : const Color(0xFFbec9c1).withOpacity(0.4),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_add_alt_1, size: 48, color: isDark ? Colors.white24 : const Color(0xFF00462f).withOpacity(0.3)),
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
              color: isDark ? Colors.white54 : const Color(0xFF3f4943).withOpacity(0.7),
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
