import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../data/global_state.dart';

class _Vendor {
  final String name;
  final String category;
  final String location;
  final String imageUrl;
  final bool isVerified;

  _Vendor({
    required this.name,
    required this.category,
    required this.location,
    required this.imageUrl,
    required this.isVerified,
  });
}

class FollowedSellersScreen extends StatefulWidget {
  const FollowedSellersScreen({super.key});

  @override
  State<FollowedSellersScreen> createState() => _FollowedSellersScreenState();
}

class _FollowedSellersScreenState extends State<FollowedSellersScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animController.forward();
  }

  void _filterVendors(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animController.dispose();
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
    final secondaryTextColor = isDark ? const Color(0xFF89d6b0) : const Color(0xFF486456);
    final outlineVariant = isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFbec9c1).withValues(alpha: 0.2);

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
          'Siguiendo',
          style: GoogleFonts.plusJakartaSans(
            color: isDark ? const Color(0xFF89d6b0) : primaryGreen,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: ValueListenableBuilder<List<Map<String, dynamic>>>(
        valueListenable: globalFollowedSellers,
        builder: (context, followedList, child) {
          final allVendors = followedList.map((m) => _Vendor(
            name: m['name'] ?? '',
            category: m['category'] ?? m['tags'] ?? 'General',
            location: m['location'] ?? m['distance'] ?? 'México',
            imageUrl: m['imageUrl'] ?? m['img'] ?? m['image'] ?? '',
            isVerified: m['isVerified'] ?? m['verified'] ?? true,
          )).toList();

          final filteredVendors = allVendors.where((vendor) {
            final query = _searchQuery.toLowerCase();
            if (query.isEmpty) return true;
            return vendor.name.toLowerCase().contains(query) ||
                vendor.category.toLowerCase().contains(query) ||
                vendor.location.toLowerCase().contains(query);
          }).toList();

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Bar
                  _buildAnimatedItem(_buildSearchBar(isDark, surfaceColor, outlineVariant), 0),
                  const SizedBox(height: 24),

                  _buildAnimatedItem(
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'PROVEEDORES QUE SIGUES',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                            color: secondaryTextColor,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: (isDark ? const Color(0xFF89d6b0) : primaryGreen).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${allVendors.length} PROVEEDORES',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: isDark ? const Color(0xFF89d6b0) : primaryGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                    1,
                  ),
                  const SizedBox(height: 16),

                  // Vendor List
                  if (filteredVendors.isEmpty)
                    _buildAnimatedItem(
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40.0),
                          child: Column(
                            children: [
                              Icon(Icons.search_off, size: 48, color: secondaryTextColor.withValues(alpha: 0.5)),
                              const SizedBox(height: 16),
                              Text(
                                'No se encontraron productores',
                                style: GoogleFonts.plusJakartaSans(
                                  color: secondaryTextColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      2,
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredVendors.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final vendor = filteredVendors[index];
                        return _buildAnimatedItem(
                          _buildVendorCard(
                            context: context,
                            name: vendor.name,
                            category: vendor.category,
                            location: vendor.location,
                            imageUrl: vendor.imageUrl,
                            isVerified: vendor.isVerified,
                            isDark: isDark,
                            surfaceColor: surfaceColor,
                          ),
                          index + 2,
                        );
                      },
                    ),

                  const SizedBox(height: 32),
                  _buildAnimatedItem(
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'PROVEEDORES RECOMENDADOS',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                            color: secondaryTextColor,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Ver todos',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isDark ? const Color(0xFF89d6b0) : primaryGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                    (filteredVendors.isEmpty ? 1 : filteredVendors.length) + 2,
                  ),
                  const SizedBox(height: 16),
                  _buildAnimatedItem(
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          _buildRecommendedProviderCard(
                            name: 'Finca La Esperanza',
                            location: 'Texcoco, México',
                            rating: '4.9',
                            reviewsCount: '128',
                            followersCount: '1.2k',
                            productsCount: '850+',
                            imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDYy_wBWRMtvtLajakKrrKPNIlcQcH3iJr_Z9HfQ_dEp6cjXpdIyFY3Z-gNjyPf36hTjjftK6sNHZv1j9xQyQvGW7ob_6ihEdu8ir_2o27ey0EJCZmRfSIn_kMfGqc_bKTnM1AP54Q9CmZj6z2SkM5o94z12hz3FlYXEdP0FIWAw4uMrbDeWYdIUiwiBObEcBqS6wqa5xWWmyeOxFlv2ljkLJyMdUhCire0X6IazwKUoZWsgUq8PfulnAXr28WK3CQ19zeUyMmqXI0',
                            isDark: isDark,
                          ),
                          const SizedBox(width: 16),
                          _buildRecommendedProviderCard(
                            name: 'Rancho el Olvido',
                            location: 'Xochimilco, CDMX',
                            rating: '4.8',
                            reviewsCount: '95',
                            followersCount: '800',
                            productsCount: '120',
                            imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDarjIdbjAMkh6HlyDLKLjV_2yKMpY4YMrl63fQt9tsh5e-zrnkOpDS5PcWn4IpUHDbf_R5cZICdwTw6cUjN7jBzIJgds0UzmhiV5_9WfVF12I0CClgPF81A3fM04Xs5ZuPegrW0xC2kAMfBIE40nonjIrRDsLKWaD_yjvE18QiSC1DZTSOTaSBOi0QfgLjr8NizuJllOlLX9AxF_Fn41GhS573VrGb93jYgYjqC_79ed-5BL1pq_SqTl3GambrjZNwgVWF7JMpOBA',
                            isDark: isDark,
                          ),
                          const SizedBox(width: 16),
                          _buildRecommendedProviderCard(
                            name: 'Huerta Los Arcos',
                            location: 'Metepec, México',
                            rating: '4.7',
                            reviewsCount: '210',
                            followersCount: '2.1k',
                            productsCount: '450',
                            imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDYy_wBWRMtvtLajakKrrKPNIlcQcH3iJr_Z9HfQ_dEp6cjXpdIyFY3Z-gNjyPf36hTjjftK6sNHZv1j9xQyQvGW7ob_6ihEdu8ir_2o27ey0EJCZmRfSIn_kMfGqc_bKTnM1AP54Q9CmZj6z2SkM5o94z12hz3FlYXEdP0FIWAw4uMrbDeWYdIUiwiBObEcBqS6wqa5xWWmyeOxFlv2ljkLJyMdUhCire0X6IazwKUoZWsgUq8PfulnAXr28WK3CQ19zeUyMmqXI0',
                            isDark: isDark,
                          ),
                          const SizedBox(width: 16),
                          _buildRecommendedProviderCard(
                            name: 'Lácteos El Caporal',
                            location: 'Tequisquiapan, Qro',
                            rating: '4.9',
                            reviewsCount: '340',
                            followersCount: '3.5k',
                            productsCount: '56',
                            imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDarjIdbjAMkh6HlyDLKLjV_2yKMpY4YMrl63fQt9tsh5e-zrnkOpDS5PcWn4IpUHDbf_R5cZICdwTw6cUjN7jBzIJgds0UzmhiV5_9WfVF12I0CClgPF81A3fM04Xs5ZuPegrW0xC2kAMfBIE40nonjIrRDsLKWaD_yjvE18QiSC1DZTSOTaSBOi0QfgLjr8NizuJllOlLX9AxF_Fn41GhS573VrGb93jYgYjqC_79ed-5BL1pq_SqTl3GambrjZNwgVWF7JMpOBA',
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ),
                    (filteredVendors.isEmpty ? 1 : filteredVendors.length) + 3,
                  ),
                  const SizedBox(height: 80), // Extra space for bottom navigation
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar(bool isDark, Color surfaceColor, Color outlineVariant) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1c2c26) : const Color(0xFFf1f4f0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.transparent),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _filterVendors,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          color: isDark ? Colors.white : Colors.black87,
        ),
        decoration: InputDecoration(
          icon: Icon(Icons.search, size: 20, color: isDark ? Colors.white38 : Colors.grey),
          hintText: 'Buscar entre mis vendedores...',
          hintStyle: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: isDark ? Colors.white38 : Colors.grey[600],
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildVendorCard({
    required BuildContext context,
    required String name,
    required String category,
    required String location,
    required String imageUrl,
    required bool isVerified,
    required bool isDark,
    required Color surfaceColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
                  color: isDark ? const Color(0xFF1a2f26) : const Color(0xFFebefea),
                  image: imageUrl.isNotEmpty
                      ? (imageUrl.startsWith('http')
                          ? DecorationImage(
                              image: NetworkImage(imageUrl),
                              fit: BoxFit.cover,
                            )
                          : (imageUrl.startsWith('assets/')
                              ? DecorationImage(
                                  image: AssetImage(imageUrl),
                                  fit: BoxFit.cover,
                                )
                              : null))
                      : null,
                ),
                child: (!imageUrl.startsWith('http') && !imageUrl.startsWith('assets/'))
                    ? Icon(
                        Icons.storefront,
                        size: 32,
                        color: isDark ? const Color(0xFF89d6b0) : const Color(0xFF00462f),
                      )
                    : null,
              ),
              if (isVerified)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Color(0xFF00462f),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.verified, size: 12, color: Colors.white),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: isDark ? Colors.white : const Color(0xFF181d1a),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFcaead7),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    category,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF042015),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      location.toUpperCase(),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => _showUnfollowDialog(context, name, isDark),
            style: TextButton.styleFrom(
              backgroundColor: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFf1f4f0),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              foregroundColor: isDark ? Colors.white70 : const Color(0xFF3f4943),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check, size: 14),
                const SizedBox(width: 6),
                Text(
                  'Siguiendo',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showUnfollowDialog(BuildContext context, String name, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1c2c26) : Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¿Dejar de seguir?',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF181d1a),
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Ya no recibirás actualizaciones de $name en tu feed principal.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      height: 1.5,
                      color: isDark ? Colors.grey[400] : Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        toggleFollowSeller({'name': name});
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Has dejado de seguir a $name'),
                            backgroundColor: const Color(0xFF00462f),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            margin: const EdgeInsets.all(12),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFe57373),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(
                        'DEJAR DE SEGUIR',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  borderRadius: BorderRadius.circular(99),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      Icons.close,
                      size: 20,
                      color: isDark ? Colors.white38 : Colors.grey[400],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendedProviderCard({
    required String name,
    required String location,
    required String rating,
    required String reviewsCount,
    required String followersCount,
    required String productsCount,
    required String imageUrl,
    required bool isDark,
  }) {
    final cardColor = isDark ? const Color(0xFF1c2c26) : Colors.white;
    final secondaryBg = isDark ? const Color(0xFF0f231d) : const Color(0xFFf1f4f0);
    final primaryGreen = isDark ? const Color(0xFF89d6b0) : const Color(0xFF00462f);
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.withValues(alpha: 0.1);
    final textColor = isDark ? Colors.white : const Color(0xFF181d1a);
    final subtitleColor = isDark ? Colors.grey[400] : Colors.grey[600];

    return Container(
      width: 320, // Set fixed width for horizontal scroll
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
                        color: isDark ? const Color(0xFF1a2f26) : const Color(0xFFebefea),
                        image: imageUrl.isNotEmpty
                            ? (imageUrl.startsWith('http')
                                ? DecorationImage(
                                    image: NetworkImage(imageUrl),
                                    fit: BoxFit.cover,
                                  )
                                : (imageUrl.startsWith('assets/')
                                    ? DecorationImage(
                                        image: AssetImage(imageUrl),
                                        fit: BoxFit.cover,
                                    )
                                    : null))
                            : null,
                      ),
                      child: (!imageUrl.startsWith('http') && !imageUrl.startsWith('assets/'))
                          ? Icon(
                              Icons.storefront,
                              size: 32,
                              color: isDark ? const Color(0xFF89d6b0) : const Color(0xFF00462f),
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: -2,
                      right: -2,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00462f),
                          shape: BoxShape.circle,
                          border: Border.all(color: cardColor, width: 2),
                        ),
                        child: const Icon(Icons.verified, size: 12, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: textColor,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined, size: 16, color: subtitleColor),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                color: subtitleColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, size: 14, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              rating,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '($reviewsCount reviews)',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: subtitleColor,
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
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.only(top: 16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: borderColor)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: secondaryBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'SEGUIDORES',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                              color: subtitleColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            followersCount,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: primaryGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: secondaryBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'NEGOCIACIONES',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                              color: subtitleColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            productsCount,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
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
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: Icon(
                  Icons.person_add_alt_1,
                  size: 18,
                  color: isDark ? const Color(0xFF002114) : Colors.white,
                ),
                label: Text(
                  'Seguir',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isDark ? const Color(0xFF002114) : Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
