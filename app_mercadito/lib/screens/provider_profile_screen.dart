import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/product_card.dart';
import '../widgets/skeleton_loading.dart';
import '../widgets/animated_favorite_button.dart';
import '../data/global_state.dart';

class ProviderProfileScreen extends StatefulWidget {
  final Map<String, dynamic> provider;

  const ProviderProfileScreen({super.key, required this.provider});

  @override
  State<ProviderProfileScreen> createState() => _ProviderProfileScreenState();
}

class _ProviderProfileScreenState extends State<ProviderProfileScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Simulate initial load for Skeleton effect
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0f231d) : const Color(0xFFf5f8f7),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: _isLoading 
            ? _buildSkeletonLoader(context)
            : DefaultTabController(
                length: 3,
                child: NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) {
                    return [
                      // Header Section (Banner, Top Nav, and overlapping Avatar)
                      SliverToBoxAdapter(
                        child: Column(
                          children: [
                            Stack(
                              clipBehavior: Clip.none,
                              alignment: Alignment.bottomCenter,
                              children: [
                                // Banner
                                _EntranceAnimation(
                                  delay: 0,
                                  child: Container(
                                    height: 240,
                                    margin: const EdgeInsets.only(bottom: 50),
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.only(
                                        bottomLeft: Radius.circular(32),
                                        bottomRight: Radius.circular(32),
                                      ),
                                      image: DecorationImage(
                                        image: NetworkImage(widget.provider['banner'] ?? widget.provider['img'] ?? ''),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                                // Dark gradient overlay
                                Positioned(
                                  top: 0, left: 0, right: 0, height: 100,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(32),
                                        bottomRight: Radius.circular(32),
                                      ),
                                      gradient: LinearGradient(
                                        colors: [Colors.black54, Colors.transparent],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                    ),
                                  ),
                                ),
                                // Top Navigation
                                Positioned(
                                  top: 16, left: 16, right: 16,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: Colors.white,
                                        child: IconButton(
                                          icon: const Icon(Icons.arrow_back, color: Colors.black),
                                          onPressed: () => context.pop(),
                                        ),
                                      ),
                                      const Text(
                                        'Proveedor',
                                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                                      ),
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: Colors.white,
                                            child: IconButton(
                                              icon: const Icon(Icons.verified, color: Colors.blue),
                                              onPressed: () {},
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          ValueListenableBuilder<List<Map<String, dynamic>>>(
                                            valueListenable: globalFavoriteProviders,
                                            builder: (context, favorites, child) {
                                              final isFav = isFavoriteProvider(widget.provider['name'] ?? '');
                                              return AnimatedFavoriteButton(
                                                isFavorite: isFav,
                                                size: 24,
                                                onTap: () {
                                                  toggleFavoriteProvider(widget.provider);
                                                  ScaffoldMessenger.of(context).clearSnackBars();
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        isFav 
                                                          ? 'Eliminado de favoritos' 
                                                          : 'Agregado a favoritos',
                                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                                      ),
                                                      backgroundColor: isFav ? Colors.red : theme.colorScheme.primary,
                                                      behavior: SnackBarBehavior.floating,
                                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                                      duration: const Duration(seconds: 2),
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                // Square Profile Avatar
                                Positioned(
                                  bottom: 0,
                                  child: _EntranceAnimation(
                                    delay: 200,
                                    type: EntranceType.scale,
                                    child: Hero(
                                      tag: widget.provider['name'],
                                      child: Container(
                                        width: 100,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          color: isDark ? const Color(0xFF0f231d) : Colors.white,
                                          borderRadius: BorderRadius.circular(16),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.1),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                          image: (widget.provider['img']?.toString().isNotEmpty == true)
                                              ? DecorationImage(
                                                  image: NetworkImage(widget.provider['img'] ?? ''),
                                                  fit: BoxFit.cover,
                                                )
                                              : null,
                                        ),
                                        child: (widget.provider['img']?.toString().isNotEmpty != true)
                                            ? Icon(
                                                Icons.storefront,
                                                size: 48,
                                                color: isDark ? const Color(0xFF89d6b0) : const Color(0xFF00462f),
                                              )
                                            : null,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            // Provider Info
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: Column(
                                children: [
                                  _EntranceAnimation(
                                    delay: 300,
                                    child: Text(widget.provider['name'] ?? '', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                                  ),
                                  const SizedBox(height: 4),
                                  _EntranceAnimation(
                                    delay: 400,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.location_on, size: 16, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Text(widget.provider['distance'] ?? '', style: const TextStyle(color: Colors.grey)),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 8),
                                  _EntranceAnimation(
                                    delay: 500,
                                    child: Text(
                                      widget.provider['tags'] ?? '',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: theme.colorScheme.primary,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  _EntranceAnimation(
                                    delay: 550,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: isDark ? const Color(0xFF16251E) : const Color(0xFFEAF2E8),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: isDark ? const Color(0xFF23352B) : theme.colorScheme.primary.withValues(alpha: 0.2),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.sell_outlined,
                                            size: 14,
                                            color: isDark ? const Color(0xFF8BD8B2) : theme.colorScheme.primary,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            widget.provider['salesType'] ?? 'Al Detalle',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: isDark ? const Color(0xFF8BD8B2) : theme.colorScheme.primary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  _EntranceAnimation(
                                    delay: 600,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        _buildStatColumn(Icons.star, widget.provider['rating'] ?? '', 'Valoración', isIcon: true),
                                        _buildStatColumn(null, widget.provider['traded'] ?? '', 'Ventas'),
                                        _buildStatColumn(null, '15', 'Productos'),
                                      ],
                                    ),
                                  ),
                                  // Action buttons
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _EntranceAnimation(
                                          delay: 700,
                                          child: ValueListenableBuilder<List<Map<String, dynamic>>>(
                                            valueListenable: globalFollowedSellers,
                                            builder: (context, followedList, child) {
                                              final isFollowing = isFollowingSeller(widget.provider['name'] ?? '');
                                              return ElevatedButton.icon(
                                                onPressed: () {
                                                  toggleFollowSeller(widget.provider);
                                                  ScaffoldMessenger.of(context).clearSnackBars();
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        isFollowing 
                                                          ? 'Dejaste de seguir a ${widget.provider['name']}' 
                                                          : 'Ahora sigues a ${widget.provider['name']}',
                                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                                      ),
                                                      backgroundColor: const Color(0xFF00462f),
                                                      behavior: SnackBarBehavior.floating,
                                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                                      duration: const Duration(seconds: 2),
                                                    ),
                                                  );
                                                },
                                                icon: Icon(
                                                  isFollowing ? Icons.check : Icons.person_add_outlined,
                                                  size: 18,
                                                ),
                                                label: Text(
                                                  isFollowing ? 'Siguiendo' : 'Seguir',
                                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                                ),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: isFollowing
                                                      ? const Color(0xFF00462f)
                                                      : theme.colorScheme.primary.withValues(alpha: 0.1),
                                                  foregroundColor: isFollowing
                                                      ? Colors.white
                                                      : theme.colorScheme.primary,
                                                  elevation: 0,
                                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _EntranceAnimation(
                                          delay: 800,
                                          child: ElevatedButton.icon(
                                            onPressed: () {
                                              context.push('/chat-detail', extra: widget.provider);
                                            },
                                            icon: const Icon(Icons.chat_bubble_outline, size: 18),
                                            label: const Text('Chat', style: TextStyle(fontWeight: FontWeight.bold)),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: theme.colorScheme.primary,
                                              foregroundColor: Colors.white,
                                              elevation: 0,
                                              padding: const EdgeInsets.symmetric(vertical: 12),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                            ),
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
                      // TabBar Pinned
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: _SliverAppBarDelegate(
                          tabBar: TabBar(
                            labelColor: theme.colorScheme.primary,
                            unselectedLabelColor: Colors.grey,
                            indicatorColor: theme.colorScheme.primary,
                            indicatorWeight: 3,
                            tabs: const [
                              Tab(text: 'Productos'),
                              Tab(text: 'Reseñas'),
                              Tab(text: 'Información'),
                            ],
                          ),
                          color: isDark ? const Color(0xFF0f231d) : const Color(0xFFf5f8f7),
                        ),
                      ),
                    ];
                  },
                  body: TabBarView(
                    children: [
                      _buildProductsTab(context),
                      _buildReviewsTab(context),
                      _buildInfoTab(context),
                    ],
                  ),
                ),
              ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(IconData? icon, String value, String label, {bool isIcon = false}) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isIcon && icon != null) Icon(icon, color: Colors.amber, size: 16),
            if (isIcon && icon != null) const SizedBox(width: 4),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _buildProductsTab(BuildContext context) {
    // Mock data for Primera (4 products)
    final primera = [
      {'title': 'Fresas Extra', 'price': '8.500', 'unit': '/lb', 'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuCnW6_MorKLz7ezxkGcHG6rQjhSFNPk8HPgeIsUbUJgp9DUy5kB2jUbGf4NDVs02rHGeJ4ro5fC_o-CVgZdBbzfhnoIX6Oz-YBKAMbwvBnKt0DUNJfnQJ-4cR8YhjFg7n2YTsCUja9uRWf099e4MF7xhxHmzFwjLCdCgywatNoUU6oNbjKVFR4AvgIv8s4ecmGAnIR2EtLvlghaKIOjsvzYQBd-K2z9jJ0Zk9LsA0e7JsmFHImz82G7W_vMJG5zDP64iTEgJpRLJF0'},
      {'title': 'Zanahoria Orgánica', 'price': '3.200', 'unit': '/kg', 'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuAUP07pMS-fkGRl_e-A_ksfxKmrKWa-uMZFZ7hvjE42DscxBHwUsx6fScNLD5TRZrw8Uh6fGNy9JYfNt6iISLHMW5-uMUFqybHPkrQwig52Qn0dn7Rix-GwCC_XihkPXq3G1-sGNzsnk3yb8ZB3mcXS7lnPrYUf_ovpd-ND9zD970NSGVKIzVbzFZiEz2lcIUcI03Ezq9NjBZrvVnut5BAKWvqPARC1Cef9NKXci0FArJHZlt8dqNTLc9Zl80YSPAtDKDEH0cl8mEw'},
      {'title': 'Tomates Premium', 'price': '2.100', 'unit': '/lb', 'image': 'https://images.unsplash.com/photo-1592924357228-91a4daadc239?q=80&w=300&auto=format&fit=crop'},
      {'title': 'Lechuga Hidropónica', 'price': '1.500', 'unit': '/unidad', 'image': 'https://images.unsplash.com/photo-1622206151226-18ca2c9ab4a1?q=80&w=300&auto=format&fit=crop'},
    ];
    // Mock data for Segunda (2 products)
    final segunda = [
      {'title': 'Fresa Mediana', 'price': '5.500', 'unit': '/lb', 'image': 'https://images.unsplash.com/photo-1464965911861-746a04b4bca6?q=80&w=300&auto=format&fit=crop'},
      {'title': 'Zanahoria Estándar', 'price': '2.000', 'unit': '/kg', 'image': 'https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?q=80&w=300&auto=format&fit=crop'},
    ];
    // Mock data for Tercera (2 products)
    final tercera = [
      {'title': 'Hortalizas para Caldo', 'price': '2.000', 'unit': '/atado', 'image': 'https://images.unsplash.com/photo-1601648764658-cf37e8c89b70?q=80&w=300&auto=format&fit=crop'},
      {'title': 'Tomate para Guiso', 'price': '1.000', 'unit': '/lb', 'image': 'https://images.unsplash.com/photo-1518977676601-b53f82aba655?q=80&w=300&auto=format&fit=crop'},
    ];

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      children: [
        _buildSection(context, 'Calidad: Primera', 'PRIMERA', primera, isPrimera: true),
        const SizedBox(height: 24),
        _buildSection(context, 'Calidad: Segunda', 'SEGUNDA', segunda, isSegunda: true),
        const SizedBox(height: 24),
        _buildSection(context, 'Calidad: Tercera', 'TERCERA', tercera, isTercera: true),
      ],
    );
  }

  Widget _buildSection(BuildContext context, String title, String badgeText, List<Map<String, String>> items, {bool isPrimera = false, bool isSegunda = false, bool isTercera = false}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Header
    Widget header = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isPrimera 
                    ? theme.colorScheme.primary.withValues(alpha: 0.1)
                    : isSegunda 
                        ? const Color(0xFFFF8A5B).withValues(alpha: 0.15) // Mamey
                        : Colors.red.withValues(alpha: 0.1), // Tercera/Red
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                badgeText, 
                style: TextStyle(
                  fontSize: 10, 
                  fontWeight: FontWeight.bold, 
                  color: isPrimera 
                      ? theme.colorScheme.primary 
                      : isSegunda 
                          ? const Color(0xFFFF8A5B) // Mamey
                          : Colors.red[700] // Tercera/Red
                )
              ),
            ),
            const SizedBox(width: 4),
            TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () {},
              child: Text('Ver todo', style: TextStyle(color: theme.colorScheme.primary, fontSize: 12, fontWeight: FontWeight.bold)),
            )
          ]
        )
      ],
    );

    // List of items
    Widget content;
    if (isTercera) {
       // Tercera is a smaller horizontal list-tile style layout
       content = Column(
         children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final p = entry.value;
          return _EntranceAnimation(
            delay: 200 + (index * 100),
            child: GestureDetector(
              onTap: () => context.push('/product_detail', extra: {
                'name': p['title'],
                'price': p['price'],
                'unit': p['unit'],
                'image': p['image'],
                'quality': 'Tercera',
              }),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1a2f26) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(8),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(p['image']!, width: 60, height: 60, fit: BoxFit.cover),
                ),
                title: Text(p['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Mezcla surtida (tamaño irregular)', style: TextStyle(fontSize: 12, color: Colors.grey)), 
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('\$${p['price']}', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(_formatUnit(p['unit']!), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
            ),
          ));
        }).toList()
       );
    } else {
       // Primera and Segunda use product card grids
         content = GridView.builder(
           shrinkWrap: true,
           physics: const NeverScrollableScrollPhysics(),
           gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
             crossAxisCount: 2,
             crossAxisSpacing: 12,
             mainAxisSpacing: 12,
             mainAxisExtent: 205, // Fixed height specifically calculated to prevent empty space
           ),
           itemCount: items.length,
           itemBuilder: (context, index) {
             final p = items[index];
             return _EntranceAnimation(
               delay: 200 + (index * 100),
               child: GestureDetector(
                 onTap: () => context.push('/product_detail', extra: {
                   'name': p['title'],
                   'price': p['price'],
                   'unit': p['unit'],
                   'image': p['image'],
                   'quality': isPrimera ? 'Primera' : (isSegunda ? 'Segunda' : 'Tercera'),
                 }),
                 child: ProductCard(
                   imageUrl: p['image']!,
                   title: p['title']!,
                   price: p['price']!,
                   priceUnit: p['unit']!,
                 ),
               ),
             );
           },
       );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _EntranceAnimation(delay: 100, child: header),
        const SizedBox(height: 16),
        content,
      ],
    );
  }

  Widget _buildInfoTab(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF1a2f26) : Colors.white;
    final borderColor = Colors.grey.withValues(alpha: 0.1);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      children: [
        // Sobre el Vendedor
        _EntranceAnimation(
          delay: 100,
          child: Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.local_florist_outlined, color: theme.colorScheme.primary, size: 20),
                    const SizedBox(width: 8),
                    Text('SOBRE EL VENDEDOR', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: theme.colorScheme.primary, letterSpacing: 1.0)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Granja El Sol cuenta con más de 20 años cultivando productos orgánicos en el corazón del Valle de Santiago. Nuestro compromiso con la frescura comienza al amanecer; cada hortaliza es recolectada a mano solo horas antes de llegar a su mesa. Creemos en una agricultura regenerativa que respeta los ciclos de la tierra y garantiza el sabor más auténtico de nuestra región.',
                  style: TextStyle(fontSize: 14, height: 1.5, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),

        // Contacto
        _EntranceAnimation(
          delay: 200,
          child: Container(
             padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Row(
                  children: [
                    Icon(Icons.call_outlined, color: theme.colorScheme.primary, size: 20),
                    const SizedBox(width: 8),
                     Text('CONTACTO', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: theme.colorScheme.primary, letterSpacing: 1.0)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                     Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         const Text('TELÉFONO DIRECTO', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.0)),
                         const SizedBox(height: 4),
                         const Text('+52 464 123 4567', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                       ],
                     ),
                       ElevatedButton.icon(
                         onPressed: () {},
                         icon: const Icon(Icons.chat, size: 16),
                         label: const Text('WHATSAPP', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.0)),
                         style: ElevatedButton.styleFrom(
                           backgroundColor: const Color(0xFF25D366),
                           foregroundColor: Colors.white,
                           elevation: 2,
                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                           minimumSize: Size.zero, 
                         ),
                       )
                  ],
                )
              ],
            )
          ),
        ),

        // Horarios
        _EntranceAnimation(
          delay: 300,
          child: Container(
             padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Row(
                  children: [
                    Icon(Icons.schedule, color: theme.colorScheme.primary, size: 20),
                    const SizedBox(width: 8),
                     Text('HORARIOS DE ATENCIÓN', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: theme.colorScheme.primary, letterSpacing: 1.0)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Lunes a Sábado', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('8:00 AM - 6:00 PM', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                    )
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Domingo', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[800] : Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('Cerrado', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                    )
                  ],
                ),
              ]
            )
          ),
        ),

        // Ubicación
        _EntranceAnimation(
          delay: 400,
          child: Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Row(
                  children: [
                    Icon(Icons.location_on_outlined, color: theme.colorScheme.primary, size: 20),
                    const SizedBox(width: 8),
                     Text('UBICACIÓN', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: theme.colorScheme.primary, letterSpacing: 1.0)),
                  ],
                ),
                const SizedBox(height: 12),
                const Text('Valle de Santiago, Guanajuato, México', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                     height: 180,
                     width: double.infinity,
                     child: Stack(
                       fit: StackFit.expand,
                       children: [
                          Image.network(
                            'https://lh3.googleusercontent.com/aida-public/AB6AXuBH7ADNB7QWvMbN33Gx_W3uAMM3kyaKNjbiBTi1fY3Sn5QlGIUG7Lfu93jpSklUVHqVn9uWyJrx-O7Kv6qwOzpFHvmeyi3gawpEQwgNo2qSJbINr_vDd-vX_eE51dy0VfjPJUd1hgMeFx3PKMmbJR4ZnDfevwnVv7g35h1NEG9lbvS3pvrQEruRanSbBeuKqi2unhwDtla0oV5ax8sxFHalcNqmYnSU_DgmqPp4VKU-sV1aO6TCrCo8PLcifbWHmKz8OaKVV_IyH7o',
                            fit: BoxFit.cover,
                          ),
                          Container(color: Colors.black.withValues(alpha: 0.1)),
                          const Center(child: Icon(Icons.location_on, color: Colors.red, size: 40)),
                          Positioned(
                            bottom: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                 color: isDark ? Colors.grey[900]!.withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.8),
                                 borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.open_in_new, size: 20, color: isDark ? Colors.white : Colors.black54),
                            )
                          )
                       ],
                     )
                  ),
                )
              ]
            )
          ),
        ),

        // Report
        _EntranceAnimation(
          delay: 500,
          child: Center(
            child: TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.report_outlined, size: 16, color: Colors.grey),
              label: const Text('REPORTAR VENDEDOR', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.5)),
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  String _formatUnit(String unit) {
    var raw = unit.replaceAll('/', '').toLowerCase();
    switch (raw) {
      case 'lb':
        return 'Por Libra';
      case 'kg':
        return 'Por Kilo';
      case 'unidad':
        return 'Por Unidad';
      case 'atado':
        return 'Por Atado';
      case 'caja':
        return 'Por Caja';
      case 'saco':
      case 'sacos':
        return 'Por Saco';
      default:
        // Capitalize first letter
        if (raw.isNotEmpty) {
          raw = raw[0].toUpperCase() + raw.substring(1);
        }
        return 'Por $raw';
    }
  }

  Widget _buildReviewsTab(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      children: [
        _EntranceAnimation(
          delay: 100,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Big Score (col-span-5 equivalent)
                Expanded(
                  flex: 5,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1a2f26) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('4.8', style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: theme.colorScheme.primary, height: 1.0)),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.star, color: theme.colorScheme.primary, size: 14),
                            Icon(Icons.star, color: theme.colorScheme.primary, size: 14),
                            Icon(Icons.star, color: theme.colorScheme.primary, size: 14),
                            Icon(Icons.star, color: theme.colorScheme.primary, size: 14),
                            Icon(Icons.star_half, color: theme.colorScheme.primary, size: 14),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text('128 RESEÑAS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.5)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Star Bars (col-span-7 equivalent)
                Expanded(
                  flex: 7,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0f231d) : const Color(0xFFf1f4f0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildStarBar(5, 0.85, theme),
                        const SizedBox(height: 8),
                        _buildStarBar(4, 0.10, theme),
                        const SizedBox(height: 8),
                        _buildStarBar(3, 0.03, theme),
                        const SizedBox(height: 8),
                        _buildStarBar(2, 0.01, theme),
                        const SizedBox(height: 8),
                        _buildStarBar(1, 0.01, theme),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Filters
        _EntranceAnimation(
          delay: 200,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('MÁS RECIENTES', true, theme),
                _buildFilterChip('CON FOTOS', false, theme),
                _buildFilterChip('ALTA CALIFICACIÓN', false, theme),
                _buildFilterChip('BAJA CALIFICACIÓN', false, theme),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Reviews List
        _EntranceAnimation(
          delay: 300,
          child: _buildReviewCard(
            context: context,
            name: 'Mariana Ortiz',
            date: 'hace 2 días',
            avatar: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBYJzD8Jv__HCofoE_9GXHz6ThLuAmE4GY780JgKF_CnF0e0Ag7eeBdUuo91rwB6Zu0SQvC0ZQxHfm-2ptRUB-8M06caS-RMrBIzj8QHpqkj5QX6vhBO9445gMwzqiu6Yt5juCbYloMuTe9AcbgO7tyDHdemyOCuU_oA7_LQpePOm4X00XfFhNY8SIY-x6DalOZ5-JMFeO2FTK_BoTu-2i9_A-FY9mHZui7BXNQCnwMBtaGINBTm0JmtYFeZAcAz2D5DX2EJlMSLnM',
            rating: 5,
            text: 'Los tomates llegaron frescos y a tiempo, excelente proveedor. La calidad es mucho mejor que la del supermercado tradicional.',
            images: [
              'https://lh3.googleusercontent.com/aida-public/AB6AXuBfAcdyVzjhfvN9bCOWgt1hQ64s4Hx-8jspVL2MsfJBefubpqPK10mJ5FHQdP5Asyxm_lL7ms8LgpEJZGwsf2ZkdV4H4QrFNK2fHOwcS3YMV_sc0UV-Z5tUSuho5AC1mK6ZN6CMLzpeJ-5DZPw5NDktO7wbqmNGnx0eioi__Is31kw3J_xbksGQjIt34jambbxhRB2oPS0BqU7HyozLkQPRfmQZxNHC4dkqvqe3-v5uil4IMQ8z8oAn23hB4ElnFsNIxIqyJaQWwdY',
              'https://lh3.googleusercontent.com/aida-public/AB6AXuCEBY6N0chL89FL7-rhhhwW_ggemOEv9BIecv0foRE0qNYml9czEo9CuAY2boBe2sUVluP7ouBl7Tms3r6vhfCRH1fgbJJRizEBAQLkonmgKyPJq-sUMMExfk9N4NDFzI508xE_Z6BCtPIy2xS4eGiMs64YiDOO0Hzf3YO-OofiyKSH9OB2J0YVUlYawViIAcFqk_1C-X0cbMRW0dIRDvrTRhxKwpugSFoY-vS6v_z0WL3o7HIKur7qd1mA0vbMt1R1j9bQId0Rm30'
            ],
            productBought: 'COMPRÓ: TOMATES SALADETTE',
            sellerResponse: '¡Muchas gracias por tu confianza Mariana! Nos esforzamos por seleccionar siempre lo mejor de la cosecha.',
          ),
        ),
        const SizedBox(height: 16),
        _EntranceAnimation(
          delay: 400,
          child: _buildReviewCard(
            context: context,
            name: 'Roberto G.',
            date: 'hace 1 semana',
            avatar: 'https://lh3.googleusercontent.com/aida-public/AB6AXuC86MsmWl10UM74dTqXN5cvWFEfmYUHsvKCR-y0wD2lYq9QbU1pPOuisx8V-kTEWaa2qDlT0WLBok7LgAyVI4oYfdDfTjkty2sjutfWf8TgR-dczjEg_hjEjyNx_Jt4gpAXDFR7Dgw2FV4_Lhg89Dm7gXQfTgCGY6TtUH9-Gra8NJFrRaoI6KS_t8z3wZKcmelvinox1Ah-7VlOqLa6B1FsrxJQwJPtzLlVN6e8tC5R9kIwziSN6peMLip0X-9igzwYS5lNu2tOSA0',
            rating: 4,
            text: 'Muy buen servicio. El aguacate estaba en su punto exacto. Solo un detalle con el empaque que venía un poco golpeado pero el producto intacto.',
            productBought: 'COMPRÓ: AGUACATE HASS PREMIUM',
          ),
        ),

        const SizedBox(height: 24),
        // Write Review CTA
        Center(
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.edit_note, size: 20),
            label: const Text('ESCRIBIR MI RESEÑA', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 2.0)),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildStarBar(int star, double percentage, ThemeData theme) {
    return Row(
      children: [
        SizedBox(width: 12, child: Text(star.toString(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 6,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(3),
            ),
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: percentage,
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? theme.colorScheme.primary : (theme.brightness == Brightness.dark ? const Color(0xFF1a2f26) : const Color(0xFFf1f4f0)),
        borderRadius: BorderRadius.circular(20),
        border: isSelected ? null : Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.grey[700],
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildReviewCard({
    required BuildContext context,
    required String name,
    required String date,
    required String avatar,
    required int rating,
    required String text,
    List<String>? images,
    required String productBought,
    String? sellerResponse,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1a2f26) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(avatar),
                    radius: 20,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text(date, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
              Row(
                children: List.generate(5, (index) => Icon(
                  index < rating ? Icons.star : Icons.star_border,
                  color: index < rating ? theme.colorScheme.primary : (isDark ? Colors.grey[700] : Colors.grey[300]),
                  size: 14,
                )),
              )
            ],
          ),
          const SizedBox(height: 12),
          // Text
          Text(text, style: TextStyle(fontSize: 14, color: isDark ? Colors.grey[400] : Colors.grey[600], height: 1.5)),
          const SizedBox(height: 12),
          // Images if any
          if (images != null && images.isNotEmpty) ...[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: images.map((img) => Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(img, width: 80, height: 80, fit: BoxFit.cover),
                  ),
                )).toList(),
              ),
            ),
            const SizedBox(height: 12),
          ],
          // Product bought tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0f231d) : const Color(0xFFf1f4f0),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.shopping_basket, size: 12, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(productBought, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
              ],
            ),
          ),
          // Seller Response if any
          if (sellerResponse != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0f231d) : const Color(0xFFebefea),
                borderRadius: BorderRadius.circular(12),
                border: Border(left: BorderSide(color: theme.colorScheme.primary, width: 4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.reply, size: 14, color: theme.colorScheme.primary),
                      const SizedBox(width: 4),
                      Text('RESPUESTA DE EL MERCADITO', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: theme.colorScheme.primary, letterSpacing: 1.0)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(sellerResponse, style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: isDark ? Colors.grey[400] : Colors.grey[600])),
                ],
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildSkeletonLoader(BuildContext context) {
    return SkeletonShimmer(
      child: ListView(
        primary: false,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          // Banner Skeleton
          const SkeletonContainer(
            height: 240,
            width: double.infinity,
            customBorderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -50),
            child: Column(
              children: [
                // Avatar Circle Skeleton
                const SkeletonContainer(
                  width: 100,
                  height: 100,
                  borderRadius: 16,
                ),
                const SizedBox(height: 12),
                // Name Skeleton
                const SkeletonContainer(width: 180, height: 24, borderRadius: 4),
                const SizedBox(height: 8),
                // Subtitle Skeleton
                const SkeletonContainer(width: 120, height: 16, borderRadius: 4),
                const SizedBox(height: 24),
                // Stats Row Skeleton
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(3, (index) => const SkeletonContainer(width: 60, height: 40, borderRadius: 8)),
                ),
                const SizedBox(height: 24),
                // Buttons Skeleton
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Expanded(child: SkeletonContainer(height: 48, borderRadius: 12)),
                      const SizedBox(width: 12),
                      const Expanded(child: SkeletonContainer(height: 48, borderRadius: 12)),
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
}

enum EntranceType { fade, slide, scale }

class _EntranceAnimation extends StatefulWidget {
  final Widget child;
  final int delay;
  final EntranceType type;

  const _EntranceAnimation({
    required this.child,
    required this.delay,
    this.type = EntranceType.slide,
  });

  @override
  State<_EntranceAnimation> createState() => _EntranceAnimationState();
}

class _EntranceAnimationState extends State<_EntranceAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _offset;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.65, curve: Curves.easeOut)),
    );

    _offset = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 1.0, curve: Curves.easeOutQuart)),
    );

    _scale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 1.0, curve: Curves.easeOutBack)),
    );

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: widget.type == EntranceType.scale
          ? ScaleTransition(scale: _scale, child: widget.child)
          : SlideTransition(position: _offset, child: widget.child),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({required this.tabBar, required this.color});

  final TabBar tabBar;
  final Color color;

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: color,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return oldDelegate.color != color || oldDelegate.tabBar != tabBar;
  }
}
