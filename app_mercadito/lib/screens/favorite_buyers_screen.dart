import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../data/global_state.dart';
import 'buyer_profile_screen.dart';

class FavoriteBuyersScreen extends StatefulWidget {
  const FavoriteBuyersScreen({super.key});

  @override
  State<FavoriteBuyersScreen> createState() => _FavoriteBuyersScreenState();
}

class _FavoriteBuyersScreenState extends State<FavoriteBuyersScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _selectedTabIndex = 0; // 0: Mis Favoritos, 1: Explorar Compradores

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
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
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Interval((index * 0.08).clamp(0.0, 1.0), 1.0, curve: Curves.easeOutCubic),
    ));
    final fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Interval((index * 0.08).clamp(0.0, 1.0), 1.0, curve: Curves.easeOutCubic),
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

    const primaryGreen = Color(0xFF016042);
    final bgColor = isDark ? const Color(0xFF0F1713) : const Color(0xFFF7FAF7);
    final cardColor = isDark ? const Color(0xFF16231D) : Colors.white;
    final borderColor = isDark ? const Color(0xFF22382E) : const Color(0xFFE2E8F0);

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
          'Compradores Favoritos',
          style: GoogleFonts.plusJakartaSans(
            color: isDark ? const Color(0xFF89d6b0) : primaryGreen,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: ValueListenableBuilder<List<Map<String, dynamic>>>(
        valueListenable: globalFavoriteBuyers,
        builder: (context, favorites, _) {
          return ValueListenableBuilder<List<Map<String, dynamic>>>(
            valueListenable: globalMarketplaceBuyers,
            builder: (context, allBuyers, _) {
              final currentList = _selectedTabIndex == 0 ? favorites : allBuyers;

              final filteredList = currentList.where((b) {
                final query = _searchQuery.toLowerCase().trim();
                if (query.isEmpty) return true;
                final name = (b['name'] ?? '').toString().toLowerCase();
                final id = (b['id'] ?? '').toString().toLowerCase();
                final location = (b['location'] ?? '').toString().toLowerCase();
                final businessType = (b['businessType'] ?? '').toString().toLowerCase();
                final products = (b['frequentProducts'] as List?)?.join(' ').toLowerCase() ?? '';
                final categories = (b['frequentCategories'] as List?)?.join(' ').toLowerCase() ?? '';

                return name.contains(query) ||
                    id.contains(query) ||
                    location.contains(query) ||
                    businessType.contains(query) ||
                    products.contains(query) ||
                    categories.contains(query);
              }).toList();

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Buscador
                    _buildAnimatedItem(
                      _buildSearchBar(isDark, cardColor, borderColor, primaryGreen),
                      0,
                    ),
                    const SizedBox(height: 12),

                    // Selector de Pestañas (Mis Favoritos / Explorar Compradores)
                    _buildAnimatedItem(
                      _buildTabSelector(favorites.length, allBuyers.length, isDark, primaryGreen, borderColor),
                      1,
                    ),
                    const SizedBox(height: 16),

                    if (filteredList.isEmpty)
                      _buildAnimatedItem(
                        _buildEmptyState(isDark, cardColor, borderColor, primaryGreen),
                        2,
                      )
                    else ...[
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredList.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final buyer = filteredList[index];
                          return _buildAnimatedItem(
                            _buildBuyerCard(
                              context: context,
                              buyer: buyer,
                              isDark: isDark,
                              cardColor: cardColor,
                              borderColor: borderColor,
                              primaryGreen: primaryGreen,
                            ),
                            index + 2,
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      if (_selectedTabIndex == 0 && favorites.isNotEmpty)
                        _buildAnimatedItem(
                          _buildExplorePromptCard(isDark, cardColor, borderColor, primaryGreen),
                          filteredList.length + 3,
                        ),
                    ],
                    const SizedBox(height: 80),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSearchBar(bool isDark, Color cardColor, Color borderColor, Color primaryGreen) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) {
          setState(() {
            _searchQuery = val;
          });
        },
        style: GoogleFonts.plusJakartaSans(
          fontSize: 13.5,
          color: isDark ? Colors.white : Colors.black87,
        ),
        decoration: InputDecoration(
          hintText: 'Buscar comprador por nombre, ID o producto...',
          hintStyle: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.grey[500] : Colors.grey[400],
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: isDark ? const Color(0xFF89d6b0) : primaryGreen,
            size: 22,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildTabSelector(
    int favoritesCount,
    int allCount,
    bool isDark,
    Color primaryGreen,
    Color borderColor,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildTabChip(
            label: 'Mis Favoritos',
            count: favoritesCount,
            isSelected: _selectedTabIndex == 0,
            onTap: () {
              setState(() {
                _selectedTabIndex = 0;
              });
            },
            isDark: isDark,
            primaryGreen: primaryGreen,
            borderColor: borderColor,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildTabChip(
            label: 'Buscar Compradores',
            count: allCount,
            isSelected: _selectedTabIndex == 1,
            onTap: () {
              setState(() {
                _selectedTabIndex = 1;
              });
            },
            isDark: isDark,
            primaryGreen: primaryGreen,
            borderColor: borderColor,
          ),
        ),
      ],
    );
  }

  Widget _buildTabChip({
    required String label,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
    required Color primaryGreen,
    required Color borderColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryGreen
              : (isDark ? const Color(0xFF16231D) : Colors.white),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? primaryGreen : borderColor,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primaryGreen.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 11.5,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? Colors.grey[300] : Colors.grey[700]),
                ),
              ),
            ),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.25)
                    : (isDark ? const Color(0xFF0F231D) : const Color(0xFFE8F6F0)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : primaryGreen,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBuyerCard({
    required BuildContext context,
    required Map<String, dynamic> buyer,
    required bool isDark,
    required Color cardColor,
    required Color borderColor,
    required Color primaryGreen,
  }) {
    final buyerId = (buyer['id'] ?? 'BUY-88291').toString();
    final buyerName = (buyer['name'] ?? 'Comprador').toString();
    final buyerAvatar = buyer['avatar'] as String?;
    final location = (buyer['location'] ?? '').toString();
    final distance = (buyer['distance'] ?? '').toString();
    final businessType = (buyer['businessType'] ?? '').toString();
    final rating = (buyer['rating'] ?? 4.9).toString();
    final negotiations = (buyer['negotiationsCount'] ?? 15).toString();
    final onTimePayment = (buyer['onTimePaymentPercent'] ?? 100).toString();
    final isFav = isFavoriteBuyer(buyerId) || isFavoriteBuyer(buyerName);
    final frequentProducts = (buyer['frequentProducts'] as List?)?.cast<String>() ?? [];

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => BuyerProfileScreen(buyer: buyer),
          ),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row superior: Avatar, Info principal, Botón favorito
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: primaryGreen.withValues(alpha: 0.15),
                      backgroundImage: (buyerAvatar != null && buyerAvatar.isNotEmpty)
                          ? NetworkImage(buyerAvatar)
                          : null,
                      child: (buyerAvatar == null || buyerAvatar.isEmpty)
                          ? Icon(Icons.person, color: primaryGreen, size: 28)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: primaryGreen,
                          shape: BoxShape.circle,
                          border: Border.all(color: cardColor, width: 1.5),
                        ),
                        child: const Icon(Icons.verified, size: 10, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              buyerName,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF0F231D) : const Color(0xFFE8F6F0),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              buyerId.startsWith('#') ? buyerId : '#$buyerId',
                              style: TextStyle(
                                fontFamily: 'Courier',
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: isDark ? const Color(0xFF89d6b0) : primaryGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (businessType.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          businessType,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                      if (location.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined, size: 12, color: Colors.grey[500]),
                            const SizedBox(width: 2),
                            Expanded(
                              child: Text(
                                '$location • $distance',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 10.5,
                                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: isFav ? const Color(0xFFE11D48) : Colors.grey[400],
                    size: 22,
                  ),
                  onPressed: () {
                    toggleFavoriteBuyer(buyer);
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Métricas Rápidas en Píldoras
            Row(
              children: [
                _buildMiniMetric(
                  icon: Icons.star_rounded,
                  iconColor: const Color(0xFFF2A439),
                  text: '$rating ★',
                  isDark: isDark,
                ),
                const SizedBox(width: 6),
                _buildMiniMetric(
                  icon: Icons.handshake_outlined,
                  iconColor: isDark ? const Color(0xFF89d6b0) : primaryGreen,
                  text: '$negotiations tratos',
                  isDark: isDark,
                ),
                const SizedBox(width: 6),
                _buildMiniMetric(
                  icon: Icons.payments_outlined,
                  iconColor: const Color(0xFF10B981),
                  text: '$onTimePayment% puntual',
                  isDark: isDark,
                ),
              ],
            ),

            if (frequentProducts.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 5,
                runSpacing: 4,
                children: frequentProducts
                    .take(3)
                    .map(
                      (p) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0F231D) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: borderColor),
                        ),
                        child: Text(
                          p,
                          style: TextStyle(
                            fontSize: 10,
                            color: isDark ? Colors.grey[300] : Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMiniMetric({
    required IconData icon,
    required Color iconColor,
    required String text,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F231D) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: iconColor),
          const SizedBox(width: 3.5),
          Text(
            text,
            style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, Color cardColor, Color borderColor, Color primaryGreen) {
    final isSearching = _searchQuery.isNotEmpty;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSearching
                  ? Colors.amber.withValues(alpha: 0.1)
                  : primaryGreen.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isSearching ? Icons.search_off_rounded : Icons.favorite_border_rounded,
              size: 40,
              color: isSearching ? const Color(0xFFF2A439) : primaryGreen,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isSearching
                ? 'Sin resultados para "$_searchQuery"'
                : (_selectedTabIndex == 0
                    ? 'Aún no tienes compradores favoritos'
                    : 'No hay compradores disponibles'),
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isSearching
                ? 'Prueba con otro término de búsqueda como el nombre o ID del cliente.'
                : 'Marca con un corazón a tus compradores de confianza para acceder rápido a sus perfiles y cotizaciones.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          if (!isSearching && _selectedTabIndex == 0) ...[
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _selectedTabIndex = 1;
                });
              },
              icon: const Icon(Icons.person_search_rounded, size: 16),
              label: const Text('Explorar Compradores'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildExplorePromptCard(
    bool isDark,
    Color cardColor,
    Color borderColor,
    Color primaryGreen,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F231D) : const Color(0xFFE8F6F0),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: primaryGreen.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: primaryGreen.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.travel_explore_rounded, color: primaryGreen, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¿Buscas nuevos clientes?',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  'Encuentra compradores verificados en tu zona y agrégalos a favoritos.',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () {
              setState(() {
                _selectedTabIndex = 1;
              });
            },
            icon: Icon(Icons.arrow_forward_rounded, color: primaryGreen),
          ),
        ],
      ),
    );
  }
}
